close all;
clear all;

%% Define Descriptor - SURF/BRIEF

% DESCRIPTOR = 'SURF';
DESCRIPTOR = 'BRIEF';

%% Read the image and convert to grayscale, if necessary

I = imread('../data/cv_cover.jpg');

% No need converting to grayscale, it will be done in `matchPics`

%% Compute the features and descriptors
count = 36;
countOfMatches = [];
orientations = []; 

for i = 0:count
    %% Rotate image
    I_rotated = imrotate(I, i*10);
    orientations = [orientations, i*10];
    
    %% Compute features and descriptors, Match features
    [locs1, locs2] = matchPics(I, I_rotated);

    %% Update histogram
    [currentMatches, ~] = size(locs1);
    countOfMatches = [countOfMatches, currentMatches];
    
    if i == 1  || i == 5 || i == 9 || i == 18
        showMatchedFeatures(I, I_rotated, locs1, locs2, 'montage');
        saveas(gcf, ['../results/Matches_' DESCRIPTOR '_' num2str(i) '.png'])
    end
    
end

%% Display histogram
bar(orientations, countOfMatches);
title("With " + DESCRIPTOR + " Descriptor");
xlabel('Orientation');
ylabel('Count of matches');
saveas(gcf,"../results/Hist_" + DESCRIPTOR +".png")



