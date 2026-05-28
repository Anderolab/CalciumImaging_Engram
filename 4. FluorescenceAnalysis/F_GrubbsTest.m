function[Output, Boolean] = F_GrubbsTest(Data)

% Write csv fpr of the data
writematrix(Data, "AbsFlu.csv")
% Run R Script of Analysis
ScriptPath = strcat('', pwd, '\GrubbsTestOutliers.R');
F_RunRScript(char(ScriptPath))
disp(char(ScriptPath))
Output = readtable("OutliarsTable.csv");
Boolean = zeros(size(Data));
if size(Output, 2) ~= 1
    Boolean(Output.Index) = 1;
end
end 