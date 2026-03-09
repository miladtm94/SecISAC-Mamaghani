function params = power_optimization(eve_loc, channels, optimize)

%% Resource allocation at the given Eve's location
if(~optimize)
    [params, ~]= feasible_initialization(channels);
%      checkFeasibility(params,channels, slackvars);
    fprintf("Resources initialized feasibly at Eve's location (%d,%d,%d).\n",eve_loc(1),eve_loc(2), eve_loc(3));
else

i = 1;
[params, slackvars]= feasible_initialization(channels);
% checkFeasibility(params,channels, slackvars);

[P, V, W] = params{:};

K = size(V,3);

SumVk = 0;
for k = 1:K
    SumVk = SumVk + V(:, :, k); % Sum beamforming matrices across users
end

% Calculate initial objective value without resource optimization
objVal = [];
objVal(i) =  (trace(SumVk) + trace(W) + sum(P));

% [UCSR, DCSR, CRLB, gamma_k_dl, gamma_ea_dl, gamma_la_ul, gamma_le_ul] = metrics(params, channels)

% Iterative solution until convergence
converged = false;
FE=[];
while (~converged)
    i = i + 1;
    [Prob1_Sol, slackvars] = OptimResources(params, channels, slackvars);
    V = Prob1_Sol.V_opt; % Optimized downlink user precoding covariance matrices
    W = Prob1_Sol.W_opt; % Optimized radar sensing covariance matrix
    P = Prob1_Sol.P_opt; % Optimized power allocation
    objVal(i) = Prob1_Sol.U1;
    params = {P,V,W};
    FE(i-1) = abs(objVal(i)- objVal(i-1)) /objVal(i-1);
    fprintf("Fractional Error at iteration #%d is %0.2f%%.\n",i-1, 100*FE(end));
%     checkFeasibility(params,channels, slackvars);
    if (abs(objVal(i)- objVal(i-1)) /objVal(i-1) < 1e-1)
        converged = true;
    end
end
fprintf("Algorithm is converged in %d iterations.\n", i-1);
fprintf("InitVal=%0.2f | OptVal = %0.2f. \n",objVal(1), objVal(end));

end
end