function [ H2to1 ] = computeH( x1, x2 )
%COMPUTEH Computes the homography between two sets of points
n = size(x1, 1);

x = x1(:, 1);
y = x1(:, 2);
x_p = x2(:, 1);
y_p = x2(:, 2);

% from slide: https://www2.cs.sfu.ca/~furukawa/cmpt762/slides/08-homography.pdf
A = [-x -y -ones(n, 1) zeros(n, 1) zeros(n, 1) zeros(n, 1) x.*x_p y.*x_p x_p];
A = [A; zeros(n, 1) zeros(n, 1) zeros(n, 1) -x -y -ones(n, 1) x.*y_p y.*y_p y_p];

[~, ~, V] = svd(A);

H2to1 = V(:, 9);
H2to1 = reshape(H2to1, [3 3]);
H2to1 = H2to1.';

end