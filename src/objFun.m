function fval = objFun(x, backupPoints, Data)
% 目标函数
% ======================================================================= %
    needPoints = [Data.x,Data.y];
    fval = zeros(size(x,1),1);
    dis = zeros(size(needPoints,1),size(x,2));
    % 遍历群体的每一行
    for i = 1:size(x,1)
        % 对于每一个需求点
        for j = 1:size(needPoints,1)
            % 计算每一个需求点到各个配送中心的距离
            for k = 1:size(x,2)
                dis(j,k) = norm(needPoints(j,:)-backupPoints(x(i,k),:),2);
            end
        end
        % 找到每一个需求点到配送中心的最短距离
        dis = min(dis,[],2);
        % 目标函数值 = 最短距离*需求量
        fval(i) = sum(dis.*Data.Pop/100);
    end
end