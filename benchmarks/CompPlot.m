clc
clearvars -except channels
close all

rng(0);

sysParams
target_loc = [25, 45, 50]';
load('myGroundTerminalDist.mat', 'groundTerminalsLoc');
[RBS_loc, ul_users_loc, dl_users_loc] = groundTerminalsLoc{:};
CommunChannels = channelSim(RBS_loc, ul_users_loc, dl_users_loc, target_loc);
[A_0, zeta_0] = sensing_channel(RBS_loc,target_loc);

channels.comm = CommunChannels;
channels.sensing1 = A_0;
channels.sensing2 = zeta_0;


%% === Parameters ===
maxIter = 10;

% Preallocate
Power_all = NaN(2, maxIter, 3);  % (flag, iter, component)
NPC = NaN(2, maxIter);
FE_all = NaN(2, maxIter);
UCSR_all = NaN(2, maxIter);
DCSR_all = NaN(2, maxIter);
CRLB_all = NaN(2, maxIter);

% Benchmarks labels
flag_labels = {'Proposed', 'No AN'};
colors = lines(2);

%% === Loop ===
for flag = 0:1
    fprintf("\nRunning for FLAG = %d\n", flag);

    npc = NaN(maxIter, 1);
    FE = NaN(maxIter, 1);
    Power = NaN(maxIter, 3);
    UCSR = NaN(maxIter, 1);
    DCSR = NaN(maxIter, 1);
    CRLB = NaN(maxIter, 1);

    % Init
    i = 1;
    [params, slackvars] = initFeasible(channels, flag, 1);

    Power(i,:) = calc_power(params);
    npc(i) = sum(Power(i,:));
    [UCSR(i), DCSR(i), CRLB(i), ~, ~, ~, ~] = metrics_calc(params, channels, 1);
    % Loop
    converged = false;

    while (~converged && i < maxIter)
        i = i + 1;

        [Sol, slackvars] = OptimResources(params, channels, slackvars, flag, 1);
        V = Sol.V_opt; W = Sol.W_opt; P = Sol.P_opt;
        params = {P,V,W};

        Power(i,:) = calc_power(params);
        npc(i) = sum(Power(i,:));
        [UCSR(i), DCSR(i), CRLB(i), ~, ~, ~, ~] = metrics_calc(params, channels);

        FE(i) = abs(npc(i) - npc(i-1)) / npc(i-1);

        fprintf("FLAG %d | Iter #%d | NPC = %.2f | FE = %.2f%%\n", flag, i-1, npc(i), 100*FE(i));

        if FE(i) < epsilon
            converged = true;
        end
    end

    fprintf("FLAG %d converged in %d iterations. InitVal = %.2f | OptVal = %.2f\n", flag, i-1, npc(1), npc(i));

    % Store
    Power_all(flag+1, 1:i, :) = Power(1:i, :);
    NPC(flag+1, 1:i) = npc(1:i);
    FE_all(flag+1, 1:i) = FE(1:i);
    UCSR_all(flag+1, 1:i) = UCSR(1:i);
    DCSR_all(flag+1, 1:i) = DCSR(1:i);
    CRLB_all(flag+1, 1:i) = CRLB(1:i);
end

%% === Plot convergence of objective value and fractional error ===
figure; fontSize = 12;

% Subplot 1: NPC
subplot(2,1,1); hold on; grid on;
for flag = 0:1
    y = NPC(flag+1, :);
    y = fill_to_maxIter(y, maxIter);
    semilogy(0:maxIter-1,y, '-o', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag+1}, 'Color', colors(flag+1,:));
end
set(gca, 'YScale', 'log')
xlabel('Iteration', 'Interpreter', 'latex', 'FontSize', fontSize);
ylabel('Total Network Power [dBW]', 'Interpreter', 'latex', 'FontSize', fontSize);
legend('show', 'Location', 'best');

% Subplot 2: FE
subplot(2,1,2); hold on; grid on;
for flag = 0:1
    y = FE_all(flag+1, 2:end);
    y = fill_to_maxIter(y, maxIter);
    plot(1:maxIter, y, '-o', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag+1}, 'Color', colors(flag+1,:));
end
set(gca, 'YScale', 'log')
xlabel('Iteration', 'Interpreter', 'latex', 'FontSize', fontSize);
ylabel('Fractional Error', 'Interpreter', 'latex', 'FontSize', fontSize);
legend('show', 'Location', 'best');

%% === Plot constraint satisfaction ===
figure; fontSize = 12;

% --- UCSR ---
subplot(3,1,1); hold on; grid on;
for flag = 0:1
    y = UCSR_all(flag+1, :);
    y = fill_to_maxIter(y, maxIter);
    semilogy(0:maxIter-1, y, '-o', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag+1}, 'Color', colors(flag+1,:));
end
yline(rho_ul, '--k', 'LineWidth', 1.5, 'DisplayName', '\rho^{UL}');
xlabel('Iteration', 'Interpreter', 'latex', 'FontSize', fontSize);
ylabel('UCSR', 'Interpreter', 'latex', 'FontSize', fontSize);
title('Uplink Communication Secrecy Constraint', 'Interpreter', 'latex', 'FontSize', fontSize);
legend('show');

% --- DCSR ---
subplot(3,1,2); hold on; grid on;
for flag = 0:1
    y = DCSR_all(flag+1, :);
    y = fill_to_maxIter(y, maxIter);
    semilogy(0:maxIter-1, y, '-o', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag+1}, 'Color', colors(flag+1,:));
end
yline(rho_dl, '--k', 'LineWidth', 1.5, 'DisplayName', '\rho^{DL}');
ylabel('DCSR', 'Interpreter', 'latex', 'FontSize', fontSize);
title('Downlink Communication Secrecy Constraint', 'Interpreter', 'latex', 'FontSize', fontSize);
legend('show');

% --- CRLB ---
subplot(3,1,3); hold on; grid on;
for flag = 0:1
    y = CRLB_all(flag+1, :);
    y = fill_to_maxIter(y, maxIter);
    plot(0:maxIter-1, y, '-o', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag+1}, 'Color', colors(flag+1,:));
end
yline(rho_est, '--k', 'LineWidth', 1.5, 'DisplayName', '$\rho^{est}$');
xlabel('Iteration', 'Interpreter', 'latex', 'FontSize', fontSize);
ylabel('CRLB', 'Interpreter', 'latex', 'FontSize', fontSize);
title('Radar Sensing Constraint', 'Interpreter', 'latex', 'FontSize', fontSize);
legend('show');