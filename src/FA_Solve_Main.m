%% 导入数据
clc
clear
close all

% 设置导入选项并导入数据
opts = delimitedTextImportOptions("NumVariables", 8);

% 指定范围和分隔符
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% 指定列名称和类型
opts.VariableNames = ["No", "Var2", "Var3", "Pop", "x", "y", "streetNo", "Area"];
opts.SelectedVariableNames = ["No", "Pop", "x", "y", "streetNo", "Area"];
opts.VariableTypes = ["double", "string", "string", "double", "double", "double", "double", "categorical"];

% 指定文件级属性
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 指定变量属性
opts = setvaropts(opts, ["Var2", "Var3"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var2", "Var3", "Area"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "streetNo", "TrimNonNumeric", true);
opts = setvaropts(opts, "streetNo", "ThousandsSeparator", ",");

% 导入数据
DataSet = readtable(".\data\长春市9个区主要小区相关数据.csv", opts);

%% 分类
% 有几类
aeraType = unique(DataSet.Area);
% 每一类有多少小区
aeraNum = zeros(length(aeraType),1);
for i = 1:length(aeraType)
    aeraNum(i) = numel(DataSet.No(DataSet.Area == aeraType(i)));
end
for i = 1:length(aeraType)
    fprintf("%s\t\t%d\n",aeraType(i),aeraNum(i))
end

%% 获取小区数据（需求点）
% 以长春新区(高新)为例
Data = DataSet(DataSet.Area == '长春新区(高新)',:);

%% 获取备选快递配送网点（配送点）
[backupPoints,BestCluNum] = GetBackupPoints(Data);

%% 设置参数
% ------------------设置目标数学模型 ------------------
model = struct();
model.d = BestCluNum;                % 问题的维度（个体/可行解的维度）
model.lb = 1;                        % 自变量下界（备选配送中心最小编号）
model.ub = length(backupPoints);     % 自变量上界（备选配送中心最大编号）
model.f = @objFun;                   % 目标函数
model.target = 'MIN';                % 目标

% ------------------设置萤火虫算法参数 ------------------
FA_param = struct();

% 基本萤火虫参数
FA_param.MaxG = 500;    % 最大进化代数
FA_param.n = 80;         % 种群规模
FA_param.gamma = 1;      % 光吸引系数γ

% 基于寻优偏差度的自适应随机步长
FA_param.alpha_min = 0.2;    % 最小步长因子α
FA_param.alpha_max = 0.9;   % 最大步长因子α

% 迭代自适应的最小吸引度
FA_param.beta_0 = 1.0;       % 最大吸引度β_0
FA_param.beta_minMax = 0.2;  % 迭代自适应的最小吸引度β_min最大值
FA_param.p = 0.9;            % 扩展常数

% 全局导向性移动机制
FA_param.m_max = 0.30;
FA_param.m_min = 0.25;
% --------------------------------------------------------

%% 萤火虫算法求解
best = FA_Solve(backupPoints,Data,FA_param,model);

%% 网格调参
tab = zeros(1000,5);
n = 1;
for alpha_min = 0.1:0.05:0.2
    for alpha_max = 0.5:0.1:1
        for m_min = 0.1:0.05:0.25
            for m_max = 0.3:0.1:0.5
                tmp=zeros(10,1);
                FA_param.alpha_min=alpha_min;
                FA_param.alpha_max=alpha_max;
                FA_param.m_min=m_min;
                FA_param.m_max=m_max;
                for time = 1:10
                    tmp(time)=FA_Solve(backupPoints,Data,FA_param,model);
                end
                tab(n,1) =alpha_min;
                tab(n,2) =alpha_max;
                tab(n,3) =m_min;
                tab(n,4)=m_max;
                tab(n,5) = mean(tmp(:));
                fprintf("%f %f %f %f %f",alpha_min,alpha_max,m_min,m_max,tab(n,5));
                n=n+1;
            end
        end
    end
end

disp(min(tab(:,5)))