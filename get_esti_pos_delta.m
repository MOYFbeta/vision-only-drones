function [esti_pos] = get_esti_pos_delta(real_sender,recieved_vec,delta_formation,old)
    num_plane = size(delta_formation,1);
    esti_pos = zeros(num_plane,2);
    senders = real_sender;
    parfor index = 1:num_plane
        if(index == real_sender(1) || index == real_sender(2) ||index == real_sender(3))
            esti_pos(index,:) = [nan,nan];
            continue;
        end
        p = [0,0];
        pindex = [0,0];
        p_cnt = 1;
        p0 = 0;
        td_recv_vec = zeros(3,3);
        td_recv_vec(1,:) = [reshape(recieved_vec(index,1,:),1,2),0];
        td_recv_vec(2,:) = [reshape(recieved_vec(index,2,:),1,2),0];
        td_recv_vec(3,:) = [reshape(recieved_vec(index,3,:),1,2),0];
        for p_index = 1:3
            sig = 1;
            for q_index = 1:3
                cr = sign(cross(td_recv_vec(q_index,:),td_recv_vec(p_index,:)));
                cr = cr(3);
                if(cr ~= 0)
                    sig = sig*cr;
                end
            end
            
            if(sig == -1)
                p0 =p_index;
            else
                p(p_cnt) = senders(p_index);
                pindex(p_cnt) = p_index;
                p_cnt = p_cnt+1;
            end
        end
        if(p(1) == 1 || p(2) == 1||p(1) ==p(2)||p(1) == 0 || p(2) == 0 || p0 == 0)
            esti_pos(index,:) = old(index,:);
            continue;
        end
        theta1 = vec_angle_abs(reshape(recieved_vec(index,pindex(1),:),1,2), reshape(recieved_vec(index,p0,:),1,2));
        theta2 = vec_angle_abs(reshape(recieved_vec(index,pindex(2),:),1,2), reshape(recieved_vec(index,p0,:),1,2));
        
        [r1,o11,o12] = cal_circle(delta_formation(p(1),:),delta_formation(p(2),:),theta1);
        [r2,o21,o22] = cal_circle(delta_formation(p(1),:),delta_formation(p(2),:),theta2);
        
        o1 = [o11;o12];
        o2 = [o21;o22];
        
        esti_result_list = zeros(4,2);
        cnt = 1;
        for i = 1:2
            for j = 1:2
                [ans1,ans2] = cal_cord(o1(i,:),r1,o2(j,:),r2);
                esti_result_list(cnt,:) = ans1;
                cnt = cnt + 1;
                esti_result_list(cnt,:) = ans2;
                cnt = cnt + 1;
            end
        end
        dist = 2333333333;
        for i = 1:4
            new_dist = norm(reshape(esti_result_list(i,:),1,2) - reshape(delta_formation(index,:),1,2));
            if(norm(new_dist) < dist)
                dist = new_dist;
                esti_pos(index,:) = reshape(esti_result_list(i,:),1,2);
            end
        end
    end
end