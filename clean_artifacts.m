function [LFP_filtered, TI] = clean_artifacts(LFP, TI, tag)

    LFP_filtered = LFP;

    % Create TI sequence 
    Ramp = repelem(0, (5*LFP_filtered.Fs) + 1);
    Train2s = repmat([repelem(1, round(0.03*LFP_filtered.Fs)) repelem(0, fix((0.2-0.03)*LFP_filtered.Fs))], 1, 10);
    Break8s = repelem(0, 8*LFP_filtered.Fs);
    iTBS_sequence = [Ramp repmat([Train2s Break8s], 1, 52)];
    cTBS_sequence = [Ramp repmat(Train2s, 1, 520/2)];
    HF_sequence = zeros(size(iTBS_sequence));

    if contains(tag, 'iTBS') || contains(tag, 'HF') || contains(tag, 'sham') || contains(tag, '130')% HF cleaned as if it was iTBS!! 
        Flag_only_notch = 0;
        TI_sequence = iTBS_sequence;
    elseif contains(tag, 'cTBS')
        Flag_only_notch = 0;
        TI_sequence = cTBS_sequence;
    elseif contains(tag, 'DBS') % for OCD --> no filtering at all
        return
    else
        disp('Only notch filtering!')
        Flag_only_notch = 1;
        TI.TIsequence_alignedToTrigger = HF_sequence;

    end
        

    for h = 1:size(LFP_filtered.data,2) % loop over hemispheres
        
        if Flag_only_notch == 0

            TIsequence_alignedToTrigger = [zeros(1, TI.TI_trig_LFP_referred + 1) TI_sequence];

            % Cut TI_sequence to match the length of LFP
            TIsequence_alignedToTrigger(length(LFP_filtered.data(:,h))+1 : end) = [];

            TI.TIsequence_alignedToTrigger = TIsequence_alignedToTrigger;

    
            % Plot raw LFP with TI sequence 
            % figure
            % tiledlayout(2,1,"TileSpacing","tight")
            % nexttile
            % plot(LFP_filtered.data(:,h), 'r')
            % ylim([-100 100])
            % hold on
            % xline(TI.TI_trig_LFP_referred, 'b--')
            % 
            % 
            % plot((TIsequence_alignedToTrigger*120)-60)
                
            
            % Find begining and end of each burst of 3 pulses
            Onsets = find(diff([0 TIsequence_alignedToTrigger]) == 1) - 1; % -1 to find the LAST zero before the artifact!
            End = find(diff([TIsequence_alignedToTrigger 0 ]) == -1) + 1;
            % Superimpose the beginning and end of each burst
            % xline(Onsets, 'g')
            % xline(End, 'r')
            
            % Plot spectrogram for original data
            % figure
            % sgtitle('Original data')
            % COMPats_PERCEPT_plot_BS(LFP_filtered,[],0,1)
            
            % Plot spectrum for original data
            T = 1/LFP_filtered.Fs;              
            L = fix(size(LFP_filtered.data, 1))-1;             
            t = (0:L-1)*T;        
            
            % figure
            % nexttile
            Y_left = fft(LFP_filtered.data(:,h));
            P2_left = abs(Y_left/L);
            P1_left = P2_left(1:L/2+1);
            P1_left(2:end-1) = 2*P1_left(2:end-1);
            f = LFP_filtered.Fs*(0:(L/2))/L;
            % plot(f,P1_left, 'r') 
            % ylim([0 2])
            % hold on
            % title(sprintf("%s - Original data", LFP_filtered.channel_names{h}))
            % xlabel("f (Hz)")
            % ylabel("|P1(f)|") 
            
            
        
