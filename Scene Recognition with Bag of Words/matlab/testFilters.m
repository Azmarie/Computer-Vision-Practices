clc;
close all;

image = imread('../data/desert/sun_aijjkofxcvbaoewh.jpg');

[filterBank] = createFilterBank();
filterResponses = extractFilterResponses(image,filterBank);

% figure; imshow(image); hold on;
filter = 4;
scale = 2;
ind = 5*(filter-1) + scale;
% figure; imshow(uint8(rescale(filterResponses(:,:,3*(ind-1)+1),0,255))); hold on;
% figure; imshow(uint8(rescale(filterResponses(:,:,3*(ind-1)+2),0,255))); hold on;
figure; imshow(uint8(rescale(filterResponses(:,:,3*(ind-1)+3),0,255))); hold on;
