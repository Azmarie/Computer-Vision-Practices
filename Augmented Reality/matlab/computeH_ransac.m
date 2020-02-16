function [ bestH2to1, bestinliers] = computeH_ransac(locs1, locs2)
% COMPUTEH_RANSAC
% A method to compute the best fitting homography given a list of matching points.

%% Define variables
NUM_PAIRS = 4;
ITERATION = 800;
THRESHOLD = 3; % based on experiments

max_num_inliers = 0;
[n, ~] = size(locs1);

%% RANSAC loop
for i = 1:ITERATION
    % Get four point correspondences (randomly)
    NUM_PAIRS = min(NUM_PAIRS, n);
    
    p = randperm(n, NUM_PAIRS);
    
    x1 = [];
    x2 = [];
    for j = 1:NUM_PAIRS
        x1 = [x1; locs1(p(j), :)];
        x2 = [x2; locs2(p(j), :)];
    end
    
    % Compute H using DLT
    current_H2to1 = computeH_norm(x1, x2);
    
    % Count inliers
    current_inliers = [];
    current_num_inliers = 0;
    
    for j = 1:n
        temp = [locs1(j,:), 1] * current_H2to1';
        temp = temp/temp(3);
        is_inlier = 0;
  
        if(sum((temp(1:2) - locs2(j,:)).^2) < THRESHOLD^2)
            current_num_inliers = current_num_inliers + 1;
            is_inlier = 1;
        end
        
        current_inliers = [current_inliers, is_inlier];
    end
    
    % Keep H (record others) if largest number of inliers
    if current_num_inliers > max_num_inliers
        max_num_inliers = current_num_inliers;
        bestinliers = current_inliers;
        bestH2to1 = current_H2to1;
        bestx1 = x1;
        bestx2 = x2;
    end
    
end 

% cv_cover = imread('../data/cv_cover.jpg');
% cv_desk = imread('../data/cv_desk.png');
% fig = showMatchedFeatures(cv_cover, cv_desk, bestx1, bestx2, 'montage');
% title("The 4 point-pairs (that produced the most number of inliers)");
% saveas(fig,"../results/ransac_4_pairs.png")

end

