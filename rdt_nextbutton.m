function [] = rdt_nextbutton

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_includeaborted;
global curtasktype;


rdt_trialnumber = rex_next_trial( rdt_filename, rdt_trialnumber, rdt_includeaborted );

%rdt_displaytrial_WORKING
rdt_displaytrial(curtasktype);