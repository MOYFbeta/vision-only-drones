function [ans1,ans2] = cal_cord(p1,r1,p2,r2)
x1 = p1(1);
y1 = p1(2);
x2 = p2(1);
y2 = p2(2);
% 输入两个适合的圆心坐标，求二者交点的两个交点，需要根据最接近的原则选出预测坐标
 t = r1^2-r2^2-(x1^2-x2^2)-(y1^2-y2^2);
 a = 2*(x2-x1);
 b = 2*(y2-y1);
 k = -b/a;
 m = t/a;
 a = k^2+1;
 b = 2*k*(m-x1)-2*y1;
 c = (m-x1)^2+y1^2-r1^2;
 if c~=0
ans1y = ((-b+sqrt(b^2-4*a*c))/(2*a));
ans2y = ((-b-sqrt(b^2-4*a*c))/(2*a));
ans1x = m+k*ans1y;
ans2x = m+k*ans2y;
else
    if a==0
        ans1y = 0;
        ans2y = 0;
    else
        ans1y = 0;
        ans2y = -b/a;
    end
ans1x = m+k*ans1y;
ans2x = m+k*ans2y;
end
if abs(ans1x)<1e-6
    ans1x = 0;
end
if abs(ans2x)<1e-6
    ans2x = 0;
end
ans1 = [ans1x,ans1y];
ans2 = [ans2x,ans2y];
end
