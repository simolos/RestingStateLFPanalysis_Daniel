function [TablePower, idxTrialsWoBaseline] = normalize_power(TablePower, flag_norm, BaselinePhaseName)

    % Description: function to normalise the spectrum (z-score) with 
    % respect to the first phase (Intertrial)
    %   
    % Inputs:
    %   - TablePower: TxP table, T=number of trials in the block under
    %       analysis, P=number of phases of interest. Each cell can either 
    %       contain:
    %       - FxNxH array, F=lenght of the frequency vector, N=length of the
    %           spectrum, H=hemisphere (1=left, 2=right). It is the 
    %           scalogram, output of the CWT.
    %       - Fx3 array, F=length of the frequency vector. It is the 
    %           spectrogram, output of FFT or Hilbert. col1=spectrogram for left
    %           hemisphere, col2=spectrogram for right hemisphere,
    %           col3=frequency vector.
    %       - SxH array, S=duration of the phase, H=hemisphere. It is the 
    %           instantaneous power, output of the Hilbert transform.  
    %   - flag_norm: flag to specify the type of normalisation,
    %       'TrialByTrial' or 'BlockNorm' (not yet implemented)
    %   - BaselinePhaseName: name of the phase to be used as baseline
    %
    % Outputs:
    %   - TablePower: same table as input but each phase is normalised with
    %       respect to the baseline phase
    %
    % Created by Simona Losacco on 05/01/2025
    % Modified by SL on 13/01/2025

    idxTrialsWoBaseline = [];

    OriginalTablePower = TablePower;


    if strcmp(flag_norm, 'TrialByTrial')
 
        if length(size(TablePower{1,1}{:})) > 2 % if 3D matrix --> scalogram! output of the CWT

            for i = 1:size(TablePower, 1) % Loop over trials

                if ~isempty(TablePower.(BaselinePhaseName){i})

                    for j = 1:size(TablePower, 2) % Loop over phases 
                        if 1 %~strcmp(TablePower.Properties.VariableNames{j}, BaselinePhaseName) % if the phase under analysis is not the baseline
                            for k = 1:2 % Loop over hemispheres (third dimension)
                                if ~isempty(TablePower{i,j}{:})
                    
                                
                                
                                MeanBaseline = mean(OriginalTablePower.(BaselinePhaseName){i}(:,:,k), 2);
                                StdBaseline = std(OriginalTablePower.(BaselinePhaseName){i}(:,:,k), 0, 2);
    
                                TablePower{i,j}{:}(:,:,k) = ( TablePower{i,j}{:}(:,:,k) - MeanBaseline )./ StdBaseline;
                                % TablePower{i,j}{:}(:,:,k) = ( TablePower{i,j}{:}(:,:,k) ./ MeanBaseline ) ;
                                    
                        
                                
                                end
                            end
                        end
                    end
                else 
                    % If it's empty it means that the phase
                    % is not available! e.g. using Hold in
                    % trials in which there is no EP
                    warning on 
                    warning('Baseline phase does not exist for trial %d --> NO BASELINE CORRECTION, trial will be deleted', i);
                    warning off   

                    idxTrialsWoBaseline = [idxTrialsWoBaseline, i];

                end
                  
            end

        elseif length(size(TablePower{1,1}{:})) == 2 % if 2D matrix --> spectrogram extracted with periodogram or Hilbert

            for i = 1:size(TablePower, 1) % loop over trials

                %MeanBaseline = mean(OriginalTablePower.(BaselinePhaseName){i}(:,1:2));
                %StdBaseline = std(OriginalTablePower.(BaselinePhaseName){i}(:,1:2));
                MeanBaseline = mean(OriginalTablePower.(BaselinePhaseName){i});
                StdBaseline = std(OriginalTablePower.(BaselinePhaseName){i});


                for j = 1:size(TablePower, 2) % loop over phases 
                    if 1 %~strcmp(TablePower.Properties.VariableNames{j}, BaselinePhaseName) % if it's not the baseline

                        if ~isempty(TablePower{i,j}{:})
                            
                            TablePower{i,j}{:}(:,1:2) = ( TablePower{i,j}{:}(:,1:2) - MeanBaseline )./ StdBaseline;
                        end

                    end
                end
            end

        end

    elseif strcmp(flag_norm, 'BlockNorm')

        % TO BE IMPLEMENTED

    else
        error('Specify normalization type as TrialByTrial or BlockNorm') 
    end

end