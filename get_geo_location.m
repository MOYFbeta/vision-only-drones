function [centerPos] = get_geo_location(img,subimg,show)
%GET_GEO_LOCATION 此处显示有关此函数的摘要
% 加载原图像和子图像
    % 将原图像和子图像转换为灰度图像
    grayImg = rgb2gray(img);
    %imresize(grayImg, 0.5);
    graySubimg = rgb2gray(subimg);

    % 在原图像和子图像中检测SURF特征点
    pointsImg = detectSURFFeatures(grayImg);
    pointsSubimg = detectSURFFeatures(graySubimg);

    % 计算描述子
    [featuresImg, validPointsImg] = extractFeatures(grayImg, pointsImg);
    [featuresSubimg, validPointsSubimg] = extractFeatures(graySubimg, pointsSubimg);

    % 在原图像中查找最佳匹配的子图像
    indexPairs = matchFeatures(featuresSubimg, featuresImg);
    matchedPointsSubimg = validPointsSubimg(indexPairs(:,1)).Location;
    matchedPointsImg = validPointsImg(indexPairs(:,2)).Location;

    % 计算子图像中心点在原图像的坐标
    centerSubimg = [size(subimg, 2)/2, size(subimg, 1)/2];
    
    %[~, index] = pdist2(matchedPointsImg, centerSubimg, 'euclidean', 'Smallest', 1);
    %centerImg = matchedPointsImg(index,:);
    num_matched = size(matchedPointsSubimg);
    num_matched = num_matched(1);
    centerPos = sum(matchedPointsImg - matchedPointsSubimg)./num_matched +centerSubimg;    
    % 显示原图像和匹配结果
%     figure;
      if(show)
          subplot(1,2,2);
          showMatchedFeatures(grayImg, graySubimg, matchedPointsImg, matchedPointsSubimg);
          %plot(centerPos(1), centerPos(2), 'b+', 'MarkerSize', 50);
      end
%     
% 
end
