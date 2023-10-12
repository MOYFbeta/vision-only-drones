function [sender_vec_table,ideal_pos,real_pos] = init(formation,noise)
    
    num_plane = size(formation,1);
    ideal_pos = formation(:,2).*[cos(formation(:,1)),sin(formation(:,1))];
    real_pos = ideal_pos;
    %real_pos = real_pos + (rand(size(ideal_pos))-0.5)*noise*2;
    real_pos(1,:) = [0,0];
    sender_vec_table = zeros(num_plane,num_plane,2);
    for index = 1:num_plane
        sender_vec_table(index,:,:) = unit_vec(ideal_pos - ideal_pos(index,:));
    end
end