function [nt] = rex_display_trials( filename, includeaborted, tasktype )

%% rex_display_trials( filename, includeaborted, tasktype )
% 
%  Displays a dialog (a figure) with buttons to move through all trials and
%  perform various operations, such as marking the trials BAD, or unmarking
%  them, or editing the saccades, or looking at the codes or the spike
%  data, or compiling histograms of neural activity from similar trials.
%
%  If the 2nd optional parameter 'includeaborted' is set to 1 (the DEFAULT)
%  then all trials are viewed, and used in analysis.  If it is set to 0,
%  then only good trials (those that are not marked as BAD) are included.
%
%  'filename' is that name of the rex data files.  If the data are already
%  in memory (see rex_load_processed()) rex_display_trials will use that
%  data.  If not, it will attempt to load filename.mat.  If that cannot be
%  found, it will attempt to convert filenameA and filenameE to
%  filename.mat, and then load it.
%
%  'tasktype' is an optional string variable that indicates that you want a
%  special button added to the dialog.  The button will have the task name
%  on it, and clicking the button will call a function (that you have to
%  write) called rdt_<taskname>button.  So a call like:
%    rex_display_trials( 'myrexfile', 1, 'dir' )
%  will add a button that says 'dir' on it, and when clicked this button
%  will call rdt_dirbutton.

if nargin < 2
    includeaborted = 1;
end;
if nargin < 3
    tasktype = [];
end;

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;
global ecodeout etimeout spkchan spk arate h v start_time;
global curtasktype;

rdt_includeaborted = includeaborted;
rdt_filename = filename;
[rdt_nt curtasktype] = num_rex_trials( rdt_filename );
rdt_badtrial = 0;
rdt_fh = figure();
rdt_trialnumber = rex_first_trial( rdt_filename, rdt_includeaborted );
if rdt_trialnumber == 0
    msgbox( 'There are no good trials (no trials, or all are marked BAD) for this set of Rex data.', 'Loading data', 'modal' );
    close( rdt_fh );
    return;
end;

set( rdt_fh, 'Position', [1095 50 820 910], 'Name','Display trials','NumberTitle','off','Color',[0.9 .9 .8]);

prevbhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', '<', 'Position', [10 10 20 20] );
set( prevbhandle, 'Callback', 'rdt_prevbutton' );
nextbhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', '>', 'Position', [30 10 20 20] );
set( nextbhandle, 'Callback', 'rdt_nextbutton' );
spikebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'spike analysis', 'Position', [50 10 80 20] );
set( spikebhandle, 'Callback', 'rdt_spikebutton' );
codebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'code list', 'Position', [130 10 80 20] );
set( codebhandle, 'Callback', 'rdt_codebutton' );
deletebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'mark as BAD', 'Position', [210 10 80 20] );
set( deletebhandle, 'Callback', 'rdt_deletebutton' );
undeletebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'mark as good', 'Position', [290 10 90 20] );
set( undeletebhandle, 'Callback', 'rdt_undeletebutton' );
saccadebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'saccades', 'Position', [380 10 90 20] );
set( saccadebhandle, 'Callback', 'rdt_saccadebutton' );

histobhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'compile trials', 'Position', [480 10 90 20] );
set( histobhandle, 'Callback', 'rdt_histobutton' );
if ~isempty( tasktype )
    buttonfunction = ['rdt_' tasktype 'button'];
    dirbhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', tasktype, 'Position', [570 10 40 20] );
    set( dirbhandle, 'Callback', buttonfunction );
end;
allsacbhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'saccades', 'Position', [610 10 70 20] );
set( allsacbhandle, 'Callback', 'rdt_allsacbutton' );

notesbhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'notes', 'Position', [690 10 90 20] );
set( notesbhandle, 'Callback', 'rdt_notesbutton' );

savebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'Save changes', 'Position', [780 10 90 20] );
set( savebhandle, 'Callback', 'rdt_savebutton' );

%%
%rdt_displaytrial_WORKING
rdt_displaytrial(curtasktype);
