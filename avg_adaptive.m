% Iteratively we grow the store variable with all the images we have seen.
% Store gets initiated to:
%
%     store = zeros(width, height, 3, 0);
%
% Then we apply this function with every image we see.
function [store, bg] = avg_adaptive(store, curr)
    store(:, :, :, size(store, 4) + 1) = double(curr);
    bg = zeros(size(store, 1), size(store, 2), 3);
    
    for i = 1:size(store, 4)
       bg = bg + double(store(:, :, :, i));
    end
    bg = uint8(round(bg ./ size(store, 4)));
end