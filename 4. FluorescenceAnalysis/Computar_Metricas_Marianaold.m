%% Loading and fixing the required datasets

[filename, filepath] = uigetfile('*.mat', 'Select a Experiment File to Load');

if isequal(filename, 0)  % If user cancels the file selection
    disp('File selection canceled');
else
    load(fullfile(filepath, filename));  % Directly load the selected file
end

%% Obtén todos los nombres de los animales en Experiment.SI
fields = fieldnames(Experiment);
field = string(fields{1});

animals = fieldnames(Experiment(1).(field));

%% If you want to remove Animals

% animals_to_delete = [4,5,6,7,8,9,10,11,12,13] % Write the animals you want to remove
% Experiment = removeAnimalAndGroup(Experiment, field, animals_to_delete); 

%% 
% newAnimalNames = {'M1','M2','M3'};
% 
% % Obtener los nombres de los campos actuales en Experiment.SI 
% currentAnimalNames = fieldnames(Experiment(1).(field)); 
% 
% % Verificar que la longitud de newAnimalNames sea igual a la de currentAnimalNames 
% if numel(newAnimalNames) ~= numel(currentAnimalNames) 
%     error('El número de nuevos nombres de animales no coincide con el número de animales en Experiment.'); 
% end 
% 
% % Crear una nueva estructura para Experiment.SI con los nuevos nombres 
% newExperimentSI = struct();
% 
% % Renombrar los campos 
% for i = 1:numel(currentAnimalNames) 
%     currentName = currentAnimalNames{i}; 
%     newName = newAnimalNames{i}; 
%     newExperimentSI.(newName) = Experiment(1).(field).(currentName); 
% end
% 
% % Asignar la nueva estructura a Experiment.SI 
% Experiment(1).(field) = newExperimentSI;

%% Mostrar los nuevos nombres de los campos en Experiment.SI 
disp(fieldnames(Experiment(1).(field))); 

% Inicializar una tabla para los resultados de todos los animales 
allResults = table();

% Lista de nombres de animales 
animalNames = fieldnames(Experiment(1).(field));

% Inicializar una estructura para almacenar las matrices 3D binarias y los eventos compuestos 
allBinaryMatrices = struct(); 
allCompositeEvents = struct();

% Verificar el número de animales 
numAnimals = numel(animalNames);

%% Procesar cada animal

