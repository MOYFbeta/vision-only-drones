function [angles] = vec_angle_abs(vecs,vec)
%求vecs与vec的夹角绝对值，结果是弧度
    angles = zeros(size(vecs,1),1);
    for index = 1:size(vecs,1)
        angles(index) = ( vec(1).*vecs(index,1) + vec(2).*vecs(index,2))./( norm(vecs(index,:))./norm(vec) );
        angles(index) = abs(acos(angles(index)));
    end
end

