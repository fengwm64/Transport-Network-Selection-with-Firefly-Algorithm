function [Fireflies,bright] = Brightness(f,target,Fireflies,backupPoints,Data)
% 计算每个萤火虫光源处的亮度(r = 0)
% ======================================================================= %
    fval = f(Fireflies,backupPoints,Data);
    bright = fval;

    % 极小型转极大型
    if target == "min" || target == "Min" || target == "MIN"
        bright = 1./fval;
    end
    
    % 将萤火虫个体按亮度进行排序
    [sorted_bright, sorted_idx] = sort(bright,'ascend');
    Fireflies = Fireflies(sorted_idx,:);
    bright = sorted_bright;
end