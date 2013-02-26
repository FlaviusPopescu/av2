function [res] = get_max_diff()
    ev = load('gt1.mat');
    gt = ev.gt1';
	gt = gt(:,[2:7]);
	
    % We shift the tracked images to have two time points, in between which
    % we calculate the maximum difference.
	t1 = gt([1:(size(gt,1)-1)], :);
    t2 = gt([2:(size(gt,1))], :);
		
	res = max([ sqrt(sum(t1(:,[1,2]) - t2(:,[1,2]), 2) .^ 2);
	 			sqrt(sum(t1(:,[3,4]) - t2(:,[3,4]), 2) .^ 2);
			    sqrt(sum(t1(:,[5,6]) - t2(:,[5,6]), 2) .^ 2)] );
								
end