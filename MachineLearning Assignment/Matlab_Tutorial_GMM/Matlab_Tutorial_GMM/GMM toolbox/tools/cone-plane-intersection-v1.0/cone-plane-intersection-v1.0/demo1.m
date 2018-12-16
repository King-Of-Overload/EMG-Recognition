function demo1
%
% This demo computes the intersection between a cone and a plane, and
% represents the intersection as a Gaussian Probability Density Function
% (PDF). The algorithm can be used to extract probabilistically information 
% concerning gazing or pointing direction. Indeed, by representing a visual 
% field as a cone and representing a table as a plane, the Gaussian PDF 
% can be used to compute the probability that one object on the table is 
% observed/pointed by the user. 
%
% Copyright (c) 2006 Sylvain Calinon, LASA Lab, EPFL, CH-1015 Lausanne,
%               Switzerland, http://lasa.epfl.ch
%
% The program is free for non-commercial academic use. 
% Please contact the authors if you are interested in using the 
% software for commercial purposes. The software must not be modified or 
% distributed without prior permission of the authors.
% Please acknowledge the authors in any academic publications that have 
% made use of this code or part of it. Please use this BibTex reference: 
% 
% @InProceedings{Calinon06roman,
%   author = "S. Calinon and A. Billard",
%   title = "Teaching a Humanoid Robot to Recognize and Reproduce Social 
%     Cues",
%   booktitle = "Proceedings of the IEEE International Symposium on Robot 
%     and Human Interactive Communication (RO-MAN)",
%   year = "2006"
% }

%% Cone parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Cone vertex point
coneOrg = [0;-1;2.0];
%Cone direction (axis of revolution), defined as a unity vector
coneDir = [0;cos(-1.1);sin(-1.1)];
%Cone half-angle
coneAngle = 0.2;
%Compute vectors (coneE1,coneE2) describing two oprthogonal directions of 
%the cone basis.
coneE1 = cross(coneDir,[1;0;0]);
coneE2 = cross(coneDir,coneE1);

%% Plane parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plane origin
planeOrg = [0;0;0];
%Plane first direction, defined as a unity vector
planeDir1 = [1;0;0];
%Plane second direction, defined as a unity vector
planeDir2 = [0;1;0];

%% Compute the cone-plane intersection represented as a Gaussian PDF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Mu, Sigma] = conePlaneIntersection(coneOrg, coneDir, coneAngle, planeOrg, planeDir1, planeDir2);

%% Subplot for the cone-plane intersection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('position',[50,50,1000,400],'name','Cone-plane intersection represented as Gaussian PDF');
subplot(2,2,1); hold on;
%Plot plane
planeSeg = [planeOrg-planeDir1-planeDir2 ...
  planeOrg+planeDir1-planeDir2 ...
  planeOrg+planeDir1+planeDir2 ...
  planeOrg-planeDir1+planeDir2 ...
  planeOrg-planeDir1-planeDir2];
patch(planeSeg(1,:),planeSeg(2,:),planeSeg(3,:),[.9 .9 .9]);
%Create segments for the intersection ellipse
nbSeg = 20;
t = linspace(-pi,pi,nbSeg)';
X = [cos(t) sin(t)] * real(sqrtm(Sigma)) + repmat(Mu',nbSeg,1);
for i=1:nbSeg
  interSeg(:,i) = planeOrg + X(i,1).*planeDir1 + X(i,2).*planeDir2; 
end
%Plot cone
for i=2:nbSeg
  patch([coneOrg(1) interSeg(1,i-1) interSeg(1,i)]', ...
    [coneOrg(2) interSeg(2,i-1) interSeg(2,i)]', ...
    [coneOrg(3) interSeg(3,i-1) interSeg(3,i)]', [1 0 0]);
end
%Plot cone-plane intersection
plot3(interSeg(1,:),interSeg(2,:),interSeg(3,:),'-','lineWidth',3,'color',[1 1 0]);
set(gcf,'Renderer','zbuffer'); lightangle(-45,30); lighting phong;
axis([-1 1 -1 1 0 2]); view(3); grid on;
xlabel('X','fontsize',16); ylabel('Y','fontsize',16); zlabel('Z','fontsize',16);

%% Subplot for the PDF representation of the intersection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,2); hold on;
%Create a uniform grid
szgrid = 20;
[xx,yy] = meshgrid(linspace(-1,1,szgrid), linspace(-1,1,szgrid));
%Compute the probability density function for each point in the grid
zz = gaussPDF([xx(:) yy(:)]', Mu, Sigma);
zz = reshape(zz, size(xx));
%Plot the probability density function
surf(xx,yy,zz, 'LineStyle', '-'); 
axis([-1 1 -1 1 0 max(max(zz))]); colormap Gray; view(3); grid on;
xlabel('X','fontsize',16); ylabel('Y','fontsize',16); zlabel('P(X,Y)','fontsize',16);
print('-depsc2','cone-plane-graph01.eps');

pause;
close all;

 
