function [senders] = get_sender_index(real_sender,recieved_vec,sender_vec_table)
%根据recieved_vec与sender_vec_table匹配senders的编号
%发射者获得的信息将会被算作nan
    num_plane = size(recieved_vec,1);
    num_sender = size(recieved_vec,2);
    senders = zeros(num_plane,num_sender);
    for me = 1:num_plane
        my_table = reshape(sender_vec_table(me,:,:),num_plane,2);
        for index = 1:num_sender
            my_recieved_vec = reshape(recieved_vec(me,index,:),1,2);
            [~,senders(me,index)] = min(vec_angle_abs(my_table,my_recieved_vec));
        end
    end
    for index = 1:num_sender
        senders(real_sender(index),:) = [nan,nan,nan];
    end
end