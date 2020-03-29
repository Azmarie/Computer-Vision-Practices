clear;
close all;

%% Load the two images, and the point correspondences

pts1Struct = load('../data/someCorresp.mat', 'pts1');
pts1 = pts1Struct.pts1;

pts2Struct = load('../data/someCorresp.mat', 'pts2');
pts2 = pts2Struct.pts2;

MStruct = load('../data/someCorresp.mat', 'M');
M = MStruct.M;

pts1TempleStruct = load('../data/templeCoords.mat', 'pts1');
pts1Temple = pts1TempleStruct.pts1;

%% Run eightpoint to compute the fundamental matrix F
F = eightpoint(pts1, pts2, M);

I1 = imread('../data/im1.png');
I2 = imread('../data/im2.png');
% displayEpipolarF(I1,I2,F);
% saveas(gcf, '../results/1-viz.png')

%% Get the corresponding points in image
% epipolarMatchGUI(I1, I2, F);
% saveas(gcf, '../results/2-matches.png')

pts2Temple = epipolarCorrespondence(I1, I2, F, pts1Temple);

%% Compute the essential matrix E
K1Struct = load('../data/intrinsics.mat', 'K1');
K1 = K1Struct.K1;

K2Struct = load('../data/intrinsics.mat', 'K2');
K2 = K2Struct.K2;

E = essentialMatrix(F, K1, K2);

%% Compute the camera projection matrixs
P1 = K1 * [eye(length(K1)) zeros(length(K1), 1)];
extrinsics = camera2(E);

%% Select projection matrix from candidates
maxPositiveDepth = 0;

for p = 1:length(extrinsics)
    currentExtrinsics = extrinsics(:,:,p);
    currentP2 = K2 * currentExtrinsics;
    currentPts3d = triangulate(P1, pts1Temple, currentP2, pts2Temple);
    currentPositiveDepth = 0;

    for i = 1:length(currentPts3d)
        positive_depth_test = P1 * [currentPts3d(i,:),1]';
        if positive_depth_test(end) > 0
            currentPositiveDepth = currentPositiveDepth + 1;
        end
    end
    disp(currentPositiveDepth);
    if currentPositiveDepth > maxPositiveDepth
        maxPositiveDepth = currentPositiveDepth;
        selectedP2Index = p;
    end
end

disp(selectedP2Index);
% Choose optimal candidate based on maxPositiveDepth (selectedP2Index = 2)
P2 = K2 * extrinsics(:, :, selectedP2Index);

%% Triangulation and plot
pts3d = triangulate(P1, pts1Temple, P2, pts2Temple);
plot3(pts3d(:,1), pts3d(:,2), pts3d(:,3), '.', 'Color', 'b', 'MarkerSize', 10);
axis equal

%% Calculate re-projection error
N = length(pts3d);

repPts1 = reprojectPoints(pts3d, P1, N);
repPts2 = reprojectPoints(pts3d, P2, N);

repError1 = sum(sqrt(sum((pts1Temple - repPts1).^2, 2)));
repError2 = sum(sqrt(sum((pts2Temple - repPts2).^2, 2)));

% average_error = 1.3594/ 1.1603/ 0.5609
error = (repError1+repError2) / (N * 2);
disp(error);

%% Save rotation matrix (R1, R2) and translation (t1, t2) for dense reconstruction
R1 = eye(3);
t1 = zeros(3,1);
R2 = extrinsics(:, 1:3);
t2 = extrinsics(:, 4);
save('../data/extrinsics.mat', 'R1', 't1', 'R2', 't2');

function repPts = reprojectPoints(pts, P, N)
    repPts = [pts ones(N,1)] * P';
    repPts = repPts(:,1:2) ./ repPts(:,3);
end
