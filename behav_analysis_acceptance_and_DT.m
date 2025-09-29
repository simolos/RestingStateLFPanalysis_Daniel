function behav_analysis_acceptance_and_DT(TableBehavSubset)

    RewardLevels = sort(unique(TableBehavSubset.Reward));
    EffortLevels = sort(unique(TableBehavSubset.Effort), 'descend');
    
    [x,y] = meshgrid(RewardLevels, EffortLevels);
    VectorX = reshape(x', [1,numel(x)]);
    VectorY = reshape(y', [1,numel(y)]);
    VectorAcceptance = NaN(size(VectorX));
    VectorDT = NaN(size(VectorX));
    
    for i=1:numel(VectorAcceptance)
       num_accepted = sum(TableBehavSubset.Reward == VectorX(i) & TableBehavSubset.Effort == VectorY(i) & TableBehavSubset.Acceptance == 1);
       num_total = sum(TableBehavSubset.Reward == VectorX(i) & TableBehavSubset.Effort == VectorY(i));
       VectorAcceptance(i) = num_accepted/num_total;
    
       VectorDT(i) = mean(TableBehavSubset.DecisionTime(TableBehavSubset.Reward == VectorX(i) & TableBehavSubset.Effort == VectorY(i) & TableBehavSubset.Acceptance ~= -1));
    end
    
    MeshAcceptance = reshape(VectorAcceptance, size(x))';
    MeshDT = reshape(VectorDT, size(x))';
    
    figure
    subplot(2,1,1)
    imagesc(MeshAcceptance)
    hold on
    [row,col] = find(isnan(MeshAcceptance));
    plot(row, col, 's', 'MarkerSize', 38, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0 0 0]); % Magenta
    yticks([1 2 3 4])
    xticks([1 2 3 4])
    yticklabels(EffortLevels)
    xlabel('Reward (cents)')
    ylabel('Effort (%MTF)')
    xticklabels(RewardLevels)
    colorbar
    title('Acceptance')
    
    subplot(2,1,2)
    imagesc(MeshDT, [0 1.1])
    hold on
    [row,col] = find(isnan(MeshDT));
    plot(row, col, 's', 'MarkerSize', 38, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0 0 0]); % Magenta
    yticks([1 2 3 4])
    xticks([1 2 3 4])
    yticklabels(EffortLevels)
    xlabel('Reward (cents)')
    ylabel('Effort (%MTF)')
    xticklabels(RewardLevels)
    colorbar
    title('Decision Time [s]')
    
    set(gcf,'position',[100,100,300,510])


end