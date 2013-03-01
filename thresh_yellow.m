function [res] = thresh_yellow(m)
  mhsv = rgb2hsv(m);
  h = mhsv(:,:,1);
  res = h > 0.20 & h < 0.3;
end