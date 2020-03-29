close;
clear all;

% set arameters
alpha = 200;
k = 0.05;

% load files
% image = imread('../data/auditorium/sun_adkfrlwqzwfzhspj.jpg');
% image = imread('../data/campus/sun_anlhyjfjqfdgfgzl.jpg');
image = imread('../data/bedroom/sun_aarvhntgsdfxgmmb.jpg');

I = rgb2gray(image);
I = im2double(I);

% get random points
[random_points] = getRandomPoints(image, alpha);
figure; imshow(image); hold on;
plot(random_points(:,2),random_points(:,1),'*','MarkerSize',4);
saveas(gcf, '../results/2-random1.png')
I = rgb2gray(image);
I = im2double(I);

% get harris points
[harris_points] = getHarrisPoints(I, alpha, k);
figure; imshow(image); hold on;
plot(harris_points(:,2),harris_points(:,1),'*','MarkerSize',4);
saveas(gcf, '../results/2-harris1.png')
