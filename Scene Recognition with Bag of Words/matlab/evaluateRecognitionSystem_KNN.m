clc;
close all;

% evaluateRecognitionSystem_kNN
% classifies all the test image using k Nearest Neighbors
% k is the number of nearby points to consider when classifying the new test image.

%% Load traintest.mat
load('../data/traintest.mat', 'train_labels', 'test_imagenames', 'test_labels', 'mapping');
T = size(test_imagenames, 2);
dictionarySize = 100;

%% Load visionHarris.mat
load('visionHarris.mat', 'dictionary', 'filterBank', 'trainFeatures','trainLabels');

%% initilize matrix
k_num = 40;
accuracy = zeros(k_num, 1);
confusion_matrix = zeros(8, 8, k_num);

%% kNN
for i = 1:T

    mat = strrep(strcat('../data/harris/', test_imagenames{i}),'.jpg','.mat');
    load(mat, 'wordMap');
    im_features = getImageFeatures(wordMap, dictionarySize);
    
    im_dist = getImageDistance(im_features, trainFeatures, 'chi2');
    
    for j = 1:k_num
        [~, index] = sort(im_dist);
        labels = trainLabels(index(1:j));
        label = mode(labels); % return the most frequent values in array
        confusion_matrix(test_labels(i),label,j) = confusion_matrix(test_labels(i),label,j) + 1;
    end
end

%% generate a plot of the accuracy for k from 1 to 40
for j = 1:k_num
    accuracy(j)= trace(confusion_matrix(:,:,j))/T;
end

plot(1:k_num, accuracy,'-*');
title('kNN accuracy with harris points, chi2 distance)');
xlabel('k');
ylabel('accuracy');
saveas(gcf, "../results/4-kNN-accuracy.png")

%% for the best performing k value, print the confusion matrix

[~, kOpt] = max(accuracy);
fprintf('optimal k = %d\n', kOpt)
disp('accuracy')
disp(accuracy(kOpt))
disp('confusion')
disp(confusion_matrix(:,:,kOpt))

% 
% optimal k = 32
% accuracy
%     0.5750
% 
% confusion
%     14     3     2     0     0     0     0     1
%      4    14     1     0     0     0     1     0
%      4     4    12     0     0     0     0     0
%      2     3     0    10     0     0     4     1
%      0     4     3     0    11     0     2     0
%      3     3     3     4     0     4     2     1
%      4     0     1     2     4     0     9     0
%      1     1     0     0     0     0     0    18
