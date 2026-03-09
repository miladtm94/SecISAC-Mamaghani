function checkFeasibility(params,channels, slackvars)

%% FEASIBLE INITIALIZATION OF SLACK VARIABLES

% Initialize a feasibility flag
isFeasible = true;


% Load system params
sysParams

[P_lo, V_lo, W_lo] = params{:};  

[h_la, h_el, h_lk, h_ak, h_ea] = channels.comm{:};

% Extract dimensions
[L, K]= size (h_lk);

A_0 = channels.sensing1;
zeta_0 = channels.sensing2;

H_ea = (h_ea*h_ea');

SumVk_lo = 0;
for k=1:K
    SumVk_lo = SumVk_lo + V_lo(:, :, k);
end

S_lo = SumVk_lo + W_lo;


mu_lo = slackvars.mu;
omega_lo = slackvars.omega;
s_lo = slackvars.s;
t_lo = slackvars.t;
iota_lo = slackvars.iota;

%% -------------------------------------------------
% Constraint (34c) for all k - Checked

for k = 1:K
    LHS = log(1 + mu_lo(k)) - log(1+mu_lo(K+1));
    RHS = log(2) * rho_dl;

    Gap = abs(RHS - LHS);
    if LHS < RHS
        isFeasible = false;
        disp(['Constraint (34c) violated  for k = ', num2str(k), '. Gap: ', num2str(Gap)]);
    else
        disp(['Constraint (34c) satisfied for k = ', num2str(k), '. Gap: ', num2str(Gap)]);
    end
end

%% -------------------------------------------------
% Constraint 43 - Checked

RHS = sum(P_lo .* abs(h_el).^2)+real(trace(W_lo * H_ea)) + sigma2e;
LHS = (t_lo(K+1))^2 / mu_lo(K+1);

Gap = abs(LHS - RHS);
if LHS > RHS 
    isFeasible = false;
    disp(['Constraint (43a) violated            Gap: ', num2str(Gap)]);
else
    disp(['Constraint (43a) satisfied            Gap: ', num2str(Gap)]);

end

LHS = 0;
for k = 1:K
    LHS = LHS + real(trace(V_lo(:, :, k) * H_ea));
end

RHS = (t_lo(K+1))^2;

Gap = abs(LHS - RHS);
if LHS > RHS
    isFeasible = false;
    disp(['Constraint (43b) violated.           Gap: ', num2str(Gap)]);
else
    disp(['Constraint (43b) satisfied.           Gap: ', num2str(Gap)]);

end


%% -------------------------------------------------
% Constraint 41 - Checked

for k = 1:K
    SumV_kp = 0;
    for kp = 1:K
        if (kp ~= k)
            SumV_kp = SumV_kp + V_lo(:, :, kp);
        end
    end
    H_ak = (h_ak(:, k) * h_ak(:, k)');

    LHS = sum(P_lo .* abs(h_lk(:, k)).^2) + real(trace((SumV_kp + W_lo) * H_ak)) + sigma2k;
    
    RHS = helperfunc(t_lo(k), mu_lo(k), t_lo(k), mu_lo(k));

    Gap = abs(LHS - RHS);
    if LHS > RHS
        isFeasible = false;
        disp(['Constraint (41a) violated  for k = ', num2str(k), '. Gap: ', num2str(Gap)]);
    else
        disp(['Constraint (41a) satisfied for k = ', num2str(k), '. Gap: ', num2str(Gap)]);

    end

    LHS = t_lo(k)^2;
    V_k = V_lo(:,:,k);
    RHS = real(trace(V_k * H_ak));
    
    Gap = abs(LHS - RHS);
    if LHS > RHS
        isFeasible = false;
        disp(['Constraint (41b) violated  for k = ', num2str(k), '. Gap: ', num2str(Gap)]);
    else
        disp(['Constraint (41b) satisfied for k = ', num2str(k), '. Gap: ', num2str(Gap)]);

    end
end


%% -------------------------------------------------
% Constraint 45 - Checked
X =  abs(zeta_0)*Sigman^(-1/2)* A_0;
RHS = real(trace(X' * S_lo * X));
LHS = (C_light^2) / (8 * gamma_BW^2 * B^2 * rho_est);


Gap = abs(RHS - LHS);
if LHS > RHS
    isFeasible = false;
    disp(['Constraint (45)    violated            Gap: ', num2str(Gap)]);
else
        disp(['Constraint (45)  satisfied            Gap: ', num2str(Gap)]);

end

%% -------------------------------------------------
% Constraint 44 - Checked

for l = 1:L
    Temp = 0;
    for lp = 1:L
        if lp ~= l
            Temp = Temp + P_lo(lp) * abs(h_el(lp))^2;
        end
    end

    LHS = s_lo(l)^2;
    RHS = Temp + real(trace(S_lo * H_ea)) + sigma2e;

    Gap = abs(LHS - RHS);
    if LHS > RHS
        isFeasible = false;
        disp(['Constraint (44a) violated for l = ', num2str(l), '. Gap: ', num2str(Gap)]);
    else
       disp(['Constraint (44a) satisfied for l = ', num2str(l), '. Gap: ', num2str(Gap)]);

    end

    LHS = 1 / omega_lo(L+l);
    PP_lo = P_lo(l).*abs(h_el(l)).^2;
    RHS = helperfunc(s_lo(l), PP_lo, s_lo(l), PP_lo);
    
    Gap = abs(LHS - RHS);
    if LHS > RHS
        isFeasible = false;
        disp(['Constraint (44b) violated  for l = ', num2str(l), '. Gap: ', num2str(Gap)]);
    else
       disp(['Constraint (44b) satisfied for l = ', num2str(l), '. Gap: ', num2str(Gap)]);
    end
end


%% -------------------------------------------------
% Constraint 48 - Checked

for l = 1:L
    Temp_lo = 0;
    for lp = 1:L
        if lp ~= l
            Temp_lo = Temp_lo + P_lo(lp) * real(h_la(:, lp) * h_la(:, lp)');
        end
    end
    Psi_lo = (Temp_lo + abs(zeta_0)^2 * real(A_0 * S_lo * A_0') + Sigman);
       
 QQ = real(h_la(:,l)' * (Psi_lo^(-1)) * h_la(:,l) - h_la(:,l)' ...
         * (Psi_lo^(-1)) * (Psi_lo-Psi_lo) * (Psi_lo^(-1))* h_la(:,l));

    Omega = (iota_lo(l))^2/P_lo(l) - QQ;

    Gap = abs(Omega);
    if Omega > 0
        isFeasible = false;
        disp(['Constraint (48a) violated  for l = ', num2str(l), '. Gap: ', num2str(Gap)]);
    else
       disp(['Constraint (48a) satisfied for l = ', num2str(l), '. Gap: ', num2str(Gap)]);
    end

    LHS = omega_lo(l);
    RHS = iota_lo(l)^2;

    Gap = abs(LHS - RHS);
    if LHS > RHS
        isFeasible = false;
        disp(['Constraint (48b) violated  for l = ', num2str(l), '. Gap: ', num2str(Gap)]);
    else
        disp(['Constraint (48b) satisfied for l = ', num2str(l), '. Gap: ', num2str(Gap)]);

    end
end
%% -------------------------------------------------
% Constraint (35c) for all l - Checked

for l = 1:L
    LHS = log(1 + omega_lo(l)) - (log(1 + omega_lo(L+l)) ...
            + (omega_lo(L+l) - omega_lo(L+l)) / (1 + omega_lo(L+l)));
    RHS = log(2) * rho_ul;

    Gap = abs(RHS - LHS);
    if LHS < RHS
        isFeasible = false;
        disp(['Constraint (35c) violated  for l = ', num2str(l), '. Gap: ', num2str(Gap)]);
    else
        disp(['Constraint (35c) satisfied for l = ', num2str(l), '. Gap: ', num2str(Gap)]);
    end
end


if (min(eig(W_lo)) <= 0 || ~ishermitian(W_lo))
    isFeasible = false;
    disp('W is not hermitian PSD.');

end
for k=1:K
    if(min(eig(V_lo(:,:,k))) <= 0 || ~ishermitian(V_lo(:,:,k)))
         isFeasible = false;
          fprintf('V_%d is not hermitian PSD.', k);

    end
end
if(any(P_lo < 0))
    isFeasible = false;
    disp('Some power values are negative.');

end


%% -------------------------------------------------
% Final feasibility result
if isFeasible
    disp('All constraints are feasible.');
else
    disp('Some constraints are violated.');
end


end