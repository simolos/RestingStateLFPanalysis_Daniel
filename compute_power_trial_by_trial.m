function TablePower = compute_power_trial_by_trial(TableLFP, FSamp, Flag_method, varargin)

    % Description: function to compute the power trial by trial, either
    % using Welch or simply FFT depending on the inputs of the function.
    %   
    % Inputs:
    %   - TableLFP: TxP table, T=number of trials, P=number of phases of
    %       interest. Each cell is a Nx2 array, N=length of the signal for
    %       the specific phase. dim1=left hemisphere, dim2=right hemisphere
    %   - FSamp: sampling frequency of the LFPs
    %   - Flag_method: 'Welch' or 'FFT'
    %   - varargin: structure containing the parameters for Welch's method
    %
    % Outputs:
    %   - TablePower: TxP table, T=number of trials in the block under
    %       analysis, P=number of phases of interest. Each cell contains a
    %       Fx3 array, F=length of the frequency vector. col1=spectrogram 
    %       for left hemisphere, col2=spectrogram for right hemisphere,
    %       col3=frequency vector.    
    %
    % Created by Simona Losacco on 05/01/2025


    if nargin > 3
        Welch_params = varargin{1};

        width = Welch_params.width;
        noverlap = Welch_params.noverlap;
        fRes = Welch_params.fRes;
        fRange = Welch_params.fRange;
    end
  
    TablePower = table('Size', size(TableLFP), ...
                 'VariableTypes', repmat({'cell'}, 1, size(TableLFP,2)), ...
                 'VariableNames', TableLFP.Properties.VariableNames);


    if strcmp(Flag_method, 'Welch')
 
        WindowWidth = width * FSamp; % in samples
        Window = hann(WindowWidth); % Hann window
        nfft = 2^nextpow2(round(FSamp/fRes)); % number of points used for the fft --> smallest power of two greater than or equal to Fs/fRes
    
    
        for i = 1:size(TableLFP,1)
            for j = 1:size(TableLFP,2)-2 % temporary -2 to skip the last two phases of wait feedb and feedb
                if ~isempty(TableLFP{i,j}{1})
                    PSD_channel = [];
                    for c = 1:2 % Loop over the channels
                        LFP_signal = TableLFP{i,j}{1}(:,c);
                        
                        [psd, freq] = pwelch(LFP_signal, Window, noverlap, nfft, FSamp); 
                        
                        % Selecting freqs of interest
                        fR = round((fRange/(freq(2)-freq(1)))+1);    
                        psd = psd(fR(1):fR(2)); 
                        freq = freq(fR(1):fR(2));
    
                        PSD_channel = [PSD_channel psd];
    
                    end
                    TablePower(i,j) = {[PSD_channel freq]};
                end
            end
    
        end

    elseif strcmp(Flag_method, 'FFT')

        for i = 1:size(TableLFP,1) % Loop over trials
            for j = 1:size(TableLFP,2)-2 % temporary -2 to skip the last two phase of wait feedb and feedb
                if ~isempty(TableLFP{i,j}{1}) % Check that the phase exists for the current trial
                    Power_channel = [];
                    for c = 1:2 %size(TableLFP{i,j}{1}, 2) % 2 channels
                        LFP_signal = TableLFP{i,j}{1}(:,c);
                        LFP_signal_length = length(LFP_signal);
                        freq =  (0:LFP_signal_length-1)*(FSamp/LFP_signal_length); % FSamp/LFP_signal_length=fRES!
                        
                        [dft] = fft(LFP_signal); 

                        spectrum_TwoSided = abs(dft); % Get the magnitude
                        spectrum_OneSided = spectrum_TwoSided(1:floor(LFP_signal_length/2)); % Isolate half of the spectrum (positive freq)
                        power_OneSided = spectrum_OneSided.^2; % Compute the power
                        freq_OneSided = freq(1:floor(LFP_signal_length/2))'; 
     
                        Power_channel = [Power_channel power_OneSided];
    
                    end

                    TablePower(i,j) = {[Power_channel freq_OneSided]};
                end
            end
    
        end


    end


end