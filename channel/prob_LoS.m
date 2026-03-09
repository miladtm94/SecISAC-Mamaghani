% Probability of LoS based on elevation angle and distance (urban example)
function P_LoS = prob_LoS(loc_i, loc_j)
    C = 9.61;  % Environment-specific constant (urban)
    D = 0.16;  % Environment-specific constant (urban)

    % Calculate distance between users i and j
    delta_xyz = loc_i - loc_j;
    h = abs(delta_xyz(3));
    d = norm(delta_xyz(1:2));  % horizontal distance only
    
    % Define the probability of LoS based on elevation angle and distance
    theta_deg = atan(h / d) * 180 / pi; % degrees
    
    P_LoS = 1 / (1 + C * exp(-D * (theta_deg - C)));
end
