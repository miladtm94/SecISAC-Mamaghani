function h = rician_channel(M, loc_i, loc_j)

    % Rician channel model between user i with M antennas and user j with 1 antenna.
    % M - Number of antennas (either transmit or receive antennas depending on the scenario)
    % loc_i - 3D location of user i [x, y, z] (multi-antenna user)
    % loc_j - 3D location of user j [x, y, z] (single-antenna user)
    
    sysParams

    P_LoS = prob_LoS(loc_i, loc_j);
    distance = norm(loc_i - loc_j);

    % Large-scale fading
    eta_LoS = P_LoS * beta_0 * distance^(-alpha_pathloss);  % LoS large-scale attenuation
    eta_NLoS = (1 - P_LoS) * excessivePL * beta_0 * distance^(-alpha_pathloss);  % NLoS large-scale attenuation
    
    % LoS component with phase shift
    phase_shift = exp(1j * 2 * pi * (0:M-1)'*distance / wavelength);  % Phase shift based on distance
    g_LoS =  phase_shift .* ones(M, 1);  % LoS component (M by 1 vector)
    
    % NLoS component (Rayleigh fading)
    g_NLoS =  sqrt(1 / (K_factor + 1)) * (randn(M, 1) + 1i * randn(M, 1)) / sqrt(2);  % NLoS (Rayleigh)
    
    % Combine LoS and NLoS components
    h = sqrt(eta_LoS) .* g_LoS + sqrt(eta_NLoS) .* g_NLoS;
end


