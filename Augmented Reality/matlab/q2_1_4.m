%Q2.1.4
close all;
clear all;

cv_cover = imread('../data/cv_cover.jpg');
cv_desk = imread('../data/cv_desk.png');

[locs1, locs2] = matchPics(cv_cover, cv_desk);

figure;
fig = showMatchedFeatures(cv_cover, cv_desk, locs1, locs2, 'montage');
saveas(fig,"../results/matches_0.png")
