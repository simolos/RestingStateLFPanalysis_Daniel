function [behav_data_folder, tag, trig_name, data_folder, behav_data_file_number] = define_run_path(Flag_operator, Flag_lab_pc, SubjId, SubjCat, Run, run_name) 

    if strcmp(Flag_operator, 'Simona')
        
         if Flag_lab_pc == 1
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OCD2
            if strcmp(SubjId,'S2_') && strcmp(SubjCat, 'OCD') && (Run == 5 || Run == 6 || Run == 8 || Run == 9)
                behav_data_folder = 'Behavioral data\OCD2_AM_1';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_OCD2_AM_rec'; % OCD2: 'TriggerDecoding_OCD2_AM_rec' and 'TriggerDecoding_OCD2_PM_rec' || OCD1: 'TriggerDecoding_OCD1_AM1_rec' and 'TriggerDecoding_OCD1_PM2_rec'
                data_folder ='Processed_LFP';
            elseif strcmp(SubjId,'S2_') && strcmp(SubjCat, 'OCD') && (Run == 12 || Run == 13)
                behav_data_folder = 'Behavioral data\OCD2_AM_2';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-ON-norm';
                trig_name = 'TriggerDecoding_OCD2_AM_rec'; 
                data_folder ='Processed_LFP';
            elseif strcmp(SubjId,'S2_') && strcmp(SubjCat, 'OCD') && (Run == 17 || Run == 18)
                behav_data_folder = 'Behavioral data\OCD2_PM_1';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'PM-DBS-ON-norm';
                trig_name = 'TriggerDecoding_OCD2_PM_rec'; 
                data_folder ='Processed_LFP';
            elseif strcmp(SubjId,'S2_') && strcmp(SubjCat, 'OCD') && (Run == 20 || Run == 21 || Run == 22)
                behav_data_folder = 'Behavioral data\OCD2_PM_2';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'PM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_OCD2_PM_rec'; 
                data_folder ='Processed_LFP';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OCD1
            elseif strcmp(SubjId,'S1_') && strcmp(SubjCat, 'OCD') && (Run == 6 || Run == 7)
                behav_data_folder = 'Behavioral data\OCD1_AM_1';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_OCD1_AM1_rec'; % OCD2: 'TriggerDecoding_OCD2_AM_rec' and 'TriggerDecoding_OCD2_PM_rec' || OCD1: 'TriggerDecoding_OCD1_AM1_rec' and 'TriggerDecoding_OCD1_PM2_rec'    
                data_folder ='Processed_Ste\Session1_AM'; % OCD2: Processed_LFP || OCD1: Processed_LFP/Session1_AM and ../Session2_PM
            elseif strcmp(SubjId,'S1_') && strcmp(SubjCat, 'OCD') && (Run == 10 || Run == 11)
                behav_data_folder = 'Behavioral data\OCD1_AM_2';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-ON-norm';
                trig_name = 'TriggerDecoding_OCD1_AM1_rec'; 
                data_folder ='Processed_Ste\Session1_AM'; 
            elseif strcmp(SubjId,'S1_') && strcmp(SubjCat, 'OCD') && (Run == 4 || Run == 5)
                behav_data_folder = 'Behavioral data\OCD1_PM_1';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'PM-DBS-ON-norm';
                trig_name = 'TriggerDecoding_OCD1_PM2_rec'; 
                data_folder ='Processed_Ste\Session2_PM'; 
            elseif strcmp(SubjId,'S1_') && strcmp(SubjCat, 'OCD') && (Run == 81 || Run == 82|| Run == 9)
                behav_data_folder = 'Behavioral data\OCD1_PM_2';
                if Run == 81
                    behav_data_file_number = [SubjId,run_name,'_1_'];  
                elseif Run == 82
                    behav_data_file_number = [SubjId,run_name,'_2_']; 
                elseif Run == 9
                    behav_data_file_number = [SubjId,run_name];
                end
                tag = 'PM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_OCD1_PM2_rec'; 
                data_folder ='Processed_Ste\Session2_PM'; 


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PD
            elseif strcmp(SubjId,'S2_') && strcmp(SubjCat, 'PD') && (Run == 7 || Run == 8 || Run == 9 || Run == 5 || Run == 10)
                behav_data_folder = 'Behavioral data';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_PD146_rec'; 
                data_folder ='Processed_Ste'; 
            elseif strcmp(SubjId,'S3_') && strcmp(SubjCat, 'PD') && (Run == 6 || Run == 7 || Run == 8 || Run == 9 || Run == 10)
                behav_data_folder = 'Behavioral Data';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_PD147_rec';
                data_folder ='Processed';   


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PD_TI
            elseif strcmp(SubjId,'S1_') && strcmp(SubjCat, 'PD_TI') && ismember(Run, [6 7 8 9 10 11 12])
                behav_data_folder = 'Behavioral data';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-180Hz-TI';
                trig_name = 'TriggerDecoding_PD_TI1_rec'; 
                data_folder ='Processed_Ste'; 

                if ismember(Run, [6 9])
                    tag = 'AM-DBS-180Hz-TI_HF'; %HF
                elseif ismember(Run, [7 8])
                    tag = 'AM-DBS-180Hz-TI_iTBS';
                elseif ismember(Run, [11 12])
                    tag = 'AM-DBS-180Hz-TI_cTBS';
                elseif ismember(Run, [10])
                    tag = 'AM-DBS-180Hz_FCRT';
                end


            else
                error('implement Subj1')
            end
    
         else % macbook Simona
            if strcmp(SubjId,'S2_') && strcmp(SubjCat, 'OCD') && (Run == 8 || Run == 9)
                behav_data_folder = 'Behavioral data/OCD2_AM_1';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_OCD2_AM_rec'; % OCD2: 'TriggerDecoding_OCD2_AM_rec' and 'TriggerDecoding_OCD2_PM_rec' || OCD1: 'TriggerDecoding_OCD1_AM1_rec' and 'TriggerDecoding_OCD1_PM2_rec'
                data_folder ='Processed_LFP';
            elseif strcmp(SubjId,'S2_') && strcmp(SubjCat, 'OCD') && (Run == 12 || Run == 13)
                behav_data_folder = 'Behavioral data/OCD2_AM_2';
                behav_data_file_number = [SubjId,run_name];
                tag = 'AM-DBS-ON-norm';
                trig_name = 'TriggerDecoding_OCD2_AM_rec'; 
                data_folder ='Processed_LFP';
            elseif strcmp(SubjId,'S2_') && strcmp(SubjCat, 'OCD') && (Run == 17 || Run == 18)
                behav_data_folder = 'Behavioral data/OCD2_PM_1';
                behav_data_file_number = [SubjId,run_name];
                tag = 'PM-DBS-ON-norm';
                trig_name = 'TriggerDecoding_OCD2_PM_rec'; 
                data_folder ='Processed_LFP';
            elseif strcmp(SubjId,'S2_') && strcmp(SubjCat, 'OCD') && (Run == 21 || Run == 22)
                behav_data_folder = 'Behavioral data/OCD2_PM_2';
                behav_data_file_number = [SubjId,run_name];
                tag = 'PM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_OCD2_PM_rec'; 
                data_folder ='Processed_LFP';
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OCD1
            elseif strcmp(SubjId,'S1_') && strcmp(SubjCat, 'OCD') && (Run == 6 || Run == 7)
                behav_data_folder = 'Behavioral data/OCD1_AM_1';
                behav_data_file_number = [SubjId,run_name];
                tag = 'AM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_OCD1_AM1_rec'; % OCD2: 'TriggerDecoding_OCD2_AM_rec' and 'TriggerDecoding_OCD2_PM_rec' || OCD1: 'TriggerDecoding_OCD1_AM1_rec' and 'TriggerDecoding_OCD1_PM2_rec'    
                data_folder ='Processed_Ste/Session1_AM'; % OCD2: Processed_LFP || OCD1: Processed_LFP/Session1_AM and ../Session2_PM
            elseif strcmp(SubjId,'S1_') && strcmp(SubjCat, 'OCD') && (Run == 10 || Run == 11)
                behav_data_folder = 'Behavioral data/OCD1_AM_2';
                behav_data_file_number = [SubjId,run_name];
                tag = 'AM-DBS-ON-norm';
                trig_name = 'TriggerDecoding_OCD1_AM1_rec'; 
                data_folder ='Processed_Ste/Session1_AM'; 
            elseif strcmp(SubjId,'S1_') && strcmp(SubjCat, 'OCD') && (Run == 4 || Run == 5)
                behav_data_folder = 'Behavioral data/OCD1_PM_1';
                behav_data_file_number = [SubjId,run_name];
                tag = 'PM-DBS-ON-norm';
                trig_name = 'TriggerDecoding_OCD1_PM2_rec'; 
                data_folder ='Processed_Ste/Session2_PM'; 
            elseif strcmp(SubjId,'S1_') && strcmp(SubjCat, 'OCD') && (Run == 81 || Run == 82|| Run == 9)
                behav_data_folder = 'Behavioral data/OCD1_PM_2';
                if Run == 81
                    behav_data_file_number = [SubjId,run_name,'_1_'];  
                elseif Run == 82
                    behav_data_file_number = [SubjId,run_name,'_2_']; 
                elseif Run == 9
                    behav_data_file_number = [SubjId,run_name];
                end
                tag = 'PM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_OCD1_PM2_rec'; 
                data_folder ='Processed_Ste/Session2_PM'; 
                error('implement Subj1')

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PD
            elseif strcmp(SubjId,'S2_') && strcmp(SubjCat, 'PD') && (Run == 7 || Run == 8 || Run == 9 || Run == 5 || Run == 10)
                behav_data_folder = 'Behavioral data';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_PD146_rec'; 
                data_folder ='Processed_Ste'; 
            elseif strcmp(SubjId,'S3_') && strcmp(SubjCat, 'PD') && (Run == 6 || Run == 7 || Run == 8 || Run == 9 || Run == 10)
                behav_data_folder = 'Behavioral Data';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-OFF-norm';
                trig_name = 'TriggerDecoding_PD147_rec';
                data_folder ='Processed'; 

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PD_TI
            elseif strcmp(SubjId,'S1_') && strcmp(SubjCat, 'PD_TI') && ismember(Run, [6 7 8 9 10 11 12])
                behav_data_folder = 'Behavioral data';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-180Hz-TI';
                trig_name = 'TriggerDecoding_PD_TI1_rec'; 
                data_folder ='Processed_Ste'; 

                if ismember(Run, [6 9])
                    tag = 'AM-DBS-180Hz-TI_HF'; %HF
                elseif ismember(Run, [7 8])
                    tag = 'AM-DBS-180Hz-TI_iTBS';
                elseif ismember(Run, [11 12])
                    tag = 'AM-DBS-180Hz-TI_cTBS';
                elseif ismember(Run, [10])
                    tag = 'AM-DBS-180Hz_FCRT';
                end

            end    
         end
    
    elseif strcmp(Flag_operator, 'Valeria')

    elseif strcmp(Flag_operator, 'Daniel')
        if Flag_lab_pc == 0
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PD_TI
            if strcmp(SubjId,'S1_') && strcmp(SubjCat, 'PD_TI') && ismember(Run, [13 14 15 16 17])
                behav_data_folder = 'Behavioral data';
                behav_data_file_number = [SubjId,run_name];            
                tag = 'AM-DBS-180Hz-TI';
                trig_name = 'TriggerDecoding_PD_TI1_rec'; 
                data_folder ='Processed_Ste'; 

                if ismember(Run, 13) 
                    tag = 'AM-DBS-180Hz-TI_iTBS'; %iTBS
                elseif ismember(Run, 14)
                    tag = 'AM-DBS-180Hz-TI_HF'; %HF
                elseif ismember(Run, 15)
                    tag = 'AM-DBS-180Hz-TI_cTBS'; %cTBS
                elseif ismember(Run, 16)
                    tag = 'AM-DBS-180Hz_sham'; %sham
                elseif ismember(Run, 17)
                    tag = 'AM-DBS-180Hz_130'; %130Hz
                end
            end
        end

    else
        error('Specify operator as Simona or Valeria')
    end

end

   