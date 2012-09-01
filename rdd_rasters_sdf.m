function datalign = rdd_rasters_sdf(rdd_filename, trialdirs, plotrasts, dostats, showstats)
% rdd_rasters_sdf(rdd_filename, tasktype, trialdirs)
% display subplots of rasters and sdf overlayed

%% ecodes
%
% Basic codes for all tasks (see ecode.h):
%
% ADATACD	-112	pointer into the analog data file
% ENABLECD	1001 	put at the start of every trial
% PAUSECD	1003	paradigm stop code, when paused?
% STARTCD	1005	appears a bit before 1001 each trial
% LISTDONECD	1035	ecode.h says this is “ramp list has completed”.  Whatever it is, it appears between 1005 and 1001 at the beginning of each trial.
%
% WOPENCD	800
% WCLOSECD	801	data window was closed
% WCANCELCD	802	data window was cancelled
% WERRCD	803	error aborted current window
% UWOPENCD	804
% UWCLOSECD	805
% WOPENERRCD	806	attempt to open a window while window is already open
%
% FPOFFCD	1025	Offset all objects at the end of trial
%
% 17385	Bad or aborted trial.

% Self timed saccade task
% (602y like memory-guided, but with additional ERR2CD in addition to ERR1CD distinguish)
%
% 1001		ENABLECD
% 602y		Basecode
% 622y		Onset fix target
% 642y		Eye in window
% 662y		Flash of cue light
% 682y		Cue turned off
% 702y		Rex detected saccade onset
% 722y		Eye is now in target window
% 742y		Re-display target after correct trial
% 1025		FPOFFCD
% 1030		REWCD

% Gapstop (base code 604y or 407y, depending on condition).
% Remember that left sac were initially coded with 6047, before being
% corrected to 6046 (same thing for gapstop)
% 624y / 427y		Fixation cue
% 704y / 507y		Saccade onset or fixation point reappearance

% Optiloc (base code 601y)
%
% 621y		Fixation cue
% 661y		Offset of fixation light (basically follows gap task, with 0 gap)
% 681y		Target Cue light
% 701y		Saccade Onset
% 1025			FPOFFCD

% Visually-guided saccades:
%
% 60xy (ex: 6011)	Start of the specific task (task indicated by paradigm code x and
% direction y)
% 62xy		fixation point has been turned on
% 64xy		eyes have started fixating on the fixation point
% 66xy		the fixation point has been turned off
% 68xy		cue was turned on
% 70xy		saccade started (assuming SF_ONSET is being checked, see line 1687)
% 72xy		saccade completed but not yet checked for accuracy
% 74xy		the eye is actually in the cue/target window
% >> folowing code is REWCD

% Memory-guided:
%
% 66xy		Flash of cue/target light
% 68xy		Not sure, still fixating on fixation point, cue turned off?
% 70xy		offset of fixation point
% 72xy		Rex detected saccade onset, sometimes (?) Rex places this at the saccade offset, or some other place, and no one knows why.
% 74xy		Redundant, immediately dropped after 72xy
% 76xy		Supposedly, eye is now in target window
% 78xy		Re-display target after correct trial


%%gathering information from panels
% we need to get
%    - ecode selection (from showdirpanel panel)
%    - ecode alignment (from aligntimepanel buttons)
%    - miliseconds before alignment time (from rastplottimeval panel)
%    - miliseconds after alignment time (from rastplottimeval panel)
%    - Bin width for histogram (from rastplotvalues panel)
%    - Initial sigma for density functions (from rastplotvalues panel)
%    - include or not bad trials (from badtrialsbutton)
% default values are
%    - depend on task type and user input
%    - saccade
%    - 1000
%    - 500
%    - 20
%    - 5
%    - no
% way to proceed ?
%    secondcode = str2num( answer{ 1 } );
%    aligncodes = str2num( answer{ 2 } );
%    mstart = mstart * -1.0;
%    wb = waitbar( 0.1, 'Generating rasters...' );
global directory slash;

if nargin < 5
    showstats = 0;
end

alignsacnum=0;
alignseccodes=[];
alignlabel=[];
secalignlabel=[];
collapsecode=0;

%define ecodes according to task
%add last number for direction
tasktype=get(findobj('Tag','taskdisplay'),'String');
[fixcode fixoffcode tgtcode tgtoffcode saccode ...
    stopcode rewcode tokcode errcode1 errcode2 errcode3 basecode] = taskfindecode(tasktype);

%% get align code from selected button in Align Time panel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AlignTimePanelH=findobj('Tag','aligntimepanel');%align time panel handle
ATPSelectedButton= get(get(AlignTimePanelH,'SelectedObject'),'Tag');%selected button's tag
ATPbuttonnb=find(strcmp(ATPSelectedButton,get(findall(AlignTimePanelH),'Tag')));%converted to handle tag list's number
if  ATPbuttonnb==6 % mainsacalign button
    ecodealign=saccode;
