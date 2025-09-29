function [Spectrum, idx_cut, N] = average_and_combine_segments(TablePower, Label_ColumnToAverage)

    % Description:
    %   Function to average segments from different trials, only including
    %   the phases of interests specified in Label_ColumnToAverage
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
    %   - Label_ColumnToAverage: 1xP cell array, P=number of phases of 
    %           interest. Each cell is the name of a column of TablePower.
    %
    % Outputs:
    %   - Spectrum: FxNxH array, F=lenght of the frequency vector, N=length  
    %           of the spectrum, H=hemisphere (1=left, 2=right). It is
    %           scalogram, in the format needed by the function 
    %           plotCWTspectrogram2.
    %   - N: number of trials included
    %
    % Created by Simona Losacco on 13/02/2025   

    

    Idx_ColumnToAverage = find(ismember(TablePower.Properties.VariableNames, Label_ColumnToAverage));

    Temp = table2cell(TablePower);    
    
    AverageOverTrials = cellfun(@(x) mean(cat(4, Temp{:, x}), 4), num2cell(Idx_ColumnToAverage), 'UniformOutput', false);

    phase_duration = cellfun(@(x) size(Temp{1,x}, 2), num2cell(Idx_ColumnToAverage), 'UniformOutput', false);

    idx_cut = cumsum(cell2mat(phase_duration));
    idx_cut = idx_cut(1:end-1);

    Spectrum = cat(2, AverageOverTrials{:});

    N = size(TablePower, 1);

end