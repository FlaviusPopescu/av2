function [res] = thresh_blue(m)
  mhsv = rgb2hsv(m);  
  h = mhsv(:,:,1);
  res = h > 0.47 & h < 0.65;
end