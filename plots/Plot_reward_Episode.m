%% Extract and save trajectory data from experience buffer
clc;
clearvars -except rewardSet trajSet buffer Utility
close all;


% Parameters
agentNameList = ["DDQN", "PPO"];
lambdaVec = [0 0.5 1];
networkSelection = 1;

if ~exist('rewardSet', 'var') || ~exist('trajSet','var')
   disp('Loading trained results...');   
   for i = 1:length(lambdaVec)
        lambda = lambdaVec(i);
        agentSelection = 1;  % 1: DDQN, 2: PPO
        resultPath = getResultsFolderPath(agentSelection, lambda);
        fprintf("Loading trained agent for lambda = %0.2f ...\n", lambda);
        load(resultPath, "agent", "env", "trainingStats");   
        rewardSet{i} = trainingStats;

        filename1 = getEpisodeTrajName(lambda,networkSelection);

        trajSet{i} = load(filename1, "allVisitedPosition");

    end
end

% Load 'buffer' if not already loaded
if ~exist('buffer', 'var')
    load("data/myBuffer.mat", 'buffer');
end

if ~exist('Utility','var')

    Utility = zeros(length(lambdaVec), 1e3, 5);
    
    for i = 1:length(lambdaVec)
        lambda = lambdaVec(i);
        episodeTraj = trajSet{i}; % Extract the data for each series
        for j = 1:1e3
            traj = episodeTraj.allVisitedPosition(j).Positions; % Episode rewards for each training episode
            Utility(i,j,:) = calculate_utility(traj, buffer, lambda);
        end
    
    end

    

end

%%

% Parameters for plotting
% Expanded Color Set
colorSet = {"#0072BD", "#77AC30", "#A2142F", "#EDB120", "#7E2F8E", "#4DBEEE", "#D95319", "#FF00FF", "#00FFFF"};
% Colors: Blue, Green, Red, Yellow, Purple, Teal, Orange, Magenta, Cyan

% Corresponding RGB Values
color = [
    [0, 0.4470, 0.7410];   % Blue
    [0.4660, 0.6740, 0.1880]; % Green
    [0.6350, 0.0780, 0.1840]; % Red
    [0.8500, 0.3250, 0.0980]; % Orange
    [0.4940, 0.1840, 0.5560]; % Purple
    [0.3010, 0.7450, 0.9330]; % Teal
    [0.9290, 0.6940, 0.1250]; % Orange
    [1.0000, 0.0000, 1.0000]; % Magenta
    [0.0000, 1.0000, 1.0000]; % Cyan
];

lineStyleSet = {'-', '--', '-.', ':', '-'}; % Solid, Dashed, Dash-dot, Dotted, and Solid styles
% Define marker styles for each lambda
markers = {'o', '^', 'x', 'p', 's', 'd', 'v', 'h', '>', '<', '*'}; 
% Circle, Triangle up, Cross, Pentagon, Square, Diamond, Triangle down, Hexagon, Right triangle, Left triangle, Star

%%  Plot Cumulative Reward vs. Episode
% Create figure and axes
figure;

% Plot each data series with confidence interval and episode rewards
legendHandles = [];

for i = 1:length(lambdaVec)
    lambda = lambdaVec(i);
    data = rewardSet{i}(:); % Extract the data for each series
    episode_reward = data.EpisodeReward; % Episode rewards for each training episode
    
     % Calculate moving average for average reward  
    windowSize = 50; % Define the window size for moving average  
    average_reward = movmean(episode_reward, windowSize);  
    std_data = std(episode_reward, 0, 1); % Calculate std deviation over episodes
    time = data.EpisodeIndex; % Index of episodes
    
  % Plot episode rewards as a shaded area  
          % fill([time; (time)], [average_reward - std_data; (average_reward
    % +std_data)], ...,
    fill([time; flipud(time)], [movmin(episode_reward,5); flipud(movmax(episode_reward,5))], ...  
         [color(i,:)], ...
         'FaceAlpha', 0.1, ...
         'LineStyle',':', ...
         'EdgeColor', 'none'); % Shaded area for episode rewards  ); % Shaded area for episode rewards  

    hold on 
    h = plot(time, average_reward, ...
        'Color', colorSet{i}, 'LineWidth', 2, ...
        'DisplayName', sprintf('$\\lambda = %0.2f$', lambda)); % Average reward in solid line
    legendHandles = [legendHandles h];

end

