emotions = ["happy", "sad", "risk", "embarass", "disgust"];
for j = 1:5
    folder = strcat(strcat('../data/',emotions(j)),"/");
    emotion = strcat(strcat('../data/',emotions(j)),"_");
    dir_list = dir(strcat('../data/',emotions(j)));
    dir_len = size(dir_list,1);
    % add code to load parms
    load(strcat(strcat("../data/", emotions(j)), "_ParmS_QB6.mat"))
    nLLS_test = zeros(dir_len,1);
    BICS_test = zeros(dir_len,1);
    for i = 1:dir_len
            if contains(dir_list(i).name,"train")
                dataTest = csvread(strcat(folder,strcat("test", extractAfter(dir_list(i).name,5))));
                datasize = size(dataTest,1);
                data = zeros(datasize,size(dataTest,2));
                data(1:size(dataTest,1),:) = dataTest;
                nLL = PerstoryQB6(ParmS(i,:),data);
                nLLS_test(i) = nLL;
                BICS_test(i) = nLL + 3*log(4*datasize);
            end
    end
    save(strcat(strcat("../data/", emotions(j)), "_nLLS_test_QB6.mat"),"nLLS_test");
    save(strcat(strcat("../data/", emotions(j)), "_BIC_test_QB6.mat"),"BICS_test");
end