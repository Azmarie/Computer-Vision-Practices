function [dist] = getImageDistance(hist1, histSet, method)
% dist: a vector of distances between hist1 and each histogram in histSet

hist1 = repmat(hist1, size(histSet, 1), 1);

% compute the Euclidean distance between the two histogram
if method == "euclidean"
	dist = sqrt(sum((hist1-histSet).^2, 2));
    
% compute the chi square distance between the two histogram
% defined as dist(x,y) = sum( (xi-yi)^2 / (xi+yi) ) / 2;
elseif method == "chi2"
	dist = sum(((hist1 - histSet).^2)./(hist1 + histSet+eps), 2) / 2;
else
    disp('the given method is unknown')
end

end