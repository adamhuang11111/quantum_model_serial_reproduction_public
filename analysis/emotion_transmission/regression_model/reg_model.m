function [nLL, pred] = reg_model(parm, data, num)
    s = parm(1);
    beta = parm(2);
    alpha = ones(num,1);
    d = parm(3);
    sigma = parm(4);
    alpha(1:num-1) = parm(5:num+3);
    alpha(num) = - sum(parm(5:num+3));
    nLL = 0;
    pred = zeros(size(data,1),4);
    for i = 1:size(data,1)
        for j = 0:3
            y = s*j + alpha(data(i,5)+1)*exp(d*j) + beta;
            pred(i,j+1) = y;
            LL = log(eps + normpdf(data(i,j+1)+1,y,sigma));
            nLL = nLL - LL;
        end
    end
end