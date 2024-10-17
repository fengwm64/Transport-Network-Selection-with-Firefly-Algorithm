function x_t1 = MoveFireflies(x_t,I,beta,alpha,m,lb,ub)
% 萤火虫移动
% ======================================================================= %
    x_t1 = x_t;
    for i=1:length(x_t)
        for j=1:length(x_t)
            % 如果个体j比i更加亮，则i被j吸引
            if I(j) > I(i)
                r = rand(1,length(x_t1(i,:)));
                x_t1(i,:) = x_t1(i,:) + ...
                    m.*r.*(x_t(end,:)-x_t(i,:)) +...
                    beta(i,j).*(x_t(j,:) - x_t1(i,:)) + ...
                    alpha(i).*(r-0.5);
            end
        end
    end
    % 进行取整操作
    x_t1 = round(x_t1);
    % 相同的备选点替换
    for i = 1:size(x_t1,1)
        x_t1(i,:) = replace(x_t1(i,:),lb,ub);
    end
    % 应用边界缓冲域
    for i = 1:size(x_t1,2)
        x_t1(x_t1(:, i) < lb, i) = lb;  % 将小于下限的值设为下限
        x_t1(x_t1(:, i) > ub, i) = ub;  % 将大于上限的值设为上限
    end
end