%GMM for glove
% clc;
% clear;
%--------------load data---------------------
load glove_grasp_6_13_20_100points.mat   %�������ݼ��ļ�
Odata = glove_grasp_6_13_20;   % 6x13x20

[subjectnum, motionnum, repnum] = size(Odata); % subjectnum=6 motionnum=13 repnum=20
totaltimeused = 0;
% allresult = zeros(subjectnum,motionnum);
% allrate = zeros(1,19);
%%--------------------------------------------
%%
%%
%����ʵ������ݼ��Ǽ����ź����ݼ�������һ����ά��Ԫ���󣬣���ʾ6��ʵ������ˣ���13����ͬ�����ƶ�����ÿ�鶯���ظ�20�Ρ�ÿ���ظ���ɼ�100��ʱ�����źţ�ʵ����õ���21���缫�����ÿ���ظ����ƶ�������21X100��С���������
%%
 for modelnum = 1:1
    for subject = 1:6  % ���ݼ�6��ʵ����󣬲���Ϊ6�������ÿ��ʵ��������ݼ���subject
        for motion = 1:motionnum   % �����ÿ������ƣ���ÿ��13����ͬ���ƣ���ȡÿ��ʵ������ÿ������
            
            tstart1 = tic;  % ��¼�������е�ǰʱ��


            nbStates = 10; % k-means����Ϊ10��
            %%---------------modeling---------------------
            data4model = []; 
            for i = 1:modelnum                            %single��1
                tmp = [1:100;Odata{subject,motion,i}];    %single   22*100���󣬶�ȡ��ÿ������ÿ�鶯��������
                data4model = [data4model,tmp];            %single
            end                                           %single
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            nbVar = size(data4model,1); % ���ÿ�鶯�����ݾ����������Ӧ��Ϊ22��

            % Training of GMM by EM algorithm, initialized by k-means clustering.
            %��ʼͨ��EM�㷨ѵ��GMM��˹���ģ��
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            tstart2 = tic; % ��¼ѵ����ʼ��ʱ���ʱ��
            %prior��ʾK GMM������������  1*K��Ϊ���飬1*10
            %Mu��ʾK GMM���������  22x10����
            %Sigma��ʾK GMM�����Э�������  22*22*10
            %nbStates��ʾGMM �������Ŀ����K
            %data4model��22*100���󣬱�ʾ22ά��100���ݵ�
            [Priors, Mu, Sigma] = EM_init_kmeans(data4model, nbStates); %��ʼ���ó�ʼ��k-means�������ڲ�������Ҫ���ݾ����Լ���Ҫ�����ݻ���Ϊ���࣬�˴�ָ��Ϊ10
            [Priors, Mu, Sigma] = EM(data4model, Priors, Mu, Sigma); % ����EMѵ��
            tmodel = toc(tstart2); % ��¼��ѵ������ʱ��
            model = Mu(2:22,:);  % ȥ����һ�е����ݣ���Ϊdata4model��һ��Ԫ��Ϊ1-100��ű궨


            %--------------------------recognizing  ��ʼʶ��------------

            result = zeros( motionnum, repnum, motionnum); % ����һ������13��13*20��С�ľ������� ��Ӧ13������ ÿ�鶯���ظ�20��
            for j = 1:motionnum   %13  13����������
                for i = 1:repnum   %20  �ظ�����
                    tstart = tic;   %��¼��ǰʱ�䣬��toc���ʹ������ʱ
                    %ȡ��ǰʵ������j�������ĵ�i���ظ�������
                    %Odataÿ��Ԫ�������ά����20x13 �������˷�ʱ��Ҫ��GMM���Ľ��нض�  22x10 -> 21x10
                    testdata = Odata{subject,j,i}(:,fix(Mu(1,:)));  %21*10 double�� fix����������βȡ��, Mu(1,:)��ӡMu��һ�У�Mu��22*10����
                    %���Ȳ���������ѵ��ģ�;��������Ȼ����ȡ������¾������Ԫ�ؾ���ֵ�ĺ�
                    result( j, i, motion) = sum(sum(abs(testdata - model))); %�����������result�����Ӧλ����
                    trecognize = toc(tstart);%����ʶ������ķ�ʱ��
                end
            end
            %���ż����result��ÿ���������ж��������а���ÿһ����Сֵ������������ȡ��������ת�þ���Ȼ���������һ�׵�λ������ת��(��������������������)
            %Ȼ��ʹ��result[motion]��ȥ����Ľ��
            result(:,:,motion) = result(:,:,motion) - (min(result(:,:,motion))'*ones(1,motionnum))';
            %����ʶ����
            aa_tmp = (length(find (result(motion,modelnum+1:repnum,motion) == 0)))/(repnum-modelnum);
            %�洢ʶ����
            allresult(subject,motion,modelnum) = aa_tmp;
            totaltimeused = totaltimeused + toc(tstart1);
            tremaining = toc(tstart1)*(subjectnum*motionnum - (subject-1)*motionnum - motion); % ͳ����������ʱ��
            disp([num2str(modelnum),',iterations remaining:',num2str(subjectnum*motionnum - (subject-1)*motionnum - motion),'  time used:',num2str(totaltimeused),'s']);    
        end
    end
    modelnum;
    %���������������ľ�ֵ��Ȼ��������о�ֵ�ļ����ټ����ֵ���þ�ֵ��Ϊʶ�����
    allrate(1,modelnum) = mean(mean(allresult(:,:,modelnum)));
    disp(['Finished! Overall recognition rate is: ', num2str(allrate)]);
end



