function y_filled = fill_to_maxIter(y, maxIter)
    % Find the last non-NaN, positive value
    idx = find(~isnan(y) & y > 0, 1, 'last');
    if isempty(idx)
        y_filled = zeros(1, maxIter); % all zero if empty
    else
        y_filled = y;
        y_filled(idx+1:maxIter) = y(idx); % repeat last valid value
    end
end