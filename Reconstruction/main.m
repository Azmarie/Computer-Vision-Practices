clc;
clear;
close all;

imgin = im2double(imread('./large.jpg'));

[imh, imw, nb] = size(imgin);
n_P = imh*imw;
assert(nb==1); % the image is grayscale

V = imgin;
% V = zeros(imh, imw);
% V(1:n_P) = 1:in_P;
% V(y,x) = (y-1)*imw + x
% use V(y,x) to represent the variable index of pixel (x,y)
% Always keep in mind that in matlab indexing starts with 1, not 0

% Initialize b, for each pixel in the image
% b(m, n) = 4*V(m,n) - V(m-1,n) - V(m+1,n) - V(m,n-1) - V(m,n+1);
b = zeros(imh, imw);

% when the pixel is within (2:imh-2, 2:imw-2)
b(2:imh-1, 2:imw-1) = 4*V(2:imh-1, 2:imw-1) - V(1:imh-2, 2:imw-1) - V(3:imh, 2:imw-1) - V(2:imh-1, 1:imw-2) - V(2:imh-1, 3:imw);

% when the pixel is on the edge (1, :) (imh, :) (:, 1) (:, imw)
b(1, 2:imw-1) = 2*V(1, 2:imw-1) - V(1, 1:imw-2) - V(1, 3:imw);
b(imh, 2:imw-1) = 2*V(imh, 2:imw-1) - V(imh, 1:imw-2) - V(imh, 3:imw);
b(2:imh-1, 1) = 2*V(2:imh-1, 1) - V(1:imh-2, 1) - V(3:imh, 1);
b(2:imh-1, imw) = 2*V(2:imh-1, imw) - V(1:imh-2, imw) - V(3:imh, imw);

% Initialize A through i,j,v
N = n_P*5;
% i = zeros(n_P,5);
% j = zeros(n_P,5);
v = zeros(n_P,5);
i = [1:n_P;1:n_P;1:n_P;1:n_P;1:n_P]';
j = [1:n_P;1:n_P;1:n_P;1:n_P;1:n_P]';

% Fill i,j,v with middle case
% For simplicity, the edge/corner will be overwrittern later
 
j(1:n_P, 1) = 1:n_P;
j(1:n_P-1, 2) = 2:n_P;
j(2:n_P, 3) = 1:n_P-1;
j(imh:n_P-imh, 4) = 2*imh:n_P;
j(imh+1:n_P, 5) = 1:n_P-imh; 

v(1:n_P, 1) = 4;
v(1:n_P, 2) = -1;
v(1:n_P, 3) = -1;
v(1:n_P, 4) = -1;
v(1:n_P, 5) = -1;

% Fill i,j,v with edge case - horizontal
% 2, 3, 4,---- 49; 2451, 2452, ---- 2499

j(2:imh-1, 1) = 2:imh-1; 
j(2:imh-1, 2) = 3:imh;      % -1*v(x+1, y)
j(2:imh-1, 3) = 1:imh-2;    % -1*v(x-1, y) 

v(2:imh-1, 1) = 2;
% v(2:imh-1, 2) = -1;
% v(2:imh-1, 3) = -1;
v(2:imh-1, 4) = 0;
v(2:imh-1, 5) = 0;

j(n_P-imh+1:n_P-1, 1) = n_P-imh+1:n_P-1;
j(n_P-imh+1:n_P-1, 2) = n_P-imh+2:n_P;      % -1*v(x+1, y)
j(n_P-imh+1:n_P-1, 3) = n_P-imh:n_P-2;      % -1*v(x-1, y) 

v(n_P-imh+1:n_P-1, 1) = 2;
% v(n_P-imh+1:n_P-1, 2) = -1;
% v(n_P-imh+1:n_P-1, 3) = -1;
v(n_P-imh+1:n_P-1, 4) = 0;
v(n_P-imh+1:n_P-1, 5) = 0;

% Fill i,j,v with edge case - vertical
% 50, 100, 150 ---- 2450 ; 51, 101, 151 ---- 2451

for x = 1:imh-1
    n = x*imw;
    v(n:n+1, 1) = 2;
    v(n:n+1, 2) = 0;
    v(n:n+1, 3) = 0;
%     v(n:n+1, 4) = -1;
%     v(n:n+1, 5) = -1;

    if(n > imw && n+imh < n_P)
        j(n, 4) = n+imh; % -1*v(x, y+1)
        j(n, 5) = n-imh; % -1*v(x, y-1)
        j(n+1, 4) = n+1+imh; 
        j(n+1, 5) = n+1-imh;
    end
end

% Fill i,j,v with corner case
% 1, 50, 2450, 2500
v(1,:) = 0;         v(1,1) = 1; 
v(imh,:) = 0;       v(imh,1) = 1;
% v(n_P-imh,:) = 0;   v(n_P-imh,1) = 1;
v(n_P,:) = 0;       v(n_P,1) = 1;

A =sparse(i, j ,v);

% Add extra constraints from function defined at the bottom
B = zeros(n_P, 5);
% Five reconstruction cases
% one similar to the ground truth
B_1 = constraints(b, V, 0, 0, 0, 0, imh, imw);
% one globally brighter
B_2 = constraints(b, V, 0.8, 0.8, 0.8, 0.8, imh, imw);
% one brighter on the left side
B_3 = constraints(b, V, 0.8, 0, 0.8, 0, imh, imw);
% one brighter on the bottom side
B_4 = constraints(b, V, 0, 0, 0.8, 0.8, imh, imw);
% one brighter on right bottom corner.
B_5 = constraints(b, V, 0, 0, 0, 0.8, imh, imw);

B = [B_1 B_2 B_3 B_4 B_5];
for i=1:5
    b = B(:, i);
    % Solve the equation
    solution = A\b;
    error = sum(abs(A*solution-b)); disp(error)
    imgout = reshape(solution,[imh,imw]);
    imwrite(imgout, ['case_' num2str(i) '.jpg']);
    figure(), hold off, imshow(imgout);
end

% Add extra constraints
% Corner points: (1,1) (1, imw) (imh, 1) (imh, imw)
function res = constraints(b, V, b_1, b_2, b_3, b_4, imh, imw)

    b(1,1) = V(1,1)+ b_1;
    b(1, imw) = V(1, imw) + b_2;
    b(imh, 1) = V(imh, 1) + b_3;
    b(imh, imw) = V(imh, imw) + b_4;
    res = reshape(b, [imh*imw, 1]);
end

