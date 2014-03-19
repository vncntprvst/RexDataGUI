function [success,outliers,curtasktype] = rex_process_inGUI( rexname, rawdir, reprocess )

% [success] = rex_process_inGUI( rexname, monkeydir )
%
% Given the name of some Rex data files (the A and E files,
% without the ‘A’ or ‘E’ on the end), attempts a conversion of this data
% into a Matlab file that contains all spike, code, saccade, and other
% data.  Allows the optional import of a Dex D file for saccade times.
% Data is written to a ‘.mat’ file using the name of the Rex files
% given.  (Thus ‘mineA’ and ‘mineE’ become ‘mine.mat’.)  This function
% can be called explicitly, but it is also called by rex_load_processed
% if that function cannot find an already converted Rex/Matlab file of
% the given name.  Returns 1 if successful, 0 if not.
% See also rex_load_processed and rex_save.
%
% global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums ...
%     allcodes alltimes allspkchan allspk allrates ...
%     allh allv allstart allbad alldeleted allsacstart allsacend...
%     allcodelen allspklen alleyelen allsaclen allrexnotes;
clearvars -global -except directory slash unprocfiles tasktype replacespikes triggertimes spike2times clustercodes;
global saccadeInfo tasktype slash replacespikes directory;
saccadeInfo=struct('status',[],'starttime',[],'endtime',[],'duration',[],'amplitude',[],...
    'direction',[],'peakVelocity',[],'peakAcceleration',[],'latency',[]);

if nargin<3
    reprocess=0;
end

if ~reprocess
    tasktype='';
end

includeaborted = 1;
slopethreshold = 0.025;
minwidth = 5;

allcodes = [];
alltimes = [];
allspkchan = [];
allspk = [];
allrates = [];
allh = [];
allv = [];
allstart = [];
allbad = [];
alltrigin=[];
alltrigout=[];
allrew=[];
alldeleted = [];
allsacstart = [];
allsacend = [];
alloriginaltrialnums = [];
allnewtrialnums = [];
hmarks = [];
vmarks = [];
success = 0;
usedexfile = 0;

wb = waitbar( 0, 'Reading Rex data...' );
set(wb,'position',[50 50 270.0000 56.2500]); %bottom left of the screen, not right in the middle
rez = 'No';
% rez = questdlg( 'Is there a DEX "D" file containing markers that you would like to load for this REX data?',...
%     'Converting REX data', 'No' );
if strcmp( rez, 'Cancel' )
    close( wb );
    return;
end;
if strcmp( rez, 'Yes' )
    [dfile, ddir] = uigetfile( '*.*', 'Select a DEX file' );
    if isequal( dfile, 0 ) || isequal( ddir, 0 )
        errordlg( 'No DEX file was selected.', 'Converting REX data', 'modal' );
        close( wb );
        return;
    elseif ~exist( fullfile( ddir, dfile ) )
        errordlg( 'The selected DEX file does not exist.', 'Converting REX data', 'modal' );
        close( wb );
        return;
    else
        waitbar( 0.05, wb );
        [hmarks,vmarks] = dex_load_marks( fullfile( ddir, dfile ), wb );
        usedexfile = 1;
    end;
end;

%% Radu: if replacespikes, load data for it
if replacespikes
%name = rexname(2:end);
monkeydirselected=get(get(findobj('Tag','monkeyselect'),'SelectedObject'),'Tag');
if strcmp(monkeydirselected,'sixxselect')
load([directory 'Sixx' slash 'Spike2Exports' slash rexname 's.mat']);
load([directory 'Sixx' slash 'Spike2Exports' slash rexname 't.mat']);
elseif strcmp(monkeydirselected,'rigelselect')
load([directory 'Rigel' slash 'Spike2Exports' slash rexname 's.mat']);
load([directory 'Rigel' slash 'Spike2Exports' slash rexname 't.mat']);
elseif strcmp(monkeydirselected,'hildaselect')
load([directory 'Hilda' slash 'Spike2Exports' slash rexname 's.mat']);
load([directory 'Hilda' slash 'Spike2Exports' slash rexname 't.mat']); 
elseif strcmp(monkeydirselected,'shufflesselect')
load([directory 'Shuffles' slash 'Spike2Exports' slash rexname 's.mat']);
load([directory 'Shuffles' slash 'Spike2Exports' slash rexname 't.mat']); 
end
% find which channel contains the data ( H53L5A5_20901_Ch7.title = nw-801)
varlist=who; %list variables
varlist=varlist(~cellfun(@isempty,strfind(varlist,rexname))); %restrict to the ones that start with the file name (the ones just loaded)
A = [cellfun(@(x) eval([x '.title']), varlist,'UniformOutput',false)];
A(strcmp(A, 'trig')) = cellstr('trigger'); % rename trigs to triggers
A(strcmp(A, '')) = cellstr('trigger'); % rename blanks to triggers
eval(['data = ' cell2mat(varlist(cellfun(@isempty,strfind(A,'trigger'))))]); 
global clustercodes
clustercodes = data.codes(:,1);
clus_names = unique((clustercodes(clustercodes ~= 0)));
howmanyclus = max(clus_names);
allspk_clus = cell(howmanyclus,1);
for a = 1:howmanyclus
    allspk_clus{a} = [];
