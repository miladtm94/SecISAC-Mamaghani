function Pf = flightPow(v_xy, v_z)
% Parameters for the UAV and environment
g = 9.8;  % Acceleration due to gravity (m/s^2)
mass = 3; % UAV mass (kg)
G0 = g * mass; % Weight force (N)
Pb = 79.86; % Blade profile power in hovering state (W)
Pi = 88.63; % nduced power in hovering state  (W)
C0 = 0.0092; % Profile drag coefficient (W/(m/s)^3)   C = 0.5 d0  rho s A
% Fuselage drag ratio (d0=0.6) Rotor disc area (A=0.503m^2) Rotor solidity
% (s=0.05) Air density (ρ = 1.225 kg/m^3)
U_tip = 120; % Tip speed of the propeller (m/s)
nu_0 = 4.03; % Mean rotor induced velocity in hovering state (m/s)

% Power consumption formula
Pf = Pb .* (1 + 3 .* v_xy.^2 ./ U_tip.^2) ... % Blade profile
   + C0 .* v_xy.^3 ...                        % Parasitic power
   + G0 .* v_z ...                            % Climb power
   + Pi .* sqrt(sqrt(1 + (v_xy.^4 ./ (4 .* nu_0.^4))) - (v_xy.^2 ./ (2 .* nu_0.^2))); % Induced power
end
