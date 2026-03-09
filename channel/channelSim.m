function channels = channelSim(RBS_loc, ul_users_loc, dl_users_loc, eve_loc)
    %% Simulate Channels
    
    % Load system parameters from params.m
    sysParams

    L =  size(ul_users_loc,2);
    K =  size(dl_users_loc,2);
    
    % Generate Rician Channels at timeslot
    h_la = zeros(Mr, L);
    h_el = zeros(L,1);
    h_lk = zeros(L,K);
    h_ak = zeros(Mt, K);
    h_ea = zeros(Mt,1);

        
    for l=1:L
        % Uplink channel (user l to R-BS)
        h_la(:,l) = rician_channel(Mr, ul_users_loc(:,l), RBS_loc);  % UL: Rx antennas at BS
    
        %Eavesdropping channel in uplink
        h_el(l) = rician_channel(1, eve_loc, ul_users_loc(:,l));  % Eavesdropper intercepting uplink
    end
    
    % Downlink channel (base station to DL user k)
    
    for k=1: K
        h_ak(:,k) = rician_channel(Mt, RBS_loc, dl_users_loc(:,k));  % DL: Tx antennas at BS
    end
    
    % Eavesdropping channel in downlink
    h_ea = rician_channel(Mt, RBS_loc, eve_loc);    % Eavesdropper intercepting downlink
    
    for l=1:L
        for k=1:K
            h_lk(l,k) = rician_channel(1, ul_users_loc(:,l), dl_users_loc(:,k));
        end
    end

    channels = {h_la, h_el, h_lk, h_ak, h_ea};

end