% learn2dict(feature, stream, n, k, p, ny, nx, lambda, iters, fast, color)
%
% This function learns a pair of dictionaries 'dgray' and 'dhog' to allow for
% regression between a feature and grayscale images.
%
% Arguments:
%   feature   A structure describing the descriptor
%   source    List of filepaths where images are located; if number, uses
%   random triangles instead
%   n         Number of window patches to extract in total (set to k if fast=true)
%   k         The size of the dictionary
%   p         use a subset of p images in the source (-1 for infinity)
%   ny, nx    The size of the template patch to invert
%   lambda    Sparsity regularization parameter on alpha
%   iters     Number of iterations
%   fast      If true, agregate a dictionary in real time (default false)
%   color     If true, learn color information as well (default false)
% 
% Returns a struct with fields:
%   dgray     A dictionary of gray elements
%   dhog      A dictionary of HOG elements

function pd = learn2dict(feature, source, n, k, p, ny, nx, lambda, iters, fast, color)

if ~ischar(source)
    color=false;
end
if ~exist('n', 'var'),
   n = 1000000;
end
if ~exist('k', 'var'),
  k = 1024;
end
if ~exist('p', 'var'),
  p = -1;
end
if ~exist('ny', 'var'),
  ny = 5;
end
if ~exist('nx', 'var'),
  nx = 5;
end
if ~exist('lambda', 'var'),
  lambda = 0.02; % 0.02 is best so far
end
if ~exist('iters', 'var'),
  iters = 500;
end
if ~exist('fast', 'var'),
  fast = true;
%  fast = true;
end
if ~exist('color', 'var'),
  color = false;
end
if fast==true,
    n=k;
end

graysize = (ny+2)*(nx+2)*feature.sbin^2*(1+2*color);

t = tic;

%if(exist('current_data.mat','file')),
%    load('current_data.mat','data','trainims');
%else

if ~ischar(source)
    trainims={};
    data = gettriangles(feature, source, n, [ny nx]);
else
    [data, trainims] = getdata(feature, source, n, p, [ny nx], color);
end

fprintf('ifeat: normalize\n');
for i=1:size(data,2),
  data(1:graysize, i) = data(1:graysize, i) - mean(data(1:graysize, i));
  data(1:graysize, i) = data(1:graysize, i) / (sqrt(sum(data(1:graysize, i).^2) + eps));
  data(graysize+1:end, i) = data(graysize+1:end, i) - mean(data(graysize+1:end, i));
  data(graysize+1:end, i) = data(graysize+1:end, i) / (sqrt(sum(data(graysize+1:end, i).^2) + eps));
end

%save('current_data.mat','data','trainims');

%end

if fast,
  dict = data; 
else
  dict = lasso(data, k, iters, lambda);
end

pd.dgray = dict(1:graysize, :);
pd.dfeat = dict(graysize+1:end, :);
pd.feat=feature;
pd.n = n;
pd.k = k;
pd.ny = ny;
pd.nx = nx;
pd.iters = iters;
pd.lambda = lambda;
pd.trainims = trainims;
pd.color = color;

fprintf('ifeat: paired dictionaries learned in %0.3fs\n', toc(t));

end


% lasso(data)
%
% Learns the pair of dictionaries for the data terms.
function dict = lasso(data, k, iters, lambda),

param.K = k;
param.lambda = lambda;
param.mode = 2;
param.modeD = 0;
param.iter = 50;
param.numThreads = 4;
param.verbose = 1;
param.batchsize = 400;
param.posAlpha = true;
if exist('precomp_D','var'),
    param.D=precomp_D;
end

fprintf('ifeat: lasso\n');
model = struct();
for i=1:(iters/param.iter),
  fprintf('ifeat: lasso: master iteration #%i/%i\n', i,iters/param.iter);
  [dict, model] = mexTrainDL(data, param, model);
  model.iter = i*param.iter;
  param.D = dict;
%  save('current_computation.mat','i','dict','model');
end

end

% getdata(stream, n, dim, sbin)
%
% Reads in the stream and extracts windows along with their HOG features.
function [data, images] = getdata(feature, streamdir, n, p, dim, color)

ny = dim(1);
nx = dim(2);
sbin=feature.sbin;

graysize = (ny+2)*(nx+2)*sbin^2*(1+2*color);
featsize = ny*nx*feature.channels;

fprintf('ifeat: allocating data store: %.02fGB\n', ...
        (graysize + featsize)*n*4/1024/1024/1024);
data = zeros(graysize + featsize, n, 'single');

[stream,order] = resolverandstream(streamdir,feature,dim,p);
if n>size(order,1),
    fprintf('\n');
    fprintf('ihog: warning: wrapping around dataset!\n');
end
neworder=randperm(size(order,1))'; % choose random window computation
neworder=neworder(1:min(n,size(order,1)));
order=order(neworder,:); % truncate window computation to required number of windows
[~,reorder]=sort(order(:,1)); %re-sort by image to compute features once by image
order=order(reorder,:);

fprintf('ifeat: loading data: ');

imcurrent=0;
for k=1:size(order,1),
    if mod(k,50)==0,
        fprintf('%i/%i\n',k,size(order,1));
    end
    if order(k,1)~=imcurrent, % changing picture
        imcurrent=order(k,1);
        im = double(imread(stream{imcurrent})) / 255.;
        evalc('feat = feature.encode(im)');  % Ils entraînaient sur du gris : pas très gentil pour HOG
        if ~color,
            im = mean(im,3);
        end
    end
    i=order(k,2); j=order(k,3);
    featpoint = feat(i:i+ny-1, j:j+nx-1, :);       % ERREUR CORRIGEE taille ny -> nx
    graypoint = im((i-1)*sbin+1:(i+1+ny)*sbin, (j-1)*sbin+1:(j+1+nx)*sbin, :);
    data(:, k) = single([graypoint(:); featpoint(:)]);
end

images=stream(unique(order(:,1)));
end

function data = gettriangles(feature, ntriangles, n, dim)

ny = dim(1);
nx = dim(2);
sbin=feature.sbin;

graysize = (ny+2)*(nx+2)*sbin^2;
featsize = ny*nx*feature.channels;

fprintf('ifeat: allocating data store: %.02fGB\n', ...
        (graysize + featsize)*n*4/1024/1024/1024);
data = zeros(graysize + featsize, n, 'single');

for k=1:n,
    if mod(k,50)==0,
        fprintf('%i/%i\n',k,n);
    end
    im=randomtriangles( ny, nx, sbin, ntriangles );
    feat = feature.encode(repmat(im, [1 1 3]));
    data(:, k) = single([im(:); feat(:)]);
end

end
