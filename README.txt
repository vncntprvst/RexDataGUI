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

