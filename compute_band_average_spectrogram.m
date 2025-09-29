function [TableSpectrogram_Average, TableSpectrogram_SE, N_trials] = compute_band_average_spectrogram(TablePower, FreqLimits, FreqLabels, varargin)



    TableSpectrogram_Average = table('Size', [length(FreqLabels) size(TablePower, 2)], ...
                     'VariableTypes', repmat({'cell'}, 1, size(TablePower,2)), ...
                     'VariableNames', TablePower.Properties.VariableNames, ...
                     'RowNames', FreqLabels);

    TableSpectrogram_SE = table('Size', [length(FreqLabels) size(TablePower,2)], ...
                     'VariableTypes', repmat({'cell'}, 1, size(TablePower,2)), ...
                     'VariableNames', TablePower.Properties.VariableNames, ...
                     'RowNames', FreqLabels);

       
            for j = 1:size(TablePower, 2)-2 % Loop over phases 
                for f = 1:length(FreqLabels) % Loop over frequency bands of interest
          
                    AllSpectrograms = [];
        
                    for i = 1:size(TablePower, 1) % Loop over trials
        
                        if ~isempty(TablePower{i,j}{:})
    
                            % Isolate indexes of the frequency band of interest (frequency data are in col=3)
                            BandIndexes = [find(TablePower{i,j}{:}(:,3) == FreqLimits(f,1), 1, 'last') : find(TablePower{i,j}{:}(:,3) == FreqLimits(f,2), 1, 'first')];
        
                            % Select only the PSD in the frequency band under analysis
                            CurrentSpectrogram = TablePower{i,j}{:}(BandIndexes, 1:2);
                
                            % Average all the power values in the frequency band
                            AllSpectrograms = cat(3, AllSpectrograms, CurrentSpectrogram);
                            N_trials = size(AllSpectrograms, 3);

                        end
        
                    end
        
                    TableSpectrogram_Average{f,j} = {mean(AllSpectrograms, 3)};
                    TableSpectrogram_SE{f,j} = { std(AllSpectrograms, 0, 3, 'omitnan')./sqrt(size(AllSpectrograms, 3)) };
                end
            end

end