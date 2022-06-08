%The program is used to fit the simpler models with a uniform prior (initial state). 
%For the four models with a mixture prior see fitnLL_B. Data files to fit
%can be found in the data/ folder.

%Choose the folder of data to fit
folder = '../data/disgust/';
emotion = "../data/disgust_";
paramNumlist = [3,4,5,6];
dir_list = dir("../data/disgust");
dir_len = size(dir_list,1);
reps = 3;
options = optimoptions('particleswarm','SwarmSize',320,'UseParallel',true,'Display','iter','MaxIter',2000);

%For each model type
for jj = 2:2
    paramNum = paramNumlist(jj);
    disp(paramNum)
    nLLS = zeros(dir_len,1);
    ParmS = zeros(dir_len,paramNum);
    BICS = zeros(dir_len,1);
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
            if paramNum == 3
                fun = @(x)PerstoryBS3(x, data);
                lb = [eps eps eps]; % lower bounds
                ub = [7 7 7]; % upper bounds
                newnLL = strcat(emotion,"nLLS_BS3.mat");
                newParm = strcat(emotion,"ParmS_BS3.mat");
                newBIC = strcat(emotion,"BIC_BS3.mat");
            elseif paramNum == 5
                fun = @(x)PerstoryBSA5(x, data);
                lb = [eps eps eps eps eps]; % lower bounds
                ub = [7 7 7 7 7]; % upper bounds
                newnLL = strcat(emotion,"nLLS_BSA5.mat");
                newParm = strcat(emotion,"ParmS_BSA5.mat");
                newBIC = strcat(emotion,"BIC_BSA5.mat");
            elseif paramNum == 4
                fun = @(x)PerstoryQ4(x, data);
                lb = [-5 -5 eps eps]; % lower bounds
                ub = [5 5 7 7]; % upper bounds
                newnLL = strcat(emotion,"nLLS_Q4.mat");
                newParm = strcat(emotion,"ParmS_Q4.mat");
                newBIC = strcat(emotion,"BIC_Q4.mat");
            else
                fun = @(x)PerstoryQA6(x, data);
                lb = [-5 -5 eps eps eps eps]; % lower bounds
                ub = [5 5 7 7 7 7]; % upper bounds
                newnLL = strcat(emotion,"nLLS_QA6.mat");
                newParm = strcat(emotion,"ParmS_QA6.mat");
                newBIC = strcat(emotion,"BIC_QA6.mat");
            end
    %       Pick the one with lowest training accuracy
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