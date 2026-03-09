function filename1 = getEpisodeTrajName(lambda,networkSelection)

lambda_txt = sprintf("lambda%0.2f",lambda);
lambda_txt = strrep(lambda_txt, '.', '_');  % Replace '-' with '_'
if (networkSelection)
    filename1= sprintf("visitedPositionsPerEpisode_%s_%s.mat","Smart",lambda_txt);
else
    filename1= sprintf("visitedPositionsPerEpisode_%s_%s.mat","Dumb",lambda_txt);

end
    filename1 = fullfile('~/GitHub/SecureISAC/Results', filename1);

end