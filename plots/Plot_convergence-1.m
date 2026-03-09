%% Plot convergence of resource optimizationn
clc
clear 
close all

sysParams

load("data/myBuffer.mat", 'buffer'); % load Player 1's precalculated optimal strategy 

eve_key = eveLocationKey(q_i);
index = find(strcmp({buffer.Evekeys}, eve_key), 1);
channels = buffer(index).Channels;

i = 1;
[params, slackvars]= feasible_initialization(channels);
% checkFeasibility(params,channels, slackvars);

[P, V, W] = params{:};
[ucsr(i), dcsr(i), crlb(i),~,~,~] = metrics_calc(params, channels);

K = size(V,3);

SumVk = 0;
for k = 1:K
    SumVk = SumVk + V(:, :, k); % Sum beamforming matrices across users
end

% Calculate initial objective value without resource optimization
objVal = [];
objVal(i) =  (trace(SumVk) + trace(W) + sum(P));

% [UCSR, DCSR, CRLB, gamma_k_dl, gamma_ea_dl, gamma_la_ul, gamma_le_ul] = metrics(params, channels)

% Iterative solution until convergence
converged = false;
FE=[];
while (~converged)
    i = i + 1;
    [Prob1_Sol, slackvars] = OptimResources(params, channels, slackvars);
    V = Prob1_Sol.V_opt; % Optimized downlink user precoding covariance matrices
    W = Prob1_Sol.W_opt; % Optimized radar sensing covariance matrix
    P = Prob1_Sol.P_opt; % Optimized power allocation
    objVal(i) = Prob1_Sol.U1;
    params = {P,V,W};
    [ucsr(i), dcsr(i), crlb(i),~,~,~] = metrics_calc(params, channels);
    FE(i-1) = abs(objVal(i)- objVal(i-1)) /objVal(i-1);
    fprintf("Fractional Error at iteration #%d is %0.2f%%.\n",i-1, 100*FE(end));
% checkFeasibility(params,channels, slackvars);
    if (abs(objVal(i)- objVal(i-1)) /objVal(i-1) < 1e-2)
        converged = true;
    end

    [UCSR, DCSR, CRLB, gamma_k_dl, gamma_ea_dl, gamma_la_ul, gamma_le_ul] = metrics_calc(params, channels);
    fprintf("UCSR: %0.2f, DCSR: %0.2f, CRLB: %0.2f\n", UCSR, DCSR, CRLB);
end
fprintf("Algorithm is converged in %d iterations.\n", i-1);
fprintf("InitVal=%0.2f | OptVal = %0.2f. \n",objVal(1), objVal(end));


%% Plot convergence of the objective value and fractional error
figure;

% Set global font size for labels and legends
fontSize = 12; % Adjust this value as needed

% Plot objective value
subplot(2, 1, 1);
semilogy(0:i-1, objVal, '-o', 'LineWidth', 2);
xlabel('Iteration', 'Interpreter', 'latex', 'FontSize', fontSize);
ylabel('Objective Value ($U_1$)', 'Interpreter', 'latex', 'FontSize', fontSize);
title('Convergence of Objective Value', 'Interpreter', 'latex', 'FontSize', fontSize);
grid on;

% Plot fractional error
subplot(2, 1, 2);
semilogy(1:i-1, FE, '-o', 'LineWidth', 2, 'Color', 'r');
xlabel('Iteration', 'Interpreter', 'latex', 'FontSize', fontSize);
ylabel('Fractional Error', 'Interpreter', 'latex', 'FontSize', fontSize);
title('Convergence of Fractional Error', 'Interpreter', 'latex', 'FontSize', fontSize);
grid on;


%% Plot constraint satisfaction
figure;
fontSize = 12; % Adjust this value as needed

% Plot UCSR vs. threshold
subplot(3, 1, 1);
semilogy(0:i-1, ucsr, '-o', 'LineWidth', 2);
hold on;
yline(rho_ul, '--r', 'LineWidth', 1.5);
ylabel('UCSR', 'Interpreter', 'latex', 'FontSize', fontSize);
title('Uplink Communication Secrecy Constraint', 'Interpreter', 'latex', 'FontSize', fontSize);
legend('\Gamma^{UL}', 'Threshold \rho^{UL}', 'Location', 'northeast');
grid on;

% Plot DCSR vs. threshold
subplot(3, 1, 2);
semilogy(0:i-1, dcsr, '-o', 'LineWidth', 2);
hold on;
yline(rho_dl, '--r',  'LineWidth', 1.5);
ylabel('DCSR', 'Interpreter', 'latex', 'FontSize', fontSize);
title('Downlink Communication Secrecy Constraint', 'Interpreter', 'latex', 'FontSize', fontSize);
legend('\Gamma^{DL}', 'Threshold \rho^{DL}', 'Location', 'northeast');
grid on;

% Plot CRLB vs. threshold
subplot(3, 1, 3);
plot(0:i-1, crlb, '-o', 'LineWidth', 2);
hold on;
yline(rho_est, '--r',  'LineWidth', 1.5);
xlabel('Iteration', 'Interpreter', 'latex', 'FontSize', fontSize);
ylabel('CRLB', 'Interpreter', 'latex', 'FontSize', fontSize);
title('Radar Sensing Constraint', 'Interpreter', 'latex', 'FontSize', fontSize);
legend('\Gamma^{est}', 'Threshold \rho^{est}', 'Location', 'east');
grid on;

