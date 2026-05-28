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

%% Ask for timestamp folder

% Ask the user to select a folder (only once per animal)
timestampPath = uigetdir(filepath, 'Select the folder containing the timestamp file');

%% Add Conmplete Session (Only FE)

for an=1:numAnimals
    animalName = animalNames{an};
        timestampFile = strcat("timeStamp_", animalName, "_", field, ".csv");

    Task = Experiment(1).(field).(animalName).Task;
    Experiment(1).(field).(animalName).Task.Titles{end+1} = 'Entire Session';
    TotLenght = sum([Task.Lengths{:}]);
    Experiment(1).(field).(animalName).Task.Lengths{end+1} = TotLenght;
    TotFrame = sum(Task.Frames);
    Experiment(1).(field).(animalName).Task.Frames(end+1) = TotFrame;
    TotStart = Task.Start(1);
    Experiment(1).(field).(animalName).Task.Start(end+1) = TotStart;
    TotEnd = Task.End(end);
    Experiment(1).(field).(animalName).Task.End(end+1) = TotEnd;
end 

%% Procesar cada animal
for a = 1:numAnimals
    animalName = animalNames{a};
    Task = Experiment(1).(field).(animalName).Task;

    % --- Add 'Entire Session' only if not already added ---
    if ~any(strcmp(Task.Titles,'Entire Session'))
        Task.Titles{end+1} = 'Entire Session';
        Task.Lengths{end+1} = sum([Task.Lengths{:}]);
        Task.Frames(end+1) = sum(Task.Frames);
        Task.Start(end+1) = Task.Start(1);
        Task.End(end+1) = Task.End(end);
        Experiment(1).(field).(animalName).Task = Task;  % Save back
    end

    % --- Fresh Intervals for this animal ---
    Intervals = string(Task.Titles);
    numIntervals = numel(Intervals);

    % Number of neurons
    numNeurons = size(Experiment(1).(field).(animalName).Filt, 1);

    % Ask user if bad neurons should be removed
    removeBadNeurons = input(['¿Desea eliminar las neuronas malas para ' animalName '? (s/n): '], 's');
    if strcmpi(removeBadNeurons, 's')
        [filename_goodn, filepath_goodn] = uigetfile('*.mat', 'Select Good Neuron Index to Load');
        load(fullfile(filepath_goodn, filename_goodn),"good_neurons_indices");
        good_neurons = good_neurons_indices;
    else
        good_neurons = 1:numNeurons;
    end

    % --- Initialize results table for this animal ---
    results = table('Size', [numel(good_neurons), numIntervals * 8], ...
                    'VariableTypes', repmat({'double'}, 1, numIntervals * 8), ...
                    'VariableNames', [strcat('Mean_', Intervals), ...
                                      strcat('Peaks_', Intervals), ...
                                      strcat('AmpComp_', Intervals), ...
                                      strcat('AmpPeak_', Intervals), ...
                                      strcat('AUC_', Intervals), ...
                                      strcat('CompPeaks_', Intervals), ...
                                      strcat('TotalAUC_', Intervals), ...
                                      strcat('RatePeaks_', Intervals)]);

    % Initialize binary matrix and composite events
    maxFrames = max(Task.End);
    binaryMatrix = NaN(numel(good_neurons), maxFrames, numIntervals);
    compositeEvents = cell(numel(good_neurons), numIntervals);

    % --- Process each neuron ---
    for n = 1:numel(good_neurons)
        neuronIdx = good_neurons(n);

        for c = 1:numIntervals
            intervalIdx = c;

            startFrame = Task.Start(intervalIdx);
            if startFrame == 0
                startFrame = 1;
            end
            endFrame = Task.End(intervalIdx);

            dataInterval = Experiment(1).(field).(animalName).Filt(neuronIdx, startFrame:endFrame);
            intervalSeconds = Task.Lengths{intervalIdx};

            % --- Fluorescence and total seconds ---
            totalFluorescence = sum(dataInterval);
            totalFrames = endFrame - startFrame + 1;

            % --- Peaks calculation ---
            numPeaksTotal = 0;
            ampPeaksTotal = [];
            aucsTotal = [];
            maxAmpsTotal = [];
            totalCompPeaks = 0;
            totalAUCTotal = sum(dataInterval);

            if length(dataInterval) >= 3
                [peaks, locs] = findpeaks(dataInterval);

                % Filter peaks
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

                numPeaksTotal = numel(filteredPeaks);
                ampPeaksTotal = filteredPeaks;

                % Binary matrix
                binaryMatrix(n, startFrame:endFrame, c) = ismember(1:(endFrame-startFrame+1), filteredLocs);

                % Composite events
                baselineComp = min(dataInterval) + 0.1 * (max(dataInterval) - min(dataInterval));
                [events, aucs, maxAmps, totalEvents] = detectCompositeEvents(dataInterval, baselineComp);

                totalCompPeaks = totalEvents;
                aucsTotal = aucs;
                maxAmpsTotal = maxAmps;
                compositeEvents{n, c} = events + startFrame - 1;
            end

            % Rate peaks
            ratePeaks = numPeaksTotal / intervalSeconds;

            % Save results
            results{n, sprintf('Mean_%s', Intervals{c})} = totalFluorescence / intervalSeconds;
            results{n, sprintf('Peaks_%s', Intervals{c})} = numPeaksTotal;
            results{n, sprintf('RatePeaks_%s', Intervals{c})} = ratePeaks;
            results{n, sprintf('AmpComp_%s', Intervals{c})} = mean(maxAmpsTotal(~isnan(maxAmpsTotal)));
            results{n, sprintf('AmpPeak_%s', Intervals{c})} = mean(ampPeaksTotal(~isnan(ampPeaksTotal)));
            results{n, sprintf('AUC_%s', Intervals{c})} = mean(aucsTotal(~isnan(aucsTotal)));
            results{n, sprintf('CompPeaks_%s', Intervals{c})} = totalCompPeaks;
            results{n, sprintf('TotalAUC_%s', Intervals{c})} = totalAUCTotal;
        end
    end

    % Add animal and treatment columns
    results.Animal = repmat({animalName}, numel(good_neurons), 1);
    results.Tratamiento = repmat(Experiment.Project.Groups(a, 1), numel(good_neurons), 1);
    results = results(:, [{'Animal'},{'Tratamiento'}, results.Properties.VariableNames(1:end-2)]);

    % Combine with allResults
    allResults = [allResults; results];

    % Save binary and composite matrices
    allBinaryMatrices.(animalName) = binaryMatrix;
    allCompositeEvents.(animalName) = compositeEvents;

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