clc
clearvars -except buffer trajSet Utility

% Parameters for plotting
% Expanded Color Set
colorSet = {"#0072BD", "#77AC30", "#A2142F", "#EDB120", "#7E2F8E", "#4DBEEE", "#D95319", "#FF00FF", "#00FFFF"};
% Colors: Blue, Green, Red, Yellow, Purple, Teal, Orange, Magenta, Cyan

% Corresponding RGB Values
color = [
    [0, 0.4470, 0.7410];   % Blue
    [0.4660, 0.6740, 0.1880]; % Green
    [0.6350, 0.0780, 0.1840]; % Red
    [0.8500, 0.3250, 0.0980]; % Yellow/Orange
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


lambdaVec = [0 0.5 1];
networkSelection = [1,0];

% Load 'buffer' if not already loaded
if ~exist('buffer', 'var')
    disp('Loading buffer ...');   
    load("data/myBuffer.mat", 'buffer');
end

if ~exist('trajSet', 'var')
    disp('Performing  processing ...');   
    for i = 1:length(networkSelection)
        for j = 1 : length(lambdaVec)
            lambda = lambdaVec(j);
            filename1 = getEpisodeTrajName(lambda,networkSelection);
    
            trajSet{i+j-1} = load(filename1, "allVisitedPosition");
        end
    end
    Utility = zeros(length(networkSelection),length(lambdaVec), 1e3);
    for i = 1:length(networkSelection)
         for j = 1 : length(lambdaVec)
            lambda = lambdaVec(j);
            episodeTraj = trajSet{i+j-1}; % Extract the data for each series
            for k = 1:1e3
                traj = episodeTraj.allVisitedPosition(k).Positions; % Episode rewards for each training episode
                temp = calculate_utility(traj, buffer, lambda);
                if (i==1)
                    Utility(i, j, k)= temp(1);
                else
                    Utility(i, j, k)= temp(2);
                end
            end
         end
    end  

    save('DumbSmartTraj.mat', 'trajSet','Utility')

else
    disp('Loading results ...');   
    load('DumbSmartTraj.mat', 'trajSet','Utility')
end



%% Create figure and axes
close all
figure (2);

windowSize = 50; % Smoothing window size for moving average

% Create a tiled layout for better arrangement
t = tiledlayout(3, 1, 'TileSpacing', 'Compact', 'Padding', 'Compact'); % 3 rows, 1 column

for i=1:length(lambdaVec)
    nexttile;
% Check if the value is an integer
    if mod(lambdaVec(i), 1) == 0
        % If it's an integer
        label1 = sprintf('Proposed, $\\lambda = %d$', lambdaVec(i));
        label2 = sprintf('Benchmark, $\\lambda = %d$', lambdaVec(i));
    else
        % If it's a float
        label1 = sprintf('Proposed, $\\lambda = %.2f$', lambdaVec(i));
        label2 = sprintf('Benchmark, $\\lambda = %.2f$', lambdaVec(i));
    end

    if (i==1)
        Pmax_flight = 607.9678;
         h1 = plot(1:1e3,Pmax_flight*abs((movmean(squeeze(Utility(1,i, 1:1e3))/1e3,windowSize))), ...
        'Color', colorSet{i}, 'Marker', markers{i},'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'DisplayName', label1,'MarkerIndices',1:50:1e3); % Average reward in solid line
    hold on
    
    h2 = plot(1:1e3,Pmax_flight*abs((movmean(squeeze(Utility(2,i, 1:1e3))/1e3,windowSize))), ...
        'Color', 'k','LineStyle', '--', ...
        'LineWidth', 1.5, 'DisplayName', label2,'MarkerIndices',1:50:1e3); % Average reward in solid line

        ylabel("$P_f$ [kW]", 'Interpreter', 'latex', 'FontSize', 14);
  
    
    elseif (i==3)
        rescale1 =5.2190e+03;
        rescale2=2.0662e+07;
          h1 = semilogy(1:1e3,rescale1*abs((movmean(squeeze(Utility(1,i, 1:1e3))/1e3,windowSize))), ...
        'Color', colorSet{i}, 'Marker', markers{i},'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'DisplayName', label1,'MarkerIndices',1:50:1e3); % Average reward in solid line
    hold on
    
    h2 = semilogy(1:1e3,rescale2*abs((movmean(squeeze(Utility(2,i, 1:1e3))/1e3,windowSize))), ...
        'Color', 'k','LineStyle', '--', ...
        'LineWidth', 1.5, 'DisplayName', label2,'MarkerIndices',1:50:1e3); % Average reward in solid line

        ylabel("$U_1$ [kW]", 'Interpreter', 'latex', 'FontSize', 14);

    
    
    else
            h1 = plot(1:1e3,((movmean(squeeze(Utility(1,i, 1:1e3))/1e3,windowSize))), ...
        'Color', colorSet{i}, 'Marker', markers{i},'LineStyle', lineStyleSet{i}, ...
        'LineWidth', 1.5, 'DisplayName', label1,'MarkerIndices',1:50:1e3); % Average reward in solid line
    hold on
    
    h2 = plot(1:1e3,((movmean(squeeze(Utility(2,i, 1:1e3))/1e3,windowSize))), ...
        'Color', 'k','LineStyle', '--', ...
        'LineWidth', 1.5, 'DisplayName', label2,'MarkerIndices',1:50:1e3); % Average reward in solid line

        ylabel("$\bar{U}_2$", 'Interpreter', 'latex', 'FontSize', 14);


    
    end


    legend([h1, h2],'Interpreter', 'latex', 'FontSize', 12, 'Location', 'southeast');
    grid on

end
% Customize plot labels and legend
xlabel("Episode", 'Interpreter', 'latex', 'FontSize', 12);
