%Q4.3. 4.4. 4.5. 

close all;
clear all;

%% Define constant variables
% HOMOGRAPHY = 'ORG';
% HOMOGRAPHY = 'NORM';
HOMOGRAPHY = 'RANSAC';
NUMPOINTS = 10;

%% Read images
cv_cover = imread('../data/cv_cover.jpg');
cv_desk = imread('../data/cv_desk.png');

%% Get matches points
[locs1, locs2] = matchPics(cv_cover, cv_desk);

%% Calculate fundamental matrix
if strcmp(HOMOGRAPHY, 'ORG')
    H2to1 = computeH(locs1, locs2);
end

if strcmp(HOMOGRAPHY, 'NORM')
    H2to1 = computeH_norm(locs1, locs2);
end

if strcmp(HOMOGRAPHY, 'RANSAC')
    [H2to1, ransac_inliers] = computeH_ransac(locs1, locs2);
end

%% Display based on randomly selected points
matched = [];

% Choose random pixels from an image
% Adapted from: https://www.mathworks.com/matlabcentral/answers/349246-sample-random-pixels-from-multiple-region-of-interests-from-an-image
p = randperm(numel(cv_cover), NUMPOINTS);
[r,c] = ind2sub(size(cv_cover), p);

sample_points = [r; c];

for i = 1:NUMPOINTS
    % linear equation for each correspondence
    calc = H2to1 * [sample_points(:,i);1];
    % rescaling
    matched = [matched; [calc(1)/calc(3),calc(2)/calc(3)]];
end

fig = showMatchedFeatures(cv_cover, cv_desk, sample_points', matched, 'montage');
title("With " + HOMOGRAPHY + " homography");
saveas(fig,"../results/homography_" + HOMOGRAPHY +".png")
