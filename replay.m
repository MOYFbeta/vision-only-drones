X0 = 1:NUM_STEPS;
SMOOTH_NUM_STEPS = 20000;
X1 = 1:SMOOTH_NUM_STEPS;

pos_log_smooth = zeros(10,2,SMOOTH_NUM_STEPS);

for index = 1:num_plane
    pos_log_smooth(index,1,:) = interp1(X0, smoothdata(reshape(pos_log(index,1,:),[1,NUM_STEPS]), 'movmean', 5), X1, 'v5cubic');
    pos_log_smooth(index,2,:) = interp1(X0, smoothdata(reshape(pos_log(index,2,:),[1,NUM_STEPS]), 'movmean', 5), X1, 'v5cubic');
end

imshow(img);
hold on
set(gca,'YDir','reverse');  
for i = 1:num_plane
    plot(reshape(pos_log_smooth(i,1,100:SMOOTH_NUM_STEPS),[1,SMOOTH_NUM_STEPS-99]), reshape(pos_log_smooth(i,2,100:SMOOTH_NUM_STEPS),[1,SMOOTH_NUM_STEPS-99]),'LineWidth',2);
end
hold off
%writerObj = VideoWriter('myVideo_smooth.avi');
%writerObj.FrameRate = 120;
%open(writerObj);

%for i = 1:SMOOTH_NUM_STEPS
%    imshow(img);
%    hold on
%    plot(nav_points(:,1),nav_points(:,2),'--w','LineWidth',4);
%    scatter(pos_log_smooth(:,1,i), pos_log_smooth(:,2,i),'*','g');
%    set(gca,'YDir','reverse');
%    hold off
%    frame = getframe(gcf);
%    writeVideo(writerObj, frame);
%end


