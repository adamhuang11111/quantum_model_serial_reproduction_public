% Quantum Model Predictions
load('QPred.mat')
% Mean Data
% load('RawData.mat')

data = Embarrass;
num = data(size(data,1),5) + 1;
parm0 = [0.5;0.5;0.5;0.5;0.5*ones(num,1)];
np = num+4;
lb = -10*ones(np,1);
ub = 10*ones(np,1);
lb(4) = 0;
wgt = .2;    % amount of jitter
options = optimset('Display','none','MaxFunEvals',100000,'MaxIter',1000,'TolX',1e-5);
reps = 10;
for n = 1:reps
    jitter = rand(np,1);
    parm0 = (1-wgt)*parm0 + wgt*jitter;
    [parm, nLL] = fmincon(@(parm) reg_model(parm,data,num),parm0,[],[],[],[],lb,ub,[],options);
end
parm(num+4) = -sum(parm(5:num+3));