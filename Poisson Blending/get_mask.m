function mask = get_mask(im)
% mask = getMask(im)
% Asks user to draw polygon around input image.
% Provides binary mask of polygon

disp('\n\nSelect a region to copy. You can click multiple times to specify the boundaries of your patch, then press "Q" to get a closed patch.\n\n')
figure(1), hold off, imagesc(im), axis image;
[imh, imw, ~] = size(im);
sx = [];
sy = [];
while 1
    figure(1)
    [x, y, b] = ginput(1);
    if b=='q' || b=='Q'
        break;
    end
    if x<2
        x=2;
    end
    if y<2
        y=2;
    end
    if x>imw-1
        x=imw-1;
    end
    if y>imh-1
        y=imh-1;
    end
    sx(end+1) = x;
    sy(end+1) = y;
    hold on, plot(sx, sy, '*-');
end

mask = poly2mask(sx, sy, size(im, 1), size(im, 2));

end
