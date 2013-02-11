function [res] = bgdiff_channel(m, bg)

    m = double(m);
    bg = double(bg);

    tred = 50;
    tgreen = 50;
    tblue = 50; 
    res = zeros(size(m));
    
    for i=1:size(m,1)
        for j=1:size(m,2)            
                                    
                                                                                                                        
            % if i == 243 & j == 327
            %    m(i,j,:)
            %    bg(i,j,:)   
            %    abs(m(i,j,1) - bg(i,j,1))
            %    'asdf'
            %    m(i,j,1)
            %    bg(i,j,1)                                                                                             
            %    'asdf'
            %    (abs(m(i,j,1) - bg(i,j,1)) > tred) | (abs(m(i,j,2) - bg(i,j,2)) > tgreen) | (abs(m(i,j,3) - bg(i,j,3)) > tblue)
            % end
            
            if abs(m(i,j,1) - bg(i,j,1)) > tred
                res(i,j,1) = m(i,j,1);
            else
                res(i,j,1) = 0;
            end                                
            
            if abs(m(i,j,2) - bg(i,j,2)) > tgreen
                res(i,j,2) = m(i,j,2);
            else
                res(i,j,2) = 0;
            end                                
            
            if abs(m(i,j,3) - bg(i,j,3)) > tblue
                res(i,j,3) = m(i,j,3);
            else
                res(i,j,3) = 0;
            end                                
        end
    end      
    res = uint8(res);
    
    
    

end