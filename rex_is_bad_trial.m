function [bad] = rex_is_bad_trial( name, trial )

% [bad] = rex_is_bad_trial( name, trial )
% 
%  Given a data set name (the name of the original REX data and/or the
%  matlab data file), and a trial number, return whether the trial is BAD,
%  i.e. has been marked as BAD during import from the REX A and E files
%  (aborted trial) or subsequently marked BAD for other reasons.
global allbad rexloadedname rexnumtrials;
% rexnumtrials=str2num(get(findobj('Tag','nboftrialsdisplay'),'String'));
bad = 0; 

% if exist( rexloadedname )
%     if name ~= rexloadedname
%         clear rexloadedname;
%     end;
% end;
% 
% if ~exist( rexloadedname, 'var' )
%     rex_load_processed( name );
% end;

% s = sprintf( 'rex_is_bad_trial: >%s< >%s< %d', name, rexloadedname, strcmp( name, rexloadedname ));
% disp( s );
if ~strcmp( name,rexloadedname );
     rex_load_processed( name );
end;

if trial < 1 || trial > rexnumtrials
    bad = 1;
else
    bad = allbad( trial );
end;