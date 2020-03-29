function [K, R, t] = estimate_params(P)
    % ESTIMATE_PARAMS computes the intrinsic K, rotation R and translation t from
    % given camera matrix P.

    % Compute the camera center c by using SVD
    [~, ~, V] = svd(P);
    c = V(:, end) / V(end); % smallest eigenvalue

    % Compute the intrinsic K and rotation R by using QR decomposition
    [K, R] = rq(P(:, 1:3));
    
    % Adjust R (same as testKRt.m)
    if det(R) < 0
        R = -R;
    end
    
    % Compute the translation
    t = -R*c(1:3);
    
end

function [R, Q] = rqdecomp(A)   
    eps = 1e-10;
    
    % https://math.stackexchange.com/questions/1640695/rq-decomposition
    reverseP = flip(diag([1 1 1]), 2);
    
    % Get reverse rows of A
    A = reverseP * A;
    
    % Compute decomposition of A'
    [Q, R] = qr(A');
    
    % Get Q and R
    Q = reverseP * Q'; % rot90(Q);
    R = reverseP * R' * reverseP; % rot90(R,2)';
    
    signM = diag([1 1 1]);
    signM = signM .* (-any(R < -eps) + any(R > eps));

    R = R * signM;
    Q = signM * Q;

end

% function [K, R, t] = estimate_params(P)
% % ESTIMATE_PARAMS computes the intrinsic K, rotation R and translation t from
% % given camera matrix P.
% 
% %% Camera center c
% [~, ~, V] = svd(P);
% c = V(:,end);
% c = c(1:3) ./ c(end);
% 
% %% K and R
% [K, R] = rq(P(:, 1:3));
% 
% %% t
% t = -R*c;
% 
% end

function [R, Q] = rq(A)
perm = [0 0 1; 0 1 0; 1 0 0];
A = perm*A;
[Q, R] = qr(A');
Q = perm*Q';
R = perm*R'*perm;
neg = -any(R<0 & abs(R) > 1e-4);
neg(neg==0) = 1;
R = R * diag(neg);
Q = diag(neg) * Q;
if abs(det(Q)+1) < 1e-4
    Q = - Q;
end
end