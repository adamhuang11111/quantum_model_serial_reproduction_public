function [nLL,P0s,P0Hs] = displot_q(x, data)
%This model corresponds to QB6 in the paper, where participants are modeled
%by a mixed quantum state that is a convex combination of two 
%pure states and a uniform observation noise
%is assumed at eachs step of the serial reproduction.

%Rotation parameters that characterizes the reading contents
mukappa = x(1); 
mubeta = x(2);  
%mean rating given initial state
mu0 = zeros(2,1);
mu0(1) = 3.5 + x(5);
mu0(2) = 3.5 - x(6);
%observation noise
sig = x(3);
N = size(data, 1);
%weights of the mixed quantum state
w1 = x(4);
w2 = 1 - w1;
% Measurement matrix for building the control u gate
M0 = [ 1 0; 0 0];
M1 = [ 0 0; 0 1];
P0s = zeros(N,4);
LL = 0;
P0Hs = zeros(N,4,2);
for ii = 1:N
    P0s(ii,1) = data(ii,1);
    for j = 1:3
        mu = zeros(2,1);
        Ls = zeros(2,1);
        %Compute the influence for each pure state in the mixture state
        for k = 1:2
            % An influenced by An-1. Assuming that An knows data(ii,n-1).
            [L1,expmu] = likelihood_mu_Q(mukappa,mubeta,data(ii,j), ...
            data(ii,j+1),mu0(k),sig,M0,M1);
            mu(k) = expmu;
            Ls(k) = L1;
        end
        %record the prediction for starting at each of the two priors
        P0Hs(ii,j+1,1) = mu(1);
        P0Hs(ii,j+1,2) = mu(2);
        %expected value or mean rating given the mixed state at each step
        P0s(ii,j+1) = w1*mu(1) + w2*mu(2);
        %likelihood of the data given model, which is a convex combination of
        %the likelihood from the two truncated normals (sig is the standard
        %deviation of the normal and the mean is the mean given each pure
        %state in the mixed state)
        L = w1*Ls(1) + w2*Ls(2);
        LL = LL + log(L + eps);
    end
end
%Compute negative loglikelihood for computing BIC.
nLL = -2*LL;
end