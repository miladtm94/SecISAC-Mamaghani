function [loopDetected, loopSize, loopSeq] = detectLoop(recentPositions, loopLen, params)
    % Detect loops in recent positions and return the loop as a string sequence.
    % Returns: loopDetected (boolean), loopSize (integer), loopSeq (string)
    
    % Initialize variables
    numPositions = size(recentPositions, 2);
    loopDetected = false;
    loopSize = 0;  % Default loop size if no loop is detected
    loopSeq = '';  % Initialize loop sequence as an empty string
    
    % Extract some parameters
    v_max_x = params.mobility(1);
    v_max_y = params.mobility(2);
    delta_t = params.mobility(4);
    v_max_xy = norm([v_max_x, v_max_y]);

    if numPositions >= loopLen
        % Extract the last 'loopLen' positions
        recentSeq = recentPositions(:, end-loopLen+1:end);
        
        % Initialize direction and speed vectors
        directionSet = zeros(1, loopLen-1);  % Direction set for each position
        speedLevel = zeros(1, loopLen-1);    % Speed level for each position
        
        % Loop through recent positions to calculate direction and speed
        for n = 1:loopLen-1
            delta_pos = recentSeq(:, n + 1) - recentSeq(:, n);
            
            % Determine direction based on the change in position
            if delta_pos(1) > 0
                direction = 3;  % East
            elseif delta_pos(1) < 0
                direction = 4;  % West
            elseif delta_pos(2) > 0
                direction = 1;  % North
            elseif delta_pos(2) < 0
                direction = 2;  % South
            elseif delta_pos(3) > 0
                direction = 5;  % Up
            elseif delta_pos(3) < 0
                direction = 6;  % Down
            else
                direction = 7; % Stationary
            end
            
            % Determine speed level based on distance moved
            dist = norm(delta_pos);
            if dist == 0
                speed = 1;  % Stationary
            elseif dist <= (v_max_xy / 2) * delta_t
                speed = 2;  % Middle speed
            else
                speed = 3;  % High speed
            end
            
            % Store the direction and speed in the respective arrays
            directionSet(n) = direction;
            speedLevel(n) = speed;
        end
        

        % Check if the sequence of length 'loopLen' from i to the end matches the last 'loopLen' positions
        if isequal(recentSeq(:, 1), recentSeq(:, end))
            loopDetected = true;
            loopSize = loopLen;  % Set the loop size to the fixed value (loopLen)
            loopSeq = generateLoopString(directionSet, speedLevel); % Generate loop sequence as string
        end

    end
    
    % % Print the loop details if detected
    % if loopDetected
    %     fprintf("Loop with size: %d detected! Loop sequence: %s\n", loopSize);
    % end
end

% Helper function to convert trajectory to a string of directions and speeds
function loopStr = generateLoopString(directionSet, speedLevel)
    loopStr = '';  % Initialize loop string
    
    % Direction symbols for N, S, E, W, U, D
    directionSymbols = {'N', 'S', 'E', 'W', 'U', 'D','O'};  % Cell array for direction symbols
    % Speed symbols for Low (L), Middle (M), High (H)
    speedSymbols = {'L', 'M', 'H'};  % Cell array for speed levels: Low (L), Middle (M), High (H)
    
    % Convert each direction and speed into a string representation
    for k = 1:length(directionSet)
        direction = directionSet(k);  % Direction index (1 to 6)
        speed = speedLevel(k);        % Speed level (1 to 3)
        
        % Convert to the corresponding direction symbol and speed symbol
        dirSymbol = directionSymbols{direction};  % Use cell array indexing
        speedSymbol = speedSymbols{speed};        % Use cell array indexing
        

        % Append the direction and speed to the loop string
        if (k~=length(directionSet))
            loopStr = strcat(loopStr, dirSymbol, speedSymbol,'->');  % Space for separation
        else
            loopStr = strcat(loopStr, dirSymbol, speedSymbol);  % Space for separation
        end
    end
end
