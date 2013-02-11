function [outimage] = normalized_rgb(image)
    red = double(image(:, :, 1));
    green = double(image(:, :, 2));
    blue = double(image(:, :, 3));
    sum = red + green + blue;
    outimage = [red ./ sum, green ./ sum, blue ./ sum];
    
end