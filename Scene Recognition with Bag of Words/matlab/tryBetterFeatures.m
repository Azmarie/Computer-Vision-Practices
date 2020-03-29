clc;
close all;

alpha = 50;
K = 100;

%% load files
load('../data/traintest.mat', 'train_labels', 'train_imagenames', 'test_labels', 'test_imagenames');
test_T = size(test_imagenames, 2);
train_T = size(train_imagenames, 2);

train_responses = extractHOGResponses(train_imagenames);
test_responses = extractHOGResponses(test_imagenames);

train_dictionary = getDictionary(train_responses, alpha, K);
test_dictionary = getDictionary(test_responses, alpha, K);

train_wordmaps = getVisualWords(train_responses, train_dictionary);
test_wordmaps = getVisualWords(test_responses, train_dictionary);

train_hist = getHistSet(train_wordmaps, K);
test_hist = getHistSet(test_wordmaps, K);

save('visionHOG.mat', 'testHistSet', 'trainHistSet');
% load('visionHOG.mat', 'testHistSet', 'trainHistSet');

%% generate template for SVM binary classifiers with kernel functions
t = templateSVM('Standardize', true, 'KernelFunction','linear','BoxConstraint',1,'KernelScale','auto');
svm_linear = fitcecoc(train_hist, train_labels, 'Learners', t);

t = templateSVM('Standardize', true, 'KernelFunction','gaussian','BoxConstraint',1,'KernelScale','auto');
svm_gaussian = fitcecoc(train_hist, train_labels, 'Learners', t);

t = templateSVM('Standardize', true, 'KernelFunction','polynomial','BoxConstraint',1,'KernelScale','auto');
svm_poly = fitcecoc(train_hist, train_labels, 'Learners', t);

save('visionSVMHOG.mat', 'svm_linear', 'svm_gaussian', 'svm_poly');

%% SVM predict with polynomial
pred_labels = predict(svm_poly, test_hist);
C = zeros(8);
for i = 1:test_T
    C(test_labels(i), pred_labels(i)) = C(test_labels(i), pred_labels(i)) + 1;
end

disp('SVM & polynomial:')
displayMetrics(C, test_T)

%% SVM predict with linear
pred_labels = predict(svm_linear, test_hist);
C = zeros(8);
for i = 1:test_T
    C(test_labels(i), pred_labels(i)) = C(test_labels(i), pred_labels(i)) + 1;
end

disp('SVM & linear:')
displayMetrics(C, test_T)


%% SVM predict with gaussian
pred_labels = predict(svm_gaussian, test_hist);
C = zeros(8);

for i = 1:test_T
    C(test_labels(i), pred_labels(i)) = C(test_labels(i), pred_labels(i)) + 1;
end

disp('SVM & gaussian:')
displayMetrics(C, test_T)

%% helper function: display confusion matrix and accuracy
function displayMetrics(confusion, T)
    disp('accuracy:')
    disp(trace(confusion)/T)
    disp('confusion:')
    disp(confusion)
end

%% helper function: extractHOGResponses
function hogResponses = extractHOGResponses(train_imagenames)
    T = size(train_imagenames, 2);

    hogResponses = cell(T, 1);
    for i = 1:T
        img = imread(strcat('../data/', train_imagenames{i}));

        [~, ~, c] = size(img);
        if c == 1
            img = repmat(img, [1 1 3]);
        end

        featureR = vec2mat(extractHOGFeatures(img(:,:,1)), 36);
        featureG = vec2mat(extractHOGFeatures(img(:,:,2)), 36);
        featureB = vec2mat(extractHOGFeatures(img(:,:,3)), 36);

        hogResponses{i} = [featureR featureG featureB];

    end
end

%% helper function: getDictionary from hog features
function dictionary = getDictionary(hogResponses, alpha, K)
    T = size(hogResponses, 1);

    hogResponsesRandom = zeros(alpha*T, 36*3);
    for i = 1:T
        response = hogResponses{i};
        n = size(response, 1);
        inds = randperm(n, alpha);

        hogResponsesRandom(alpha*(i-1)+1:alpha*(i), :) = response(inds, :);
    end

    disp('kmeans...')
    [~, dictionary] = kmeans(hogResponsesRandom, K, 'EmptyAction', 'drop', 'MaxIter', 1000);
end

%% helper function: getVisualWords from hog features
function wordMaps = getVisualWords(hogResponses, dictionary)
    T = size(hogResponses, 1);

    wordMaps = cell(T, 1);
    for i = 1:T
        [~, wordMap] = pdist2(dictionary, hogResponses{i}, 'euclidean', 'Smallest', 1);
        wordMaps{i} = wordMap;
    end

end

%% helper function: get histogram set from word maps
function histset = getHistSet(wordMaps, K)
    T = size(wordMaps, 1);
    histset = zeros(T, K);

    for i = 1:T
        hist = zeros(1, K);
        for k = 1:K
            hist(k) = sum(wordMaps{i} == k);
        end
        histset(i, :) = hist./numel(wordMaps{i});
    end

end
% 
% SVM & polynomial:
% accuracy:
%     0.8500
% 
% confusion:
%     12     3     3     1     1     0     0     0
%      1    16     2     0     0     0     1     0
%      0     1    19     0     0     0     0     0
%      0     0     0    18     1     0     0     1
%      0     0     0     0    17     0     3     0
%      0     1     0     1     0    18     0     0
%      0     1     0     0     2     0    16     1
%      0     0     0     0     0     0     0    20
% 
% SVM & linear:
% accuracy:
%     0.7750
% 
% confusion:
%     11     4     2     2     1     0     0     0
%      1    14     3     0     0     1     1     0
%      1     0    18     0     0     0     0     1
%      0     0     0    15     0     0     3     2
%      0     0     0     0    16     0     4     0
%      0     2     0     1     1    15     1     0
%      0     1     0     0     1     0    15     3
%      0     0     0     0     0     0     0    20
% 
% SVM & gaussian:
% accuracy:
%     0.8063
% 
% confusion:
%     12     4     1     2     1     0     0     0
%      1    15     2     0     1     1     0     0
%      0     0    19     0     0     0     0     1
%      0     0     0    17     1     0     0     2
%      0     0     0     0    16     0     4     0
%      0     1     0     1     3    14     1     0
%      0     1     0     0     0     0    16     3
%      0     0     0     0     0     0     0    20
% 
