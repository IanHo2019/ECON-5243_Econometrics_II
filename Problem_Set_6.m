% This MATLAB coding file solves ECON-5243 Problem Set 6.
% Author: Ian He
% Institution: The University of Oklahoma
% Date: Apr 23, 2023

%% Problem 2
clear

% (b)
gamma = 0.539;
se_gamma = 0.219;
av_stake = 0.2;

lower_ci = av_stake * (gamma - 1.96*se_gamma);
upper_ci = av_stake * (gamma + 1.96*se_gamma);

%% Problem 3
clear

% (h)
beta = -0.015;
t = -2.47;
sigma_b = beta/t;

lower_ci = beta - 1.96 * sigma_b;
upper_ci = beta + 1.96 * sigma_b;