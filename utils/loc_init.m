function [BS_location, uplink_users, downlink_users]= loc_init()

sysParams

r_inner =grid_size * cell_size/3;            % Inner circle radius for uplink users
r_outer = grid_size * cell_size/2;           % Outer circle radius for downlink users
min_distance_ul = 5*cell_size;     % Minimum distance between uplink users (in meters)
min_distance_dl = 5*cell_size;     % Minimum distance between downlink users (in meters)




% Place R-BS in the center of the grid
BS_location = [0,0, 0]';  % R-BS at ground level (x, y, z)


% Calculate distances of all cell centers from the BS
distances_from_bs = sqrt(sum(cell_centers.^2, 2));


%% Select Uplink Users
uplink_candidates = cell_centers(distances_from_bs <= r_inner, :); % Uplink candidates inside inner circle

uplink_users = []; % Initialize uplink users
while size(uplink_users, 1) < num_uplink_users
    remaining_ul_users = num_uplink_users - size(uplink_users, 1);
    candidate_indices = randperm(size(uplink_candidates, 1), remaining_ul_users);
    candidate_uplink_users = uplink_candidates(candidate_indices, :);
    
    % Calculate pairwise distances between selected uplink users
    if isempty(uplink_users)
        valid_ul_users = candidate_uplink_users;
    else
        distances_ul = calc_distances(uplink_users, candidate_uplink_users);
        valid_ul_users = candidate_uplink_users(all(distances_ul > min_distance_ul, 1), :);
    end
    
    % Add valid uplink users to the list
    uplink_users = [uplink_users; valid_ul_users];
    
    % Remove selected candidates from future selection
    uplink_candidates(candidate_indices, :) = [];
end

%% Select Downlink Users
downlink_candidates = cell_centers(distances_from_bs > r_inner & distances_from_bs <= r_outer, :); % Downlink candidates

downlink_users = []; % Initialize downlink users
while size(downlink_users, 1) < num_downlink_users
    remaining_dl_users = num_downlink_users - size(downlink_users, 1);
    candidate_indices = randperm(size(downlink_candidates, 1), remaining_dl_users);
    candidate_downlink_users = downlink_candidates(candidate_indices, :);
    
    % Calculate pairwise distances between selected downlink users
    if isempty(downlink_users)
        valid_dl_users = candidate_downlink_users;
    else
        distances_dl = calc_distances(downlink_users, candidate_downlink_users);
        valid_dl_users = candidate_downlink_users(all(distances_dl > min_distance_dl, 1), :);
    end
    
    % Add valid downlink users to the list
    downlink_users = [downlink_users; valid_dl_users];
    
    % Remove selected candidates from future selection
    downlink_candidates(candidate_indices, :) = [];
end

downlink_users = [downlink_users'; zeros(1,num_downlink_users)];
uplink_users = [uplink_users';zeros(1,num_uplink_users)];
end