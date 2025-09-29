function TableSpectrum = spectrum_segmentation(spectrum, TableIndexes)

    % Description: function to cut the spectrum into the phases of
    % interest.
    %   
    % Inputs:
    %   - spectrum: struct output of the computeCWT function
    %   - TableIndexes: TxP table, T=number of trials, 
    %       P=number of phases of interest. Each column is a 2x1 array, 
    %       containing the trigger index of beginning and end of the phase   
    %       of interest, referred to the LFP recording. The array is set 
    %       to [0 0] in case the phase of interest does not exist for the 
    %       specific trial (e.g. only DM trial)
    %
    % Outputs:
    %   - TableSpectrum: TxP table, T=number of trials in the block under
    %       analysis, P=number of phases of interest. Each cell contains a
    %       FxNxH array, F=lenght of the frequency vector, N=length of the
    %       spectrum, H=hemisphere (1=left, 2=right)
    %
    % Created by Simona Losacco on 05/01/2025

    spectrum_signal = spectrum.data;


    TableSpectrum = table('Size', size(TableIndexes), ...
                 'VariableTypes', repmat({'cell'}, 1, size(TableIndexes,2)), ...
                 'VariableNames', TableIndexes.Properties.VariableNames);


    for i = 1:size(TableIndexes,1) % Loop over trials
        for j = 1:size(TableIndexes,2) % Loop over phases
            if TableIndexes{i,j}(1) ~= 0 % If the phase exists
           
                TableSpectrum(i,j) = { cat(3, spectrum_signal(:, TableIndexes{i,j}(1) : TableIndexes{i,j}(2), 1), ...
                    spectrum_signal(:, TableIndexes{i,j}(1) : TableIndexes{i,j}(2), 2)) }; % 1 for left hemisphere, 2 for right
          
            end            
        end
    end


end
