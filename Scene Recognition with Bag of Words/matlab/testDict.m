close;
clear all;

% image = imread('../data/airport/sun_aerinlrdodkqnypz.jpg');
% image = imread('../data/airport/sun_agxjkxyxedwlzvkg.jpg');

% image = imread('../data/auditorium/sun_adkfrlwqzwfzhspj.jpg');
% image = imread('../data/auditorium/sun_avvpglttnlncekyi.jpg');

% image = imread('../data/campus/sun_anlhyjfjqfdgfgzl.jpg');
image = imread('../data/campus/sun_acfgwrhgcjrpcbru.jpg');


random = load('dictionaryRandom.mat', 'dictionary');
harris = load('dictionaryHarris.mat', 'dictionary');
filterBank = createFilterBank();

figure; imshow(label2rgb(getVisualWords(image, filterBank, random.dictionary))); hold on;
saveas(gcf, '../results/3-random-campus-1.png')

figure; imshow(label2rgb(getVisualWords(image, filterBank, harris.dictionary))); hold on;
saveas(gcf, '../results/3-harris-campus-1.png')

figure; imshow(image);
saveas(gcf, '../results/3-campus-1.png')
