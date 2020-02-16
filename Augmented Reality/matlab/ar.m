close all;
clear all;

% Creating an Augmented Reality application 

%% Load input image and videos

cover_image = imread('../data/cv_cover.jpg');
[book_movie, book_frames] = loadVid('../data/book.mov');
[source_movie, src_frames] = loadVid('../data/ar_source.mov');

[cover_h, cover_w] = size(cover_image);

% Pre-calculate the crop ratio (for a similar ratio with the cover)
[source_movie_h, source_movie_w, source_movie_c] = size(source_movie(1).cdata);
crop_ratio_h = max(0.13, (source_movie_h-cover_h)/(2*source_movie_h));
crop_ratio_w = max(0, (source_movie_w-cover_w)/(2*source_movie_w));

crop_up = max(1, uint32(crop_ratio_h*source_movie_h));
crop_left = max(1, uint32(crop_ratio_w*source_movie_w));

%% Initialize output video
num_frames = uint32(min(book_frames, src_frames));
output_movie = book_movie(1: num_frames);

video_object = VideoWriter('../results/ar_movie.avi','MPEG-4');
open(video_object);

%% Iterative through frames and overlay with warped ar source
for i = 1:num_frames
    % Take frames
    book_frame = book_movie(i).cdata;
    source_frame = source_movie(i).cdata;
    
    % Central crop frame_source_mov
    source_frame = source_frame(crop_up:source_movie_h-crop_up, crop_left:source_movie_w-crop_left, :);
    
    % Get matches points
    [locs1, locs2] = matchPics_mov(cover_image, book_frame);
   
    % Get fundamental matrix
    [bestH2to1, ~] = computeH_ransac(locs1, locs2);
    
    % Resize source frame
    source_frame = imresize(source_frame, [cover_h, cover_w]);
    
    % Composite frame
    output_movie(i).cdata = compositeH(inv(bestH2to1), source_frame, book_frame);
    % imshow(compositeH(inv(bestH2to1), source_frame, book_frame));
    writeVideo(video_object,output_movie(i).cdata);

end

close(video_object);
