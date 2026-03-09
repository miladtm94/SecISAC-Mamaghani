function result = solveOptimization(groundTerminalsLoc,eve_loc)

    result= struct();
    result.Evekeys=[];  % Initializing with a dummy field
    result.Channels = [];  % Initializing with a dummy field
    result.metrics = [];  % Initializing with a dummy field
    result.params = [];  % Initializing with a dummy field

    [BS_location, uplink_users, downlink_users] = groundTerminalsLoc{:};

    eve_key = eveLocationKey(eve_loc);

    communicationChannels = channelSim(BS_location, uplink_users, downlink_users,eve_loc);
    [A_0, zeta_0] = sensing_channel(BS_location, eve_loc);
    channels.comm = communicationChannels;
    channels.sensing1 = A_0;
    channels.sensing2 = zeta_0; 
    result.Evekeys = eve_key;  % Initializing with a dummy field
    result.Channels =  channels;


    params_init = power_optimization(eve_loc, channels, false);
    params_optimal = power_optimization(eve_loc, channels, true);
    [ucsr, dcsr, crlb,~,~,~] = metrics_calc(params_optimal, channels);
    result.metrics = [ucsr, dcsr, crlb]; 
    result.params = {params_init, params_optimal};

end