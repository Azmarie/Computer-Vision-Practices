function [filterResponses] = extractFilterResponses(I, filterBank)

[h, w, c] = size(I);
[N, ~] = size(filterBank);

if c == 1
    I = repmat(I, [1 1 3]);
end

I = im2double(I);
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

[L, A, B] = RGB2Lab(R, G, B);

filterResponses = zeros(h, w, 3*N);
for n = 1:N
    filter = filterBank{n};
    filterResponses(:, :, 3*(n-1)+1) = imfilter(L, filter);
    filterResponses(:, :, 3*(n-1)+2) = imfilter(A, filter);
    filterResponses(:, :, 3*(n-1)+3) = imfilter(B, filter);
end

    
end