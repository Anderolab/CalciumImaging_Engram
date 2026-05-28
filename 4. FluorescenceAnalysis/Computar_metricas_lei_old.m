%%SIOF
addpath(genpath("C:\Users\1627858\OneDrive - UAB\Escritorio\CAIMAN\src"))
addpath(genpath("C:\Users\1627858\OneDrive - UAB\Escritorio\CAIMAN\src"))
%%

% Loading and fixing the required datasets

[filename, filepath] = uigetfile('*.mat', 'Select a Experiment File to Load');

if isequal(filename, 0)  % If user cancels the file selection
    disp('File selection canceled');
else
    load(fullfile(filepath, filename));  % Directly load the selected file
end

%%
% Obtén todos los nombres de los animales en Experiment.SI
animals = fieldnames(Experiment.SPT);

% Recorre cada animal
for a = 1:length(animals)
    animal = animals{a};  % Nombre del animal actual
    % Obtén los títulos de las tareas del animal actual
    titles = Experiment.SPT.(animal).Task.Titles;

    % Recorre cada título
  %  for t = 1:length(titles)
  %        title = titles{t};  %Título actual
  % 
  %         %Reemplaza 'ROI2' por 'ROI1'
  %        if startsWith(title, 'ROI2')
  %           newTitle = strrep(title, 'ROI2', 'ROI1');
  %            Experiment.EPM.(animal).Task.Titles{t} = newTitle;
  %        end
  % 
  %         %Reemplaza 'ROI3' por 'ROI2'
  %        if startsWith(title, 'ROI3')
  %           newTitle = strrep(title, 'ROI3', 'ROI2');
  %           Experiment.EPM.(animal).Task.Titles{t} = newTitle;
  %       end
  % 
  %        %Reemplaza 'ROI4' por 'ROI2'
  %       if startsWith(title, 'ROI4')
  %         newTitle = strrep(title, 'ROI4', 'ROI2');
  %         Experiment.EPM.(animal).Task.Titles{t} = newTitle;
  %      end
  % end
end

% Mostrar algunos títulos modificados como verificación
disp(Experiment.SPT.M1.Task.Titles(1:10));
%%
Experiment = removeAnimalAndGroup(Experiment, []);
%%
newAnimalNames = {'M1','M2','M3','M4','M5','M6','M7', 'M8', 'M9','M10','M11','M12','M13','M14'}
%newAnimalNames = {,'M2','M3','M4','M5','M6','M7', 'M8', 'M9','M10','M11','M12','M13','M14'};
% Obtener los nombres de los campos actuales en Experiment.SI
currentAnimalNames = fieldnames(Experiment.SPT);

% Verificar que la longitud de newAnimalNames sea igual a la de currentAnimalNames
if numel(newAnimalNames) ~= numel(currentAnimalNames)
    error('El número de nuevos nombres de animales no coincide con el número de animales en Experiment.');
end

% Crear una nueva estructura para Experiment.SI con los nuevos nombres
newExperimentSPT = struct();

% Renombrar los campos
for i = 1:numel(currentAnimalNames)
    currentName = currentAnimalNames{i};
    newName = newAnimalNames{i};
    newExperimentSPT.(newName) = Experiment.SPT.(currentName);
end

% Asignar la nueva estructura a Experiment.SI
Experiment.SPT = newExperimentSPT;

% Mostrar los nuevos nombres de los campos en Experiment.SI
disp(fieldnames(Experiment.SPT));

% Inicializar una tabla para los resultados de todos los animales
allResults = table();

% Lista de nombres de animales
animalNames = fieldnames(Experiment.SPT);

% Inicializar una estructura para almacenar las matrices 3D binarias y los eventos compuestos
allBinaryMatrices = struct();
allCompositeEvents = struct();

% Verificar el número de animales
numAnimals = numel(animalNames);

