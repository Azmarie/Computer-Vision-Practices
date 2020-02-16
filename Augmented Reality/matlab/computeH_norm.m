function [H2to1] = computeH_norm(x1, x2)

[n, ~] = size(x1);

%% Compute centroids of the points
centroid1 = mean(x1);
centroid2 = mean(x2);

%% Shift the origin of the points to the centroid
x1 = x1 - centroid1;
x2 = x2 - centroid2;

%% Normalize the points so that the average distance from the origin is equal to sqrt(2).
dist1 = sqrt(sum(x1.^2, 2));
dist2 = sqrt(sum(x2.^2, 2));

scale1 = n* sqrt(2)/ sum(dist1);
scale2 = n* sqrt(2)/ sum(dist2);

x1Norm = scale1 * x1;
x2Norm = scale2 * x2;

%% similarity transform 1
T1 = [scale1, 0, -scale1*centroid1(1); 0, scale1, -scale1*centroid1(2); 0, 0, 1];

%% similarity transform 2
T2 = [scale2, 0, -scale2*centroid2(1); 0, scale2, -scale2*centroid2(2); 0, 0, 1];

%% Compute Homography
H = computeH(x1Norm, x2Norm);

%% Denormalization
% Note: calculating H from x2 to x1
H2to1 = inv(T2) * H * T1;

end