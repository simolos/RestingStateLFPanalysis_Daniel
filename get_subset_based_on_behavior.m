function [SubsetTables, BehavSubsetTables] = get_subset_based_on_behavior(Table_Data, Table_Behavior, TableBehavCondition)

    % Description: function to create a subset of the behavioral table
    %   
    % Inputs:
    %   - Table_Data: TxP table, T=number of trials in the block under
    %       analysis, P=number of phases of interest. 
    %   - Table_Behavior: TxN table, T=number of trials in the block under
    %       analysis, N=number of phases of interest + 4 (columns for Subj,
    %       Phase, Block and Trial codes)
    %   - TableBehavCondition: 1xN table, T=number of trials in the block under
    %       analysis, N=number of phases of interest + 4 (columns for Subj,
    %       Phase, Block and Trial codes). Each cell is either empty or 
    %       contains:
    %           - a 2xV array, V=number of values belonging to each
    %           category, row1=condition1, row2=condition2.
    %           e.g. TableBehavCondition.Effort = [E1 E2; E3 E4] will split
    %           Table_Data in two, one subtable containing only efforts E1-E2
    %           and the other containing only efforts E3-E4
    %           e.g. TableBehavCondition.Acceptance = [1; 0] will split
    %           Table_Data in two, one subtable containing accepted trials and
    %           the other containing only non accepted trials
    %           - a 1xV, V=number of values belonging to this category.
    %           This condition will be applied to the whole dataset, before
    %           the creation of the categories
    %           e.g. TableBehavCondition.EffortProd = [1] will exclude all
    %           trials that do not satisfy this condition
    %
    % Outputs:
    %   - SubsetTables: 1x2 cell, each one containing the subset table
    %   - BehavSubsetTables: 1x2 cell, each one containing the behavioral 
    %       subset table
    %
    % Created by Simona Losacco on 05/01/2025, updated on 14/02/2025

    % First loop to set general conditions
    for j=1:size(TableBehavCondition, 2)

        if ~isempty(TableBehavCondition{1,j}{:}) % If a condition is specified in the table

            % If there is only one value --> apply to the whole dataset OR handling the case of Block or Phase
            if ischar(TableBehavCondition{1,j}{:}) 

                if contains(TableBehavCondition{1,j}{:}, '&')

                    Table_Data( ~ismember(Table_Behavior{:,j}, strsplit(TableBehavCondition{1,j}{:}, '&') ), : ) = [];
                    Table_Behavior( ~ismember(Table_Behavior{:,j}, strsplit(TableBehavCondition{1,j}{:}, '&') ), : ) = [];
                
                else
                    Table_Data( ~ismember(Table_Behavior{:,j}, TableBehavCondition{1,j}{:}), : ) = [];
                    Table_Behavior( ~ismember(Table_Behavior{:,j}, TableBehavCondition{1,j}{:}), : ) = [];
                end


            end
                
            if length(TableBehavCondition{1,j}{:}) == 1 
                
                Table_Data( ~ismember(Table_Behavior{:,j}, TableBehavCondition{1,j}{:}), : ) = [];
                Table_Behavior( ~ismember(Table_Behavior{:,j}, TableBehavCondition{1,j}{:}), : ) = [];
                
            end
        end
    end

    Flag_no_subset_created = 0;

    % Second loop to create the categories
    for j=1:size(TableBehavCondition, 2)

        if ~isempty(TableBehavCondition{1,j}{:}) % If a condition is specified in the table

            if length(TableBehavCondition{1,j}{:}) ~= 1 && ~ischar(TableBehavCondition{1,j}{:}) % If there is more than one value

                for i = 1:size(TableBehavCondition{1,j}{:}, 1) % loop over the conditions
    
                    Flag_no_subset_created = 1;
                    SubsetTables{i} = Table_Data( ismember(Table_Behavior{:,j}, TableBehavCondition{1,j}{:}(i,:)), : );
                    BehavSubsetTables{i} = Table_Behavior( ismember(Table_Behavior{:,j}, TableBehavCondition{1,j}{:}(i,:)), : );
                end
            end
        end
    end


    if Flag_no_subset_created == 0 % In case only a general condition is used 
        SubsetTables = Table_Data;
        BehavSubsetTables = Table_Behavior;
    end


end