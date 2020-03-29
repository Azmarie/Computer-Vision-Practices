function [wordMap] = getVisualWords(I, filterBank, dictionary)
% I is the input image of size H × W × 3
% dictionary is the dictionary computed previousl
% filterBank is the filter bank that was used to construct the dictionary
% wordMap is an H × W matrix of integer labels

[h, w, ~] = size(I);
[n, ~] = size(filterBank);

responses = reshape(extractFilterResponses(I, filterBank), [], 3*n);

[~, ind] = pdist2(dictionary, responses, 'euclidean', 'Smallest', 1);
wordMap = reshape(ind, h, w);


end