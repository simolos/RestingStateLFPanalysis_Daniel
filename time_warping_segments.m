function New_Table_Data = time_warping_segments(Table_Data, varargin)

    % Description:
    %   Function to time warp each segments in the table, according to the
    %   average duration of the phase.
    %   
    % Inputs:
    %   - Table_Data: TxP table, T=number of trials in the block under
    %       analysis, P=number of phases of interest. Each cell can either 
    %       contain:
    %       - FxNxH array, F=lenght of the frequency vector, N=length of 
    %           the spectrum, H=hemisphere (1=left, 2=right). It is the 
    %           scalogram, output of the CWT.
    %       - Fx3 array, F=length of the frequency vector. It is the 
    %           spectrogram, output of FFT or Welch. col1=spectrogram for 
    %           left hemisphere, col2=spectrogram for right hemisphere,
    %           col3=frequency vector.     
    %
    % Outputs:
    %   - New_Table_Data: TxP table, T=number of trials in the block under
    %       analysis, P=number of phases of interest. For each specific 
    %       phase, every segment has the same lenght.
    %
    % Created by Simona Losacco on 05/01/2025   

    if nargin > 1
        FixedLenght = varargin{1};
    end

    New_Table_Data = table('Size', [size(Table_Data)], ...
                     'VariableTypes', repmat({'cell'}, 1, size(Table_Data,2)), ...
                     'VariableNames', Table_Data.Properties.VariableNames);


    for j = 1:size(Table_Data,2) % Loop over phases        

        % Get average duration of the phase
        N_samples_phase = cellfun(@(x) size(x, 2), Table_Data{:,j}, 'UniformOutput', false);
        N_samples_phase = [N_samples_phase{:}];
        N_samples_phase(N_samples_phase == 0) = NaN;
        median_N_samples_phase = median(N_samples_phase, 'omitnan');

        if nargin > 1
            LengthInterpolation = FixedLenght;
        else
            LengthInterpolation = median_N_samples_phase;
        end


        % Check if the segments already have all the same lenght
        if all(N_samples_phase == N_samples_phase(1))
            % --> do not interpolate if they already have the same length!
            New_Table_Data{:,j} = Table_Data{:,j};
            continue 
        end


        for i = 1:size(Table_Data,1) % Loop over trials

            if ~isempty(Table_Data{i,j}{:}) % If the phase exists for the specific trial

                for c = 1:2 % Loop over channels

                    if ndims(Table_Data{i,j}{:}) == 3 % Time warping scalogram

                        current_signal = Table_Data{i,j}{:}(:,:,c);

                        New_Table_Data{i,j}{:}(:,:,c) = interp1(1:size(current_signal, 2), current_signal', linspace(1, size(current_signal, 2), LengthInterpolation))';
                
                    else % Time warping spectrogram

                        current_signal = Table_Data{i,j}{:}(:,c);

                        New_Table_Data{i,j}{:}(:,c) = interp1(1:size(current_signal, 1), current_signal', linspace(1, size(current_signal, 1), LengthInterpolation))';
   
                    end
                end

            end

        end

    end


end