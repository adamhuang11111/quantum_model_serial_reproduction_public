function [nLL, P0s] = PerstoryBSA5(x, data)
%This model corresponds to BSA5 in the paper, where a uniform prior is
%assumed for each person in the serial reproduction and a changing
%observation noise is assumed at eachs step of the serial reproduction.

%noise of the prior distriution
sig0 = x(1); 
%observation noise
sig1 = x(2);  
sig2 = x(4);
sig3 = x(5);
%mean of the prior distribution
mu0 = x(3);
N = size(data, 1);
P0s = zeros(N,4);
Psigs = zeros(3,1);
%Lambdas from the Bayesian model for computing posterior.
lambdas = zeros(3,1);
lambdas(1) = sig0^2/(sig1^2 + sig0^2);
lambdas(2) = sig0^2/(sig2^2 + sig0^2);
lambdas(3) = sig0^2/(sig3^2 + sig0^2);
%Noise at each step of the serial reproduction
Psigs(1) = sqrt((1 + lambdas(1))* sig1^2);
Psigs(2) = sqrt((1 + lambdas(2))* sig2^2);
Psigs(3) = sqrt((1 + lambdas(3))* sig3^2);
LL = eps;
for ii = 1:N
    P0s(ii,1) = data(ii,1);
    for j = 1:3
        [L,mu] = likelihood_mu_BS(lambdas(j),Psigs(j),mu0,data(ii,j),data(ii,j+1));
        P0s(ii,j+1) = mu;
        LL = LL + log(L + eps);
    end
end
%Compute negative loglikelihood for computing BIC.
nLL = -2 * LL;
end