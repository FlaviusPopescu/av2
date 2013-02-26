function [res] = get_max_diff
	% load 'track.mat' % get points in var tracks of size 99 x 6
	
	% t1 = tracks([1:(size(tracks,1)-1)], :);
  % t2 = tracks([2:(size(tracks,1))], :);

	load 'gt1.mat';
  ev = load('gt1.mat');
  gt = ev.gt1';
	gt = gt(:,[2:7]);
	
	t1 = gt([1:(size(gt,1)-1)], :);
  t2 = gt([2:(size(gt,1))], :);
		
	res = max([  sqrt(sum(t1(:,[1,2]) - t2(:,[1,2]), 2) .^ 2);
	 							sqrt(sum(t1(:,[3,4]) - t2(:,[3,4]), 2) .^ 2);
								sqrt(sum(t1(:,[5,6]) - t2(:,[5,6]), 2) .^ 2)] );
								
end