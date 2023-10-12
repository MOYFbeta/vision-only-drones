function [recieved_vec] = send(senders,real_pos)
% 发送定位信号
    num_plane = size(real_pos,1);
    num_sender = size(senders,2);
    recieved_vec = zeros(num_plane,num_sender,2);
    for index = 1:num_sender
        recieved_vec(:,index,:) = unit_vec(real_pos(senders(index),:)-real_pos);
    end
end

