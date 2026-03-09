%%  Step Function 

% Step function defines how the UAV moves in the grid
function [NextObservation, Reward, IsDone, UpdatedInfo] = stepFunctionD(Action, Info, params)
    
    global episodeCount

    % Extract some parameters
    v_max_x = params.mobility(1);
    v_max_y = params.mobility(2);
    v_max_z = params.mobility(3);
    delta_t = params.mobility(4);
    N = params.missiontime;
    q_f = params.finalLoc;
    q_i = params.initLoc;
    Llimit = params.limit(:,1);
    Ulimit = params.limit(:,2);
    


    % Extract current state from Info signal: location and timeslot
    q_current = Info.Loc;
    n_current = Info.Time;

    visitedPositions = Info.VisitedPos;
    recentPositions = Info.RecentPos;


    % Choose action a
    directon=Action(1);
    speed = Action(2);
    
   switch directon
    case 1 % North
        vy = (speed) * (v_max_y / 2);
        q_next = q_current + vy * delta_t * [0; 1; 0];
    case 2 % South
        vy = (speed) * (v_max_y / 2);
        q_next = q_current + vy * delta_t * [0; -1; 0];
    case 3 % East
        vx = (speed) * (v_max_x / 2);
        q_next = q_current + vx * delta_t * [1; 0; 0];
    case 4 % West
        vx = (speed) * (v_max_x / 2);
        q_next = q_current + vx * delta_t * [-1; 0; 0];
    case 5 % Up
        vz = (speed) * (v_max_z / 2);
        q_next = q_current + vz * delta_t * [0; 0; 1];
    case 6 % Down
        vz = (speed) * (v_max_z / 2);
        q_next = q_current + vz * delta_t * [0; 0; -1];
       otherwise 
           % Stationary
           q_next = q_current;
           speed = 0;
    end

    % Boundary violation 
    flags.boundary = false;
    if ((any(q_next > Ulimit) || any(q_next < Llimit)))
        q_next = q_current;
        flags.boundary =true;
    end

    n_next = n_current+1;
    dist2End_next = norm(q_next-q_f);
  
    % Move to new state s'
    NextObservation = [q_next;dist2End_next;n_next];


    % Update recently visited positions
    recentPositions = [recentPositions, q_next];
    visitedPositions = [visitedPositions, q_next];
    
    % Specify maximum number of moves to track (e.g., last 7 moves)
    maxHistory = N-1;
    if size(recentPositions, 2) > maxHistory
        recentPositions(:, 1) = []; % Remove oldest position if buffer exceeds maxHistory
    end

    % tiem flag for mission time
    flags.time = n_next == N;
    flags.distance = norm(q_next-q_f)<=params.regionRadius;


    fprintf("------------------------------------------------\n" + ...
            "Timestep: #%d\n",n_next);

    % Map action to human-readable labels
    directionNames = {'North', 'South', 'East', 'West', 'Up', 'Down'};
    speedNames = {'Low', 'High'};
    fprintf("Old position: [%d, %d, %d], New position: [%d, %d, %d]\n", q_current, q_next);
    if speed == 0
       fprintf("Action: Stationary\n");
    else
        fprintf("Action: Direction = %s, Speed = %s\n", directionNames{directon}, speedNames{speed});
    end
    % fprintf("Number of recent positions at state s': %d\n",size(recentPositions, 2))
    % fprintf("Number of visited positions at state s': %d\n",size(visitedPositions, 2))

    % flag for repetition and backtracking
    LoopLength = 2:maxHistory;

    flags.loop =  false; 
    for loopLen=LoopLength
        [loopDetected, loopSize, loopSeq] = detectLoop(recentPositions, loopLen, params);
        if(loopDetected)
           flags.loop = true;
           flags.loopSize= loopSize;
           flags.loopSeq= loopSeq;
        end
    end
   
    % flag for obstacle collision
    flags.collision =false;
    if ~isempty(params.obstacleLocs)
        if(any(vecnorm(q_next-params.obstacleLocs)<=0.95*params.obstacleRadius))
            flags.collision =true;
        end
    end

    % % Penalty for visiting states more than once
    % flag_visited = false;
    % if (any(ismember(visitedPositions(:,1:end-1)',q_next','rows')))
    %     flag_visited = true;
    %     fprintf("(-) Already visited location\n");
    % end
    
    
    % Set the termination flag and other flags 
    IsDone = (flags.time || flags.distance);
    
    Reward = rewardFunc(q_current, q_next, n_next,IsDone,  params, flags);

        % Store visited positions in the structure
    if (IsDone)
        episodeCount = episodeCount + 1;
        % Check if the file exists
        filename1 = params.filename;
        if exist(filename1, 'file')
          % Load the existing data
            load(filename1, 'allVisitedPosition');
        
            % Add new data
            allVisitedPosition(episodeCount).Episode = episodeCount;
            allVisitedPosition(episodeCount).Positions = visitedPositions;
        
            % Save back to file
            save(filename1, 'allVisitedPosition');
        else
            % File does not exist, create the file
            allVisitedPosition(episodeCount).Episode = episodeCount;
            allVisitedPosition(episodeCount).Positions = visitedPositions;
            save(filename1, 'allVisitedPosition');
        end

    end

    % Update logged signals   
    UpdatedInfo.Loc = q_next;
    UpdatedInfo.Time = n_next;
    UpdatedInfo.Dist = dist2End_next;
    UpdatedInfo.RecentPos = recentPositions;
    UpdatedInfo.VisitedPos = visitedPositions;

end





