TUNNING ANALYSIS 

1. Open Tunning_Mariana.m
2. Check if Iterations = 1000 (line 151)
3. RUN
4. Select the Experiment file
5. Select the folder in which you want to save the results
6. Enter the number of lists (ex. 4) [this is the number of groups you want to do your analysis for. Example: fem veh, male treatment, ...]
7.  Enter a name for list 1 (Ex. Male_veh) [CAREFUL No spaces after the name of the list (Ex.: 'Male '), it will give you an error]
8. Enter numbers for "Males" (separated by spaces): 1 2 3 7 8 9 
	Do not write their name (Ex. "M1"), only their number
9. Repeat for all your lists
10. Select your folder containing the Good Neurones
11. ¿Desea eliminar las neuronas malas para M1? (s/n):
12. Do it for all the animals
13. Do you want to analyze (1) All Tones/Shock/ITI or (2) Binned? Enter 1 or 2:
	Choose the type of analysis you prefer to do:
	- (1) All Tones/Shock/ITI: takes into consideration all the Tones/Shock/ITI as one;
	- (2) Binned: groups the interval of your choice into bins (how many you prefer);
IF (1)
14. What interval do you want to analyse: 
	Choose one of the proposed intervals and write it 
IF (2)
14.1 How many bins do you want? (Ex. 2)
14.2 Enter tones/shocks for Bin 1 (separated by spaces): 1 2 
     Enter tones/shocks for Bin 2 (separated by spaces): 3 4 5

15. Do you want to take a specific interval as reference? If yes, write it. If done, press Enter: 
	- If you want to take the entire session as a reference just press ENTER
	- If you want to take one or more intervals as reference write then one at the time
16. The analysis will start. Do not stop it until Matlab stops working
17. The results will be saved in the folder you chose
18. If you want to perform another analysis right after RUN TO END from line 99
	%% Choose Analysis Option - START FROM HERE TO PERFORM ANOTHER ANALYSIS 

