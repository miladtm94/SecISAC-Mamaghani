function fullFilePath = getResultsFolderPath(networkSelection,lambda)

lambda_txt = sprintf("lambda%0.2f",lambda);
lambda_txt = strrep(lambda_txt, '.', '_');  % Replace '-' with '_'

if networkSelection==1
    filename= sprintf("TrainedAgent_%s_%s.mat", "Smart",lambda_txt);
else
    filename= sprintf("TrainedAgent_%s_%s.mat", "Dumb",lambda_txt);
end


% Define the folder path for Results
folderPath = '~/Results'; % Change this to your desired folder path

% Create the folder if it doesn't exist
if ~exist(folderPath, 'dir')
    mkdir(folderPath);
end

% Construct the full file path
fullFilePath = fullfile(folderPath, filename);

end