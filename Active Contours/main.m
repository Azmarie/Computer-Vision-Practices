clear;
close all;

file_name = 'circle.jpg';
expression = '\.';
reg = regexp(file_name,expression,'split');
img_name = reg{1};

% Parameters (play around with different images and different parameters)
% N = 200;
% alpha = 0.10;
% beta = 0.8;
% gamma = 0.2;
% kappa = 0.15;
% Wline = 0.5;
% Wedge = 0.7;
% Wterm = 0.5;
% sigma = 0.5;

% save(strcat('data/', img_name, '.mat'),'N','alpha','beta','gamma','kappa','Wline','Wedge','Wterm', 'sigma');
load(strcat('data/', img_name, '.mat'));

% Load image
I = imread(strcat('images/', file_name));
if (ndims(I) == 3)
    I = rgb2gray(I);
end

% Initialize the snake
[x, y] = initializeSnake(I);

% Calculate external energy
I_smooth = double(imgaussfilt(I, sigma));
Eext = getExternalEnergy(I_smooth,Wline,Wedge,Wterm);

% Calculate matrix A^-1 for the iteration
Ainv = getInternalEnergyMatrix(size(x,2), alpha, beta, gamma);
% Ainv = getInternalEnergyMatrixBonus(size(x,2), alpha, beta, gamma);

% Iterate and update positions
displaySteps = floor(N/10);
for i=1:N
    % Iterate
    [x,y] = iterate(Ainv, x, y, Eext, gamma, kappa);

    % Plot intermediate result
    imshow(I); 
    hold on;
    plot([x x(1)], [y y(1)], 'r', 'LineWidth', 2);
        
    % Display step
    if(mod(i,displaySteps)==0)
        fprintf('%d/%d iterations\n',i,N);
    end
    
    pause(0.0001)
end
 
if(displaySteps ~= N)
    fprintf('%d/%d iterations\n',N,N);
end