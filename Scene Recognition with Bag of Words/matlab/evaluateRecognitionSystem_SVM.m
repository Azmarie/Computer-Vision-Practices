clc;
close all;

%% load mat files
load('../data/traintest.mat', 'train_labels', 'test_imagenames', 'test_labels', 'mapping');
T = size(test_imagenames, 2);

load('visionRandom.mat', 'dictionary', 'filterBank', 'trainFeatures');
% load('visionHarris.mat', 'dictionary', 'filterBank', 'trainFeatures');
dictionarySize = size(dictionary, 1);


%% get image features from training images
features = zeros(T, dictionarySize);

for i = 1:T
    mat = strrep(strcat('../data/random/', test_imagenames{i}),'.jpg','.mat');
    % mat = strrep(strcat('../data/harris/', test_imagenames{i}),'.jpg','.mat');
    load(mat, 'wordMap');
    features(i, :) = getImageFeatures(wordMap, dictionarySize);
end

%% generate template for SVM binary classifiers with kernel functions
t = templateSVM('KernelFunction','linear');
svm_linear = fitcecoc(trainFeatures, train_labels, 'Learners', t);

t = templateSVM('KernelFunction','gaussian');
svm_gaussian = fitcecoc(trainFeatures, train_labels, 'Learners', t);

t = templateSVM('KernelFunction','polynomial');
svm_poly = fitcecoc(trainFeatures, train_labels, 'Learners', t);

save('visionSVMRandom.mat', 'svm_linear', 'svm_gaussian', 'svm_poly');

%% SVM predict with linear
pred_labels = predict(svm_linear, features);
C = zeros(8);
for i = 1:T
    C(test_labels(i), pred_labels(i)) = C(test_labels(i), pred_labels(i)) + 1;
end

disp('SVM & linear:')
displayMetrics(C, T)


%% SVM predict with gaussian
pred_labels = predict(svm_gaussian, features);
C = zeros(8);

for i = 1:T
    C(test_labels(i), pred_labels(i)) = C(test_labels(i), pred_labels(i)) + 1;
end

disp('SVM & gaussian:')
displayMetrics(C, T)

%% SVM predict with polynomial
pred_labels = predict(svm_poly, features);
C = zeros(8);
for i = 1:T
    C(test_labels(i), pred_labels(i)) = C(test_labels(i), pred_labels(i)) + 1;
end

disp('SVM & polynomial:')
displayMetrics(C, T)

%% helper function: display confusion matrix and accuracy
function displayMetrics(confusion, T)
    disp('accuracy:')
    disp(trace(confusion)/T)
    disp('confusion:')
    disp(confusion)
end
% 
% Harris:
% 
% SVM & linear:
% accuracy:
%     0.4250
% 
% confusion:
%     12     5     2     0     0     0     0     1
%      5    14     0     0     0     0     1     0
%      4     5    10     0     1     0     0     0
%      3     1     1     5     0     0    10     0
%      0     5     3     0     5     0     7     0
%      7     2     3     3     0     0     4     1
%      5     0     2     0     4     0     9     0
%      5     1     0     1     0     0     0    13
% 
% SVM & gaussian:
% accuracy:
%     0.4875
% 
% confusion:
%     12     5     2     0     0     0     0     1
%      5    13     0     0     1     0     1     0
%      3     5    12     0     0     0     0     0
%      2     1     1     9     0     0     7     0
%      0     4     3     0     6     0     7     0
%      3     2     3     5     0     3     3     1
%      3     0     1     2     5     0     9     0
%      4     1     0     1     0     0     0    14
% 
% SVM & polynomial:
% accuracy:
%     0.5500
% 
% confusion:
%     13     5     1     0     0     0     0     1
%      5    13     0     0     1     0     1     0
%      3     5    12     0     0     0     0     0
%      2     1     1     9     0     0     7     0
%      0     4     2     0     9     0     5     0
%      3     2     3     3     0     5     3     1
%      2     0     1     2     5     0    10     0
%      2     1     0     0     0     0     0    17
% 
% 
% Random
% SVM & linear:
% accuracy:
%     0.4750
% 
% confusion:
%     15     3     1     0     0     0     0     1
%      5    13     0     0     1     0     1     0
%      2     6    11     0     1     0     0     0
%      1     2     1     3     0     0    13     0
%      0     4     3     0     8     0     5     0
%      5     3     2     2     1     1     5     1
%      7     0     0     0     3     0    10     0
%      3     1     0     0     0     0     1    15
% 
% SVM & gaussian:
% accuracy:
%     0.5312
% 
% confusion:
%     15     3     1     0     0     0     0     1
%      5    13     0     0     1     0     1     0
%      2     7    11     0     0     0     0     0
%      1     2     1     9     0     0     7     0
%      0     3     3     0     9     0     5     0
%      2     3     2     4     1     4     3     1
%      3     0     1     2     4     0     9     1
%      2     1     0     1     0     0     1    15
% 
% SVM & polynomial:
% accuracy:
%     0.5563
% 
% confusion:
%     15     3     1     0     0     0     0     1
%      4    13     0     0     2     0     1     0
%      2     6    12     0     0     0     0     0
%      0     2     1    10     0     0     7     0
%      0     2     2     1    10     0     5     0
%      3     3     2     2     1     5     3     1
%      3     0     0     2     5     0     9     1
%      2     1     0     1     0     0     1    15
% 
