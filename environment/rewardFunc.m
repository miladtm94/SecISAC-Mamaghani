%% Reward function
function     Reward = rewardFunc(q_current, q_next, n_next,IsDone, params, flags)

% load parameters
N = params.missiontime;
q_f = params.finalLoc;
q_i = params.initLoc;
v_max_x= params.mobility(1);
v_max_y= params.mobility(2);
v_max_z= params.mobility(3);
delta_t =params.mobility(4);
networkSelection = params.networkSelection;

% eta4 = 1;   % scaling for main objective
% eta5 = 1; %scaling the milestone reward
% decay_factor = exp(-5*(1 - (N - n_next)/N)); % to balance ending mission and reducing main metric
GoalReward = +100; % Reward for reaching the goal
FailurePenalty = -10; % Penalty for mission failure or constraint violation
Reward = 0;
time_factor = n_next/N; % Exponential decay factor (might decay faster)
nextdist2end = norm(q_next - q_f); % Distance to goal
currdist2end = norm(q_current - q_f); % Distance to goal
max_dist = norm(q_i-q_f);

%% Calculate rewar-shaping components
eta1 = 10;  % main reward coeff: 
% (1-lambda)* Pf  lambda * U1 
% Pf is normalized by max and ranges [0,1])
% U1 is also normalized by max and ranges [0,1]
% lambda is another scaling coeff ranges  [0,1]
eta2 = 2;  % distance penalty factor x (-1 ... -2)
eta3 = 1;  % loop penalty factor  x (-1 ... -2)

main_reward = getMainReward(q_current,q_next, params, networkSelection); 
distance_penalty = - (nextdist2end/max_dist);

loop_penalty = 0;
if flags.loop
    loop_penalty =  - (1 + flags.loopSize/N);  
end

Reward = eta1 * (1 - time_factor) * main_reward ... 
       + eta2 * (1 + time_factor) * distance_penalty  ...
       + eta3 * loop_penalty;

%%
if (~IsDone)
   % Main penalty: Initialize reward with utility function
    fprintf("(+) Main reward: %0.2f.\n", eta1* (1 - time_factor) *main_reward);
    fprintf("(-) Distance penalty: %0.2f\n", eta2 * (1 + time_factor) * distance_penalty);
    if flags.loop
        fprintf("(-) Backtracking detected: %0.2f; Loop size: %d; " + ...
            "Loop sequence: %s\n",eta3 *loop_penalty, flags.loopSize, flags.loopSeq);
    end
    if flags.boundary
        Reward =  Reward + FailurePenalty;
        fprintf("(-) Boundary violation: %0.2f\n", FailurePenalty); 
    elseif flags.collision
        Reward = Reward + FailurePenalty; % Obstacle collision penalty
        fprintf("(-) Obstacle collision: %0.2f\n", FailurePenalty);
    end


    fprintf("(T) Scaled Reward received: %0.2f\n", Reward);
else
%% If mission has not ended
    if (flags.distance)
        fprintf("==============================================\n" + ...
                "|(+) Mission accomplished successfully, yaay!|\n" + ...
                "==============================================\n");
        Reward =  Reward + GoalReward; % Big reward for finishing on time
    else
        Reward = Reward  + FailurePenalty;
        fprintf("(-) Mission failed :( %0.2f\n", Reward);
    end
end

end