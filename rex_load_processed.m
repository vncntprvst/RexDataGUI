function [success] = rex_load_processed( name, skip)

%  [success] = rex_load_processed( name )
% 
%  Rex data for the rex_ matlab functions are stored in memory.  (They are
%  read in from a matlab file created by rex_process().)  This function
%  searches for the matlab file (do not include '.mat' when calling it),
%  and if it cannot find it, calls rex_process() which will see if there
%  are original Rex data files that it can convert.
%  Either way, it then loads the variables into memory.
%
%  See also num_rex_trials, rex_trial, rex_first_trial.

% global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums ...
%     allcodes alltimes allspkchan allspk allrates ...
%     allh allv allstart allbad alldeleted allsacstart allsacend...
%     allcodelen allspklen alleyelen allsaclen allrexnotes saccadeInfo;

global allcodes alltimes allspkchan allspk allrates ...
        allh allv allstart allbad saccadeInfo;
    
global sessiondata rexloadedname rexnumtrials;

if nargin<2
    skip=0;
end

allrexnotes = '';

monkeydirselected=get(get(findobj('Tag','monkeyselect'),'SelectedObject'),'Tag'); 
if strcmp(monkeydirselected,'rigelselect')
    if ~strcmp(name(1),'R')
        name=cat(2,'R', name);
    end
elseif strcmp(monkeydirselected,'sixxselect')
    if ~strcmp(name(1),'S')
        name=cat(2,'S', name);
    end
elseif strcmp(monkeydirselected,'hildaselect')
    if ~strcmp(name(1),'H')
        name=cat(2,'H', name);
    end
end

namelength = length( name );
rexmatname = name;
if ~strcmpi(  name( namelength-3:namelength ) , '.mat' )
    rexmatname = cat( 2, name, '.mat' );  
end;
if ~exist( rexmatname, 'file' ) && ~skip
    disp( 'File to be processed...');
%     if findstr(name,'gap')
%         success = rex_process_gaptask( name ); %specifically to analyse gap tasks
%     else
        success = rex_process_inGUI( name );
%     end
    if ~success
        disp( 'Failed to process file...');
        return;
    end;
elseif ~exist( rexmatname, 'file' ) && skip
    success=0;
    return;
end;

success = 1;
load( rexmatname );
disp( ['Loading ' rexmatname]);

