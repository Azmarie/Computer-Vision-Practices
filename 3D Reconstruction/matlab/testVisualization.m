clear;
close all;

%% Load variables from mat

pts1Struct = load('../data/someCorresp.mat', 'pts1');
pts1 = pts1Struct.pts1;

pts2Struct = load('../data/someCorresp.mat', 'pts2');
pts2 = pts2Struct.pts2;

MStruct = load('../data/someCorresp.mat', 'M');
M = MStruct.M;

%% Compute F Matrix
F = eightpoint(pts1, pts2, M);

%% Test eightpoint (displayEpipolarF)

I1 = imread('../data/im1.png');
I2 = imread('../data/im2.png');
displayEpipolarF(I1,I2,F);
saveas(gcf, '../results/1-viz.png')

%% Test epipolar correspondence (epipolarMatchGUI)
epipolarMatchGUI(I1, I2, F);
saveas(gcf, '../results/2-matches.png')

%% Test Essential Matrix
K1Struct = load('../data/intrinsics.mat', 'K1');
K1 = K1Struct.K1;

K2Struct = load('../data/intrinsics.mat', 'K2');
K2 = K2Struct.K2;

E = essentialMatrix(F, K1, K2);

% E =

% 0.0040   -0.0433   -0.0192
% -0.1498   -0.0009    0.7264
% 0.0019   -0.7352   -0.0008