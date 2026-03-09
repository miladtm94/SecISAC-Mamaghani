function [Prob1_Sol, slackvars] = OptimResources_Clutter_WithoutAN(params, channels, slackvars,params_clutter)
    % This function optimizes power allocation (P_opt), communication beamforming matrices (V_opt),
    % and radar sensing/jamming beamforming matrix (W_opt) based on the system parameters and channel conditions.

    sysParams % Load system parameters 
    [Sigman, Pmax] = params_clutter{:};
    
    % Unpack the parameters: initial power (P_lo), beamforming (V_lo), radar signal (W_lo), etc.
    [P_lo, V_lo, W_lo] = params{:};
    
    % Unpack communication channels 
    [h_la, h_el, h_lk, h_ak, h_ea] = channels.comm{:};
    
    % Extract dimensions of the system
    [L, K] = size(h_lk); % L: number of users, K: number of communication links
    Mt = size(h_ak,1); % Mt: number of transmit antennas
    
    % Extract radar channel parameters
    A_0 = channels.sensing1;
    zeta_0 = channels.sensing2;
    
    % Compute Hermitian channel matrix
    H_ea = (h_ea * h_ea');

    % Sum all the initial beamforming matrices (Vk_lo) over all users
    SumVk_lo = 0;
    for k = 1:K
        SumVk_lo = SumVk_lo + V_lo(:, :, k);
    end
    
    % Compute the initial total covariance matrix (S_lo = sum of V_lo + radar matrix W_lo)
    S_lo = SumVk_lo + W_lo;

    % Initialize slack variables feasibly by calling an initSlackVars function that handles these variables
    mu_lo =     slackvars.mu;
    omega_lo =  slackvars.omega;
    s_lo =      slackvars.s;
    t_lo =      slackvars.t;
    iota_lo =   slackvars.iota;

    %% Begin the convex optimization process
    cvx_begin sdp quiet
        % Declare optimization variables
        variable V(Mt, Mt, K) hermitian semidefinite % Beamforming matrices for K users
        variable P(L,1) nonnegative % Power allocation vector for L uplink users
        variable mu_opt(K+1,1) nonnegative % Slack variables for constraint (34)
        variable omega(2*L,1) nonnegative % Slack variables for constraint (35)
        variable t(K+1,1) nonnegative % Slack variables for constraint (41)
        variable s(L,1) nonnegative % Slack variable vector for constraint (44)
        variable iota(L,1) nonnegative % Slack variable vector for constraint (48)
        


        % Objective function: Minimize total beamforming power, radar power, and user power
        SumVk = 0;
        for k = 1:K
            SumVk = SumVk + V(:, :, k); % Sum beamforming matrices across users
        end

%          slacks= -sum(omega(1:L))+sum(omega(L+1:end))-sum(t)...
%                  -sum(mu_opt(1:K)+mu_opt(1+K) +sum(iota) -sum(s));
%         

         minimize(trace(SumVk) + sum(P)) % Minimize total power
    
        subject to
            
            %% Constraint 33b: DCSR >= rho_UL   SINR constraint for DL user communication
            % constraint 34a: gamma_DL_k >=mu_k for all k
            for k = 1:K
                SumV_kp = 0; % Summation of interference from other users
                for kp = 1:K
                    if (kp ~= k)
                        SumV_kp = SumV_kp + V(:, :, kp); % Interference from other users
                    end
                end
                H_ak = (h_ak(:,k) * h_ak(:,k)'); % Channel matrix for user k
                
                % Constraint 41a
                sum(P .* abs(h_lk(:,k)).^2) + real(trace((SumV_kp) * H_ak)) + sigma2k ...
                    <= helperfunc(t(k), mu_opt(k), t_lo(k), mu_lo(k));

                % Constraint 41b
                square_pos(t(k)) <= real(trace(V(:,:,k) * H_ak));
            end
    
            % Constraint 34b: gamma_DL_ea <=mu_K+1
            % Constraint 43a
            quad_over_lin(t(K+1), mu_opt(K+1)) <= sum(P .* abs(h_el).^2) + sigma2e;
            
            % Constraint 43b
            LHS = 0; 
            for k = 1:K
                LHS = LHS + real(trace(V(:, :, k) * H_ea));
            end
            LHS <= -(t_lo(K+1))^2 + 2 * t(K+1) * t_lo(K+1);
        
            % Constraint 34c: log2(1+mu_k)-log2(1+mu_K+1)>=rho_DL for all k         
            log(1 + mu_opt(1:K)) - (log(1+mu_lo(K+1)) + (mu_opt(K+1) - mu_lo(K+1)) ./ (1 + mu_lo(K+1))) >= log(2) * rho_dl;
    
            
    
            %% Constraint 45: Radar sensing constraint   CRLB > rho_est
            % trace(X'*A*X) = trace(X'*sqrtm(A)*sqrtm(A)*X) = norm(sqrtm(A)*X,'fro')^2 
            %  X= Sigman^(-1/2)*A_0;
            % square_pos(norm(sqrtm(X)*S,'fro')) == trace(A_0 * S * A_0' * Sigman^(-1))
            % square_pos(norm(sqrtm(X)*S,'fro')) >= (C_light^2) / (8 * gamma_BW^2 * B^2 * abs(zeta_0)^2 * rho_est); 
            %real(trace(A_0 * S * A_0' * Sigman^(-1))) >= (C_light^2) / (8 * gamma_BW^2 * B^2 * abs(zeta_0)^2 * rho_est); 
            
            constant_rhs = (C_light^2) / (8 * gamma_BW^2 * B^2 * rho_est);
            X =  abs(zeta_0)*Sigman^(-1/2)* A_0;
            real(trace(X' * S_lo * X)+ trace((X'*((SumVk-SumVk_lo))*X))) >= constant_rhs;

            %% Constraint 35a/40b/(48a, 48b): UCSR constraint... \tilde{gamma_UL_l} >= omega_l  for all l
            S = SumVk;
            for l = 1:L
                Temp_lo = 0;
                Temp = 0;
                for lp = 1:L
                    if lp ~= l
                        Temp = Temp + P(lp) * real(h_la(:,lp) * h_la(:,lp)');
                        Temp_lo = Temp_lo + P_lo(lp) * real(h_la(:,lp) * h_la(:,lp)');
                    end
                end
                Psi = Temp + abs(zeta_0)^2 * real(A_0 * S * A_0')+ Sigman; 
                Psi_lo = Temp_lo + abs(zeta_0)^2 * real(A_0 * S_lo * A_0') + Sigman; 
                
            QQ = real(h_la(:,l)' * (Psi_lo^(-1)) * h_la(:,l) - h_la(:,l)' ...
                * (Psi_lo^(-1)) * (Psi-Psi_lo) * (Psi_lo^(-1))* h_la(:,l));


            Omega = quad_over_lin(iota(l),P(l)) - QQ;
            
            % Constraint (48a)
            Omega <= 0; 
           
                % Constraint (48b)
                omega(l) <= -(iota_lo(l))^2+2*iota(l)*iota_lo(l); % Helper function for power constraint
            end

            % Constraint 35b/(44a, 44b): 
            S = SumVk; 
            for l = 1:L
                Temp = 0;
                for lp = 1:L
                    if lp ~= l
                        Temp = Temp + P(lp) * abs(h_el(lp))^2;
                    end
                end
                % constraint (44a)
                square_pos(s(l)) <= (Temp + real(trace(S * H_ea)) + sigma2e); 
                
                PP_lo = P_lo(l) .* abs(h_el(l)).^2;
                PP = abs(h_el(l))^2 * P(l);

                % constraint (44b)
                inv_pos(omega(L+l)) <= helperfunc(s(l), PP, s_lo(l), PP_lo); 
        
                % Constraint 35c
                log(1 + omega(l)) - (log(1+omega_lo(L+l)) + (omega(L+l) - omega_lo(L+l)) ./ (1 + omega_lo(L+l))) >= log(2) * rho_ul;    
            end
    
            

            for k = 1:K
                V(:, :, k) >= 0; % Sum beamforming matrices across users
            end
            Pmax >= P >= 0;

                
    cvx_end

    
Prob1_Sol.V_opt = V; % Optimized downlink user precoding covariance matrices
Prob1_Sol.W_opt = W_lo; % Optimized radar sensing covariance matrix
Prob1_Sol.P_opt = P; % Optimized power allocation
Prob1_Sol.U1 = cvx_optval;

slackvars.mu  = mu_opt;
slackvars.omega = omega ;
slackvars.s = s;
slackvars.t  =t ;
slackvars.iota = iota;

end
