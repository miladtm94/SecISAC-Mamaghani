function slackvars = initSlackVars(params,channels, CNR)

%% FEASIBLE INITIALIZATION OF SLACK VARIABLES

% Load system params
sysParams

Rc = CNR*sigma2*(1/Mr)*eye(Mr);
Sigman = (1/Mr)*(sigma2a+sigma2SI)*eye(Mr)+Rc;


[P_lo, V_lo, W_lo] = params{:};  

[h_la, h_el, h_lk, h_ak, h_ea] = channels.comm{:};

% Extract dimensions
[L, K]= size(h_lk);

A_0 = channels.sensing1;
zeta_0 = channels.sensing2;

H_ea = (h_ea*h_ea');

SumVk_lo = 0;
for k=1:K
    SumVk_lo = SumVk_lo + V_lo(:, :, k);
end

S_lo = SumVk_lo + W_lo;

[~,~,~, gamma_k_dl, gamma_ea_dl, gamma_la_ul, gamma_le_ul] ...
                                = metrics_calc(params, channels, CNR);


%% -------------------------------------------------
% Constraint (34c) for all k - Checked

mu_lo  = zeros(K+1,1);
% mu_lo(1:K)  = gamma_k_dl;


%%%%%%%%%  (34b) &  (43a)  %%%%%%%%%%%%% 

mu_lo(K+1) = gamma_ea_dl;


mu_lo(1:K)= 2^(rho_dl + log2(1+mu_lo(K+1)))-1 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% -------------------------------------------------
% Constraint (35c) for all l - Checked


omega_lo = zeros(2*L,1);

%%%%%%%%%%%%% (35a) & (46) %%%%%%%%%%%%%%%%%%%%%%%%%%

omega_lo(L+1:end) = gamma_le_ul;

omega_lo(1:L) = 2.^(rho_ul + log2(1+ omega_lo(L+1:end)))-1;


for l = 1:L
    Temp_lo = 0;
    for lp = 1:L
        if lp ~= l
            Temp_lo = Temp_lo + P_lo(lp) * real(h_la(:,lp) * h_la(:,lp)');
        end
    end
    Psi_lo = Temp_lo + abs(zeta_0)^2 * real(A_0 * S_lo * A_0') + Sigman; 
    
    QQ = real(h_la(:,l)' * (Psi_lo^(-1)) * h_la(:,l) - h_la(:,l)' ...
         * (Psi_lo^(-1)) * (Psi_lo-Psi_lo) * (Psi_lo^(-1))* h_la(:,l));
    
    omega_lo(l) = min(P_lo(l)* QQ, omega_lo(l));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% -------------------------------------------------
% Constraint 41 - Checked

t_lo = zeros(K+1,1);

for k = 1:K
    SumV_kp = 0;
    for kp = 1:K
        if (kp ~= k)
            SumV_kp = SumV_kp + V_lo(:, :, kp);
        end
    end
    H_ak = (h_ak(:, k) * h_ak(:, k)');
  
    t_lo(k) = sqrt(mu_lo(k)*sum(P_lo .* abs(h_lk(:, k)).^2) ...
                   + real(trace((SumV_kp + W_lo) * H_ak)) + sigma2k); 
end

t_lo(K+1) = sqrt(mu_lo(K+1) * (sum(P_lo .* abs(h_el).^2) ...
                   + real(trace(W_lo * H_ea)) + sigma2e));

%% -------------------------------------------------
% Constraint 44 - Checked

PP_lo = P_lo.*abs(h_el).^2;
s_lo = sqrt(PP_lo./omega_lo(L+1:end));

%% -------------------------------------------------
% Constraint 48 - Checked

  
iota_lo = sqrt(omega_lo(1:L));

%% -------------------------------------------------

slackvars.mu  = mu_lo;
slackvars.omega = omega_lo ;
slackvars.s = s_lo;
slackvars.t  =t_lo ;
slackvars.iota = iota_lo;

end