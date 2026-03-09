function [k3, k4] = find_thresholds(rho_ul, k4_min, k4_max, num_values)
    % Inputs:
    % rho_ul: the given rho^ul value
    % k4_min: minimum value of k4
    % k4_max: maximum value of k4
    % num_values: number of values to compute for k4 in the range

    % Generate a set of k4 values in the specified range
    k4_values = linspace(k4_min, k4_max, num_values);

    % Initialize the set of L values
    L = zeros(num_values, 2);
    
    % Loop over k4 values and compute the corresponding k3 values
    for i = 1:num_values
        k4(i) = k4_values(i);
        k3(i) = 2^rho_ul * (1 + k4(i)) - 1;
    end
end