clc;
close all;

% evaluateRecognitionSystem_NN.m
% evaluates your nearest neighbor recognition system on the test images

%% Load traintest.mat
load('../data/traintest.mat', 'train_labels', 'test_imagenames', 'test_labels', 'mapping');
T = size(test_imagenames, 2);
dictionarySize = size(dictionary, 1);

%% Calculate with random points

load('visionRandom.mat', 'trainFeatures');
trainFeaturesRandom = trainFeatures;

% report 8 × 8 confusion matrix C, where entry C(i,j) is
% number of times an image of actual class i was classified as class j.

% initialize 8 x 8 confusion matrix C
C_euc_random = zeros(8);
C_chi_random = zeros(8);

for i = 1:T
    
    mat = strrep(strcat('../data/random/', test_imagenames{i}),'.jpg','.mat');
    load(mat, 'wordMap');
    im_features = getImageFeatures(wordMap, dictionarySize);
        
    % random & euclidean
    im_dist = getImageDistance(im_features, trainFeaturesRandom, 'euclidean');
    [~, ind] = min(im_dist);
    C_euc_random(test_labels(i), train_labels(ind)) = C_euc_random(test_labels(i), train_labels(ind)) + 1;
    
    % random & chi2    
    im_dist = getImageDistance(im_features, trainFeaturesRandom, 'chi2');
    [~, ind] = min(im_dist);
    C_chi_random(test_labels(i), train_labels(ind)) = C_chi_random(test_labels(i), train_labels(ind)) + 1;
end

%% Calculate with harris points
load('visionHarris.mat', 'trainFeatures');
trainFeaturesHarris = trainFeatures;

% initialize 8 x 8 confusion matrix C
C_euc_harris = zeros(8);
C_chi_harris = zeros(8);

for i = 1:T    
    mat = strrep(strcat('../data/harris/', test_imagenames{i}),'.jpg','.mat');
    load(mat, 'wordMap');
    im_features = getImageFeatures(wordMap, K);
    
    % random & euclidean
    im_dist = getImageDistance(im_features, trainFeaturesHarris, 'euclidean');
    [~, ind] = min(im_dist);
    C_euc_harris(test_labels(i), train_labels(ind)) = C_euc_harris(test_labels(i), train_labels(ind)) + 1;
    
    % random & chi2    
    im_dist = getImageDistance(im_features, trainFeaturesHarris, 'chi2');
    [~, ind] = min(im_dist);
    C_chi_harris(test_labels(i), train_labels(ind)) = C_chi_harris(test_labels(i), train_labels(ind)) + 1;
end

%% print results

% for each combination of dictionary and distance metric
% print out the confusion metric and the confusion matrix
% report both the accuracy

disp('random & euclidean result:')

disp('confusion:')
disp(C_euc_random)
disp('accuracy:')
disp(trace(C_euc_random)/T)

disp('random & chi2 result:')

disp('confusion:')
disp(C_chi_random)
disp('accuracy:')
disp(trace(C_chi_random)/T)

disp('harris & euclidean result:')
disp('confusion:')
disp(C_euc_harris)
disp('accuracy:')
disp(trace(C_euc_harris)/T)

disp('harris & chi2 result:')
disp('confusion:')
disp(C_chi_harris)
disp('accuracy:')
disp(trace(C_chi_harris)/T)
% 
% 
% random & euclidean result:
% confusion:
%     14     3     1     1     0     0     0     1
%      4    12     2     0     1     1     0     0
%      5     4     7     1     1     1     1     0
%      2     2     0     8     2     0     4     2
%      1     3     1     3     7     0     4     1
%      3     4     2     4     0     3     1     3
%      3     0     1     7     1     0     7     1
%      5     0     0     4     0     0     0    11
% 
% accuracy:
%     0.4313
% 
% random & chi2 result:
% confusion:
%     14     2     2     0     0     0     0     2
%      3    12     3     0     1     1     0     0
%      2     5    13     0     0     0     0     0
%      0     2     2     6     1     3     4     2
%      0     4     3     2     9     0     2     0
%      2     2     3     0     2     8     2     1
%      2     1     3     5     1     0     5     3
%      4     0     0     3     0     0     0    13
% 
% accuracy:
%     0.5000
% 
% harris & euclidean result:
% confusion:
%     10     3     3     2     1     0     0     1
%      5    12     1     0     2     0     0     0
%      9     2     7     1     1     0     0     0
%      1     3     1     7     0     1     5     2
%      1     1     3     1     8     0     6     0
%      1     4     2     5     0     4     2     2
%      1     1     0     6     2     2     7     1
%      2     0     1     2     0     0     0    15
% 
% accuracy:
%     0.4375
% 
% harris & chi2 result:
% confusion:
%     13     1     3     0     0     0     0     3
%      6    11     0     0     1     1     1     0
%      5     2     9     0     3     0     1     0
%      1     2     2     7     0     1     6     1
%      1     2     2     0    12     0     3     0
%      0     4     3     2     0     7     1     3
%      1     0     2     3     2     1     9     2
%      4     0     0     1     0     0     0    15
% 
% accuracy:
%     0.5188
