function [dictionary] = getDictionary(imgPaths, alpha, K, method)

% set getPoint method
if strcmp(method, 'random')
    getPointsGivenMethod = @(img) getRandomPoints(img, alpha);
elseif strcmp(method, 'harris')
    k = 0.05;
    getPointsGivenMethod = @(img) getHarrisPoints(img, alpha, k);
else 
    disp('the given method is unknown')
end

fprintf('given method is %s \n', method);

% for each and every training image, load and apply the filter bank
filterBank = createFilterBank();
[~, T] = size(imgPaths); % there are T training images total
[N, ~] = size(filterBank); % n is the number of filters

pointResponses = zeros(alpha*T, 3*N);

for i = 1:T
    fprintf('Img %d/%d...\n', i, T);
    img = imread(strcat('../data/', imgPaths{i}));
   
    filterResponses = reshape(extractFilterResponses(img, filterBank), [], 3*N);
    
    points = getPointsGivenMethod(img);
    ind = sub2ind(size(img), points(:,1), points(:,2));
    pointResponses(alpha*(i-1)+1:alpha*(i),:) = filterResponses(ind,:);
    
end

% pass all of the points to Matlab?s K-means function
disp('perform kmeans...')

[~, dictionary] = kmeans(pointResponses, K, 'EmptyAction', 'drop', 'MaxIter', 1000);

end
