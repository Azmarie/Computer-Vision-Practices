clear all;
close all;

cv_img = imread('../data/cv_cover.jpg'); % 1
desk_img = imread('../data/cv_desk.png'); % 2
hp_img = imread('../data/hp_cover.jpg');

%% Extract features and match
[locs1, locs2] = matchPics(cv_img, desk_img);

%% Compute homography using RANSAC
[bestH2to1, ~] = computeH_ransac(locs1, locs2);

%% Scale harry potter image to template size
scaled_hp_img = imresize(hp_img, [size(cv_img,1) size(cv_img,2)]);

%% Display warped image.
imshow(warpH(scaled_hp_img, inv(bestH2to1), size(desk_img)));

%% Display composite image
fig = imshow(compositeH(inv(bestH2to1), scaled_hp_img, desk_img));
title("Harry Potter Textbook");
saveas(fig,"../results/hp_cover_book.png")
