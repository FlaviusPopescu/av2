load gt1

files = dir('juggle1/0*.jpg')

figure(1);
for ii = 1:size(files,1)
    Image = imread(['juggle1/', files(ii).name]);
    imshow(Image);
    hold on;   
    
    % plot ground truth points
    plot(gt1(3,ii),gt1(2,ii),'r.');
    plot(gt1(5,ii),gt1(4,ii),'g.');
    plot(gt1(7,ii),gt1(6,ii),'y.');
    
    % calculate ball centres
    
    
    
    drawnow;
    pause(1)
end
