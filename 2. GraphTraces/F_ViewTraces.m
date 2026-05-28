function [OutputTable, Outs] = F_ViewTraces(TableInput, Variable, ...
    GroupVariable, Project, RF, SetZero, x_label, y_label, ...
    output_path, stats_option, FolderName, ViewStatus, StatusLength)

% For a table (TableInput), it plots the value (Variable) grouped by a
% cathegory (GroupVariable, for multiple specify as [a, b]) given the 
% colour parameters specified in a specific project (Project, Experiment). 
% Also takes the sampling frequency (RF, normally 30fps).
% Other arguments
    % SetZero - For visualisation, frame that will be considered t=0
    % x/y_label - Labels for the axes
    % output_path - Where the image will be stored
    % stats_option - true/false - Will call for a repeated measures anova
    % FolderName - CLARIFY
    % ViewStatus - Creates a black window of time where the stimulus is
         % presented starting in the set zero.
    % StatusLength - Specifies the length of such event.
%%
Palette = Project.Project.Palette;

if ViewStatus 
    status_ = zeros(1, size(TableInput.(Variable),2));
    status_(SetZero:(SetZero+StatusLength)) = 1;
end
%% Generating the MATLAB to R signal csv

if isempty(GroupVariable)
    Mean = mean(TableInput.(Variable), 1,'omitnan');
    SDs = std(TableInput.(Variable), 1, 'omitnan');
    Ns = sum(~isnan(sum(TableInput.(Variable), 2)));
    F_FillArea(Mean, SDs./sqrt(Ns), ...
        'k', ([1:length(Mean)]-SetZero)./RF)
    hold on
    plot(([1:length(Mean)]-SetZero)./RF, ...
        Mean, "Color", 'k', 'LineWidth', 1)
    hold off
