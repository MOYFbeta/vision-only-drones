function [nav_points] = gen_nav_points(plan,length)
%GEN_NAV_POINTS 此处显示有关此函数的摘要
%   此处显示详细说明
tq = linspace(1, length,length);
x = plan(:,1);
y = plan(:,2);
xq = interp1(plan(:,3), x, tq);
yq = interp1(plan(:,3), y, tq);
nav_points = [xq', yq'];
end

