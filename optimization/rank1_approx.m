function H_refined = rank1_approx(H)
    % Input: 
    % H: The input Hermitian matrix to approximate
    % num_randomizations: Number of Gaussian randomizations

    % Get the size of the Hermitian matrix
    n = size(H, 1);
    
    % Perform eigenvalue decomposition for initial rank-1 approximation
    [U, Lambda] = eig(H);
    [lambda_max, idx] = max(diag(Lambda)); % Get the largest eigenvalue
    u1 = U(:, idx);                        % Get the corresponding eigenvector
    H_refined = lambda_max * (u1 * u1'); % Initial rank-1 approximation
    
    % Initialize the best approximation error to a large value (optional)
%     best_error = inf;
%     H_refined = H_rank1_initial; % Initialize the refined matrix with the initial guess
%     
%     % Perform Gaussian randomization
%     for i = 1:num_randomizations
%         % Generate a random complex Gaussian vector
%         g = (randn(n, 1) + 1i * randn(n, 1)) / sqrt(2);
%         
%         % Create a rank-1 matrix from the random vector
%         H_random = g * g';
%         
%         % Compute the Frobenius norm of the error: ||H - H_random||_F^2
%         error = norm(H - H_random, 'fro')^2;
%         
%         % Update the best approximation if the error is lower
%         if error < best_error
%             best_error = error;
%             H_refined = H_random; % Update the refined rank-1 approximation
%         end
%     end
%     
%     % Display the results
%     disp('Initial rank-1 approximation error:');
%     disp(norm(H - H_rank1_initial, 'fro')^2);
%     
%     disp('Refined rank-1 approximation error:');
%     disp(best_error);
end
