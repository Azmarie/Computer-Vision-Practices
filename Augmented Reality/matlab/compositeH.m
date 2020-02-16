function [ composite_img ] = compositeH( H2to1, template, img )
%COMPOSITE Create a composite image after warping the template image on top
%of the image using the homography

% Note that the homography we compute is from the image to the template;
% x_template = H2to1*x_photo
% For warping the template to the image, we need to invert it.
H_template_to_img = inv(H2to1);

%% Create mask of same size as template
mask = ones(size(template), 'uint8') * 255;

%% Warp mask by appropriate homography
mask = warpH(mask, H_template_to_img, size(img));
% imshow(mask);

%% Warp template by appropriate homography
template = warpH(template, H_template_to_img, size(img));
% imshow(template)

%% Use mask to combine the warped template and the image
img_mask = uint8(~(mask/255));
composite_img = img_mask .* img + template;
% imshow(composite_img);

end
