function [TablePSD_mean_SE, TablePSD_band_single_trial] = compute_band_average_power(TablePower, FreqLimits, FreqLabels, varargin)

    % Description:
    %   Function to compute, for each trial and phase, the average power in
    %   specific frequency windows
    %   
    % Inputs:
    %   - TablePower: TxP table, T=number of trials in the block under
    %       analysis, P=number of phases of interest. Each cell can either 
    %       contain:
    %       - FxNxH array, F=lenght of the frequency vector, N=length of 
    %           the spectrum, H=hemisphere (1=left, 2=right). It is the 
    %           scalogram, output of the CWT.
    %       - Fx3 array, F=length of the frequency vector. It is the 
    %           spectrogram, output of FFT or Welch. col1=spectrogram for 
    %           left hemisphere, col2=spectrogram for right hemisphere,
    %           col3=frequency vector.
    %   - freq_limits: vector containing the lower and upper limits of each 
    %       frequency band of interest
    %       e.g. in case of three bands of interest 
    %       [f_low1 f_high1; f_low2 f_high2; f_low3 f_high3]
    %   - freq_labels: vector containing the labels of the frequency bands 
    %       of interest
    %       e.g. in case of three bands of interest 
    %       ['band1', 'band2', 'band3']
    %   - varargin: frequency vector in case the input is the scalogram
    %       from CWT
    %
    % Outputs:
    %   - TablePSD_mean_SE: BxP table, B=number of bands of interest, 
    %       P=number of phases of interest. Each cell contains a 2x2 
    %       matrix, top row is mean, bottom row is standard deviation; 
    %       left is left hemisphere, right is right hemisphere. 
    %   - TablePSD_band_single_trial: BxP table, B=number of bands of 
    %       interest, P=number of phases of interest. Each cell contains a
    %       Tx2 matrix, T=number of trials, col1=left hemisphere,
    %       col2=right hemisphere.
    %
    % Created by Simona Losacco on 05/01/2025   



    TablePSD_mean_SE = table('Size', [length(FreqLabels) size(TablePower, 2)], ...
                     'VariableTypes', repmat({'cell'}, 1, size(TablePower,2)), ...
                     'VariableNames', TablePower.Properties.VariableNames, ...
                     'RowNames', FreqLabels);

    TablePSD_band_single_trial = table('Size', [length(FreqLabels) size(TablePower,2)], ...
                     'VariableTypes', repmat({'cell'}, 1, size(TablePower,2)), ...
                     'VariableNames', TablePower.Properties.VariableNames, ...
                     'RowNames', FreqLabels);

    if ~isempty(FreqLimits)

        if length(size(TablePower{1,1}{:})) > 2 % if 3D matrix --> scalogram! output of the CWT
    
            FreqVector = varargin{1};
    
            for j = 1:size(TablePower, 2)-2 % Loop over phases 
                for f = 1:length(FreqLabels) % Loop over frequency bands of interest
    
                    PSD_band_single_trial = [];
        
                    for i = 1:size(TablePower, 1) % Loop over trials
        
                        if ~isempty(TablePower{i,j}{:})
    
                            % Isolate indexes of the frequency band of interest (frequency data are in col=3)
                            BandIndexes = find( FreqVector > FreqLimits(f,1) & FreqVector < FreqLimits(f,2) );
        
                            % Select only the PSD in the frequency band under analysis
                            PSD = TablePower{i,j}{:}(BandIndexes, :,:);
                
                            % Average all the power values in the frequency band
                            PSD_band_single_trial = [PSD_band_single_trial; squeeze(mean(PSD,[1,2]))'];
                        else
                            PSD_band_single_trial = [PSD_band_single_trial; [NaN NaN]];
                        end
        
                    end
        
                    TablePSD_band_single_trial{f,j} = {PSD_band_single_trial};
        
                    % Mean and Standard Error over trials 
                    TablePSD_mean_SE{f,j} = {[ mean(TablePSD_band_single_trial{f,j}{:}, 1, 'omitnan'); ...
                        std(TablePSD_band_single_trial{f,j}{:}, 0, 1, 'omitnan')./sqrt(sum(~isnan(TablePSD_band_single_trial{f,j}{:}(:,1)))) ]};
        
                end
            end
    
    
        elseif length(size(TablePower{1,1}{:})) == 2 % if 2D matrix --> spectrogram extracted with periodogram
    
            for j = 1:size(TablePower, 2)-2 % Loop over phases 
                for f = 1:length(FreqLabels) % Loop over frequency bands of interest
              
          
                    PSD_band_single_trial = [];
        
                    for i = 1:size(TablePower, 1) % Loop over trials
        
                        if ~isempty(TablePower{i,j}{:})
    
                            % Isolate indexes of the frequency band of interest (frequency data are in col=3)
%                             BandIndexes = find( TablePower{i,j}{:}(:,3) > FreqLimits(f,1) & TablePower{i,j}{:}(:,3) < FreqLimits(f,2) );
                            BandIndexes = [find(TablePower{i,j}{:}(:,3) == FreqLimits(f,1), 1, 'last') : find(TablePower{i,j}{:}(:,3) == FreqLimits(f,2), 1, 'first')];

        
                            % Select only the PSD in the frequency band under analysis
                            PSD = TablePower{i,j}{:}(BandIndexes, 1:2);
                
                            % Average all the power values in the frequency band
                            PSD_band_single_trial = [PSD_band_single_trial; mean(PSD,1)];
                        else
                            PSD_band_single_trial = [PSD_band_single_trial; [0 0]];
                        end
        
                    end
        
                    TablePSD_band_single_trial{f,j} = {PSD_band_single_trial};
        
                    % Mean and Standard Error over trials 
                    TablePSD_mean_SE{f,j} = {[ mean(TablePSD_band_single_trial{f,j}{:}, 1, 'omitnan'); ...
                        std(TablePSD_band_single_trial{f,j}{:}, 0, 1, 'omitnan')./sqrt(sum(~isnan(TablePSD_band_single_trial{f,j}{:}))) ]};
        
                end
            end
    
        end

    else % no frequency limits specified --> already passing the band of interest!

        for j = 1:size(TablePower, 2)-2 % Loop over phases 
          
            PSD_band_single_trial = [];

            for i = 1:size(TablePower, 1) % Loop over trials

                if ~isempty(TablePower{i,j}{:})

                    % Select only the PSD in the frequency band under analysis
                    PSD = TablePower{i,j}{:}(BandIndexes, 1:2);
        
                    % Average all the power values in the frequency band
                    PSD_band_single_trial = [PSD_band_single_trial; mean(PSD,1)];
                else
                    PSD_band_single_trial = [PSD_band_single_trial; [0 0]];
                end

            end

            TablePSD_band_single_trial{f,j} = {PSD_band_single_trial};

            % Mean and Standard Error over trials 
            TablePSD_mean_SE{f,j} = {[ mean(TablePSD_band_single_trial{f,j}{:}, 1, 'omitnan'); ...
                std(TablePSD_band_single_trial{f,j}{:}, 0, 1, 'omitnan')./sqrt(sum(~isnan(TablePSD_band_single_trial{f,j}{:}))) ]};

        end
            
    

    end


end