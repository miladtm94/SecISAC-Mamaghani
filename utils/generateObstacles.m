function obstacles = generateObstacles(numObstacles, obstacleRadius, q_i, q_f, grid_size, cell_size, z_min, z_max,Llimit,Ulimit)
    % Generate random obstacle positions within the grid limits, avoiding overlap with start/end locations
    obstacles = zeros(3, numObstacles);
    for i = 1:numObstacles
        while true
            x = (rand - 0.5) * grid_size * cell_size;
            y = (rand - 0.5) * grid_size * cell_size;
            z = z_min + rand * (z_max - z_min);
            obstaclePos = [x; y; z];


            
            % Ensure the obstacle does not overlap with the start or end locations
            if (norm(obstaclePos - q_i) > 2 * obstacleRadius ...
                && norm(obstaclePos - q_f) > 2 * obstacleRadius ...
                && norm(obstaclePos - Llimit)>=2 * obstacleRadius ...
                && norm(obstaclePos - Ulimit)>=2 * obstacleRadius)
                obstacles(:, i) = obstaclePos;
                break;
            end
        end
    end
end