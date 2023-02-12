% This file has solutions to Problem 4 in ECON-5243 Problem Set 2.
% Author: Ian He
% Institution: The University of Oklahoma
% Date: Feb 12, 2023

%% (2)
clear

data = readtable('Data\PS2_problem4_data.xls');

% Construct X and y vectors
A = ['a', 'b', 'c', 'd', 'e', 'f', 'g']; % This vector is just used to name 7 fields and help loop.

for i = 1:numel(A)
    X_vec.(A(i)) = [table2array(data(i,"x1")); table2array(data(i,"x2"))];
    y_vec.(A(i)) = table2array(data(i,"y"));
end

% Calculate summations of XX and Xy
for i = 1:numel(A)
    Xy_vec.(A(i)) = X_vec.(A(i))*y_vec.(A(i));
end

sumXX = X_vec.(A(1))*transpose(X_vec.(A(1)));
sumXy = Xy_vec.(A(1));
for i = 2:numel(A)
    sumXX = sumXX + X_vec.(A(i))*transpose(X_vec.(A(i)));
    sumXy = sumXy + Xy_vec.(A(i));
end

% Calculate beta
invXX = inv(sumXX);
beta = invXX * sumXy;

% Construct residual vector
hat_e = zeros(7,1);
for i = 1:numel(A)
    hat_e(i) = y_vec.(A(i)) - transpose(X_vec.(A(i)))*beta;
end

% Calculate variance of beta (n=7, k=2)
sigma_sq = 1/(7-2) * (hat_e' * hat_e);
Var_beta = sigma_sq*invXX;


%% (3)
clear

data = readtable('Data\PS2_problem4_data.xls');

% Construct X and y vectors
A = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];
for i = 1:numel(A)
    X_vec.(A(i)) = [1; table2array(data(i,"x1")); table2array(data(i,"x2"))];
    y_vec.(A(i)) = table2array(data(i,"y"));
end

% Calculate summations of XX and Xy
for i = 1:numel(A)
    Xy_vec.(A(i)) = X_vec.(A(i))*y_vec.(A(i));
end

sumXX = X_vec.(A(1))*transpose(X_vec.(A(1)));
sumXy = Xy_vec.(A(1));
for i = 2:numel(A)
    sumXX = sumXX + X_vec.(A(i))*transpose(X_vec.(A(i)));
    sumXy = sumXy + Xy_vec.(A(i));
end

% Calculate beta
invXX = inv(sumXX);
beta = invXX * sumXy;

% Construct residual vector
hat_e = zeros(7,1);
for i = 1:numel(A)
    hat_e(i) = y_vec.(A(i)) - transpose(X_vec.(A(i)))*beta;
end

% Calculate variance of beta (n=7, k=3)
sigma_sq = 1/(7-3) * (hat_e' * hat_e);
Var_beta = sigma_sq*invXX;


%% (4)
clear

data = readtable('Data\PS2_problem4_data.xls');

% Construct X and y vectors
A = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];
for i = 1:numel(A)
    X_vec.(A(i)) = [1; table2array(data(i,"x1")); table2array(data(i,"x2"))];
    y_vec.(A(i)) = table2array(data(i,"y"));
end

% Calculate means of X and y
mX = X_vec.(A(1));
my = y_vec.(A(1));
for i = 2:numel(A)
    mX = mX + X_vec.(A(i));
    my = my + y_vec.(A(i));
end

mX = mX/numel(A);
mX(1,1) = 0;
my = my/numel(A);

% Demean variables
for i = 1:numel(A)
    Xs_vec.(A(i)) = X_vec.(A(i)) - mX;
    ys_vec.(A(i)) = y_vec.(A(i)) - my;
end

% Calculate summations of XX and Xy
for i = 1:numel(A)
    Xy_vec.(A(i)) = Xs_vec.(A(i))*ys_vec.(A(i));
end

sumXX = Xs_vec.(A(1))*transpose(Xs_vec.(A(1)));
sumXy = Xy_vec.(A(1));
for i = 2:numel(A)
    sumXX = sumXX + Xs_vec.(A(i))*transpose(Xs_vec.(A(i)));
    sumXy = sumXy + Xy_vec.(A(i));
end

% Calculate beta
invXX = inv(sumXX);
beta = invXX * sumXy;

% Construct residual vector
hat_e = zeros(7,1);
for i = 1:numel(A)
    hat_e(i) = ys_vec.(A(i)) - transpose(Xs_vec.(A(i)))*beta;
end

% Calculate variance of beta (n=7, k=3)
sigma_sq = 1/(7-3) * (hat_e' * hat_e);
Var_beta = sigma_sq*invXX;