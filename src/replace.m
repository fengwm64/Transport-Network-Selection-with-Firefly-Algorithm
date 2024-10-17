function new_row = replace(row,lb,ub)
    % 检查是否存在重复
    if length(unique(row)) ~= length(row)
        % 找到重复值的位置
        [~,ia,~]=unique(row);
        pos = setdiff(1:length(row),unique(ia'));
        % 获取未使用的值
        unUsedValue = setdiff(lb:ub, unique(row));
        row(pos) = unUsedValue(randi([1, length(unUsedValue)]));
    else
        new_row = row;
        return;
    end
    % 针对重复多次情况
    if length(unique(row)) ~= length(row)
        row = replace(row,lb,ub);
    end

    new_row = row;
end