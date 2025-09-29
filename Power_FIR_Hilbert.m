function TableInstantaneousPower_Hilbert_norm = Power_FIR_Hilbert(FrequencyLimits, NamePhasesOfInterest, LFP_run, Modified_Indexes_LFP_referred)



    
    % Add a buffer around the phases of interest
    buffer_duration = 1.5; % 1.5s of buffer before and after the window of interest to avoid edge artifacts!
    buffer_length = 1.5 * LFP_run.Fs;

    TableOffset = table('Size', [1 size(Modified_Indexes_LFP_referred, 2)], ...
                 'VariableTypes', repmat({'cell'}, 1, size(Modified_Indexes_LFP_referred,2)), ...
                 'VariableNames', Modified_Indexes_LFP_referred.Properties.VariableNames);

    if ismember('FullSignal', NamePhasesOfInterest)
        IdxEnd = length(NamePhasesOfInterest)-1; % Do not work on FullSignal yet!
    else
        IdxEnd = length(NamePhasesOfInterest);
    end

    for ph = 1:IdxEnd
        TableOffset.(NamePhasesOfInterest{ph}) = [-buffer_duration +buffer_duration]; % baseline!!!!!!!!
    end

    Buffered_Indexes_LFP_referred = modify_phase_indexes(Modified_Indexes_LFP_referred, LFP_run, TableOffset);
    Buffered_TableLFP = LFP_recording_segmentation(LFP_run, Buffered_Indexes_LFP_referred);

    % Need to timewarp before proceeding in case the segments do not have
    % all the same length!

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Extract the segment phases
    TableLFP = LFP_recording_segmentation(LFP_run, Modified_Indexes_LFP_referred);

    % Time-warp the segments
    Temp_TableLFP = TableLFP;
    Temp_TableLFP(:, ~ismember(Temp_TableLFP.Properties.VariableNames, NamePhasesOfInterest)) = [];
    TimeWarpedTableLFP = time_warping_segments(Temp_TableLFP, 200);
    % Create a new phase by joining the segments of interest 
    C = table2cell(TimeWarpedTableLFP); 
    TableLFP.('FullSignal') = cellfun(@(a,b) [a; b], C(:,1), C(:,2), 'UniformOutput', false);

    % Add buffer pre and post
    TableOffset = table('Size', [1 size(Modified_Indexes_LFP_referred, 2)], ...
                 'VariableTypes', repmat({'cell'}, 1, size(Modified_Indexes_LFP_referred,2)), ...
                 'VariableNames', Modified_Indexes_LFP_referred.Properties.VariableNames);

    TableOffset.(NamePhasesOfInterest{1}) = [-buffer_duration 0]; 
    Buffered_Indexes_LFP_referred = modify_phase_indexes(Modified_Indexes_LFP_referred, LFP_run, TableOffset);
    TableOffset.(NamePhasesOfInterest{1}) = {[] +buffer_duration 'From1'}; 
    Buffered_Indexes_LFP_referred = modify_phase_indexes(Buffered_Indexes_LFP_referred, LFP_run, TableOffset);

    % Extract the pre buffer segment 
    PreBuffered_TableLFP = LFP_recording_segmentation(LFP_run, Buffered_Indexes_LFP_referred);
    TableLFP.('PreBuffer') = PreBuffered_TableLFP.(NamePhasesOfInterest{1});

    TableOffset = table('Size', [1 size(Modified_Indexes_LFP_referred, 2)], ...
                 'VariableTypes', repmat({'cell'}, 1, size(Modified_Indexes_LFP_referred,2)), ...
                 'VariableNames', Modified_Indexes_LFP_referred.Properties.VariableNames);

    TableOffset.(NamePhasesOfInterest{end-1}) = [0 +buffer_duration]; 
    Buffered_Indexes_LFP_referred = modify_phase_indexes(Modified_Indexes_LFP_referred, LFP_run, TableOffset);
    TableOffset.(NamePhasesOfInterest{end-1}) = {-buffer_duration []  'From2'}; 
    Buffered_Indexes_LFP_referred = modify_phase_indexes(Buffered_Indexes_LFP_referred, LFP_run, TableOffset);

    % Extract the post buffer segment 
    PostBuffered_TableLFP = LFP_recording_segmentation(LFP_run, Buffered_Indexes_LFP_referred);
    TableLFP.('PostBuffer') = PostBuffered_TableLFP.(NamePhasesOfInterest{end-1});

    % Add the buffers to the signal
    ColNames = TableLFP.Properties.VariableNames;
    AllPhases = [{'PreBuffer'}, NamePhasesOfInterest{end}, {'PostBuffer'}];
    NewTable = TableLFP(:, AllPhases);
    C = table2cell(NewTable); 
    TableLFP.('FullSignal') = cellfun(@(a,b,c) [a; b; c], C(:,1), C(:,2), C(:,3), 'UniformOutput', false);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    TableInstantaneousPower_Hilbert_norm = table('Size', [size(TableLFP)], ...
                 'VariableTypes', repmat({'cell'}, 1, size(TableLFP,2)), ...
                 'VariableNames', TableLFP.Properties.VariableNames);

    PowerCurrentFreq = cell(size(Modified_Indexes_LFP_referred,1), 1);

     for freq_idx = 1:size(FrequencyLimits,1)
            
     
        % Design the filter
        Fs = LFP_run.Fs;  
        f_low = FrequencyLimits(freq_idx, 1);
        f_high = FrequencyLimits(freq_idx, 2);
        fNy = Fs / 2;
        
        filter_order = 20 * fix(Fs / f_low);  % 4 cycles
        b = fir1(filter_order, [f_low f_high] / fNy);
        [H, f] = freqz(b, 1, 2048, Fs);  % H = complex response, f = frequencies in Hz
        
        % Plot
