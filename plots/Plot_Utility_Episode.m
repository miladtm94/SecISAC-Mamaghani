clc
clearvars -except buffer trajSet


lambdaVec = [0 0.5 1];
networkSelection = [1,1,0];

% Load 'buffer' if not already loaded
if ~exist('buffer', 'var')
    disp('Loading buffer ...');   
    load("~/GitHub/SecureISAC/data/myBuffer.mat", 'buffer');
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
end

Utility = zeros(length(networkSelection),length(lambdaVec), 1e3);

for i = 1:length(networkSelection)
     for j = 1 : length(lambdaVec)
        lambda = lambdaVec(j);
        episodeTraj = trajSet{i+j-1}; % Extract the data for each series
        for k = 1:1e3
            traj = episodeTraj.allVisitedPosition(k).Positions; % Episode rewards for each training episode
            temp = Calc_Utility_Updated(traj, lambda);
            if (i==1)
                Utility(:, j, k)= temp(1);
            elseif (i==2)
                Utility(i, j, k)= temp(2);
            else
                Utility(i, j, k)= temp(3);
            end
        end
     end
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
        label2 = sprintf('Without AN, $\\lambda = %d$', lambdaVec(i));
        label3 = sprintf('Baseline, $\\lambda = %d$', lambdaVec(i));

    else
        % If it's a float
        label1 = sprintf('Proposed, $\\lambda = %.1f$', lambdaVec(i));
        label2 = sprintf('Without AN, $\\lambda = %.1f$', lambdaVec(i));
        label3 = sprintf('Baseline, $\\lambda = %.1$', lambdaVec(i));

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
