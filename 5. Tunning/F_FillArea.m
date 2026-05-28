function [] = F_FillArea(Mean, SD, C, x)
% Creates shaded error bars given the mean and SD/SEM
% Also needed colour and the x variable.

top = Mean + SD;
bot = Mean - SD;

X = [x, fliplr(x)];
g = [bot, fliplr(top)];

fill(X, g, C, "FaceAlpha", 0.4, "EdgeAlpha", 0)
end

