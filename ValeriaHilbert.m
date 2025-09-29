%% OCD patient only diveded by effort (High/Low) disgregarding the acceptance
% Hilbert Trasnform in the following phase compared between efforts (single trial):
% - baseline last 0.8s of prepDM (new baseline)
% - DM phase 
% - post DM phase (ITI)
% - post post DM phase 

 
clear all; clc; warning off
close all;

%% Init
addpath(genpath('C:\Users\User\NeuroRestore Dropbox\Valeria De Seta\_PIPELINE'))
addpath(genpath(['C:\Users\User\NeuroRestore Dropbox\Valeria De Seta\chronux_2_12']))
path = '/Users/deseta/NeuroRestore Dropbox/Valeria De Seta/DM_Task_LFP/20241030_OCD2_GVA';
data_folder ='Processed_Ste';
behav_data_folder_AM = 'Behavioral data/OCD2_AM_1';
behav_data_folder_PM = 'Behavioral data/OCD2_PM_2';
tag_session = {'AM','AM','PM','PM'};
output_folder = 'Plots/Power';
outputpath_dir = fullfile(path,output_folder);
if ~exist(outputpath_dir,'dir')
    mkdir(outputpath_dir);
end
subject = 'OCD2';
run = {8,9,21,22}; %[6,7,10,11] AM; [4,5,81,82,9] PM
run_name= {'B1','B2','B1','B2'}; %{'B1_1_2024','B1_2_2024','B2'};
flag_normalisePower = 1;
tag = 'Power-Effort-DMphase-AllSessions-DBS-OFF';

Power_DM_all_runs_High = [];
Power_DM_all_runs_Low = [];
Power_postDM_all_runs_High = [];
Power_postDM_all_runs_Low = [];
Power_newTr_all_runs_High = [];
Power_newTr_all_runs_Low = [];
bands = [3 8;8 12;12 30;30 80];
bands_name = {'theta','alpha','beta','gamma'};
BP_order = 3;



%%
for r = 1:length(run)
    numFile = run{r};
    sess = tag_session{r};
    disp(num2str(numFile))
    % loading data
    trigger_filename =strcat('TriggerDecoding_',subject,'_',sess,'_rec',num2str(numFile),'.mat');
    load(fullfile(path,'Triggers',trigger_filename))
    if strcmp(subject,'OCD2')
       load(fullfile(path,data_folder,'LFP',['LFP_rec',num2str(numFile)]))
       load(fullfile(path,data_folder,'EMG',['EMG_rec',num2str(numFile)]))
    end
    % behavioral data
    % Get a list of all files in the folder
    switch sess 
        case 'AM'
            fileList = dir(fullfile(path,behav_data_folder_AM));
            % Extract  the names of the files 
            fileNames = {fileList(~[fileList.isdir]).name};
            idx_behavfilename = find(contains(fileNames,['S2_',run_name{r}]));
            behav_filename = fileNames{idx_behavfilename};
            behav = load(fullfile(path,behav_data_folder_AM,behav_filename));
            if strcmp(subject,'OCD1')
                load(fullfile(path,data_folder,'Session1_AM', ['LFP_rec',num2str(numFile)]))
                load(fullfile(path,data_folder,'Session1_AM',['EMG_rec',num2str(numFile)]))
            end
        case 'PM'
            fileList = dir(fullfile(path,behav_data_folder_PM));
            % Extract  the names of the files 
            fileNames = {fileList(~[fileList.isdir]).name};
            idx_behavfilename = find(contains(fileNames,['S2_',run_name{r}]));
            behav_filename = fileNames{idx_behavfilename};
            behav = load(fullfile(path,behav_data_folder_PM,behav_filename));
            if strcmp(subject,'OCD1')
                load(fullfile(path,data_folder,'Session2_PM', ['LFP_rec',num2str(numFile)]))
                load(fullfile(path,data_folder,'Session2_PM',['EMG_rec',num2str(numFile)]))
            end
    end
    Trig = TriggerInfo;
      
    clear TriggerInfo
    
    disp('loaded')
    % check for NaN value
    NaNidx = find(isnan(LFP.data(:,1)));
    if ~isempty(NaNidx) % && numFile~= 8 %--> OCD1
        disp('Warning NaN values detected')
        % interpolation
        valid_idx = ~isnan(LFP.data(:,2));
        LFP.data(:,1)= interp1(LFP.time(valid_idx),LFP.data(valid_idx,1),LFP.time, 'pchip');
        LFP.data(:,2)= interp1(LFP.time(valid_idx),LFP.data(valid_idx,2),LFP.time, 'pchip');
    end     
       %% --- Behavioral data 
    if isfield(behav, 'trials')
        DM_Acceptance = behav.trials.Acceptance;
        DM_Reward = behav.trials.reward;
        DM_Effort = behav.trials.effort;
        DM_Task = behav.trials.EffortProduction;
    elseif isfield(behav, 'trials_new')
        DM_Acceptance = behav.trials_new.Acceptance;
        DM_Reward = behav.trials_new.reward;
        DM_Effort = behav.trials_new.effort;
        DM_Task = behav.trials_new.EffortProduction;
    end
    DM_YES = sum(DM_Acceptance);
    DM_NO = length(DM_Acceptance)-DM_YES;
    DM_RewardLevels = unique(DM_Reward);
    DM_EffortLevels = unique(DM_Effort);
    DM_TaskTrials = nansum(DM_Task);
    DM_Effort_2lev = zeros(length(DM_Effort),1);

    DM_Effort_2lev(DM_Effort>=0.80)=1;
    DM_High = sum(DM_Effort_2lev);
    DM_Low = length(DM_Effort_2lev)-DM_High;

