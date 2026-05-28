function Experiment = adjustExperimentInfo(Experiment, Paradigm, animalsIndexToRemove)
    % Asegurarse de que animalsIndexToRemove sea un arreglo ordenado de menor a mayor
    animalsIndexToRemove = sort(animalsIndexToRemove, 'descend');
    
    % Iterar sobre cada índice de animal a eliminar
    for i = 1:length(animalsIndexToRemove)
        animalIndexToRemove = animalsIndexToRemove(i);
        animalToRemove = sprintf('M%d', animalIndexToRemove);  % Animal a eliminar
        
        % Eliminar la información del animal de la subestructura EPM
        if isfield(Experiment.(Paradigm), animalToRemove)
            Experiment.(Paradigm) = rmfield(Experiment.(Paradigm), animalToRemove);
        end
        
        % Eliminar la entrada de Groups correspondiente al animal eliminado
        Experiment.Project.Groups(animalIndexToRemove,:) = [];
    end
    
    % Ajustar el número de animales a la longitud de Groups actualizada
    Experiment.Project.Animals = numel(Experiment.Project.Groups(:,1));
    
    % Renombrar las claves de los animales restantes en EPM para reflejar los índices correctos
    animalFields = fieldnames(Experiment.(Paradigm));  % Obtener los campos de animales actuales
    for i = 1:length(animalFields)
        correctIndex = sprintf('M%d', i);
        if ~strcmp(animalFields{i}, correctIndex)
            Experiment.(Paradigm).(correctIndex) = Experiment.(Paradigm).(animalFields{i});
            Experiment.(Paradigm) = rmfield(Experiment.(Paradigm), animalFields{i});
        end
    end
end