for a = 1:numAnimals
    animalName = animalNames{a};
    
    % Preguntar al usuario por el archivo de timestamp (solo una vez por animal)
    [timestampFile, timestampPath] = uigetfile({'*.csv;*.dat', 'Timestamp Files (*.csv, *.dat)';}, ...
                                                'Select the Timestamp File for Animal', ...
                                                fullfile(filepath));
    if isequal(timestampFile, 0)  % Si el usuario cancela
        disp(['No timestamp file selected for ' animalName]);
        continue;  % Pasar al siguiente animal
    end

    % Leer el archivo de timestamps dependiendo del formato (CSV o DAT)
    [~, ~, ext] = fileparts(timestampFile); % Obtener la extensión del archivo
    if strcmp(ext, '.csv')
        % Si el archivo es CSV
        timestampsData = readtable(fullfile(timestampPath, timestampFile));
        timestampsData.TimeStamp_ms_(1)=0;
    elseif strcmp(ext, '.dat')
        % Si el archivo es DAT
        cameraNum = input('Seleccione el número de cámara (0 o 1): ');
        datData = readtable(fullfile(timestampPath, timestampFile));
        datData = datData(datData.camNum == cameraNum, :);  % Filtrar según la cámara seleccionada
        datData.sysClock(1) =0;
    else
        disp('Unsupported timestamp file format.');
        continue;
    end

    % Nombre del animal
    numNeurons = size(Experiment(1).(field).(animalName).Filt, 1);

    % Preguntar al usuario si desea eliminar las neuronas malas para este animal
    removeBadNeurons = input(['¿Desea eliminar las neuronas malas para ' animalName '? (s/n): '], 's');
    % Cargar los índices de las buenas neuronas para el animal actual si se requiere
    if strcmpi(removeBadNeurons, 's')
        [filename_goodn, filepath_goodn] = uigetfile('*.mat', 'Select an Good Neuron Index to Load');
        load(fullfile(filepath_goodn, filename_goodn),"good_neurons_indices");
        good_neurons = good_neurons_indices; % Seleccionar solo las buenas neuronas
    else
        good_neurons = 1:numNeurons; % Incluir todas las neuronas
    end

    % Crear las categorías
    hab_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'Hab'));
    tone1_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'Tone 1'));
    shock1_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'Shock 1'));
    ITI1_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'ITI 1'));
    tone2_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'Tone 2'));
    shock2_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'Shock 2'));
    ITI2_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'ITI 2'));
    tone3_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'Tone 3'));
    shock3_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'Shock 3'));
    ITI3_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'ITI 3'));
    tone4_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'Tone 4'));
    shock4_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'Shock 4'));
    ITI4_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'ITI 5'));
    tone5_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'Tone 5'));
    shock5_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'Shock 5'));
    ITI5_interval = find(contains(Experiment(1).(field).(animalName).Task.Titles, 'ITI 5'));

    intervalCategories = Experiment(1).(field).(animalName).Task.Titles;
    intervals = {hab_interval, tone1_interval, shock1_interval, ITI1_interval, tone2_interval, shock2_interval, ITI2_interval, ...
        tone3_interval, shock3_interval, ITI3_interval, tone4_interval, shock4_interval, ITI4_interval, tone5_interval, shock5_interval, ITI5_interval};
    
    % Inicializar la tabla de resultados para este animal
    results = table('Size', [numel(good_neurons), numel(intervalCategories) * 8], ...
                    'VariableTypes', repmat({'double'}, 1, numel(intervalCategories) * 8), ...
                    'VariableNames', [strcat('Mean_', intervalCategories), ...
                                      strcat('Peaks_', intervalCategories), ...
                                      strcat('AmpComp_', intervalCategories), ...
                                      strcat('AmpPeak_', intervalCategories), ...
                                      strcat('AUC_', intervalCategories), ...
                                      strcat('CompPeaks_', intervalCategories), ...
                                      strcat('TotalAUC_', intervalCategories), ...
                                      strcat('RatePeaks_', intervalCategories)]);

    % Inicializar la matriz 3D binaria y la estructura para eventos compuestos
    maxFrames = max(Experiment(1).(field).(animalName).Task.End);
    binaryMatrix = NaN(numel(good_neurons), maxFrames, numel(intervalCategories));
    compositeEvents = cell(numel(good_neurons), numel(intervalCategories));

    % Procesar cada neurona
    for n = 1:numel(good_neurons)
        neuronIdx = good_neurons(n);
        
        % Depuración: Imprimir la neurona que se está procesando
        fprintf('Procesando neurona %d de %d\n', neuronIdx, numNeurons);

        for c = 1:numel(intervalCategories)
            currentIntervals = intervals{c};
            disp(intervalCategories(c))
            % Inicializar contenedores para las métricas agregadas
            totalFluorescence = 0;
            totalFrames = 0;
            numPeaksTotal = 0;
            ampPeaksTotal = [];
            aucsTotal = [];
            maxAmpsTotal = [];
            totalCompPeaks = 0;
            totalAUCTotal = 0;
            ratePeaksTotal = [];
            filteredPeaksTotal = [];
            timestamps = [];
            numPeaksWindow = [];
            timeInRoi = 0;

            % Procesar cada intervalo correspondiente a la categoría actual
            totalSeconds = 0;  % Inicializar los segundos totales para esta categoría
            for i = 1:numel(currentIntervals)
             
                intervalIdx = currentIntervals(i);

                % Obtener el intervalo de frames
                startFrame = Experiment(1).(field).(animalName).Task.Start(intervalIdx);
                if startFrame == 0 
                    startFrame = 1
                end 
                endFrame = Experiment(1).(field).(animalName).Task.End(intervalIdx);

                % Obtener los datos de fluorescencia para el intervalo
            
                dataInterval = Experiment(1).(field).(animalName).Filt(neuronIdx, startFrame:endFrame);

                % Calcular los segundos correspondientes a este intervalo usando timestamps
                if exist('timestampsData', 'var')
                    % Para el archivo CSV
                    startTime = timestampsData.TimeStamp_ms_(startFrame); % Timestamp de inicio
                    endTime = timestampsData.TimeStamp_ms_(endFrame); % Timestamp de fin
                    intervalSeconds = (endTime - startTime) / 1000; % Convertir a segundos
                    totalSeconds = totalSeconds + intervalSeconds; % Acumular los segundos totales

                    % Depuración: Imprimir timestamps y segundos
                    % fprintf('StartTime = %.3f, EndTime = %.3f, IntervalSeconds = %.3f\n', startTime, endTime, intervalSeconds);
                elseif exist('datData', 'var')
                    % Para el archivo DAT
                    startTime = datData.sysClock(startFrame); % Timestamp de inicio
                    endTime = datData.sysClock(endFrame); % Timestamp de fin
                    intervalSeconds = (endTime - startTime) / 1000; % Convertir a segundos
                    totalSeconds = totalSeconds + intervalSeconds; % Acumular los segundos totales

                    % Depuración: Imprimir timestamps y segundos
                    % fprintf('StartTime = %.3f, EndTime = %.3f, IntervalSeconds = %.3f\n', startTime, endTime, intervalSeconds);
                end

                % Imprimir los valores de fluorescencia del intervalo
                % fprintf('Fluorescencia en el intervalo: %s\n', mat2str(dataInterval));

                % Sumar las fluorescencias de este intervalo
                totalFluorescence = totalFluorescence + sum(dataInterval);
                % Sumar el número de frames en este intervalo
                totalFrames = totalFrames + (endFrame - startFrame + 1);

                % Solo calcular picos y otros eventos si hay suficientes datos
                if length(dataInterval) >= 3
                    % Encontrar los picos (máximos locales)
                    [peaks, locs] = findpeaks(dataInterval);

                    % Filtrar picos irrelevantes
                    filteredPeaks = [];
                    filteredLocs = [];
                    minVal = min(dataInterval);
                    maxVal = max(dataInterval);
                    threshold = 0.05 * (maxVal - minVal);

                    for p = 1:numel(peaks)
                        if p > 1
                            prevMin = min(dataInterval(locs(p-1):locs(p)));
                        else
                            prevMin = minVal;
                        end
                        if p < numel(peaks)
                            nextMin = min(dataInterval(locs(p):locs(p+1)));
                        else
                            nextMin = minVal;
                        end

                        if (peaks(p) - prevMin > threshold) && (peaks(p) - nextMin > threshold)
                            filteredPeaks = [filteredPeaks; peaks(p)];
                            filteredLocs = [filteredLocs; locs(p)];
                        end
                    end

                    % Calcular el número de picos como eventos separados
                    numPeaks = numel(filteredPeaks);
                    numPeaksTotal = numPeaksTotal + numPeaks;

                    % Calcular la amplitud media de los picos generales
                    ampPeaksTotal = [ampPeaksTotal; filteredPeaks];

                    % Marcar los picos en la matriz 3D binaria
                    binaryMatrix(n, startFrame:endFrame, c) = NaN;
                    binaryMatrix(n, startFrame:endFrame, c) = ismember(1:(endFrame-startFrame+1), filteredLocs);

                    % Calcular eventos compuestos para AUC y amplitud
                    baselineComp = min(dataInterval) + 0.1 * (max(dataInterval) - min(dataInterval));
                    [events, aucs, maxAmps, totalEvents] = detectCompositeEvents(dataInterval, baselineComp);

                    % Calcular el AUC total del intervalo
                    totalAUC = sum(dataInterval);
                    totalAUCTotal = totalAUCTotal + totalAUC;

                    % Almacenar los eventos compuestos
                    compositeEvents{n, c} = [compositeEvents{n, c}; events + startFrame - 1]; % Ajustar los frames al índice global

                    % Agregar métricas
                    aucsTotal = [aucsTotal; aucs];
                    maxAmpsTotal = [maxAmpsTotal; maxAmps];
                    totalCompPeaks = totalCompPeaks + totalEvents;

                end
            end
            
            % Calcular ratePeaks como la división de picos totales entre los segundos totales
            if totalSeconds > 0
                ratePeaks = numPeaksTotal / totalSeconds; % Número de picos dividido entre los segundos totales
            else
                ratePeaks = 0;
            end
            disp(totalSeconds)
            


            % Almacenar los resultados agregados en la tabla, ignorando NaN
            results{n, sprintf('Mean_%s', intervalCategories{c})} = totalFluorescence / totalSeconds;
            results{n, sprintf('Peaks_%s', intervalCategories{c})} = numPeaksTotal;
            results{n, sprintf('RatePeaks_%s', intervalCategories{c})} = ratePeaks;

            results{n, sprintf('AmpComp_%s', intervalCategories{c})} = mean(maxAmpsTotal(~isnan(maxAmpsTotal)));
            results{n, sprintf('AmpPeak_%s', intervalCategories{c})} = mean(ampPeaksTotal(~isnan(ampPeaksTotal)));
            results{n, sprintf('AUC_%s', intervalCategories{c})} = mean(aucsTotal(~isnan(aucsTotal)));
            results{n, sprintf('CompPeaks_%s', intervalCategories{c})} = totalCompPeaks;
            results{n, sprintf('TotalAUC_%s', intervalCategories{c})} = totalAUCTotal;

        end
    end

    % Añadir la columna del animal
    results.Animal = repmat({animalName}, numel(good_neurons), 1);
    
    % Añadir las columnas de los grupos (sexo y tratamiento)
    results.Sexo = repmat(Experiment.Project.Groups(a, 1), numel(good_neurons), 1);
    results.Tratamiento = repmat(Experiment.Project.Groups(a, 2), numel(good_neurons), 1);

    % Reordenar las columnas para poner "Animal", "Sexo" y "Tratamiento" al principio
    results = results(:, [{'Animal'}, {'Sexo'}, {'Tratamiento'}, results.Properties.VariableNames(1:end-3)]);

    % Combinar los resultados de este animal con los resultados de todos los animales
    allResults = [allResults; results];

    % Almacenar la matriz 3D binaria y los eventos compuestos en la estructura
    allBinaryMatrices.(animalName) = binaryMatrix;
    allCompositeEvents.(animalName) = compositeEvents;
    clear timestampsData; 
    clear datData; 
