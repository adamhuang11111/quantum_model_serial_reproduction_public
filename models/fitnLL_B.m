%The program is used to fit the more complex models with a mixture prior or
%initial state. For the four simpler models see fitnLL_A. Data files to fit
%can be found in the data/ folder.

%Choose the folder of data to fit
folder = '../data/embarass/';
emotion = "../data/embarass_";
paramNumlist = [5,6,7,8];
dir_list = dir("../data/embarass");
dir_len = size(dir_list,1);
nLLS = zeros(dir_len,1);
BICS = zeros(dir_len,1);
reps = 3;
param_pen = zeros(dir_len,1);

options = optimoptions('particleswarm','SwarmSize',320,'UseParallel',true,'Display','iter','MaxIter',2000);

%For each model type
for jj = 2:2
    paramNum = paramNumlist(jj);
    nLLS = zeros(dir_len,1);
    BICS = zeros(dir_len,1);
    ParmS = zeros(dir_len,paramNum);
    param_pen = zeros(dir_len,1);
    %For each orginal narrative
    for i = 1:dir_len
        if contains(dir_list(i).name,"train")
            %For some reasons, we split the dataset into training and
            %testing, but for the BIC fitting, we fit over the entire
            %dataset, so please ignore the training and testing here, as we
            %combine them together by the below code. 
            dataTrain = csvread(strcat(folder,dir_list(i).name));
            dataTest = csvread(strcat(folder,strcat("test", extractAfter(dir_list(i).name,5))));
            datasize = size(dataTest,1) + size(dataTrain,1);
            data = zeros(datasize,size(dataTrain,2));
            data(1:size(dataTrain,1),:) = dataTrain;
            data(size(dataTrain,1)+1:datasize,:) = dataTest;
            %Compute the BIC parameter penalties (four times since each sequence has four datapoints).
            param_pen(i) = paramNum*log(4*datasize);
            if paramNum == 5
                fun = @(x)PerstoryBSB5(x, data);
                lb = [eps eps eps eps eps]; % lower bounds
                ub = [7 7 1 3.5-eps 3.5-eps]; % upper bounds
                newnLL = strcat(emotion,"nLLS_BSB5.mat");
                newParm = strcat(emotion,"ParmS_BSB5.mat");
                newBIC = strcat(emotion,"BIC_BSB5.mat");
            elseif paramNum == 7
                fun = @(x)PerstoryBSAB7(x, data);
                lb = [eps eps eps eps eps eps eps]; % lower bounds
                ub = [7 7 7 7 1 3.5-eps 3.5-eps]; % upper bounds
                newnLL = strcat(emotion,"nLLS_BSAB7.mat");
                newParm = strcat(emotion,"ParmS_BSAB7.mat");
                newBIC = strcat(emotion,"BIC_BSAB7.mat");
            elseif paramNum == 6
                fun = @(x)PerstoryQB6(x, data);
                lb = [-5 -5 eps eps eps eps]; % lower bounds
                ub = [5 5 7 1 3.5-eps 3.5-eps]; % upper bounds
                newnLL = strcat(emotion,"nLLS_QB6.mat");
                newParm = strcat(emotion,"ParmS_QB6.mat");
                newBIC = strcat(emotion,"BIC_QB6.mat");
            else
                fun = @(x)PerstoryQAB8(x, data);
                lb = [-5 -5 eps eps eps eps eps eps]; % lower bounds
                ub = [5 5 7 7 7 1 3.5-eps 3.5-eps]; % upper bounds
                newnLL = strcat(emotion,"nLLS_QAB8.mat");
                newParm = strcat(emotion,"ParmS_QAB8.mat");
                newBIC = strcat(emotion,"BIC_QAB8.mat");
            end
    %         Pick the one of the three repetitions with lowest training accuracy
            nLLV = zeros(reps,1);
            ParmM = zeros(reps,paramNum);
            for n = 1:reps
                [parm, nLL] = particleswarm(fun,paramNum,lb,ub,options);
                nLLV(n) =  nLL;
                ParmM(n,:) =  parm;
                disp(nLL)
            end
            [nLL, Ind] = min(nLLV);
            parm = ParmM(Ind,:);
            nLLS(i) = nLL;
            ParmS(i,:) = parm;
            BICS(i) = nLL + param_pen(i);
            disp(dir_list(i).name)
        end
    end
    save(newnLL,"nLLS");
    save(newParm,"ParmS");
    save(newBIC,"BICS");
end
