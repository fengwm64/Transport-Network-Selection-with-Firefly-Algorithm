function beta = Attraction(r, gamma, beta_0,beta_min)
% 计算个体之间吸引度
% ======================================================================= %
    beta = (beta_0 - beta_min).*exp(-gamma.*r.^2) + beta_min;
end