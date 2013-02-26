% Task 1: Detection
% -----------------
%
% The algorithm starts by calculating the average background from all
% the images gathered (see `avgall` bellow), and doing some setup.
% Also an option for skipping this step is presented.
function main(skip_detection)    
    avgbg = avgall;
    
    fg = figure(1);
    files = dir('juggle1/0*.jpg');
    tracks = zeros(size(files,1), 6);
    wb = waitbar(0, 'Initializing');
    count = size(files,1);
		
		thresh_reg = 40;
    
		kinit = 0;
		
    if nargin == 1 & skip_detection
        tracks = load('track.mat');
        tracks = tracks.tracks;
    else
        for ii = 1:count
            tic;
            Image = imread(['juggle1/', files(ii).name]);
            % The algorithm processes each input image. It substracts the 
            % average background image, keeping the colours intact in
            % places where the difference is large enough. Then we
            % calculate thresholds for the individual color values.
            diff = bgdiff(Image, avgbg);

						diff = double(diff);
						if kinit == 1
							yc = round(tracks(ii-1, [1]));
							yr = round(tracks(ii-1, [2]));
							bc = round(tracks(ii-1, [3]));
							br = round(tracks(ii-1, [4]));
							rc = round(tracks(ii-1, [5]));
							rr = round(tracks(ii-1, [6]));
							
							y_rows = [max(yr - thresh_reg, 1) : min(yr + thresh_reg, size(diff,1))];
							y_cols = [max(yc - thresh_reg, 1) : min(yc + thresh_reg, size(diff,2))];
							b_rows = [max(br - thresh_reg, 1) : min(br + thresh_reg, size(diff,1))];
							b_cols = [max(bc - thresh_reg, 1) : min(bc + thresh_reg, size(diff,2))];
							r_rows = [max(rr - thresh_reg, 1) : min(rr + thresh_reg, size(diff,1))];
							r_cols = [max(rc - thresh_reg, 1) : min(rc + thresh_reg, size(diff,2))];
							
							y_mask = zeros(size(diff));
							b_mask = zeros(size(diff));
							r_mask = zeros(size(diff));
							
							y_mask(y_rows, y_cols, :) = 1;
							b_mask(b_rows, b_cols, :) = 1;
							r_mask(r_rows, r_cols, :) = 1;
														
							ydiff = double(diff .* double(y_mask));
							bdiff = double(diff .* double(b_mask));
							rdiff = double(diff .* double(r_mask));
						else
							ydiff = diff;
							bdiff = diff;
							rdiff = diff;
						end
						
						kinit = 1;

            Y = thresh_yellow(ydiff);
            B = thresh_blue(bdiff);
            R = thresh_red(rdiff);
            
            % Then we calculate the centroid of the biggest continous blob
            % in our thresholded image and store them in our tracking
            % matrix.
            cy = biggest_center(Y);
            cb = biggest_center(B);
            cr = biggest_center(R);
            tracks(ii, :) = [cy, cb, cr];
            
            set(fg, 'name', files(ii).name);
            imshow(R + Y + B);
            hold on
            plot(cy(1), cy(2), 'y*', cb(1), cb(2), 'b*', cr(1), cr(2), 'r*');
            drawnow;
						
						
            pause(1 - toc)
            perc = ii/(size(files,1) * 2 + 4);
            waitbar(perc,wb,sprintf('%d%% completed...',round(perc * 100)));
        end 
        save('track.mat', 'tracks');
    end
    
    % Task 2: Tracking
    % ----------------
    % Tracking is largely done in the previous step, here we visualise the
    % individual required images as well as an overall image of the
    % juggling.
    figure(1);
    imshow(imread('background.jpg'))
    hold on
    plot(tracks(:, 1), tracks(:, 2), 'y', tracks(:, 3), ...
        tracks(:, 4), 'b', tracks(:, 5), tracks(:, 6), 'r')
    print('-dpng', 'report/tracking')
    
    figure(1);
    imshow(imread('background.jpg'))
    hold on
    plot(tracks(:, 1), tracks(:, 2), 'y')
    print('-dpng', 'report/tracking-yellow')
    
    figure(1);
    imshow(imread('background.jpg'))
    hold on
    plot(tracks(:, 3), tracks(:, 4), 'b')
    print('-dpng', 'report/tracking-blue')
    
    figure(1);
    imshow(imread('background.jpg'))
    hold on
    plot(tracks(:, 5), tracks(:, 6), 'r')
    print('-dpng', 'report/tracking-red')
       
    
    % Task 3: Evaluation
    % ------------------
    % 
    % We load the true data and calculate euclidian distance from the true
    % data and our tracked data. We then count the number of images that
    % were tracked more then 10px off as well as the average error.
    ev = load('gt1.mat');
    gt = ev.gt1';
    
    yellow_d = sqrt(sum(gt(:,[7,6]) - tracks(:,[1,2]), 2) .^ 2);
    blue_d   = sqrt(sum(gt(:,[5,4]) - tracks(:,[3,4]), 2) .^ 2);
    red_d    = sqrt(sum(gt(:,[3,2]) - tracks(:,[5,6]), 2) .^ 2);
    
    yellow_correct = sum(yellow_d < 10);
    blue_correct   = sum(blue_d < 10);
    red_correct    = sum(red_d < 10);
    
    overall_d = [yellow_d; blue_d; red_d];
    overall   = (yellow_correct + blue_correct + red_correct) / (count * 3);
    
    disp(sprintf('%f%% within 10px of true center (R=%f%%, Y=%f%%, B=%f%%)', ...
        overall * 100, red_correct / count * 100, yellow_correct / count * 100, ...
        blue_correct / count * 100)); 

    disp(sprintf('Average distance from true center %fpx (SD=%f)', ...
        mean(overall_d), std(overall_d)));
    
    fg = figure(1);
    delete('fixme/*.png');
    % Finally we will display each image with the tracked center and the
    % real center, saving to disk those that are more then 10px off.
    for ii = 1:count
        tic;
        Image = imread(['juggle1/', files(ii).name]);
        set(fg, 'name', files(ii).name);
        imshow(Image);
        hold on
		plot(tracks(ii, 1), tracks(ii, 2), 'y+', ...
            tracks(ii, 3), tracks(ii, 4), 'b+', ...
            tracks(ii,5), tracks(ii, 6), 'r+');
		plot(gt(ii, 7), gt(ii, 6), 'y*', ...
            gt(ii,5), gt(ii, 4), 'b*', ...
            gt(ii,3), gt(ii,2), 'r*');
        drawnow;
        pause(1 - toc)
        perc = (ii + size(files,1))/(size(files,1) * 2 + 4);
        
        [pathstr, name, ext] = fileparts(files(ii).name);
        
        if yellow_d(ii) > 10 
            print('-dpng', ['fixme/' name 'yellow']);
        end
        if blue_d(ii) > 10
            print('-dpng', ['fixme/' name 'blue']);
        end
        if red_d(ii) > 10
            print('-dpng', ['fixme/' name 'red']);
        end
        
        waitbar(perc,wb,sprintf('%d%% completed...',round(perc * 100)));
    end 
    
    close(fg);
    close(wb);
    
end