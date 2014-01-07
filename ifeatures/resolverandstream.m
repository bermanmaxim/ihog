function [stream,order] = resolverandstream(streamdir,feature,dim,p),

order=zeros(128,3);

if isstr(streamdir),
  fprintf('ifeat: reading images from directory: %s\n', streamdir);
  directory = streamdir;
  files = dir(streamdir);
  if p<1,
      perm = randperm(numel(files));
      perm = perm(1:min(end,p));
      files = files(perm);
  end
  c = 1;
  d = 1;
  for f=1:length(files);
    if ~files(f).isdir,
      stream{c} = [directory '/' files(f).name];
      info=imfinfo(stream{c});
      imax=feature.nfeat(info.Height) - dim(1);
      jmax=feature.nfeat(info.Width) - dim(2);
      for i=1:imax,
          for j=1:jmax,
              if d>size(order,1), % dynamic preallocation
                  order(end+1:2*end,:)=0;
                 % fprintf('window allocated size : %i\n',size(order,1));
              end
              order(d,1:3) = [c i j];
              d = d+1;
          end
      end
      c = c + 1;
    end
  end
  order(d:end,:)=[];
  fprintf('ifeat: stream resolved to %i windows over %i images\n', d-1, c-1);
  
end
