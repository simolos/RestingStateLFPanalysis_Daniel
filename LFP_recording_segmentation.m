function TableLFP = LFP_recording_segmentation(LFP_signal, TableIndexes)

    % Description: function to segment the LFP recording into the phases of
    % interest.
    %   
    % Inputs:
    %   - LFP_signal
    %   - TableIndexes: TxP table, T=number of trials, P=number of phases 
    %       of interest. Each column is a 2x1 array, containing the trigger 
    %       index of beginning and end of the phase of interest, referred  
    %       to the LFP recording. The array is set to [0 0] in case the  
    %       phase of interest does not exist for the specific trial (e.g. 
    %       only DM trial)
    %
    % Outputs:
    %   - TableLFP: TxP table, T=number of trials, P=number of phases of
    %       interest. Each cell is a Nx2 array, N=length of the signal for
    %       the specific phase. col1=left hemisphere, col2=right hemisphere
    %
    % Created by Simona Losacco on 05/01/2025


    TableLFP = table('Size', size(TableIndexes), ...
                 'VariableTypes', repmat({'cell'}, 1, size(TableIndexes,2)), ...
                 'VariableNames', TableIndexes.Properties.VariableNames);


    for i = 1:size(TableIndexes,1) % Loop over trials
        for j = 1:size(TableIndexes,2) % Loop over phases
            if TableIndexes{i,j}(1) ~= 0
           
                TableLFP(i,j) = {[LFP_signal(TableIndexes{i,j}(1) : TableIndexes{i,j}(2), 1) ...
                    LFP_signal(TableIndexes{i,j}(1) : TableIndexes{i,j}(2), 2)]}; % 1 for left hemisphere, 2 for right
          
            end           
        end
    end

end