end

%% Allow the user to choose the folder and name of the results file
[file_name, folder_path] = uiputfile('*.xlsx', 'Save Results', 'Results_.xlsx');
if isequal(file_name, 0) || isequal(folder_path, 0)
    error('File save operation canceled.');
end

% Generate the full file path and save the results table
full_file_path = fullfile(folder_path, file_name);
writetable(allResults, full_file_path);

% Allow the user to choose the folder and name of the binary matrices file
[binary_file_name, binary_folder_path] = uiputfile('*.mat', 'Save Binary Matrices', 'BinaryMatrices_.mat');
if isequal(binary_file_name, 0) || isequal(binary_folder_path, 0)
    error('File save operation canceled.');
end

% Generate the full file path and save the binary matrices
binary_full_file_path = fullfile(binary_folder_path, binary_file_name);
save(binary_full_file_path, 'allBinaryMatrices');

% Allow the user to choose the folder and name of the composite events file
[composite_file_name, composite_folder_path] = uiputfile('*.mat', 'Save Composite Events', 'CompositeEvents_.mat');
if isequal(composite_file_name, 0) || isequal(composite_folder_path, 0)
    error('File save operation canceled.');
end

% Generate the full file path and save the composite events
composite_full_file_path = fullfile(composite_folder_path, composite_file_name);
save(composite_full_file_path, 'allCompositeEvents');

