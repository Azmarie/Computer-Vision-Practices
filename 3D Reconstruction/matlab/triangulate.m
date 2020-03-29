function pts3d = triangulate(P1, pts1, P2, pts2 )
% triangulate estimate the 3D positions of points from 2d correspondence
%   Args:
%       P1:     projection matrix with shape 3 x 4 for image 1
%       pts1:   coordinates of points with shape N x 2 on image 1
%       P2:     projection matrix with shape 3 x 4 for image 2
%       pts2:   coordinates of points with shape N x 2 on image 2
%
%   Returns:
%       Pts3d:  coordinates of 3D points with shape N x 3
%

p11 = P1(1,:);
p12 = P1(2,:);
p13 = P1(3,:);
p21 = P2(1,:);
p22 = P2(2,:);
p23 = P2(3,:);

N = length(pts1);
pts3d = zeros(N, 3);

for n = 1:N
    x = pts1(n,1);
    y = pts1(n,2);
    xp = pts2(n,1);
    yp = pts2(n,2);
    
    A = [-p12+y*p13; p11-x*p13; -p22+yp*p23; p21-xp*p23];
    
    [~, ~, V] = svd(A);
    eig = V(:,end).';
    eig = eig/eig(4);
    
    pts3d(n, :) = eig(1:3);
end

