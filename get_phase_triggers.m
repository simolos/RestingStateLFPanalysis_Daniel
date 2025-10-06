function [TableTrig] = get_phase_triggers(EP_flag, behav_table)
    
    % Description:
    %   Function to define, for each phase of the task, the indexes of the 
    %   triggers for each phase of interest. This has to be modified in
    %   case the trigger decoding changes or there is a new phase of
    %   interest.
    %   
    % Inputs:
    %   - EP_flag: vector Tx1, T=number of trials of the block under
    %       analysis. 
    %
    % Outputs:
    %   - TableTrig: TxP table, T=number of trials, P=number of phases of
    %       interest. Each column is a 2x1 array, containing the trigger 
    %       number of beginning and end of the phase of interest, defined  
    %       by the number of bursts sent through arduino. The array is set 
    %       to [0 0] in case the phase of interest does not exist for the 
    %       specific trial (e.g. only DM trial)
    %
    % Created by Simona Losacco on 05/01/2025

    
    TableTrig = table();

    if contains(behav_table.Block{1}, 'EffProd') % EP familiarization

         for i=1:length(EP_flag) % Loop over the trials
    
            TableTrig{i, 'Intertrial'} = [4 2]; 
            TableTrig{i, 'ShowEffort'} = [2 1]; 
            TableTrig{i, 'Hold'} = [1 3]; 
            TableTrig{i, 'PrepEP'} = [3 8];
            TableTrig{i, 'EP'} = [8 10]; 
            TableTrig{i, 'Feedb'} = [10 4]; 
          
        end


    elseif contains(behav_table.Block{1}, 'B') || contains(behav_table.Block{1}, 'FCRT')   % Task blocks

        for i=1:length(EP_flag) % Loop over the trials
    
            TableTrig{i, 'Intertrial'} = [4 7];
            TableTrig{i, 'PrepDM'} = [7 1];
            TableTrig{i, 'DM_PreYN'} = [1 2];
            % TableTrig{i, 'DM_PreYN_common'} = [];
    
            if EP_flag(i) == 1
                % Consider also Hold phase and EP 
                TableTrig{i, 'DM_PostYN'} = [2 5]; % from DMade to Hold
                TableTrig{i, 'Hold'} = [5 5]; 
                TableTrig{i, 'PrepEP'} = [5 8];
                TableTrig{i, 'EP'} = [8 3]; 
                TableTrig{i, 'WaitFeedb'} = [3 10]; 
                TableTrig{i, 'Feedb'} = [10 4]; 
            else
                disp('entrata')
                TableTrig{i, 'DM_PostYN'} = [2 4];
            end
          
        end

        if contains(behav_table.Phase{1}, 'TI')
            TableTrig{:, 'TI'} = [11];
        end

    elseif contains(behav_table.Block{1}, 'RS')

        TableTrig{1, 'B0'} = [1, 11];
        TableTrig{1, 'Stim1'} = [11, 2];
        TableTrig{1, 'B1'} = [2, 11];
        TableTrig{1, 'Stim2'} = [11, 3];
        TableTrig{1, 'B2'} = [3, 4];

        if contains(behav_table.Phase{1}, 'TI')
            TableTrig{1, 'TI'} = [1];
        end

    end


end