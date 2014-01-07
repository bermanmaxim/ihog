% ifeat(feat, pd)
%
% This function recovers the natural image that may have generated the
% feature 'feat'.
%
% This function should take no longer than a second to invert any reasonably sized
% HOG feature point on a 12 core machine.
function im = ifeat(feat, pd)

sbin=pd.feat.sbin;

par = max(pd.ny,pd.nx);

feat = padarray(feat, [par par 0], 0);

[ny, nx, ~] = size(feat);

% pad feat with 0s if not big enough
if size(feat,1) < pd.ny,
  feat = padarray(feat, [pd.ny - size(feat,1) 0 0], 0, 'post');
end
if size(feat,2) < pd.nx,
  feat = padarray(feat, [0 pd.nx - size(feat,2) 0], 0, 'post');
end

% extract every window 
windows = zeros(pd.ny*pd.nx*pd.feat.channels, (ny-pd.ny+1)*(nx-pd.nx+1));
c = 1;
for i=1:size(feat,1) - pd.ny + 1,
  for j=1:size(feat,2) - pd.nx + 1,
    part = feat(i:i+pd.ny-1, j:j+pd.nx-1, :);
    part = part(:) - mean(part(:));
    part = part(:) / sqrt(sum(part(:).^2) + eps);
    windows(:,c)  = part(:);
    c = c + 1;
  end
end

% solve lasso problem % http://spams-devel.gforge.inria.fr/doc/html/doc_spams005.html
param.lambda = pd.lambda;
param.mode = 2; % scaled norm mode
param.pos = true; % non-negativity constraints
a = full(mexLasso(single(windows), pd.dfeat, param));
recon = pd.dgray * a;

% reconstruct
fil     = fspecial('gaussian', [(pd.ny+2)*sbin (pd.nx+2)*sbin], 9);
%fil     = fspecial('average', [(pd.ny+2)*sbin (pd.nx+2)*sbin]);
%fil     = zeros([(pd.ny+2)*sbin (pd.nx+2)*sbin]);
%fil(((pd.ny-1)/2+1)*sbin:((pd.ny+1)/2+1)*sbin, ((pd.nx-1)/2+1)*sbin:((pd.nx+1)/2+1)*sbin-1) = 1;
%fil = fil / sum(fil(:)); % normaliser le filtre à 1

im      = zeros((size(feat,1)+2)*sbin, (size(feat,2)+2)*sbin, 1+2*pd.color);
weights = zeros((size(feat,1)+2)*sbin, (size(feat,2)+2)*sbin);
c = 1;
for i=1:size(feat,1) - pd.ny + 1,
  for j=1:size(feat,2) - pd.nx + 1,
    patch = reshape(recon(:, c), [(pd.ny+2)*sbin (pd.nx+2)*sbin 1+2*pd.color]);
    patch = bsxfun(@times,fil,patch);

    iii = (i-1)*sbin+1:(i-1)*sbin+(pd.ny+2)*sbin;
    jjj = (j-1)*sbin+1:(j-1)*sbin+(pd.nx+2)*sbin;

    im(iii, jjj, :) = im(iii, jjj, :) + patch;
    weights(iii, jjj) = weights(iii, jjj) + 1;

    c = c + 1;
  end
end

% post processing averaging and clipping
im = bsxfun(@rdivide,im,weights);
im = im(1:(ny+2)*sbin, 1:(nx+2)*sbin, :);
im(:) = im(:) - min(im(:));
im(:) = im(:) / max(im(:));

im = im(par*sbin:end-par*sbin-1, par*sbin:end-par*sbin-1, :);
