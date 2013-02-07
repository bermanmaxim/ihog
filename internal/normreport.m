% reportcard(in, out, pd)
%
% Processes every image in input directory 'in' and outputs
% the inversion to 'out' using the paired dictionary 'pd'. This
% is useful for diagnosis purposes.
function reportcard(in, out, pdnorm, pdnonorm),

images = dir(in);
images = images(randperm(length(images)));

for i=1:length(images);
  if ~images(i).isdir,
    output = sprintf('%s/%s', out, images(i).name);

    if exist(output, 'file'),
      fprintf('skip %s\n', output);
      continue;
    end
    if exist([output '.lock'], 'dir'),
      fprintf('skip locked %s\n', output);
      continue;
    end
    mkdir([output '.lock']);

    filepath = [in '/' images(i).name];
    im = double(imread(filepath)) / 255.;

    featnorm = features(im, 8, 1);
    ihognorm = invertHOG(featnorm, pdnorm);

    featnonorm = features(im, 8, 0);
    ihognonorm = invertHOG(featnonorm, pdnonorm);

    im = imresize(im, [size(ihognorm, 1) size(ihognorm, 2)]);
    im(im > 1) = 1;
    im(im < 0) = 0;

    ihognorm = padarray(ihognorm, [0 10], 1, 'post');
    ihognonorm = padarray(ihognonorm, [0 10], 1, 'post');

    ihognorm = repmat(ihognorm, [1 1 3]);
    ihognonorm = repmat(ihognonorm, [1 1 3]);

    graphic = cat(2, ihognonorm, ihognorm, im);

    imagesc(graphic);
    axis image;
    drawnow;

    imwrite(graphic, output);

    fprintf('processed %s\n', filepath);

    rmdir([output '.lock']);
  end
end
