%% Auxiliary function to compute sensing channel A_0 based on the target's 3D location
function [A_0, zeta_0] = sensing_channel(RBS_loc,target_location)
    % Inputs:
    % M_tx_h - Number of horizontal transmit antennas
    % M_tx_v - Number of vertical transmit antennas
    % M_rx_h - Number of horizontal receive antennas
    % M_rx_v - Number of vertical receive antennas
    % target_location - [x, y, z] coordinates of the target in 3D space
    % BS_location - [x, y, z] coordinates of the radar base station
    % wavelength - Carrier signal wavelength (in meters)
    
    sysParams

    % Calculate 3D distance between the base station and target
    delta_xyz = target_location - RBS_loc;
    distance = norm(delta_xyz);
    distance_xy = norm([delta_xyz(1), delta_xyz(2)]);

    % Calculate angles for steering vectors
    theta = atan2(delta_xyz(3), distance_xy); % Elevation angle (in radian)
    phi = atan2(delta_xyz(2), delta_xyz(1));  % Azimuth angle (in radian)
    ang = rad2deg([phi;theta]); % in degree

    % Transmit steering vector (AoD) for UPA
    a_t = steering_vector(M_tx_h, M_tx_v, ang, wavelength, fc);

    % Receive steering vector (AoA) for UPA
    a_r = steering_vector(M_rx_h, M_rx_v, ang, wavelength, fc);
    
    % Sensing channel A_0
    A_0 = a_r * a_t';  % Outer product of the two steering vectors

    % Calculate one-way attenuation zeta_0
    zeta_0 = sqrt(beta_0 * distance^(-alpha_pathloss)*RCS);
    
end

%% Generate the transmit steering vector for UPA
function a_t = steering_vector(M_h, M_v, ang, wavelength, fc)
    % M_h - Number of horizontal antennas
    % M_v - Number of vertical antennas
    % theta - Elevation angle
    % phi - Azimuth angle
    % wavelength - Signal wavelength
    [delta_spacingX, delta_spacingY] = deal(wavelength/2); % hald wavelength 

    
    array = phased.URA('Size',[M_h, M_v], 'ElementSpacing',[delta_spacingX, delta_spacingY], 'ArrayNormal','y');

    steervec = phased.SteeringVector("SensorArray",array);

    a_t = steervec(fc, ang);


%     elementPos_v = delta_spacingX*linspace(-(M_v-1)/2,(M_v-1)/2, M_v);
%     elementPos_h = delta_spacingY*linspace(-(M_h-1)/2,(M_h-1)/2, M_h);
%     
%     % Horizontal steering component
%     a_h = exp(1j * 2 * pi * elementPos_h' * sin(theta) * cos(phi) / wavelength);
%     
%     % Vertical steering component
%     a_v = exp(1j * 2 * pi * elementPos_v' * sin(theta) * sin(phi) / wavelength);
%     
%     % Full transmit steering vector using Kronecker product
%     a_t = kron(a_h, a_v);
end

%% Generate the receive steering vector for UPA
% function a_r = receive_steering_vector(M_h, M_v, theta, phi, wavelength)
%     % M_h - Number of horizontal antennas
%     % M_v - Number of vertical antennas
%     % theta - Elevation angle
%     % phi - Azimuth angle
%     % wavelength - Signal wavelength
%     delta_spacing = wavelength/2; % hald wavelength 
% 
%     % Horizontal steering component
%     a_h = exp(-1j * 2 * pi * delta_spacing* (0:M_h-1)' * sin(theta) * cos(phi) / wavelength);
%     
%     % Vertical steering component
%     a_v = exp(-1j * 2 * pi * delta_spacing*(0:M_v-1)' * sin(theta) * sin(phi) / wavelength);
%     
%     % Full receive steering vector using Kronecker product
%     a_r = kron(a_h, a_v);
% end


