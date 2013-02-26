function [res] = thresh_yellow(m)
  mhsv = rgb2hsv(m);
  h = mhsv(:,:,1);
  res = h > 0.13 & h < 0.25;
end