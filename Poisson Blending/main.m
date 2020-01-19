clc;
clear;
close all;

% im_background = im2double(imread('img/glass.jpeg'));
% im_object = im2double(imread('img/surf.jpeg'));

% im_background = im2double(imread('img/cat_1.jpg'));
% im_object = im2double(imread('img/lion_1.jpeg'));

im_background = im2double(imread('img/teddy.jpg'));
im_object = im2double(imread('img/poodle.jpg'));

% im_background = im2double(imread('img/cat_2.jpg'));
% im_object = im2double(imread('img/lion_2.jpeg'));

% get source region mask from the user
objmask = get_mask(im_object);

% align im_s and mask_s with im_background
[im_s, mask_s] = align_source(im_object, objmask, im_background);

% blend
disp('start');
im_blend = poisson_blend(im_s, mask_s, im_background);
disp('end');

imwrite(im_blend,'img/output.png');
figure(), hold off, imshow(im_blend);
