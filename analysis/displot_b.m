function [nLL, P0s,Psigs,P0Hs] = displot_b(x, data)
%This model corresponds to BSB5 in the paper, where participants in the
%serial reproduction are assumed to come from a mixture of two Gaussian
%distributions, and observation noise is assumed to be the same
%at eachs step of the serial reproduction.

%noise of the prior distriution
sig0 = x(1); 
sig1 = x(2);
%observation noise
sig2 = sig1;
sig3 = sig2;
%mean of the two Gaussian distributions in the mixture prior
mu0 = zeros(2,1);
mu0(1) = 3.5 + x(4);
mu0(2) = 3.5 - x(5);
%weights between the two priors
w1 = x(3);
w2 = 1 - w1;
N = size(data, 1);
P0s = zeros(N,4);
Psigs = zeros(3,1);
P0Hs = zeros(N,4,2);
lambdas = zeros(3,1);
%Lambdas from the Bayesian model for computing posterior.
lambdas(1) = sig0^2/(sig1^2 + sig0^2);
lambdas(2) = sig0^2/(sig2^2 + sig0^2);
lambdas(3) = sig0^2/(sig3^2 + sig0^2);
%Noise at each step of the serial reproduction
Psigs(1) = sqrt((1 + lambdas(1))* sig1^2);
Psigs(2) = sqrt((1 + lambdas(2))* sig2^2);
Psigs(3) = sqrt((1 + lambdas(3))* sig3^2);
LL = 0;
for ii = 1:N
    P0s(ii,1) = data(ii,1);
    for j = 1:3
        mu = zeros(2,1);
        Ls = zeros(2,1);
        for k = 1:2
            [L1,expmu] = likelihood_mu_BS(lambdas(j),Psigs(j),mu0(k),data(ii,j),data(ii,j+1));
            %mean and likelihood of data given model starting at each of the two Gaussian
            %priors.
            mu(k) = expmu;
            Ls(k) = L1;
        end
        %record the prediction for starting at each of the two priors
        P0Hs(ii,j+1,1) = mu(1);
        P0Hs(ii,j+1,2) = mu(2);
        %expected value or mean of the mixture distribution at each step
        P0s(ii,j+1) = w1*mu(1) + w2*mu(2);
        %likelihood of the data given model, which is a convex combination of
        %the likelihood from the two truncated normals.
        L = w1*Ls(1) + w2*Ls(2);
        LL = LL + log(L + eps);
    end
end
%Compute negative loglikelihood for computing BIC.
nLL = -2*LL;
end