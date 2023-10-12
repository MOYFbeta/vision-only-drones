function [real_pos] = step(real_pos,recieved_vec,formation,ideal_pos,noise)
    
    if(noise == "true")
        real_pos = real_pos + rand(size(init_pos))*5;
    end
    esti_pos = get_esti_pos(recieved_vec,formation);
    move = (ideal_pos - esti_pos)*0.1;
    move(isnan(move)) = 0;
    real_pos = real_pos+move;
end

