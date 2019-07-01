function [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial, curtrialsacInfo] = rdd_rex_trial(name, trial, spikechannel, reload)

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
global allcodes alltimes allspkchan allspk allspk_clus allrates ...
        allh allv allstart allbad saccadeInfo;
global rexloadedname rexnumtrials; %sessiondata

    
if nargin<4
    reload=0;
end

ecodeout = [];
etimeout = [];
spkchan = 0;
spk = [];
arate = 0;
h = [];
v = [];
start_time = 0; 
badtrial = 1;
% if isempty(rexloadedname)
% rexloadedname = get(findobj('Tag','filenamedisplay'),'String');
% end

if ~strcmp( name,rexloadedname ) || reload;
     success = rex_load_processed( name, spikechannel );
     if ~success
         s = sprintf( 'rex_trial:  could not load the data for %s (cannot find .mat or A and E files).', name );
         disp( s );
         return;
     end    
end

if isempty(rexnumtrials)
rexnumtrials=str2num(get(findobj('Tag','trialnumbdisplay'),'String'));
end

if trial < 1 || trial > rexnumtrials
    s = sprintf( 'rex_trial:  attempt to retrieve data for a trial number that does not exist (%d).', trial );
    disp( s );
    return;
end;

%%
% tried using matfile function for each trial, instead of
% using global variables, but it's slower to acces the data from
% disk than memory. 

ecodeout = allcodes(trial,~isnan(allcodes(trial,:)));
etimeout = alltimes(trial,~isnan(alltimes(trial,:)));
spkchan = allspkchan(trial);

if ~isempty(allspk_clus)
    % Check if selected cluster (selclus) is greater than number of clusters or
    % otherwise nonsensical
    
    howmanyclus = double(length(allspk_clus));
    %if howmanyclus && (~(selclus == round(selclus)) || selclus > howmanyclus || selclus < 1)
    %fprintf('Invalid cluster selected. Maximum is %d Setting to cluster 1\n',howmanyclus);
    %set(findobj('Tag','whichclus'),'String','1');
    %selclus = 1;
    %end
    try
        temp_allspk = allspk_clus{spikechannel};
        spk = temp_allspk(trial,~isnan(temp_allspk(trial,:)));
    catch
        fprintf('Invalid cluster selected. Maximum is %d Setting to cluster 1\n',howmanyclus);
        set(findobj('Tag','whichclus'),'String','1');
        return;
    end
    
else
    spk = allspk(trial,~isnan(allspk(trial,:)));
end

arate = allrates(trial);
h = allh(trial,~isnan(allh(trial,:)));
v = allv(trial,~isnan(allv(trial,:)));
start_time = allstart(trial);
badtrial = allbad(trial);
curtrialsacInfo=cat(1,saccadeInfo(trial,:));

% 
% ecodeout = sessiondata.allcodes(trial,:); 
% keepvalues=size(ecodeout,2);
% while isnan(ecodeout(keepvalues))
%     keepvalues=keepvalues-1;
% end
% ecodeout=ecodeout(1:keepvalues);
% 
% etimeout = sessiondata.alltimes(trial,:); 
% keepvalues=size(etimeout,2);
% while isnan(etimeout(keepvalues))
%     keepvalues=keepvalues-1;
% end
% etimeout=etimeout(1:keepvalues);
% 
% spkchan = sessiondata.allspkchan(trial,:);
% 
% spk = sessiondata.allspk(trial,:);
% keepvalues=size(spk,2);
% while isnan(spk(keepvalues))
%     keepvalues=keepvalues-1;
% end
% spk=spk(1:keepvalues);
% 
% arate = sessiondata.allrates(trial,:);
% 
% h = sessiondata.allh( trial,:); 
% keepvalues=size(h,2);
% while isnan(h(keepvalues))
%     keepvalues=keepvalues-1;
% end
% h=h(1:keepvalues);
% 
% v = sessiondata.allv( trial,:); 
% keepvalues=size(v,2);
% while isnan(v(keepvalues))
%     keepvalues=keepvalues-1;
% end
% v=v(1:keepvalues);
% 
% start_time = sessiondata.allstart(trial,:);
% badtrial = sessiondata.allbad(trial,:);
% curtrialsacInfo=cat(1,sessiondata.saccadeInfo(trial,:));
    