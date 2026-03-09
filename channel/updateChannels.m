function channels = updateChannels(groundTerminalsLoc,eve_loc)
    
global buffer
% Declare the buffer as a global variable

[BS_location, uplink_users, downlink_users] = groundTerminalsLoc{:};

% Create a unique key for the eve location

eve_key = eveLocationKey(eve_loc);

% Initialize the buffer if it is empty
if isempty(buffer)
    buffer= struct();
    buffer.Evekeys=[];  % Initializing with a dummy field
    buffer.Channels = [];  % Initializing with a dummy field
    buffer.metrics = [];  % Initializing with a dummy field
    buffer.params = [];  % Initializing with a dummy field
    counter = 1;
end

% Find the index of the structure where 'eve_key' matches 
index = find(strcmp({buffer.Evekeys} , eve_key),1);

% Retrieve cached values
if ~isempty(index)
    channels = buffer(index).Channels;
else
    counter = numel(buffer)+1;
    buffer(counter).Evekeys=[];  % Initializing with an empty field
    buffer(counter).Channels = [];  % Initializing with  an empty
    buffer(counter).metrics = [];  % Initializing with an empty
    buffer(counter).params = [];  % Initializing with  an empty

    % Perform calculations 
    communicationChannels = channelSim(BS_location, uplink_users, downlink_users,eve_loc);
    [A_0, zeta_0] = sensing_channel(BS_location, eve_loc);
    channels.comm = communicationChannels;
    channels.sensing1 = A_0;
    channels.sensing2 = zeta_0; 

    % Store results in the buffer
    buffer(counter).Evekeys = eve_key;  % Initializing with a dummy field
    buffer(counter).Channels =  channels;

end

end



