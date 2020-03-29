function [M1, M2, K1n, K2n, R1n, R2n, t1n, t2n] = ...
                        rectify_pair(K1, K2, R1, R2, t1, t2)
% RECTIFY_PAIR takes left and right camera paramters (K, R, T) and returns left
%   and right rectification matrices (M1, M2) and updated camera parameters. You
%   can test your function using the provided script q4rectify.m

% load('../data/intrinsics.mat', 'K1', 'K2');
% load('../data/extrinsics.mat', 'R1', 'R2', 't1', 't2');

%% Compute the optical center 
c1 = -inv(K1*R1)*(K1*t1);
c2 = -inv(K2*R2)*(K2*t2);

r1 = (c1 - c2)/ norm(c1 - c2); % sum(abs(c2 - c1));

[M1, K1n, R1n, t1n] = rectify(r1, c1, K1, R1);
[M2, K2n, R2n, t2n] = rectify(r1, c2, K2, R2);

end

function [M1, K1n, R1n, t1n] = rectify(r1, c, K1, R1)
%% Compute the new rotation matrix
r2 = cross(R1(3, :), r1);
r3 = cross(r1, r2);

R1n = [r1.'; r2; r3];

%% Compute the new intrinsic parameter
K1n = K1;

%% Compute the new translation
t1n = -R1n * c;

%% Compute the rectification matrix 
M1 = (K1n * R1n)/(K1 * R1);
end