elseif ATPbuttonnb==7 % tgtshownalign button
    ecodealign=tgtcode;
elseif ATPbuttonnb==3 % rewardnalign button
    ecodealign=rewcode;
elseif ATPbuttonnb==8 % stopsignalign button
    if ~strcmp(tasktype,'gapstop')
        %faire qqchose!!
    else
        ecodealign=stopcode;
    end
elseif ATPbuttonnb==9 % other sac align
    %made for corrective saccades in particular
    ecodealign=saccode;
    alignsacnum=1; %that is n-th saccade following the alignment code, which for now will be the main saccade.
    % to be tested
    
    %then there should be the error code button, and then listbox ecodes
end


%% second code: allow selection of second align time. For example, for gapstop
% task, one may want to display the gap trial and the stop trials together.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SAlignTimePanelH=findobj('Tag','secaligntimepanel');%align time panel handle
SATPSelectedButton= get(get(SAlignTimePanelH,'SelectedObject'),'Tag');%selected button's tag
SATPbuttonnb=find(strcmp(SATPSelectedButton,get(findall(SAlignTimePanelH),'Tag')));%converted to handle tag list's number
if  SATPbuttonnb==3 % no align button
    secondcode=[];
elseif SATPbuttonnb==4
    secondcode=errcode1;
elseif SATPbuttonnb==5
    secondcode=errcode2;
elseif SATPbuttonnb==6
    secondcode=saccode;
elseif SATPbuttonnb==7
    secondcode=tgtcode;
elseif SATPbuttonnb==8
    if ~strcmp(tasktype,'gapstop')
        %not good!
    else
        secondcode=stopcode;
    end
elseif SATPbuttonnb==9
    secondcode=saccode;
    alignsacnum=1;
end

%% Bin width for rasters and Initial sigma for density functions( from rastplotvalues panel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

binwidth= str2num(get(findobj('Tag','binwidthval'),'String'));
fsigma= str2num(get(findobj('Tag','sigmaval'),'String'));

%% Rasters start and stop times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mstart= str2num(get(findobj('Tag','msbefore'),'String'));
mstop= str2num(get(findobj('Tag','msafter'),'String'));

%% include bad trials?
%%%%%%%%%%%%%%%%%%%%%%%
includebad= get(findobj('Tag','badtrialsbutton'),'value');

%% which channel to use, in case there are multiple channels ?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(get(get(findobj('Tag','chanelspanel'),'SelectedObject'),'Tag'),'ch1button');
    spikechannel = 1;
elseif strcmp(get(get(findobj('Tag','chanelspanel'),'SelectedObject'),'Tag'),'ch2button');
    spikechannel = 2;
else
    disp('Channel not recognized. Default: Channel 1');
    spikechannel = 1;
end

%% Fusing task type and direction into ecode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (ecodealign(1))<1000 % if only three numbers
    for i=1:length(trialdirs)
        aligncodes(i,:)=ecodealign*10+trialdirs(i);
    end
else
    aligncodes=ecodealign;
end
if logical(secondcode)
    if (secondcode(1))<1000
        for i=1:length(trialdirs)
            alignseccodes(i,:)=secondcode*10+trialdirs(i);
        end
    else
        alignseccodes=secondcode;
    end
end
if length(trialdirs)>1
    basecodes=[];
    for numbasecd=1:length(basecode)
        basecodes=[basecodes;(basecode(numbasecd)*ones(length(trialdirs),1)*10)+trialdirs];
    end
else
    basecodes=basecode;
end

% default option: will display all directions separately
% strcmp(get(get(findobj('Tag','showdirpanel'),'SelectedObject'),'Tag'),'selecalldir');
% (no need to change alignment codes)

if strcmp(get(get(findobj('Tag','showdirpanel'),'SelectedObject'),'Tag'),'selecdir');
    %get the selected direction
    dirmenulist=get(findobj('Tag','SacDirToDisplay'),'String');
    dirmenuselection=get(findobj('Tag','SacDirToDisplay'),'Value');
    dirmenuselection=dirmenulist{dirmenuselection};
    
    if strcmp(dirmenuselection,'Horizontals') %remember error on initial gapstops
        codeidx=find(aligncodes-(floor(aligncodes./10).*10)==2 | aligncodes-(floor(aligncodes./10).*10)==6);
        aligncodes=aligncodes(codeidx);
        seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==2 | alignseccodes-(floor(alignseccodes./10).*10)==6);
        alignseccodes=alignseccodes(seccodeidx);
    elseif strcmp(dirmenuselection,'Verticals')
        codeidx=find(aligncodes-(floor(aligncodes./10).*10)==0 | aligncodes-(floor(aligncodes./10).*10)==4);
        aligncodes=aligncodes(codeidx);
        seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==0 | alignseccodes-(floor(alignseccodes./10).*10)==4);
        alignseccodes=alignseccodes(seccodeidx);
    elseif strcmp(dirmenuselection,'SU')
        codeidx=find(aligncodes-(floor(aligncodes./10).*10)==0);
        aligncodes=aligncodes(codeidx);
        seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==0);
        alignseccodes=alignseccodes(seccodeidx);
    elseif strcmp(dirmenuselection,'UR')
        codeidx=find(aligncodes-(floor(aligncodes./10).*10)==1);
        aligncodes=aligncodes(codeidx);
        seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==1);
        alignseccodes=alignseccodes(seccodeidx);
    elseif strcmp(dirmenuselection,'SR')
        codeidx=find(aligncodes-(floor(aligncodes./10).*10)==2);
        aligncodes=aligncodes(codeidx);
        seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==2);
        alignseccodes=alignseccodes(seccodeidx);
    elseif strcmp(dirmenuselection,'BR')
        codeidx=find(aligncodes-(floor(aligncodes./10).*10)==3);
        aligncodes=aligncodes(codeidx);
        seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==3);
        alignseccodes=alignseccodes(seccodeidx);
    elseif strcmp(dirmenuselection,'SD')
        codeidx=find(aligncodes-(floor(aligncodes./10).*10)==4);
        aligncodes=aligncodes(codeidx);
        seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==4);
        alignseccodes=alignseccodes(seccodeidx);
    elseif strcmp(dirmenuselection,'BL')
        codeidx=find(aligncodes-(floor(aligncodes./10).*10)==5);
        aligncodes=aligncodes(codeidx);
        seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==5);
        alignseccodes=alignseccodes(seccodeidx);
    elseif strcmp(dirmenuselection,'SL')
        codeidx=find(aligncodes-(floor(aligncodes./10).*10)==6);
        aligncodes=aligncodes(codeidx);
        seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==6);
        alignseccodes=alignseccodes(seccodeidx);
    elseif strcmp(dirmenuselection,'UL')
        codeidx=find(aligncodes-(floor(aligncodes./10).*10)==7);
        aligncodes=aligncodes(codeidx);
        seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==7);
        alignseccodes=alignseccodes(seccodeidx);
    end
    
