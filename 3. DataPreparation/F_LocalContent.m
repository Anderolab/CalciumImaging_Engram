function[folders, mat_files] = F_LocalContent(mother_path)
% F_LocalContent(path)
% This function will return the paths for all folders and .m files within
% a given path.

%% Function
% Extracting the content of the mother path
files = dir(mother_path);

% Empty dataframes to save the content
folders = [];
mat_files = [];

% Looping through each file
for i = 1:size(files, 1)
    
    % Checking if a folder
    if contains(files(i).name, ".") == false

        % Saving folder path
        folders = [folders;...
            strcat(mother_path, "/", files(i).name)];

    % ... or a matlab file
    elseif contains(files(i).name, ".m") | contains(files(i).name, ".xls") == true
        
        if ~contains(files(i).name, "._m")
            
            % Saving mat file paths
            mat_files = [mat_files;...
                strcat(mother_path,"/",files(i).name)];
        end
        
    
end
end
