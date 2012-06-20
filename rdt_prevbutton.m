function [] = rdt_prevbutton

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_includeaborted;
global curtasktype;


if rdt_trialnumber == 1
    rdt_trialnumber = rdt_nt;
else
    rdt_trialnumber = rex_prev_trial( rdt_filename, rdt_trialnumber, rdt_includeaborted );
end;


%rdt_displaytrial_WORKING
rdt_displaytrial(curtasktype);