elseif strcmp(get(get(findobj('Tag','showdirpanel'),'SelectedObject'),'Tag'),'seleccompall');
    collapsecode=1;
    %compile all trial directions into a single raster
    aligncodes=aligncodes'; % previously: ecodealign,  so that when
    % aligncodes was only three numbers long,
    % rdd_rasters would know it had to collapse all
    % directions together
    alignseccodes= alignseccodes'; %secondcode;
else
    disp('Selected option: all directions'); %that's the 'selecalldir' tag
    if strcmp(tasktype,'base2rem50')
        aligncodes=aligncodes';
        alignseccodes= alignseccodes';
    end
end

%% Grey area in raster
greycodes=[];
togrey=find([get(findobj('Tag','greycue'),'Value'),get(findobj('Tag','greyemvt'),'Value'),get(findobj('Tag','greyfix'),'Value')]);

if strcmp(tasktype,'gapstop') %otherwise CAT arguments dimensions are not consistent below
    saccode=[saccode saccode];
    stopcode=[stopcode stopcode];
end

conditions =[tgtcode tgtoffcode;saccode saccode;fixcode fixoffcode];

if logical(sum(togrey))
    greycodes=conditions(togrey,:); %selecting out the codes
end


%% aligning data and generating rasters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First, align data to codes
% Function rdd_rasters returns value for alignedrasters, alignindex, eyehoriz, eyevert, eyevelocity, allonofftime, trialnumbers
% Needs to be run for aech direction, and each alignment code (Unless all
% directions are collapse, or only one alignement code, etc...)

% default nonecodes. Potential conflict resolved in rdd_rasters
nonecodes=[17385 16386];

% variable to save aligned data
datalign=struct('dir',{},'rasters',{},'trials',{},'timefromtrig',{},'timetotrig',{},'alignidx',{},'eyeh',{},'eyev',{},'eyevel',{},'amplitudes',{},...
    'peakvels',{},'peakaccs',{},'allgreyareas',{},'stats',{},'alignlabel',{},'savealignname',{});
if strcmp(get(get(findobj('Tag','showdirpanel'),'SelectedObject'),'Tag'),'seleccompall') && sum(secondcode)==0
    singlerastplot=1;
else
    singlerastplot=0;
end

%find alignment label
if strfind(ATPSelectedButton,'mainsac')
    alignlabel='sac';
elseif strfind(ATPSelectedButton,'correctivesac')
    alignlabel='corsac';
elseif strfind(ATPSelectedButton,'tgt')
    alignlabel='tgt';
