function [all_mats] = F_ListMatfiles(path)
% F_LISTMATFILES List all mat files in folders and subfolders
% Requires F_LocalContent

%% Function
% Saving found mat files and unexplored folders
all_mats = [];
unexp_folders = [];

% Identifying contents of the mother path
[files, mats] = F_LocalContent(path);

% Saving
all_mats = cat(1, all_mats, mats);
unexp_folders = cat(1, unexp_folders, files);

while isempty(unexp_folders) == false

    % Extracting content
    [files, mats] = F_LocalContent(unexp_folders(1));

    % Saving
    all_mats = cat(1, all_mats, mats);
    unexp_folders = cat(1, unexp_folders, files);
    
    % Deleting the already explored file
    unexp_folders(1) = [];
end


end

