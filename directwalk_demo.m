% 使用极坐标表示的编队形状
        formation = [
    0	0
    0	35
    0.698131700797732	35
    1.39626340159546	35
    2.09439510239320	35
    2.79252680319093	35
    3.49065850398866	35
    4.18879020478639	35
    4.88692190558412	35
    5.58505360638185	35
    0+0.35	75
    0.698131700797732+0.35	75
    1.39626340159546+0.35	75
    2.09439510239320+0.35	75
    2.79252680319093+0.35	75
    3.49065850398866+0.35	75
    4.18879020478639+0.35	75
    4.88692190558412+0.35	75
    5.58505360638185+0.35	75
    ];
size_temp = size(formation);
num_plane = size_temp(1);
writerObj = VideoWriter('myVideo.avi');
% 生成视频的帧率
writerObj.FrameRate = 24;

open(writerObj);

% *确定迭代的参数*

NUM_STEPS = 1000; %每轮步数
NUM_ROUND = 1; %轮数
rand_dis_list = [0]; %随机扰动值的列表，每一轮从中选取一个值作为扰动值
usenoise = "true"; % 飞行时添加扰动

v_coeff = 0.1;
use_real_loc_init_ploar = "false"; % 在初始化时使用理想坐标，用于debug
%% 
% *使用极坐标初始化编队形状*
% 
% 单位为弧度，米

r_avg_list = zeros(NUM_ROUND,size(rand_dis_list,2));
%此for用于自动化测试初始扰动
for j = 1:size(rand_dis_list,2)

    rand_dis = rand_dis_list(j);
    %此for用于多次实验
    varient_list = zeros(NUM_ROUND,NUM_STEPS);
    varient_upper = zeros(NUM_STEPS,1);
    avg_angle_list = zeros(NUM_ROUND,NUM_STEPS);
    varient_upper_angle = zeros(NUM_STEPS,1);
    varient_list_angle = zeros(NUM_ROUND,NUM_STEPS);
    for i = 1:NUM_ROUND
        

        % 航点信息，x，y，时间
        nav_points = [
            646,118,0;
            1178,351,500;
            1436,621,1000
            ];
        nav_points = gen_nav_points(nav_points,NUM_STEPS);
        real_loc_init_ploar = formation;
        if(use_real_loc_init_ploar == "true")
            [sender_vec_table,ideal_pos,~] = init(formation,rand_dis);
            real_loc_init_ploar(:,1) = deg2rad(real_loc_init_ploar(:,1));
            real_pos = real_loc_init_ploar(:,2).*[cos(real_loc_init_ploar(:,1)),sin(real_loc_init_ploar(:,1))];
        else
            [sender_vec_table,ideal_pos,real_pos] = init(formation,rand_dis);
        end

        real_pos = real_pos + 200;


%% 
% *开始迭代*
        move_geo_log = zeros(0,4);
        move_mom_log = zeros(0,4);
        pos_log = zeros(num_plane,2,0);
        move_temp = zeros(7,2);
        for iter = 1:NUM_STEPS
            %添加噪声
            randsender = randperm (num_plane);
            senders = randsender(1:3);
            senders(1)=1;
            if(usenoise == "true")
                noise = rand(num_plane,2)*0.1;
                for index = 1:3
                    noise(senders(index),:) = [0,0];
                end

                real_pos = real_pos + noise;

            end
            esti_pos = nan(num_plane,2);
            recieved_vec = send(senders,real_pos);
            esti_pos = get_esti_pos(senders,recieved_vec,formation,sender_vec_table,esti_pos);
            move = (ideal_pos - esti_pos)*v_coeff;
            senders = randsender(1:7);
            for s = 1:7

                gnd_esti_pos = get_geo_location(img,getsubimage(img,real_pos(senders(s),:)),senders(s)==1);
                if isnan(gnd_esti_pos)
                    move_temp(s,:) = (ideal_pos(senders(s),:) + nav_points(iter,:)) - (real_pos(senders(s),:)+rand());
                    move_mom_log = cat(1,move_mom_log,[real_pos(senders(s),:),move_temp(s,:)]);
                    disp('isnan')
                else
                    move_temp(s,:) = (ideal_pos(senders(s),:) + nav_points(iter,:)) - gnd_esti_pos;
                    if  norm(move_temp(s,:))>10
                        move_temp(s,:) = (ideal_pos(senders(s),:) + nav_points(iter,:)) - (real_pos(senders(s),:)+rand());
                        move_mom_log = cat(1,move_mom_log,[real_pos(senders(s),:),move_temp(s,:)]);
                        disp('toofast')
                    end
                    disp('-------------')
                    move_geo_log = cat(1,move_geo_log,[real_pos(senders(s),:),move_temp(s,:)]);
                    disp(real_pos(senders(s),:))
                    disp(gnd_esti_pos)
                end
            end
            for s = 1:7
                move(senders(s),:) = move_temp(s,:);
            end
            move(isnan(move)) = 0;
            real_pos = real_pos+move;

            pos_log = cat(3,pos_log,reshape(real_pos,num_plane,2,1));
            if mod(iter,10) == 0
                for index = 1:num_plane
                    sender_vec_table(index,:,:) = unit_vec(real_pos - real_pos(index,:));
                end
            end


%% 
% *评估并记录本轮迭代效果*

            %半径
            r = sqrt(real_pos(2:num_plane,1).*real_pos(2:num_plane,1)+real_pos(2:num_plane,2).*real_pos(2:num_plane,2));
            r_avg = mean(r);
            r_avg_list(i,j) = r_avg;
            varient_list(i,iter) = var(r);
            varient_upper(iter) = max([varient_list(i,iter),varient_upper(iter)]);
            %角度
            [ang_mean,ang_var] = get_angle_mean_var(real_pos);
            avg_angle_list(i,iter) = ang_mean;
            varient_list_angle(i,iter) = ang_var;
            varient_upper_angle(iter) = max([varient_list_angle(i,iter),varient_upper_angle(iter)]);
            
            subplot(1,2,1);
            imshow(img);
            hold on
                plot(nav_points(:,1),nav_points(:,2),'--w','LineWidth',4);
                scatter(real_pos(:,1), real_pos(:,2),20,'*g');
                set(gca,'YDir','reverse');
            hold off
            frame = getframe(gcf);
            %writeVideo(writerObj, frame);
        end
        %此end是多轮测试的结束
    end
    %此end是自动化测试扰动的结束
    close(writerObj);
    
end
%% 
% *绘制迭代结果*

%运动可视化
title("在"+NUM_ROUND+"次迭代中平均半径为"+mean(r_avg_list)+"，平均半径的方差为"+var(r_avg_list));
for index = 1:num_plane
    plot(reshape(pos_log(index,1,:),1,NUM_STEPS),reshape(pos_log(index,2,:),1,NUM_STEPS),'LineWidth',1, 'color', 'jet');
end

scatter(real_pos(:,1), real_pos(:,2),'*','g');
set(gca,'YDir','reverse');
hold off

plot(reshape(pos_log(index,1,:),1,NUM_STEPS),reshape(pos_log(index,2,:),1,NUM_STEPS),'LineWidth',1, 'color', 'jet');
