function r = Distance(Fireflies)
% 计算两只萤火虫之间的距离
% ======================================================================= %
    r= zeros(size(Fireflies,1));
    
    for i = 1:size(Fireflies,1)
        for j = 1:size(Fireflies,1)
            r(i,j) = norm(Fireflies(i, :) - Fireflies(j, :),2);
        end
    end
end
