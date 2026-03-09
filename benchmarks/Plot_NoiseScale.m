clc
clearvars -except channels
close all

rng(0);

sysParams
% target_loc = [25, 45, 50]';
% load('myGroundTerminalDist.mat', 'groundTerminalsLoc');
% [RBS_loc, ul_users_loc, dl_users_loc] = groundTerminalsLoc{:};
% CommunChannels = channelSim(RBS_loc, ul_users_loc, dl_users_loc, target_loc);
% [A_0, zeta_0] = sensing_channel(RBS_loc,target_loc);
% 
% channels.comm = CommunChannels;
% channels.sensing1 = A_0;
% channels.sensing2 = zeta_0;




CNR_dB = linspace(-10,3,10);

xVals = length(CNR_dB);

% Preallocate
Power_all = NaN(2, xVals, 3);  % (flag, iter, component)
NPC_all = NaN(2, xVals);
UCSR_all = NaN(2, xVals);
DCSR_all = NaN(2, xVals);
CRLB_all = NaN(2, xVals);



for iter = 1:xVals

CNR = db2pow(CNR_dB(iter)); 


for flag = 0:2
    fprintf("\nRunning for FLAG = %d\n", flag);
    npc = [];
    i = 1;
    [params, slackvars] = initFeasible(channels, flag, CNR);

    npc(i) = sum(calc_power(params));
    % Loop
    converged = false;

    while (~converged)
        i = i + 1;

        [Sol, slackvars] = OptimResources(params, channels, slackvars, flag, CNR);
        V = Sol.V_opt; W = Sol.W_opt; P = Sol.P_opt;
        params = {P,V,W};

        Power = calc_power(params);
        npc(i) = sum(Power);
        [UCSR, DCSR, CRLB, ~, ~, ~, ~] = metrics_calc(params, channels, CNR);

        FE = abs(npc(i) - npc(i-1)) / npc(i-1);

        fprintf("FLAG %d | Iter #%d | NPC = %.2f | FE = %.2f%%\n", flag, i-1, npc(i), 100*FE);

        if FE < epsilon
            converged = true;

        end
    end

    fprintf("FLAG %d converged in %d iterations. InitVal = %.2f | OptVal = %.2f\n", flag, i-1, npc(1), npc(i));

    % Store
    Power_all(flag+1, iter, :) = Power;
    NPC_all(flag+1, iter) = npc(end);
    UCSR_all(flag+1,iter) = UCSR;
    DCSR_all(flag+1, iter) = DCSR;
    CRLB_all(flag+1, iter) = CRLB;
end

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
    y = NPC_all(flag, :);
    plot(CNR_dB, y, '-o', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag}, 'Color', colors(flag,:));
end
ylabel('NPC','Interpreter','latex','FontSize',fontSize);
legend('show','Location','northwest');
xlim([-10 3]);  
ylim([30 100]);
% --- 2: UCSR ---
subplot(4,1,2); hold on; grid on;
for flag = 1:2
    y = Power_all(flag, :, 1);
    plot(CNR_dB, y, '-s', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag}, 'Color', colors(flag,:));
end
ylabel('DLP','Interpreter','latex','FontSize',fontSize);
xlim([-10 3]);  
ylim([0 100]);
% --- 3: DCSR ---
subplot(4,1,3); hold on; grid on;
for flag = 1:2
    y = Power_all(flag, :, 2);
    plot(CNR_dB, y, '-d', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag}, 'Color', colors(flag,:));
end
ylabel('RSP','Interpreter','latex','FontSize',fontSize);
xlim([-10 3]);  
ylim([0 100]);
% --- 4: CRLB ---
subplot(4,1,4); hold on; grid on;
for flag = 1:2
    y = Power_all(flag, :, 3);
    plot(CNR_dB, y, '-^', 'LineWidth', 2, ...
        'DisplayName', flag_labels{flag}, 'Color', colors(flag,:));
end
xlabel('CNR [dB]','Interpreter','latex','FontSize',fontSize);
ylabel('ULP ','Interpreter','latex','FontSize',fontSize);
xlim([-10 3]);  

% sgtitle('Performance vs. Power Scaling','Interpreter','latex','FontSize',fontSize+2);