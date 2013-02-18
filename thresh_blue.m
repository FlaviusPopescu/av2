function [res] = thresh_blue(m)
          
  mhsv = rgb2hsv(m);  
   
  h = mhsv(:,:,1);
  s = mhsv(:,:,2);
  v = mhsv(:,:,3);
  
  class(mhsv)
  class(h)
              
  for i=1:size(mhsv,1)
      for j=1:size(mhsv,2)            
          if h(i,j) > 0.47 & h(i,j) < 0.65
            res(i,j,:) = m(i,j,:);
          else  
            res(i,j,:) = [255; 255; 255];
          end                         
                  
      end
  end        

  res = uint8(res);
  imshow(res);





end