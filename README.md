# CalciumImaging_Engram
Analysis of Calcium Imaging Output for Fear Learning Paradigm
All functions needed for Fear Learning analysis of Calcium Imaging Data

Before Starting with the Analysis you have to deconvolute all the videos

Pipeline of the Analysis

GraphTraces: to check the quality of your deconvoluted videos and eventually remove wrongly identified neurons;
DataPreparation: to compute the variable Experiment, which will be used for the rest of the steps;
FluorescenceAnalysis: to analyze the fluorescent traces of all your neurons;
Tunning: to analyze the responsiveness of the neurons to the different stimuli (ex. tones or shocks).
The pipeline needs to be performed for every session of your experiment (ex. FA, FE1, ...).
