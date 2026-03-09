function [hasLoop, loopIndices] = detectLoopTraj(trajectory)
    % detectLoop checks if there is a loop in the 3D trajectory.
    % Inputs:
    %   trajectory: A 3 x N matrix, where each column represents a 3D point (x, y, z).
    % Outputs:
    %   hasLoop: Boolean indicating if a loop is detected.
    %   loopIndices: Indices [i, j] indicating the start and end of the loop, if found.

    % Initialize outputs
    hasLoop = false;
    loopIndices = [];
    
    % Get the number of trajectory points
    N = size(trajectory, 2);
    
    % Loop through each point and check if it matches any previous point
    for i = 1:N-1
        for j = i+1:N
            % Check if the points are exactly the same (i.e., loop detected)
            if isequal(trajectory(:, i), trajectory(:, j))
                hasLoop = true;
                loopIndices = [i, j];
                return;
            end
        end
    end
end
