function [metrics, params] = observed_metrics(channels, eve_loc)
    
    global buffer

    eve_key = eveLocationKey(eve_loc); 
    % Find the index of the structure where 'eve_key' matches 
    index = find(strcmp({buffer.Evekeys} , eve_key));

    % Check if the metrics for this eve location are already calculated
    if ~isempty(buffer(index).metrics)
        % Retrieve cached values
        metrics = buffer(index).metrics;
        params = buffer(index).params;

    else
        % Perform calculations    
        params_init = power_optimization(eve_loc, channels, false);
        params_optimal = power_optimization(eve_loc, channels, true);
        [ucsr, dcsr, crlb,~,~,~] = metrics_calc(params_optimal, channels);
    
        metrics = [ucsr, dcsr, crlb];
        params = {params_init, params_optimal};

        % Store results in the 
        buffer(index).metrics = [ucsr, dcsr, crlb]; 
        buffer(index).params = {params_init, params_optimal};

    end

    
end