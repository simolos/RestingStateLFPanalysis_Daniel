function path = define_general_path(Flag_operator, Flag_lab_pc, SubjId, SubjCat)

    if strcmp(Flag_operator, 'Simona')
        if Flag_lab_pc == 1 % Simona's LAB computer

            % restoredefaultpath
            % addpath \\sv-nas1.rcp.epfl.ch\hummel-lab\PhD\Simona\invasiveDBS_SL_2023\apatTIS_iDBS\apatTIS_iDBS_OCD_2024\Data_Analysis\Toolboxes&Functions\fieldtrip-20250318
            % ft_defaults

            % Define path for scripts/functions/pipeline
            addpath(genpath('\\sv-nas1.rcp.epfl.ch\Hummel-Lab\PhD\Simona\invasiveDBS_SL_2023\apatTIS_iDBS\apatTIS_iDBS_OCD_2024\Data_Analysis\Toolboxes&Functions\functions'))
            % addpath(genpath('\\sv-nas1.rcp.epfl.ch\Hummel-Lab\PhD\Simona\invasiveDBS_SL_2023\apatTIS_iDBS\apatTIS_iDBS_OCD_2024\Data_Analysis\Toolboxes&Functions\chronux_2_10'))
            % addpath(genpath('\\sv-nas1.rcp.epfl.ch\Hummel-Lab\PhD\Simona\invasiveDBS_SL_2023\apatTIS_iDBS\apatTIS_iDBS_OCD_2024\Data_Analysis\Commented_Script\New Pipeline EBDM-DBS'))

            if strcmp(SubjId, 'S2_') && strcmp(SubjCat, 'OCD')
                addpath(genpath('\\sv-nas1.rcp.epfl.ch\Hummel-Data\TI\iDBS\apatTIS_iDBS\apatTIS_iDBS_OCD_2024\OCD2'))
                path = '\\sv-nas1.rcp.epfl.ch\Hummel-Data\TI\iDBS\apatTIS_iDBS\apatTIS_iDBS_OCD_2024\OCD2';
            elseif strcmp(SubjId, 'S1_') && strcmp(SubjCat, 'OCD')
                addpath(genpath('\\sv-nas1.rcp.epfl.ch\Hummel-Data\TI\iDBS\apatTIS_iDBS\apatTIS_iDBS_OCD_2024\OCD1'))
                path = '\\sv-nas1.rcp.epfl.ch\Hummel-Data\TI\iDBS\apatTIS_iDBS\apatTIS_iDBS_OCD_2024\OCD1';
            elseif strcmp(SubjId, 'S2_') && strcmp(SubjCat, 'PD')
                addpath(genpath('\\sv-nas1.rcp.epfl.ch\Hummel-Data\TI\iDBS\apatTIS_iDBS\apatTIS_iDBS_PD_2024\20250114_PD2'))
                path = '\\sv-nas1.rcp.epfl.ch\Hummel-Data\TI\iDBS\apatTIS_iDBS\apatTIS_iDBS_PD_2024\20250114_PD2';
            elseif strcmp(SubjId, 'S3_') && strcmp(SubjCat, 'PD')
                addpath(genpath('\\sv-nas1.rcp.epfl.ch\Hummel-Data\TI\iDBS\apatTIS_iDBS\apatTIS_iDBS_PD_2024\20250128_PD3'))
                path = '\\sv-nas1.rcp.epfl.ch\Hummel-Data\TI\iDBS\apatTIS_iDBS\apatTIS_iDBS_PD_2024\20250128_PD3';   
            elseif strcmp(SubjId, 'S1_') && strcmp(SubjCat, 'PD_TI')
                addpath(genpath('\\sv-nas1.rcp.epfl.ch\Hummel-Data\TI\iDBS\apatTIS_iDBS\apatTIS_iDBS_PD_2024\20250319_PD_TI1'))
                path = '\\sv-nas1.rcp.epfl.ch\Hummel-Data\TI\iDBS\apatTIS_iDBS\apatTIS_iDBS_PD_2024\20250319_PD_TI1';   
            end
        else % Simona's MAC

            % restoredefaultpath
            % addpath /Volumes/Hummel-Lab/PhD/Simona/invasiveDBS_SL_2023/apatTIS_iDBS/apatTIS_iDBS_OCD_2024/Data_Analysis/Toolboxes&Functions/fieldtrip-20250318
            % ft_defaults

            % Define path for scripts/functions/pipeline
            addpath(genpath('/Volumes/Hummel-Lab/PhD/Simona/invasiveDBS_SL_2023/apatTIS_iDBS/apatTIS_iDBS_OCD_2024/Data_Analysis/Toolboxes&Functions/functions'))
            addpath(genpath('/Volumes/Hummel-Lab/PhD/Simona/invasiveDBS_SL_2023/apatTIS_iDBS/apatTIS_iDBS_OCD_2024/Data_Analysis/Toolboxes&Functions/chronux_2_10'))
            % addpath(genpath('/Volumes/Hummel-Lab/PhD/Simona/invasiveDBS_SL_2023/apatTIS_iDBS/apatTIS_iDBS_OCD_2024/Data_Analysis/Commented_Script/New Pipeline EBDM-DBS'))

            if strcmp(SubjId, 'S2_') && strcmp(SubjCat, 'OCD')
                addpath(genpath('/Volumes/Hummel-Data/TI/iDBS/apatTIS_iDBS/apatTIS_iDBS_OCD_2024/OCD2'))
                path = '/Volumes/Hummel-Data/TI/iDBS/apatTIS_iDBS/apatTIS_iDBS_OCD_2024/OCD2';
            elseif strcmp(SubjId, 'S1_') && strcmp(SubjCat, 'OCD')
                addpath(genpath('/Volumes/Hummel-Data/TI/iDBS/apatTIS_iDBS/apatTIS_iDBS_OCD_2024/OCD1'))
                path = '/Volumes/Hummel-Data/TI/iDBS/apatTIS_iDBS/apatTIS_iDBS_OCD_2024/OCD1';
            elseif strcmp(SubjId, 'S2_') && strcmp(SubjCat, 'PD')
                addpath(genpath('/Volumes/Hummel-Data/TI/iDBS/apatTIS_iDBS/apatTIS_iDBS_PD_2024/20250114_PD2'))
                path = '/Volumes/Hummel-Data/TI/iDBS/apatTIS_iDBS/apatTIS_iDBS_PD_2024/20250114_PD2';
            elseif strcmp(SubjId, 'S3_') && strcmp(SubjCat, 'PD')
                addpath(genpath('/Volumes/Hummel-Data/TI/iDBS/apatTIS_iDBS/apatTIS_iDBS_PD_2024/20250128_PD3'))
                path = '/Volumes/Hummel-Data/TI/iDBS/apatTIS_iDBS/apatTIS_iDBS_PD_2024/20250128_PD3';   
            elseif strcmp(SubjId, 'S1_') && strcmp(SubjCat, 'PD_TI')
                addpath(genpath('/Volumes/Hummel-Data/TI/iDBS/apatTIS_iDBS/apatTIS_iDBS_PD_2024/20250319_PD_TI1'))
                path = '/Volumes/Hummel-Data/TI/iDBS/apatTIS_iDBS/apatTIS_iDBS_PD_2024/20250319_PD_TI1'; 
            end
        end
    
    elseif strcmp(Flag_operator, 'Valeria')
    
    elseif strcmp(Flag_operator, 'Daniel')
        if Flag_lab_pc == 0 % Daniel's Mac

            % restoredefaultpath
            % addpath /Volumes/Hummel-Lab/Students_Interns/Daniel/apatTIS_iDBS_PD_2024/Toolboxes&Functions/fieldtrip-20250318
            % ft_defaults

            % Define path for scripts/functions/pipeline
            addpath(genpath('/Volumes/Hummel-Lab/Students_Interns/Daniel/apatTIS_iDBS_PD_2024/Toolboxes&Functions/functions'))
            addpath(genpath('/Volumes/Hummel-Lab/Students_Interns/Daniel/apatTIS_iDBS_PD_2024/Toolboxes&Functions/chronux_2_10'))


            if strcmp(SubjId, 'S1_') && strcmp(SubjCat, 'PD_TI')
                addpath(genpath('/Volumes/Hummel-Lab/Students_Interns/Daniel/apatTIS_iDBS_PD_2024/20250319_PD_TI1'))
                path = '/Volumes/Hummel-Lab/Students_Interns/Daniel/apatTIS_iDBS_PD_2024/20250319_PD_TI1'; 
            end
        end
    
        
    
    
    
    else
        error('Specify operator as Simona, Valeria or Daniel')
    end

end