elseif length(string(GroupVariable)) == 1
    
    % Temporary storage array
    Means = zeros(length(unique(TableInput.(GroupVariable))), ...
        size(TableInput.(Variable), 2)); % Save means
    SDs = Means; % Save STDs
    Ns = zeros(length(unique(TableInput.(GroupVariable))), 1); % Save the n

    c = 1; % Will iterate between conditions

    for g_ix = unique(TableInput.(GroupVariable)).'
    
        % Computing the variables
        Means(c, :) = ... % Group mean for all animals
            mean(TableInput.(Variable)(TableInput.(GroupVariable) ...
            == g_ix, :), 1,'omitnan');
        SDs(c, :) = ... % Group sd for all animals
            std(TableInput.(Variable)(TableInput.(GroupVariable) ...
            == g_ix, :), [], 1, 'omitnan');
        Ns(c) = sum(TableInput.(GroupVariable) == g_ix, "all"); % N for SEM

        % Plotting the error bars
        F_FillArea(Means(c, :), SDs(c, :)./sqrt(Ns(c)), ...
            cell2mat(Palette(g_ix)), ...
 ([1:length(Means(c, :))]-SetZero)./RF)

        % Identifying the asterisk locations
        hold on
        xlabel(x_label)
        ylabel(y_label)
        c = c+1;
    
    end

    % Plotting the means
    c = 1;
    for g_ix = unique(TableInput.(GroupVariable)).'
    
        % Plotting the error bars
        plot(([1:length(Means(c, :))]-SetZero)./RF, ...
             Means(c, :), 'Color', cell2mat(Palette(g_ix)), ...
            'LineWidth', 1)
        hold on
        c = c+1;
    
    end

    % Identifying location for significance bars
    Sig_Loco = max(Means + SDs./sqrt(Ns), [], 1) ... % Masimum location
        + .05*(max(ylim()) - min(ylim())); % Some space for asterisks
    
    if stats_option == true  

        % Generating the output
        OutputTable = table();
        OutputTable.(GroupVariable) = unique(TableInput.(GroupVariable));
        OutputTable.MeanFlu = Means;
        OutputTable.SD = SDs;
        OutputTable.SEM = SDs./sqrt(Ns);
        

        %% Outlier identification
        MeanAUCs = mean(TableInput.(Variable), 2);
        Outs = []
        for grp = unique(TableInput.(GroupVariable)).'
            [~, Bools] = F_GrubbsTest(MeanAUCs(TableInput.(GroupVariable) == grp));
            Outs = [Outs; Bools]
        end

        F_GrubbsTest(MeanAUCs)

        %% STATS
        % Prepping for the statistics
        StatsTable = table();
        StatsTable.Treatment = TableInput.Treatment;
        StatsTable.Animal = TableInput.Animal;
        StatsTable.(Variable) = TableInput.(Variable);
        StatsTable = StatsTable(~Outs, :)
        stats_csv_filename = strcat(output_path, "\FluTable.csv");
        writetable(StatsTable, stats_csv_filename, "Delimiter", ',');
    
        % Make Table of Variables 
        GroupBy = GroupVariable;
        Variable1 = Variable;
        Id = "Animal";
        DatasetPath = stats_csv_filename;
        NewFolderPath = strcat(output_path, FolderName);
        
        %F_MakeCSVForStat_FC(GroupBy, Variable1, Id, DatasetPath, NewFolderPath);
        
        % Run R Script of Analysis
        ScriptPath = strcat('', pwd, '\BoxTestAndANOVA_FC.R');
        F_RunRScript(ScriptPath)

        % %% REGENERATING THE FIGURE
        % % Identifying the outlier section of the stats
        % tbl_ = readtable(strcat(NewFolderPath, "\SummaryStatistics.csv"));
        % included_animals = ...
        %     find(prod(double(string({out_table{:, :, 3}})) ...
        %     ~= StatsTable.Animal, 2) == 1);
        % NoOutliars = TableInput(included_animals, :);
        % 
        % subplot(1, 2, 2)
        %     % Temporary storage array
        % Means = zeros(length(unique(NoOutliars.(GroupVariable))), ...
        %     size(NoOutliars.(Variable), 2)); % Save means
        % SDs = Means; % Save STDs
        % Ns = zeros(length(unique(NoOutliars.(GroupVariable))), 1); % Save the n
        % 
        % c = 1; % Will iterate between conditions
        % 
        % for g_ix = unique(NoOutliars.(GroupVariable)).'
        % 
        %     % Computing the variables
        %     Means(c, :) = ... % Group mean for all animals
        %         nanmean(NoOutliars.(Variable)(NoOutliars.(GroupVariable) ...
        %         == g_ix, :), 1);
        %     SDs(c, :) = ... % Group sd for all animals
        %         nanstd(NoOutliars.(Variable)(NoOutliars.(GroupVariable) ...
        %         == g_ix, :), [], 1);
        %     Ns(c) = sum(NoOutliars.(GroupVariable) == g_ix, "all"); % N for SEM
        % 
        %     % Plotting the error bars
        %     F_FillArea(Means(c, :), SDs(c, :)./sqrt(Ns(c)), ...
        %         cell2mat(Palette(g_ix)), ...
        %         ([1:length(Means(c, :))]-SetZero)./RF)
        % 
        %     % Identifying the asterisk locations
        %     hold on
        %     xlabel(x_label)
        %     ylabel(y_label)
        %     c = c+1;
        % 
        % end
        % 
        % % Plotting the means
        % c = 1;
        % for g_ix = unique(NoOutliars.(GroupVariable)).'
        % 
        %     % Plotting the error bars
        %     plot(([1:length(Means(c, :))]-SetZero)./RF, ...
        %          Means(c, :), 'Color', cell2mat(Palette(g_ix)), ...
        %         'LineWidth', 1)
        %     hold on
        %     c = c+1;
        % 
        % end
        % 
        % % Identifying location for significance bars
        % Sig_Loco = max(Means + SDs./sqrt(Ns), [], 1) ... % Masimum location
        %     + .05*(max(ylim()) - min(ylim())); % Some space for asterisks
        % 
        % 
        % figure(fig_pre_outl)
    end 




    if stats_option
        % Generating the significance position and reshaping the graph
        yl_ = ylim();
        y_len = (yl_(2)-yl_(1));
        my_ = Means + (SDs./sqrt(Ns));
        max_pos_y = .05*y_len+max(my_, [], 1);
        ylim([yl_(1), yl_(1)+y_len*1.1])
        x_ = ([1:length(Means(1, :))]-SetZero)./RF;

        % Prepping for the statistics
        StatsTable = table();
        StatsTable.Treatment = TableInput.Treatment;
        StatsTable.Animal = TableInput.Animal;
        StatsTable.(Variable) = TableInput.(Variable);
        
        % Saving it as a csv for R to read
        stats_csv_filename = strcat(output_path, "\StatsTable.csv");
        writetable(StatsTable, stats_csv_filename);
        
        % Getting the variable names
        s_  =readtable(stats_csv_filename);
        var_names = string(s_.Properties.VariableNames);
        vars_of_interest = var_names(contains(var_names, Variable));
        clear s_ var_names

        % Sample stat path
        stat_res = "C:\Users\1657711\OneDrive - UAB\Escritorio";





        % Generating the statistics
        sign_ = ["", "", "", "", ""];
    
        for i = 1:length(sign_)
            text(x_(i), max_pos_y(i), sign_(i), "FontSize", 15, ...
                "HorizontalAlignment", "center", "VerticalAlignment", ...
                "middle")
        end  
    end