% Confirm the save operation
fprintf('The results table was saved in: %s\n', full_file_path);
fprintf('The binary matrices were saved in: %s\n', binary_full_file_path);
fprintf('The composite events were saved in: %s\n', composite_full_file_path);

%% Función para detectar eventos compuestos
function [events, aucs, maxAmps, totalEvents] = detectCompositeEvents(data, baselineComp)
    events = [];
    aucs = [];
    maxAmps = [];
    totalEvents = 0;
    inEvent = false;
    eventStart = 0;
    currentMaxAmp = 0;
    auc = 0;
    
    for t = 1:length(data)
        if ~inEvent && data(t) > baselineComp
            % Inicia un nuevo evento compuesto
            inEvent = true;
            eventStart = t;
            currentMaxAmp = data(t);
            auc = data(t);
        elseif inEvent
            % Dentro de un evento compuesto
            auc = auc + data(t);
            if data(t) > currentMaxAmp
                currentMaxAmp = data(t);
            end
            
            if data(t) < baselineComp || t == length(data)
                % Termina el evento compuesto
                inEvent = false;
                eventEnd = t;

                % Calcular el AUC desde el inicio hasta el fin del evento
                events = [events; eventStart, eventEnd];
                aucs = [aucs; sum(data(eventStart:eventEnd))];
                maxAmps = [maxAmps; currentMaxAmp];
                totalEvents = totalEvents + 1;
            end
        end
    end
    
    % Manejar el último evento si no se cerró
    if inEvent
        eventEnd = length(data);
        events = [events; eventStart, eventEnd];
        aucs = [aucs; sum(data(eventStart:eventEnd))];
        maxAmps = [maxAmps; currentMaxAmp];
        totalEvents = totalEvents + 1;
    end
end