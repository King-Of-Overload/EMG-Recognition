function demo2
%
% Demo of the spatial Gaussian Mixture Regression (GMR) using query points 
% of arbitrary dimensions. This software loads a 4D dataset, trains a 
% Gaussian Mixture Model (GMM), and uses query points of 2 dimensions to 
% retrieve a generalized version of the data for the remaining 2 dimensions, 
% with associated constraints, through Gaussian Mixture Regression (GMR).
% Each datapoint has 4 dimensions, consisting of 2x2 spatial values 
% (e.g. drawing on a 2D Cartesian plane simultaneously with right and left 
% hand). A new sequence of 2D spatial values (i.e. data for left hand) is 
% loaded and used as query points to retrieve a sequence of expected 
% spatial distributiuon for the remaining dimensions (i.e. data for right 
% hand), through Gaussian Mixture Regression (GMR).
%
% Copyright (c) 2006 Sylvain Calinon, LASA Lab, EPFL, CH-1015 Lausanne,
%               Switzerland, http://lasa.epfl.ch
%
% The program is free for non-commercial academic use.  
% Please acknowledge the authors in any academic publications that have 
% made use of this code or part of it. Please use this BibTex reference: 
% 
% @article{Calinon06SMC,
%   title="On Learning, Representing and Generalizing a Task in a Humanoid 
%     Robot",
%   author="S. Calinon and F. Guenter and A. Billard",
%   journal="IEEE Transactions on Systems, Man and Cybernetics, Part B. 
%     Special issue on robot learning by observation, demonstration and 
%     imitation",
%   year="2006",
%   volume="36",
%   number="5"
% }

%% Definition of the number of components used in GMM.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nbStates = 3;

%% Load a dataset consisting of 3 demonstrations of a 2D signal.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('data/data2_a.mat'); %load 'Data'
load('data/data2_b.mat'); %load 'queryData'
nbVar = size(Data,1);

%% Training of GMM by EM algorithm, initialized by k-means clustering.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Priors, Mu, Sigma] = EM_init_kmeans(Data, nbStates);
[Priors, Mu, Sigma] = EM(Data, Priors, Mu, Sigma);

%% Use of GMR to retrieve a generalized version of the data and associated
%% constraints. A sequence of temporal values is used as input, and the 
%% expected distribution is retrieved. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expData(1:2,:) = queryData;
[expData(3:4,:), expSigma] = GMR(Priors, Mu, Sigma,  expData(1:2,:), [1:2], [3:4]);

%% Plot of the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('position',[10,10,1000,800],'name','GMM-GMR-demo2'); 
subplot(3,1,1); hold on;
plot(Data(1,:), Data(2,:), 'x', 'markerSize', 4, 'color', [.8 0 0]);
plot(Data(3,:), Data(4,:), 'x', 'markerSize', 4, 'color', [0 .8 0]);
axis([min([Data(1,:),Data(3,:)])-0.02 max([Data(1,:),Data(3,:)])+0.02 ...
  min([Data(2,:),Data(4,:)])-0.01 max([Data(2,:),Data(4,:)])+0.01]);
xlabel('x_1,x_3','fontsize',16); ylabel('x_2,x_4','fontsize',16);

%% Plot of the GMM encoding results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,1,2); hold on;
plotGMM(Mu([1,2],:), Sigma([1,2],[1,2],:), [.8 0 0], 1);
plotGMM(Mu([3,4],:), Sigma([3,4],[3,4],:), [0 .8 0], 1);
axis([min([Data(1,:),Data(3,:)])-0.02 max([Data(1,:),Data(3,:)])+0.02 ...
  min([Data(2,:),Data(4,:)])-0.01 max([Data(2,:),Data(4,:)])+0.01]);
xlabel('x_1,x_3','fontsize',16); ylabel('x_2,x_4','fontsize',16);

%% Plot of the GMR regression results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,1,3); hold on;
plotGMM(expData([3,4],:), expSigma([1,2],[1,2],:), [0 0 .8], 2);
plot(expData(1,:), expData(2,:), '-', 'lineWidth', 3, 'color', [0 0 .8]);
axis([min([Data(1,:),Data(3,:)])-0.02 max([Data(1,:),Data(3,:)])+0.02 ...
  min([Data(2,:),Data(4,:)])-0.01 max([Data(2,:),Data(4,:)])+0.01]);
xlabel('x_1,x_3','fontsize',16); ylabel('x_2,x_4','fontsize',16);

pause;
close all;
