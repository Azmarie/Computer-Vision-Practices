% load the train_imagenames and train_labels from traintest.mat
load('../data/traintest.mat', 'train_imagenames', 'train_labels');
trainLabels = train_labels;

T = size(train_imagenames,2);

% Perform Random
load('dictionaryRandom.mat', 'dictionary', 'filterBank');
dictionarySize = size(dictionary, 1);
trainFeatures = zeros(T, dictionarySize);

for i = 1:T
    matname = strcat('../data/random/', train_imagenames{i});
    load(strrep(matname,'.jpg','.mat'), 'wordMap');
    trainFeatures(i,:) = getImageFeatures(wordMap, dictionarySize)';
end
save('visionRandom.mat', 'dictionary', 'filterBank', 'trainFeatures', 'trainLabels');

% Perform Harris
load('dictionaryHarris.mat', 'dictionary', 'filterBank');
dictionarySize = size(dictionary, 1);
trainFeatures = zeros(T, dictionarySize);

for i = 1:T
    matname = strcat('../data/harris/', train_imagenames{i});
    load(strrep(matname,'.jpg','.mat'), 'wordMap');
     trainFeatures(i,:) = getImageFeatures(wordMap, dictionarySize)';
end
save('visionHarris.mat', 'dictionary', 'filterBank', 'trainFeatures', 'trainLabels');
