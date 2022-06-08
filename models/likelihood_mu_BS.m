function [L,mu] = likelihood_mu_BS(lambda,sig,mu0,data1,data2)
%program for computing the likelihood of data given the model.
    mu = lambda*data1 + (1-lambda)*mu0;
    pd = makedist('Normal','mu',mu,'sigma',sig);
    %truncate the normal distribution to the scale of ratings
    pd = truncate(pd,0,7);
    L = pdf(pd,data2);
end