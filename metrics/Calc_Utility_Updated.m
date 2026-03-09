function Utility = Calc_Utility_Updated(traj, lambda)

N = size(traj,2)-1;
U2_Proposed = zeros(1,N);
U1_Baseline = zeros(1,N);
U2_Benchmark = zeros(1,N);
U1_Proposed = zeros(1,N);
U1_WithoutAN = zeros(1,N);

P_f = zeros(1,N);
Pmax_flight = 607.9678;

for n=1:N
    q_current = traj(:,n);
    q_next = traj(:,n+1);

    % Flight Power Consumption
    normv_xy = norm([q_next(1) - q_current(1), q_next(2) - q_current(2)]); % Velocity in x-y plane
    normv_z = abs(q_next(3) - q_current(3)); % Velocity in z-direction
    

    P_f(n) = flightPow(normv_xy, normv_z); % Compute power consumption based on velocity components

    [U1_Proposed(n), U1_Baseline(n), U1_WithoutAN(n)] = calc_U1(q_next);
    % Objective function of Player 2
    U2_Proposed(n) =  (lambda * U1_Proposed(n) - (1-lambda) * P_f(n));
    U2_Baseline(n) =  (lambda * U1_Baseline(n) - (1-lambda) * P_f(n));
    U2_WithoutAN(n) =  (lambda* U1_WithoutAN(n) - (1-lambda) * P_f(n));

end

Utility = [sum(U2_Proposed), sum(U2_Baseline), sum(U2_WithoutAN)];


end