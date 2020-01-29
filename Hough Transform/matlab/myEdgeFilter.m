function [edge] = myEdgeFilter(img0, sigma)
    %% 1. Gaussian blur the image with myImageFilter
 
    hsize = 2 * ceil(3 * sigma) + 1;
    gFilter = fspecial('gaussian',hsize,sigma);
    img1 = myImageFilter(img0, gFilter);
 
    %% 2. Apply Sobel Filter in X and Y directions
    
    sobelX = [-1 0 1; -2 0 2; -1 0 1];
    sobelY = [-1 -2 -1; 0 0 0; 1 2 1];
 
    imgX = myImageFilter(img1, sobelX);
    imgY = myImageFilter(img1, sobelY);
 
    %% 3. Perform Non maximum suppression
 
    [h w] = size(img0);
    
    % Calculate the gradient magnitude and direction (by tangent)
    gMag = sqrt(imgX.^2 + imgY.^2);
    gTan = imgY./imgX;
    edge = gMag;
    
    % Here we adapt a 3*3 kernal, thus starting from position 2
    for r=2:h-1
        for c=2:w-1
 
            % tan(22.5?) = 0.4142, angel = 0?, when tan = [-0.4142, 0.4142)
            if(gTan(r,c) >= tan(-pi/8) && gTan(r,c) <= tan(pi/8))
                % Compare it with gMag at position (r,c+1), (r,c-1)
                if(gMag(r,c) < gMag(r,c+1)) || (gMag(r,c) < gMag(r,c-1))
                    edge(r,c) = 0;
                end
            end
 
            % tan(67.5?) = 2.4142, angel = 45? when tan = [0.4142, 2.4142)
            if(gTan(r,c) >= tan(pi/8) && gTan(r,c) <= tan(3*pi/8))
                % Compare it with gMag at position (r+1,c+1), (r-1,c-1)
                if(gMag(r,c) < gMag(r+1,c+1)) || (gMag(r,c) < gMag(r-1,c-1))
                    edge(r,c) = 0;
                end
            end

            % tan(112.5?) = -2.4142, angel = 90? when tan = (-inf, -2.4142) U
            % [2.4142, inf)
            if(gTan(r,c) <= tan(5*pi/8) || gTan(r,c) >= tan(3*pi/8))
                 % Compare it with gMag at position (r-1,c), (r+1,c)
                if(gMag(r,c) < gMag(r-1,c)) || (gMag(r,c) < gMag(r+1,c))
                    edge(r,c) = 0;
                end
            end
 
            % tan(157.5) = -0.4142, angel = 135? when tan = [-2.4142, -0.4142)
            if(gTan(r,c) >= tan(5*pi/8) && gTan(r,c) <= tan(-pi/8))
                % Compare it with gMag at position (r-1,c+1), (r+1,c-1)
                if(gMag(r,c) < gMag(r-1,c+1)) || (gMag(r,c) < gMag(r+1,c-1))
                    edge(r,c) = 0;
                end
            end
        end
    end

end