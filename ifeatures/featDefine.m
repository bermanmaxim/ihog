clear hog
clear hoglegacy

hog.sbin=8;
hog.encode=@(im) features(im,hog.sbin);
hog.channels=32; %18 contrast-insensitive, 9 contrast-sensitive, 4 textures
hog.nfeat=@(size) round(size/hog.sbin)-2; %number of features in 1 direction of length size

hogM.sbin=8;
hogM.encode=@(im) HOGM(im,hogM.sbin);
hogM.channels=31; % 9 contrast-insensitive * 4 normalizations
hogM.nfeat=@(size) fix((size-2*hogM.sbin-1)/hogM.sbin)+1; %number of features in 1 direction of length size

hoglegacy.sbin=8;
hoglegacy.encode=@(im) HOGlegacy(im,hoglegacy.sbin);
hoglegacy.channels=36; % 9 contrast-insensitive * 4 normalizations
hoglegacy.nfeat=@(size) fix((size-2*hoglegacy.sbin-1)/hoglegacy.sbin)+1; %number of features in 1 direction of length size

daisy.sbin=15;
daisy.RQ=2; %number of rings
daisy.TQ=5; %number of histograms per ring
daisy.HQ=3; %number of bins per histogram
daisy.encode=@(im) compute_daisy_grid(im, daisy.sbin,...
    daisy.RQ, daisy.TQ, daisy.HQ);
daisy.channels=(daisy.RQ*daisy.TQ+1)*daisy.HQ;
daisy.nfeat=@(size) fix((size-2*daisy.sbin-1)/daisy.sbin)+1;

bigdaisy.sbin=15;
bigdaisy.RQ=2; %number of rings
bigdaisy.TQ=5; %number of histograms per ring
bigdaisy.HQ=9; %number of bins per histogram
bigdaisy.encode=@(im) compute_daisy_grid(im, bigdaisy.sbin,...
    bigdaisy.RQ, bigdaisy.TQ, bigdaisy.HQ);
bigdaisy.channels=(bigdaisy.RQ*bigdaisy.TQ+1)*bigdaisy.HQ;
bigdaisy.nfeat=@(size) fix((size-2*bigdaisy.sbin-1)/bigdaisy.sbin)+1;

