%% LOAD THE REQUIRED DATASETS

% 1 - Adding the project path to the searchpath
[file, output_path] = uigetfile('*.*', 'Select Experiment');

% Verifica si el usuario seleccionó un archivo o canceló
if isequal(file, 0)
    disp('No se seleccionó ningún archivo.');
else
    % Carga el archivo seleccionado como una variable en MATLAB
    full_file_path = fullfile(output_path, file);
    load(full_file_path, 'Experiment'); % Asegúrate de que el archivo contenga una variable 'AnimalConfig'
end

% Adding functions to search path
addpath(genpath(output_path))

% 2 - Creating a new folder for the query
target_path = output_path + "\FluorescenceResults " + ...
    string(datetime(floor(now),'ConvertFrom','datenum'));
mkdir(target_path)

%% Nuevos colores en formato RGB
new_color_CORT = [0.341, 0.341, 0.976];
new_color_VEH = [0.784, 0.871, 0.976];

% Actualizar la paleta de colores en Experiment.Project.Palette
Experiment.Project.Palette("female") = {new_color_CORT};
Experiment.Project.Palette("male") = {new_color_VEH};

% Mostrar la paleta actualizada para verificar los cambios
disp('Paleta de colores actualizada:');
disp(Experiment.Project.Palette);

%% 1 - Global fluorescence changes

% Setting the parameters for the specific query
fields = fieldnames(Experiment)
field = string(fields{1})
Data = Experiment(1).(field);

% Extracting the palette and sexes
GroupBy = string(Experiment.Project.Groups);
Palette = Experiment.Project.Palette;
RF = 30;
PerformStats = false;
close all

% Running the function
[Means,Fluorescence] = F_PopulationFluorescence_Mariana(Data, GroupBy, "Treatment");

exportgraphics(gcf, strcat(target_path, "\Outliers.pdf"),  ...
    'ContentType','vector')

% Pre-allocate para almacenar la media de cada fila
meanFluPerRow_noshift = nan(size(Fluorescence, 1), 1);

% Iterar a través de cada fila para calcular la media, excluyendo NaN
for i = 1:size(Fluorescence, 1)
    % Acceder directamente al vector de 'Flu' para la fila i
    currentFluVector = Fluorescence.Flu(i, :); % Asegúrate de que esto corresponde a cómo están organizados tus datos
    % Calcular la media, excluyendo NaN
    meanFluPerRow_noshift(i) = nanmean(currentFluVector);
end
close all

%% Visualising the traces
F_ViewTraces(Fluorescence, 'Flu', 'Treatment', Experiment, RF, 0, "Time (s)",...
    "(\DeltaF/F_0)-F_{Hab}", output_path, false, [], false,[])
exportgraphics(gcf, strcat(target_path, "\GlobalFluorescence.pdf"),  ...
    'ContentType','image')

%%
RefEpoch = [];
Method = "Pctile 50"; % "Mean", "Pctile n", "None"
Scaling = true;
%%
animalFields = fieldnames(Experiment(1).(field));

% Filtrar para quedarse solo con los campos que comienzan con 'M'
animals = animalFields(startsWith(animalFields, 'M'));
%%
Task=[];
Fluorescence = F_ShiftTrace(Fluorescence, 'Flu', [], Method, Task, ...
      Scaling);