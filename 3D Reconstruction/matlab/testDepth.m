clear all ;
% Load image and paramters
im1 = imread('../data/im1.png');
im2 = imread('../data/im2.png');
im1 = rgb2gray(im1);
im2 = rgb2gray(im2);
load('rectify2.mat', 'M1', 'M2', 'K1n', 'K2n', 'R1n', 'R2n', 't1n', 't2n');

maxDisp = 20; 
windowSize = 3;
dispM = get_disparity(im1, im2, maxDisp, windowSize);

% Get depth map
depthM = get_depth(dispM, K1n, K2n, R1n, R2n, t1n, t2n);

% Display
figure; imagesc(dispM.*(im1>40)); colormap(gray); axis image;
saveas(gcf, '../results/4-dispM.png')

figure; imagesc(depthM.*(im1>40)); colormap(gray); axis image;
saveas(gcf, '../results/5-depthM.png')
