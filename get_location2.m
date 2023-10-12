function [theta,rho] = get_location2(theta1,theta2,p0,p1,p2,formation)
%   根据理想队形、观测到的角度计算当前位置估计
    alpha1 = formation(p1,1);
    alpha2 = formation(p2,1);
    type1=judgetype(p0,p1);
    type2=judgetype(p0,p2);
    R = 100;
    if type1==1&&type2==1
         t1 = theta1+alpha1;
         t2 = theta2+alpha2;
         up = (sin(theta2).*sin(t1) - sin(theta1).*sin(t2));
         down = (sin(theta2).*cos(t1) - sin(theta1).*cos(t2));
         index = ((p0-2)*40-rad2deg(atan2(up,down)))/180;
         if abs(index)<1
             index =0;
         else
             index = round(index);
         end
         theta = atan2(up,down)+index*pi;
         rho = R.*sin(t1-theta)./sin(theta1);
    elseif type1==2&&type2==2
         t1 = theta1-alpha1;
         t2 = theta2-alpha2;
         up = (sin(theta2).*sin(t1) - sin(theta1).*sin(t2));
         down = (sin(theta1).*cos(t2) - sin(theta2).*cos(t1));
         index = ((p0-2)*40-rad2deg(atan2(up,down)))/180;
         if abs(index)<1
             index =0;
         else
             index = round(index);
         end
         theta = atan2(up,down)+index*pi;
         rho = R.*sin(t1+theta)./sin(theta1);        
    elseif type1==1&&type2==2
         t1 = theta1+alpha1;
         t2 = theta2-alpha2;
         up = (sin(theta2).*sin(t1) - sin(theta1).*sin(t2));
         down = (sin(theta2).*cos(t1) + sin(theta1).*cos(t2));
         index = ((p0-2)*40-rad2deg(atan2(up,down)))/180;
         if abs(index)<1
             index =0;
         else
             index = round(index);
         end
         theta = atan2(up,down)+index*pi;
         rho = R.*sin(t1-theta)./sin(theta1);        
    else
         t1 = theta1-alpha1;
         t2 = theta2+alpha2;
         up = (sin(theta2).*sin(t1) - sin(theta1).*sin(t2));
         down = (-sin(theta2).*cos(t1) - sin(theta1).*cos(t2));
         index = ((p0-2)*40-rad2deg(atan2(up,down)))/180;
         if abs(index)<1
             index =0;
         else
             index = round(index);
         end
         theta = atan2(up,down)+index*pi;
         rho = R.*sin(t1+theta)./sin(theta1);         
    end
       if rho<0
           rho = -rho;
           index = ((p0-2)*40-rad2deg(atan2(up,down)))/180;
           index = round(index);
           theta = atan2(up,down)+index*pi;
       end
    %disp("("+rho+","+rad2deg(theta)+"°)");
end

