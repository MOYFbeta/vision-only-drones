function [radialvec_list,sender_list] = get_theta(real_sender,recieved_vec,formation,sender_vec_table)
 % 获得的径向向量沿着径向向外
    num_plane = size(formation,1);
    senders = get_sender_index(real_sender,recieved_vec,sender_vec_table);
    sender_list = zeros(num_plane,2);
    radialvec_list = zeros(num_plane,2);
    for index = 1:num_plane
        if(isnan(senders(index,1)))
            sender_list(index,:) = [nan,nan];
            radialvec_list(index,:)= [nan,nan];
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
        if(p(1) == 1 || p(2) == 1||p(1) ==p(2)||p(1) == 0 || p(2) == 0)
            sender_list(index,:) = [nan,nan];
        else
            
            sender_list(index,1) = pindex(1);
            sender_list(index,2) = pindex(2);
        end
        if(p0 ~= 0)
            radialvec_list(index,:) = reshape(recieved_vec(index,p0,:),1,2);
        end 
    end
end