% Procesar cada animal ""
for a = 1:numAnimals
    animalName = animalNames{a};
    numNeurons = size(Experiment.SPT.(animalName).Filt, 1);
    
    % Preguntar al usuario si desea eliminar las neuronas malas para este animal
    removeBadNeurons = input(['¿Desea eliminar las neuronas malas para ' animalName '? (s/n): '], 's');

    % Cargar los índices de las buenas neuronas para el animal actual si se requiere
    if strcmpi(removeBadNeurons, 's')
        load(['E:\Ex3_BLA\DLC\Good_neurones\Good_Neurones_SPT\good_neurons_' animalName '_index.mat'], 'good_neurons_indices');
        % Seleccionar solo las buenas neuronas
        good_neurons = good_neurons_indices;
    else
        % Incluir todas las neuronas
        good_neurons = 1:numNeurons;
    end

    % Definir los intervalos para ROI1, ROI2, y NO_ROI
    roi1Intervals = find(contains(Experiment.SPT.(animalName).Task.Titles, 'ROI1'));
    roi2Intervals = find(contains(Experiment.SPT.(animalName).Task.Titles, 'ROI2'));
    noRoiIntervals = find(contains(Experiment.SPT.(animalName).Task.Titles, 'NO_ROI'));

    % Crear las categorías
    intervalCategories = {'ROI1', 'ROI2', 'NO_ROI'};
    intervals = {roi1Intervals, roi2Intervals, noRoiIntervals};
    
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
    maxFrames = max(Experiment.SPT.(animalName).Task.End);
    binaryMatrix = NaN(numel(good_neurons), maxFrames, numel(intervalCategories));
    compositeEvents = cell(numel(good_neurons), numel(intervalCategories));

    % Procesar cada neurona
    for n = 1:numel(good_neurons)
        neuronIdx = good_neurons(n);
        for c = 1:numel(intervalCategories)
            currentIntervals = intervals{c};
            
            % Inicializar contenedores para las métricas agregadas
            meanFluorescences = [];
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
            for i = 1:numel(currentIntervals)
                intervalIdx = currentIntervals(i);

                % Obtener el intervalo de frames
                startFrame = Experiment.SPT.(animalName).Task.Start(intervalIdx);
                endFrame = Experiment.SPT.(animalName).Task.End(intervalIdx);

                % Verificar si el intervalo tiene al menos 1 frame
                if startFrame < endFrame
                    % Obtener los datos de fluorescencia para el intervalo
                    dataInterval = Experiment.SPT.(animalName).Filt(neuronIdx, startFrame:endFrame);

                    % Calcular el valor medio de fluorescencia siempre
                    meanFluorescence = mean(dataInterval);
                    meanFluorescences = [meanFluorescences, meanFluorescence];

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
                        
                        

                        if numPeaks>0
                            numPeaksWindow = [numPeaksTotal; numPeaks];
                            filteredPeaksTotal = [filteredPeaksTotal; filteredPeaks];
                            timestamps = [timestamps; (endFrame-startFrame)/Experiment.Project.RF];
                            ratePeaksTotal = [ratePeaksTotal; numPeaks/((endFrame-startFrame)/Experiment.Project.RF)];
                        end


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
            end
            
            % Almacenar los resultados agregados en la tabla, ignorando NaN
            if ~isempty(meanFluorescences)
                results{n, sprintf('Mean_%s', intervalCategories{c})} = mean(meanFluorescences(~isnan(meanFluorescences)));
            else
                results{n, sprintf('Mean_%s', intervalCategories{c})} = NaN;
            end
            if numPeaksTotal == 0
                ratePeaks = 0;
            else
                ratePeaks = sum(ratePeaksTotal)/numel(ratePeaksTotal);
            end

            results{n, sprintf('Peaks_%s', intervalCategories{c})} = numPeaksTotal;
            results{n, sprintf('AmpComp_%s', intervalCategories{c})} = mean(maxAmpsTotal(~isnan(maxAmpsTotal)));
            results{n, sprintf('AmpPeak_%s', intervalCategories{c})} = mean(ampPeaksTotal(~isnan(ampPeaksTotal)));
            results{n, sprintf('AUC_%s', intervalCategories{c})} = mean(aucsTotal(~isnan(aucsTotal)));
            results{n, sprintf('CompPeaks_%s', intervalCategories{c})} = totalCompPeaks;
            results{n, sprintf('TotalAUC_%s', intervalCategories{c})} = totalAUCTotal;
            results{n, sprintf('RatePeaks_%s', intervalCategories{c})} = ratePeaks;
            
        end
    end

    % Añadir la columna del animal
    results.Animal = repmat({animalName}, numel(good_neurons), 1);
    
    % Añadir las columnas de los grupos (sexo y tratamiento)
    results.Tratamiento = repmat(Experiment.Project.Groups(a, 1), numel(good_neurons), 1);
    results.Sexo = repmat(Experiment.Project.Groups(a, 2), numel(good_neurons), 1);

    % Reordenar las columnas para poner "Animal", "Sexo" y "Tratamiento" al principio
    results = results(:, [{'Animal'}, {'Sexo'}, {'Tratamiento'}, results.Properties.VariableNames(1:end-3)]);

    % Combinar los resultados de este animal con los resultados de todos los animales
    allResults = [allResults; results];

    % Almacenar la matriz 3D binaria y los eventos compuestos en la estructura
    allBinaryMatrices.(animalName) = binaryMatrix;
    allCompositeEvents.(animalName) = compositeEvents;
end


% Guardar la tabla en un archivo CSV
folder_path = 'E:\Ex3_BLA\DLC\SPT_metricas';
filename = fullfile(folder_path, 'results_SPT.xlsx');
writetable(allResults, filename);

% Guardar las matrices 3D binarias en un archivo MAT
binaryMatricesPath = fullfile(folder_path, 'binaryMatrices_SPT.mat');
save(binaryMatricesPath, 'allBinaryMatrices');

% Guardar los eventos compuestos en un archivo MAT
compositeEventsPath = fullfile(folder_path, 'compositeEvents_SPT.mat');
save(compositeEventsPath, 'allCompositeEvents');

% Mostrar un mensaje de confirmación
fprintf('La tabla de resultados se ha guardado en: %s\n', filename);
fprintf('Las matrices 3D binarias se han guardado en: %s\n', binaryMatricesPath);
fprintf('Los eventos compuestos se han guardado en: %s\n', compositeEventsPath);


