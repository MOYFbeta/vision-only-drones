function [subimg] = getsubimage(img,pos)
    pos = round(pos);
    subimg = zeros(200, 200, size(img, 3),'uint8');
    xw = size(img, 1);
    yw = size(img, 2);
    % 左上角
    x1 = max(pos(2)-100, 2);
    y1 = max(pos(1)-100, 1);
    
    % 右下角
    x2 = min(pos(2)+99, xw);
    y2 = min(pos(1)+99, yw);
    
    subimg(101 -pos(2)+x1:101 + x2-pos(2), 101 - pos(1)+y1:101 + y2-pos(1) ,:) = img(x1:x2,y1:y2,:);
    
    noise_density = 0.05; % 噪声密度
    filter_size = 5; % 滤波器大小
    
    subimg = imnoise(subimg, 'salt & pepper', noise_density);
    subimg = imfilter(subimg, fspecial('average', filter_size));
end

