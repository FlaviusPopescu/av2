function [C] = biggest_center(BW)
    % Find the centroid of the biggest object
    CC = bwconncomp(BW);
    S = regionprops(CC,'Centroid');
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [biggest,idx] = max(numPixels);
    C = S(idx).Centroid;
end