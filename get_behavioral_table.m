function TableBehav = get_behavioral_table(behav, PhaseTag)

    % Description: function to create the table containing the behavior of
    % the subject for a specific block of the task.  
    %   
    % Inputs:
    %   - behav: struct containing all the behavioral info from one block, 
    %       output of the task.
    %   - PhaseTag: name of the phase under analysis
    %
    % Outputs:
    %   - TableBehav: TxN table, T=number of trials in the block under
    %       analysis, N=number of phases of interest + 4 (columns for Subj,
    %       Phase, Block and Trial codes)
    %
    % Created by Simona Losacco on 05/01/2025

    if contains(behav.block_name, 'RS')

        Subj = behav.SubjectNum';
        Phase = {PhaseTag}';
        Block = {behav.block_name}';     
        Trial = 1; % default value
        Duration = 210000; % 3'30'' in ms

        TableBehav = table(Subj, Phase, Block, Trial, Duration);
    else
        Subj = repelem(behav.SubjectNum, behav.nTrials)';
        Phase = repelem({PhaseTag}, behav.nTrials)';
        Block = repelem({behav.block_name}, behav.nTrials)';
        Trial = behav.trials.trial;

        if contains(behav.block_name, 'B')
            Reward = behav.trials.reward; 
            Effort = behav.trials.effort;
            AnticipationDM = behav.trials.Anticipation_DM;
            DecisionTime = behav.trials.DecisionTime;
            Acceptance = behav.trials.Acceptance;
            EffortProd = behav.trials.EffortProduction;
            ReactionTime = behav.trials.ReactionTimeEP;
            AnticipationEP = behav.trials.Anticipation_EP;
            Success = behav.trials.success;
            CURSOR = mat2cell(behav.CURSOR, size(behav.CURSOR, 1), ones(1,size(behav.CURSOR, 2)))';
            EffortTested = behav.trials.efftested;
            RewardTested = behav.trials.rewtested;
    
        elseif contains(behav.block_name, 'EffProd')
            Reward = repelem(NaN, behav.nTrials)'; 
            Effort = behav.trials.effort;
            AnticipationDM = repelem(NaN, behav.nTrials)'; 
            DecisionTime = repelem(NaN, behav.nTrials)'; 
            Acceptance = repelem(NaN, behav.nTrials)'; 
            EffortProd = repelem(1, behav.nTrials)'; % This field doesn't exist in EffProd because we assume it's always 1. I'm adding it for processing reasons
            ReactionTime = repelem(NaN, behav.nTrials)';
            AnticipationEP = behav.trials.Anticipation_EP;
            Success = behav.trials.success;
            CURSOR = mat2cell(behav.CURSOR, size(behav.CURSOR, 1), ones(1,size(behav.CURSOR, 2)))';
            EffortTested = behav.trials.efftested;
            RewardTested = behav.trials.rewtested;
    
        elseif contains(behav.block_name, 'FCRT')
            Reward = repelem(NaN, behav.nTrials)'; 
            Effort = behav.trials.ForcedChoiceValue; % This is the value of the forced choice
            AnticipationDM = behav.trials.Anticipation_DM;
            DecisionTime = behav.trials.PressTime;
            Acceptance = behav.trials.ActualKeyPressed; 
            EffortProd = repelem(0, behav.nTrials)'; % This field doesn't exist in EffProd because we assume it's always 1. I'm adding it for processing reasons
            ReactionTime = repelem(NaN, behav.nTrials)';
            AnticipationEP = repelem(NaN, behav.nTrials)';        
            Success = repelem(NaN, behav.nTrials)';
            CURSOR = repelem(NaN, behav.nTrials)';
            EffortTested = repelem(NaN, behav.nTrials)';
            RewardTested = behav.trials.rewtested;
    
        end
    
    
        TableBehav = table(Subj, Phase, Block, Trial, Effort, Reward, ... 
            AnticipationDM, DecisionTime, Acceptance, EffortProd, ReactionTime, ...
            AnticipationEP, Success, CURSOR, EffortTested, RewardTested);

    end
end

