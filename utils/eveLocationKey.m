function eve_key = eveLocationKey(eve_loc)
        % Create a unique key for the eve location
    eve_key = sprintf('(%d, %d, %d)', eve_loc(1), eve_loc(2), eve_loc(3));
    eve_key = strrep(eve_key, '-', 'n');  % Replace '-' with 'n'
    % eve_key = strrep(eve_key, '.', '_');  % Replace '-' with 'n'

end