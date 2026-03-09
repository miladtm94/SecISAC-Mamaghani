function agent = createDDQNAgent(env)

%% Extract environment action and observation specs
    obsInfo = env.getObservationInfo();
    actInfo = env.getActionInfo();

%% 2. Define the DQN Agent using RNN
% Create the DQN agent

net = [
featureInputLayer(prod(obsInfo.Dimension))
fullyConnectedLayer(16)
reluLayer
fullyConnectedLayer(8)
reluLayer
fullyConnectedLayer(numel(actInfo.Elements))];

net = dlnetwork(net);

   
% Create the Q-value (critic) representation
critic = rlVectorQValueFunction(net,obsInfo,actInfo);
% getValue(critic,{rand(obsInfo.Dimension)})

criticOptions = rlOptimizerOptions( ...
'LearnRate',1e-3);


% Define the epsilon-greedy exploration options
epsilonGreedyExploration = rl.option.EpsilonGreedyExploration(...
    'Epsilon', 1, ...         % Initial epsilon
    'EpsilonDecay', 1e-3, ...   % Decay factor for epsilon
    'EpsilonMin', 0.01);         % Minimum epsilon value

% Define the DQN agent options
agentOpts = rlDQNAgentOptions(...
    'UseDoubleDQN', true, ...
    'TargetSmoothFactor', 1e-2, ...
    'DiscountFactor', 0.99, ...
    'MiniBatchSize', 64, ...,
    'ExperienceBufferLength', 1e6,...
    'EpsilonGreedyExploration', epsilonGreedyExploration,...
    'TargetUpdateFrequency', 5,...
    'CriticOptimizerOptions',criticOptions);

% Create the DQN agent
agent = rlDQNAgent(critic, agentOpts);
% getAction(agent,rand(obsInfo.Dimension))


end