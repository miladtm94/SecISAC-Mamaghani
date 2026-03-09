function Power = calc_power(params)

    [P, V, W] = params{:};
     K = size(V,3);
     
     SumVk = 0;
        for k = 1:K
            SumVk = SumVk + V(:, :, k); % Sum beamforming matrices across users
        end

     Power = [trace(SumVk), trace(W), sum(P)];

end