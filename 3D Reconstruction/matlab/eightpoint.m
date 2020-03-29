function F = eightpoint(pts1, pts2, M)
% eightpoint:
%   pts1 - Nx2 matrix of (x,y) coordinates
%   pts2 - Nx2 matrix of (x,y) coordinates
%   M    - max (imwidth, imheight)

%% Normalize points

scaler = 1/M;
pts1 = scaler*pts1;
pts2 = scaler*pts2;

transMatrix1 = [scaler,0,0; 0,scaler,0; 0,0,1];
transMatrix2 = [scaler,0,0; 0,scaler,0; 0,0,1];

% [pts1, transMatrix1] = normalize2d(pts1);
% [pts2, transMatrix2] = normalize2d(pts2);

%% Construct the N * 9 matrix A
N = length(pts1);

x1 = pts1(:, 1);
y1 = pts1(:, 2);
x2 = pts2(:, 1);
y2 = pts2(:, 2);

A = [x1.*x2 y1.*x2 x2 x1.*y2 y1.*y2 y2 x1 y1 ones(N, 1)];

%% Enforce the rank 2 constraint
[~, ~, V] = svd(A);
F_full = reshape(V(:, end), 3,3)';

[U, S, V] = svd(F_full);
S(end) = 0;
F = U * S * V';

%% Refine F
F = refineF(F, pts1, pts2);

%% Un-normalize F
F = transMatrix1.' * F * transMatrix2;

end