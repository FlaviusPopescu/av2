% Calculating the average background image
% ----------------------------------------
% To calculate the average background we iterate through all the images and
% simply average their numerical values.
function [avgbg] = avgall
    files = dir('juggle1/0*.jpg');
    avgbg = zeros(size( imread('background.jpg')) , 'double' );
    for ii = 1:size(files,1)
        Image = imread(['juggle1/', files(ii).name]);
        avgbg = avgbg + double(Image);    
    end 


    avgbg = uint8(  avgbg / size(files,1)  ); 
end

