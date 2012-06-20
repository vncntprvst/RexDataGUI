function [sstarts,sends] = rex_trial_saccade_times( name, trial )

% [sstarts,sends] = rex_trial_saccade_times( name, trial )
% 
%  Given a data set name (the name of the original REX data and/or the
%  matlab data file), and a trial number, return saccade data for the
%  requested trial.  This includes:
%     sstarts - the indices in the horiz and vert eye traces (allh or
%            allv (they're the same)) that are the starting points of saccades.
%     sends - corresponding ending points (indices) of all of these same
%            saccades.
%  Thus sstarts(3) and sends(3) are the starting and ending indices into
%  the eye movement traces of the third saccade for this trial.
%
%  See also rex_all_saccades() and rex_display_saccades().
%
% EXAMPLE:
%     [codes, times, chan, spk, arate, h, v, stime, badtrial ] = rex_trial(filename, trial);
%     [sstarts, sends] = rex_trial_saccade_times( filename, trial );
%     
%     vcomp = v( sends) - v( sstarts );
%     hcomp = h( sends ) - h( sstarts );
%     sacamp = sqrt( (vcomp .* vcomp) + (hcomp .* hcomp) );
%     sacangle = atan2( vcomp, hcomp );
%     sacangle = sacangle * (180/pi);
%     f = find( sacangle < 0);
%     sacangle( f ) = sacangle( f ) + 360;
%     numsac = length( sstarts );
%
% This example calculates the amplitude and direction (in degrees I think)
% for all of the saccades in a trial.


global rexloadedname rexnumtrials;
%rexnumtrials alloriginaltrialnums allnewtrialnums...
%     allcodes alltimes allspkchan allspk allrates ...
%     allh allv allstart allbad alldeleted allsacstart allsacend...
%     allcodelen allspklen alleyelen allsaclen;

%global trialsaclen trialsacstart trialsacend;

sstarts = [];
sends = [];

if ~strcmp( name,rexloadedname );
     success = rex_load_processed( name );
     if ~success
         s = sprintf( 'rex_trial_saccade_times:  could not load the data for %s (cannot find .mat or A and E files).', name );
         disp( s );
         return;
     end;        

end;

if trial < 1 || trial > rexnumtrials
    s = sprintf( 'rex_trial_saccade_times:  attempt to retrieve data for a trial number that does not exist (%d).', trial );
    disp( s );

    return;
end;

if allsaclen(trial) < 1
    sstarts = [];
    sends = [];
else
    sstarts = allsacstart( trial, 1:allsaclen( trial ) );
    sends = allsacend( trial, 1:allsaclen( trial ) );
end;