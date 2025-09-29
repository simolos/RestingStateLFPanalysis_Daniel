function plot_band_average_power(TableDataCondition, NameBehavCondition, NamePhasesOfInterest, TableSingleDataCondition)

    % Description: function to plot the power averages per band
    %   
    % Inputs:
    %   - TableDataCondition: 1×S cell array, S=number of subset table, 
    %       each one containing:
    %       - BxP table, B=number of bands of interest, P=number of 
    %           phases of interest. Each cell contains a 2x2 matrix, top row is 
    %           mean, bottom row is standard deviation; left is left 
    %           hemisphere, right is right hemisphere.
    %   - NameBehavCondition: 1×S cell array, S=number of subset table
    %   - NamePhasesOfInterest: 1×P cell array, P=number of phases to be
    %       represented in the plot
    %   - TableSingleDataCondition: 1×S cell array, S=number of subset 
    %       table, each one containing:
    %       - BxP table, B=number of bands of interest, P=number of phases 
    %           of interest. Each cell contains a Tx2 matrix, T=number of 
    %           trials, col1=left hemisphere, col2=right hemisphere.
    %
    % Created by Simona Losacco on 05/01/2025

  
    N_cond = size(NameBehavCondition, 2);
    N_channels = size(TableDataCondition{1}{1,1}{:}, 2);
    N_freq_bands = size(TableDataCondition{1}, 1);
    N_phases = length(NamePhasesOfInterest);

    colors = parula(4);

    legend_names = NameBehavCondition;
    phases_labels = NamePhasesOfInterest;
    freq_band_labels = TableDataCondition{1}.Properties.RowNames;
    channel_labels = {'ZERO TWO LEFT', 'ZERO TWO RIGHT' };    


%     power_ylim = [0 3.5; 0 1.5; 0 0.5; 0 0.5]; % for preDM and postDM plot
%     power_ylim = [0 3.5; -0.2 2; 0 0.6; -0.1 0.5]; % for preDM and postDM plot

    power_ylim = [-1 3.5; -0.2 1.5; -0.1 0.8; -0.1 0.5]; % for prepEP plot
%     power_ylim = [0 3.5; -0.2 1.5; -0.1 1; -0.1 0.7]; % for prepEP plot


    for ch = 1:N_channels

        if N_freq_bands == 1 
            if N_phases == 1
                figure('Position', [100, 100, 150, 300])
            elseif N_phases == 2
                figure('Position', [100, 100, 300, 300])
            end
        elseif N_freq_bands == 2
            if N_phases == 1
                figure('Position', [100, 100, 300, 300])
            elseif N_phases == 2
                figure('Position', [100, 100, 600, 300])
            end        
        elseif N_freq_bands == 3
            if N_phases == 1
                figure('Position', [100, 100, 450, 300])
            elseif N_phases == 2
                figure('Position', [100, 100, 900, 300])
            end        
        elseif N_freq_bands == 4
            if N_phases == 1
                figure('Position', [100, 100, 600, 300])
            elseif N_phases == 2
                figure('Position', [100, 100, 1200, 300])
            end           
        end

        t = tiledlayout(1,N_freq_bands);
        title(t, channel_labels{ch})
    
        for freq_band = 1:N_freq_bands
            nt = nexttile;
        
            for n = 1:N_cond

                  y = cellfun(@(x) x(1,ch), TableDataCondition{n}{freq_band,phases_labels}, 'UniformOutput', false);
                  err = cellfun(@(x) x(2,ch), TableDataCondition{n}{freq_band,phases_labels}, 'UniformOutput', false);
                  x = [1:N_phases] + 0.1*(n-1);

                  eb(n) = errorbar(x, [y{:}], [err{:}], '.', 'MarkerSize', 10, 'LineWidth', 1, 'CapSize', 10, 'Color', colors(n,:));
                  % if I want connected dots
                  % eb(n) = errorbar(x, [y{:}], [err{:}], '-', 'Marker', '.', 'MarkerSize', 10, 'LineWidth', 1, 'CapSize', 10, 'Color', colors(n,:)); 

                  hold on

                xlim([0.5 x(end)+0.5])
                xticks([1:N_phases]); % Set x-axis ticks to match the number of rows in y
                xticklabels(strrep(phases_labels, '_', ' ')); % Apply custom labels
                xtickangle(45); % Rotate labels for better readability if needed

                ylabel('Mean Power');
                ylim([power_ylim(freq_band, :)])

                if ch== 1 && freq_band == 1 % This assuming that the number of points averaged is the same for all the phases displayed! I should add a check for this -SL
                    % Get number of points for the legend
                    Npoints(n) = sum(~isnan(TableSingleDataCondition{n}{1, phases_labels(1)}{:}(:,1)), 1); % 1 because all frequency bands have are the same
    
                    % Add number of points to the legend
                    legend_names{n} = sprintf('%s N=%d', legend_names{n}, Npoints(n));
                end

            end



            if freq_band == N_freq_bands 
                legend(eb, legend_names, 'Location', 'eastoutside');
            end
            title(nt, freq_band_labels{freq_band})

        end
    
    end


end