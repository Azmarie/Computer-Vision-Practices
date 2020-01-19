function [xx, yy] = initializeSnake(I)

% Show figure
imshow(I);
hold on;

% Get figure width and height
[hi, wid] = size(I);

% Get initial points
[xx, yy] = getpts();
cPoly = [xx yy];

[m,n]=size(cPoly);
 
cPoly_X = zeros(m+1, n);
cPoly_X(1:m, :) = cPoly;
cPoly_X(m+1, :) = cPoly(1, :);
 
% Interpolate
[m,n] = size(cPoly_X);
 
stepSize = 0.04;

t = 1:m;
o = 1:stepSize:m;
y = spline(t, cPoly_X', o);

xx = y(1, :);
yy = y(2, :);

% Clamp points to be inside of image

xx = min(xx, wid);
xx = max(0, xx);

yy = min(yy, hi);
yy = max(0, yy);

plot(xx, yy);
hold on;

end
