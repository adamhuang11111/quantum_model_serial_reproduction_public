function [L,mu] = likelihood_mu_Q(mukappa,mubeta,data1,data2, ...
    mu0,sig0,M0,M1)
    %Create starting state of opinion of An
    Psimu0 = [sqrt(mu0/7) ; sqrt(1 - (mu0/7))];
    %Mean rating after An is influenced by An-1
    mu = 7*lifted_qw(mukappa, mubeta, data1, Psimu0, M0, M1);
    sig = sig0;
    pd = makedist('Normal','mu',mu,'sigma',sig);
    %truncate the distribution to the appropriate range
    pd = truncate(pd,0,7);
    L = pdf(pd,data2);
end