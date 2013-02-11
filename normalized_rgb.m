% NORMALIZED_RGB returns an image which should be 
% lightness invariant.
function [outimage] = normalized_rgb(image)
    % Select the individual channels
    red = double(image(:, :, 1));
    green = double(image(:, :, 2));
    blue = double(image(:, :, 3));
    
    sum = red + green + blue;
    % Make a matrix of the original dimensions and
    % fill it.
    outimage = zeros(size(image));
    outimage(:, :, 1) = red ./ sum;
    outimage(:, :, 2) = green ./ sum;
    outimage(:, :, 3) = blue ./ sum;
end