%% 

% Con isotlier
% Crear los Violin Plots

% % Definir la carpeta de destino
outputFolder = fullfile(['E:\Ex3_BLA\DLC\SPT_metricas\SPT_ViolinPlots']);

% Elegir colores para los grupos
colors = containers.Map({ 'cort_female', 'veh_female', 'cort_male', 'veh_male'}, ...
                        { [0.635, 0.078, 0.184], [0, 0.447, 0.741],[0.85, 0.33, 0.1], [0.301, 0.745, 0.933]});




% Generar y guardar los gráficos sin restricciones
for c = 1:numel(intervalCategories)
    tiledlayout(1,4);
    groupNames = unique(strcat(Experiment.Project.Groups(:, 2), '_', Experiment.Project.Groups(:, 1)));
    A=[];
    for g = 1:size(groupNames,1) %numAnimals
        % Construir el nombre del grupo en función de Tratamiento y Sexo
        % groupName = strcat(Experiment.Project.Groups(g, 2), '_', Experiment.Project.Groups(g, 1));
        columnName = sprintf('RatePeaks_%s', intervalCategories{c});
        elements = split(groupNames(g),'_');
        % Extraer los datos del grupo para el ROI actual
        auxData = allResults(strcmp(allResults.Sexo, elements(1)) & ...
                               strcmp(allResults.Tratamiento, elements(2)), :);
        
        disp("mida aux")
        disp(size(auxData))
        auxData2=auxData(auxData.(columnName)>0,:);
        disp("mida aux2")
        disp(size(auxData2))
        auxData3 = auxData2(~isoutlier(auxData2.(columnName),"mean")==1,:);
        disp("mida aux3")
        disp(size(auxData3))
        A=[A;auxData3];
        % Guardar la tabla en un archivo CSV
        folder_path = 'E:\Ex3_BLA\DLC\SPT_metricas';
        folder_path = strcat(folder_path,'\results_sinoutliers',groupNames(g));
        filename = strcat(folder_path, '.xlsx');
        writetable(auxData3, filename);
        
        

        % Graficar los datos
        nexttile
        violin(auxData3.(columnName), 'facecolor', colors(groupNames(g)));  % Asignar el color basado en Tratamiento_Sexo
        xlabel(groupNames(g));
        ylabel('RatePeaks','FontSize',8);
        %ylim([0,(max(allResults{~isoutlier(allResults{allResults{:, columnName} > 0, columnName},"mean"),columnName})-mean(allResults{~isoutlier(allResults{allResults{:, columnName} > 0, columnName},"mean"),columnName}))*5/8]);
        ylim([0,max(allResults{allResults{:, columnName} > 0, columnName})]);
        %ylim([0,1]); 
        

    end
    
    % Guardar el gráfico como PDF
    outputFileName = fullfile(outputFolder, [char(intervalCategories{c}), '.pdf']);
    set(gcf,'PaperOrientation','landscape','PaperSize',[30,10]);
    print(gcf, outputFileName,'-dpdf','-fillpage');
    close(gcf);
    
end

 


% Agrupar datos por grupo y categoría
% for c = 1:numel(intervalCategories)
%     % ROI1, ROI2, NO_ROI para grupo 1
%     group1Data = allResults{strcmp(allResults.Group, char(Experiment.Project.Groups(1))), sprintf('Mean_%s', intervalCategories{c})};
%     figure;
% 
%     % Crear un boxplot
%     boxplot(group1Data, 'Positions', 1, 'Widths', 0.5);
%     hold on;
% 
%     % Añadir los datos dispersos para simular un violín
%     jitterAmount = 0.1; % Ajustar para más o menos dispersión
%     x = ones(size(group1Data)) + (rand(size(group1Data)) - 0.5) * jitterAmount;
%     scatter(x, group1Data, 'filled', 'MarkerFaceAlpha', 0.6);
% 
%     %title(['Grupo ' char(Experiment.Project.Groups(1)) ': ' intervalCategories{c}]);
%     xlabel('Grupo');
%     ylabel('Fluorescencia Media');
%     hold off;
% 
%     % ROI1, ROI2, NO_ROI para grupo 2
%     group2Data = allResults{strcmp(allResults.Group, char(Experiment.Project.Groups(2))), sprintf('Mean_%s', intervalCategories{c})};
%     figure;
% 
%     % Crear un boxplot
%     boxplot(group2Data, 'Positions', 1, 'Widths', 0.5);
%     hold on;
% 
%     % Añadir los datos dispersos para simular un violín
%     x = ones(size(group2Data)) + (rand(size(group2Data)) - 0.5) * jitterAmount;
%     scatter(x, group2Data, 'filled', 'MarkerFaceAlpha', 0.6);
% 
%     %title(['Grupo ' char(Experiment.Project.Groups(2)) ': ' intervalCategories{c}]);
%     xlabel('Grupo');
%     ylabel('Fluorescencia Media');
%     hold off;
% end


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