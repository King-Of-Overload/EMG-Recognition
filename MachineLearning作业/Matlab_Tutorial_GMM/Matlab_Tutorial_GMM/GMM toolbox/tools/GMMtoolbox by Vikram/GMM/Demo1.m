x1 = 10 + sqrt(3) * randn(2,3);
x2 = 20 + sqrt(5) * randn(2,3);
x3 = 25 + sqrt(2) * randn(2,3);
Input = [x1 x2 x3];
No_of_Clusters = 3;
No_of_Iterations = 5;
[INDEX,Mu, Variances] = GMM(Input, No_of_Clusters,No_of_Iterations)