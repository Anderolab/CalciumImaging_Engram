function GUI_SetAnimals

%% EMPTY DATASETS
AnimalConfig = [];
NumAnimals = [];
NumGroups = [];
Groups = [];
cath_counter = [];
an_counter = [];
in_gr_n = [];
in_an_gr = [];
N_Gr_Caths = [];
an_grs = [];
tog = [];
Caths = [];
grp_per_cath = [];
name_grs = [];
G_Counter = [];
gr_csum = [];
grn = [];
Group_prompts = {};
%% MAIN WINDOW
% Creating the main window
in_animals = figure('Visible','on','Position',[500,240,200,500], ...
    'Color', 'w');
movegui(in_animals,'center')


% BTN - Start and select number of animals
start_bt = uicontrol("Parent", in_animals, "Style", "pushbutton", ...
    "String", "Start", "Position", [10, 10, 50, 20], ...
    "Callback", @select_anim_num);

% BTN - Cancel
uicontrol("Parent", in_animals, "Style", "pushbutton", "String", ...
    "Cancel", "Position", [70, 10, 50, 20], "Callback", @close_animal_sel);

    %% MAIN WINDOW FUNCTIONS
    
    % Selecting number of animals
    function select_anim_num(~, ~)

        % TXT - Asking for number of animals
        uicontrol("Parent", in_animals, "Style", 'text', 'String',...
            "Number of animals in study", "Position", ...
            [10, 470, 180, 20], "BackgroundColor", 'w');

        % EDIT - Asking for number of animals
        uicontrol("Parent", in_animals, "Style", 'edit',...
            "Position", [10, 450, 180, 20], "Callback", @save_an_count);

        start_bt.Visible = 'off';

    end
    
    % Close the animal selection window
    function close_animal_sel(~, ~)

        in_animals.Visible = 'off';
        closereq();
    end

    % Saving the animal count and generaring the frame
    function save_an_count(src, ~)

        % Saving the animal count
        NumAnimals = str2double(src.String);

        % Creating the text version
        uicontrol("Parent", in_animals, "Style", 'text',...
            "Position", [10, 450, 180, 20], "String", ...
            strcat(num2str(NumAnimals), " animals in this experiment"), ...
            "BackgroundColor", 'w');
        
        % Loading ask for number of criteria
        % TXT - Asking for number of criteria
        uicontrol("Parent", in_animals, "Style", 'text', 'String',...
            "Number of grouping criteria", "Position", ...
            [10, 420, 180, 20], "BackgroundColor", 'w');

        % EDIT - Asking for number of groups
        uicontrol("Parent", in_animals, "Style", 'edit',...
            "Position", [10, 400, 180, 20], "Callback", @save_grouping_cath_n);        

    end
    
    function save_grouping_cath_n(src, ~)
        N_Gr_Caths = str2double(src.String);
        Caths = repmat("", 1, N_Gr_Caths);

        % BTN - Set group names
        uicontrol("Parent", in_animals, "Style", 'pushbutton',...
            "Position", [10, 380, 180, 20], "String",...
            "Set criteria", "Callback", @set_caths);

        % TEXT - Reminding user of previously selected input
        uicontrol("Parent", in_animals, "Style", 'text',...
            "Position", [10, 400, 180, 20], "String", ...
            strcat(num2str(N_Gr_Caths), " criteria in this experiment"), ...
            "BackgroundColor", 'w');
    end
    
    % Initiating the labelling of cathegories
    function set_caths(~, ~)
        in_gr_n = dialog('Visible','on','Position', ...
            [500,500, 100*N_Gr_Caths, 100], 'Color', 'w');
        movegui(in_gr_n,'center')

        % Setting a counter
        cath_counter = 1;
        
        % Creating group labels
        % TXT - Asking for criteria name
        uicontrol("Parent", in_gr_n, "Style", 'text', 'String', ...
            strcat("Name crit. ", num2str(cath_counter)), ...
            "Position", ...
            [10 + (cath_counter-1)*100, 70, 80, 20], "BackgroundColor", 'w');

        % EDIT - Asking for number of animals
        uicontrol("Parent", in_gr_n, "Style", 'edit', "Position", ...
            [10 + (cath_counter-1)*100, 50, 80, 20], "Callback", ...
            @save_cath_name);
        
        % BTN - Creating a cancel button
        uicontrol("Parent", in_gr_n, "Style", "pushbutton", "String", ...
            "Cancel", "Position", [(100*N_Gr_Caths)-50, 10, 40, 20], ...
            "Callback", @close_gr_set)

    end

    % Continuing and saving labelling of cathegories
    function save_cath_name(src, ~)
        Groups{1, cath_counter} = convertStringsToChars(src.String);

        % TEXT - Reminding previous input
        uicontrol("Parent", in_gr_n, "Style", 'text', "Position", ...
            [10 + (cath_counter-1)*100, 50, 80, 20], "String", ...
            Groups{1, cath_counter}, "BackgroundColor", 'w');

        if cath_counter == N_Gr_Caths
            % BTN - Creating save button
            uicontrol("Parent", in_gr_n, "Style", "pushbutton", ...
                "String", "Next", "Position", ...
                [(100*N_Gr_Caths)/2-20, 10, 40, 20], "Callback", ...
                @finish_cath_naming)
        else
            cath_counter = cath_counter + 1;

            % TXT - Asking for number of animals
            uicontrol("Parent", in_gr_n, "Style", 'text', 'String',...
                strcat("Name crit. ", num2str(cath_counter)), "Position",...
                [10 + (cath_counter-1)*100, 70, 80, 20], ...
                "BackgroundColor", 'w');
            
            % EDIT - Asking for number of animals
            uicontrol("Parent", in_gr_n, "Style", 'edit', "Position",...
                [10 + (cath_counter-1)*100, 50, 80, 20], "Callback",...
                @save_cath_name);
        end
    end
    
    % Saving criterion groups and getting number of groups per criterion
    function finish_cath_naming(~, ~)
        in_gr_n.Visible = 'off';
        
        grp_per_cath = dialog('Visible','on','Position', ...
            [500,500, 100*N_Gr_Caths, 100], 'Color', 'w');
        movegui(grp_per_cath,'center')


        % Setting a counter
        cath_counter = 1;
        
        % Creating group labels
        % TXT - Asking for groups in criteria
        uicontrol("Parent", grp_per_cath, "Style", 'text', 'String', ...
            strcat("Nº groups in ", Groups{1, cath_counter}), ...
            "Position", ...
            [10 + (cath_counter-1)*100, 60, 80, 30], ...
            "BackgroundColor", 'w');

        % EDIT - Asking for number of animals
        uicontrol("Parent", grp_per_cath, "Style", 'edit', "Position", ...
            [10 + (cath_counter-1)*100, 40, 80, 20], "Callback", ...
            @save_gr_in_cath);

    end
    
    % Continuing on setting the number of animals per cathegory
    function save_gr_in_cath(src, ~)
        
        % Saving the number of groups in this cathegory
        Groups{2, cath_counter} = str2double(src.String);

        % TEXT - Setting the output
        uicontrol("Parent", grp_per_cath, "Style", 'text', "Position", ...
            [10 + (cath_counter-1)*100, 40, 80, 20], "String", ...
            num2str(Groups{2, cath_counter}), "BackgroundColor", 'w');
        
        % If we've already set all the cathegories...
        if cath_counter == N_Gr_Caths
            % BTN - Creating save button
            uicontrol("Parent", grp_per_cath, "Style", "pushbutton", ...
                "String", "Next", "Position", ...
                [(100*N_Gr_Caths)/2-20, 10, 40, 20], "Callback", ...
                @finish_cath_ngrups)
        else
            cath_counter = cath_counter + 1;

            % TXT - Asking for number of animals
            uicontrol("Parent", grp_per_cath, "Style", 'text', 'String',...
                strcat("Nº groups in ", Groups{1, cath_counter}), "Position",...
                [10 + (cath_counter-1)*100, 60, 80, 30], ...
                "BackgroundColor", 'w');
            
            % EDIT - Asking for number of animals
            uicontrol("Parent", grp_per_cath, "Style", 'edit', "Position",...
                [10 + (cath_counter-1)*100, 40, 80, 20], "Callback",...
                @save_gr_in_cath);
        end
        
        
    end
    
    % Now naming individual groups in cathegories
    function finish_cath_ngrups(~, ~)
        % Closing the previous window
        grp_per_cath.Visible = 'off';
        
        % Creating also a counter to populate names
        G_Counter = 1;

        % Determining number of total groups
        grn = sum(cell2mat({Groups{2, :}}));
        gr_csum = cumsum(cell2mat({Groups{2, :}}));

        % Creating new window to visualise the groups
        name_grs = dialog('Visible','on','Position', ...
            [500, 300, 300, 40*grn+30], 'Color', 'w');
        movegui(name_grs,'center')

        
        % Creating an empty array to store strings
        Group_prompts = {};

        % And counter to save outs
        c_ = 1;
        
        % Creating list of prompts
        for i = 1:size(Groups, 2)
            for j = 1:Groups{2, i}
                
                % Generating and saving the prompt
                Group_prompts{c_} = strcat("Name ", Groups{1, i}, ...
                    " group ", num2str(j));

                % Updating the counter
                c_ = c_ + 1;
            end

            % Greating empty array to save future individual groups
            Groups{3, i} = [];
        end
        
        % TEXT - Presenting the first prompt
        uicontrol("Parent", name_grs, "Style", "text", "string", ...
            Group_prompts{G_Counter}, "Position", ...
            [10, (grn-G_Counter+1)*40, 150, 20], "BackgroundColor", 'w')

        % INPUT - Saving the group 1
        uicontrol("Parent", name_grs, "Style", "edit", ...
            "Position", [170, (grn - G_Counter+1)*40, 100, 20], ...
            "Callback", @SaveGrName)
        

    end

    % Saving the group name
    function SaveGrName(src, ~)

        % Identifying the cathegory we are in
        diff = gr_csum - G_Counter;
        curr_cath = find(diff >= 0, 1);

        % TEXT - Replacing the edit
        uicontrol("Parent", name_grs, "Style", "text", ...
            "Position", [170, (grn - G_Counter+1)*40, 100, 20], ...
            "String", convertCharsToStrings(src.String), ...
            "BackgroundColor", 'w')

        % Saving the string
        Groups{3, curr_cath} = [Groups{3, curr_cath}, ...
            convertCharsToStrings(src.String)];
        
        % Ending if the counter reaches the maximum
        if G_Counter == grn
            uicontrol("Parent", name_grs, "Style", "pushbutton", ...
                "String", "Continue", "Callback", @CloseGroupNaming, ...
                "Position", [(300-70)/2, 10, 70, 20])
        else



            % Updating the G_Counter
            G_Counter = G_Counter + 1;

            % Launching the new prompt
            % TEXT - Presenting the first prompt
            uicontrol("Parent", name_grs, "Style", "text", "string", ...
                Group_prompts{G_Counter}, "Position", ...
                [10, (grn-G_Counter+1)*40, 150, 20], "BackgroundColor", 'w')

            % INPUT - Saving the group 1
            uicontrol("Parent", name_grs, "Style", "edit", ...
                "Position", [170, (grn - G_Counter+1)*40, 100, 20], ...
                "Callback", @SaveGrName)


        end
        
    end
    
    % Close the pop-up window which saves the group names
    function CloseGroupNaming(~, ~)

        % Closing the window
        name_grs.Visible = 'off';
        
        
        % Creating a new window to label each animal  in each cathegory
        uicontrol("Parent", in_animals, "Position", [10, 310, 180, 20], ...
            "Style", "pushbutton", "String", "Group animals", ...
            "Callback", @select_animals);
    end
    
    % Selecting the animals
    function select_animals(~, ~)
        
        % Creating the visibility window
        in_an_gr = dialog('Visible','on','Position', ...
            [500,500-30*NumAnimals + 30, 110*(N_Gr_Caths+1), ...
            30*NumAnimals + 30], 'Color', 'w');
        movegui(in_an_gr,'center')


        % Creating an empty array to save the input
        an_grs = repmat("", NumAnimals, N_Gr_Caths);

        % Generating an animal and cathegory counter
        an_counter = 1;
        cath_counter = 1;

        uicontrol("Parent", in_an_gr, "Style", 'text', 'string',...
            "Animal "+num2str(an_counter), 'Position', ...
            [10, 30*(NumAnimals+1-an_counter) + 30 - 32.5, 80, 20], ...
            "BackgroundColor", 'w')
        
        % TOG - Creating the toggle to select the animal type
        tog = uicontrol("Parent", in_an_gr, "Style", "popupmenu",...
            "Position", [100*cath_counter, ...
            30*(NumAnimals+1-an_counter) + 30 - 30, 80, 20], ...
            "Callback", @select_animal, "String", Groups{3, cath_counter});
    end
    
    % Close group setting window
    function close_gr_set(~, ~)
        Groups = repmat("", 1, NumGroups);
        in_gr_n.Visible = 'off';
    end

    % Function that selects the animal
    function select_animal(~, ~)

        % Saving the result
        an_grs(an_counter, cath_counter) = ...
            Groups{3, cath_counter}(tog.Value);

        % TXT - Previous result
        uicontrol("Parent", in_an_gr, "Style", "text", ...
            "Position", tog.Position, ...
            "String", an_grs(an_counter, cath_counter), ...
            "BackgroundColor", 'w')

        % If the counter is the number of animals...
        if (an_counter == NumAnimals) && (cath_counter == N_Gr_Caths)
        
            % Creating the save button
            tog.Visible = 'off';

            % Creating the save button
            uicontrol("Parent", in_an_gr, "Style", "pushbutton", ...
                "String", "Save", "Position", [125, 10, 50, 20], ...
                "Callback", @save_an_list)

        else
            
            if cath_counter ~= N_Gr_Caths
                
                % Changing the position of the toggle
                tog.Position = tog.Position - [-105, 0, 0 , 0];

                cath_counter = cath_counter + 1;
                
                tog.String = Groups{3, cath_counter};
            else
                % Updating the counters
                an_counter = an_counter + 1;
                cath_counter = 1;

                % Changing the position of the toggle
                tog.Position = [100, 30*(NumAnimals+1-an_counter), 80, 20];

                % Changing the toggle content
                tog.String = Groups{3, cath_counter};
            end

            % TXT - Current animal
            uicontrol("Parent", in_an_gr, "Style", 'text', 'string',...
                "Animal "+num2str(an_counter), 'Position', ...
                [10, 30*(NumAnimals+1-an_counter) + 30 - 32.5, 80, 20], ...
                "BackgroundColor", 'w')


        end
    end
    
    % Save the animal
    function save_an_list(~, ~)
        
        % Closing the window
        in_an_gr.Visible = 'off';

        % Generating the save button
        uicontrol("Parent", in_animals, "Position", [10, 260, 180, 20], ...
            "Style", "pushbutton", "String", "Save animal config", ...
            "Callback", @save_animal_report);


    end 

    % Asking for the colours
    %function ask_colours
    
    % Save the results
    function save_animal_report(~, ~)
        
        savename = [];
        save_path = [];
        % Generating the save window
        savew = dialog("Visible", 'on', "Position", ...
            [300, 300, 500, 100], 'Color', 'w');
        movegui(savew,'center')
        
        % Asking user to select name   
            % TEXT - Prompts
        uicontrol('Parent', savew, 'Style', 'text', 'String', ...
            "Animal Config Savename (no spaces)", 'Position', ...
            [10, 80, 200, 20], 'BackgroundColor', 'w')
        uicontrol('Parent', savew, 'Style', 'text', 'String', ...
            ".mat", 'Position', [500-40, 80, 30, 20], ...
            'BackgroundColor', 'w')
            % EDIT - Input
        uicontrol('Parent', savew, 'Style', 'edit', 'Position', ...
            [220, 80, 230, 20], 'Callback', @ask_path_btn)
        
        % Asking for the path
        function ask_path_btn(src, ~)

            % Save savename
            savename = src.String;

            % Replacing the saved value
            uicontrol('Parent', savew, 'Style', 'text', 'Position', ...
                [220, 80, 230, 20], 'String', savename, ...
                'BackgroundColor', 'w')

            % Adding the path input button
            uicontrol('Parent', savew, 'Style', 'pushbutton', ...
                'Position', [10, 50, 200, 20], 'String', ...
                'Select the config destination', 'Callback', @ask_path)

        end

        % Ask for the path
        function ask_path(~, ~)
            save_path = uigetdir([], ...
                "Select the location where you wish to save the config file");

            % Updating the user of successful selection
            uicontrol('Parent', savew, 'Style', 'text', 'Position', ...
                [220, 50, 260, 20], 'String', save_path, ...
                'BackgroundColor', 'w')

            uicontrol('Parent', savew, 'Style', 'text', ...
                'Position', [10, 50, 200, 20], 'String', ...
                'Destination:', 'BackgroundColor', 'w')

            % Final save button
            h = uicontrol('Parent', savew, 'Style', 'pushbutton', ...
                'Position', [10, 30, 480, 20], 'String', ...
                'SAVE!', 'BackgroundColor', 'black', 'Callback', ...
                @finish_and_save);
            set(h,'ForegroundColor','w');
        end
%         
        % Finish
        function finish_and_save(~, ~)

            % Generating the output
            AnimalConfig.Animals = NumAnimals;
            AnimalConfig.GroupingCat = N_Gr_Caths;
            AnimalConfig.CritName = Groups(1, :);
            AnimalConfig.Animals = 1:NumAnimals;
            AnimalConfig.AnimalGroups = an_grs;
        
            % Saving the output
            save(strcat(save_path, '\', savename, '.mat'), "AnimalConfig")

            savew.Visible = 'off';
            in_animals.Visible = 'off';

            fprintf('%s', 'Saving complete')
        end
    end

end