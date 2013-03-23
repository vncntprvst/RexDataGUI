****************************************
* README for the RexDataGUI repository *
*                                      *
****************************************

RexGUI is a Matlab GUI designed to process and display recordings made with NIH's REX
It runs on MATLAB version 2011b and older, and requires the signal processing toolbox.

The directories to recording files (REX's A and E files), and outputs from the GUI 
(processed files, figures) have to be specified in the code, at multiple locations. 
If you plan to contribute to the repository, preserve compatibilty with current users'
settings by simply adding a "elseif" statement at appropriate locations (to find those,  
make a search for "getenv('username')" and add your own username and, if necessary, path).  

Important note: the code assumes that data from different subjects are kept in separate
folders, and that recording files' name start with the initial letter of the subject.
On opening the GUI, the code will make a pass through the folders and, if found lacking,
add the relevant initial letter to the files, according to the folder name.
Similarly, the initial letter will be added to the file when processed, if necessary.
This feature is not optional, and numerous parts of the code depend on it. However,
 feel free to change it as long as you preserve compatibility with the current system.
 
 Notes on using cluster names from Spike2:
 
1. Create a subfolder in each subject's data folder, named Spike2Exports, e.g. "E:\Data\Sixx\Spike2Exports"
2. Once clustering is finished in Spike2, export 2 .mat files containing the new spike times and cluster names, and REX trigger times respectively, to Spike2Exports.
	2a. The name of the .mat file with the spike times and names should be the same as the original .snr file, with an 's' appended to the end, e.g. "S144L2A3_7830s.mat". Make sure that the .snr file name begins with the subject's initial BEFORE exporting the .mat files to avoid naming convention conflicts. The easiest way to do this is to open the GUI, because it automatically appends initials to things that don't have them. Make sure Spike2 is closed if you do this, because MATLAB won't be able to rename a file if it's open in another program.
	2b. The name of the trigger times .mat file should be the same as the original .snr file, with a 't' appended to it, e.g. "S144L2A3_7830t.mat". The GUI expects the structure containing trigger times to be have a title field "trigger", so name your trigger channel ... trigger . Again, make sure the .snr file name begins with the subject's initial.
3. In the GUI, you need to reprocess the data for each cluster separately, by ticking the Use Spike2 radio button, indicating which cluster to look at. In the open raw file dialog box, indicate the A file correspoding to the record you just classified. Sometimes the raster plots that are displayed correspond to the old cluster, you might end up needing to replot after each time you reprocess a file.
4. Enjoy!