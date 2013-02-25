function main
    % This function should do the three required tasks from the assignment.
    % It can also be a place where sample usage of the stuff we created is 
    % shown, so that we know what the heck some of this stuff does.
    
    
    
    % Task 1: Detection
    figure(1, 'I
    avgbg = avgall;
    
    files = dir('juggle1/0*.jpg');
    tracks = zeros(size(files,1), 6);
    
    for ii = 1:size(files,1)
        Image = imread(['juggle1/', files(ii).name]);
        diff = bgdiff(Image, avgbg);
        
        Y = thresh_yellow(diff);
        B = thresh_blue(diff);
       
        cy = biggest_center(Y);
        cb = biggest_center(B);
        
        tracks(ii, :) = [cy, cb, [0, 0]];
        
        hold on
        imshow(Y + B);
        plot(cy(1), cy(2), 'y*', cb(1), cb(2), 'b*');
        drawnow;
        %pause(1)
    end 
    
    
    tracks
    % Task 2: Tracking
    figure(2);
    imshow(imread('background.jpg'))
    hold on
    plot(tracks(:, 1), tracks(:, 2), 'y', tracks(:, 3), tracks(:, 4), 'b')
    
    print('-dpng', 'report/tracking')
    
       
    
    % Task 3: Evaluation
end