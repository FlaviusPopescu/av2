function [res] = bgdiff(m, bg)

    m = double(m);
    bg = double(bg);

    tred = 20;
    tgreen = 10;
    tblue = 20; 
    res = zeros(size(m));
    
    for i=1:size(m,1)
        for j=1:size(m,2)            
                                     
            if abs(m(i,j,1) - bg(i,j,1)) > tred | abs(m(i,j,2) - bg(i,j,2)) > tgreen | abs(m(i,j,3) - bg(i,j,3)) > tblue
                res(i,j,:) = m(i,j, :);
            else
                res(i,j,:) =  [0; 0; 0];
            end        
        end
    end        

     res = uint8(res);          
    n = bwmorph( im2bw(res,0.15), 'erode', 1  );
    res = double(res);
% %    figure(2)
% %    imshow(n)
% %    figure(1)          
    res(:,:,1) = res(:,:,1) .* n;
    res(:,:,2) = res(:,:,2) .* n;
    res(:,:,3) = res(:,:,3) .* n;       
%     
%                       
    res = uint8(res);

    
    
    
    

end