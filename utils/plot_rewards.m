function plot_rewards(data_list, min_len)
    % Set up colors and labels
    colors = {[1, 0, 0], [0, 0, 0], [0, 1, 0], [0, 0, 1], [0.5, 0, 0.5]}; % RGB colors
    labels = {'DDQN', 'PPO'};
    
    % Create figure and axes
    figure;
    hold on;
    set(gcf, 'Color', 'w'); % Set background to white
    set(gca, 'Box', 'off'); % Remove top and right borders
    set(gca, 'LineWidth', 1, 'FontSize', 16); % Thicker axis lines

    % Plot each data series with confidence interval and episode rewards
    for i = 1:length(data_list)
        data = data_list(i); % Extract the data for each series
        episode_reward = data.episode_reward; % Episode rewards for each training episode
        average_reward = data.average_reward; % Average reward over episodes
        episode_index = data.episode_index; % Index of episodes
        
        % Ensure data length does not exceed min_len
        time = episode_index(1:min_len); % Define time range
        episode_reward = episode_reward(1:min_len);
        avg_data = average_reward(1:min_len); % Restrict avg data to min_len
        std_data = std(episode_reward, 0, 2); % Calculate std deviation over episodes
        
        % Fill for confidence interval
        fill([time; fliplr(time)], [avg_data - 1.96*std_data; flipud(avg_data + 1.96*std_data)], ...
             colorSet{i}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        
        % Plot episode rewards and average line
        plot(time, episode_reward, ':', 'Color', colors{i}, 'LineWidth', 1); % Episode reward in dotted line
        plot(time, avg_data, 'Color', colors{i}, 'LineWidth', 1.5); % Average reward in solid line
    end

    % Customize plot labels and legend
    xlabel('Training Episodes $(\times10^6)$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('Reward', 'FontSize', 12);
    xlim([0, min_len]);
    legend(labels, 'FontSize', 10, 'Location', 'best', 'Box', 'off');
    title('Reward Progression Across Episodes', 'FontSize', 14);

    % % Customize x-axis tick labels
    % xticks([10, 20, 30, 40, 50]);
    % xticklabels({'0.5', '1.0', '1.5', '2.0', '2.5'});

    % Tight layout and final adjustments
    axis tight;
    grid on;
    hold off;
end
