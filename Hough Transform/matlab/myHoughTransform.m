function [H, rhoScale, thetaScale] = myHoughTransform(Im, threshold, rhoRes, thetaRes)
    %% 1. Define the scale of rho and theta

    [h, w] = size(Im);
    diagonal = rhoRes*ceil(sqrt((h - 1)^2 + (w - 1)^2)/rhoRes);
    
    rhoScale = -diagonal: rhoRes: diagonal;
    thetaScale = 0: thetaRes: pi;
    
    %% 2. Initialize accumulator H to all zeros

    H = zeros(length(rhoScale), length(thetaScale));
    
    %% 3. Iterate through the image pixel and performs voting
    
    for y = 1:h
        for x = 1:w
            if Im(y,x) >= threshold
                for theta = thetaScale
                    rho = floor(y*sin(theta) + x*cos(theta));
                    if rho> diagonal
                        rho = diagonal;
                    end
                    rhoI = round((rho+diagonal)/rhoRes) + 1;
                    thetaI = round(theta/thetaRes) + 1;
                    H(rhoI, thetaI) = H(rhoI, thetaI) + 1;
                end
            end
        end
    end
end
