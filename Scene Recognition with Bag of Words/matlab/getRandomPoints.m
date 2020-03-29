function [points] = getRandomPoints(I, alpha)

[h, w, ~] = size(I);

rows = randi(h, alpha, 1);
cols = randi(w, alpha, 1);

points = [rows cols];

end