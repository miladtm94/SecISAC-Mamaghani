function [NPC, UCSR, DCSR, CRLB] = Metrics_Comp(params, channels, params_clutter)
    % Load system parameters from params.m
    sysParams
    
    [Sigman, ~] = params_clutter{:};

    [P, V, W] = params{:};
    
    
    [h_la, h_el, h_lk, h_ak, h_ea] = channels.comm{:};
    [L, K]= size (h_lk);

    A_0 = channels.sensing1;
    zeta_0 = channels.sensing2;

    % Downlink Secrecy Rate (DCSR) metric
    gamma_k_dl = zeros(1,K);
    for k=1:K
   
        Term1 = 0;
        for kp = 1:K
            if kp~=k
                Term1 = Term1 + real(h_ak(:,k)'*V(:,:,kp)*h_ak(:,k));
            end
        end


        gamma_k_dl(k) = real(h_ak(:,k)'*V(:,:,k)*h_ak(:,k))/(sigma2k + real(h_ak(:,k)'*W*h_ak(:,k))+ ...
                 sum(P .* abs(h_lk(:,k)).^2, 1) + Term1);
    end
    
    SumVk = 0;
    for k=1:K
        SumVk = SumVk + V(:, :, k);
    end
    gamma_ea_dl = real(h_ea'*SumVk*h_ea) ./ (sigma2e + real(h_ea'*W*h_ea)+...
                        sum(P .* abs(h_el).^2,1));


    DCSR = max(min(log2(1 + gamma_k_dl) - log2(1 + (gamma_ea_dl))),0);



    % Uplink Secrecy Rate (UCSR) metric

    S = SumVk + W;

    gamma_la_ul = zeros(1,L);
    gamma_le_ul = zeros(1,L);

    for l=1: L
        Term1 =0;
        for lp=1:L
            if (lp~= l)
                Term1 = Term1 + P(lp)*real(h_la(:,lp)*h_la(:,lp)');
            end
        end
        % Applying optimal beamforming ul
        Psi = (Term1 + abs(zeta_0)^2 * real(A_0 * S * A_0') + Sigman);

        gamma_la_ul(l) = P(l)*real(h_la(:,l)'*(Psi^(-1))*h_la(:,l));


        Term2 =0;
        for lp=1:L
            if (lp~= l)
                Term2 = Term2 + P(lp)*abs(h_el(lp))^2;
            end
        end
        gamma_le_ul(l) = (P(l)*abs(h_el(l))^2)/(Term2+real(h_ea'*S*h_ea)+sigma2e);

    end

   
    UCSR = max(min(log2(1 + gamma_la_ul) - log2(1 + gamma_le_ul)), 0);


    % Cramér-Rao Lower Bound (CRLB) metric       
    X =  abs(zeta_0)*Sigman^(-1/2)* A_0;
    CRLB = (C_light^2) / (8 * gamma_BW^2 * B^2* real(trace(X' * S * X)));




     NPC  = trace(SumVk) + trace(W) + sum(P);

 end

