function Experiment = eliminarMalasNeuronas(Experiment, taskType, basePath)

    %basePath = strcat(basePath, "_", taskType)
    basePath
    
    % Verificar si el campo especificado existe en Experiment
    if ~isfield(Experiment, taskType)
        error('El campo especificado "%s" no existe en Experiment.', taskType);
    end

    % Obtener la lista de animales a partir de los campos en Experiment.(taskType)
    animalNames = fieldnames(Experiment.(taskType));

    % Iterar sobre cada animal
    for i = 1:numel(animalNames)
        animalName = animalNames{i};

        % Obtener el número de neuronas
        numNeurons = size(Experiment.(taskType).(animalName).Filt, 1);

        % Preguntar al usuario si desea eliminar las neuronas malas para este animal
        removeBadNeurons = input(['¿Desea eliminar las neuronas malas para ' animalName '? (s/n): '], 's');

        % Cargar los índices de las buenas neuronas para el animal actual si se requiere
        if strcmpi(removeBadNeurons, 's')
            % Generar la ruta completa del archivo de buenas neuronas utilizando basePath proporcionado
            % goodNeuronsFile = fullfile(basePath, ['good_neurons_' animalName '_index.mat']);
            goodNeuronsFile = fullfile(basePath, ['good_neurons_' animalName '_' taskType '_index.mat']);

            % Verificar si el archivo existe
            if exist(goodNeuronsFile, 'file')
                % Cargar el archivo de índices de buenas neuronas
                load(goodNeuronsFile, 'good_neurons_indices');

                % Filtrar las neuronas para incluir solo las buenas
                Experiment.(taskType).(animalName).Filt = Experiment.(taskType).(animalName).Filt(good_neurons_indices, :);
                fprintf('Neuronas malas eliminadas para %s en %s. Quedan %d neuronas.\n', animalName, taskType, numel(good_neurons_indices));
            else
                warning('No se encontró el archivo de buenas neuronas para %s en %s. No se eliminaron neuronas.', animalName, taskType);
            end
        else
            fprintf('No se eliminaron neuronas para %s en %s. Se mantienen las %d neuronas originales.\n', animalName, taskType, numNeurons);
        end
    end
end

