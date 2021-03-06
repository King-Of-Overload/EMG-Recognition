function mu = Compute_Mean_for_Cluster(X,Means,Variances,PC,Label_of_Cluster)
[r,c] = size(X);
mu = 0.0;
Numerator = 0.0;
Denominator = 0.0;
for i=1:c
    Numerator = Numerator+ Probability_of_Cluster_given_X(X(:,i),Means,Variances,PC,Label_of_Cluster)*X(:,i);
    Denominator = Denominator + Probability_of_Cluster_given_X(X(:,i),Means,Variances,PC,Label_of_Cluster);
end;
mu = Numerator/Denominator;
