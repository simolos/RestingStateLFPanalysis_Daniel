function TableIndexes_LFP_referred = modify_phase_indexes(TableIndexes_LFP_referred, LFP_struct, TableOffsetPerPhase)

    % Description: function to modify the indexes of beginning and end of a 
    % phase according to an offset.  
    %   
    % Inputs:
    %   - TableIndexes_LFP_referred: TxP table, T=number of trials, 
    %       P=number of phases of interest. Each column is a 2x1 array, 
    %       containing the trigger index of beginning and end of the phase   
    %       of interest, referred to the LFP recording. The array is set 
    %       to [0 0] in case the phase of interest does not exist for the 
    %       specific trial (e.g. only DM trial)
    %   - LFP_struct
    %   - TableOffsetPerPhase: 1xP table, P=number of phases of interest, 
    %       containing the offsets for each phase. Each column is either a
    %       2x1 or a 3x1 array in case offsets are defined, empty otherwise.
    %
    %       [+-x +-y] to add/remove seconds at the beginning (x) or end (y) of the phase
    %       e.g. [+1.2 0] --> adds 1.2s to the beginning of the phase, leaving the
    %       end unaltered
    %
    %       {[] +-t 'Fromx'} to set the end of the phase as the beginning +- t seconds 
    %       e.g. {[] +0.6 'Fromx'} --> the end of the phase is set 600ms
    %       after the beginning of the phase

    %       {+-t [] 'Fromy'} to set the end of the phase as the beginning +- t seconds 
    %       e.g. {-0.8 [] 'Fromy'} the beginning of the phase is set 800ms
    %       before the end of the phase
    %
    %       {+-t1 +-t2 'Fromy'} to set the beginning of the phase as the end +- t1 seconds
    %       and the end of the phase as the end +- t2 seconds
    %       e.g. {-0.8 -0.3 'Fromy'} the beginning of the phase is set 800ms
    %       before the end of the phase and the end of the phase is set
    %       300ms before the end
    %
    %       {+-t1 +-t2 'Fromx'} to set the beginning of the phase as the beginning +- t1 seconds
    %       and the end of the phase as the beginning +- t2 seconds
    %       e.g. {+0.1 +0.3 'Fromx'} the beginning of the phase is set 100ms
    %       after the beginning of the phase and the end of the phase is set
    %       300ms after the beginning
    %
    % Outputs:
    %   - TableIndexes_LFP_referred: same table as input, but with the new
    %       boundaries.
    %
    % Created by Simona Losacco on 05/01/2025

    LFP_Fs = LFP_struct.Fs;


    for j=1:size(TableOffsetPerPhase, 2) % Loop over phases

        if size(TableOffsetPerPhase{1,j},2) == 2 % If the offset is defined as [+-x +-y]
            for k=1:size(TableOffsetPerPhase{1,j},2) 
                if isnumeric(TableOffsetPerPhase{1,j}(k)) % if the offset exists
                    if TableIndexes_LFP_referred{:,j}(:, k) ~= 0
                        TableIndexes_LFP_referred{:,j}(:, k) = (TableIndexes_LFP_referred{:,j}(:, k) + ( TableOffsetPerPhase{1,j}(k) * LFP_Fs )) .* double(TableIndexes_LFP_referred{:,j}(:, k) ~= 0);
                    end
                end            
            end
        elseif size(TableOffsetPerPhase{1,j},2) == 3 % If the offset is defined as {[] +-t 'Fromx'} or {+-t [] 'Fromy'} 
            
            if strcmp(TableOffsetPerPhase{1,j}{3}, 'From2') % Set index1 as index2-t
                if ~isempty(TableOffsetPerPhase{1,j}{1})
                    TableIndexes_LFP_referred{:,j}(:, 1) = ...
                        (TableIndexes_LFP_referred{:,j}(:, 2) + (TableOffsetPerPhase{1,j}{1} * LFP_Fs)) ...
                        .* double(TableIndexes_LFP_referred{:,j}(:, 2) ~= 0);
                end

                if ~isempty(TableOffsetPerPhase{1,j}{2})
                    TableIndexes_LFP_referred{:,j}(:, 2) = ...
                        (TableIndexes_LFP_referred{:,j}(:, 2) + ( TableOffsetPerPhase{1,j}{2} * LFP_Fs )) ...
                        .* double(TableIndexes_LFP_referred{:,j}(:, 2) ~= 0);
                end

            elseif strcmp(TableOffsetPerPhase{1,j}{3}, 'From1') % Set index2 as index1+t
                if ~isempty(TableOffsetPerPhase{1,j}{1})
                    TableIndexes_LFP_referred{:,j}(:, 1) = ...
                        (TableIndexes_LFP_referred{:,j}(:, 1) + (TableOffsetPerPhase{1,j}{1} * LFP_Fs)) ...
                        .* double(TableIndexes_LFP_referred{:,j}(:, 2) ~= 0);
                end

                if ~isempty(TableOffsetPerPhase{1,j}{2})
                    TableIndexes_LFP_referred{:,j}(:, 2) = ...
                        (TableIndexes_LFP_referred{:,j}(:, 1) + ( TableOffsetPerPhase{1,j}{2} * LFP_Fs )) ...
                        .* double(TableIndexes_LFP_referred{:,j}(:, 2) ~= 0);
                end

            end

        end

    end



end