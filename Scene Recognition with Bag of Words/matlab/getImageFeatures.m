function [ h ] = getImageFeatures(wordMap, dictionarySize)
% h, the vector representation of the image, is a histogram of size 1×K
% dictionarySize is the number of clusters K in the dictionary
% h(i) should be equal to the number of times visual word i occurred in the word map

h = zeros(1, dictionarySize);
    
for i = 1:dictionarySize
    h(i) = sum(sum(wordMap == i));
end

% L1 normalize the histogram before returning it from your function.
h = h./norm(h,1);

end