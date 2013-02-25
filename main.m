function main
    % This function should do the three required tasks from the assignment.
    % It can also be a place where sample usage of the stuff we created is 
    % shown, so that we know what the heck some of this stuff does.
    
    % Task 1: Detection
    
    avgbg = avgall;
    
    files = dir('juggle1/0*.jpg');
    
    for ii = 1:size(files,1)
        Image = imread(['juggle1/', files(ii).name]);
        diff = bgdiff(Image, avgbg);
        imshow(thresh_yellow(diff) + thresh_blue(diff)); 
        pause(1)
    end 
          
    
    
    
    
    
    
    % Task 2: Tracking
    
    % Task 3: Evaluation
end