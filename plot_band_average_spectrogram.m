function plot_band_average_spectrogram(TableDataCondition_average, TableDataCondition_SE, NameBehavCondition, NamePhaseOfInterest, N_trials_averaged)

    
    % if isempty(NameBehavCondition) % Superimpose all 
    %     N_cond = 1;


    N_cond = size(NameBehavCondition, 2);
    N_channels = 2; %size(TableDataCondition_average{1}{1, NamePhaseOfInterest}{:}, 2);
    N_freq_bands = size(TableDataCondition_average{1}, 1);
    if length(NamePhaseOfInterest) > 1
        error('Must specify only one phase!')
    end

    colors = lines(4);

    legend_names = NameBehavCondition;
    freq_band_labels = TableDataCondition_average{1}.Properties.RowNames;
    channel_labels = {'ZERO TWO LEFT', 'ZERO TWO RIGHT' };    


%     power_ylim = [0 3.5; 0 1.5; 0 0.5; 0 0.5]; % for preDM and postDM plot
%     power_ylim = [0 3.5; -0.2 2; 0 0.6; -0.1 0.5]; % for preDM and postDM plot

    power_ylim = [-1 3.5; -0.2 1.5; -0.1 0.8; -0.1 0.5]; % for prepEP plot
%     power_ylim = [0 3.5; -0.2 1.5; -0.1 1; -0.1 0.7]; % for prepEP plot



    for ch = 1:N_channels

        if N_freq_bands == 1 
            figure('Position', [100, 100, 300, 300])
        elseif N_freq_bands == 2
            figure('Position', [100, 100, 600, 300])
        elseif N_freq_bands == 3
            figure('Position', [100, 100, 900, 300])
        elseif N_freq_bands == 4
            figure('Position', [100, 100, 1200, 300])
        end

        
        t = tiledlayout(1,N_freq_bands);
        title(t, sprintf('%s - %s', replace(NamePhaseOfInterest{1}, "_", " "), channel_labels{ch}))
    
        for freq_band = 1:N_freq_bands
            nt = nexttile;
        
            for n = 1:N_cond

                
                time_point = 1:length(TableDataCondition_average{n}{freq_band, NamePhaseOfInterest}{:}(:,ch));

                upper_shade = TableDataCondition_average{n}{freq_band, NamePhaseOfInterest}{:}(:,ch) + TableDataCondition_SE{n}{freq_band, NamePhaseOfInterest}{:}(:,ch);
                lower_shade = TableDataCondition_average{n}{freq_band, NamePhaseOfInterest}{:}(:,ch) - TableDataCondition_SE{n}{freq_band, NamePhaseOfInterest}{:}(:,ch);
                light_color = colors(n, :) + (1 - colors(n, :)) * 0.5;
                fill([time_point fliplr(time_point)],[upper_shade' fliplr(lower_shade')],  light_color, 'EdgeColor', 'none', 'FaceAlpha', 0.3);  % light blue with transparency
                hold on

                line(n) = plot(time_point, TableDataCondition_average{n}{freq_band, NamePhaseOfInterest}{:}(:,ch)', 'Color', colors(n,:));

                ylabel('Mean+-SE Power');

                xlim([0 numel(time_point)])

                if numel(time_point)/250 < 0.6
                    tick_step = 250 * 0.1; % 100 ms in samples
                else
                    tick_step = 250 * 0.2; % 100 ms in samples
                end
                xticks = 0:tick_step:numel(time_point);
                
                % Convert tick positions to seconds
                xtick_labels = (xticks / 250);
%                 xtick_labels = (xticks / 250) - 0.2; % WATCH OUTTTTTTTT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%                 xline(tick_step, '--', 'DMade')

                % Apply to plot
                set(gca, 'XTick', xticks);
                set(gca, 'XTickLabel', arrayfun(@(x) sprintf('%.1f', x), xtick_labels, 'UniformOutput', false));
                
                xlabel('Time (s)');
                               
                % Add number of points to the legend
                if freq_band == length(freq_band) && ch == length(N_channels)
                    legend_names{n} = sprintf('%s N=%d', legend_names{n}, N_trials_averaged(n));
                end
                

            end



            title(nt, freq_band_labels{freq_band})

        end
        legend(line, legend_names, 'Location', 'eastoutside');

    
    end


end