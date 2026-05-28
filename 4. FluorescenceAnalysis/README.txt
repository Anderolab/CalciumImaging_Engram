FLUORESCENCE 

1. Open Computar_Metricas_Mariana;
2. In the section If you want to remove Animals (line 17) you can decide if you want to restrict your analysis to a subgroup (example: only females):
	a. inside animals_to_delete write the numbers of the animals to exclude as follows [1,2,3,4,5]
	b. this way your group will have ONLY [6,7,8,9,...]
3. On line 23 change the list of animals with the correct one for your experiment;
4. RUN;
5. Select your Experiment file;
6. The following steps need to be repeated for all animals (be careful not to lose count):
	a. Select the timestamp of the animal;
	b. Do you want to select only Real Neurones?
		- n : done, now it will go to the next animal (point a.)
		- y : select the good_neuron_index of this animal, done, now it will go to the next animal (point a.)
7. Choose where to save the result file, the binary matrix and the composite events  	
