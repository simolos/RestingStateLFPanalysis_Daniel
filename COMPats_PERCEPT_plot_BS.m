function COMPats_PERCEPT_plot_BS(LFP,EMG,offset,patientNum)
%%
% if( ispc )
%     addpath(genpath(['C:\Users\\emartinm\Dropbox\_TMP\LFP_Cybex\chronux_2_12\']))
    addpath(genpath(['L:\PhD\Simona\Park-invasiveDBS\20230926_ITIS_Zurich\CODE\chronux_2_10']))

% else
%     addpath(genpath(['/Users/bsi/Dropbox/_TMP/LFP_Cybex/chronux_2_12/']))
%     addpath(genpath(['L:\PhD\Simona\Park-invasiveDBS\20230926_ITIS_Zurich\CODE\chronux_2_10']))

% end


%% SPECTROGRAM PARAMS
fmin            = 2;   % min frequency
fmax            = 125;  % max frequency (120)
window_size     = 0.5; %0.5;  % window size for FFT in s
shift_inc       = 50;  % shift increment in ms
delta_f         = 1;   % frequency increment (in Hz)
n_taper         = 3;   % number of tapers (integer >=1)

t_par.Fs        = LFP.Fs;
t_par.tapers    = [(n_taper+1)/2 n_taper];
t_par.fpass     = [fmin fmax];
t_par.pad       = nextpow2(2^nextpow2(1/window_size)/delta_f);


LFP.nChannels = length(LFP.channel_names); % in case error


sig4spec = LFP.data(:,1);
sigName = LFP.channel_names{1};

if(  ~isempty( regexpi(sigName,'RIGHT') ) ), this_subplot = 1; 
else, this_subplot = 2;
end

[P,T,F] = mtspecgramc(sig4spec,[window_size,shift_inc/1000],t_par);
P       = P'; 
N_win   = window_size*LFP.Fs;
P       = 2*LFP.Fs/N_win * P;  % P is now in mV^2/Hz

%P = ( P )./median(P(:,[1:1000]),2);
%P = zscore(P,0,2);

ax(2) = subplot(3,1,this_subplot);
imagesc(T,F,10*log(P)); hold on;
axis xy; ylabel('Frequency'); title(sigName,'fontsize',13,'interpreter','none')
set(gca,'ylim',[5 125]);

caxis([-80 30])
plot([0 LFP.time(end)],[20 20],'w--')
plot([0 LFP.time(end)],[30 30],'w--')
colorbar


if(LFP.nChannels>1)
    sig4spec = LFP.data(:,2);
    sigName = LFP.channel_names{2};
    
    if(  ~isempty( regexpi(sigName,'RIGHT') ) ), this_subplot = 1;
    else, this_subplot = 1;
    end
    
    [P,T,F] = mtspecgramc(sig4spec,[window_size,shift_inc/1000],t_par);
    P       = P';
    %P = ( P  )./std(P,0,2);
    N_win   = window_size*LFP.Fs;
    P       = 2*LFP.Fs/N_win * P;  % P is now in mV^2/Hz
    
%     P = ( P )./median(P(:,[1:1000]),2);
    %P = ( P )./mean(P,2);
    %P = zscore(P,0,2);
    
    ax(1) = subplot(3,1,this_subplot);
    imagesc(T,F,10*log(P)); hold on;
    axis xy; ylabel('Frequency'); title(sigName,'fontsize',13,'interpreter','none')
    set(gca,'ylim',[5 125]);
    
    caxis([-80 30])
    plot([0 LFP.time(end)],[20 20],'w--')
    plot([0 LFP.time(end)],[30 30],'w--')
    colorbar

    %}
end

grid on
linkaxes(ax,'x')




