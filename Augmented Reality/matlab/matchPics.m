function [ locs1, locs2] = matchPics( I1, I2 )
%MATCHPICS Extract features, obtain their descriptors, and match them!
THRESHOLD = 10.0;
MAXRATIO = 0.68;
% DESCRIPTOR = 'SURF';
DESCRIPTOR = 'BRIEF';

%% Convert images to grayscale, if necessary

[~, ~, nC1] = size(I1);
[~, ~, nC2] = size(I2);
if nC1 > 1
    I1 = rgb2gray(I1);
end
I1 = double(I1) / 255;

if nC2 > 1
    I2 = rgb2gray(I2);
end
I2 = double(I2) / 255;

%% Validate DESCRIPTOR method

if strcmp(DESCRIPTOR, 'BRIEF')
    %% Detect features in both images
    I1_p = detectFASTFeatures(I1);
    I2_p = detectFASTFeatures(I2);

    %% Obtain descriptors for the computed feature locations
    [I1_descriptors, I1_p] = computeBrief(I1, I1_p.Location);
    [I2_descriptors, I2_p] = computeBrief(I2, I2_p.Location);
end

if strcmp(DESCRIPTOR, 'SURF')
    I1_p = detectSURFFeatures(I1);
    I2_p = detectSURFFeatures(I2);
    
    [I1_descriptors, I1_p] = extractFeatures(I1, I1_p, 'Method', 'SURF');
    [I2_descriptors, I2_p] = extractFeatures(I2, I2_p, 'Method', 'SURF');
end

%% Match features using the descriptors

matches = matchFeatures(I1_descriptors, I2_descriptors, 'MatchThreshold', THRESHOLD,'MaxRatio', MAXRATIO);

locs1 = I1_p(matches(:,1),:);
locs2 = I2_p(matches(:,2),:);
end