%     DM_High_idx = find(DM_Effort>0.8);
%     DM_Low_idx = find(DM_Effort<0.65);
% 
%     DM_High = length(DM_High_idx);
%     DM_Low = length(DM_Low_idx);
    if numFile == 81
       DM_High = DM_High-1;
    end  
    
    %% --- Filtering the signal
    Data_bands = [];
    Data_hilb = [];
    for b = 1:size(bands,1)
            BP_freq = bands(b,:);
            Wn = BP_freq / (LFP.Fs/2);
            [b_BP a_BP]= butter(BP_order, Wn); % Butterworth Band-pass filter, 6° order 
            Data_bands(:,:,b) = filtfilt(b_BP,a_BP,LFP.data);
            Data_hilb(:,:,b) = abs(hilbert(Data_bands(:,:,b)').^2);
    end
    
    %% check
       % for b = 1:size(bands,1)
       %      figure            
       %      plot(squeeze(Data_hilb(2,:,b)))
       %      title(bands_name{b})
       % end
    %% --- MARKER EXTRACTION
    % Nburst_TrialBeginning = 4; 
    % Nburst_PrepDM = 7;
    % Nburst_StartDM = 1;
    % Nburst_DecidedYes = 2;
    % Nburst_DecidedNo = 2;
    % Nburst_PrepEP = 5; 
    % Nburst_Anticip = 6; 
    % Nburst_StartEP = 8; 
    % Nburst_WaitingFeedback = 3;
    % Nburst_Feedback = 10; 
    % Nburst_TotalReward = 9;

   
    idx_4 = find( Trig == 4); N4 = length(idx_4);
    idx_7 = find( Trig == 7); N7 = length(idx_7);
    idx_1 = find( Trig == 1); N1 = length(idx_1);
    idx_2 = find( Trig == 2); N2 = length(idx_2);
    idx_5 = find( Trig == 5); N5 = length(idx_5);
    idx_6 = find( Trig == 6); N6 = length(idx_6);
    idx_8 = find( Trig == 8); N8 = length(idx_8);
    idx_3 = find( Trig == 3); N3 = length(idx_3);
    idx_10 = find( Trig == 10); N10 = length(idx_10);
    idx_9 = find( Trig == 9); N9 = length(idx_9);

    ALL_EVS = [ [idx_7' 7*ones(N7,1)] ; [idx_1' 1*ones(N1,1)] ; [idx_2' 2*ones(N2,1)]];
    ALL_EVS = sortrows(ALL_EVS,1);
    ALL_EVS = reshape(ALL_EVS(:,1),3,[])';


     %% --- Selecting High and Low Effort trials
    idx_4_High = [];
    idx_7_High = [];
    idx_1_High = [];
    idx_2_High = [];
    idx_4_Low = [];
    idx_7_Low  = [];
    idx_1_Low  = [];
    idx_2_Low  = [];

    idx_High = find(DM_Effort_2lev);
    idx_Low = find(~DM_Effort_2lev);
%     idx_High = DM_High_idx;
%     idx_Low = DM_Low_idx;
    if numFile == 81 % --> OCD1
        idx_High(end) = [];
    end
    idx_4_High = idx_4(idx_High);
    idx_7_High = idx_7(idx_High);
    idx_1_High = idx_1(idx_High);
    idx_2_High = idx_2(idx_High);
    idx_4_Low = idx_4(idx_Low);
    idx_7_Low = idx_7(idx_Low);
    idx_1_Low = idx_1(idx_Low);
    idx_2_Low = idx_2(idx_Low);
       
    ALL_EVS_High = [[idx_7_High' 7*ones(DM_High,1)] ; [idx_1_High' 1*ones(DM_High,1)] ; [idx_2_High' 2*ones(DM_High,1)]];
    ALL_EVS_High = sortrows(ALL_EVS_High,1);
    ALL_EVS_High = reshape(ALL_EVS_High(:,1),3,[])';

    ALL_EVS_Low = [[idx_7_Low' 7*ones(DM_Low,1)] ; [idx_1_Low' 1*ones(DM_Low,1)] ; [idx_2_Low' 2*ones(DM_Low,1)]];
    ALL_EVS_Low = sortrows(ALL_EVS_Low,1);
    ALL_EVS_Low = reshape(ALL_EVS_Low(:,1),3,[])';

   
    %% -- TRIALS CONCATENATION BY PHASE
    % baseline
    idx_base = [];
    for iu = 1: length(idx_1)
        idx_base = [idx_base, [find(LFP.time>=EMG.time(idx_1(iu)-round(0.8*EMG.Fs)+1),1) : find(LFP.time >= EMG.time(idx_1(iu)),1) ] ]; 
    end

    % Data_base = Data_bands(idx_base,:,:);
    Data_hilb_base = Data_hilb(:,idx_base,:);
    %% check
       % for b = 1:size(bands,1)
       %      figure            
       %      plot(squeeze(Data_hilb_base(2,:,b)))
       %      title(bands_name{b})
       % end
    %%
    min_dur_DM = min(ALL_EVS(:,3)-ALL_EVS(:,2));
    disp('min duration DM')
    disp(num2str(min_dur_DM/EMG.Fs))
    
    % phases
    EVS_phases_High = ALL_EVS_High(:,2:end);
    EVS_phases_Low = ALL_EVS_Low(:,2:end);
    dur = 0.5; %(s)
    borders_i_High = phase_extraction(EVS_phases_High,dur,EMG.Fs,LFP.time,EMG.time);
    borders_i_Low = phase_extraction(EVS_phases_Low,dur,EMG.Fs,LFP.time,EMG.time);
    %% check
      %  for b = 1:size(bands,1)
      %   figure
      %   for tr = 1:length(idx_High)
      %       % power_check{tr,b} = abs(hilbert(Data_bands(borders_i_High(tr,1)+1:borders_i_High(tr,2),:,b)').^2);
      %       power_check{tr,b} = Data_hilb(:,borders_i_High(tr,1)+1:borders_i_High(tr,2),b);
      %       signal2plot = power_check{tr,b};
      %       plot( signal2plot(2,:))
      %       hold on
      % 
      %   end
      %   title(bands_name{b})
      %  end
      % 
      % for b = 1:size(bands,1)
      %   figure
      %   for tr = 1:length(idx_High)
      %       % power_check2{tr,b} = abs(hilbert(Data_bands(borders_i_Low(tr,1)+1:borders_i_Low(tr,2),:,b)').^2);
      %       power_check2{tr,b} = Data_hilb(:,borders_i_Low(tr,1)+1:borders_i_Low(tr,2),b);
      %       signal2plot = power_check2{tr,b};
      %       plot(signal2plot(2,:))
      %       hold on
      % 
      %   end
      %    title(bands_name{b})
      %  end
    %% --- Hilbert Transform + mean on band
    Power_base_mean = [];
    Power_base_std = [];
    Power_phase_DM_High = [];
    Power_phase_postDM_High = [];
    Power_phase_newTr_High = [];
    Power_phase_DM_Low = [];
    Power_phase_postDM_Low = [];
    Power_phase_newTr_Low = [];

    % for b = 1:size(bands,1)
    %     Power_base_mean(:,b) = median(abs(hilbert(Data_base(:,:,b)').^2),2);
    %     Power_base_std(:,b) = mad(abs(hilbert(Data_base(:,:,b)').^2),1,2);
    %     for tr = 1:length(idx_High)
    %         Power_phase_DM_High(:,tr,b) = median(abs(hilbert(Data_bands(borders_i_High(tr,1)+1:borders_i_High(tr,2),:,b)').^2),2);
    %         Power_phase_postDM_High(:,tr,b) = median(abs(hilbert(Data_bands(borders_i_High(tr,2)+1:borders_i_High(tr,3),:,b)').^2),2);
    %         Power_phase_newTr_High(:,tr,b) = median(abs(hilbert(Data_bands(borders_i_High(tr,3)+round(0.5*LFP.Fs)+1:borders_i_High(tr,3)+round(LFP.Fs),:,b)').^2),2);
    %     end
    %     for tr = 1:length(idx_Low)
    %         Power_phase_DM_Low(:,tr,b) = median(abs(hilbert(Data_bands(borders_i_Low(tr,1)+1:borders_i_Low(tr,2),:,b)').^2),2);
    %         Power_phase_postDM_Low(:,tr,b) = median(abs(hilbert(Data_bands(borders_i_Low(tr,2)+1:borders_i_Low(tr,3),:,b)').^2),2);
    %         Power_phase_newTr_Low(:,tr,b) = median(abs(hilbert(Data_bands(borders_i_Low(tr,3)+round(0.5*LFP.Fs)+1:borders_i_Low(tr,3)+round(LFP.Fs),:,b)').^2),2);
    %     end
    % end
     for b = 1:size(bands,1)
        Power_base_mean(:,b) = mean(Data_hilb_base(:,:,b),2);
        Power_base_std(:,b) = std(Data_hilb_base(:,:,b),0,2);
        for tr = 1:length(idx_High)
            Power_phase_DM_High(:,tr,b) = mean(Data_hilb(:,borders_i_High(tr,1)+1:borders_i_High(tr,2),b),2);
            Power_phase_postDM_High(:,tr,b) = mean(Data_hilb(:,borders_i_High(tr,2)-round(0.5*LFP.Fs)+1:borders_i_High(tr,3),b),2);
            Power_phase_newTr_High(:,tr,b) = mean(Data_hilb(:,borders_i_High(tr,3)+round(0.5*LFP.Fs)+1:borders_i_High(tr,3)+round(LFP.Fs),b),2);
        end
        for tr = 1:length(idx_Low)
            Power_phase_DM_Low(:,tr,b) = mean(Data_hilb(:,borders_i_Low(tr,1)+1:borders_i_Low(tr,2),b),2);
            Power_phase_postDM_Low(:,tr,b) = mean(Data_hilb(:,borders_i_Low(tr,2)-round(0.5*LFP.Fs)+1:borders_i_Low(tr,3),b),2);
            Power_phase_newTr_Low(:,tr,b) = mean(Data_hilb(:,borders_i_Low(tr,3)+round(0.5*LFP.Fs)+1:borders_i_Low(tr,3)+round(LFP.Fs),b),2);
        end
    end
    %% ---- NORMALIZATION 
    % NORMALISE with respect to the 0.8s before start decision
    if( flag_normalisePower )
       for b = 1:size(bands,1)
           for ch = 1:size(Power_base_mean,1)
               Power_phase_DM_High(ch,:,b) =  (Power_phase_DM_High(ch,:,b)-Power_base_mean(ch,b))./Power_base_std(ch,b);
               Power_phase_postDM_High(ch,:,b) =  (Power_phase_postDM_High(ch,:,b)-Power_base_mean(ch,b))./Power_base_std(ch,b);
               Power_phase_newTr_High(ch,:,b) =  (Power_phase_newTr_High(ch,:,b)-Power_base_mean(ch,b))./Power_base_std(ch,b);
               Power_phase_DM_Low(ch,:,b) =  (Power_phase_DM_Low(ch,:,b)-Power_base_mean(ch,b))./Power_base_std(ch,b);
               Power_phase_postDM_Low(ch,:,b) =  (Power_phase_postDM_Low(ch,:,b)-Power_base_mean(ch,b))./Power_base_std(ch,b);
               Power_phase_newTr_Low(ch,:,b) =  (Power_phase_newTr_Low(ch,:,b)-Power_base_mean(ch,b))./Power_base_std(ch,b);
           end
       end
    
    end  
       
    %% --- all runs
    Power_DM_all_runs_High = cat(2,Power_DM_all_runs_High, Power_phase_DM_High);
    Power_DM_all_runs_Low = cat(2,Power_DM_all_runs_Low,Power_phase_DM_Low);
    Power_postDM_all_runs_High = cat(2,Power_postDM_all_runs_High,Power_phase_postDM_High);
    Power_postDM_all_runs_Low = cat(2,Power_postDM_all_runs_Low,Power_phase_postDM_Low);
    Power_newTr_all_runs_High = cat(2,Power_newTr_all_runs_High,Power_phase_newTr_High);
    Power_newTr_all_runs_Low = cat(2,Power_newTr_all_runs_Low,Power_phase_newTr_Low);
    N_tr_High{r} = length(idx_High);
    N_tr_Low{r} = length(idx_Low);
    
    clear idx_base
end % loop on runs

%% --- Plot
N_tr = size(Power_newTr_all_runs_Low,2);
phases = {'DM','PostDM','NewTr'};
for b = 1:length(bands_name)
    % ch1
    title_fig = strcat(bands_name{b},'-',LFP.channel_names{1});
    Power_High = [squeeze(Power_DM_all_runs_High(1,:,b));squeeze(Power_postDM_all_runs_High(1,:,b));squeeze(Power_newTr_all_runs_High(1,:,b))]';
    Power_Low = [squeeze(Power_DM_all_runs_Low(1,:,b));squeeze(Power_postDM_all_runs_Low(1,:,b));squeeze(Power_newTr_all_runs_Low(1,:,b))]';
    boxplot_parameters_gramm(Power_High,Power_Low,title_fig,N_tr,phases)
    saveas(gcf, fullfile(outputpath_dir,title_fig), 'png')
    % ch2
    title_fig = strcat(bands_name{b},'-',LFP.channel_names{2});
    Power_High = [squeeze(Power_DM_all_runs_High(2,:,b));squeeze(Power_postDM_all_runs_High(2,:,b));squeeze(Power_newTr_all_runs_High(2,:,b))]';
    Power_Low = [squeeze(Power_DM_all_runs_Low(2,:,b));squeeze(Power_postDM_all_runs_Low(2,:,b));squeeze(Power_newTr_all_runs_Low(2,:,b))]';
    boxplot_parameters_gramm(Power_High,Power_Low,title_fig,N_tr,phases)
    % saveas(gcf, fullfile(outputpath_dir,title_fig), 'png')

end
%%
for b = 1:length(bands_name)
    figure
    subplot(1,2,1)
    high = squeeze(Power_newTr_all_runs_High(1,:,b));
    low = squeeze(Power_newTr_all_runs_Low(1,:,b));
    data2plot = [high;low];
    data_type = [ones(length(high),1); zeros(length(low),1)];
    h1 = boxplot(data2plot,data_type);
    xticklabels({'High','Low'});
    box off
    set(h1(:,1), 'Color', '#abd0e6');
    set(h1(:,2), 'Color', '#3787c0');
    title(LFP.channel_names{1})
    ylim([-1 2.5])
    subplot(1,2,2)
    high = squeeze(Power_newTr_all_runs_High(2,:,b));
    low = squeeze(Power_newTr_all_runs_Low(2,:,b));
    data2plot = [high;low];
    data_type = [ones(length(high),1); zeros(length(low),1)];
    h2 = boxplot(data2plot,data_type);
    xticklabels({'High','Low'});
    box off
    set(h2(:,1), 'Color', '#abd0e6');
    set(h2(:,2), 'Color', '#3787c0');
    title(LFP.channel_names{2})
    ylim([-1 2.5])
    title_fig = strcat(bands_name{b},'-',tag);
    suptitle(title_fig)
    %% --- Saving Section
    %saveas(gcf, fullfile(outputpath_dir,title_fig), 'png')
end

%% functions
function barplot_parameters_gramm(par_High,par_Low,par_name,N_tr,phases)
    figure
    n = N_tr;
    phases = length(phases);
    xaxis = repmat([{'DM'};{'PostDM'};{'NewTr'}],n,1);
    xaxis=repmat(xaxis,2,1);
    color_m = [repmat({'High'},n*phases,1);repmat({'Low'},n*phases,1)];
    par_High_resh = reshape(par_High,size(par_High,1)*size(par_High,2),1);
    par_Low_resh = reshape(par_Low,size(par_Low,1)*size(par_Low,2),1);
    yaxis = [par_High_resh;par_Low_resh];
    % gramm
    g = gramm('x',xaxis,'y',yaxis,'color',color_m);
    g.stat_summary('geom',{'bar','black_errorbar'},'type','sem','width',0.6);
    g.set_title(par_name,'FontSize',10)
    g.axe_property('YLim',[-0.5 1]);
    g.set_order_options('x',0,'color',0);
    g.set_text_options('font','Times New Roman','base_size',10,'legend_title_scaling',1.0,'label_scaling',1.1,'legend_scaling',1.0);
    g.set_color_options('map',[0.6705882352941176,0.8156862745098039,0.9019607843137255; 0.21568627450980393, 0.5294117647058824, 0.7529411764705882]);
    g.set_names('x','Phases','y','Power','color','Walking condition');
    % set(gcf, 'Position', get(0, 'Screensize'));
    g.draw()
end

function boxplot_parameters_gramm(par_High,par_Low,par_name,N_tr,phases)
    figure
    n = N_tr;
    phases = length(phases);
    xaxis = repmat([{'DM'};{'PostDM'};{'NewTr'}],n,1);
    xaxis=repmat(xaxis,2,1);
    color_m = [repmat({'High'},n*phases,1);repmat({'Low'},n*phases,1)];
    par_High_resh = reshape(par_High,size(par_High,1)*size(par_High,2),1);
    par_Low_resh = reshape(par_Low,size(par_Low,1)*size(par_Low,2),1);
    yaxis = [par_High_resh;par_Low_resh];
    % gramm
    g = gramm('x',xaxis,'y',yaxis,'color',color_m);
    g.stat_boxplot('width', 0.6, 'dodge',1);
    g.set_title(par_name, 'FontSize', 14);
    g.axe_property('YLim', [-2 5]);
    g.set_order_options('x', 0, 'color', 0);
    g.set_text_options('font', 'Times New Roman', 'base_size', 12, 'legend_title_scaling', 1.0, 'label_scaling', 1.1, 'legend_scaling', 1.0);
    g.set_color_options('map', [0.6706, 0.8157, 0.9020; 0.2157, 0.5294, 0.7529]);
    g.set_names('x', 'Phases', 'y', 'Power', 'color', 'Effort');
    % set(gcf, 'Position', get(0, 'Screensize'));
    g.draw()
end
% Last Edit: Valeria de Seta 29/11/2024