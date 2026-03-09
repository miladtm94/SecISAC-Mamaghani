function Utility = calculate_utility(traj, buffer, lambda)

N = size(traj,2)-1;
Player1 = zeros(1,N);
Player2 = zeros(1,N);
U1_init = zeros(1,N);
U2_init = zeros(1,N);
P_f = zeros(1,N);
Pmax_flight = 607.9678;

for n=1:N
    q_current = traj(:,n);
    q_next = traj(:,n+1);

    % Flight Power Consumption
    normv_xy = norm([q_next(1) - q_current(1), q_next(2) - q_current(2)]); % Velocity in x-y plane
    normv_z = abs(q_next(3) - q_current(3)); % Velocity in z-direction
    

    P_f(n) = flightPow(normv_xy, normv_z)/Pmax_flight; % Compute power consumption based on velocity components

    eve_key = eveLocationKey(q_next);
    index = find(strcmp({buffer.Evekeys}, eve_key), 1);
    
    % Objective function of Player 1
    Player1(n) = buffer(index).U1 /5.2190e+03;
    

    power_init = buffer(index).params(1);
    SumP_init = sum(cell2mat(power_init{:}(1)));
    SumVk_init = trace(sum(cell2mat(power_init{:}(2)),3));
    SumW_init=  trace(cell2mat(power_init{:}(3)));
    U1_init(n) = (SumP_init + SumVk_init + SumW_init)/2.0662e+07;
    
    % Objective function of Player 2
    Player2(n) =  (lambda * Player1(n) - (1-lambda) * P_f(n));
    U2_init(n) =  (lambda* U1_init(n) - (1-lambda) * P_f(n));

end

Utility = [sum(Player2), sum(U2_init)];


end