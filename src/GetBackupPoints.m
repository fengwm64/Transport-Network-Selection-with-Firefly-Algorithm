function [backupPoints,BestCluNum] = GetBackupPoints(Data)
% 获取备选的快递配送网点 
%% 小区信息数据可视化
    
    % 数据可视化
    figure
    scatter(Data.x, Data.y, Data.Pop/45, ...
        'MarkerFaceColor', [128 159 186]/255, ...
        'MarkerEdgeColor', 'k', ...
        'LineWidth', 1.2);
    xlabel("x坐标")
    ylabel("y坐标")
    title("小区位置")
    legend("小区")
    % 坐标区域修饰
    ax=gca;
    ax.LineWidth=1.4;
    ax.Box='on';
    ax.TickDir='in';
    ax.XMinorTick='on';
    ax.YMinorTick='on';
    ax.XGrid='on';
    ax.YGrid='on';
    ax.GridLineStyle='--';
    ax.XColor=[.3,.3,.3];
    ax.YColor=[.3,.3,.3];
    ax.FontWeight='bold';
    ax.FontName='YaHei';
    ax.FontSize=10;
    
%% 使用聚类确定备选配送网点，使用肘部图确定最优簇数
    % 最大可能的簇数
    maxCluNum = floor(85/5);
    
    % 簇内平均畸变程度SSE
    SSE = zeros(maxCluNum,1);
    
    % 开始尝试在不同簇数下聚类
    for cluNum = 1:maxCluNum
        [~,center_km] = kmeans([Data.x,Data.y], cluNum, 'Start', 'plus');
        SSE(cluNum) = getSSE([Data.x,Data.y],center_km);
    end
    
    % 绘制SSE随簇数增加变化的折线图
    figure
    plot(SSE,'LineStyle','-','LineWidth',1.5,'Marker','o')
    xlabel("聚类簇数")
    ylabel("SSE")
    xticks(1:1:maxCluNum);
    % 一些坐标区的微调美化
    set(gcf,'Color',[1 1 1])
    set(gca, 'Box', 'off', ...                                % 边框
        'LineWidth', 1.4,...                             % 线宽
        'XGrid', 'off', 'YGrid', 'on', ...               % 网格
        'TickDir', 'out', 'TickLength', [.01 .01], ...   % 刻度
        'XMinorTick', 'off', 'YMinorTick', 'off', ...
        'GridLineStyle', '--')
    ax=gca;
    ax.XColor=[.3,.3,.3];
    ax.YColor=[.3,.3,.3];
    ax.FontWeight='bold';
    ax.FontName='YaHei';
    ax.FontSize=10;
    xlim([1 maxCluNum])
    ylim([0 max(SSE)+100])
    chart = gca().Children;
    datatip(chart,11,308.694,"Location","northeast");
    chart.DataTipTemplate.DataTipRows(1).Label="CluNum";
    chart.DataTipTemplate.DataTipRows(2).Label="SSE";
    
    % 根据上图选择簇数为11
    BestCluNum = 11;
    [idx_km,center_km] = kmeans([Data.x,Data.y], BestCluNum, 'Start', 'plus');
    
    %% 可视化最优聚类结果
    figure
    % 使用不同颜色绘制不同簇的数据点
    % colors = ['r', 'g', 'b', 'c', 'm', 'y', 'k', 'w'];
    for i = 1:BestCluNum
        cluster_points = [Data.x(idx_km == i), Data.y(idx_km == i)];
        point_sizes = Data.Pop(idx_km == i) / 50;
        scatter(cluster_points(:, 1), cluster_points(:, 2), ...
            point_sizes, ...
            'filled', ...
            'MarkerEdgeColor', 'k', ...
            'LineWidth', 1);
        hold on;
    end
    
    % 绘制簇中心
    scatter(center_km(:, 1), center_km(:, 2), 100, 'k','x', ...
        'MarkerEdgeColor', 'flat', ...
        'LineWidth', 2);
    hold off;
    
    title('最优k-means小区分类结果');
    xlabel('X');
    ylabel('Y');
    legend('Cluster 1', 'Cluster 2', 'Cluster 3', 'Cluster 4', 'Cluster 5', ...
        'Cluster 6', 'Cluster 7', 'Cluster 8', 'Cluster 10', 'Cluster 11', 'Centroids');
    % 坐标区域修饰
    ax=gca;
    ax.LineWidth=1.4;
    ax.Box='on';
    ax.TickDir='in';
    ax.XMinorTick='on';
    ax.YMinorTick='on';
    ax.XGrid='on';
    ax.YGrid='on';
    ax.GridLineStyle='--';
    ax.XColor=[.3,.3,.3];
    ax.YColor=[.3,.3,.3];
    ax.FontWeight='bold';
    ax.FontName='YaHei';
    ax.FontSize=10;
    legend("Position", [0.68596,0.14294,0.19643,0.22976])
    
    %% 为了可以创造更加多的备选网点，考虑最优簇数上下浮
    up = 5;
    down = 5;
    
    % 计算预分配 backupPoints 数组的大小
    numClusters = BestCluNum - down : BestCluNum + up;
    totalCenters = sum(arrayfun(@(cluNum) size(kmeans([Data.x, Data.y], cluNum, 'Start', 'plus'), 1), numClusters));
    backupPoints = zeros(totalCenters, 2);
    
    n = 1;
    
    for cluNum = BestCluNum-down:BestCluNum+up
        [~, center_km] = kmeans([Data.x, Data.y], cluNum, 'Start', 'plus');
    
        % 将 center_km 存储在 backupPoints 中
        backupPoints(n:n+size(center_km, 1)-1, :) = center_km;
        n = n + size(center_km, 1);
    end
    
    % 去除多余空间
    backupPoints(n:end, :) = [];
    
    % 去除重复点
    backupPoints = unique(backupPoints, 'rows');
    
    %% 可视化备选配送网点
    figure
    scatter(Data.x, Data.y, Data.Pop/30, ...
        'MarkerFaceColor', [128 159 186]/255, ...
        'MarkerEdgeColor', 'k', ...
        'LineWidth', 1.2);
    hold on
    % 绘制簇中心
    scatter(backupPoints(:, 1), backupPoints(:, 2), 85,'x', ...
        'MarkerFaceColor',[0.0352941176470588  0.0470588235294118  0.0745098039215686],...
        'MarkerEdgeColor', 'flat', ...
        'LineWidth', 2);
    xlabel('x');
    ylabel('y');
    legend("小区","备选配送网点")
    % 坐标区域修饰
    ax=gca;
    ax.LineWidth=1.4;
    ax.Box='on';
    ax.TickDir='in';
    ax.XMinorTick='on';
    ax.YMinorTick='on';
    ax.XGrid='on';
    ax.YGrid='on';
    ax.GridLineStyle='--';
    ax.XColor=[.3,.3,.3];
    ax.YColor=[.3,.3,.3];
    ax.FontWeight='bold';
    ax.FontName='YaHei';
    ax.FontSize=12;
end

function SSE = getSSE(Data, center)
    D = pdist2(Data, center);   % 计算每个数据点到每个簇中心的距离
    min_D = min(D, [], 2);      % 每个数据点到最近的簇中心的距离
    SSE = sum(min_D.^2);        % 平方误差和
end