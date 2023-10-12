function [r1,ans1,ans2] = cal_circle(p1,p2,angle1)
x1 = p1(1);
y1 = p1(2);
x2 = p2(1);
y2 = p2(2);
%已知两点作为弦，圆周角，返回两个圆心坐标以及半径
k1 = (y1-y2)/(x1-x2);
c1 = (x1+x2)/2;
c2 = (y1+y2)/2;
t = c1+c2*k1;
r1 = (sqrt((x1-x2)^2+(y1-y2)^2))/(2*sin(angle1));
a = k1^2+1;
b = 2*k1*(x1-t)-2*y1;
c = (x1-t)^2+y1^2-r1^2;
if c~=0
ans1y = ((-b+sqrt(b^2-4*a*c))/(2*a));
ans2y = ((-b-sqrt(b^2-4*a*c))/(2*a));
ans1x = t-k1*ans1y;
ans2x = t-k1*ans2y;
ans1 = [ans1x,ans1y];
ans2 = [ans2x,ans2y];
else
    if a==0
        ans1y = 0;
        ans2y = 0;
    else
        ans1y = 0;
        ans2y = -b/a;
end
ans1x = t-k1*ans1y;
ans2x = t-k1*ans2y;
if abs(ans1x)<1e-6
    ans1x = 0;
end
if abs(ans2x)<1e-6
    ans2x = 0;
end
ans1 = [ans1x,ans1y];
ans2 = [ans2x,ans2y];
end