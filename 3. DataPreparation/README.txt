STEP 1 - TASK CREATION

1. Create a new folder for all the task files (ex. Task_FA)
2. Make sure all the timestamp files are in the same folder and named correctly (ex. timestamp_M1_FA)
3. Open Create_task_fear.m and RUN
4. Select your first timestamp file
5. Insert when asked the number of SECONDS for each period (example below):
	Enter the durations (in seconds):
	Hab: 300
	Tone: 29
	Shock: 1
	ITI: 180
	Durations saved as:
  		durations = [300.00, 29.00, 1.00, 180.00];
6. Save the created file with the name of the animal in the new folder (ex: Task_FA/task_M1_FA.m)
7. Repeat for all animals.

STEP 2 - ANIMAL CONFIGURATION

1. Open GUI_SetAnimals.m and RUN
2. Press Start
3. Insert the number of Animals in your study
4. Insert the number of Groups you have
5. Press Set criteria 
6. Insert the name of the first criteria (ex: sex) and press ENTER
7. Insert the name of the second criteria (ex: treatment) and press ENTER and then Next
8. Insert the number of groups you have in your first criteria and press ENTER
9. Insert the number of groups you have in your second criteria and press ENTER and then Next
10. Insert names for all your groups pressing ENTER each time then Continue
11. Press Group animals
12. For each animal select the groups and finish by pressing Save
13. Press Save animal config
14. Choose the name for your file and press ENTER
15. Press Select the config destination and choose the location
16. Press Save

STEP 3 - Create Project

1. Create a folder with all your ms files for every animal
2. Rename all of the ms files with the same order you chose in your animal configuration file (ex: ms_M1_FA.m; ms_M2_FA.m;...)
3. Open create_project_Mariana and RUN
4. Select the folder containing the ms files
5. Select the Animal configuration file
6. Write your Trial type (for example FA or FE1)
7. A window will open, select one by one the task files in order
8. The file called Experiment.m will be saved in the ms folder

NOTE: On the code (line 23) a color dictionary will be created. You can change the name of the variable if needed
NOTE: Check if frame rate is correct RF