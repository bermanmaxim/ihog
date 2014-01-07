%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Written and (C) by                                                      %
% Engin Tola                                                              %
%                                                                         %
% web   : http://cvlab.epfl.ch/~tola/                                     %
% email : engin.tola@epfl.ch                                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This code is a matlab implementation of the algorithm presented in the
% paper titled 'A Fast Local Descriptor for Dense Matching' by Engin Tola,
% Vincent Lepetit and Pascal Fua published in the proceedings of the
% Computer Vision and Pattern Recognition 2008 Conference.
%
% Please give a reference to that paper if you use this code in any
% academic work.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Source code is available under the GNU General Public License. In short,
% if you distribute a software that uses DAISY, you have to distribute it 
% under GPL with the source code. Another option is to contact us to 
% purchase a commercial license.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% See the usage.matlab document about the details on how to use this code
% and some warnings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [outfeat] = compute_daisy_grid(image, R, RQ, TQ, HQ, SI, LI, NT)

%%
if nargin == 5
    SI = 1;
    LI = 1;
    NT = 1;
elseif nargin == 1
    R  = 15;
    RQ = 3;
    TQ = 8;
    HQ = 8;
    SI = 1;
    LI = 1;
    NT = 1;
end

[dzy] = init_daisy(image,R,RQ,TQ,HQ,SI,LI,NT);

o = 0; % which orientation to compute the descriptors

fprintf(1,'computing descriptors ');
tic;
dzy.descs = mex_compute_all_descriptors(dzy.H, dzy.params, dzy.ogrid(:,:,o+1), dzy.ostable, single(o) )';
time_dc=toc;
fprintf(1,'is done in %f sec\n',time_dc);

[Y,X,~]=size(image);
j=1;
for y=R+1:R:Y-R,
    i=1;
    for x=R+1:R:X-R,
        outfeat(j,i,:) = reshape(display_descriptor(dzy,j,i),(RQ*TQ+1)*HQ,1);
        i=i+1;
    end
    j=j+1;
end



