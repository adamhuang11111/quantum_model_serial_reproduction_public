emotions = {'happy', 'sad', 'risk', 'disgust', 'embarass'};
folders = {'../data/happy/', '../data/sad/', '../data/risk/', '../data/disgust/', '../data/embarass/'};
funBS3 = @(x,data)PerstoryBS3(x,data);
funBSB5 = @(x,data)PerstoryBSB5(x,data);
funBSAB7 = @(x,data)PerstoryBSAB7(x,data);
funQB6 = @(x,data)PerstoryQB6(x,data);
funQAB8 = @(x,data)PerstoryQAB8(x,data);
funs = {funBS3, funBSB5, funBS3, funBSB5, funBSAB7};
funs_q = {funQAB8,funQB6,funQAB8,funQB6,funQB6};
funnames = ["BS3", "BSB5","BS3","BSB5","BSAB7"];
funnames_q = ["QAB8","QB6","QAB8","QB6","QB6"];
storyID = [37 36 35 26 24; 40 38 36 32 26; 38 30 29 28 27; 
    42 40 30 28 27; 40 37 31 28 23];
story2ID = [37 26; 40 32; 30 27; 42 30; 37 28];
offset = 0; % for plotting each emotion in one row
for nn = 1 : 5 
    emotion = strcat(emotions{nn},"_");
    dir_list = dir(folders{nn});
%     dir_len = size(dir_list,1);
    folder = folders{nn};
    funname = funnames(nn);
    funname_q = funnames_q(nn);
    load(strcat("fitting_results/Parm/",emotion,"ParmS_",funname));
    ParmS_b = ParmS;
    load(strcat("fitting_results/Parm/",emotion,"ParmS_",funname_q));
    ParmS_q = ParmS;
    stories = storyID(nn,:);
    stories2 = story2ID(nn,:);
    kk = 1;
    BSfun = funs{nn};
    Qfun = funs_q{nn};
    index2 = 6;
    for i = stories
        if contains(dir_list(i).name,"train")
            dataTrain = csvread(strcat(folder,dir_list(i).name));
            dataTest = csvread(strcat(folder,strcat("test", extractAfter(dir_list(i).name,5))));
            datasize = size(dataTest,1) + size(dataTrain,1);
            data = zeros(datasize,size(dataTrain,2));
            data(1:size(dataTrain,1),:) = dataTrain;
            data(size(dataTrain,1)+1:datasize,:) = dataTest;
            pred_q = zeros(size(data,1),1);
            pred_b = zeros(size(data,1),1);
            pred_q2 = zeros(size(data,1),1);
            pred_b2 = zeros(size(data,1),1);
            x1ub = 1.02*max(data(:,3));
            x1lb = 0.98*min(data(:,3));
            x1 = linspace(x1lb,x1ub,100);
            [~,idx] = sort(data(:,3));
            sorted_data = data(idx,:);
            for j = 1:size(data,1)
%                 data_temp = ones(1,4);
%                 data_temp(3) = x1(j);
                data_temp = sorted_data(j,:);
                [nLLS,P0s] = Qfun(ParmS_q(i,:),data_temp);
                [nLLS,P0s1] = BSfun(ParmS_b(i,:),data_temp);
                pred_q(j) = P0s(4);
                pred_b(j) = P0s1(4);
                pred_q2(j) = P0s(3);
                pred_b2(j) = P0s1(3);
            end
            subplot(5,7,kk+offset)
            plot(data(:,3),data(:,4),"s",'LineWidth',1.5,'color',[0.9290 0.6940 0.1250]);
            hold on
            plot(sorted_data(:,3),pred_b,"*",'LineWidth',1.5,'color',[0.8500 0.3250 0.0980]);
            hold on
            plot(sorted_data(:,3),pred_q,"ob",'LineWidth',1.5,'color',[0 0.4470 0.7410]);
            story_name = replace(erase(erase(dir_list(i).name,"train_"),".csv"),"_", " ");
            disp(story_name)
            title(strcat('\fontsize{12}\fontname{Times New Roman} ', story_name))
            ylabel('\fontsize{14}\fontname{Times New Roman}\it x_{4}')
            if offset == 28
                xlabel('\fontsize{14}\fontname{Times New Roman}\it x_{3}') 
            end
            if kk+offset == 1
                legend(["Data", "Best Bayesian","Best Quantum"], ...
                'FontSize',8,'FontName','Times New Roman','color','none','Location','best')
            end
            if ismember(i,stories2)
                subplot(5,7,index2 + offset)
                plot(data(:,2),data(:,3),"s",'LineWidth',1.5,'color',[0.9290 0.6940 0.1250],'MarkerSize',6);
                hold on
                plot(sorted_data(:,2),pred_b2,"*",'LineWidth',1.5,'color',[0.8500 0.3250 0.0980],'MarkerSize',6);
                hold on
                plot(sorted_data(:,2),pred_q2,"ob",'LineWidth',1.5,'color',[0 0.4470 0.7410],'MarkerSize',6);
                ylabel('\fontsize{14}\fontname{Times New Roman}\it x_{3}')
                if offset == 28
                xlabel('\fontsize{14}\fontname{Times New Roman}\it x_{2}') 
                end
                index2 = index2 + 1;
            end
        end
        kk = kk + 1;
    end  
    offset = offset + 7;
end