%%
% Preguntar al usuario si desea graficar todas las neuronas, solo las buenas o solo las malas
disp('Graph options:');
disp('1. All the neurones');
disp('2. Only real neurones');
disp('3. Only fake neurones');
plotOption = input('Choose an option (1/2/3): ');


ms.FiltTraces = ms.FiltTraces.';
ms.RawTraces = ms.RawTraces.';

% Seleccionar las neuronas a graficar
switch plotOption
    case 1
        neuronsToPlot = 1:size(ms.FiltTraces, 1);
        titleSuffix = 'All the neurones';
    case 2
        neuronsToPlot = good_neurons_indices;
        titleSuffix = 'Real neurones';
    case 3
        allNeurons = 1:size(ms.FiltTraces, 1);
        neuronsToPlot = setdiff(allNeurons, good_neurons_indices);
        titleSuffix = 'Fake neurones';
    otherwise
        error('Option not correct. Choose 1, 2 o 3.');
end

% Número de neuronas a graficar
numNeurons = numel(neuronsToPlot);

% Ploteo de FiltTraces
figure;
hold on;
for i = 1:numNeurons
    neuronIndex = neuronsToPlot(i);
    plot(ms.FiltTraces(neuronIndex, :) + (i-1)*1, 'DisplayName', ['Neurons ' num2str(neuronIndex)]);
end
title(['FiltTraces - ' titleSuffix]);
xlabel('Time (frames)');
ylabel('Intensity (offset for neurons)');
legend('show');
hold off;

% Ploteo de RawTraces
figure;
hold on;
for i = 1:numNeurons
    neuronIndex = neuronsToPlot(i);
    plot(ms.RawTraces(neuronIndex, :) + (i-1)*1, 'DisplayName', ['Neurons ' num2str(neuronIndex)]);
end
title(['RawTraces - ' titleSuffix]);
xlabel('Time (frames)');
ylabel('Intensity (offset for neurons)');
legend('show');
hold off;

% Ploteo de SFP (spatial footprints) en una sola imagen continua
figure;
hold on;
colormap('jet');
combinedSFP = zeros(size(ms.SFPs, 1), size(ms.SFPs, 2));
for i = 1:numNeurons
    neuronIndex = neuronsToPlot(i);
    combinedSFP = combinedSFP + ms.SFPs(:,:,neuronIndex);
end
imagesc(combinedSFP);
axis equal;
axis tight;
colorbar;
title(['SFP - ' titleSuffix]);
hold off;