%             % Replace the artifact with the syntetic template            
            for i=1:length(Onsets)
            
                    SignalDuringArtifact = LFP_filtered.data(Onsets(i) : End(i), h);
                    MeanDuringArtifact = mean(SignalDuringArtifact);
                    MaxDuringArtifact = max(SignalDuringArtifact);   
                    MinDuringArtifact = min(SignalDuringArtifact);
                    p2pDuringArtifact = MaxDuringArtifact - MinDuringArtifact;
                  
                    % Isolate signal of equal length before/after the artifact
                    SignalBeforeArtifact = LFP_filtered.data(Onsets(i)-length(SignalDuringArtifact) : Onsets(i)-1, h);
                    MeanBeforeArtifact = mean(SignalBeforeArtifact);
                    MaxBeforeArtifact = max(SignalBeforeArtifact);   
                    MinBeforeArtifact = min(SignalBeforeArtifact);
                    p2pBeforeArtifact = MaxBeforeArtifact - MinBeforeArtifact;
        
                    SignalAfterArtifact = LFP_filtered.data(End(i)+1: End(i)+length(SignalDuringArtifact), h);
                    MeanAfterArtifact = mean(SignalAfterArtifact);
                    MaxAfterArtifact = max(SignalAfterArtifact);   
                    MinAfterArtifact = min(SignalAfterArtifact);
                    p2pAfterArtifact = MaxAfterArtifact - MinAfterArtifact;

                    % Mirror and taper the segments
                    Length_taper = size(SignalBeforeArtifact, 1);
                    SignalBeforeArtifact_flipped_and_tapered = flip(SignalBeforeArtifact)' .* linspace(1, 0, Length_taper);
                    SignalAfterArtifact_flipped_and_tapered = flip(MeanAfterArtifact)' .* linspace(0, 1, Length_taper);


        
                  
                    % Align the signal
        
        
                    % Syntetic signal as average of the signal before and after the artifact
%                     ReplacementSignal = (SignalBeforeArtifact + SignalAfterArtifact) / 2;
                    ReplacementSignal = (SignalBeforeArtifact_flipped_and_tapered + SignalAfterArtifact_flipped_and_tapered);


                    % ReplacementSignal = flip(ReplacementSignal);
        
%                     figure
%                     plot(SignalBeforeArtifact, 'b')
%                     hold on
%                     plot(SignalAfterArtifact, 'k')
%                     plot(SignalDuringArtifact, 'g')
%                     plot(ReplacementSignal, 'r')
%                     legend('Before', 'After', 'True', 'Replacement')
%             
        
                    % AvgTemplate_L_hemisphere
        %             scale = ((p2pBeforeArtifact+p2pAfterArtifact)/2) / p2pDuringArtifact;
        %             offset = ((MeanBeforeArtifact-MeanAfterArtifact)/2);
        
        %             LFP_filtered.data(Onsets(i):End(i), 1) = LFP_filtered.data(Onsets(i):End(i), 1) * scale - offset; % THIS WORKS
            
                    % Replace the artifact with the syntetic signal
                    LFP_filtered.data(Onsets(i):End(i), h) = ReplacementSignal;
            
            end



%             % Interpolate the artifact    
%             for i=1:length(Onsets)
%             
%                     LFP_filtered.data(Onsets(i):End(i), h) = linspace(LFP_filtered.data(Onsets(i),h), LFP_filtered.data(End(i),h), End(i)-Onsets(i)+1);            
%             end
            
            % Plot spectrogram for filtered data - after syntetic signal paste
            % figure
            % sgtitle('After synthetic paste')
            % COMPats_PERCEPT_plot_BS(LFP_filtered,[],0,1)
            
            % Plot spectrum for filtered data - after syntetic signal paste
            T = 1/LFP_filtered.Fs;             % Sampling period       
            L = fix(size(LFP_filtered.data, 1))-1;             % Length of signal
            t = (0:L-1)*T;        % Time vector
            
            % figure
            % nexttile
            Y_left = fft(LFP_filtered.data(:,h));
            P2_left = abs(Y_left/L);
            P1_left = P2_left(1:L/2+1);
            P1_left(2:end-1) = 2*P1_left(2:end-1);
            f = LFP_filtered.Fs*(0:(L/2))/L;
            % plot(f,P1_left, 'k') 
            % ylim([0 2])
            % hold on
            % title(sprintf("%s - After syntetic paste", LFP_filtered.channel_names{h}))
            % xlabel("f (Hz)")
            % ylabel("|P1(f)|") 

            % Plot raw signal and cleaned one
            % figure
            % tiledlayout(2,1,"TileSpacing","tight")
            % nexttile
            % plot(LFP.data(:,h), 'g')
            % hold on 
            % plot(LFP_filtered.data(:,h), 'r')
            % ylim([-100 100])
            % xline(TI.TI_trig_LFP_referred, 'b--')
            % plot((TIsequence_alignedToTrigger*120)-60)
                
            
            % Find begining and end of each burst of 3 pulses
            Onsets = find(diff([0 TIsequence_alignedToTrigger]) == 1) - 1; % -1 to find the LAST zero before the artifact!
            End = find(diff([TIsequence_alignedToTrigger 0 ]) == -1) + 1;
            % Superimpose the beginning and end of each burst
            % xline(Onsets, 'g')
            % xline(End, 'r')
           

            
            
            % Smooth around the syntetic signal
            
