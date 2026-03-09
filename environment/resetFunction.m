%% Define Reset Function

% Reset function resets the environment at the start of each episode
function [InitialObservation,Info] = resetFunction(params) 
    q_f = params.finalLoc; 
    q_i = params.initLoc;
    dist2End = norm(q_i-q_f);
    
    InitialObservation = [q_i;dist2End; 0];
    
   

    Info.Loc = q_i;
    Info.Dist = dist2End;
    Info.Time = 0;
    Info.RecentPos = q_i;
    Info.VisitedPos = q_i;
end
