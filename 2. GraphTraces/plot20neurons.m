
%%
% Preguntar al usuario si desea graficar todas las neuronas, solo las buenas, solo las malas, o 20 neuronas aleatorias
disp('Opciones de graficar:');
disp('1. Todas las neuronas');
disp('2. Solo las buenas neuronas');
disp('3. Solo las malas neuronas');
disp('4. 20 neuronas aleatorias');
plotOption = input('Elija una opción (1/2/3/4): ');

ms.FiltTraces = ms.FiltTraces.';
ms.RawTraces = ms.RawTraces.';

% Seleccionar las neuronas a graficar
switch plotOption
    case 1
        neuronsToPlot = 1:size(ms.FiltTraces, 1);
        titleSuffix = 'All neurons';
    case 2
        neuronsToPlot = good_neurons_indices;
        titleSuffix = 'Good neurons';
    case 3
        allNeurons = 1:size(ms.FiltTraces, 1);
        neuronsToPlot = setdiff(allNeurons, good_neurons_indices);
        titleSuffix = 'Bad neurons';
    case 4
        allNeurons = good_neurons_indices;
        numToPlot = min(20, numel(allNeurons)); % Limitar a 20 si hay menos neuronas
        neuronsToPlot = randsample(allNeurons, numToPlot);
        titleSuffix = '20 Random neurons';
    otherwise
        error('Opción no válida. Elija 1, 2, 3 o 4.');
end

% Número de neuronas a graficar
numNeurons = numel(neuronsToPlot);

% Ploteo de FiltTraces
figure;
hold on;
for i = 1:numNeurons
    neuronIndex = neuronsToPlot(i);
    plot(ms.FiltTraces(neuronIndex, :) + (i-1)*1, 'DisplayName', ['Neurona ' num2str(neuronIndex)]);
end
title(['FiltTraces - ' titleSuffix]);
xlabel('Tiempo (frames)');
ylabel('Intensidad (offset por neurona)');
if numNeurons <= 10 % Mostrar leyenda solo si hay <= 10 neuronas
    legend('show');
end
hold off;

% Ploteo de RawTraces
figure;
hold on;
for i = 1:numNeurons
    neuronIndex = neuronsToPlot(i);
    plot(ms.RawTraces(neuronIndex, :) + (i-1)*1, 'DisplayName', ['Neurona ' num2str(neuronIndex)]);
end
title(['RawTraces - ' titleSuffix]);
xlabel('Tiempo (frames)');
ylabel('Intensidad (offset por neurona)');
if numNeurons <= 10 % Mostrar leyenda solo si hay <= 10 neuronas
    legend('show');
end
hold off;

% %% Ploteo de SFP (spatial footprints) en una sola imagen continua
% figure;
% hold on;
% colormap('jet');
% combinedSFP = zeros(size(ms.SFPs, 1), size(ms.SFPs, 2));
% centroids = []; % Array to store centroids of the neurons
% 
% for i = 1:numNeurons
%     neuronIndex = neuronsToPlot(i);
%     combinedSFP = combinedSFP + ms.SFPs(:,:,neuronIndex);
% 
% 
%     % Calculate the centroid of the neuron
%     [rows, cols] = find(ms.SFPs(:,:,neuronIndex) > 0); % Pixels belonging to the neuron
%     centroidX = mean(cols);
%     centroidY = mean(rows);
%     centroids = [centroids; centroidX, centroidY];
% end
% 
% % Normalize the combined SFP for better visualization
% combinedSFP = combinedSFP / max(combinedSFP(:));
% imagesc(combinedSFP);
% axis equal;
% axis tight;
% colorbar;
% 
% % Overlay circles on the centroids of selected neurons
% for i = 1:size(centroids, 1)
%     plot(centroids(i, 1), centroids(i, 2), 'o', ...
%          'MarkerEdgeColor', 'red', ...
%          'MarkerFaceColor', 'none', ...
%          'MarkerSize', 20, ...
%          'LineWidth', 1.5);
% end
% 
% title(['SFP - ' titleSuffix ' (' num2str(numNeurons) ' neuronas)']);
% hold off;


%

% Ploteo de SFP (spatial footprints) en una sola imagen continua
figure;
hold on;
colormap('jet');
combinedSFP = zeros(size(ms.SFPs, 1), size(ms.SFPs, 2));
for i = 1:numNeurons
    neuronIndex = neuronsToPlot(i);
    combinedSFP = combinedSFP + ms.SFPs(:,:,neuronIndex);
end
combinedSFP = combinedSFP / max(combinedSFP(:)); % Normalizar valores
imagesc(combinedSFP);
axis equal;
axis tight;
colorbar;
title(['SFP - ' titleSuffix ' (' num2str(numNeurons) ' neuronas)']);
hold off;