elseif strfind(ATPSelectedButton,'rew')
    alignlabel='rew';
elseif strfind(ATPSelectedButton,'stop')
    alignlabel='stop';
end

if  singlerastplot || aligncodes(1)==1030 || aligncodes(1)== 17385
    datalign(1).alignlabel=alignlabel; %only one array
else
    for numlab=1:size(aligncodes,1)+size(alignseccodes,1)
        datalign(numlab).alignlabel =alignlabel;
    end
end

if sum(alignseccodes)
    
    if strfind(SATPSelectedButton,'mainsac')
        secalignlabel='sac';
    elseif strfind(SATPSelectedButton,'correctivesac')
        secalignlabel='corsac';
    elseif strfind(SATPSelectedButton,'tgt')
        secalignlabel='tgt';
    elseif strfind(SATPSelectedButton,'stop')
        secalignlabel='stop';
    elseif strfind(SATPSelectedButton,'errcd2align')
        secalignlabel='error2';
    elseif strfind(SATPSelectedButton,'nosec') %unnecessary
        secalignlabel='none';
    end
    
    for numlab=(size(aligncodes,1)+size(alignseccodes,1))/2+1:size(aligncodes,1)+size(alignseccodes,1)
        datalign(numlab).alignlabel =secalignlabel;
    end
end

%% formatting aligncodes

allaligncodes=[];

if ~sum(alignseccodes) %only one align code
    numcodes=size(aligncodes,1);
    allaligncodes=aligncodes;
    rotaterow=0;
else
    if collapsecode
        numcodes=size(aligncodes,1)+size(alignseccodes,1); %if collapsed ecodes
    else
        numcodes=2*max(size(aligncodes,1),size(alignseccodes,1)); %not collapsed together
    end
    if length(aligncodes)==length(alignseccodes)
        allaligncodes=[aligncodes;alignseccodes];
        rotaterow=0;
    else %unequal length of alignment codes. Making them equal here
        allaligncodes=1001*ones(numcodes,2); %first making a matrix 1001 to fill up the future "voids"
        if size(aligncodes,1)>size(alignseccodes,1)
            allaligncodes(1:size(aligncodes,1),1)=aligncodes;
            allaligncodes(size(aligncodes,1)+1:end,1)=alignseccodes*ones(size(aligncodes,1),1);
            allaligncodes(size(aligncodes,1)+1:end,2)=basecodes;
            rotaterow=fliplr(allaligncodes(size(aligncodes,1)+1:end,:));
        elseif size(aligncodes,1)<size(alignseccodes,1)
            allaligncodes(1:size(alignseccodes,1),1)=alignseccodes;
            allaligncodes(size(alignseccodes,1)+1:end,1)=aligncodes*ones(size(alignseccodes,1),1);
            allaligncodes(size(alignseccodes,1)+1:end,2)=basecodes;
            rotaterow=fliplr(allaligncodes(size(alignseccodes,1)+1:end,:));
        elseif size(aligncodes,2)>size(alignseccodes,2)
            allaligncodes(1:size(aligncodes,1),1:size(aligncodes,2))=aligncodes;
            allaligncodes(size(aligncodes,1)+1:end,1:size(alignseccodes,2))=alignseccodes*ones(size(aligncodes,1),1);
            allaligncodes(size(aligncodes,1)+1:end,size(alignseccodes,2)+1:end)=NaN;
            rotaterow=0;
        elseif size(aligncodes,2)<size(alignseccodes,2)
            allaligncodes(1:size(alignseccodes,1),1:size(alignseccodes,2))=alignseccodes;
            allaligncodes(size(alignseccodes,1)+1:end,1:size(aligncodes,2))=aligncodes*ones(size(alignseccodes,1),1);
            allaligncodes(size(alignseccodes,1)+1:end,size(aligncodes,2)+1:end)=NaN;
            rotaterow=0;
        end
    end
end


