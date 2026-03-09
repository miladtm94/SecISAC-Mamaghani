%% setup.m
% Run this script ONCE at the start of a MATLAB session to add all
% project subfolders to the MATLAB path.
%
% Usage:
%   >> setup
%   >> main         % then run any entry-point script
%
% The paths are NOT saved permanently; run setup.m again if you restart
% MATLAB.

clc;
projectRoot = fileparts(mfilename('fullpath'));

subfolders = {
    'config',
    'environment',
    'agent',
    'optimization',
    'channel',
    'metrics',
    'utils',
    'plots',
    'benchmarks',
};

for i = 1:numel(subfolders)
    p = fullfile(projectRoot, subfolders{i});
    if isfolder(p)
        addpath(p);
    else
        warning('setup:missingFolder', 'Subfolder not found: %s', p);
    end
end

% Create data directory if it doesn't exist
dataDir = fullfile(projectRoot, 'data');
if ~isfolder(dataDir)
    mkdir(dataDir);
end

fprintf('==============================================\n');
fprintf('  SecureISAC-UAV-DRL — paths configured.\n');
fprintf('  Project root: %s\n', projectRoot);
fprintf('==============================================\n');
fprintf('  Next steps:\n');
fprintf('    1. Place required .mat files in data/\n');
fprintf('       - myBuffer.mat\n');
fprintf('       - myGroundTerminalDist.mat\n');
fprintf('       - ObstacleLocs.mat\n');
fprintf('    2. Run main.m to train or simulate.\n');
fprintf('==============================================\n');
