% This MATLAB coding file solves Problem 4 in ECON-5243 Problem Set 5.
% Author: Ian He
% Institution: The University of Oklahoma
% Date: Mar 25, 2023

%% Problem 1
clear

% (f)
Xmean = 0.08;
Xvar = 0.01;
Xstd = sqrt(Xvar);
theta0 = -0.65;
theta1 = -4;

prob1 = exp(theta0+theta1*Xmean)/(1 + exp(theta0+theta1*Xmean));

% (g)
X = Xmean + 3*Xstd;

prob2 = exp(theta0+theta1*X)/(1 + exp(theta0+theta1*X));


% (h)
ME1 = theta1 * exp(-theta0-theta1*Xmean)/(1 + exp(-theta0-theta1*Xmean))^2;
ME2 = theta1 * exp(-theta0-theta1*X)/(1 + exp(-theta0-theta1*X))^2;


%% Problem 2
clear

% (b)
hat_theta = 2;
se = 0.3;
tau1 = 0.4;
tau2 = 0.35;

change_X = log(1-tau1) - log(1-tau2);
Ey = change_X * hat_theta;

CI_low = change_X * (hat_theta - 1.96*se);
CI_high = change_X * (hat_theta + 1.96*se);


%% Problem 4
clear

X = [0, 0.2, 2.5, 4, 6.1];
TEX = [-0.02, 0.06, 0.1, 0.2, 0.3];

% (a)
ATE = mean(TEX,2);


% (b)
syms b0 b1
eqn1 = log(0.272/(1-0.272)) == b0 + X(2)*b1;
eqn2 = log(0.354/(1-0.354)) == b0 + X(4)*b1;

sol = solve([eqn1, eqn2], [b0, b1]);
b0_sol = sol.b0;
b1_sol = sol.b1;


% (c)
ATT_n1 = [0, 0, 0, 0, 0];
ATT_d1 = [0, 0, 0, 0, 0];

for i = 1:numel(ATT_n1)
    ATT_n1(i) = TEX(i) * exp(b0_sol+b1_sol*X(i)) / (1+exp(b0_sol+b1_sol*X(i)));
    ATT_d1(i) = exp(b0_sol+b1_sol*X(i)) / (1+exp(b0_sol+b1_sol*X(i)));
end

ATT1 = sum(ATT_n1)/sum(ATT_d1);


% (f)
ATT_n2 = [0, 0, 0, 0, 0];
ATT_d2 = [0, 0, 0, 0, 0];
b_new = 0.5;

for i = 1:numel(ATT_n2)
    ATT_n2(i) = TEX(i) * exp(b0_sol+b_new*X(i)) / (1+exp(b0_sol+b_new*X(i)));
    ATT_d2(i) = exp(b0_sol+b_new*X(i)) / (1+exp(b0_sol+b_new*X(i)));
end

ATT2 = sum(ATT_n2)/sum(ATT_d2);


% (g)
TEX_new = [-0.02, 0.06, 0.1, 0.2, 0.9];

ATE_new = mean(TEX_new,2);

ATT_n3 = [0, 0, 0, 0, 0];
ATT_d3 = [0, 0, 0, 0, 0];

for i = 1:numel(ATT_n3)
    ATT_n3(i) = TEX_new(i) * exp(b0_sol+b1_sol*X(i)) / (1+exp(b0_sol+b1_sol*X(i)));
    ATT_d3(i) = exp(b0_sol+b1_sol*X(i)) / (1+exp(b0_sol+b1_sol*X(i)));
end

ATT_new = sum(ATT_n3)/sum(ATT_d3);

diff_old = ATT1 - ATE;
diff_new = ATT_new - ATE_new;