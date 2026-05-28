%% Identify "good" neurons
% Two options of exclusion criteria: 
% - Exclude cells of low variance: 
%       neuron must have variance >=10% max variance (among non-outliers).
%       change the % by changing the parameter varianceThreshFrac.

varianceThreshFrac = 0.10;

% Cargar la estructura 
load("F:\Neha Calcium\Organised\FA_Hab\ms_FAHab\ms_M3_FAHab.mat", 'ms');

% Inicializa el vector de varianzas
segVariance = zeros(size(ms.RawTraces, 2), 1);

% Calcular la varianza de cada neurona
for cellNum = 1:size(ms.RawTraces, 2)
    segVariance(cellNum) = var(ms.RawTraces(:, cellNum)); 
end

% Calcular el umbral de varianza
varThresh = max(segVariance) * varianceThreshFrac; 

% Preguntar al usuario si desea excluir outliers del cálculo del umbral
excludeOutliersForThreshold = input('¿Desea excluir los outliers del cálculo del umbral? (s/n): ', 's');
excludeOutliersForThreshold = strcmpi(excludeOutliersForThreshold, 's');

% Identificar outliers
tempOutlier = isoutlier(segVariance, 'median');

% Excluir outliers si se requiere para el cálculo del umbral
if excludeOutliersForThreshold
    % Calcular el umbral de varianza excluyendo outliers
    varThresh = max(segVariance(~tempOutlier)) * varianceThreshFrac;
end

% Preguntar al usuario si desea considerar los outliers como neuronas no buenas
considerOutliersAsBad = input('¿Desea considerar los outliers como neuronas no buenas? (s/n): ', 's');
considerOutliersAsBad = strcmpi(considerOutliersAsBad, 's');

% Identificar neuronas con picos exageradamente grandes
excludeNeuronsWithLargePeaks = input('¿Desea excluir neuronas con picos exageradamente grandes? (s/n): ', 's');
excludeNeuronsWithLargePeaks = strcmpi(excludeNeuronsWithLargePeaks, 's');

% Calcular los picos y sus amplitudes
peakAmplitudes = zeros(size(ms.FiltTraces, 2), 1);
for cellNum = 1:size(ms.FiltTraces, 2)
    [peaks, ~] = findpeaks(ms.FiltTraces(:, cellNum));
    peakAmplitudes(cellNum) = mean(peaks); 
end

% Preguntar al usuario qué método desea usar para excluir neuronas con picos exageradamente grandes
if excludeNeuronsWithLargePeaks
    method = input('Elige el método para excluir neuronas con picos exageradamente grandes: (1) isoutlier, (2) 99% de confianza, (3) 95% de confianza: ', 's');
    switch method
        case '1'
            % Usar isoutlier con 'median'
            peakOutliers = isoutlier(peakAmplitudes, 'median');
        case '2'
            % Usar percentil 99
            upperBound = prctile(peakAmplitudes, 99);
            peakOutliers = peakAmplitudes > upperBound;
        case '3'
            % Usar percentil 90
            upperBound = prctile(peakAmplitudes, 85);
            peakOutliers = peakAmplitudes > upperBound;
        otherwise
            error('Método no válido. Elige 1, 2 o 3.');
    end
else
    peakOutliers = false(size(peakAmplitudes));
end

% Pedir coordenadas límite para considerar neuronas como malas
xUpperLimit = input('Ingrese el límite superior de la coordenada X para considerar neuronas como malas (dejar en blanco para omitir): ', 's');
xLowerLimit = input('Ingrese el límite inferior de la coordenada X para considerar neuronas como malas (dejar en blanco para omitir): ', 's');
yUpperLimit = input('Ingrese el límite superior de la coordenada Y para considerar neuronas como malas (dejar en blanco para omitir): ', 's');
yLowerLimit = input('Ingrese el límite inferior de la coordenada Y para considerar neuronas como malas (dejar en blanco para omitir): ', 's');

% Convertir los límites a números si no están vacíos
if ~isempty(xUpperLimit)
    xUpperLimit = str2double(xUpperLimit);
end
if ~isempty(xLowerLimit)
    xLowerLimit = str2double(xLowerLimit);
end
if ~isempty(yUpperLimit)
    yUpperLimit = str2double(yUpperLimit);
end
if ~isempty(yLowerLimit)
    yLowerLimit = str2double(yLowerLimit);
end

% Identificar neuronas malas basadas en las coordenadas de ms.SFPs
coordBadNeurons = false(size(ms.FiltTraces, 2), 1);

for neuron = 1:size(ms.SFPs, 3)
    [rows, cols] = find(ms.SFPs(:, :, neuron));
    if ~isempty(xUpperLimit) && any(cols > xUpperLimit)
        coordBadNeurons(neuron) = true;
    end
    if ~isempty(xLowerLimit) && any(cols < xLowerLimit)
        coordBadNeurons(neuron) = true;
    end
    if ~isempty(yUpperLimit) && any(rows > yUpperLimit)
        coordBadNeurons(neuron) = true;
    end
    if ~isempty(yLowerLimit) && any(rows < yLowerLimit)
        coordBadNeurons(neuron) = true;
    end
end

% Asegurar que todas las variables lógicas tengan el mismo tamaño que el número de neuronas
segVariance = segVariance(:);
peakOutliers = peakOutliers(:);
coordBadNeurons = coordBadNeurons(:);

% Identificar neuronas "buenas"
if considerOutliersAsBad
    good_neurons = segVariance > varThresh & ~tempOutlier & ~peakOutliers & ~coordBadNeurons;
else
    good_neurons = segVariance > varThresh & ~peakOutliers & ~coordBadNeurons;
end

% Mostrar resultados
disp(['Found ', num2str(sum(good_neurons)), ' good neurons (', ...
    num2str(100 * sum(good_neurons) / length(good_neurons)), '%)']);

% Guardar los resultados
save(['F:\Neha Calcium\Organised\FA_Hab\Good_Neurons_FAHab\good_neurons_M8_FAHab.mat'], 'good_neurons');

% Opcional: guardar los índices de las buenas neuronas
good_neurons_indices = find(good_neurons);
save('F:\Neha Calcium\Organised\FA_Hab\Good_Neurons_FAHab\good_neurons_M8_index_FAHab.mat', 'good_neurons_indices');
