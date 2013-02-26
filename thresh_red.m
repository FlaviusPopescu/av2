function [res] = thresh_red(m)
          
  mhsv = rgb2hsv(m);  
   
  h = mhsv(:,:,1);

  res = h > 0.9;
end