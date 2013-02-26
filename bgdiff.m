% Background substraction
% -----------------------
% We start by defining threshold values for each colour channel.
function [res] = bgdiff(m, bg)
    m = double(m);
    bg = double(bg);
    
    tred = 20;
    tgreen = 10;
    tblue = 20; 
    res = zeros(size(m));
    
    % Then we loop through each pixel and compare the difference in colour
    % of our image and the background image to the threshold value. If the
    % difference is too big, we set the pixel to black, otherwise we keep
    % the original colour.
    for i=1:size(m,1)
        for j=1:size(m,2)                    
            if abs(m(i,j,1) - bg(i,j,1)) > tred | ...
                    abs(m(i,j,2) - bg(i,j,2)) > tgreen | ...
                    abs(m(i,j,3) - bg(i,j,3)) > tblue
                res(i,j,:) = m(i,j, :);
            else
                res(i,j,:) =  [0; 0; 0];
            end        
        end
    end        
    
    % Since the difference is calculated from an average image, there are
    % plenty of artifacts that can confuse the later algorithm. We make a
    % copy of our image and threshold it to black and white. Then we erode
    % the images and use the result as a mask to further get rid of areas
    % with colours.
    res = uint8(res);          
    n = bwmorph(im2bw(res,0.15), 'erode', 1);
    
    res = uint8(double(res) .* repmat(n, [1 1 3]));
end