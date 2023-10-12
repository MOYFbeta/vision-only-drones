function [esti_pos] = get_esti_pos(real_sender,recieved_vec,formation,sender_vec_table,old)
    num_plane = size(formation,1);
    esti_pos = zeros(num_plane,2);
    senders = get_sender_index(real_sender,recieved_vec,sender_vec_table);
    for index = 1:num_plane
        if(isnan(senders(index,1)))
            esti_pos(index,:) = [nan,nan];
            continue;
        end
        p = [0,0];
        pindex = [0,0];
        p_cnt = 1;
        p0 = 0;
        for p_index = 1:size(real_sender,2)
            if(senders(index,p_index)~=1)
                p(p_cnt) = senders(index,p_index);
                pindex(p_cnt) = p_index;
                p_cnt = p_cnt+1;
            else
                p0 =p_index;
            end
        end
        if(p(1) == 1 || p(2) == 1||p(1) ==p(2)||p(1) == 0 || p(2) == 0 || p0 == 0)
            esti_pos = old;
        else
            theta1 = vec_angle_abs(reshape(recieved_vec(index,pindex(1),:),1,2), reshape(recieved_vec(index,p0,:),1,2));
            theta2 = vec_angle_abs(reshape(recieved_vec(index,pindex(2),:),1,2), reshape(recieved_vec(index,p0,:),1,2));
            [theta,rho] = get_location2(theta1,theta2,index,p(1),p(2),formation);
            esti_pos(index,:) = rho.*[cos(theta),sin(theta)];
        end
    end
end