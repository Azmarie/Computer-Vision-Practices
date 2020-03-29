% load image names
load('../data/traintest.mat', 'train_imagenames');

% set parameters
alpha = 500;
K = 100;
filterBank = createFilterBank();

% create dictionary of visual words
dictionary = getDictionary(train_imagenames, alpha, K, 'random');
save('dictionaryRandom.mat', 'filterBank', 'dictionary');

dictionary = getDictionary(train_imagenames, alpha, K, 'harris');
save('dictionaryHarris.mat', 'filterBank', 'dictionary');
