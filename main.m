function main(skip_detection)
    % This function should do the three required tasks from the assignment.
    % It can also be a place where sample usage of the stuff we created is 
    % shown, so that we know what the heck some of this stuff does.
    
    
    
    % Task 1: Detection
    
    fg = figure(1);
    avgbg = avgall;
    
		% Kalman globals
		[MR,MC,Dim] = size(avgbg);
		radius = 10;
		
    files = dir('juggle1/0*.jpg');
    tracks = zeros(size(files,1), 6);
    
    % wb = waitbar(0, 'Initializing');
    
    count = size(files,1);
    
		% Kalman filter initialization - red ball
		RR=[[0.2845,0.0045]',[0.0045,0.0455]'];
		H=[[1,0]',[0,1]',[0,0]',[0,0]'];
		Q=0.01*eye(4);
		P = 100*eye(4);
		dt=1;
		A=[[1,0,0,0]',[0,1,0,0]',[dt,0,1,0]',[0,dt,0,1]'];
		g = 6; % pixels^2/time step
		Bu = [0,0,0,g]';
		kfinit=0;
		x=zeros(100,4);

		% Kalman filter initialization - blue ball
		BRR=[[0.2845,0.0045]',[0.0045,0.0455]'];
		BH=[[1,0]',[0,1]',[0,0]',[0,0]'];
		BQ=0.01*eye(4);
		BP = 100*eye(4);
		Bdt=1;
		BA=[[1,0,0,0]',[0,1,0,0]',[Bdt,0,1,0]',[0,Bdt,0,1]'];
		Bg = 6; % pixels^2/time step
		BBu = [0,0,0,Bg]';
		Bkfinit=0;
		Bx=zeros(100,4);

		% Kalman filter initialization - yellow ball
		YRR=[[0.2845,0.0045]',[0.0045,0.0455]'];
		YH=[[1,0]',[0,1]',[0,0]',[0,0]'];
		YQ=0.01*eye(4);
		YP = 100*eye(4);
		Ydt=1;
		YA=[[1,0,0,0]',[0,1,0,0]',[Ydt,0,1,0]',[0,Ydt,0,1]'];
		Yg = 6; % pixels^2/time step
		YBu = [0,0,0,Yg]';
		Ykfinit=0;
		Yx=zeros(100,4);

		
    if nargin == 1 & skip_detection
        tracks = load('track.mat');
        tracks = tracks.tracks;
    else
        for ii = 1:count
            % tic;
            Image = imread(['juggle1/', files(ii).name]);
            diff = bgdiff(Image, avgbg);

            Y = thresh_yellow(diff);
            B = thresh_blue(diff);
            R = thresh_red(diff);

            cy = biggest_center(Y);
            cb = biggest_center(B);
            cr = biggest_center(R);

						% local state for Kalman - red ball
						rcc(ii) = cr(1);
						rcr(ii) = cr(2);
						
						% local state for Kalman - blue ball
						bcc(ii) = cb(1);
						bcr(ii) = cb(2);
						
						% local state for Kalman - yellow ball
						ycc(ii) = cy(1);
						ycr(ii) = cy(2);

						% store tracks
            tracks(ii, :) = [cy, cb, cr];
            set(fg, 'name', files(ii).name);
            imshow(R + Y + B);
            hold on
            plot(cy(1), cy(2), 'y*', cb(1), cb(2), 'b*', cr(1), cr(2), 'r*');
            
					  % Kalman update - red
					  if kfinit==0
					    xp = [MC/2,MR/2,0,0]' ;
					  else
					    xp=A*x(ii-1,:)' + Bu ;
					  end
					  kfinit=1;
					  PP = A*P*A' + Q ;
					  K = PP * H' * inv(H*PP*H'+RR)  ;
					  x(ii,:) = (xp + K * ([rcc(ii),rcr(ii)]' - H * xp))';

					  P = (eye(4) - K * H) * PP ;

				    for c = -0.97*radius: radius/20 : 0.97*radius
				      r = sqrt(radius^2-c^2);
				      plot(x(ii,1)+c,x(ii,2)+r,'r.')
				      plot(x(ii,1)+c,x(ii,2)-r,'r.')
				    end						

					  % Kalman update - blue
					  if Bkfinit==0
					    Bxp = [MC/2,MR/2,0,0]' ;
					  else
					    Bxp=BA*Bx(ii-1,:)' + BBu ;
					  end
					  Bkfinit=1;
					  BPP = BA*BP* BA' + BQ ;
					  BK = BPP * BH' * inv(BH*BPP*BH'+ BRR)  ;
					  Bx(ii,:) = (Bxp + BK * ([bcc(ii),bcr(ii)]' - BH * Bxp))';

					  BP = (eye(4) - BK * BH) * BPP ;

				    for c = -0.97*radius: radius/20 : 0.97*radius
				      r = sqrt(radius^2-c^2);
				      plot(Bx(ii,1)+c,Bx(ii,2)+r,'b.')
				      plot(Bx(ii,1)+c,Bx(ii,2)-r,'b.')
				    end						


					  % Kalman update - yellow
					  if Ykfinit==0
					    Yxp = [MC/2,MR/2,0,0]' ;
					  else
					    Yxp=YA*Yx(ii-1,:)' + YBu ;
					  end
					  Ykfinit=1;
					  YPP = YA*YP* YA' + YQ ;
					  YK = YPP * YH' * inv(YH*YPP*YH'+ YRR)  ;
					  Yx(ii,:) = (Yxp + YK * ([ycc(ii),ycr(ii)]' - YH * Yxp))';

					  YP = (eye(4) - YK * YH) * YPP ;

				    for c = -0.97*radius: radius/20 : 0.97*radius
				      r = sqrt(radius^2-c^2);
				      plot(Yx(ii,1)+c,Yx(ii,2)+r,'y.')
				      plot(Yx(ii,1)+c,Yx(ii,2)-r,'y.')
				    end						
						
						
						
						drawnow;
            % pause(1 - toc)
            % perc = ii/(size(files,1) * 2 + 4);
            %waitbar(perc,wb,sprintf('%d%% completed...',round(perc * 100)));
        end 
        save('track.mat', 'tracks');
    end
    
    % Task 2: Tracking
    figure(1);
    imshow(imread('background.jpg'))
    hold on
    plot(tracks(:, 1), tracks(:, 2), 'y', tracks(:, 3), tracks(:, 4), 'b', tracks(:, 5), tracks(:, 6), 'r')
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
    
    
    
    disp(sprintf('Average distance from true center %fpx (SD=%f)', mean(overall_d), std(overall_d)));
    
    fg = figure(1);
    delete('fixme/*.png');
    
    for ii = 1:count
        tic;
        Image = imread(['juggle1/', files(ii).name]);
        set(fg, 'name', files(ii).name);
        imshow(Image);
        hold on
				plot(tracks(ii, 1), tracks(ii, 2), 'y+',tracks(ii, 3), tracks(ii, 4), 'b+', tracks(ii,5), tracks(ii, 6), 'r+');
				plot(gt(ii, 7), gt(ii, 6), 'y*', gt(ii,5), gt(ii, 4), 'b*', gt(ii,3), gt(ii,2), 'r*');
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
    
    
    % Cleanup
    
    close(fg);
    close(wb);
    
end