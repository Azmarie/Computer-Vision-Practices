close;
clear all ;

% Load
load('../data/PnP.mat', 'cad', 'x', 'X', 'image');

% Run
P = estimate_pose(x, X);
[K, R, t] = estimate_params(P);
N = size(X, 2);

% Project the given 3D points X onto the image
xProjected = P * [X; ones(1, N)];
xProjected = xProjected(1:2,:)./ xProjected(end, :);

% Plot the given 2D points x and the projected 3D points on screen
figure; imshow(image,[]); hold on;
plot(x(1,:), x(2,:), '.b');
plot(xProjected(1,:), xProjected(2,:), 'ok', 'MarkerSize', 10);
hold off;
saveas(gcf, '../results/6-projectedPoints.png')

% Draw the CAD model rotated by your estimated rotation R on screen
rotatedCAD = cad.vertices * R.';
figure;
trimesh(cad.faces, rotatedCAD(:,1), rotatedCAD(:,2), rotatedCAD(:,3));
saveas(gcf, '../results/6-rotatedCAD.png')

% Project the CAD?s all vertices onto the image and 
% draw the projected CAD model overlapping with the 2D image.
cad.vertices(:, end+1) = 1;
cadProjected = cad.vertices * P.';
cadProjected = cadProjected(:, 1:2) ./ cadProjected(:, end);
figure; 
ax = axes;
imshow(image);
hold on;
patch(ax, 'Faces', cad.faces, 'Vertices', cadProjected, 'FaceColor', 'yellow', 'FaceAlpha', .2, 'EdgeColor', 'none'); 
hold on;
saveas(gcf, '../results/6-finalCAD.png')

