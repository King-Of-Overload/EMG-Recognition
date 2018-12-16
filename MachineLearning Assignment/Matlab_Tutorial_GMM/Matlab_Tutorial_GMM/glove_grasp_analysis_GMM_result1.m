%GMM for glove
% clc;
% clear;
%--------------load data---------------------
load glove_grasp_6_13_20_100points.mat   %加载数据集文件
Odata = glove_grasp_6_13_20;   % 6x13x20

[subjectnum, motionnum, repnum] = size(Odata); % subjectnum=6 motionnum=13 repnum=20
totaltimeused = 0;
% allresult = zeros(subjectnum,motionnum);
% allrate = zeros(1,19);
%%--------------------------------------------
%%
%%
%本次实验的数据集是肌电信号数据集，他是一个三维单元矩阵，，表示6个实验对象（人），13个不同的手势动作，每组动作重复20次。每次重复会采集100个时间点的信号，实验采用的是21个电极，因此每次重复手势动作产生21X100大小矩阵的数。
%%
 for modelnum = 1:1
    for subject = 1:6  % 数据集6个实验对象，步长为6，分离出每个实验对象数据集，subject
        for motion = 1:motionnum   % 分离出每组的手势，即每组13个不同手势，读取每个实验对象的每个手势
            
            tstart1 = tic;  % 记录程序运行当前时间


            nbStates = 10; % k-means划分为10类
            %%---------------modeling---------------------
            data4model = []; 
            for i = 1:modelnum                            %single：1
                tmp = [1:100;Odata{subject,motion,i}];    %single   22*100矩阵，读取到每个对象每组动作的数据
                data4model = [data4model,tmp];            %single
            end                                           %single
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            nbVar = size(data4model,1); % 获得每组动作数据矩阵的行数，应该为22行

            % Training of GMM by EM algorithm, initialized by k-means clustering.
            %开始通过EM算法训练GMM高斯混合模型
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            tstart2 = tic; % 记录训练开始的时候的时间
            %prior表示K GMM组件的先验概率  1*K，为数组，1*10
            %Mu表示K GMM组件的中心  22x10矩阵
            %Sigma表示K GMM组件的协方差矩阵  22*22*10
            %nbStates表示GMM 组件的数目，即K
            %data4model是22*100矩阵，表示22维的100数据点
            [Priors, Mu, Sigma] = EM_init_kmeans(data4model, nbStates); %开始调用初始化k-means函数，内部传入需要数据矩阵以及需要将数据划分为几类，此处指定为10
            [Priors, Mu, Sigma] = EM(data4model, Priors, Mu, Sigma); % 进行EM训练
            tmodel = toc(tstart2); % 记录下训练结束时间
            model = Mu(2:22,:);  % 去除第一行的数据，因为data4model第一行元素为1-100序号标定


            %--------------------------recognizing  开始识别------------

            result = zeros( motionnum, repnum, motionnum); % 生成一个包含13个13*20大小的矩阵数组 对应13个动作 每组动作重复20次
            for j = 1:motionnum   %13  13个动作遍历
                for i = 1:repnum   %20  重复次数
                    tstart = tic;   %记录当前时间，和toc配合使用来计时
                    %取当前实验对象第j个动作的第i次重复的数据
                    %Odata每个元素数组的维度是20x13 做算数乘法时需要对GMM中心进行截断  22x10 -> 21x10
                    testdata = Odata{subject,j,i}(:,fix(Mu(1,:)));  %21*10 double， fix函数用来截尾取整, Mu(1,:)打印Mu第一行，Mu是22*10矩阵
                    %首先测试数据与训练模型矩阵相减，然后求取相减后新矩阵各个元素绝对值的和
                    result( j, i, motion) = sum(sum(abs(testdata - model))); %将结果保存在result矩阵对应位置中
                    trecognize = toc(tstart);%计算识别结束耗费时间
                end
            end
            %接着计算出result中每个手势所有动作矩阵当中包含每一列最小值的行向量，求取行向量的转置矩阵，然后用其乘以一阶单位行向量转置(该行向量包括几个动作)
            %然后使用result[motion]减去上面的结果
            result(:,:,motion) = result(:,:,motion) - (min(result(:,:,motion))'*ones(1,motionnum))';
            %计算识别率
            aa_tmp = (length(find (result(motion,modelnum+1:repnum,motion) == 0)))/(repnum-modelnum);
            %存储识别率
            allresult(subject,motion,modelnum) = aa_tmp;
            totaltimeused = totaltimeused + toc(tstart1);
            tremaining = toc(tstart1)*(subjectnum*motionnum - (subject-1)*motionnum - motion); % 统计最终运行时间
            disp([num2str(modelnum),',iterations remaining:',num2str(subjectnum*motionnum - (subject-1)*motionnum - motion),'  time used:',num2str(totaltimeused),'s']);    
        end
    end
    modelnum;
    %计算矩阵各列向量的均值，然后对所有列均值的集合再计算均值，该均值即为识别概率
    allrate(1,modelnum) = mean(mean(allresult(:,:,modelnum)));
    disp(['Finished! Overall recognition rate is: ', num2str(allrate)]);
end



