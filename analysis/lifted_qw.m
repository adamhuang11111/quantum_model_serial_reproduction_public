function Pred = lifted_qw(kappa,beta,data,psi, M0, M1)
%Program for the lifted quantum walk that models the influence of An-1 on
%An.
    P0s = data/7;
    %The control part of the lifted wuantum walk is given by the emotional
    %rating of the received narrative.
    psiA1 = [sqrt(P0s); sqrt(1-P0s)];
    %Step1: Form a joint system
    psi1 = kron(psiA1, psi);
    rho1 = psi1 * psi1';
    %compute the rotation angle from the comprehension parameters that are
    %linearly related to it
    theta0 = kappa * P0s + beta;
    %build the rotation matrix
    V20 = unitary2(theta0, 0);
    %create the control unitary operator as shown in equation (7) of the
    %paper.
    if P0s > .5
        U2 = kron(M0, V20) + kron(M1, eye(2));
    else
        U2 = kron(M0, eye(2)) + kron(M1, V20);
    end
    %Step2: Apply the unitary
    rho2 = U2 * rho1 * U2';
    %Step3: Get prediction by taking partial trace
    rhoA2 = PartialTrace(rho2,1); % partial trace over the first subsystem
    Pred = rhoA2(1, 1);
end