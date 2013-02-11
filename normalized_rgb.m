function [outimage] = normalized_rgb(image)
    red = double(image(:, :, 1));
    green = double(image(:, :, 2));
    blue = double(image(:, :, 3));
    sum = red + green + blue;
    outimage = zeros(size(image));
    outimage(:, :, 1) = red ./ sum;
    outimage(:, :, 2) = green ./ sum;
    outimage(:, :, 3) = blue ./ sum;
    
end