else
    % Temporary output storage
    NumRows = length(unique(TableInput.(GroupVariable(1)))) + ...
        length(unique(TableInput.(GroupVariable(2))));
    Means = zeros(NumRows, size(TableInput.(Variable), 2));
    SDs = Means;
    Ns = zeros(NumRows, 1);
    Labels = unique(TableInput.(GroupVariable(2)), 'stable').';
    Subplot_N = length(Labels);

    % Extracting the bounds
    mean_ = mean(TableInput.(Variable), 'all');
    sd_ = std(TableInput.(Variable), [], 'all');
    upper_bound = mean_ + 1.96*sd_;
    lower_bound = mean_ - 1.96*sd_;

    
    % Looping through each cath
    c = 1;
    for gr_1 = unique(TableInput.(GroupVariable(1))).'
        c_2 = 1;
        for gr_2 = Labels
            
            ix = (TableInput.(GroupVariable(1)) == gr_1) & ...
                (TableInput.(GroupVariable(2)) == gr_2);
            Means(c, :) = mean(TableInput.(Variable)(ix, :), 1,'omitnan');
            SDs(c, :) = std(TableInput.(Variable)(ix, :), [], 1,'omitnan');
            Ns(c) = sum(ix == 1);

            if ViewStatus
                subplot(12, Subplot_N, c_2 + Subplot_N.*[1:11])
            else
                subplot(1, Subplot_N, c_2)
            end
            hold on
            % Plotting the error bars
            F_FillArea(Means(c, :), SDs(c, :)./sqrt(Ns(c)), ...
                cell2mat(Palette(gr_1)), ...
                ([1:length(Means(c, :))]-SetZero)./RF)
            c = c+1;    % Counter update
            c_2 = c_2+1;    % Counter update
        end
    end
    
    % Now plotting the lines
    c = 1;
    lims = zeros(Subplot_N, 2);
    for gr_1 = unique(TableInput.(GroupVariable(1))).'
        c_2 = 1;
        for gr_2 = Labels
            if ViewStatus
                subplot(12,  Subplot_N, c_2)
                area(([1:length(Means(c, :))]-SetZero)./RF, status_, ...
                    "FaceColor", 'k', "FaceAlpha", 1)
                ax_ = gca;
                ax_.YColor = 'w';
                ylim([0, 2])
                box off
                xticks([])
                yticks([])
                subplot(12, Subplot_N, c_2 + Subplot_N.*[1:11])
            else
                subplot(1, Subplot_N, c_2)
            end
            hold on
            % Plotting the error bars
            plot(([1:length(Means(c, :))]-SetZero)./RF, ...
                Means(c, :), 'Color', cell2mat(Palette(gr_1)), ...
                'LineWidth', 1)
            yline(upper_bound, "Color", 'r', "LineStyle", ":", "LineWidth", 2)
            yline(lower_bound, "Color", 'r', "LineStyle", ":", "LineWidth", 2)
            
            % Saving plot ylim
            lims(c_2, :) = ylim();
            c_2 = c_2+1;    % Counter update
            c = c+1;    % Counter update

        end
    end

    % Setting the axes to equal
    for subp_ix = 1:Subplot_N
        
        if ViewStatus
            subplot(12,  Subplot_N, subp_ix)
            title(Labels(subp_ix))
            subplot(12, Subplot_N, subp_ix + Subplot_N.*[1:11])
        else
            subplot(1, Subplot_N, subp_ix)
            title(Labels(subp_ix))
            
        end
        
        ylim([min(lims(:, 1)), max(lims(:, 2))])
        xlabel(x_label)
        ylabel(y_label)
        xline(0, "LineWidth", 1.2, "LineStyle", ":")
    end




end
