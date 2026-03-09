function visualize_system_obstacle(R_BS_location, uplink_users, downlink_users, params)
    % Visualize the communication system in 3D with obstacleLocs
    % R_BS_location: 1x3 vector for R-BS location [x, y, z]
    % uplink_users: Lx3 matrix for uplink user locations [x, y, z]
    % downlink_users: Kx3 matrix for downlink user locations [x, y, z]
    % q_i: 1x3 vector for UAV start location [x, y, z]
    % q_f: 1x3 vector for UAV end location [x, y, z]
    % regionRadius: radius of the end region
    % numObstacles: number of obstacleLocs
    % obstacleRadius: radius of each obstacle


    q_i = params.initLoc;
    q_f = params.finalLoc;
    regionRadius = params.regionRadius;
    

    sysParams;
    hold on;
    
    % Plot R-BS
    plot3(R_BS_location(1), R_BS_location(2), R_BS_location(3), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    text(R_BS_location(1), R_BS_location(2), R_BS_location(3), ' R-BS', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

    % Plot uplink users
    plot3(uplink_users(1,:), uplink_users(2,:), uplink_users(3,:), 'b^', 'MarkerSize', 8, 'LineWidth', 2);
    for i = 1:size(uplink_users, 2)
        text(uplink_users(1,i), uplink_users(2,i), uplink_users(3,i), [' UL' num2str(i)], 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end

    % Plot downlink users
    plot3(downlink_users(1,:), downlink_users(2,:), downlink_users(3,:), 'gs', 'MarkerSize', 8, 'LineWidth', 2);
    for i = 1:size(downlink_users, 2)
        text(downlink_users(1,i), downlink_users(2,i), downlink_users(3,i), [' DL' num2str(i)], 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end

    % Plot UAV start location
    plot3(q_i(1), q_i(2), q_i(3), 'kp', 'MarkerSize', 10);
    text(q_i(1), q_i(2), q_i(3), ' Start', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');

    % Plot UAV end location
    plot3(q_f(1), q_f(2), q_f(3), 'kh', 'MarkerSize', 10);
    text(q_f(1), q_f(2), q_f(3), ' End', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

    % Plot the end region as a transparent sphere
    [x_sphere, y_sphere, z_sphere] = sphere(20);
    surf(regionRadius * x_sphere + q_f(1), ...
         regionRadius * y_sphere + q_f(2), ...
         regionRadius * z_sphere + q_f(3), ...
         'FaceAlpha', 0.2, 'EdgeColor', 'none', 'FaceColor', 'm');

    % Add obstacleLocs
    if (~isempty(params.obstacleLocs))
        obstacleLocs = params.obstacleLocs;
        obstacleRadius = params.obstacleRadius;
        numObstacles = size(obstacleLocs,2);
        for j = 1:numObstacles
            obsPos = obstacleLocs(:, j);
            surf(obstacleRadius * x_sphere + obsPos(1), ...
                 obstacleRadius * y_sphere + obsPos(2), ...
                 obstacleRadius * z_sphere + obsPos(3), ...
                 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'FaceColor', '#FF6347');
        end
    end
    % Set plot limits
    xlim([-grid_size * cell_size / 2, grid_size * cell_size / 2]);
    ylim([-grid_size * cell_size / 2, grid_size * cell_size / 2]);
    zlim([0, z_max]);
    
    % Labels and title
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
    grid on;
    view(3);
    hold off;
end


