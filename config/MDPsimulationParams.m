% Define parameters for the grid
grid_size = 10;  % Size of the grid (10x10 cells)
cell_size = 20;  % Size of each cell (20 meters)
z_min = 1*cell_size;     % Min altitude (m)
z_max = 5*cell_size;    % Max altitude (m)

Llimit = [-grid_size * cell_size / 2; -grid_size * cell_size / 2; z_min];
Ulimit = [grid_size * cell_size / 2; grid_size * cell_size / 2; z_max];

% gridSize3D = [grid_size, grid_size, grid_size]; % [X, Y, Z] dimensions of the grid

num_uplink_users = 5;  % Number of uplink users
num_downlink_users = 10;  % Number of downlink users
L = num_uplink_users;
K = num_downlink_users;

% Initialize grid
grid_x = -grid_size * cell_size / 2: 0.5*cell_size :grid_size * cell_size / 2;
grid_y = -grid_size * cell_size / 2: 0.5*cell_size :grid_size * cell_size / 2;
grid_z = z_min: 0.25*cell_size: z_max;

% Calculate the cell centers
cell_centers_x = grid_x(1:end-1) + cell_size / 4;
cell_centers_y = grid_y(1:end-1) + cell_size / 4;

% Create a meshgrid of all cell centers
[X, Y] = meshgrid(cell_centers_x, cell_centers_y);
cell_centers = [X(:), Y(:)]; % List of all cell center coordinates (x, y)

[X_cord, Y_cord, Z_cord] = ndgrid(cell_centers_x,cell_centers_y, grid_z);

Eve_Locs = [X_cord(:), Y_cord(:), Z_cord(:)];

% Define UAV parameters
q_i = [cell_centers_x(1), cell_centers_x(end), grid_z(end)]';  % Initial position
q_f =[cell_centers_x(end), cell_centers_x(1), grid_z(end)]';    % Final position
regionRadius = 30;


v_max_xy = sqrt(2)*cell_size;  % Max horizontal speed (m/s)
v_max_x = cell_size;
v_max_y = cell_size;
v_max_z = 0.5*cell_size;   % Max vertical speed (m/s)
delta_t = 1;   % Time step (s)

d_xy = v_max_xy*delta_t;  % 
d_z = v_max_z * delta_t; % z_max = k d_z + z_min
N = 100; % Number of steps, N mission time  maxSteps