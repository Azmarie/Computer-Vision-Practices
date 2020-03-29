function [pts2] = epipolarCorrespondence(im1, im2, F, pts1)
% epipolarCorrespondence:
%   Args:
%       im1:    Image 1
%       im2:    Image 2
%       F:      Fundamental Matrix from im1 to im2
%       pts1:   coordinates of points in image 1
%   Returns:
%       pts2:   coordinates of points in image 2
%

[H1,W1,D1] = size(im1);
[H2,W2,D2] = size(im2);
im1 = double(im1);
im2 = double(im2);

[N, ~] = size(pts1);
windowSize = 10;
pts2 = zeros(N, 2);

% Loop over all points in img1
for n = 1:N
    l = F * [pts1(n, :), 1]';
    window1 = calcWindow(im1, pts1(n,1), pts1(n,2), windowSize);
    maxDist = Inf;

    % Slide over windows in img2
    for x2 = 1+windowSize:W2-windowSize
        y2 = (-l(3) - l(1)*x2)/l(2);
        
        window2 = calcWindow(im2, x2, y2, windowSize);
        distance = calcEuclideanDist(window1, window2);
        
        % Record current distance and pts2
        if maxDist > distance
            maxDist = distance;
            pts2(n,:) = [x2,y2];
        end
    end

end

end

function window = calcWindow(im, x, y, windowSize)
    x = round(x);
    y = round(y);
    window = im(y-windowSize:y+windowSize, x-windowSize:x+windowSize, :);
end

% Similarity Metric: Euclidean distance 
function dist = calcEuclideanDist(window1, window2)
    dist = sqrt(sum((window1(:) - window2(:)) .^ 2));
end