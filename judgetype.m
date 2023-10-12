function [type] = judgetype(p0,pt)
%判断图像类型
if p0-pt>4
    type =1;
elseif p0-pt<0
    if p0-pt<-4
        type = 2;
    else
        type = 1;
    end
else
    type = 2;
end
