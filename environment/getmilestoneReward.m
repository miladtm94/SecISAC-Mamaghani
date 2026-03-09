function reward_milestone = getmilestoneReward(q_current,q_next, n_next, params_milestone)

% Extracts params
[q_i, q_f, N] = params_milestone{:};

nextdist2end = norm(q_next - q_f); % Distance to goal
currdist2end = norm(q_current - q_f); % Distance to goal
max_dist = norm(q_i-q_f);

% Precompute the milestone positions and timestep indices
numMilestone = N;
milestonesVec = linspace(max_dist,0,numMilestone); % Directly calculate in ascending order

timestepVec = round(linspace(1, N, numMilestone));   % Timestep positions
% Only check if n_next is within timestepVec

% Calculate the gradual distance-based milestone reward
timeVec= logical(n_next-timestepVec);
distanceVec =  (abs(nextdist2end - milestonesVec) <= 0.1*abs(min(diff(milestonesVec))));

reward_milestone = any(timeVec & distanceVec);

if(reward_milestone~=0)
    fprintf("============================================\n" + ...
          "    #%d milestone(s) reached successfully   !\n" + ...
          "=============================================\n",sum(timeVec & distanceVec));
end
end
