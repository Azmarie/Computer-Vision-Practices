function dispM = get_disparity(im1, im2, maxDisp, windowSize)

% GET_DISPARITY creates a disparity map from a pair of rectified images 
% im1 and im2, given the maximum disparity MAXDISP,
% the window size WINDOWSIZE.

% Pre-processing and initialization
w = (windowSize-1)/2;

im1 = im2double(im1);
im2 = im2double(im2);

[H, W] = size(im1);
dispM = zeros(H, W);

% Pad im arrays for convolution later
im1 = padarray(im1, [w w], 0, 'both');
im2 = padarray(im2, [w w], 0, 'both');

for y = 1:H
    for x = 1:W
    
        minDist = Inf;
        minArg = 0;
        
        for d = 0:maxDisp
            if x>w && y>w && x-d>w
                
                window1 = calcWindow(im1, x, y, w);
                window2 = calcWindow(im2, x-d, y, w);
                dist = calcEuclideanDist(window1, window2);

                if(dist < minDist)
                    minDist = dist;
                    minArg = d;
                end
            end
        end
        
        dispM(y,x) = minArg;
    end
end

end

% reuse functions from epipolarCorrespondence.m
function window = calcWindow(im, x, y, windowSize)
    x = round(x);
    y = round(y);
    window = im(y-windowSize:y+windowSize, x-windowSize:x+windowSize);
end

function dist = calcEuclideanDist(window1, window2)
    dist = sum(sum((window1-window2).^2));
end
