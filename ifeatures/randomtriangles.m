function [ im ] = randomtriangles( ny, nx, sbin, ntriangles )
ry = (ny+2)*sbin;
rx = (nx+2)*sbin;
im = 0.5 * ones(ry, rx);
core = tril(ones(max(ry, rx)));

for k=1:ntriangles,
  rot = rand() * 360;             % rotate
  w = floor(rand() * sbin*4)+1;   % width
  h = floor(rand() * sbin*4)+1;   % height
  x = floor(rand() * rx);         % center x
  y = floor(rand() * ry);         % center y 
  int = (rand()-0.5) * 0.5;       % intensity
  trial = imrotate(core, rot);
  trial = imresize(trial, [h w]);
  trial = int * trial;
  % calculate position in reconstruction from center of triangle
  ix = floor(x - w/2);
  iy = floor(y - h/2);

  if ix+w > rx,
    trial = trial(:, 1:end-(ix+w-rx));
    w = rx-ix;
  end
  if iy+h > ry,
    trial = trial(1:end-(iy+h-ry), :);
    h = ry-iy;
  end

  if ix < 1,
    trial = trial(:, 1-ix:end);
    w = w-(1-ix)+1;
    ix = 1;
  end
  if iy < 1,
    trial = trial(1-iy:end, :);
    h = h-(1-iy)+1;
    iy = 1;
  end
  im(iy:iy+h-1, ix:ix+w-1) = im(iy:iy+h-1, ix:ix+w-1) + trial;
  im(im > 1) = 1;
  im(im < 0) = 0;
% candidate = reconstruction;
%  candidate(iy:iy+h-1, ix:ix+w-1) = candidate(iy:iy+h-1, ix:ix+w-1) + trial;
%  candidate(candidate > 1) = 1;
%  candidate(candidate < 0) = 0;
end
end

