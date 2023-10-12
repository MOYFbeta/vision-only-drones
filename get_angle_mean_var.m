function [ang_mean,ang_var] = get_angle_mean_var(real_pos)
    num_plane = size(real_pos,1);
    pos = [real_pos(2:num_plane,:);real_pos(2,:)];
    
    angle_list = zeros(num_plane-1,1);
    
    for index = 1:num_plane-1
        vec = pos(index,:);
        vecs = pos(index+1,:);
        angle_list(index) = acos((vec(1).*vecs(1) + vec(2).*vecs(2))./( norm(vecs).*norm(vec)));
    end
    
    ang_mean = mean(angle_list);
    ang_var = var(angle_list);
end