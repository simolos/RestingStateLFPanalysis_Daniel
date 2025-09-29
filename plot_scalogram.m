function plot_scalogram(signal_to_plot, CutIdx, LFP_run, params, XTickLabels, N)


    nPhases = length(CutIdx) + 1;

    params.channel_map    = LFP_run{1}.channel_map;
    params.channel_names  = LFP_run{1}.channel_names;
    params.nChannels      = LFP_run{1}.nChannels;
    params.Fs             = LFP_run{1}.Fs;
    
    %params.frequencies                   = processData.CW.frequencies;
    
    params.ylabel   = 'Frequency Hz';
    params.xlabel   = 'Time s';
    params.clabel   = 'Magnitude';
    params.spectfun = 'cwt';
    params.type     = categorical({'spectrum'});
    params.time          = (1:size(signal_to_plot, 2))/LFP_run{1}.Fs;

    plotCWTspectrogram2(signal_to_plot, params)

    gcf
    h1 = subplot(2,1,1);
    title(h1, sprintf('Left hemisphere - N=%d', N));
    h1 = subplot(2,1,2);
    title(h1, sprintf('Right hemisphere - N=%d', N));


    hold on
    subplot(2,1,1), caxis([-0.9 1.2]); set(gca,'ylim',[3 100]) % [-0.9 0.6] for baseline PrepDM     [-0.9 15] for baseline Intertrial
    yline([10 20 30],'w-', 'LineWidth',2)
    if ~isempty(CutIdx)
        xline(CutIdx/params.Fs,'w-', 'LineWidth',2);
        xticks([1 CutIdx length(signal_to_plot)]/params.Fs)
        xticklabels(XTickLabels)
        xlabel('')
    end
    
    subplot(2,1,2), caxis([-0.9 1.2]); set(gca,'ylim',[3 100])
    yline([10 20 30],'w-', 'LineWidth',2)
    if ~isempty(CutIdx)
        xline(CutIdx/params.Fs,'w-', 'LineWidth',2);
        xticks([1 CutIdx length(signal_to_plot)]/params.Fs)
        xticklabels(XTickLabels)
        xlabel('')
    end

    if nPhases == 1
        set(gcf,'position',[350   50  300   800])
    elseif nPhases == 2
        set(gcf,'position',[350   50  600   800])
    else
        set(gcf,'position',[350   50  1400   800]) %1200 for PD
    end




end