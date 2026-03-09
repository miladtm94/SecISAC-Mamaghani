%% Extract and save trajectory data from experience buffer
clc;
clearvars -except buffer groundTerminalsLoc obstacles obstacleRadius trajectorySet lambdaVec;
close all;

sysParams;

networkSelection = 1;
% Load 'groundTerminalsLoc' if not already loaded
if ~exist('groundTerminalsLoc', 'var')
    load('myGroundTerminalDist.mat', 'groundTerminalsLoc');
end

% Load 'buffer' if not already loaded
if ~exist('buffer', 'var')
    load("data/myBuffer.mat", 'buffer');
end

 if ~exist('obstacles', 'var') || ~exist('obstacleRadius', 'var')
        disp('Loading variables from ObstacleLocs.mat...');
        load('ObstacleLocs.mat', 'obstacles', 'obstacleRadius');
    else
        disp('Variables "obstacles" and "obstacleRadius" are already loaded.');
 end

[BS_location, uplink_users, downlink_users] = groundTerminalsLoc{:};

if ~exist('trajectorySet', 'var')

% Parameters
lambdaVec = [0, 0.5, 1];
trajectorySet = cell(1, length(lambdaVec));

% Extract trajectory data and save
for i = 1:length(lambdaVec)
    lambda = lambdaVec(i);
    resultPath = getResultsFolderPath(networkSelection, lambda);
    fprintf("Loading trained agent for lambda = %0.2f ...\n", lambda);
    load(resultPath, "agent", "env", "trainingStats");

    % Disable exploration for deterministic policy during simulation
    if isprop(agent, 'UseExplorationPolicy')
        agent.UseExplorationPolicy = false;
    end

    % Set up simulation options
    simOpts = rlSimulationOptions('MaxSteps', N, 'StopOnError', 'on');

    % Run the simulation to get experience data
    experience = sim(env, agent, simOpts);

    % Extract and store trajectory data
    trajectory = squeeze(experience.Observation.TrajectoryTime.Data);
    trajectorySet{i} = trajectory(1:3, :);
end

% Save the extracted trajectories to a .mat file
save('data/trajectorySet.mat', 'trajectorySet', 'lambdaVec');
fprintf("Trajectory data saved successfully.\n");
end

%% Plot Trajectories learned throught he experience

% Parameters for plotting
% Expanded Color Set
colorSet = {"#0072BD", "#77AC30", "#A2142F", "#EDB120", "#7E2F8E", "#4DBEEE", "#D95319", "#FF00FF", "#00FFFF"};
% Colors: Blue, Green, Red, Yellow, Purple, Teal, Orange, Magenta, Cyan

lineStyleSet = {'-', '--', '-.', ':', '-'}; % Solid, Dashed, Dash-dot, Dotted, and Solid styles
% Define marker styles for each lambda
markers = {'o', '^', 'x', 'p', 's', 'd', 'v', 'h', '>', '<', '*'}; 
% Circle, Triangle up, Cross, Pentagon, Square, Diamond, Triangle down, Hexagon, Right triangle, Left triangle, Star

% lambdaVec = [0, 0.5, 1];

% Visualize the system with obstacles
figure;

% lambda=0  maximize U1, 
% lambda=1 minimze Pf, 
% 0<lambda<1:  maximize (1-lambda)U1 - lambda Pf
params.limit = [Llimit, Ulimit];
params.missiontime = N;
params.initLoc =q_i;
params.finalLoc = q_f;
params.mobility= [v_max_x, v_max_y, v_max_z, delta_t];
params.regionRadius = regionRadius;
params.obstacleLocs = obstacles;
params.obstacleRadius = obstacleRadius;


visualize_system_obstacle(BS_location, uplink_users, downlink_users, params);
hold on;

% Initialize an empty array for legend entries
legendHandles = [];

% Plot each trajectory from the loaded data
for i = 1:length(lambdaVec)
    lambda = lambdaVec(i);
    params.lambda = lambda;  

    trajectory = trajectorySet{i};

    % Plot the trajectory with distinct line and marker styles
    if mod(lambda, 1) == 0
        aa = sprintf('$\\lambda = %d$', lambda); % Format as integer
    else
        aa = sprintf('$\\lambda = %0.2f$', lambda); % Format as float
    end
    h = plot3(trajectory(1,:), trajectory(2,:), trajectory(3,:), ...
        'Color', colorSet{i}, ...
        'LineStyle', lineStyleSet{i}, ...
        'Marker', markers{i}, ...
        'Marker', markers{i},...
        'MarkerSize', 6, ...
        'LineWidth', 1.5, ...
        'DisplayName', aa);

    legendHandles = [legendHandles, h];


    % Check constraints
    violations = checkTrajConstraints(trajectory,params);
    if ~violations
        disp('All constraints are satisfied.');
    else
        disp('Some constraints are violated.');
    end


end
% Add Legends and Labels
legend(legendHandles, 'Interpreter', 'latex', 'FontSize', 12, 'Location', 'north');

