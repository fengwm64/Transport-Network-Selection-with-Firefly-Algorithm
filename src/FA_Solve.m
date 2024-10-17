function [best] = FA_Solve(backupPoints,Data,FA_param,model)
% 萤火虫优化算法解决物流运输网点选址问题
%% 设置参数

% 设置模型参数
d = model.d;         % 问题的维度（个体/可行解的维度）
lb = model.lb;       % 自变量下界（备选配送中心最小编号）
ub = model.ub;       % 自变量上界（备选配送中心最大编号）
f = model.f;         % 目标函数
target = model.target; % 目标

% ------------------设置萤火虫算法参数 ------------------
% 基本萤火虫参数
MaxG = FA_param.MaxG;         % 最大进化代数
n = FA_param.n;              % 种群规模
gamma = FA_param.gamma;           % 光吸引系数γ

% 基于寻优偏差度的自适应随机步长
alpha_min = FA_param.alpha_min;        % 最小步长因子α
alpha_max = FA_param.alpha_max;        % 最大步长因子α

% 迭代自适应的最小吸引度
beta_0 = FA_param.beta_0;        % 最大吸引度β_0
beta_minMax = FA_param.beta_minMax;   % 迭代自适应的最小吸引度β_min最大值
p = FA_param.p;             % 扩展常数

% 全局导向性移动机制
m_max = FA_param.m_max;
m_min = FA_param.m_min;
% --------------------------------------------------------

%% 算法主循环
GenBestTab = cell(MaxG,2);

% Step1：随机生成萤火虫个体的初始位置
Fireflies = InitFireflies(n,d,lb,ub);

for gen = 1:MaxG    
    % Step2：计算萤火虫个体的亮度
    [Fireflies,bright] = Brightness(f,target,Fireflies,backupPoints,Data);
   
    % Step3：计算两只萤火虫之间的距离
    distance = Distance(Fireflies);

    % Step4：计算个体之间吸引度
    beta_min = newBetaMin(beta_minMax,p,gen,MaxG);
    attraction = Attraction(distance, gamma, beta_0,beta_min);

    % Step5：萤火虫移动
    alpha = newAlpha(alpha_min,alpha_max,Fireflies,Fireflies(1,:),Fireflies(end,:));
    m = new_m(m_min,m_max,gen,MaxG);
    new_Fireflies = MoveFireflies(Fireflies,bright,attraction,alpha,m,lb,ub);

    % 输出该代萤火虫最佳个体信息
    [bright_GMAX, idx_GMAX] = max(bright);
    % disp(num2str([gen,bright_GMAX]));
    GenBestTab{gen,1} = Fireflies(idx_GMAX,:);
    GenBestTab{gen,2} = bright_GMAX;

    Fireflies = new_Fireflies;
end

[bright_Best, idx_Best] = max(cell2mat(GenBestTab(:,2)));
disp("----------------------------------------------------------------")
disp("找到最优解：")
disp(1./bright_Best)
% best = cell2mat(GenBestTab(idx_Best,2));
best = 1./bright_Best;
%% 绘制收敛曲线图
figure
subplot(1,2,1)
plot(1./cell2mat(GenBestTab(:,2)),'LineStyle','-','LineWidth',1.8)
xlabel("迭代次数")
ylabel("目标函数值")
title("收敛曲线图")
set(gcf,'Color',[1 1 1])
set(gca, 'Box', 'on', ...                                % 边框
         'LineWidth', 1.4,...                             % 线宽
         'XGrid', 'off', 'YGrid', 'on', ...               % 网格
         'XMinorTick', 'off', 'YMinorTick', 'off', ...
         'GridLineStyle', '--')
ax=gca; 
ax.XColor=[.3,.3,.3];
ax.YColor=[.3,.3,.3];
ax.FontWeight='bold';
ax.FontName='YaHei';
ax.FontSize=10;

%% 绘制最终配送网点图 
subplot(1,2,2)

bestResult = cell2mat(GenBestTab(idx_Best,1));

% 绘制客户坐标点
scatter(Data.x, Data.y, ...
    Data.Pop/50, ...
    'MarkerFaceColor', 'g', ...
    'MarkerEdgeColor', 'k', ...
    'LineWidth', 1);
hold on

% 绘制配送中心
scatter(backupPoints(unique(bestResult), 1), ...
        backupPoints(unique(bestResult), 2), ...
        80, 'magenta','x', ...
        'MarkerEdgeColor', 'flat', ...
        'LineWidth', 2);

% for i = 1:size(Data,1)
%     color = [rand rand rand];
%     line = [backupPoints(bestResult(i),:);[Data.x(i),Data.y(i)]];
%     plot(line(:,1),line(:,2),'--','LineWidth',1.5);
% end

xlabel('x坐标');
ylabel('y坐标');
legend("需求点（小区）","配送网点")
title("快递运输网点选址方案图")

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
end

%% --------------------------- 所有函数实现 ----------------------------
% 迭代自适应的最小吸引度（改进1）
function new_beta_min = newBetaMin(beta_minMax,p,t,MaxG)
    new_beta_min = beta_minMax.*exp(-t^2/(p.*MaxG));
end

% 基于寻优偏差度的自适应随机步长机制（改进2）
function new_alpha = newAlpha(alpha_min,alpha_max,x,x_worst,x_best)
    % 生成正态分布的随机数
    mu = 0.5;      % 均值
    sigma = 0.1;   % 标准差
    Grand = normrnd(mu, sigma, size(x, 1), 1);
    x(x < 0) = 0;
    x(x > 1) = 1;

    new_alpha = zeros(size(x,1),1);
    L_max = norm(x_worst-x_best,2);

    for i = 1:size(x,1)
        new_alpha(i) = alpha_min + (alpha_max-alpha_min).*((norm(x(i,:)-x_best,2))/(L_max)).*Grand(i);
    end
end

% 全局导向性移动机制（改进3）
function m = new_m(m_min,m_max,t,MaxG)
    m = m_max - ((m_max-m_min)/sum(1:t)).*(log(t^2)/log(MaxG));
end

