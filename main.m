%% main.m  —  Secure ISAC UAV Trajectory Design via DDQN
% =========================================================================
%  Entry point for training and simulating the DDQN-based UAV trajectory
%  optimisation agent.
%
%  USAGE
%  -----
%    1. Run setup.m once per MATLAB session to configure all paths.
%    2. Adjust the control flags in Section 0 below.
%    3. Run this script (F5 or >> main).
%
%  KEY PARAMETERS
%  ----------------------------
%    doTraining      1  → initial training from scratch
%                    2  → resume training from saved checkpoint
%                    3  → skip training, load saved agent only
%
%    doSimulation    1  → simulate trained agent and plot trajectory
%                    0  → skip simulation
%
%    lambda          reward trade-off weight:
%                      0     → maximise communication/sensing utility U1
%                      1     → minimise flight power P_f
%                      (0,1) → (1-lambda)*U1 - lambda*P_f
%
%    networkSelection  1 → Proposed (smart): uses SCA-optimised resources
%                      0 → Benchmark (dumb): uses initial/unoptimised resources
%
%    withObstacle    1 → include obstacle avoidance constraints
%                    0 → obstacle-free environment
%
%  DATA DEPENDENCIES  (place in data/ folder before running)
%  ----------------------------------------------------------
%    myBuffer.mat              pre-computed optimal resources per UAV location
%    myGroundTerminalDist.mat  BS, uplink and downlink user locations
%    ObstacleLocs.mat          obstacle positions and radii
% =========================================================================

%% Housekeeping
clc
clearvars -except buffer groundTerminalsLoc obstacles obstacleRadius
close all

%% 1. Load system and MDP parameters
sysParams            % system-level constants        (config/sysParams.m)
MDPsimulationParams  % gridworld / MDP definitions  (config/MDPsimulationParams.m)
rng(0)               % fix random seed for reproducibility

% Ground terminal locations
if ~exist('groundTerminalsLoc', 'var')
    disp('Loading groundTerminalsLoc...');
    load(fullfile('data', 'myGroundTerminalDist.mat'), 'groundTerminalsLoc');
else
    disp('groundTerminalsLoc already in workspace.');
end

% Pre-computed resource buffer
if ~exist('buffer', 'var')
    disp('Loading buffer...');
    load(fullfile('data', 'myBuffer.mat'), 'buffer');
else
    disp('buffer already in workspace.');
end

[BS_location, uplink_users, downlink_users] = groundTerminalsLoc{:};

%% =====================  CONTROL FLAGS  ===================================
doTraining       = 1;    % 1: initial | 2: resume | 3: load only
doSimulation     = 1;    % 1: simulate after training | 0: skip

lambda           = 0.5;  % trade-off weight in {0, 0.5, 1}
networkSelection = 1;    % 1: proposed (smart) | 0: benchmark (dumb)
withObstacle     = 1;    % 1: with obstacles | 0: without

maxStep_init    = 1e3;   % episodes for initial training
maxStep_further = 2e3;   % episodes for resumed training
%% ==========================================================================

global episodeCount
episodeCount = 0;

%% 2. Build environment parameter struct
params.lambda           = lambda;
params.buffer           = buffer;
params.limit            = [Llimit, Ulimit];
params.missiontime      = N;
params.initLoc          = q_i;
params.finalLoc         = q_f;
params.mobility         = [v_max_x, v_max_y, v_max_z, delta_t];
params.regionRadius     = regionRadius;
params.data             = normalize([buffer(:).U1], 'range');
params.networkSelection = networkSelection;

resultPath = getResultsFolderPath(networkSelection, lambda);
params.filename = getEpisodeTrajName(lambda, networkSelection);

% Obstacle data
if withObstacle
    if ~exist('obstacles', 'var') || ~exist('obstacleRadius', 'var')
        disp('Loading obstacle data...');
        load(fullfile('data', 'ObstacleLocs.mat'), 'obstacles', 'obstacleRadius');
    else
        disp('Obstacle data already in workspace.');
    end
    params.obstacleLocs   = obstacles;
    params.obstacleRadius = obstacleRadius;
else
    params.obstacleLocs = [];
end

% Create MDP environment and DDQN agent
env   = createEnv(params);      % environment/createEnv.m
agent = createDDQNAgent(env);   % agent/createDDQNAgent.m

%% 3. Train or load the DDQN agent
if doTraining == 1
    % Initial training from scratch
    trainOpts = rlTrainingOptions;
    trainOpts.MaxEpisodes               = maxStep_init;
    trainOpts.MaxStepsPerEpisode        = N;
    trainOpts.ScoreAveragingWindowLength = 5;
    trainOpts.StopTrainingCriteria      = 'AverageSteps';
    trainOpts.Verbose                   = true;
    trainOpts.Plots                     = 'training-progress';
    trainOpts.StopOnError               = 'on';

    fprintf('\n####################\nStarting DDQN training (initial)...\n')
    trainingStats = train(agent, env, trainOpts);
    fprintf('####################\nTraining complete.\n')

    try
        save(resultPath, 'agent', 'env', 'trainingStats', '-v7.3');
        fprintf('Saved to: %s\n', resultPath)
    catch ME
        fprintf('Save error: %s\n', ME.message); rethrow(ME);
    end

elseif doTraining == 2
    % Resume / further training
    fprintf('\n####################\nResuming DDQN training...\n')
    load(resultPath, 'agent', 'env', 'trainingStats');
    trainingStats.TrainingOptions.MaxEpisodes = maxStep_further;
    trainingStats = train(agent, env, trainingStats);

    try
        save(resultPath, 'agent', 'env', 'trainingStats', '-v7.3');
        fprintf('Saved to: %s\n', resultPath)
    catch ME
        fprintf('Save error: %s\n', ME.message); rethrow(ME);
    end

else
    % Load saved agent only
    fprintf('\n####################\nLoading trained agent: %s\n', resultPath)
    load(resultPath, 'agent', 'env', 'trainingStats');
end

%% 4. Simulate trained agent
if doSimulation
    if isprop(agent, 'UseExplorationPolicy')
        agent.UseExplorationPolicy = false;  % deterministic greedy policy
    end

    simOpts = rlSimulationOptions('MaxSteps', N, 'StopOnError', 'on');
    fprintf('\n####################\nRunning simulation...\n')
    experience = sim(env, agent, simOpts);

    % Extract (x, y, z) trajectory
    trajectory = squeeze(experience.Observation.TrajectoryTime.Data);
    trajectory = trajectory(1:3, :);

    % Visualise
    figure;
    visualize_system_obstacle(BS_location, uplink_users, downlink_users, params);
    hold on;
    plot3(trajectory(1,:), trajectory(2,:), trajectory(3,:), ...
          '>-k', 'MarkerSize', 5, 'DisplayName', 'UAV Trajectory');
    hold off;
    title(sprintf('DDQN Trajectory  (\\lambda = %.2f)', lambda));

    % Constraint check
    if ~checkTrajConstraints(trajectory, params)
        disp('All trajectory constraints satisfied.');
    else
        warning('Some trajectory constraints were violated.');
    end
end
