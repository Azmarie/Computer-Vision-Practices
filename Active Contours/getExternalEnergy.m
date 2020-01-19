function [Eext] = getExternalEnergy(I,Wline,Wedge,Wterm)

% Eline: This energy is equal to the intensities of the image
Eline = I;

% Eedge: An edge in an image is a contour with a large image gradient
% 'Sobel' filter will cause wiggly lines, 'intermediate' seems right 
[Gmag, Gdir] = imgradient(I, 'intermediate');
Eedge = Gmag* -1;

% Eterm
first_d_mask_x = [-1 1];
first_d_mask_y = [-1; 1];
second_d_mask_x = [1 -2 1];
second_d_mask_y = [1; -2; 1];
first_d_mask_x_y = first_d_mask_x.*first_d_mask_y;

Cx = conv2(I, first_d_mask_x,'same');
Cy = conv2(I, first_d_mask_y,'same');
Cxx = conv2(I, second_d_mask_x,'same');
Cyy = conv2(I, second_d_mask_y,'same');
Cxy = conv2(I, first_d_mask_x_y, 'same');

Eterm = (Cyy.*Cx.^2 - 2*Cxy.*Cx.*Cy + Cxx.*Cy.^2)./(1+Cx.^2+Cy.^2).^(3/2);

% Eext
Eext = Wline*Eline + Wedge*Eedge + Wterm*Eterm;

end
