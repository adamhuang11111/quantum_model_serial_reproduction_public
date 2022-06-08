function [nLL,P0s] = PerstoryQA6(x, data)
%This model corresponds to QA6 in the paper, where a uniform initial state is
%assumed for each person in the serial reproduction and a changing
%observation noise is assumed at eachs step of the serial reproduction.

%Rotation parameters that characterizes the reading contents
mukappa = x(1); 
mubeta = x(2);  
%mean rating given initial state
mu0 = x(3);
%observation noise
sig = zeros(3,1);
sig(1) = x(4);
sig(2) = x(5);
sig(3) = x(6);
N = size(data, 1);
% Measurement matrix for building the control u gate
M0 = [ 1 0; 0 0];
M1 = [ 0 0; 0 1];
P0s = zeros(N,4);
LL = eps;
for ii = 1:N
    P0s(ii,1) = data(ii,1);
    for j = 1:3
    % An influenced by An-1. Assuming that An knows data(ii,n-1).
        [L,mu] = likelihood_mu_Q(mukappa,mubeta,data(ii,j), ...
            data(ii,j+1),mu0,sig(j),M0,M1);
        P0s(ii,j+1) = mu;
        LL = LL + log(L + eps);
    end
end
%Compute negative loglikelihood for computing BIC.
nLL = -2*LL;