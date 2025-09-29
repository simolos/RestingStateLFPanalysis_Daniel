function TriggerVector = check_for_discontinuities(TriggerVector, LFP_struct, EMG_struct)

    % Description:
    %   Function to check if there are discontinuities in the LFP signal
    %   and set to zero all the triggers in the discontinuity window
    %   (except for trigger 4 - StartTrial)
    %   
    % Inputs:
    %   - TriggerVector: 1xN signal, N=length of the EMG recording.
    %       Contains all the triggers code sent out by arduino during the
    %       task, it is zero if no trigger was sent and nonzero in
    %       correspondance of the beginning of a phase of interest.
    %   - LFP_struct
    %   - EMG_struct
    %
    % Outputs:
    %   - TriggerVector: same as output but with zeros in case of signal
    %   discontinuity
    %
    % Created by Simona Losacco on 14/02/2025 

    LFP_time = LFP_struct.time;
    EMG_time = EMG_struct.time;

    zeroRegions = (LFP_struct.data(:,1) == 0)';
    DiscontinuityBoundaries = diff([0 zeroRegions 0]);
    zeroStart = find(DiscontinuityBoundaries == 1); % Indices where zero sequences start
    zeroEnd = find(DiscontinuityBoundaries == -1) - 1; % Indices where zero sequences end

    longIntervals = find((zeroEnd - zeroStart + 1) >= 100);

    Idx_start = zeroStart(longIntervals);
    Idx_end = zeroEnd(longIntervals);

    % Find triggers 4 (start trial)
    StartTrialIdx = find(TriggerVector == 4);

    for i = 1:length(Idx_start)
        TriggerVector(find( EMG_time >= LFP_time(Idx_start(i)), 1 ) : find( EMG_time >= LFP_time(Idx_end(i)), 1 )) = 0;
    end

    % Keep triggers 4
    TriggerVector(StartTrialIdx) = 4;


end