hold off;
xlabel('x [m]', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('y [m]', 'Interpreter', 'latex', 'FontSize', 14);
zlabel('z [m]', 'Interpreter', 'latex', 'FontSize', 14);
grid on;
set(gca, 'FontSize', 12);

%%  Preprocessing of data 

% Initialize variables

% v_xy = zeros(length(lambdaVec), N);
% v_x = zeros(length(lambdaVec), N);
% v_y = zeros(length(lambdaVec), N);
% v_z = zeros(length(lambdaVec), N);
% P_f = zeros(length(lambdaVec), N);
% U1 = zeros(length(lambdaVec), N);
% U2 = zeros(length(lambdaVec), N);
% SumP = zeros(length(lambdaVec), N);
% SumVk = zeros(length(lambdaVec), N);
% SumW = zeros(length(lambdaVec), N);

Pmax_flight = 607.9678;

for i = 1:length(lambdaVec)
    lambda = lambdaVec(i); 
    trajectory = trajectorySet{i};

    for n=1:size(trajectory,2)-1
        q_current = trajectory(:,n);
        q_next = trajectory(:,n+1);
    
        % Flight Power Consumption
        normv_xy = norm([q_next(1) - q_current(1), q_next(2) - q_current(2)]); % Velocity in x-y plane
        normv_z = abs(q_next(3) - q_current(3)); % Velocity in z-direction
        
        v_x(i,n) = q_next(1) - q_current(1);  % timestep == 1
        v_y(i,n) = q_next(2) - q_current(2);
        v_z(i,n) = q_next(3) - q_current(3);

        P_f(i,n) = flightPow(normv_xy, normv_z); % Compute power consumption based on velocity components
    
        eve_key = eveLocationKey(q_next);
        index = find(strcmp({buffer.Evekeys}, eve_key), 1);
        
        % Objective function of Player 1
        U1(i, n) = buffer(index).U1;
        
        power_opt = buffer(index).params(2);
        SumP(i,n) = sum(cell2mat(power_opt{:}(1)));
        SumVk(i,n) = trace(sum(cell2mat(power_opt{:}(2)),3));
        SumW(i,n) =  trace(cell2mat(power_opt{:}(3)));

        power_init = buffer(index).params(1);
        SumP_init = sum(cell2mat(power_init{:}(1)));
        SumVk_init = trace(sum(cell2mat(power_init{:}(2)),3));
        SumW_init=  trace(cell2mat(power_init{:}(3)));
        U1_init(i, n) = SumP_init + SumVk_init + SumW_init;
        
        % Objective function of Player 2
        U2(i, n) =  abs(lambda* U1(i, n) - (1-lambda) * P_f(i,n));
        U2_init(i, n) =  abs(lambda* U1_init(i, n) - (1-lambda) * P_f(i,n));

        % Retrieve cached values
        metrics = buffer(index).metrics;
        UCSR(i,n) = buffer(index).metrics(1);
        DCSR(i,n) = buffer(index).metrics(2);
        CRLB(i,n) = buffer(index).metrics(3);

    end

end

%% Plot 3: UCSR DCSR CRLB vs. TimeStep

figure;

legendHandles = [];


hold on;
for i = 1:length(lambdaVec)
     N= size(UCSR(i, :),2);
     plot(1:N, (UCSR(i, :)), 'Color', colorSet{i}, 'Marker', markers{i},'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'DisplayName', sprintf('$\\lambda = %0.2f$', lambdaVec(i)),'MarkerIndices',1:6:N);

end
hold off;
ylabel("UCSR [bps/Hz]", 'Interpreter', 'latex', 'FontSize', 14);
grid on;

xlabel('Timeslot ($n$)', 'Interpreter', 'latex', 'FontSize', 14);

% Show legend only in the last subplot (third one)
legend(legendHandles,'Interpreter', 'latex', 'FontSize', 12, 'Location', 'best');

 

%% Plot 4: Velocity and Flight power vs. Step


% Plot 1: Velocity in x direction vs. Step
figure
subplot(4, 1, 1);
hold on;
for i = 1:length(lambdaVec)
    stem(1:N, v_x(i, :), 'Color', colorSet{i}, 'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'Marker', markers{i}, ...
        'DisplayName', sprintf('$\\lambda = %0.2f$', lambdaVec(i)));
end
xlim([1,N])
ylim([-20,20])
hold off;
ylabel('$v_x$ [$m/s$]', 'Interpreter', 'latex', 'FontSize', 12);
grid on;

% Plot 2: Velocity in y direction vs. Step
subplot(4, 1, 2);
hold on;
legendHandles = [];

for i = 1:length(lambdaVec)
    h = stem(1:N, v_y(i, :), 'Color', colorSet{i}, 'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'Marker',markers{i}, ...
        'DisplayName', sprintf('$\\lambda = %0.2f$', lambdaVec(i)));

end
xlim([1,N])
ylim([-20,20])
hold off;
ylabel('$v_y$ [$m/s$]', 'Interpreter', 'latex', 'FontSize', 12);
grid on;
xlim([1,N])

% Plot 3: Velocity in z direction vs. Step
subplot(4, 1, 3);
hold on;
for i = 1:length(lambdaVec)
    stem(1:N, v_z(i, :), 'Color', colorSet{i}, 'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'Marker', markers{i}, ...
        'DisplayName', sprintf('$\\lambda = %0.2f$', lambdaVec(i)));

end
hold off;
xlabel('Timeslot ($n$)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('$v_z$ [$m/s$]', 'Interpreter', 'latex', 'FontSize', 12);
grid on;
xlim([1,N])
ylim([-10,10])

% Plot 3: Cumulative Flight Power Consumption (P_f) vs. Step
subplot(4, 1, 4);
hold on;
for i = 1:length(lambdaVec)
     h = plot(1:N, cumsum(P_f(i, :))/1000, 'Color', colorSet{i}, 'Marker', markers{i},'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'DisplayName', sprintf('$\\lambda = %0.2f$', lambdaVec(i)), 'MarkerIndices',1:7:N);
         legendHandles = [legendHandles h];

end
hold off;
xlabel('Timeslot ($n$)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel("$\sum P_f$ [kW]", 'Interpreter', 'latex', 'FontSize', 14);
grid on;
xlim([1,N])


% Only show legend in the last subplot (third one)
subplot(4, 1, 4);
legend(legendHandles,'Orientation','horizontal' ,'Interpreter', 'latex', 'FontSize', 12, 'Location', 'best');

%% Plot 5: Cumulative utility vs. Step

% Create figure and set properties
figure;


legendHandles = [];

% Plot 1: Cumulative SumP
subplot(3, 1, 1);
hold on;
for i = 1:length(lambdaVec)
    h = plot(1:N, db(cumsum(SumP(i, :))), 'Color', colorSet{i}, 'Marker', markers{i}, ...
         'LineStyle', lineStyleSet{i}, 'LineWidth', 1.5, ...
         'DisplayName', sprintf('$\\lambda = %0.2f$', lambdaVec(i)), ...
         'MarkerIndices', 1:6:N);
    legendHandles = [legendHandles, h];
end
xlim([1, N]);
title('Cumulative power allocated to UL transmissions [dBW]', 'Interpreter','latex', 'FontSize', 14)

ylabel('$\sum_L p_l$', 'Interpreter', 'latex', 'FontSize', 14);
grid on;
hold off;

% Plot 2: Cumulative SumVk
subplot(3, 1, 2);
hold on;
for i = 1:length(lambdaVec)
    plot(1:N, db(cumsum(SumVk(i, :))), 'Color', colorSet{i}, 'Marker', markers{i}, ...
         'LineStyle', lineStyleSet{i}, 'LineWidth', 1.5, ...
         'DisplayName', sprintf('$\\lambda = %0.2f$', lambdaVec(i)), ...
         'MarkerIndices', 1:6:N);
end
xlim([1, N]);
title('Cumulative power allocated to DL beamforming [dBW]', 'Interpreter','latex', 'FontSize', 14)
ylabel('$\sum_k \mathrm{tr}(V_k)$', 'Interpreter', 'latex', 'FontSize', 14);
grid on;
hold off;

% Plot 3: Cumulative SumW
subplot(3, 1, 3);
hold on;
for i = 1:length(lambdaVec)
    plot(1:N, db(cumsum(SumW(i, :))), 'Color', colorSet{i}, 'Marker', markers{i}, ...
         'LineStyle', lineStyleSet{i}, 'LineWidth', 1.5, ...
         'DisplayName', sprintf('$\\lambda = %0.2f$', lambdaVec(i)), ...
         'MarkerIndices', 1:6:N);
end
xlim([1, N]);
xlabel('Timeslot ($n$)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('$\mathrm{tr}(W)$', 'Interpreter', 'latex', 'FontSize', 14);
title('Cumulative power allocated to Sensing beamforming (dBW)', 'Interpreter','latex', 'FontSize', 14)
grid on;

% Only show legend in the last subplot (third one)
subplot(3, 1, 1);

legend(legendHandles,'Interpreter', 'latex', 'FontSize', 12, 'Location', 'best');
hold off;





%% Plot 7: Cumulative Player 2's Utility (U1) vs. Step

figure;


plot(lambdaVec, db(sum(U2,2)), 'Marker', 's','LineStyle','-', ...
        'LineWidth', 1.5);
hold on;

plot(lambdaVec, db(sum(U2_init,2)),'LineStyle', ':','Marker', 'diamond', ...
        'LineWidth', 1.5);

legend('Proposed','Benchmark' ,'Interpreter', 'latex', 'FontSize', 12, 'Location', 'northeast');
ylabel("Magnitude of Player 2's Utility [kW]", 'Interpreter', 'latex', 'FontSize', 14);
xlabel('Scaling factor ($\lambda$)', 'Interpreter', 'latex', 'FontSize', 14);
grid on

