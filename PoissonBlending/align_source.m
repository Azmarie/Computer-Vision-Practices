function [im_s2, mask2] = align_source(im_s, mask, im_t)
% GUI for aligning

disp('\n\nChoose target location. Click in the image to preview. Press "W""S" to resize and "A""D" to rotate. Press "Q" to finish.\n\n')
[imh, imw, ~] = size(im_t);
tx = imw/2; ty = imh/2;
scale = 1.0;
angle = 0.0;

while 1
    im_s_copy = imrotate(im_s,angle);
    im_s_copy = imresize(im_s_copy,scale);
    mask_copy = imrotate(mask,angle,'nearest');
    mask_copy = imresize(mask_copy,scale,'nearest');
    [y, x] = find(mask_copy);
    y1 = min(y)-1;
    y2 = max(y)+1;
    x1 = min(x)-1;
    x2 = max(x)+1;
    [imsh, imsw, ~] = size(im_s_copy);
    if y1<1 || y2>imsh || x1<1 || x1>imsw
        scale = scale+0.05;
        im_s_copy = imresize(im_s,scale);
        mask_copy = imresize(mask,scale,'nearest');
        [y, x] = find(mask_copy);
        y1 = min(y)-1;
        y2 = max(y)+1;
        x1 = min(x)-1;
        x2 = max(x)+1;
    end
    
    temp = im_t;
    
    yind2 = (y1:y2) - round(mean(y)) + round(ty);
    yind2 = min(max(yind2,1),imh);
    yind = yind2 + round(mean(y)) - round(ty);
    xind2 = (x1:x2) - round(mean(x)) + round(tx);
    xind2 = min(max(xind2,1),imw);
    xind = xind2 + round(mean(x)) - round(tx);
    
    y = y - round(mean(y)) + round(ty);
    y = min(max(y,1),imh);
    x = x - round(mean(x)) + round(tx);
    x = min(max(x,1),imw);
    
    ind = y + (x-1)*imh;
    mask2 = false(imh,imw);
    mask2(ind) = true;
    im_s2 = zeros(size(im_t));
    im_s2(yind2, xind2, :) = im_s_copy(yind, xind, :);
    temp(repmat(mask2, [1 1 3])) = im_s2(repmat(mask2, [1 1 3]));
    
    figure(2); hold off, imagesc(temp), axis image;
    
    [tx, ty, b] = ginput(1);
    if b=='q' || b=='Q'
        break;
    end
    if b=='w' || b=='W'
        scale = scale+0.05;
    end
    if b=='s' || b=='S'
        scale = scale-0.05;
        if scale<0.1
            scale = 0.1;
        end
    end
    if b=='a' || b=='A'
        angle = angle+11.25;
    end
    if b=='d' || b=='D'
        angle = angle-11.25;
    end
end

