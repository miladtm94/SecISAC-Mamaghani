%% Figure for Flight power illustration


clc;
clear;
close all

% Load system parameters
sysParams;

% Define test values for velocities
vx = [0, cell_size/2, cell_size];
vy = [0, cell_size/2, cell_size];
[Vx, Vy] = meshgrid(vx, vy);
Vxy = [Vx(:) Vy(:)];
Vz = [0, cell_size/4, cell_size/2];

% Calculate the maximum flight power

for i = 1:size(Vxy, 1)
    vxy = norm(Vxy(i, :));
    for k = 1:length(Vz)
        vz = Vz(k);
        P(i,k) = flightPow(vxy, vz); % Normalize the power
    end
end

% P_norm = normalize(P,'all','range');

%%

% Define the range for horizontal velocity
x = linspace(0, norm([v_max_x, v_max_y]), 100);

% Calculate normalized power consumption at different altitudes
y1 = flightPow(x, 0);
y2 = flightPow(x, v_max_z / 2) ;
y3 = flightPow(x, v_max_z) ;

% Plotting the Results
figure;
hold on;
grid on;

% Plot each curve with adjusted line styles, markers, and colors
plot(x, y1, 'r-', 'LineWidth', 1.5);
plot(x, y2, 'k--', 'LineWidth', 1.5);
plot(x, y3, 'b-.', 'LineWidth', 1.5);

% Adding Labels and Title with LaTeX formatting
xlabel('Horizontal Velocity ($v_{xy}$) [m/s]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Flight Power Consumption (${P}_f$)', 'Interpreter', 'latex', 'FontSize', 12);
title('Flight Power Consumption vs. Velocity', 'Interpreter', 'latex', 'FontSize', 14);

% Add legend with LaTeX support
legend('$v_z = 0$', '$v_z = 0.5{v^{\max}_z}$', '$v_z = v^{\max}_z$', 'FontSize', 10, 'Interpreter', 'latex', 'Location', 'best');

hold off


% Calculate and mark points on the plot
colors = ['r', 'k', 'b']; % Colors for different z levels
markers = ['o', 's', 'd']; % Different markers for visual distinction

for i = 1:size(Vxy, 1)
    vxy = norm(Vxy(i, :));
    for k = 1:length(Vz)
        vz = Vz(k);
        P = flightPow(vxy, vz); % Normalize the power
        % Mark the point on the plot
        hold on
        scatter(vxy, P, 60, colors(k), markers(k), 'filled', 'HandleVisibility', 'off');
    end
end

hold off;
