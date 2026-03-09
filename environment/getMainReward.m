function U2 = getMainReward(q_current,q_next,  params,networkSelection)
 
buffer = params.buffer;
lambda = params.lambda;
Pmax_flight = 607.9678;

%% Flight Power Consumption
v_xy = norm([q_next(1) - q_current(1), q_next(2) - q_current(2)]); % Velocity in x-y plane
v_z = abs(q_next(3) - q_current(3)); % Velocity in z-direction
P_f = flightPow(v_xy, v_z); % Compute power consumption based on velocity components
P_f = P_f/Pmax_flight; % normalize by max
%% Communication and radar power consumption   
eve_key = eveLocationKey(q_next);
index = find(strcmp({buffer.Evekeys}, eve_key), 1);

if (networkSelection) 
    % Smart network
    U1 = buffer(index).U1;
    U1 = U1/5.2190e+03; % normalize
else 
    % Dumb network
    power_init = buffer(index).params(1);
    SumP_init = sum(cell2mat(power_init{:}(1)));
    SumVk_init = trace(sum(cell2mat(power_init{:}(2)),3));
    SumW_init=  trace(cell2mat(power_init{:}(3)));
    U1 = SumP_init + SumVk_init + SumW_init;
    U1 = U1/2.0662e+07; % normalize by max
end

U2 =  lambda* U1 - (1-lambda) * P_f;

end