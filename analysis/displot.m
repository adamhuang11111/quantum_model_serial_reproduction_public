load(strcat("fitting_results/Parm/disgust_ParmS_BSB5"));
ParmS_b = ParmS;
load(strcat("fitting_results/Parm/disgust_ParmS_QB6"));
ParmS_q = ParmS;
stories = [32 34];
dir_list = dir("../data/disgust");
kk = 1;
for i = stories
    if contains(dir_list(i).name,"train")
        dataTrain = csvread(strcat("../data/disgust/",dir_list(i).name));
        dataTest = csvread(strcat("../data/disgust/",strcat("test", extractAfter(dir_list(i).name,5))));
        datasize = size(dataTest,1) + size(dataTrain,1);
        data = zeros(datasize,size(dataTrain,2));
        data(1:size(dataTrain,1),:) = dataTrain;
        data(size(dataTrain,1)+1:datasize,:) = dataTest;
        x1ub = 7;
        x1lb = 0;
        x1 = linspace(x1lb,x1ub,100);
        [nLLS,P0s,P0Hs] = displot_q(ParmS_q(i,:),data);
        pd_q1 = makedist('Normal','mu',P0Hs(1,2,1),'sigma',ParmS_q(i,3));
        pd_q1 = truncate(pd_q1,0,7);
        pd_q2 = makedist('Normal','mu',P0Hs(1,2,2),'sigma',ParmS_q(i,3));
        pd_q2 = truncate(pd_q2,0,7);
        d_q = ParmS_q(i,4)*pdf(pd_q1,x1) + (1 - ParmS_q(i,4))*pdf(pd_q2,x1);
        [nLLS,P0s1,Psigs,P0Hs1] = displot_b(ParmS_b(i,:),data);
        pd_b1 = makedist('Normal','mu',P0Hs1(1,2,1),'sigma',Psigs(1));
        pd_b1 = truncate(pd_b1,0,7);
        pd_b2 = makedist('Normal','mu',P0Hs1(1,2,2),'sigma',Psigs(1));
        pd_b2 = truncate(pd_b2,0,7);
        d_b = ParmS_b(i,3)*pdf(pd_b1,x1) + (1 - ParmS_b(i,3))*pdf(pd_b2,x1);
        %figure
        disp(kk)
        subplot(1,2,kk)
        histogram(data(:,2),'Normalization','probability');
        hold on
        plot(x1,d_q,x1,d_b,'LineWidth',1.5);
        pbaspect([1 1 1])
        story_name = replace(erase(erase(dir_list(i).name,"train_"),".csv"),"_", " ");
        disp(story_name)
        title(strcat('\fontsize{12}\fontname{Times New Roman} ', strcat(story_name, "")))
        ylabel('\fontsize{14}\fontname{Times New Roman}\it Density')
        xlabel('\fontsize{14}\fontname{Times New Roman}\it S_2')
        if kk == 1
            legend(["Data", "Best Quantum","Best Bayesian"], ...
            'FontSize',8,'FontName','Times New Roman','color','none','Location','best')
        end
    end
    kk = kk + 1;
end