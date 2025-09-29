function LFP_PowerHilbert = compute_hilbert_power(LFP_struct, FrequencyLimits, FrequencyLabels, Flag_plot_filter)

    % Description: function to compute LFP power through Finite Impulse Response filter + hilbert   
    %   
    % Inputs:
    %   - LFP_struct 
    %   - FrequencyLimits: limits of the frequency bands,
    %       Fx2 table, F=number of frequency bands of interest.
    %   - FrequencyLabels: names of the frequency bands; 1xF cell array
    %   - Flag_plot_filter --> set to 1 to plot the amplitude and phase of
    %   the FIR 
    %
    % Outputs:
    %   - TableIndexes_LFP_referred: same table as input, but with the new
    %       boundaries.
    %
    % Created by Simona Losacco on 05/09/2025

     
    % Initialise the output structure
    LFP_PowerHilbert = struct;

    for freq_idx = 1:size(FrequencyLimits,1)
        % Design the filter
        Fs = LFP_struct.Fs;  
        f_low = FrequencyLimits(freq_idx, 1);
        f_high = FrequencyLimits(freq_idx, 2);
        fNy = Fs / 2;
        
        filter_order = 20 * fix(Fs / f_low);  % 4 cycles
        b = fir1(filter_order, [f_low f_high] / fNy);


        %%%% Test
        % [b_BP, a_BP]= butter(5, [f_low f_high] / fNy); % Butterworth Band-pass filter, 6° order 
        %%%% end Test

        
        if Flag_plot_filter == 1
            % Plot
            [H, f] = freqz(b, 1, 512, Fs);  % H = complex response, f = frequencies in Hz
            figure;
            subplot(2,1,1)
            plot(f, abs(H), 'LineWidth', 2);
            xlabel('Frequency (Hz)');
            ylabel('Amplitude');
            title(sprintf('FIR Filter Frequency Response (%d-%d Hz)', f_low, f_high));
            grid on;
            xlim([0 120]);  % Focus on low frequencies

            % [H, f] = freqz(b_BP, a_BP, 512, Fs);  % H = complex response, f = frequencies in Hz
            % subplot(2,1,2)
            % plot(f, abs(H), 'LineWidth', 2);
            % xlabel('Frequency (Hz)');
            % ylabel('Amplitude');
            % title(sprintf('Butter Filter Frequency Response (%d-%d Hz)', f_low, f_high));
            % grid on;
            % xlim([0 120]);  % Focus on low frequencies
            % linkaxes
        end


        for ch = 1:size(LFP_struct.data,2) % Loop over hemispheres

            % Filter the signal
            FilteredLFP = filtfilt(b, 1, LFP_struct.data(:, ch));
            % FilteredLFP = filtfilt(b_BP,a_BP,LFP_struct.data(:, ch));


            % Extract power 
            LFP_PowerHilbert.(FrequencyLabels{freq_idx})(:,ch) = abs(hilbert(FilteredLFP)).^2;

        end

    end


end
