function [newX, newY] = iterate(Ainv, x, y, Eext, gamma, kappa)

% Get fx and fy
[fx, fy] = gradient(Eext);

% Get image size
[hi, wid] = size(Eext);

% Iterate
% Take transpose because we want it to be n by 1 matrix for x/y axis value
% Use 'spline' to avoid NaN values
newX = Ainv*(gamma*x' + kappa * interp2(fx, x, y, 'spline')');
newY = Ainv*(gamma*y' + kappa * interp2(fy, x, y, 'spline')');

% Clamp to image size
newX = min(newX, wid);
newX = max(0, newX);

newY = min(newY, hi);
newY = max(0, newY);

% We need to transpose them,
% because newX and x need to be of the same size
% for future iterations
newX = newX';
newY = newY';

end