clear all; close all; clc;

tiffFileName = 'xy01_02';

%ViewImageStack(ReadTiffStack(['../im/',  tiffFileName, '.tif']));

sResults = SAM(true, tiffFileName);
nFrames = numel(sResults{1});

lengths = zeros(nFrames, 1);
imPreThr = zeros(nFrames, numel(sResults{1}(1).imPreThr(:)));
for k=1:nFrames
    CC2 = sResults{1}(k).CC2;
    s = regionprops(CC2,{'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Orientation'});

    centroids2 = cat(1, s.Centroid);
    lengths2 = cat(1, s.MajorAxisLength);
    y_coordinate = centroids2(:,2);
    [values, indexes] = sort(y_coordinate);

    lengths(k) = lengths2(indexes(1));    

    imPreThr(k,:) = sResults{1}(k).imPreThr(:);
end

figure; cdfplot(imPreThr(:));
xlabel('enhanced pixel values');
xline(SAM_parameters().thr, 'r');
legend('cdf','binarization thr');
grid on


for k=1:nFrames
    display(['creating png ',int2str(k),' out of ',int2str(nFrames)])
    plot_sResults(sResults{1}(k), lengths)
end