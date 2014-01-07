clear hog

hog.sbin=8;
%hog.xoffset=8;
%hog.yoffset=8;
hog.encode=@(im) features(im,hog.sbin);
hog.channels=32; %18 contrast-insensitive, 9 contrast-sensitive, 4 textures
hog.nfeat=@(size) round(size/hog.sbin)-2; %number of features in 1 direction of length size

save('hog.mat', 'hog');