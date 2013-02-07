function texturereport(im, pdnormal, pdtexture),

feat = features(im2double(im), 8);

ihognormal = invertHOG(feat, pdnormal);
ihogtexture = invertHOGtexture(feat, pdtexture);

im = imresize(im2double(im), [size(ihognormal,1) size(ihognormal,2)]);
im(im > 1) = 1;
im(im < 0) = 0;

ihognormal = repmat(ihognormal, [1 1 3]);
ihogtexture = repmat(ihogtexture, [1 1 3]);

ihognormal = padarray(ihognormal, [0 10], 1, 'post');
ihogtexture = padarray(ihogtexture, [0 10], 1, 'post');

graphic = cat(2, ihogtexture, ihognormal, im);

imagesc(graphic);