% Customize plot labels and legend
legend(legendHandles,'Interpreter', 'latex', 'FontSize', 12, 'Location', 'southeast');
xlabel('Episode', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Reward', 'Interpreter', 'latex', 'FontSize', 12);

% Tight layout and final adjustments
axis tight;
grid on;
hold off;

%% Plot Player 1 and 2's interaction over episodes

% Create figure and axes
figure;

windowSize = 50; % Smoothing window size for moving average

for i = 1:length(lambdaVec)
    lambda = lambdaVec(i);
    subplot(3,1,i)
    hold on
    h1 = plot(1:1e3,(movmean(Utility(i,:,1),windowSize)), ...
        'Color', colorSet{i}, 'Marker', markers{i},'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'DisplayName', sprintf('Proposed, $\\lambda = %0.2f$', lambdaVec(i)),'MarkerIndices',1:20:1e3); % Average reward in solid line

    % h2 = plot(1:1e3,(movmean(Utility(i,:,2),windowSize)), ...
    %     'Color', 'k','LineStyle', lineStyleSet{i}, ...
    %     'LineWidth', 1.5, 'DisplayName', sprintf('Benchmark, $\\lambda = %0.2f$', lambdaVec(i)),'MarkerIndices',1:20:1e3); % Average reward in solid line
    legend(h1,'Interpreter', 'latex', 'FontSize', 12, 'Location', 'east');
    if (i==2)
        ylabel("Player 1's Utility (U1)", 'Interpreter', 'latex', 'FontSize', 14);
    end
    grid on
    hold off
end

% Customize plot labels and legend
xlabel("Episode", 'Interpreter', 'latex', 'FontSize', 12);



% Create figure and axes
figure;

windowSize = 50; % Smoothing window size for moving average

for i = 1:length(lambdaVec)
    lambda = lambdaVec(i);
    subplot(3,1,i)
    hold on
    h1 = plot(1:1e3,(movmean(Utility(i,:,3),windowSize)), ...
        'Color', colorSet{i}, 'Marker', markers{i},'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5,'MarkerIndices',1:20:1e3); % Average reward in solid line

    plot(1:1e3,(movmean(Utility(i,:,1),windowSize)), ...
    'Color', 'k','LineStyle', '-', ...
    'LineWidth', 1.5); % Average reward in solid line

    plot(1:1e3,(movmean(Utility(i,:,end),windowSize)), ...
    'Color', colorSet{4},'LineStyle', ':', ...
    'LineWidth', 1.5); % Average reward in solid line

    if (i==1)
        legend(["Player 2's Utility", "Player 1's Utility", "P_f" ],'Interpreter', 'latex', 'FontSize', 12, 'Location', 'east');
    end
    grid on
    hold off
end

% Customize plot labels and legend
xlabel("Episode", 'Interpreter', 'latex', 'FontSize', 12);
ylabel("Player 2's Utility (U2)", 'Interpreter', 'latex', 'FontSize', 14);


%%

% Create figure and axes
figure;

windowSize = 50; % Smoothing window size for moving average

% Plot U1
subplot(3, 1, 2)
hold on
for i = 1:length(lambdaVec)
    plot(1:1e3, movmean(Utility(i, :, 1), windowSize), ...
        'Color', colorSet{i}, 'Marker', markers{i}, 'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'MarkerIndices', 1:50:1e3); % Player 1's Utility
end
% Add legend to the last subplot
legend(["$\lambda = 0$", "$\lambda = 0.5$", "$\lambda = 1$"], 'Interpreter', 'latex', 'FontSize', 12, 'Location', 'northeast');

hold off
xlabel("Episode", 'Interpreter', 'latex', 'FontSize', 12);
ylabel("$U_1$", 'Interpreter', 'latex', 'FontSize', 14);
grid on

% Plot U2
subplot(3, 1, 1)
hold on
for i = 1:length(lambdaVec)
    plot(1:1e3, movmean(Utility(i, :, 3), windowSize), ...
        'Color', colorSet{i}, 'Marker', markers{i}, 'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'MarkerIndices', 1:50:1e3); % Player 2's Utility
end
% Add legend to the last subplot
legend(["$\lambda = 0$", "$\lambda = 0.5$", "$\lambda = 1$"], 'Interpreter', 'latex', 'FontSize', 12, 'Location', 'southeast');


hold off
xlabel("Episode", 'Interpreter', 'latex', 'FontSize', 12);
ylabel("$U_2$", 'Interpreter', 'latex', 'FontSize', 14);
grid on


% Plot Pf
subplot(3, 1, 3)

hold on
for i = 1:length(lambdaVec)
    plot(1:1e3, movmean(Utility(i, :, end), windowSize), ...
        'Color', colorSet{i}, 'Marker', markers{i}, 'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'MarkerIndices', 1:50:1e3); % P_f
end
% Add legend to the last subplot
legend(["$\lambda = 0$", "$\lambda = 0.5$", "$\lambda = 1$"], 'Interpreter', 'latex', 'FontSize', 12, 'Location', 'northeast');


hold off
xlabel("Episode", 'Interpreter', 'latex', 'FontSize', 12);
ylabel("$P_f$", 'Interpreter', 'latex', 'FontSize', 14);
grid on



