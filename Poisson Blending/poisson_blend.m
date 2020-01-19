function imgout = poisson_blend(im_s, mask_s, im_t)
% -----Input
% im_s     source image (object)
% mask_s   mask for source image (1 meaning inside the selected region)
% im_t     target image (background)
% -----Output
% imgout   the blended image

[imh, imw, NB] = size(im_s);
imgout = zeros(size(im_s));

% Consider different channel numbers nb = 1, 2, 3
for nb = 1:NB

    im1d_s = im_s(:,:,nb); 
    im1d_t = im_t(:,:,nb); 

    % Flatten the images
    n_P = imh*imw;
    S = im1d_s(:);
    T = im1d_t(:); 
    M = mask_s(:); 

    [k_x, k_y] = find(mask_s>0);
    k = size(k_x, 1);
    for k_n = 1: k 
        assert(mask_s(k_x(k_n), k_y(k_n)) == 1);
        assert(M((k_y(k_n)-1)*imh + k_x(k_n),1) == 1);
    end

    % Initialize counter, A (sparse matrix) and b.
    % Initialize i,j,v

    i = zeros(1, k*5); 
    j = zeros(1, k*5); 
    v = zeros(1, k*5)+4;
    b = zeros(k, 1);

    % Fill in initial value for i,j,v

    i = [1:k 1:k 1:k 1:k 1:k];
    j = [1:k 1:k 1:k 1:k 1:k];

    v(1:k) = 4;
    v(k+1:2*k) = -1;
    v(2*k+1:3*k) = -1;
    v(3*k+1:4*k) = -1;
    v(4*k+1:5*k) = -1;

    % To make indexing easiser (mainly just the case when the point is
    % on the top or bottom line, y->y-1, y->y+1), we define o_indxing
    % to store the target point indexing given p indexing (from n_P)
    % We need to prepopulate this before the big loop because 
    % j needs to reference index at its vertical neighbors p+imh and p-imh
    inx = 1;
    o_indxing = zeros(1, n_P);
    for p = 1:n_P 
        if M(p)==1  
            o_indxing(p) = inx; 
            inx = inx + 1; 
        end 
    end 

    % Fill the elements in A and b, for each pixel in the image
    n = 1;
    for p = 1:n_P
        if(M(p) == 1) % when p is inside the image
            b(n) = 4*S(p); % v(x,y)

            % when p+1 is inside the image
            if M(p+1) == 1
                j(n+1*k) = n+1; 
                b(n) = b(n) - S(p+1); % -v(x+1, y)

            % when p+1 is NOT inside the image
            else
                v(n+1*k) = 0; 
                b(n) = b(n) - S(p) + T(p+1); 
            end

            % when p is inside the image
            if M(p-1) == 1  
                j(n+2*k) = n-1;
                b(n) = b(n) - S(p-1); % -v(x-1, y)

             % when p-1 is NOT inside the image
            else
                v(n+2*k) = 0; 
                b(n) = b(n) - S(p) + T(p-1); 
            end

            if M(p+imh) == 1
               j(n+3*k) = o_indxing(p+imh);
               b(n) = b(n) - S(p+imh);  % -v(x, y+1)

            else
                v(n+3*k) = 0; 
                b(n) = b(n) - S(p) + T(p+imh);
            end

            if M(p-imh) == 1  
                j(n+4*k) = o_indxing(p-imh);
                b(n) = b(n) - S(p-imh);  % -v(x, y-1)

            else
                v(n+4*k) = 0;  
                b(n) = b(n) - S(p) + T(p-imh); 
            end

            n = n + 1;
        end
    end

    % Solve the equation (No extra constraints)
    A = sparse(i, j, v); 
    solution = A\b;
    error = sum(abs(A*solution-b));
    disp(error)

    % Copy those variable pixels to the appropriate positions
    % in the output image to obtain the blended image

    res = zeros(1, n_P);
    e = 1;
    for n = 1: n_P
        if M(n) == 0 
            res(n) = T(n);
        else
            res(n) = solution(e);
            e = e+1;
        end
    end

    imgout(:,:,nb) = reshape(res,[imh,imw]);
end