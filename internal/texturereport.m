function texturereport(im, pdnormal, pdtexture),

im = imread(im);

feat = features(im2double(im), 8);

ihognormal = invertHOG(feat, pdnormal);
ihogtexture = invertHOGtexture(feat, pdtexture);

im = imresize(im2double(im), [size(ihognormal,1) size(ihognormal,2)]);
im(im > 1) = 1;
im(im < 0) = 0;

ihognormal = repmat(ihognormal, [1 1 3]);
ihogtexture = repmat(ihogtexture, [1 1 3]);

graphic = cat(2, ihogtexture, ihognormal, im);

imagesc(graphic);
