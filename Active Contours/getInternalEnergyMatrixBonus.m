function [Ainv] = getInternalEnergyMatrixBonus(nPoints, alpha, beta, gamma)

n = nPoints;

% Build coefficient
x_i_2 = beta;
x_i_1 = -alpha-4*beta;
x_i = 2*alpha + 6*beta;

% Construct A matrix with alpha and beta
A = x_i * speye(n);
A = A + x_i_1 * sparse(1:n-1,2:n,1,n,n);
A = A + x_i_2 * sparse(1:n-2,3:n,1,n,n);
A = A + x_i_1 * sparse(2:n,1:n-1,1,n,n);
A = A + x_i_2 * sparse(3:n,1:n-2,1,n,n);
A(n-1:n, 1:2) = [x_i_2 0; x_i_1 x_i_2];
A(1:2, n-1:n) = [x_i_2 x_i_1; 0 x_i_2];

Ainv = inv(A + gamma*speye(n)) ; 
end