% align trials
for i=1:numcodes
    aligntype=datalign(i).alignlabel;
    adjconditions=conditions;
    if strcmp(aligntype,'stop')
        includebad=1; %we want to compare cancelled with non-cancelled
        numplots=numcodes+1;
    elseif strcmp(tasktype,'base2rem50')
        adjconditions=[conditions(i,:);conditions(i+numcodes,:);conditions(i+2*numcodes,:)];
    else
        includebad=0;
        numplots=numcodes;
    end
    [rasters,aidx, trialidx, timefromtrigs, timetotrigs, eyeh,eyev,eyevel,...
        amplitudes,peakvels,peakaccs,allgreyareas,badidx,ssd] = rdd_rasters( rdd_filename, spikechannel,...
        allaligncodes(i,:), nonecodes, includebad, alignsacnum, aligntype, collapsecode, adjconditions);
    
    
    if isempty( rasters )
        disp( 'No raster could be generated (rex_rasters_trialtype returned empty raster)' );
        continue;
    elseif strcmp(aligntype,'stop')
        canceledtrials=~badidx';
        datalign(i).alignlabel='stop_cancel';
        datalign(i).rasters=rasters(canceledtrials,:);
        datalign(i).alignidx=aidx;
        datalign(i).trials=trialidx(canceledtrials);
        datalign(i).timefromtrig=timefromtrigs(canceledtrials);
        datalign(i).timetotrig=timetotrigs(canceledtrials);
        datalign(i).eyeh=eyeh(canceledtrials,:);
        datalign(i).eyev=eyev(canceledtrials,:);
        datalign(i).eyevel=eyevel(canceledtrials,:);
        datalign(i).allgreyareas=allgreyareas(:,canceledtrials);
        datalign(i).amplitudes=amplitudes(canceledtrials);
        datalign(i).peakvels=peakvels(canceledtrials);
        datalign(i).peakaccs=peakaccs(canceledtrials);
        datalign(i).bad=badidx(canceledtrials);
        datalign(i).ssd=ssd(canceledtrials,:);
        
        canceledtrials=~canceledtrials;
        datalign(i+1).alignlabel='stop_non_cancel';
        datalign(i+1).rasters=rasters(canceledtrials,:);
        datalign(i+1).alignidx=aidx;
        datalign(i+1).trials=trialidx(canceledtrials);
        datalign(i+1).timefromtrig=timefromtrigs(canceledtrials);
        datalign(i+1).timetotrig=timetotrigs(canceledtrials);
        datalign(i+1).eyeh=eyeh(canceledtrials,:);
        datalign(i+1).eyev=eyev(canceledtrials,:);
        datalign(i+1).eyevel=eyevel(canceledtrials,:);
        datalign(i+1).allgreyareas=allgreyareas(:,canceledtrials);
        datalign(i+1).amplitudes=amplitudes(canceledtrials);
        datalign(i+1).peakvels=peakvels(canceledtrials);
        datalign(i+1).peakaccs=peakaccs(canceledtrials);
        datalign(i+1).bad=badidx(canceledtrials);
        datalign(i+1).ssd=ssd(canceledtrials,:);
        %             datalign(i+1).condtimes=condtimes(canceledtrials);
    else
        datalign(i).rasters=rasters;
        datalign(i).alignidx=aidx;
        datalign(i).trials=trialidx;
        datalign(i).timefromtrig=timefromtrigs;
        datalign(i).timetotrig=timetotrigs;
        datalign(i).eyeh=eyeh;
        datalign(i).eyev=eyev;
        datalign(i).eyevel=eyevel;
        datalign(i).allgreyareas=allgreyareas;
        datalign(i).amplitudes=amplitudes;
        datalign(i).peakvels=peakvels;
        datalign(i).peakaccs=peakaccs;
        datalign(i).bad=badidx;
        %             datalign(i).condtimes=condtimes;
    end
    
end

