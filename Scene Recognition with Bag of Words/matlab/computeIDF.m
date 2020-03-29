function computeIDF
    % compute a vector IDF of size 1 × K containing IDF for all visual words
    % K is the dictionary size (100)

    load('../matlab/visionRandom.mat', 'trainFeatures');
    T = size(trainFeatures, 1);

    % dw is the number of images d such that w occurs in that image
    dw = sum(trainFeatures ~= 0, 1);
    idf = log(T ./ dw);

    % save IDF in idf.mat
    save('idf.mat', 'idf');

end