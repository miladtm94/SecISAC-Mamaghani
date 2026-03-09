function [U1_Proposed, U1_Baseline, U1_WithoutAN]  = calc_U1(target_loc)


rng(0)

sysParams
target_loc = [-95, 95, 80]';
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
U1 = zeros(1,3);


for flag = 0:1
    fprintf("\nRunning for FLAG = %d\n", flag);
    npc = [];
    FE = [];
    i = 1;
    [params, slackvars] = initFeasible(channels, flag, CNR);
    npc(i) = sum(calc_power(params));
    
    if flag == 0
        U1(1) = npc(i);
    end

    % Loop
    converged = false;

    while (~converged)
        i = i + 1;

        [Sol, slackvars] = OptimResources(params, channels, slackvars, flag, CNR);
        V = Sol.V_opt; W = Sol.W_opt; P = Sol.P_opt;
        params = {P,V,W};

        npc(i) = sum(calc_power(params));

   
        FE(i-1) = abs(npc(i) - npc(i-1)) / npc(i-1);

        fprintf("FLAG %d | Iter #%d | FE = %.2f%%\n", flag, i-1, 100*FE(i-1));

        if FE(i-1) < epsilon
            converged = true;

        end
    end

    fprintf("FLAG %d converged in %d iterations. InitVal = %.2f | OptVal = %.2f\n", flag, i-1, npc(1), npc(i));
    U1(flag+2) = npc(i);
end


U1_Proposed = U1(2);
U1_Baseline = U1(1);
U1_WithoutAN = U1(3);


end