%             for i=1:length(Onsets)    
%                     margin = 3; %2
%                     smoothing_degree = 6; %s
%                     smooth_range = (Onsets(i)-margin : Onsets(i)+margin);
%                     LFP_filtered.data(smooth_range, 1) = smoothdata(LFP_filtered.data(smooth_range, h), 'movmean', smoothing_degree);
%             
%                     smooth_range = (End(i)-margin : End(i)+margin);
%                     LFP_filtered.data(smooth_range, 1) = smoothdata(LFP_filtered.data(smooth_range, h), 'movmean', smoothing_degree);   
%             end
            
            
            
            % Plot spectrogram for filtered data - after syntetic signal paste and smoothing
        
            % figure
            % sgtitle('After synthetic paste and smoothing')
            % COMPats_PERCEPT_plot_BS(LFP_filtered,[],0,1)
             
            % Plot spectrum for filtered data - after syntetic signal paste and smoothing
            T = 1/LFP_filtered.Fs;             % Sampling period       
            L = fix(size(LFP_filtered.data, 1))-1;             % Length of signal
            t = (0:L-1)*T;        % Time vector
            
            % figure
            Y_left = fft(LFP_filtered.data(:,h));
            P2_left = abs(Y_left/L);
            P1_left = P2_left(1:L/2+1);
            P1_left(2:end-1) = 2*P1_left(2:end-1);
            f = LFP_filtered.Fs*(0:(L/2))/L;
            % plot(f,P1_left, 'b') 
            % ylim([0 2])
            % hold on
            % title(sprintf("%s - After synthetic paste and smoothing", LFP_filtered.channel_names{h}))
            % xlabel("f (Hz)")
            % ylabel("|P1(f)|") 

        end

        % Notch filter for DBS artifact
        notch_freq = 90.9;
        bw = 0.5;          % Bandwidth around 90 Hz (e.g., 2 Hz = notch from 89 to 91 Hz)
        
        % Design notch filter
        Wo = notch_freq / (LFP_filtered.Fs/2);               % Normalize frequency
        BW = bw / (LFP_filtered.Fs/2);               % Normalize bandwidth
        [b, a] = designNotchPeakIIR(Response="notch",CenterFrequency=Wo,Bandwidth=BW, FilterOrder=2);
        % [b, a] = iirnotch(Wo, BW);      % Design notch filter
        
        % Apply zero-phase filter
        LFP_filtered.data(:,h) = filtfilt(b, a, LFP_filtered.data(:,h));  % Replace with your variable


        % Plot spectrum for filtered data - after NOTCH
        T = 1/LFP_filtered.Fs;             % Sampling period       
        L = fix(size(LFP_filtered.data(:,h), 1))-1;             % Length of signal
        t = (0:L-1)*T;        % Time vector
        
        % figure
        Y_left = fft(LFP_filtered.data(:,h));
        P2_left = abs(Y_left/L);
        P1_left = P2_left(1:L/2+1);
        P1_left(2:end-1) = 2*P1_left(2:end-1);
        f = LFP_filtered.Fs*(0:(L/2))/L;
        % plot(f,P1_left, 'b') 
        % ylim([0 2])
        % hold on
        % title(sprintf("%s - Adding also notch", LFP_filtered.channel_names{h}))
        % xlabel("f (Hz)")
        % ylabel("|P1(f)|") 


     

    end % end loop over hemispheres
    
end