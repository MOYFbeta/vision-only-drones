function [unit_vecs] = unit_vec(vecs)
%求单位向量,当输入二维数组按行向量运算
    unit_vecs = zeros(size(vecs));
    for index = 1:size(vecs,1)
        unit_vecs(index,:) = (vecs(index,:))./norm(vecs(index,:));
    end
end

