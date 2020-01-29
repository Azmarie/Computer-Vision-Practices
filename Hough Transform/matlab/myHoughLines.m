function [rhos, thetas] = myHoughLines(H, nLines)
    [m,n] = size(H);
  
    % Non maximal suppression considering all neighbors
    H = imregionalmax(H).* H;
    
    % Just in case H is extremely sparse
    if nLines > nnz(H)
        nLines = nnz(H);
    end
    
    % Get top nLines sorted H entries
    H_sorted = sort(H(:),'descend');
    rhos = zeros(nLines,1);
    thetas = rhos;
    
    % Iterate and fill rhos and thetas
    for i = 1:nLines
        [row, column] = find(H == H_sorted(i));
        rhos(i) = row(1); % row could be [68;69]
        thetas(i) = column(1);
    end
    
end
        