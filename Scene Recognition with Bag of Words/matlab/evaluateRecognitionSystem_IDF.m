clc;
close all;

%% load mat files
load('../data/traintest.mat', 'train_labels', 'test_imagenames', 'test_labels', 'mapping');
load('visionRandom.mat', 'dictionary', 'filterBank', 'trainFeatures');
load('idf.mat', 'idf');
T = size(test_imagenames, 2);

%% initilize matrix
k_num = 40;
accuracy = zeros(k_num, 1);
confusion_matrix = zeros(8, 8, k_num);

%% kNN
for i = 1:T

    mat = strrep(strcat('../data/random/', test_imagenames{i}),'.jpg','.mat');
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
title('kNN accuracy with random points, chi2 distance)');
xlabel('k');
ylabel('accuracy');
saveas(gcf, "../results/5-IDF-kNN-accuracy.png")

%% for the best performing k value, print the confusion matrix
[~, kOpt] = max(accuracy);
fprintf('optimal k = %d\n', kOpt)
disp('accuracy')
disp(accuracy(kOpt))
disp('confusion')
disp(confusion_matrix(:,:,kOpt))


% optimal k = 16
% accuracy
%     0.5813
% 
% confusion
%     15     1     2     0     0     0     0     2
%      5    13     2     0     0     0     0     0
%      4     5    11     0     0     0     0     0
%      2     2     2    10     0     0     3     1
%      0     3     2     1    11     0     3     0
%      2     3     2     3     1     7     0     2
%      5     0     1     3     2     0     8     1
%      1     0     1     0     0     0     0    18