end

global save_rexname % replaceecodes2 needs to call it
save_rexname = rexname;

else
    howmanyclus = 1;
    clus_names = 1;
    allspk_clus = cell(1,1);
    allspk_clus{1} = [];
end

next = 1;
channel = -1;
nt = rex_numtrials_raw( rexname, includeaborted ); %rawdir
%nt = rex_numtrials_fake( rexname, includeaborted );
%% trialnumber is the trial # from the recorded file. Some may be discarded in this loop. next is the resulting trial number
for trialnumber = 1:nt
    try
        [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial, analog_time] = rex_trial_raw(rexname, trialnumber, includeaborted, reprocess); %rawdir
        if reprocess
            reprocess=0; %unnecessary after 1st call to rex_trial_raw
        end
    catch
        errmess= sprintf('file %s could not be processed at trial %d. Terminate processing',rexname, trialnumber);
        disp(errmess);
        return;
    end
    
    if  strcmp(tasktype,'optiloc') && logical(sum(find(ecodeout==16386)))
        badtrial=1;
    end
    if  strcmp(tasktype,'st_saccades') && logical(sum(find(ecodeout==16386)))
        if diff(find(ecodeout==16386 | ecodeout==17385),1)==1 %just making that's the right configuration
            ecodeout(ecodeout==17385)=16386; %became obsolete
        end
    end
    %[ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial ] = rex_trial_fake(rexname, trialnumber, includeaborted);
    if length(badtrial)>1 %rare event: two identical error code in the same trial
        secbadtrltime=badtrial(2)-analog_time;
        figure;
        plot(h,'r');
        hold on; plot(v,'g');
        plot(badtrial-analog_time,8,'*-k');
        plot(etimeout([2 4 5]),8,'*b'); % if token task, these are the
        % basecode, fixation display and
        % eye in window respectively (if
        % it goes to that point)
        badtrial=badtrial(1);
    end
    
    if isempty(h) || isempty(ecodeout)
        disp( 'rex_process_inGUI.m:  Something wrong with trial, no data.  The trial will be skipped, and trial numbers will shift in the converted file to reflect this.' );
        %     elseif badtrial && ~includeaborted
        %         disp( 'rex_process.m:  Skipping bad trial.' );
    else
        allcodes = cat_variable_size_row( allcodes, ecodeout );
        alltimes = cat_variable_size_row( alltimes, etimeout );
        %allcodelen( next ) = length( ecodeout ); %perfectly unnecessary
        if isempty( spkchan )
            s = sprintf( 'rex_process.m:  No neural spike data found for trial %d (converted trial # %d), but including anyway.', trialnumber, next );
            disp( s );
            spk{1} = 0;
            spkchan = 1;
        end;
        %%
        %  Kloodge, because all this stuff only deals with one channel at a
        %  time.  If there are more than one channel, the user is asked
        %  which one to convert.  Multiple conversions can be done, but the
        %  original A and E files should be renamed first (to avoid
        %  overwriting the result.
        
        %  Once a channel is picked, we don't want to do it again for each
        %  trial.
        
        szspk = length( spkchan );
        if ( szspk > 1 && channel == -1)
            while ( channel < 1 || channel > szspk )
                %                 sp = sprintf( 'There are %d spike channels in this file.  \nPick one for this translation (1 - %d).', szspk, szspk );
                %                 prompt = {sp};
                %                 name='Kloodgy spike channel picking...';
                %                 numlines=1;
                %                 defaultanswer={'1'};
                %
                %                 answer = inputdlg( prompt, name, numlines, defaultanswer );
                %                 channel = answer{:};

                channel=1;
                rex_process_channelpicked = channel;
            end;
        elseif szspk ==1
            %for processing only files with >1 channels:
            %return
            channel = 1;
        end;
        %%
        %  The following should only happen if a channel > 1 is picked, but
        %  we hit a trial that has fewer spike channels.  Hopefully Rex is
        %  not stupid enough to do this.
        
        if (channel > szspk)
            allspkchan( next ) = 1;
            allspk = cat_variable_size_row( allspk, 0 );
            allspklen( next ) = 0;
            allrates( next ) = 0;
        else
            allspkchan( next ) = spkchan( channel );
            allspk = cat_variable_size_row( allspk, spk{channel} );
            allspklen( next ) = length( spk{channel} );
            allrates( next ) = arate;
        end;
        allh = cat_variable_size_row( allh, h );
        allv = cat_variable_size_row( allv, v );
        
        for  a = 1:howmanyclus
            if ~isempty(spk{a})
            allspk_clus{a} = cat_variable_size_row(allspk_clus{a},spk{a});
            else
            allspk_clus{a} = cat_variable_size_row(allspk_clus{a},nan);
            end
        end
        
        %alleyelen( next ) = length( h );
        allstart(next) = start_time;
        %collect absolute times for bad trials, trigger and reward
        allbad(next) = badtrial;
        alltrigin(next)=etimeout(find(ecodeout==1001,1))+analog_time-1; %-1 to align with first trigger (useless if no trigger channel
        if find(ecodeout==1502)
            alltrigout(next)=etimeout(find(ecodeout==1502,1))+analog_time; % the second 1502 in ecodes is actually the one for the next trial
        else
            if find(ecodeout==1030,1)
                alltrigout(next)=etimeout(find(ecodeout==1030,1))+analog_time; % if no trigger code, then use reward time
            else
                alltrigout(next)=NaN; %nothing to align bad trials on recordings without trigger channel to
            end
        end
        if find(ecodeout==1030,1)
            allrew(next)=etimeout(find(ecodeout==1030,1))+analog_time;
        else
            allrew(next)=NaN;
        end
        alldeleted( next ) = 0;
        %%
        %  Find saccades, either from a DEX file, or by using the
        %  find_saccades function.  If there is a DEX file, but no marks
        %  for this trial, also call the find_saccades function.
        
        %         sstarts = 2000; % WHAT IS THAT ???? Was there in the archive file
        %         sends = 3500;
        markedsaccades = 0;
        if usedexfile % obsolete method, could be discarded
            [sstarts, sends] = dex_find_saccades_from_marks( trialnumber, hmarks, vmarks );
            
            if ~isempty( sstarts )
                markedsaccades = 1;
                s = sprintf( 'rex_process.m:  Saccades for trial %d (converted trial # %d) were found using DEX marks in %s file,', trialnumber, next, dfile );
                disp( s );
            end;
        end;
        if ~markedsaccades
            [sstarts, sends, eddhv] = find_saccades( h, v, minwidth, slopethreshold );
            f = find( sstarts == 0);
            if ~isempty( f )
                s = sprintf( 'rex_process:  A saccade start time came back 0 in trial %d (converted trial # %d).', trialnumber, next );
                disp( s );
            end;
        end;
        
        %% new saccade detection
        
        % Calculate velocity and acceleration
        % Input horizontal and vertical velocity vectors, plus saccade duration
        % window in ms.
        % Output filtered position, velocity and acceleration plus unfiltered velocity.
        % Unfiltered velocity (nativevel) is used for noise detection.
        %------------------------------------
        
        [filth, filtv, filtvel, filtacc, nativevel, nativeacc] = cal_velacc(h,v,minwidth);
        
        % Detect noise
        % Vestigial processing from eye tracking data analysis. (=no blinks for eye
        % coil)
        % Might come in handy for future setups
        % For the moment, only minimal processing to remove noise
        %-------------------------------------
        
        VelocityThreshold = 1.5;     %peak velocity is almost never more than 1000deg/s, so if vel > 1.5 deg/ms, it is noise (or blinks for eye tracker)
        AccThreshold = 0.1;          %if acc > 100000 degrees/s^2, that is 0.1 deg/ms^2, it is noise (or blinks)
        
        noisebg= median(nativevel)*2;
        
        % Detect possible noise (if the eyes move too fast)
        noiseIdx = nativevel> VelocityThreshold | abs(filtacc) > AccThreshold;
        %label groups of noisy data
        noiselabels = bwlabel(noiseIdx);
        
        % Process one noise period at the time
        for k = 1:max(noiselabels)
            
            % The samples related to the current event
            noisyperiod = find(noiselabels == k);
            
            % Go back in time to see where the noise started
            sEventIdx = find(nativevel(noisyperiod(1):-1:1) <= noisebg);
            if isempty(sEventIdx), continue, end
            sEventIdx = noisyperiod(1) - sEventIdx(1) + 1;
            noiseIdx(sEventIdx:noisyperiod(1)) = 1;
            
            % Go forward in time to see where the noise ended
            eEventIdx = find(nativevel(noisyperiod(end):end) <= noisebg);
            if isempty(eEventIdx), continue, end
            eEventIdx = (noisyperiod(end) + eEventIdx(1) - 1);
            noiseIdx(noisyperiod(end):eEventIdx) = 1;
            
        end
        
        %then correct if possible
        noiselabels = bwlabel(noiseIdx);
        
        %str = sprintf('found %d noise periods in trial #%d', max(noiselabels), next);
        %disp(str);
        
        % Process one noise period at the time
        for k = 1:max(noiselabels)
            
            % The samples related to the current event
            noisyperiod = find(noiselabels == k);
            
            % in case it's only filtvel that has outliers, correct them
            if median(filtvel(noisyperiod(1):noisyperiod(end)))> VelocityThreshold && median(nativevel(noisyperiod(1):noisyperiod(end)))< VelocityThreshold
                filtvel(noisyperiod(1):noisyperiod(end)) = median(nativevel(noisyperiod(1):noisyperiod(end)));
                noiseIdx(noisyperiod(1):noisyperiod(end)) = 0;
                %disp('noise was in filtered velocity data, corrected');
            else
                %disp('noise in raw data, left uncorrected');
            end
        end
        
        %     if logical(sum(noiseIdx))
        %     snoisearea = find(diff(noiseIdx) > 0);
        %     enoisearea = find(diff(noiseIdx) < 0);
        %     if isempty(snoisearea) || snoisearea(1) > enoisearea(1) % plot is shaded from start
        %         snoisearea = [1 snoisearea];
        %     end
        %     if isempty(enoisearea) || snoisearea(end) > enoisearea(end) % plot is shaded until end
        %         enoisearea = [enoisearea length(noiseIdx)];
        %     end
        %     end
        %
        % iteratively find the optimal noise threshold
        %---------------------------------------------
        minfixwidth = 40; %minimum fixation duration
        
        peakDetectionThreshold = 0.1;     % Initial value of the peak detection threshold. Final value typically around 0.47
        oldPeakT = inf;
        while abs(peakDetectionThreshold -  oldPeakT) > 1 % will iterate until reach consensus value
            
            oldPeakT  = peakDetectionThreshold;
            
            % Detect velocity peaks larger than a threshold ('peakDetectionThreshold')
            % Sets a '1' where the velocity is larger than the threshold and '0' otherwise
            
            InitialVelPeakIdx  = (filtvel > peakDetectionThreshold);
            
            % Find fixation noise level and calculate peak velocity threshold
            [peakDetectionThreshold, saccadeVelocityTreshold, velPeakIdx] = rex_detectFixationNoiseLevel(minfixwidth,InitialVelPeakIdx,filtvel);
            
        end
        
        % New saccade detection methode (with peak detection threshold (v <
        % v_avg_noise + 3*v_std_noise)) (original code also detected glissades)
        %-------------------------------------
        %  s = sprintf('trial %d',next);
        %   disp(s);
        %note that the trial number given to find_saccades_3 is 'next', not
        %'trialnumber'
        
%         if next==109
%             next
%         end
        
        [saccadeInfo, saccadeIdx] = find_saccades_3(next,filtvel,filtacc,velPeakIdx,minwidth,minfixwidth,saccadeVelocityTreshold,peakDetectionThreshold,filth,filtv);
        
        %% check for missed saccade, if old method has found a correct saccade that the new one missed
        % and add latency! 
        clear ampsacofint sacofint newsacs;
        if isfield(saccadeInfo, 'starttime')
            nwsacstart=cat(1,saccadeInfo(next,:).starttime);
        else
            nwsacstart=0;
        end
        
        [curtasktype, ecodecueon, ecodesacstart, ecodesacend]=taskdetect(ecodeout);
        if strcmp(curtasktype,'reproc')
            close(wb);
            [success,outliers,curtasktype]=rex_process_inGUI( rexname, rawdir, 1); %last argument is for reprocessing file
            return;
        end
        if (strcmp(curtasktype,'tokens') || strcmp(curtasktype,'periodCmd')) && logical(sum(ecodecueon)) %multiple cues
            allcues=ecodecueon; %keep it for later
            ecodecueon=ecodecueon(end); %for the moment only keep the last one
        end
        codefound=sum(ecodecueon & ecodesacstart & ecodesacend);
        if codefound
            if numel(etimeout)<ecodesacstart-1
                sacofint=0;
            else
                sacofint=nwsacstart>etimeout(ecodesacstart-1); %considering all saccades occuring after the ecode
                %preceding the saccade ecode, which is often erroneous
                if strcmp(curtasktype,'gapstop') && find(ecodeout==1503)
                    sacofint=nwsacstart>etimeout(ecodesacstart-2);
                elseif strcmp(curtasktype,'periodCmd') && ecodeout(ecodesacstart-1)==17385
                % subject maintained fixation beyond alloted time window to
                % make saccade, or broke fixation
                    sacofint=nwsacstart>etimeout(ecodesacstart-2);
                end
            end
        else
            sacofint=0;
        end
        
        for k=find(sacofint,1):length(sacofint)
            ampsacofint(1,k)=abs(getfield(saccadeInfo, {next,k}, 'amplitude'));
        end
        if exist('ampsacofint') & find(ampsacofint>2.5,1)
            goodsac(next)=find(ampsacofint>2.5,1);
            saccadeInfo(next,find(ampsacofint>2.5,1)).latency=saccadeInfo(next,find(ampsacofint>2.5,1)).starttime-etimeout(ecodecueon);
        end
        
        if logical(sum(length(etimeout)<ecodesacstart+2)) || ~codefound || ~isfield(saccadeInfo, 'starttime') || isempty(saccadeInfo(next).starttime)
            %then don't bother looking for saccades
            goodsac(next)=0;
        elseif  ~exist('ampsacofint') || nwsacstart(find(sacofint,1))>etimeout(ecodesacstart+2) || ~logical(sum(ampsacofint>3)) %meaning: no saccade detected after that event, or very late
            
            if logical(sum(sstarts>etimeout(ecodesacstart-1))) && sstarts(find(sstarts>etimeout(ecodesacstart-1),1))<etimeout(ecodesacstart+1)+110 && ...
                    sstarts(find(sstarts>etimeout(ecodesacstart-1),1))-sends(find(sstarts>etimeout(ecodesacstart-1),1))<75 %check if there are suitable saccades detected by former method
                nwsacofint=find(sstarts>etimeout(ecodesacstart-1),1);
                ampsacofint=sqrt((h(sstarts(nwsacofint))-h(sends(nwsacofint)))^2 + ...
                    (v(sstarts(nwsacofint))-v(sends(nwsacofint)))^2);
                %making some room
                saccadeInfo(next,find(sacofint,1)+1:(find(sacofint,1)+sum(sacofint)))=saccadeInfo(next,find(sacofint,1):(find(sacofint,1)+sum(sacofint)-1));
                if ~isempty(find(sacofint,1))
                    newpeak=find(sacofint,1);
                else
                    newpeak=length(sacofint)+1;
                end
                %instead of replacing with old method saccade,
                %alternatively reanalysis the given segment with higher
                %noise threshold
                excs=sstarts(nwsacofint)-25;%start excerpt
                exce=sends(nwsacofint)+25; %end excerpt
                sacfound = find_saccades_excerpt(next,newpeak,excs,exce,filtvel(excs:exce),filtacc(excs:exce),minwidth,minfixwidth,saccadeVelocityTreshold,peakDetectionThreshold,filth(excs:exce),filtv(excs:exce));
                if ~sacfound
                    saccadeInfo(next,newpeak).starttime = sstarts(nwsacofint); % replace find(sacofint,1,'first') with length(sacofint)+1
                    saccadeInfo(next,newpeak).endtime = sends(nwsacofint);
                    saccadeInfo(next,newpeak).duration = saccadeInfo(next,newpeak).endtime - ...
                        saccadeInfo(next,newpeak).starttime;
                    if filth(sends(nwsacofint))>filth(sstarts(nwsacofint))%leftward negative, inverted signal
                        ampsacofint=-ampsacofint;
                    end
                    saccadeInfo(next,newpeak).amplitude = ampsacofint;
                    saccadeInfo(next,newpeak).peakVelocity = max(filtvel(sstarts(nwsacofint):sends(nwsacofint)));
                    saccadeInfo(next,newpeak).peakAcceleration = max(filtacc(sstarts(nwsacofint):sends(nwsacofint)));
                    saccadeInfo(next,newpeak).status='saccade';
                    saccadeInfo(next,newpeak).latency=saccadeInfo(next,newpeak).starttime-etimeout(ecodecueon);
                    
                    goodsac(next)=newpeak;
                elseif sacfound
                    goodsac(next)=newpeak; %information filling already taken cared of by find_saccades_excerpt
                    saccadeInfo(next,newpeak).latency=saccadeInfo(next,newpeak).starttime-etimeout(ecodecueon);
                end
            else
                goodsac(next)=0;
            end
        end
        
        %% detect actual direction of "good" sac for each trial
        
        %         try
        %             lasac=find(~cellfun(@isempty,{saccadeInfo(next,:).latency}));
        %             lasach=allh(next,saccadeInfo(next,lasac).starttime:saccadeInfo(next,lasac).endtime);
        %             lasacv=allv(next,saccadeInfo(next,lasac).starttime:saccadeInfo(next,lasac).endtime);
        %             sacdeg=atand((lascv(end)-lascv(1))/(lasch(end)-lasch(1)));
        %             if (lasch(end)-lasch(1))<1
        %                 sacdeg=sacdeg+180;
        %             end
        %             saccadeInfo(next,lasac).direction=sacdeg;
        %         catch
        %         end
        
        
        %% back to old code, pre-processing stage, still within the loop
        
        saclen = length( sstarts );
        if isempty( sstarts )
            sstarts = [0];
            sends = [0];
        end;
        
        allsacstart = cat_variable_size_row( allsacstart, sstarts );
        allsacend = cat_variable_size_row( allsacend, sends );
        allsaclen( next ) = saclen;
        alloriginaltrialnums( next ) = trialnumber;
        allnewtrialnums( next ) = next;
        
        if isempty(char(saccadeInfo(:,end).status))
            disp('last column empty');
            break;
        end
        next = next + 1;
    end;
    waitbar( (trialnumber/nt)*0.9, wb, 'Converting Rex data...' );
end;

%% data clinic
if strcmp(tasktype,'gapstop') || strcmp(tasktype,'optiloc')
    if strcmp(tasktype,'gapstop') % fix potentially wrong dir in gapstop recording
        cure='fixdircs';
    elseif strcmp(tasktype,'optiloc')  % fix directions for optimal location task
        cure='fixdirol';
    end
    allcodes=dataclinic(cure,allcodes,saccadeInfo,allbad);
end

%% detect ouliers

%first make sure the trials as dected without good saccades are in wrong
%trials
if ~exist('goodsac')
    %not even one recorded trial
    success = 0;
    outliers = 0;
    curtasktype='unspecified';
    return
end

if ~isequal((logical(allbad) & (~goodsac)),~goodsac)
    disp('mismatch in saccade detection and wrong trials')
    mismatch=find((~goodsac)~= (logical(allbad) & (~goodsac)));
else
    mismatch=0;
end

amps=nan(size(goodsac));
lats=amps;
durs=amps;
sactocomp=find(goodsac);

for l=1:length(sactocomp)
    amps(1,sactocomp(l))=getfield(saccadeInfo, {sactocomp(l),goodsac(sactocomp(l))}, 'amplitude');
    lats(1,sactocomp(l))=getfield(saccadeInfo, {sactocomp(l),goodsac(sactocomp(l))}, 'latency');
    durs(1,sactocomp(l))=getfield(saccadeInfo, {sactocomp(l),goodsac(sactocomp(l))}, 'duration');
end

ampoutlier=abs(amps(~isnan(amps)))>=mean(abs(amps(~isnan(amps))))+2*std(abs(amps(~isnan(amps))));
latoutlier=lats(~isnan(lats))>=mean(lats(~isnan(lats)))+2*std(lats(~isnan(lats)));
duroutlier=durs(~isnan(durs))>=median(durs(~isnan(durs)))+2*std(durs(~isnan(durs))); %WARNING: works here because very typical durations

%reconvert to original trial number (not discounting NaNs)
ampoutlier=sactocomp(ampoutlier);
latoutlier=sactocomp(latoutlier);
duroutlier=sactocomp(duroutlier);

outliers=[ampoutlier,latoutlier,duroutlier];
outliers=sort(outliers);
outliers=unique(outliers);

outlandmismtch(1)={mismatch};
outlandmismtch(2)={outliers};

%% saving data
%archst  = computer('arch');

if logical(regexpi(rawdir(1:end-1),'Rigel$'))
    if strcmp(getenv('username'),'nick')
        procdir='/Users/nick/Dropbox/filesforNick/processed/Rigel/';
    elseif strcmp(getenv('username'),'SommerVD') ||...
            strcmp(getenv('username'),'LabV')||...
            strcmp(getenv('username'),'Ramanujan')||...
            strcmp(getenv('username'),'JuanandKimi') || ...
            strcmp(getenv('username'),'vp35')
        procdir='C:\Data\Recordings\processed\Rigel\';
    elseif strcmp(getenv('username'),'DangerZone')
        procdir='E:\Data\Recordings\processed\Rigel\';
    elseif strcmp(getenv('username'),'Radu')
        procdir = 'E:\Spike_Sorting\processed\Rigel\';
    elseif strcmp(getenv('USER'),'zacharyabzug')
        procdir = '/Users/zacharyabzug/Desktop/zackdata/processed/Rigel/';
    elseif strcmp(getenv('USER'),'zmabzug')
        procdir = '/Users/zmabzug/Desktop/zackdata/processed/Rigel/';
    elseif strcmp(getenv('username'),'The Doctor')
        procdir = 'C:\Users\The Doctor\Data\processed\Rigel\';
    else
        procdir='B:\data\Recordings\processed\Rigel\';
    end
    if ~strcmp(rexname(1),'R')
        rexname=cat(2,'R',rexname);
    end
    if replacespikes
        rexname=cat(2,rexname,'_Sp2');
    else
        rexname=cat(2,rexname,'_REX');
    end  
elseif logical(regexpi(rawdir(1:end-1),'Sixx$'))
    if strcmp(getenv('username'),'nick')
        procdir='/Users/nick/Dropbox/filesforNick/processed/Sixx/';
    elseif strcmp(getenv('username'),'SommerVD') ||....
            strcmp(getenv('username'),'LabV')||...
            strcmp(getenv('username'),'Ramanujan')||...
            strcmp(getenv('username'),'JuanandKimi') || ...
            strcmp(getenv('username'),'vp35')
        procdir='C:\Data\Recordings\processed\Sixx\';
    elseif strcmp(getenv('username'),'DangerZone')
        procdir='E:\Data\Recordings\processed\Sixx\';
    elseif strcmp(getenv('username'),'Radu')
        procdir = 'E:\Spike_Sorting\processed\Sixx\';
    elseif strcmp(getenv('USER'),'zacharyabzug')
        procdir = '/Users/zacharyabzug/Desktop/zackdata/processed/Sixx/';  
    elseif strcmp(getenv('USER'),'zmabzug')
        procdir = '/Users/zmabzug/Desktop/zackdata/processed/Sixx/'; 
    elseif strcmp(getenv('username'),'The Doctor')
        procdir = 'C:\Users\The Doctor\Data\processed\Sixx\';
    else
        procdir='B:\data\Recordings\processed\Sixx\';
    end
    if ~strcmp(rexname(1),'S')
        rexname=cat(2,'S',rexname);
    end
    if replacespikes
        rexname=cat(2,rexname,'_Sp2');
    else
        rexname=cat(2,rexname,'_REX');
    end  
elseif logical(regexpi(rawdir(1:end-1),'Hilda$'))
    if strcmp(getenv('username'),'nick')
        procdir='/Users/nick/Dropbox/filesforNick/processed/Hilda/';
    elseif strcmp(getenv('username'),'SommerVD') ||...
            strcmp(getenv('username'),'LabV')||...
            strcmp(getenv('username'),'Ramanujan')||...
            strcmp(getenv('username'),'JuanandKimi') || ...
            strcmp(getenv('username'),'vp35')
        procdir='C:\Data\Recordings\processed\Hilda\';
    elseif strcmp(getenv('username'),'DangerZone')
        procdir='E:\Data\Recordings\processed\Hilda\';
    elseif strcmp(getenv('username'),'Radu')
        procdir = 'E:\Spike_Sorting\processed\Hilda\';
    elseif strcmp(getenv('USER'),'zacharyabzug')
        procdir = '/Users/zacharyabzug/Desktop/zackdata/processed/Hilda/'; 
    elseif strcmp(getenv('USER'),'zmabzug')
        procdir = '/Users/zmabzug/Desktop/zackdata/processed/Hilda/'; 
    elseif strcmp(getenv('username'),'The Doctor')
        procdir = 'C:\Users\The Doctor\Data\processed\Hilda\';
    else
        procdir='B:\data\Recordings\processed\Hilda\';
    end
    if ~strcmp(rexname(1),'H')
        rexname=cat(2,'H',rexname);
    end
    if replacespikes
        rexname=cat(2,rexname,'_Sp2');
    else
        rexname=cat(2,rexname,'_REX');
    end
elseif logical(regexpi(rawdir(1:end-1),'Shuffles$'))
    if strcmp(getenv('username'),'nick')
        procdir='/Users/nick/Dropbox/filesforNick/processed/Shuffles/';
    elseif strcmp(getenv('username'),'SommerVD') ||...
            strcmp(getenv('username'),'LabV')||...
            strcmp(getenv('username'),'Ramanujan')||...
            strcmp(getenv('username'),'JuanandKimi') || ...
            strcmp(getenv('username'),'vp35')
        procdir='C:\Data\Recordings\processed\Shuffles\';
    elseif strcmp(getenv('username'),'DangerZone')
        procdir='E:\Data\Recordings\processed\Shuffles\';
    elseif strcmp(getenv('username'),'Radu')
        procdir = 'E:\Spike_Sorting\processed\Shuffles\';
    elseif strcmp(getenv('USER'),'zacharyabzug')
        procdir = '/Users/zacharyabzug/Desktop/zackdata/processed/Shuffles/';  
    elseif strcmp(getenv('USER'),'zmabzug')
        procdir = '/Users/zmabzug/Desktop/zackdata/processed/Shuffles/'; 
    elseif strcmp(getenv('username'),'The Doctor')
        procdir = 'C:\Users\The Doctor\Data\processed\Shuffles\'; 
    else
        procdir='B:\data\Recordings\processed\Shuffles\';
    end
    if ~strcmp(rexname(1),'S')
        rexname=cat(2,'S',rexname);
    end
    if replacespikes
        rexname=cat(2,rexname,'_Sp2');
    else
        rexname=cat(2,rexname,'_REX');
    end      
end

newname = cat( 2, procdir, rexname, '.mat' );
s = sprintf('Writing converted Rex data to %s.', cat(2,rexname,'.mat'));
waitbar( 0.9, wb, s );
%rexloadedname = rexname;
rexnumtrials = next -1; %nt;

allrexnotes = sprintf( '%s, converted on %s\n%d trials\n', rexname, datestr( now ), rexnumtrials );
disp(allrexnotes);
save( newname, 'rexname', 'rexnumtrials', 'alloriginaltrialnums', 'allnewtrialnums',...
    'allcodes', 'alltimes', 'allspkchan', 'allspk', 'allspk_clus', 'allrates', 'allh', 'allv', 'allstart',...
    'allbad', 'alltrigin', 'alltrigout', 'allrew', 'alldeleted', 'allsacstart', 'allsacend',...
    'allspklen', 'allsaclen', 'allrexnotes', 'saccadeInfo','outlandmismtch','-v7.3'); %using '-v7.3' input arguments so that matfile loading runs well when retrieving data from file
%removed allcodelen and alleyelen. allspklen should go too, and allrates be included
%elsewhere


%%
success = 1;
clearvars -global -except directory slash unprocfiles replacespikes spike2times clustercodes triggertimes;
close( wb );

%% graphic verif if any bug:
% sacfound=zeros(size(saccadeInfo));
% for i=1:length(saccadeInfo)
% thattrial=char(saccadeInfo(i,:).status);%=cat(1,saccadeInfo(i,:).starttime);
% for j=1:min(size(saccadeInfo))
%     sacfound(i,j)=~isempty(deblank(thattrial(j,:)));
%     if strcmp('saccade',deblank(thattrial(j,:)))
%         sacfound(i,j)=2*(strcmp('saccade',deblank(thattrial(j,:))));
%     end
%     %sacfound(i,1:length(thattrial))=thattrial;
% end
% end
% % Create figure
% figure21 = figure('Color',...
%     [0.800000011920929 0.800000011920929 0.800000011920929]);
% colormap('copper');
%
% % Create axes
% axes21 = axes('Parent',figure21,'PlotBoxAspectRatio',[1 1 1],...
%     'DataAspectRatio',[12.5 60 1],...
%     'CameraViewAngle',5.33243073393796);
% view(axes21,[0.5 -90]);
% grid(axes21,'on');
% hold(axes21,'all');
%
% % Create surf
% surf(sacfound,'Parent',axes21,'DisplayName','sacfound');
