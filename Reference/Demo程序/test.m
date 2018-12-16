clc;
clear;
tic

filename = 'chf.txt';  %数据文件名称
data_all = importdata(filename);

% for i=1:16
%     y(:,i)=fft_filter(data_all(:,i),20,450,0.001);
% end

data1 = data_all(6001:9000,1:16);  %第一个手势
data2 = data_all(16001:19000,1:16); %第二个手势
data3 = data_all(26001:29000,1:16); %第三个手势
data4 = data_all(36001:39000,1:16); %第四个手势
data5 = data_all(46001:49000,1:16); %第五个手势
data6 = data_all(56001:59000,1:16); %第六个手势
data7 = data_all(66001:69000,1:16); %第七个手势
data8 = data_all(76001:79000,1:16); %第八个手势

%对各个手势动作部分的信号进行RMS信号提取
data_1_1 = GetRMS(data1, 300, 50);
data_2_1 = GetRMS(data2, 300, 50);
data_3_1 = GetRMS(data3, 300, 50);
data_4_1 = GetRMS(data4, 300, 50);
data_5_1 = GetRMS(data5, 300, 50);
data_6_1 = GetRMS(data6, 300, 50);
data_7_1 = GetRMS(data7, 300, 50);
data_8_1 = GetRMS(data8, 300, 50);

%对各个手势动作部分的信号标定类别标签
a1 = ones(55,1) * 1;
a2 = ones(55,1) * 2;
a3 = ones(55,1) * 3;
a4 = ones(55,1) * 4;
a5 = ones(55,1) * 5;
a6 = ones(55,1) * 6;
a7 = ones(55,1) * 7;
a8 = ones(55,1) * 8;

%形成训练数据+测试数据合集
data_1 = [data_1_1 a1];
data_2 = [data_2_1 a2];
data_3 = [data_3_1 a3];
data_4 = [data_4_1 a4];
data_5 = [data_5_1 a5];
data_6 = [data_6_1 a3];
data_7 = [data_7_1 a4];
data_8 = [data_8_1 a5];

%分别按照比例形成训练集和测试集
[row, col] = size(data_1);
data_traing = [data_1;data_2;data_3;data_4;data_5;data_6;data_7;data_8];
[m, n] = size(data_traing);
num_train = fix(m * 0.7);
num_test = fix(m * 0.3);
accuracy = zeros(30,1);

for i = 1:30
    num=0;
    choose = randperm(length(data_traing));
    %形成随机的训练集，训练集标签，测试集以及测试集标签
    TrainData = data_traing(choose(1:num_train),:);
    TrainLabel = TrainData(:,end);
    TrainData = TrainData(1:num_train,1:col-1);
    TestData = data_traing(choose(num_train+1:end),:);
    TestLabel = TestData(:,end);
    TestData = TestData(1:num_test,1:col-1);
    
% %     调用knn时需要先保存数据文件
%     save F:\工作\EMG研究资料\Codes\2017.11.1\TrainData.txt TrainData -ascii
%     save F:\工作\EMG研究资料\Codes\2017.11.1\TrainLabel.txt TrainLabel -ascii
%     save F:\工作\EMG研究资料\Codes\2017.11.1\TestData.txt TestData -ascii
    
% %  1.LDA分类
    MdlLinear = fitcdiscr(TrainData,TrainLabel);
    target = predict(MdlLinear,TestData);
    for j = 1:num_test
        if target(j,1) == TestLabel(j,1)
            num = num+1;
        end
    end
     accuracy(i,1) = num / num_test;
    
% %  2.SVM分类
%     model = libsvmtrain(TrainLabel, TrainData,'-s 0 -t 1 -c 1 -g 0.125');
%     [predict_label, accuracy1, dec_values] = libsvmpredict(TestLabel, TestData, model);
%     accuracy(i) = accuracy1(1, 1);

% %  3.knn分类
%     warning('off');
%     k = knnclassify(TestData,TrainData,TrainLabel',3,'cosine','random');
%     for j = 1:num_test
%         if k(j,1) == TestLabel(j,1)
%             num = num+1;
%         end
%     end
%     accuracy(i,1) = num / num_test;
 
% %  4.Bayes分类
%     [ Priors Mus Sigmas numClass] = BayesTraining( TrainData, TrainLabel );
%     [ TrainAccuracyWithRawData ] = BayesTesting( Priors,Mus,Sigmas,numClass , TrainData, TrainLabel );
%     [ accuracy(i,1) ] = BayesTesting( Priors,Mus,Sigmas,numClass , TestData, TestLabel );
end

cpu_time = toc
Accuracy = mean(accuracy)