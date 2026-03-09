clc
clear all
close all

rng(0)

sysParams
target_loc = [25    45   50]';
load('myGroundTerminalDist.mat', 'groundTerminalsLoc');
[RBS_loc, ul_users_loc, dl_users_loc] = groundTerminalsLoc{:};
CommunChannels = channelSim(RBS_loc, ul_users_loc, dl_users_loc, target_loc);
[A_0, zeta_0] = sensing_channel(RBS_loc,target_loc);

channels.comm = CommunChannels;
channels.sensing1 = A_0;
channels.sensing2 = zeta_0;


CNR = 1;

maxItr = 10;

% Preallocate
NPC_all = NaN(2, maxItr);
UCSR_all = NaN(2, maxItr);
DCSR_all = NaN(2, maxItr);
CRLB_all = NaN(2, maxItr);
FE_all = NaN(2, maxItr);


for flag = 0:1
    fprintf("\nRunning for FLAG = %d\n", flag);
    npc = [];
    FE = [];
    i = 1;
    [params, slackvars] = initFeasible(channels, flag, CNR);

    npc(i) = sum(calc_power(params));
    [ucsr, dcsr, crlb, ~, ~, ~, ~] = metrics_calc(params, channels, CNR);
    
    % Store
    NPC_all(flag+1, i) = npc(i);
    UCSR_all(flag+1, i) = ucsr;
    DCSR_all(flag+1, i) = dcsr;
    CRLB_all(flag+1, i) = crlb;

    % Loop
    converged = false;

    while (~converged)
        i = i + 1;

        [Sol, slackvars] = OptimResources(params, channels, slackvars, flag, CNR);
        V = Sol.V_opt; W = Sol.W_opt; P = Sol.P_opt;
        params = {P,V,W};

        npc(i) = sum(calc_power(params));
        [ucsr, dcsr, crlb, ~, ~, ~, ~] = metrics_calc(params, channels, CNR);

        NPC_all(flag+1, i) = npc(i);
        UCSR_all(flag+1, i) = ucsr;
        DCSR_all(flag+1, i) = dcsr;
        CRLB_all(flag+1, i) = crlb;

        FE(i-1) = abs(npc(i) - npc(i-1)) / npc(i-1);
        FE_all (flag+1, i) = FE(i-1);
        fprintf("FLAG %d | Iter #%d | NPC = %.2f | FE = %.2f%%\n", flag, i-1, npc(i), 100*FE(i-1));

        if FE(i-1) < epsilon
            converged = true;

        end
    end

    fprintf("FLAG %d converged in %d iterations. InitVal = %.2f | OptVal = %.2f\n", flag, i-1, npc(1), npc(i));


end



%%

%% === Plot: Comparison over delta_dB with subplots ===
close all
figure; 
fontSize = 12;
flag_labels = {'Proposed', 'Without AN'};
colors = lines(2);

% --- 1: NPC ---
subplot(4,1,1); hold on; grid on;
for flag = 1:2
    y = NPC_all(flag, 2:end);
    y = fill_to_maxIter(y, maxItr);
    semilogy(1:maxItr, y, '-o', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag}, 'Color', colors(flag,:));
end
ylabel('NPC','Interpreter','latex','FontSize',fontSize);
legend('show','Location','northeast');
ylim([55 100])
% --- 2: UCSR ---
subplot(4,1,2); hold on; grid on;
for flag = 1:2
    y = UCSR_all(flag, :);
    y = fill_to_maxIter(y, maxItr);
    semilogy(1:maxItr, y, '-s', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag}, 'Color', colors(flag,:));
end
yline(rho_ul, ':k',  'LineWidth', 2, 'DisplayName', 'Threshold \rho^{UL}');
ylabel('UCSR','Interpreter','latex','FontSize',fontSize);
legend('Location', 'northeast');

% --- 3: DCSR ---
subplot(4,1,3); hold on; grid on;
for flag = 1:2
    y = DCSR_all(flag, :);
     y = fill_to_maxIter(y, maxItr);
    semilogy(1:maxItr, y, '-d', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag}, 'Color', colors(flag,:));
end
yline(rho_dl, ':k',  'LineWidth', 2, 'DisplayName', 'Threshold \rho^{DL}');
ylabel('DCSR','Interpreter','latex','FontSize',fontSize);
legend('Location', 'northeast');

% --- 4: CRLB ---
subplot(4,1,4); hold on; grid on;
for flag = 1:2
    y = CRLB_all(flag, :);
    y = fill_to_maxIter(y, maxItr);
    semilogy(1:maxItr, y, '-^', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag}, 'Color', colors(flag,:));
end
hold on;
yline(rho_est, ':k',  'LineWidth', 2,  'DisplayName', 'Threshold \rho^{est}');
xlabel('Iteration','Interpreter','latex','FontSize',fontSize);
ylabel('CRLB ','Interpreter','latex','FontSize',fontSize);
legend('Location', 'east');

% sgtitle('Performance vs. Power Scaling','Interpreter','latex','FontSize',fontSize+2);