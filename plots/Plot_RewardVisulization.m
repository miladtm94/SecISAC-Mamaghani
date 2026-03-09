clc
clearvars -except buffer groundTerminalsLoc
close all

sysParams

% Define fixed altitudes for Eve  
altitudes = [z_min, grid_z(6), grid_z(13), z_max];% Example altitudes in meters  
num_altitudes = length(altitudes);  

% Define simulation parameters for horizontal locations  
x_range = cell_centers_x; % X coordinates for Eve locations  
y_range = cell_centers_y; % Y coordinates for Eve locations  

grid_size_x = length(x_range);
grid_size_y = length(y_range);
% Create a figure for subplots  
figure;  

% Loop through each altitude and create a heatmap  
for k = 1:num_altitudes  
    fixed_altitude = altitudes(k);  
    U1_matrix = zeros(grid_size_x, grid_size_y); % Reset matrix for each altitude  
    
    % Populate U1_matrix based on Eve's key corresponding to q_next  
    for i = 1:grid_size_x  
        for j = 1:grid_size_y  
            eve_location = [x_range(i), y_range(j), fixed_altitude]; % Add fixed altitude  
            
            % Get the key for the current location  
            eve_key = eveLocationKey(eve_location);   
            
            % Find the index for the current location's key in the buffer  
            index = find(strcmp({buffer.Evekeys}, eve_key), 1);  
            if ~isempty(index)  
                U1_matrix(i,j) = buffer(index).U1; % Store the U1 in the matrix  
            else  
                U1_matrix(i,j) = NaN; % Or some other value if not found
            end  
        end  
    end  
    
% Create a subplot for the current altitude  
subplot(2, 2, k); % Creates a 2x2 grid of subplots  
h = heatmap(x_range, y_range, U1_matrix', 'GridVisible', 'off'); % Transpose U1_matrix  
 colormap(jet); % Change colormap as needed  
xlabel('X [m]');  
ylabel('Y [m]');  
title(['Altitude z = ', num2str(fixed_altitude), ' m']);  
colorbar; % Show color bar indicating U1 values  

  % Set x-axis and y-axis to show only min and max values
h.XDisplayLabels = repmat({''}, 1, length(x_range));
h.YDisplayLabels = repmat({''}, length(y_range), 1);
h.XDisplayLabels([1,end/2, end]) = {num2str(x_range(1)),0, num2str(x_range(end))};
h.YDisplayLabels([1, end/2,end]) = {num2str(y_range(1)),0, num2str(y_range(end))};

end  

% Adjust layout for clarity  
sgtitle('Optimal U_1 at Different UAV Altitudes'); % Overall title for all subplots