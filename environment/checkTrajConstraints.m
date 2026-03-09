function violations = checkTrajConstraints(trajectory, params)
    % Check for constraint violations in the UAV trajectory
    % trajectory: Nx3 matrix of UAV positions [x, y, z]
    % q_i: Initial position [x, y, z]
    % q_f: Final position [x, y, z]
    % v_max_xy: Maximum horizontal velocity (m/s)
    % v_max_z: Maximum vertical velocity (m/s)
    % delta_t: Time step (s)
    % z_min: Minimum altitude (m)
    % z_max: Maximum altitude (m)

    % Load parameters
    sysParams;
    
    % Initialize violations flag
    violations = false;  % No violations initially
    
    % Initialize loop detection variables
    action_history = strings(1, 0);  % Store actions as strings
    % Direction symbols
    directionSymbols = ["N", "S", "E", "W", "U", "D"];
    position_map = containers.Map('KeyType', 'char', 'ValueType', 'int32');

    %% Check initial and final positions
    if ~isequal(trajectory(:, 1), q_i)
        fprintf('Violation: Initial position does not match q_i.\n');
        violations = true;
    end
    if ~(norm(trajectory(:, end) - q_f) <= params.regionRadius)
        fprintf('Violation: Final position is not within the end region.\n');
        violations = true;
    end

    %% Check for obstacle collisions
    if ~isempty(params.obstacleLocs)
        for n = 2:size(trajectory, 2)
            q_next = trajectory(:, n);
            if any(vecnorm(q_next - params.obstacleLocs) <= params.obstacleRadius)
                violations = true;
                fprintf('Violation: Collision occurred with an obstacle at step %d.\n', n);
            end
        end
    end

    %% Check for maximum velocity and altitude constraints
    for n = 1:size(trajectory, 2) - 1
        % Check horizontal movement constraint
        dist_xy = norm(trajectory(1:2, n + 1) - trajectory(1:2, n));
        if dist_xy > v_max_xy * delta_t
            fprintf('Violation: Horizontal movement exceeds limit at step %d.\n', n);
            violations = true;
        end
        
        % Check vertical movement constraint
        dist_z = abs(trajectory(3, n + 1) - trajectory(3, n));
        if dist_z > v_max_z * delta_t
            fprintf('Violation: Vertical movement exceeds limit at step %d.\n', n);
            violations = true;
        end

        % Check altitude constraints
        if trajectory(3, n + 1) < z_min || trajectory(3, n + 1) > z_max
            fprintf('Violation: Altitude out of bounds at step %d.\n', n);
            violations = true;
        end

    end

%     %% Check for loops and backtracking in the trajectory
%     for n = 1:size(trajectory, 2) - 1
%         % Calculate the change in position between consecutive steps
%         delta_pos = trajectory(:, n + 1) - trajectory(:, n);
%         
%         % Determine direction based on the change in position
%         if delta_pos(1) > 0
%             direction = 3;  % East
%         elseif delta_pos(1) < 0
%             direction = 4;  % West
%         elseif delta_pos(2) > 0
%             direction = 1;  % North
%         elseif delta_pos(2) < 0
%             direction = 2;  % South
%         elseif delta_pos(3) > 0
%             direction = 5;  % Up
%         elseif delta_pos(3) < 0
%             direction = 6;  % Down
%         else
%             direction = NaN; % Stationary
%         end
% 
%         % Determine speed level based on distance moved
%         dist = norm(delta_pos);
%         if dist == 0
%             speed = 1;  % Stationary
%         elseif dist <= (v_max_xy / 2) * delta_t
%             speed = 2;  % Middle speed
%         else
%             speed = 3;  % High speed
%         end
% 
%         % Convert the action to a string representation
%         if ~isnan(direction)
%             action_str = directionSymbols(direction) + string(speed);
%         else
%             action_str = "S1"; % Stationary
%         end
%         
%         % Store the action
%         action_history = [action_history, action_str];
% 
%         % Convert the current position to a string key
%         current_position = mat2str(trajectory(:, n)');
% 
%         % Check if the current position has been visited before
%         if isKey(position_map, current_position)
%             % Calculate loop size (number of actions between repetitions)
%             previous_index = position_map(current_position);
%             loop_size = n - previous_index;
%             
%             fprintf('Loop detected at step %d with size %d.\n', n, loop_size);
%             fprintf('Loop actions: %s\n', strjoin(action_history(previous_index + 1:n), ' '));
%             violations = true;
%         end
%         % Store/update the current position in the map with its index
%         position_map(current_position) = n;


%     end
end

