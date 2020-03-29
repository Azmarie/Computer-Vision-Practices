function P = estimate_pose(xx, XX)
% ESTIMATE_POSE computes the pose matrix (camera matrix) P given 2D and 3D
% points.
%   Args:
%       x: 2D points with shape [2, N]
%       X: 3D points with shape [3, N]

[~, N] = size(XX);

% A = zeros(2*N, 4*3);
% 
% for i = 1:N
%     Xi = XX(1, i); Yi = XX(2, i); Zi = XX(3, i);
%     xi = xx(1, i); yi = xx(2, i);
%     A(2*i-1, :) = [-Xi, -Yi, -Zi, -1, 0, 0, 0, 0, xi*Xi, xi*Yi, xi*Zi, xi];
%     A(2*i, :) = [0, 0, 0, 0, -Xi, -Yi, -Zi, -1, yi*Xi, yi*Yi, yi*Zi, yi];
% end

x = XX(1, :)';
y = XX(2, :)';
z = XX(3, :)';
x_p = xx(1, :)';
y_p = xx(2, :)';

A = [-x -y -z -ones(N, 1) zeros(N, 4) x.*x_p y.*x_p z.*x_p x_p];
A = [A; zeros(N, 4) -x -y -z -ones(N, 1) x.*y_p y.*y_p z.*y_p y_p];

[~, ~, V] = svd(A);
P = reshape(V(:, end), [4 3])';

end
    