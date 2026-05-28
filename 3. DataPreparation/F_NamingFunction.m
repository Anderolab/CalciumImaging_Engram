function [Name] = F_NamingFunction(Animal,TrialType)
%F_NAMINGFUNCTION Given the animal number and the trial type, outputs the
% expected name for the file
Name = strcat("ms_M", num2str(Animal), "_", TrialType, ".mat");
end