%% Now plotting rasters
%%%%%%%%%%%%%%%%%%%%%%
if plotrasts
    figure(gcf);
    
    if  singlerastplot || aligncodes(1)==1030 || aligncodes(1)== 17385
        % || aligncodes(1)==16386 || aligncodes(1)==16387 || aligncodes(1)==16388;
        %Which means that, until other code is deemed necessary, if aligned on
        %reward or error codes, and only one align code, collapse all trials
        
        rasterflowh = uigridcontainer('v0','Units','norm','Position',[.3,.1,.7,.9], ...
            'Margin',3,'Tag','rasterflow','parent',findobj('Tag','rasterspanel'),'backgroundcolor', 'white');
        % default GridSize is [1,1]
        rasterh = axes('parent',rasterflowh);
        set(rasterh,'YTickLabel',[],'XTickLabel',[]);
        
        sdfflowh = uigridcontainer('v0','Units','norm','Position',[.3,.1,.7,.9], ...
            'Tag','rasterflow','parent',findobj('Tag','rasterspanel'),'backgroundcolor', 'none');
        % default GridSize is [1,1]
        sdfploth = axes('parent',sdfflowh,'Color','none');
        
        
    else % if multiple, separate directions, or multiple align codes, create individual rasterplots and sdf plots locations
        
        rasterflowh = uigridcontainer('v0','Units','norm','Position',[.3,.1,.7,.9], ...
            'Margin',3,'Tag','rasterflow','parent',findobj('Tag','rasterspanel'),'backgroundcolor', 'white');
        set(rasterflowh, 'GridSize',[ceil(numplots/2),2]);  % default GridSize is [1,1]
        for i=1:numplots
            rasterh(i) = axes('parent',rasterflowh);
            set(rasterh(i),'YTickLabel',[],'XTickLabel',[]);
        end
        
        sdfflowh = uigridcontainer('v0','Units','norm','Position',[.3,.1,.7,.9], ...
            'Tag','rasterflow','parent',findobj('Tag','rasterspanel'),'backgroundcolor', 'none');
        set(sdfflowh, 'GridSize',[ceil(numplots/2),2]);  % default GridSize is [1,1]
        for i=1:numplots
            sdfploth(i) = axes('parent',sdfflowh,'Color','none');
            %set(rasterh(i),'YTickLabel',[],'XTickLabel',[]);
        end
        
    end
    % preallocate
    isnantrial=cell(numplots,1);
    
    for i=1:numplots
        
        rasters=datalign(i).rasters;
        
        if isempty(rasters)
            continue
        end
        
        aidx=datalign(i).alignidx;
        trialidx=datalign(i).trials;
        timefromtrigs=datalign(i).timefromtrig;
        timetotrigs=datalign(i).timetotrig;
        eyeh=datalign(i).eyeh;
        eyev=datalign(i).eyev;
        eyevel=datalign(i).eyevel;
        allgreyareas=datalign(i).allgreyareas;
        amplitudes=datalign(i).amplitudes;
        peakvels=datalign(i).peakvels;
        peakaccs=datalign(i).peakaccs;
        badidx=datalign(i).bad;
        if strcmp(aligntype,'stop')
            ssd=datalign(i).ssd;
        end
           
        % adjust temporal axis
        start = aidx - mstart;
        stop = aidx + mstop;
        if start < 1
            start = 1;
        end;
        if stop > length( rasters )
            stop = length( rasters );
        end;
        
        %get the current axes
        axes(rasterh(i));
        %plot the rasters
        % if one wants to plots the whole trials, find the
        % size of the longest trials as follow, and adjust
        % axis accordingly
        %                     testbin=size(rasters,2);
        %                     while ~sum(rasters(:,testbin))
        %                     testbin=testbin-1;
        %                     end
        trials = size(rasters,1);
        isnantrial(i)={zeros(1,size(rasters,1))};
        axis([0 stop-start+1 0 size(rasters,1)]);
        hold on
        
        %% grey patches for multiple plots
        if logical(sum(togrey))
            
            for num_trials=1:size(allgreyareas,2) %plotting grey area trial by trial
                try
                    greytimes=allgreyareas{num_trials}-start;
                    if greytimes(2,1)~=mstart && ~(strcmp(aligntype,'stop') && i==2) %just a control for unnoticed incorrect trials
                        num_trials
                        greytimes(2,1)
                    end
                    greytimes(find(greytimes<0))=0;
                    greytimes(find(greytimes>stop))=stop;
                catch %grey times out of designated period's limits
                    greytimes=0;
                end
                
                %             diffgrey = find(diff(greytimes)>1); %in case the two grey areas overlap, it doesn't discriminate. But that's not a problem
                %             diffgreytimes = greytimes(diffgrey);
                
                for numcond=1:length(togrey)
                    patch([greytimes(togrey(numcond),1) greytimes(togrey(numcond),end) ...
                        greytimes(togrey(numcond),end) greytimes(togrey(numcond),1)],...
                        [num_trials num_trials num_trials-1 num_trials-1],...
                        [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
                    if greytimes(togrey(numcond),1)>0
                        greylim1 = patch([greytimes(togrey(numcond),1) greytimes(togrey(numcond),1)],...
                            [num_trials num_trials-1], [1 0 0]);
                        set(greylim1, 'Edgecolor', [0 0 1],'Linewidth',2, 'EdgeAlpha', 0.5, 'FaceAlpha', 0.3)
                    end
                    if greytimes(togrey(numcond),end)<stop
                        greylim2 = patch([greytimes(togrey(numcond),end) greytimes(togrey(numcond),end)],...
                            [num_trials num_trials-1], [1 0 0]);
                        set(greylim2, 'Edgecolor', [0 0 1],'Linewidth',2, 'EdgeAlpha', 0.5, 'FaceAlpha', 0.3)
                    end
                end
            end
        end
        
        %% plotting rasters trial by trial
        for j=1:size(rasters,1)
            spiketimes=find(rasters(j,start:stop)); %converting from a matrix representation to a time collection, within selected time range
            if isnan(sum(rasters(j,start:stop)))
                isnantrial{i}(j)=1;
            end
            rastploth=plot([spiketimes;spiketimes],[ones(size(spiketimes))*j;ones(size(spiketimes))*j-1],'k-');
            uistack(rastploth,'down');
        end
        
        if exist('greylim1')
            uistack(greylim1,'top');
        elseif exist('greylim2')
            uistack(greylim2,'top');
        end
        
        hold off;
        set(gca,'TickDir','out'); % draw the tick marks on the outside
        set(gca,'YTick', []); % don't draw y-axis ticks
        set(gca,'YDir','reverse');
        %set(gca,'Color',get(gcf,'Color'))
        set(gca,'YColor',get(gcf,'Color')); % hide the y axis
        box off
        
        % finding current trial direction.
        % Direction already flipped left/ right in find_saccades_3 line 183
        % (see rex_process > find_saccades_3)
        if i>numcodes
            aligncodeidx=max(numcodes);
        else
            aligncodeidx=i;
        end
        if logical(sum(rotaterow(1,:))) && logical(aligncodeidx>=length(aligncodes)+1)
            curdirnb=rotaterow(aligncodeidx-length(aligncodes),1)-(floor(rotaterow(aligncodeidx-length(aligncodes),1)/10)*10);
        else
            curdirnb=allaligncodes(aligncodeidx,1)-(floor(allaligncodes(aligncodeidx,1)/10)*10);
        end
        
        if collapsecode
            curdir='all_directions';
        else
            if curdirnb==0
                curdir='upward';
            elseif curdirnb==1
                curdir='up_right';
            elseif curdirnb==2
                curdir='rightward';
            elseif curdirnb==3
                curdir='down_right';
            elseif curdirnb==4
                curdir='downward';
            elseif curdirnb==5
                curdir='down_left';
            elseif curdirnb==6
                curdir='leftward';
            elseif curdirnb==7
                if strcmp(tasktype,'tokens') && sum(allaligncodes(:,1)-(floor(allaligncodes(1,1)/10)*10)==2)
                    curdir='leftward'; % made a mistake on the flag
                else
                    curdir='up_left';
                end
            end
        end
        
        s1 = sprintf( 'Trials for %s direction, n = %d trials.', curdir, trials); %num2str( aligncodes(i) )
        htitle=title( s1 );
        set(htitle,'Interpreter','none'); %that prevents underscores turning charcter into subscript
        
        datalign(i).dir=curdir;
        
        %% sdf plot
        % for kernel optimization, see : http://176.32.89.45/~hideaki/res/ppt/histogram-kernel_optimization.pdf
        sumall=sum(rasters(~isnantrial{i},start:stop));
        sdf=spike_density(sumall,fsigma)./length(find(~isnantrial{i})); %instead of number of trials
        %pdf = probability_density( sumall, fsigma ) ./ trials;
        
        axes(sdfploth(i));
        %         sdfaxh = axes('Position',get(rasterh(i),'Position'),...
        %            'XAxisLocation','top',...
        %            'YAxisLocation','left',...
        %            'Color','none',...
        %            'XColor','k','YColor','k');
        plot(sdf,'Color','b','LineWidth',3);
        axis([0 stop-start 0 200])
        set(sdfploth(i),'Color','none','YAxisLocation','right','TickDir','out', ...
            'FontSize',8,'Position',get(rasterh(i),'Position'));
        
        patch([repmat((aidx-start)-5,1,2) repmat((aidx-start)+5,1,2)], ...
            [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
            [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
        
    end
end

if dostats
    %% do stats for each raster
    
    %prealloc
    p_sac=nan(length(numplots),6);
    h_sac=nan(length(numplots),2);
    
    for alignmtnum=1:numplots
        
        rasters=datalign(alignmtnum).rasters;
        allgreyareas=datalign(alignmtnum).allgreyareas;
        
        %preallocate
        allpostcue=nan(size(rasters,1),1);
        allbaseline=nan(size(rasters,1),1);
        allpresac=nan(size(rasters,1),1);
        allpostsac=nan(size(rasters,1),1);
        allperisac=nan(size(rasters,1),1);
        alldelay=nan(size(rasters,1),1);
        
        %% Statistic Information
        for num_trials = 1:size(rasters,1)
            timesmat = allgreyareas{num_trials}; %condtimes
            
            %       Measure mean firing rate in four time periods:
            %       - fixation period from (500 to 200) or 300 ms before target
            %       - visual period from 50 to 150 ms after visual stimulus onset
            %       - delay period covering the last 300 ms interval of the delay
            %       interval (if any)
            %       - presaccadic period covering the last 100 ms before saccade onset
            %       - postsaccadic period covering the first 100 ms after saccade onset
            
            %300ms of fixation period
            baseline = timesmat(1,1)-300 : timesmat(1,1)-1;   %300 ms to 1ms before cue
            
            %150ms period of visual response
            postcue = timesmat(1,1)+51 : timesmat(1,1)+150; %50ms to 150ms after cue presentation
            
            %100ms of pre-eye movement period
            presac = timesmat(2,1)-100 : timesmat(2,1)-1; %100ms before sac initation
            
            %100ms of eye movement period
            postsac = timesmat(2,1)+1 : timesmat(2,1)+100; %100ms before sac initation
            
            %perisactime
            perisac = timesmat(2,1)-50 : timesmat(2,1)+50; %100ms around sac initation
            
            if strcmp(tasktype,'memguided') % || strcmp(tasktype,'vg_saccades')
                delay=timesmat(3,2)-300 : timesmat(3,2)-1;
            elseif strcmp(tasktype, 'st_saccades') || strcmp(tasktype, 'tokens')
                delay=timesmat(2,1)-400 : timesmat(2,1)-101;
            else
                delay=0;
            end
            %make changes above for gapstop
            
            %conversion to firing rate (since epochs are different
            %durations)
            if ~plotrasts % then have to find isnantrial
                aidx=datalign(alignmtnum).alignidx;
                start = aidx - mstart;
                stop = aidx + mstop;
                isnantrial(alignmtnum)={zeros(1,size(rasters,1))};
                for szrast=1:size(rasters,1)
                    if isnan(sum(rasters(szrast,start:stop)))
                        isnantrial{alignmtnum}(szrast)=1;
                    end
                end
            end
            
            
            if ~isnantrial{alignmtnum}(num_trials)
                allpostcue(num_trials) = (sum(rasters(num_trials, postcue))/length(postcue))*1000;
                allbaseline(num_trials) = (sum(rasters(num_trials, baseline))/length(baseline))*1000;
                allpresac(num_trials) = (sum(rasters(num_trials, presac))/length(presac))*1000;
                allpostsac(num_trials) = (sum(rasters(num_trials, postsac))/length(postsac))*1000;
                allperisac(num_trials) = (sum(rasters(num_trials, perisac))/length(perisac))*1000;
                if delay
                    alldelay(num_trials) = (sum(rasters(num_trials, delay))/length(delay))*1000;
                end
            end
            
        end
        
        allpostcue=allpostcue(~isnantrial{alignmtnum});
        allbaseline=allbaseline(~isnantrial{alignmtnum});
        allpresac=allpresac(~isnantrial{alignmtnum});
        allpostsac=allpostsac(~isnantrial{alignmtnum});
        allperisac=allperisac(~isnantrial{alignmtnum});
        if delay
            alldelay=alldelay(~isnantrial{alignmtnum});
        end
        
        %Wilcoxon signed rank test, get p value (adding difference of mean
        %firing rate), and h (yes or no significance)
        [p_sac(alignmtnum,1),h_sac(alignmtnum,1)] = signrank(allbaseline, allpresac);
        p_sac(alignmtnum,2)=mean(allpresac)-mean(allbaseline);
        
        %if pre-sac inhibition and post-sac burst, the pre-sac Vs baseline
        % comparison might not give correct results, but that will be
        % caught by following pre/post comparison
        
        [p_sac(alignmtnum,3),h_sac(alignmtnum,2)] = signrank(allpresac, allpostsac);
        p_sac(alignmtnum,4)=mean(allpostsac)-mean(allpresac);
        
        % if saccade burst sharp, short and exacty at saccade time, the
        % first two tests may not catch it (100ms periods too long for that).
        % But perisaccadic period comparison with baseline should
        
        [p_sac(alignmtnum,5),h_sac(alignmtnum,3)] = signrank(allbaseline, allperisac);
        p_sac(alignmtnum,6)=mean(allperisac)-mean(allbaseline);
        
        datalign(alignmtnum).stats.p=p_sac(alignmtnum,:);
        datalign(alignmtnum).stats.h=h_sac(alignmtnum,:);
        
        
    end
    
if showstats
    %% Present statistics
    pdata = {};
    stat_dir = {};
    set(findobj('Tag','wilcoxontable'),'Data',pdata,'RowName',[]); %Clears previous table
    
    % Create table data
    if any(sum(h_sac,1))
        pdata=num2cell(p_sac);
        stat_dir ={datalign.dir};
        set(findobj('Tag','wilcoxontable'),'Data',pdata,'RowName',stat_dir);
    end
end
end

% last item: save name
datalign(1).savealignname = cat( 2, directory, 'processed',slash, 'aligned',slash, rdd_filename, '_', cell2mat(unique({datalign.alignlabel})));

% comparison of raster from different methods
%    figure(21);
%    subplot(3,1,1)
%    %fat = fat_raster( rasters, 1 );
%    imagesc( rasters(:,start:stop) );
%    colormap( 1-gray );
%    ax1 = axis();
%    subplot(3,1,2)
%    axis([0 stop-start+1 0 size(rasters,1)]);
%    hold on
%    for j=size(rasters,1):-1:1 %plotting rasters trial by trial
%         spiketimes=find(rasters(j,start:stop)); %converting from a matrix representation to a time collection, within selected time range
%         plot([spiketimes;spiketimes],[ones(size(spiketimes))*j;ones(size(spiketimes))*j-1],'k-');
%    end
%    hold off
%    subplot(3,1,3)
%    spy(rasters(:,start:stop),':',5);
%    set(gca,'PlotBoxAspectRatio',[1052 200 1]);

end
