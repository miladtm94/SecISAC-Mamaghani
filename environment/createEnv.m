function  env = createEnv(params)

    %% 1. Define the 3D Grid Environment
    
    Llimit = params.limit(:,1);
    Ulimit = params.limit(:,2);
    N = params.missiontime;
    
    % Define state space: The UAV's position at timeslot n in the grid
    obsInfo = rlNumericSpec([5 1], 'LowerLimit', [Llimit;0;0], 'UpperLimit', [Ulimit;norm(Llimit-Ulimit);N]);
    obsInfo.Name = 'TrajectoryTime';
    obsInfo.Description = '(X, Y, Z, dis2End, time)';
    
    % Define action space: Six possible movements in 3D
    directionSet = 1:6;  % 1 = North, 2 = South, 3 = East, 4 = West, 5 = Up, 6 = Down
    speedLevel = 1:2;    % 1 = Low, 2 = High
    
    % Initialize action space
    actionSpace = cell(numel(directionSet) * numel(speedLevel), 1);
    
    % Fill action space with numeric action pairs
    index = 1;
    for i = 1:length(directionSet)
       for j = 1:length(speedLevel)
           actionSpace{index} = [directionSet(i), speedLevel(j)];
           index = index + 1;
       end
    end
    actionSpace{end+1} = [0, 0];

    % Define the finite action space using rlFiniteSetSpec
    actInfo = rlFiniteSetSpec(actionSpace);
    actInfo.Name = 'Action';
    actInfo.Description = 'Direction & speed level';

    % Create the environment with proper specs
    %env = rlFunctionEnv(obsInfo, actionInfo, @stepFunction, @resetFunction);

    % Create the environment using an anonymous function

    StepHandle = @(Action,Info) stepFunctionD(Action,Info,params);
    ResetHandle = @() resetFunction(params);

    env = rlFunctionEnv(obsInfo, actInfo, StepHandle, ResetHandle);

end




