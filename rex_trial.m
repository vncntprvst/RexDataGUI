function [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial, curtrialsacInfo] = rex_trial(name, trial)

% [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial] 
%     = rex_trial(name, trial)
%
%  Given a data set name (the name of the original REX data and/or the
%  matlab data file), and a trial number, return all of the data for the
%  requested trial.  This includes:
%
%  ecodeout - a list of the rex codes for the trial
%  etimeout - a list of the times at which those codes occur
%  spkchan - I think this is the number of neural data channels.  All of
%         code at present assumes only one channel.
%  spk - an array of spike times as established by MEX.  See also
%         rex_rasters_trialtype() and rex_spk2raster().
%  arate - sampling rate (e.g. 1000 for 1kHz )
%  h - the horizontal eye movement trace for the trial
%  v - the vertical eye movement trace
%  start_time - I think this is already accounted for when adjusting the
%         values for etimeout.  Not sure.
%  badtrial - is this a bad trial (marked BAD or ABORTED)
%
%  See also rex_process(), rex_load_processed(), rex_trial_saccadetimes()


% global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums...
%     allcodes alltimes allspkchan allspk allrates ...
%     allh allv allstart allbad alldeleted allsacstart allsacend...
%     allcodelen allspklen alleyelen allsaclen saccadeInfo;

ecodeout = [];
etimeout = [];
spkchan = 0;
spk = [];
arate = 0;
h = [];
v = [];
start_time = 0; 
badtrial = 1;

if ~strcmp( name,rexloadedname );
     success = rex_load_processed( name );
     if ~success
         s = sprintf( 'rex_trial:  could not load the data for %s (cannot find .mat or A and E files).', name );
         disp( s );
         return;
     end;        
end;

if trial < 1 || trial > rexnumtrials
    s = sprintf( 'rex_trial:  attempt to retrieve data for a trial number that does not exist (%d).', trial );
    disp( s );
    return;
end;

ecodeout = allcodes( trial, 1:allcodelen(trial) );
etimeout = alltimes( trial, 1:allcodelen(trial) );
spkchan = allspkchan( trial );
spk = allspk( trial, 1:allspklen(trial) );
arate = allrates( trial );
h = allh( trial, 1:alleyelen(trial) );
v = allv( trial, 1:alleyelen(trial) );
start_time = allstart( trial );
badtrial = allbad( trial );
curtrialsacInfo=cat(1,saccadeInfo(trial,:));
    