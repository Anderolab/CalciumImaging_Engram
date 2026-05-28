% Leer el archivo de timestamps
[filename, pathname] = uigetfile('*.csv', 'Select the timestamp file');
fullpath = fullfile(pathname, filename);
timestampTable = readtable(fullpath);

% Ajustar el primer timestamp a 0 (es común que el primer valor esté desalineado)
timestampTable.TimeStamp_ms_(1) = 0; 

% Extraer los datos de la tabla
frame_numbers = timestampTable.FrameNumber;
time_stamps_ms = timestampTable.TimeStamp_ms_;  % Timestamps en milisegundos

% Prompt the user to input durations
disp('Enter the durations (in seconds):');
durations(1) = input('Hab: ');     % Hab duration
durations(2) = input('Tone: ');    % Tone 1 duration 
durations(3) = input('ITI: ');     % ITI 1 duration

% Display the results
fprintf('Durations saved as:\n');
fprintf('  durations = [%.2f, %.2f, %.2f];\n', ...
    durations(1), durations(2), durations(3));

%% Inicializar las celdas para almacenar los resultados
task_titles = {};  % Nombres de los periodos (Hab, Tone 1, Shock 1, ITI 1, etc.)
task_durations = {};  % Duraciones de cada periodo en segundos
task_frames = {};  % Duraciones de cada periodo en frames
task_start = [];  % Frame de inicio de cada periodo
task_end = [];  % Frame de fin de cada periodo

% Variables de tiempo para la división de los intervalos
current_start_time = 0;  % Tiempo de inicio del primer periodo (Hab)
frame_idx = 1;  % Primer frame
total_frames = numel(time_stamps_ms);  % Total de frames

%% Crear los intervalos de tiempo para Hab, Tone, Shock, ITI
% Empezamos con "Hab" (15 tones)
intervals = {'Hab'};
for i = 1:15
    % Tone
    intervals{end+1} = sprintf('Tone %d', i);
    % ITI
    intervals{end+1} = sprintf('ITI %d', i);
end

%% Dividir el tiempo en los diferentes intervalos
for i = 1 %1:numel(intervals)
    % Asignar el título
    task_titles{end+1} = intervals{i};
    
    % Obtener la duración en segundos de este periodo
    if mod(i, 3) == 1  % "Hab"
        duration_sec = durations(1);
    elseif mod(i, 3) == 2  % "Tone"
        duration_sec = durations(2);
    else  % "ITI"
        duration_sec = durations(3);
    end
    
    % Guardar la duración en segundos
    task_durations{end+1} = duration_sec;
    
    % Convertir la duración a milisegundos
    end_time_ms = current_start_time + duration_sec * 1000;  % Calculamos el tiempo de fin en milisegundos
    
    % Buscar el frame correspondiente al tiempo de inicio y de fin
    [~, start_frame_idx] = min(abs(time_stamps_ms - current_start_time));  % El frame más cercano al start_time
    [~, end_frame_idx] = min(abs(time_stamps_ms - end_time_ms));  % El frame más cercano al end_time
    
    % Ajustar el índice del frame para que empiece desde 0
    task_start(end+1) = frame_numbers(start_frame_idx);  % Ajustamos al frame correspondiente en FrameNumber
    task_end(end+1) = frame_numbers(end_frame_idx);  % Ajustamos al frame correspondiente en FrameNumber
    
    % Guardar la duración en frames
    task_frames{end+1} = task_end(end) - task_start(end) + 1;
    
    % Actualizar el tiempo de inicio para el siguiente periodo
    current_start_time = end_time_ms;
end

%% Crear la estructura Task
Task = struct();
Task.Titles = task_titles;
Task.Lengths = task_durations;
Task.Frames = cell2mat(task_frames);  % Convertir la celda de frames a matriz
Task.Start = task_start;
Task.End = task_end;

% Mostrar el resultado
disp('Task structure generated:');
disp(Task);

%% Let the user choose the folder to save the file

% Allow the user to choose the folder and name of the file
[file_name, folder_path] = uiputfile('*.mat', 'Save Task', 'Task.mat');
if isequal(file_name, 0) || isequal(folder_path, 0)
    error('File save operation canceled.');
end

% Generate the full file path and save the variable
full_file_path = fullfile(folder_path, file_name);
save(full_file_path, 'Task');

% Confirm the save
fprintf('The variable Task was saved in: %s\n', full_file_path);

