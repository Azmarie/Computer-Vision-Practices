function [output] = myImageFilter(img0, filter)
    
    [h w] = size(img0);
    [m n] = size(filter);
    f_filter = rot90(filter, 2);

    %% 1. Padding with nearest neighbors 
    
    % Initilize padded NaN matrix (stride = 1)
    % p = (k-1)/2, which is valid since dim of filter is always odd
    p_h = (m-1)/2; 
    p_w = (n-1)/2; 
    Init = NaN(h+2*p_h, w+2*p_w);

    % Fill the array with img0 at corresponding positions
    Init(p_h+1: h+p_h, p_w+1:w+p_w) = img0;

    % Fill the missing NaN values
    Filled_rows = fillmissing(Init, 'nearest');
    Filled_cols = fillmissing(Filled_rows', 'nearest');
    Filled = Filled_cols';
    assert(all(size(Filled) == [h+2*p_h w+2*p_w]), 'Padded matrix size incorrect');
    assert(isempty(find(isnan(Filled), 1)), 'Filled array has NaN values');
    
    % Test padding with 0 instead
    % Filled = fillmissing(Init,'constant',0);

    %% 2. Iterate over the image
    
    output = zeros(size(img0));
    % Vectorization
    r = 1:h; 
    c = 1:w;

    Index_x = r;
    for mm = 1:m-1
        Index_x=[Index_x;r+mm];
    end
    Index_y = c;
    for nn = 1:n-1
        Index_y=[Index_y;c+nn];
    end
    for rr = 1:h
        for cc = 1:w
            Patch = Filled(Index_x(:,rr)', Index_y(:,cc)');
            output(rr,cc) = sum(f_filter.*Patch, 'all');
        end
    end

%     imshow(output/max(output(;)))
end