%         figure;
%         plot(f, abs(H), 'LineWidth', 2);
%         xlabel('Frequency (Hz)');
%         ylabel('Amplitude');
%         title(sprintf('FIR Filter Frequency Response (%d-%d Hz)', f_low, f_high));
%         grid on;
%         xlim([0 120]);  % Focus on low frequencies

        Temp_TableInstantaneousPower_Hilbert_norm = TableLFP;


        if ismember('FullSignal', NamePhasesOfInterest)
            NamePhasesOfInterest = {'FullSignal'};
        end
        for ph = 1:length(NamePhasesOfInterest)
    
    
            % Extract the buffered-phase and concatenate trials 
            Signal_phaseOfInterest = TableLFP.(NamePhasesOfInterest{ph});
            ConcatenatedBufferedTrials = cell2mat(Signal_phaseOfInterest);

       
            for ch = 1:size(ConcatenatedBufferedTrials,2) % Loop over hemispheres

                % Filter the signal
                ConcatenatedBufferedTrials_Filtered(:,ch) = filtfilt(b, 1, ConcatenatedBufferedTrials(:, ch));

                % Extract power 
                ConcatenatedBufferedTrials_InstantaneousPower(:,ch) = abs(hilbert(ConcatenatedBufferedTrials_Filtered(:,ch))).^2;

            end

            % Re-format the data
            Temp = mat2cell(ConcatenatedBufferedTrials_InstantaneousPower, ...
                repmat(size(Signal_phaseOfInterest{1}, 1), 1, size(Signal_phaseOfInterest, 1)));
            
            % Remove the buffer
            Temp = cellfun(@(x) x(buffer_length:end-buffer_length-1, :), Temp, 'UniformOutput', false); %+1+25

            % Add FreqVector on third dimension
            LenghtPhase = size(Temp{1},1);
            FreqVector = linspace(FrequencyLimits(freq_idx, 1), FrequencyLimits(freq_idx, 2), LenghtPhase)';
 
            Temp_TableInstantaneousPower_Hilbert_norm.(NamePhasesOfInterest{ph}) = cellfun(@(c) [c, FreqVector], Temp, 'UniformOutput', false);

            clear ConcatenatedBufferedTrials_Filtered ConcatenatedBufferedTrials_InstantaneousPower Temp
        end

        % Normalise
        % [Temp_TableInstantaneousPower_Hilbert_norm, idxTrialsWoBaseline] = normalize_power(Temp_TableInstantaneousPower_Hilbert_norm, 'TrialByTrial', 'PrepDM'); 
        % Temp_TableInstantaneousPower_Hilbert_norm(idxTrialsWoBaseline, :) = [];      

        % Append different frequencies

        for ph = 1:length(NamePhasesOfInterest)

            Temp_Phase = Temp_TableInstantaneousPower_Hilbert_norm.(NamePhasesOfInterest{ph});
            PowerCurrentFreq = TableInstantaneousPower_Hilbert_norm.(NamePhasesOfInterest{ph});

            TableInstantaneousPower_Hilbert_norm.(NamePhasesOfInterest{ph}) = cellfun(@(a,b) [a; b], PowerCurrentFreq, Temp_Phase, 'UniformOutput', false);
       
        end

        clear Temp_TableInstantaneousPower_Hilbert_norm
         

    end



end