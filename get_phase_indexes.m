function [TableIndexes_LFP_referred, behav_table, TI_struct] = get_phase_indexes(TriggerVector, LFP_struct, EMG_struct, behav_table)

    % Description:
    %   Function to extract, for each trial, the indexes of the phases of
    %   interest in the LFP timeframe. It handles the following exceptions:
    %      - anticipationEP --> not all phases exist --> indexes set to [0 0] 
    %      - DM time expired --> not all phases exist --> indexes set to [0 0] 
    % Inputs:
    %   - TriggerVector: 1xN signal, N=length of the EMG recording.
    %       Contains all the triggers code sent out by arduino during the
    %       task, it is zero if no trigger was sent and nonzero in
    %       correspondance of the beginning of a phase of interest.
    %   - LFP_struct
    %   - EMG_struct
    %   - behav_table: TxN table, T=number of trials in the block under
    %       analysis, P=number of phases of interest + 4 (columns for Subj, 
    %       Phase, Block and Trial codes)
    % 
    % Outputs:
    %   - TableIndexes_LFP_referred: TxP table, T=number of trials, 
    %       P=number of phases of interest. Each column is a 2x1 array, 
    %       containing the trigger index of beginning and end of the phase   
    %       of interest, referred to the LFP recording. The array is set 
    %       to [0 0] in case the phase of interest does not exist for the 
    %       specific trial (e.g. only DM trial)
    %
    % Created by Simona Losacco on 05/01/2025

    
    LFP_time = LFP_struct.time;
    EMG_time = EMG_struct.time;
    EMG_Fs = EMG_struct.Fs;

    TI_struct = struct();
    if contains(behav_table.Block, 'RS')
        % Get triggers numbers for each phase and each trial
        TableTriggers = get_phase_triggers(1, behav_table);
        % Get all indexes (EMG referred) for the beginning of trials
        StartTrial = find( TriggerVector == 1);


        % The following is to handle mismatch between number of trials in
        % TableTriggers and StartTrial
        if length(StartTrial)-behav_table.Trial(end) ~= 0
            warning on 
            warning('Found %d triggers for trial beginning, but the behavioral file contains only %d trials', length(StartTrial), behav_table.Trial(end))
            warning('--> deleting the last %d trials', length(StartTrial)-behav_table.Trial(end))
            warning off 
            OriginalStartTrial = StartTrial; % This is needed to define the end of CurrentTrialTriggers in case of exception
            StartTrial(behav_table.Trial(end)+1:end) = [];
            HandleDisconnectionExeption = 1;
        else
            HandleDisconnectionExeption = 0;
        end

        % Create TI structure if TI trigger exists
        if ismember('TI', TableTriggers.Properties.VariableNames)
            TI_struct.TI_trig_LFP_referred = find( LFP_time >= EMG_time(find(TriggerVector == TableTriggers{1, 'TI'})), 1 );
            behav_table.TI_trigger = repelem(TI_struct.TI_trig_LFP_referred, size(behav_table,1))';
        end

        TableIndexes = table();
        TrashedTrials = [];
    
        for i=1:length(StartTrial) % Loop over trials
            
            disp(i)
            % Isolate only the triggers in the specific trial window --> double
            % check for missing triggers due to lost connection! No risk of 
            % working on triggers from other trials 
            if i ~= length(StartTrial) || HandleDisconnectionExeption
    
                if HandleDisconnectionExeption
                    CurrentTrialTriggers = TriggerVector(StartTrial(i) : OriginalStartTrial(i+1));
                else 
                    CurrentTrialTriggers = TriggerVector(StartTrial(i) : StartTrial(i+1));
                end
    
            else % Last trial exception
                CurrentTrialTriggers = TriggerVector(StartTrial(i) : end);
            end
    
            % Check existance of all triggers (handling disconnection issues)
            if numel(find(CurrentTrialTriggers ~= 0)) == 2
                % If only StartTrial exists, mark the trial as trashed
                TrashedTrials = [TrashedTrials i];
                continue
            end


            if ismember('B0', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('B0')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                TableIndexes{i, 'B0'} = [find(CurrentTrialTriggers == TableTriggers.B0(i,1)) find(CurrentTrialTriggers == TableTriggers.B0(i,2), 1, 'first')] + StartTrial(i);
            else
                TableIndexes{i, 'B0'} = [0 0];
            end

            if ismember('Stim1', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('Stim1')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                TableIndexes{i, 'Stim1'} = [find(CurrentTrialTriggers == TableTriggers.Stim1(i,1), 1, 'first') find(CurrentTrialTriggers == TableTriggers.Stim1(i,2))] + StartTrial(i);
            else
                TableIndexes{i, 'Stim1'} = [0 0];
            end

            if ismember('B1', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('B1')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                TableIndexes{i, 'B1'} = [find(CurrentTrialTriggers == TableTriggers.B1(i,1)) find(CurrentTrialTriggers == TableTriggers.B1(i,2), 1, 'last')] + StartTrial(i);
            else
                TableIndexes{i, 'B1'} = [0 0];
            end

            if ismember('Stim2', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('Stim2')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                TableIndexes{i, 'Stim2'} = [find(CurrentTrialTriggers == TableTriggers.Stim2(i,1), 1, 'last') find(CurrentTrialTriggers == TableTriggers.Stim2(i,2))] + StartTrial(i);
            else
                TableIndexes{i, 'Stim2'} = [0 0];
            end

            if ismember('B2', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('B2')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                TableIndexes{i, 'B2'} = [find(CurrentTrialTriggers == TableTriggers.B2(i,1)) find(CurrentTrialTriggers == TableTriggers.B2(i,2))] + StartTrial(i);
            else
                TableIndexes{i, 'B2'} = [0 0];
            end
        end

    else
        EP_flag = behav_table.EffortProd;
        EP_Anticip_flag = behav_table.AnticipationEP;
        DM_Timeout = behav_table.Acceptance;
    
        % Get triggers numbers for each phase and each trial
        TableTriggers = get_phase_triggers(EP_flag, behav_table);
        % Get all indexes (EMG referred) for the beginning of trials
        StartTrial = find( TriggerVector == TableTriggers.Intertrial(1,1)); 
        
        % The following is to handle mismatch between number of trials in
        % TableTriggers and StartTrial
        if length(StartTrial)-behav_table.Trial(end) ~= 0
            warning on 
            warning('Found %d triggers for trial beginning, but the behavioral file contains only %d trials', length(StartTrial), behav_table.Trial(end))
            warning('--> deleting the last %d trials', length(StartTrial)-behav_table.Trial(end))
            warning off 
            OriginalStartTrial = StartTrial; % This is needed to define the end of CurrentTrialTriggers in case of exception
            StartTrial(behav_table.Trial(end)+1:end) = [];
            HandleDisconnectionExeption = 1;
        else
            HandleDisconnectionExeption = 0;
        end
    
        % Create TI structure if TI trigger exists
        if ismember('TI', TableTriggers.Properties.VariableNames)
            TI_struct.TI_trig_LFP_referred = find( LFP_time >= EMG_time(find(TriggerVector == TableTriggers{1, 'TI'})), 1 );
            behav_table.TI_trigger = repelem(TI_struct.TI_trig_LFP_referred, size(behav_table,1))';
        end
    
        TableIndexes = table();
        TrashedTrials = [];
    
        for i=1:length(StartTrial) % Loop over trials
            disp(i)
            % Isolate only the triggers in the specific trial window --> double
            % check for missing triggers due to lost connection! No risk of 
            % working on triggers from other trials 
            if i ~= length(StartTrial) || HandleDisconnectionExeption
    
                if HandleDisconnectionExeption
                    CurrentTrialTriggers = TriggerVector(StartTrial(i) : OriginalStartTrial(i+1));
                else 
                    CurrentTrialTriggers = TriggerVector(StartTrial(i) : StartTrial(i+1));
                end
    
            else % Last trial exception
                CurrentTrialTriggers = TriggerVector(StartTrial(i) : end);
            end
    
            % Check existance of all triggers (handling disconnection issues)
            if numel(find(CurrentTrialTriggers ~= 0)) == 2
                % If only StartTrial exists, mark the trial as trashed
                TrashedTrials = [TrashedTrials i];
                continue
            end
    
            % The second condition checks whether the trigger actually exists (might not be the case if disconnection)
            if ismember('Intertrial', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.( 'Intertrial')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                TableIndexes{i, 'Intertrial'} = [find(CurrentTrialTriggers == TableTriggers.Intertrial(i,1), 1, 'first') find(CurrentTrialTriggers == TableTriggers.Intertrial(i,2))-1] + StartTrial(i); % StartTrial(i) to compensate for working only in the specific trial indexes 
            else
                TableIndexes{i, 'Intertrial'} = [0 0];
            end
    
            if ismember('ShowEffort', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.( 'ShowEffort')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                % Here I take the last because, in case of anticipation, there
                % is a second attempt and the GetReady is shown again --> I
                % take the first trigger, the effort presentation phase is not
                % repeated!
                TableIndexes{i, 'ShowEffort'} = [find(CurrentTrialTriggers == TableTriggers.ShowEffort(i,1)) find(CurrentTrialTriggers == TableTriggers.ShowEffort(i,2), 1, 'first')] + StartTrial(i);
            else
                TableIndexes{i, 'ShowEffort'} = [0 0];
            end
    
            if ismember('PrepDM', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.( 'PrepDM')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                TableIndexes{i, 'PrepDM'} = [find(CurrentTrialTriggers == TableTriggers.PrepDM(i,1)) find(CurrentTrialTriggers == TableTriggers.PrepDM(i,2))] + StartTrial(i);
            else
                TableIndexes{i, 'PrepDM'} = [0 0];
            end
    
            if ismember('DM_PreYN', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.( 'DM_PreYN')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                if DM_Timeout(i) ~= 2 % If the decision was made before the timeout            
                    TableIndexes{i, 'DM_PreYN'} = [find(CurrentTrialTriggers == TableTriggers.DM_PreYN(i,1)) find(CurrentTrialTriggers == TableTriggers.DM_PreYN(i,2))] + StartTrial(i);
                else 
                    % This phase doesn't exist if the decision was not made at all!
                    TableIndexes{i, 'DM_PreYN'} = [0 0];
                end
            else
                TableIndexes{i, 'DM_PreYN'} = [0 0];
            end
    
            % TableIndexes{i, 'DM_PreYN_common'} = [];
    
            % 'first' or 'last' because trigger 5 codifies two different moments of the task!! No problem if we change triggers, will keep working also in case there is only one value found
            
            
            if EP_flag(i) == 1
    
                if ismember('DM_PostYN', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('DM_PostYN')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                    if DM_Timeout(i) ~= 2 % If the decision was made before the timeout
                        TableIndexes{i, 'DM_PostYN'} = [find(CurrentTrialTriggers == TableTriggers.DM_PostYN(i,1)) find(CurrentTrialTriggers == TableTriggers.DM_PostYN(i,2), 1, 'first')] + StartTrial(i);  
                    else
                        % This phase doesn't exist if the decision was not made at all!
                        TableIndexes{i, 'DM_PostYN'} = [0 0];
                    end
                else
                    TableIndexes{i, 'DM_PostYN'} = [0 0];
                end
    
            else
    
                if i ~= length(StartTrial)
                    if ismember('DM_PostYN', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('DM_PostYN')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                        TableIndexes{i, 'DM_PostYN'} = [find(CurrentTrialTriggers == TableTriggers.DM_PostYN(i,1)) find(CurrentTrialTriggers == TableTriggers.DM_PostYN(i,2), 1, 'last')] + StartTrial(i);
                    else
                        TableIndexes{i, 'DM_PostYN'} = [0 0];
                    end
                else % handling last trial exception --> 1s after the decision the block is over
                    if ismember('DM_PostYN', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('DM_PostYN')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                        TableIndexes{i, 'DM_PostYN'} = [find(CurrentTrialTriggers == TableTriggers.DM_PostYN(i,1)) find(CurrentTrialTriggers == TableTriggers.DM_PostYN(i,1)) + round(EMG_Fs)] + StartTrial(i);
                    else
                        TableIndexes{i, 'DM_PostYN'} = [0 0];
                    end
                end
            end
    
            if ismember('Hold', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('Hold')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                TableIndexes{i, 'Hold'} = [find(CurrentTrialTriggers == TableTriggers.Hold(i,1), 1, 'first') find(CurrentTrialTriggers == TableTriggers.Hold(i,2), 1, 'last')] + StartTrial(i);
            else
                TableIndexes{i, 'Hold'} = [0 0];
            end
    
            if EP_Anticip_flag(i) ~= 1 % If the EP was not anticipated
                if ismember('PrepEP', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('PrepEP')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                    TableIndexes{i, 'PrepEP'} = [find(CurrentTrialTriggers == TableTriggers.PrepEP(i,1), 1, 'last') find(CurrentTrialTriggers == TableTriggers.PrepEP(i,2), 1, 'last')] + StartTrial(i);
                else
                    TableIndexes{i, 'PrepEP'} = [0 0];
                end
    
                if ismember('EP', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('EP')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                    TableIndexes{i, 'EP'} = [find(CurrentTrialTriggers == TableTriggers.EP(i,1)) find(CurrentTrialTriggers == TableTriggers.EP(i,2))] + StartTrial(i);
                else
                    TableIndexes{i, 'EP'} = [0 0];
                end
                
                if ismember('WaitFeedb', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('WaitFeedb')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                    TableIndexes{i, 'WaitFeedb'} = [find(CurrentTrialTriggers == TableTriggers.WaitFeedb(i,1)) find(CurrentTrialTriggers == TableTriggers.WaitFeedb(i,2))] + StartTrial(i);
                else
                    TableIndexes{i, 'WaitFeedb'} = [0 0];
                end
    
                if i ~= length(StartTrial) 
                    if ismember('Feedb', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('Feedb')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                        TableIndexes{i, 'Feedb'} = [find(CurrentTrialTriggers == TableTriggers.Feedb(i,1)) find(CurrentTrialTriggers == TableTriggers.Feedb(i,2), 1, 'last')] + StartTrial(i);
                    else 
                        TableIndexes{i, 'Feedb'} = [0 0];
                    end
                else % handling last trial exception --> 1s after the feedback the EP fam is over!
                    if ismember('Feedb', TableTriggers.Properties.VariableNames) && all(ismember(TableTriggers.('Feedb')(i,:), CurrentTrialTriggers(CurrentTrialTriggers~=0))) 
                        TableIndexes{i, 'Feedb'} = [find(CurrentTrialTriggers == TableTriggers.Feedb(i,1)) find(CurrentTrialTriggers == TableTriggers.Feedb(i,1)) + round(EMG_Fs)] + StartTrial(i);
                    else
                        TableIndexes{i, 'Feedb'} = [0 0];
                    end
                end
    
             
            else
                % Those phases doesn't exist if the EP was anticipated!
                TableIndexes{i, 'PrepEP'} = [0 0];
                TableIndexes{i, 'EP'} = [0 0];
                TableIndexes{i, 'WaitFeedb'} = [0 0];
                TableIndexes{i, 'Feedb'} = [0 0];
            end
        end
    end


    % Deleting invalid trials (having indeces = 0 because of
    % discontinuities)
    if ~isempty(TrashedTrials)
        warning on;
        warning('Discontinuities found, deleting trials: %s', num2str(TrashedTrials))
        warning off;
        TableIndexes(TrashedTrials, :) = [];
        behav_table(TrashedTrials, :) = [];
    end


    % Referring the indexes from EMG to LFP recording
    TableIndexes_LFP_referred = TableIndexes;

    for i=1:size(TableIndexes, 1)
        for j=1:size(TableIndexes, 2)
            for k=1:size(TableIndexes{i,j},2)
                if TableIndexes{i,j}(k) ~= 0
                    TableIndexes_LFP_referred{i,j}(k) = find( LFP_time >= EMG_time(TableIndexes{i,j}(k)), 1 );
                end                   
            end
        end
    end

            
end