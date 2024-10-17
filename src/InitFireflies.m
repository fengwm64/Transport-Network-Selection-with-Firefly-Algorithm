function Fireflies = InitFireflies(n,d,lb,ub)
% 随机生成萤火虫个体的初始位置
% ======================================================================= %
    arrage = lb:ub;
    
    % 选出哪些配送中心备选点被选中
    selBackupPoints = zeros(n,d);
    for i=1:n
        % 生成随机排列的索引
        randIdx = randperm(length(arrage));
        % 更新原始矩阵，将打乱后的行重新放回去
        selBackupPoints(i, :) = arrage(randIdx(1:d));
    end
    
    Fireflies = selBackupPoints;
end