function [points] = getHarrisPoints(I, alpha, k)

% set parameters
window_size = 3;

% convert rgb to gray
[h, w, c] = size(I);
if c ~= 1
    I = rgb2gray(I);
end

% make sure values within the range 0 (black) to 1 (white)
I = double(I) / 255;

% precompute the image?s X and Y gradients
[Ix, Iy] = imgradientxy(I);
Ixx = Ix.*Ix;
Ixy = Ix.*Iy;
Iyy = Iy.*Iy;
Iyx = Iy.*Ix;

% compute the covariance matrix
kernel = ones(window_size);

M11 = reshape(conv2(Ixx, kernel, 'same'), [], 1, 1);
M12 = reshape(conv2(Ixy, kernel, 'same'), [], 1, 1);
M21 = reshape(conv2(Iyx, kernel, 'same'), [], 1, 1);
M22 = reshape(conv2(Iyy, kernel, 'same'), [], 1, 1);

% compute the response function 
det = M11.*M22 - M12.*M21;
trace = M11 + M22;
R = det - k*trace.^2;

% Apply non-max suppression (taking top k values)
[~, ind] = sort(R, 'descend');
topK = ind(1:alpha);
[row, col] = ind2sub([h w], topK);
points = [row, col];

end