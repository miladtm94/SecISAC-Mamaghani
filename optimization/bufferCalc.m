% DO NOT UNCOMMENT
% [BS_location, uplink_users, downlink_users] = loc_init();
% save('myGroundTerminalDist.mat', 'groundTerminalsLoc');

% global buffer

% myBufferObj= matfile('myBufferNew.mat', Writable=true);
% 
% templateResults= struct();
% templateResults.Evekeys=[];  % Initializing with a dummy field
% templateResults.Channels = [];  % Initializing with a dummy field
% templateResults.metrics = [];  % Initializing with a dummy field
% templateResults.params = [];  % Initializing with a dummy field
% 
% myBufferObj.Results(1,7000) = templateResults;




%% DO NOT UNCOMMENT: Buffering the data
% counter = numel(buffer);
% while (counter <=size(Eve_Locs,1))
%     eve_loc = Eve_Locs(counter,:)';
%     try
%         counter = counter+1;
%         buffer(counter).Evekeys=[];  % Initializing with an empty field
%         buffer(counter).Channels = [];  % Initializing with  an empty
%         buffer(counter).metrics = [];  % Initializing with an empty
%         buffer(counter).params = [];  % Initializing with  an empty
%         tic
%         % Perform calculations 
%          results=solveOptimization(groundTerminalsLoc,eve_loc);
%          buffer(counter) = results;
%         toc
%         fprintf("#%d out of 6800: Resource optimization is completed at Eve's location (%d,%d,%d).\n",counter, eve_loc(1),eve_loc(2), eve_loc(3));
%     if(mod(counter,10)==0)
%         save('myBuffer.mat','buffer');
%     end
%     catch ME
%         disp('Error occurred, saving buffer...');
%         save('myBuffer.mat','buffer');
%         fprintf('Error in iteration %d: %s\n', counter, ME.message);
% 
%     end
% end


%% DO NOT UNCOMMENT
% for counter=1:size(Eve_Locs,1)
%     eve_loc = Eve_Locs(counter, :);
%     channels = updateChannels(groundTerminalsLoc,eve_loc);
%     [metrics, params] = observed_metrics(channels, eve_loc);
%     fprintf("#%d out of 6800: Resource optimization is completed at Eve's location (%d,%d,%d).\n",counter, eve_loc(1),eve_loc(2), eve_loc(3));
% end


% buffer.(eve_key).metrics = [ucsr, dcsr, crlb]; 
% buffer.(eve_key).params = {params_init, params_optimal};


%% DO NOT UNCOMMENT
% emptyIndices = find(arrayfun(@(x) isempty(x.Evekeys), buffer));
% 
% newBuffer = buffer(emptyIndices);
% for counter = 1:numel(newBuffer)
%     index = emptyIndices(counter);
%     eve_loc = Eve_Locs(index,:)';
%   try
%     tic
%     % Perform calculations 
%      results=solveOptimization(groundTerminalsLoc,eve_loc);
%      buffer(index) = results;
%     toc
% 
%    catch ME
%         disp('Error occurred..');
%         % save('myBuffer.mat','buffer');
%         fprintf('Error in iteration %d: %s\n', counter, ME.message);
%    end
% 
% end
% 




% figure;
% visualize_system(BS_location, uplink_users, downlink_users)
% obstacles = [];
% numObstacles = 7;
% obstacleRadius = 8;
% regionRadius = 20;
% obstacles = generateObstacles(numObstacles, obstacleRadius, q_i, q_f, grid_size, cell_size, z_min, z_max,Llimit,Ulimit);


% load("data/myBuffer.mat", 'buffer'); % load Player 1's precalculated optimal strategy 
% 
% % Correcting metric calcs and adding U1
% for i=1:length(buffer)
%     channels = buffer(i).Channels;
%     params_temp = buffer(i).params;
%     params_optimal = params_temp(2);
%     bb = params_optimal{:};
%     P = cell2mat(bb(1));
%     V = cell2mat(bb(2));
%     W = cell2mat(bb(3));
%     params_optimal = {P,V,W};
%     [ucsr, dcsr, crlb,~,~,~] = metrics_calc(params_optimal, channels);
%     buffer(i).metrics = [ucsr, dcsr, crlb]; 
%     SumVk =sum(V, 3); % Sum beamforming matrices across users
%     U1 = trace(SumVk) + trace(W) + sum(P);
%     buffer(i).U1 = U1; 
% end
% save("data/myBuffer.mat", 'buffer'); % load Player 1's precalculated optimal strategy 
% 
% % Normalize buffer.U1
% 
% % Step 1: Extract all U1 values from the buffer
% U1_values = [buffer.U1];
% 
% % Step 2: Calculate the minimum and maximum values of U1
% max_U1 = max(U1_values);
% 
% % Step 3: Normalize each U1 value and update the buffer
% for idx = 1:length(buffer)
%     % Calculate the normalized U1 value
%     normalized_U1 = (buffer(idx).U1) / (max_U1);
% 
%     % Step 4: Update the buffer with the new normalized value
%     buffer(idx).U1_normalized = normalized_U1;
% end
% save("data/myBuffer.mat", 'buffer'); % load Player 1's precalculated optimal strategy 

% To objectively compare PPO and DDQN, track metrics like:
% 
% Success Rate: The percentage of episodes where the UAV reaches the goal within the mission time.
% Average Reward: The mean reward accumulated over episodes.
% Convergence Speed: The number of episodes needed to reach a stable policy.
% Trajectory Efficiency: Average distance traveled versus the optimal path.
% Computational Cost: Time taken per training episode.

