 function datalign = rdd_rasters_sdf(rdd_filename, trialdirs, plotrasts, ecode, spikechan)
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

getraw = 0;

%define ecodes according to task
%add last number for direction
tasktype='twoafc';
[fixcode, fixoffcode, tgtcode, tgtoffcode, saccode, ...
    stopcode, rewcode, tokcode, errcode1, errcode2, errcode3, basecode ...
    dectgtcode dessaccode] = taskfindecode(tasktype);

%% align code is passed in as argument
ecodealign = ecode;

%% second code: no second code
secondcode=0;

%% Bin width for rasters and Initial sigma for density functions (chosen manually)
binwidth= 20;
fsigma= 12;

%% Rasters start and stop times: deprecated

%% include bad trials?
includebad= 0;

%% which channel to use: passed in as argument
spikechannel = spikechan;

%% Fusing task type and direction into ecode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ecodealign<1000 % if only three numbers
    for i=1:length(trialdirs)
        aligncodes(i,:)=ecodealign*10+trialdirs(i);
    end
else
    aligncodes=ecodealign;
end
if logical(secondcode)
    if secondcode<1000
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

% if strcmp(get(get(findobj('Tag','showdirpanel'),'SelectedObject'),'Tag'),'selecdir');
%     %get the selected direction
%     dirmenulist=get(findobj('Tag','SacDirToDisplay'),'String');
%     dirmenuselection=get(findobj('Tag','SacDirToDisplay'),'Value');
%     dirmenuselection=dirmenulist{dirmenuselection};
%     
%     if strcmp(dirmenuselection,'Horizontals') %remember error on initial gapstops
%         codeidx=find(aligncodes-(floor(aligncodes./10).*10)==2 | aligncodes-(floor(aligncodes./10).*10)==6);
%         aligncodes=aligncodes(codeidx);
%         seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==2 | alignseccodes-(floor(alignseccodes./10).*10)==6);
%         alignseccodes=alignseccodes(seccodeidx);
%     elseif strcmp(dirmenuselection,'Verticals')
%         codeidx=find(aligncodes-(floor(aligncodes./10).*10)==0 | aligncodes-(floor(aligncodes./10).*10)==4);
%         aligncodes=aligncodes(codeidx);
%         seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==0 | alignseccodes-(floor(alignseccodes./10).*10)==4);
%         alignseccodes=alignseccodes(seccodeidx);
%     elseif strcmp(dirmenuselection,'SU')
%         codeidx=find(aligncodes-(floor(aligncodes./10).*10)==0);
%         aligncodes=aligncodes(codeidx);
%         seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==0);
%         alignseccodes=alignseccodes(seccodeidx);
%     elseif strcmp(dirmenuselection,'UR')
%         codeidx=find(aligncodes-(floor(aligncodes./10).*10)==1);
%         aligncodes=aligncodes(codeidx);
%         seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==1);
%         alignseccodes=alignseccodes(seccodeidx);
%     elseif strcmp(dirmenuselection,'SR')
%         codeidx=find(aligncodes-(floor(aligncodes./10).*10)==2);
%         aligncodes=aligncodes(codeidx);
%         seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==2);
%         alignseccodes=alignseccodes(seccodeidx);
%     elseif strcmp(dirmenuselection,'BR')
%         codeidx=find(aligncodes-(floor(aligncodes./10).*10)==3);
%         aligncodes=aligncodes(codeidx);
%         seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==3);
%         alignseccodes=alignseccodes(seccodeidx);
%     elseif strcmp(dirmenuselection,'SD')
%         codeidx=find(aligncodes-(floor(aligncodes./10).*10)==4);
%         aligncodes=aligncodes(codeidx);
%         seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==4);
%         alignseccodes=alignseccodes(seccodeidx);
%     elseif strcmp(dirmenuselection,'BL')
%         codeidx=find(aligncodes-(floor(aligncodes./10).*10)==5);
%         aligncodes=aligncodes(codeidx);
%         seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==5);
%         alignseccodes=alignseccodes(seccodeidx);
%     elseif strcmp(dirmenuselection,'SL')
%         codeidx=find(aligncodes-(floor(aligncodes./10).*10)==6);
%         aligncodes=aligncodes(codeidx);
%         seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==6);
%         alignseccodes=alignseccodes(seccodeidx);
%     elseif strcmp(dirmenuselection,'UL')
%         codeidx=find(aligncodes-(floor(aligncodes./10).*10)==7);
%         aligncodes=aligncodes(codeidx);
%         seccodeidx=find(alignseccodes-(floor(alignseccodes./10).*10)==7);
%         alignseccodes=alignseccodes(seccodeidx);
%     end
%     
% elseif strcmp(get(get(findobj('Tag','showdirpanel'),'SelectedObject'),'Tag'),'seleccompall');
%     collapsecode=1;
%     %compile all trial directions into a single raster
%     aligncodes=aligncodes'; % previously: ecodealign,  so that when
%     % aligncodes was only three numbers long,
%     % rdd_rasters would know it had to collapse all
%     % directions together
%     alignseccodes= alignseccodes'; %secondcode;
% % elseif size(alignseccodes,1)>0
% %     collapsecode=1; % we want two plots, one for each type of code
% %     aligncodes=aligncodes';
% %     alignseccodes= alignseccodes';
% elseif strcmp(tasktype,'base2rem50')
%     collapsecode=0; % we want to plots, one for each type of code
%     aligncodes=aligncodes';
%     alignseccodes= alignseccodes';
% else
%     disp('Selected option: all directions'); %correspond to 'selecalldir' tag
% end
collapsecode=1;
aligncodes=aligncodes';
alignseccodes=alignseccodes';
%% Grey area in raster
greycodes=[];
togrey=find([get(findobj('Tag','greycue'),'Value'),get(findobj('Tag','greyemvt'),'Value'),get(findobj('Tag','greyfix'),'Value')]);

if strcmp(tasktype,'gapstop') %otherwise CAT arguments dimensions are not consistent below
    saccode=[saccode saccode];
    stopcode=[stopcode stopcode];
end

switch tasktype
    case 'twoafc'
        conditions =[tgtcode tgtoffcode;...
            saccode saccode;...
            fixcode fixoffcode;...
            rewcode rewcode;...
            dectgtcode dectgtcode;...
            dessaccode dessaccode];
    otherwise
        conditions =[tgtcode tgtoffcode;...
            saccode saccode;...
            fixcode fixoffcode];
end

if logical(sum(togrey))
    greycodes=conditions(togrey,:); %selecting out the codes
end

%% Task-specific instructions
ol_instruct='directions'; %default mode
if strcmp(tasktype,'optiloc')
    ol_instructs=get(findobj('Tag','optiloc_popup'),'String');
    ol_instruct=ol_instructs{get(findobj('Tag','optiloc_popup'),'Value')};
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
datalign=struct('dir',{},'rasters',{},'trials',{},'trigtosac',{},'sactotrig',{},...
    'trigtovis',{},'vistotrig',{},'alignidx',{},'eyeh',{},'eyev',{},'eyevel',{},...
    'amplitudes',{},'peakvels',{},'peakaccs',{},'allgreyareas',{},'stats',{},...
    'alignlabel',{},'savealignname',{},'bad',{},'rawsigs',{},'alignrawidx',{});  
if strcmp(get(get(findobj('Tag','showdirpanel'),'SelectedObject'),'Tag'),'seleccompall') && sum(secondcode)==0
    singlerastplot=1;
else
    singlerastplot=0;
end

% %find alignment label
% if strfind(ATPSelectedButton,'mainsac')
%     alignlabel='sac';
% elseif strfind(ATPSelectedButton,'correctivesac')
%     alignlabel='corsac';
% elseif strfind(ATPSelectedButton,'tgt')
%     alignlabel='tgt';
% elseif strfind(ATPSelectedButton,'rew')
%     alignlabel='rew';
% elseif strfind(ATPSelectedButton,'stop')
%     alignlabel='stop';
% elseif strfind(ATPSelectedButton,'ecodesalign')
%     if ecodealign==421
%         alignlabel='touchbell';
%     elseif ecodealign==742
%         alignlabel='retarget';
%     elseif ecodealign==507
%         alignlabel='ssd';
%     else
%         alignlabel='ecode';
%     end
% end

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
    
    for numlab=size(aligncodes,1)+1:size(aligncodes,1)+size(alignseccodes,1)
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

if strcmp(tasktype,'optiloc')
    if strcmp(ol_instruct,'directions') 
        %default, nothing to change
    elseif strcmp(ol_instruct,'amplitudes') && singlerastplot
        singlerastplot=0;
    elseif strcmp(ol_instruct,'directions and amplitudes') && singlerastplot
        singlerastplot=0;
%     elseif strcmp(ol_instruct,'directions mleft') || strcmp(ol_instruct,'amplitudes mleft')
%         numcodes=ceil(numcodes/2);
%         allaligncodes=allaligncodes(allaligncodes==7011 | allaligncodes==7012 | allaligncodes==7013);
%     elseif strcmp(ol_instruct,'directions mright') || strcmp(ol_instruct,'amplitudes mright')
%         numcodes=ceil(numcodes/2);
%         allaligncodes=allaligncodes(allaligncodes==7015 | allaligncodes==7016 | allaligncodes==7017);
    end
end


% align trials
for cnc=1:numcodes
    aligntype=datalign(cnc).alignlabel;
    adjconditions=conditions;
    if strcmp(aligntype,'stop') %|| (strcmp(tasktype,'gapstop') & cnc==2)
        includebad=1; %we want to compare cancelled with non-cancelled
        d_increment=size([aligncodes alignseccodes],1);%make room for additional "non-cancel" data
        numplots=numcodes+d_increment;
    elseif strcmp(tasktype,'base2rem50')
        adjconditions=[conditions(cnc,:);conditions(cnc+numcodes,:);conditions(cnc+2*numcodes,:)];
        numplots=numcodes;
    elseif logical(sum(strfind(ol_instruct,'amplitudes')))
        numplots=numcodes*3;
    else
       % includebad=0;
        numplots=numcodes;
    end
    [rasters,aidx, trialidx, trigtosacs, sactotrigs, trigtovis, vistotrigs, eyeh,eyev,eyevel,...
        amplitudes,peakvels,peakaccs,allgreyareas,badidx,ssd,rawsigs,alignrawidx] = rdd_rasters( rdd_filename, spikechannel, ...
        allaligncodes(cnc,:), nonecodes, includebad, alignsacnum, aligntype, collapsecode, adjconditions, getraw);
    
    if isempty( rasters )
        disp( 'No raster could be generated (rex_rasters_trialtype returned empty raster)' );
        continue;
    elseif strcmp(aligntype,'stop')
        canceledtrials=~badidx';
        datalign(cnc).alignlabel='stop_cancel';
        datalign(cnc).rasters=rasters(canceledtrials,:);
        datalign(cnc).alignidx=aidx;
        datalign(cnc).trials=trialidx(canceledtrials);
        datalign(cnc).trigtosac=trigtosacs(canceledtrials);
        datalign(cnc).sactotrig=sactotrigs(canceledtrials);
        datalign(cnc).trigtovis=trigtovis(canceledtrials);
        datalign(cnc).vistotrig=vistotrigs(canceledtrials);
        datalign(cnc).eyeh=eyeh(canceledtrials,:);
        datalign(cnc).eyev=eyev(canceledtrials,:);
        datalign(cnc).eyevel=eyevel(canceledtrials,:);
        datalign(cnc).allgreyareas=allgreyareas(:,canceledtrials);
        datalign(cnc).amplitudes=amplitudes(canceledtrials);
        datalign(cnc).peakvels=peakvels(canceledtrials);
        datalign(cnc).peakaccs=peakaccs(canceledtrials);
        datalign(cnc).bad=badidx(canceledtrials);
        datalign(cnc).ssd=ssd(canceledtrials);
        
        canceledtrials=~canceledtrials;
        datalign(cnc+d_increment).alignlabel='stop_non_cancel';
        datalign(cnc+d_increment).rasters=rasters(canceledtrials,:);
        datalign(cnc+d_increment).alignidx=aidx;
        datalign(cnc+d_increment).trials=trialidx(canceledtrials);
        datalign(cnc+d_increment).trigtosac=trigtosacs(canceledtrials);
        datalign(cnc+d_increment).sactotrig=sactotrigs(canceledtrials);
        datalign(cnc+d_increment).trigtovis=trigtovis(canceledtrials);
        datalign(cnc+d_increment).vistotrig=vistotrigs(canceledtrials);
        datalign(cnc+d_increment).eyeh=eyeh(canceledtrials,:);
        datalign(cnc+d_increment).eyev=eyev(canceledtrials,:);
        datalign(cnc+d_increment).eyevel=eyevel(canceledtrials,:);
        datalign(cnc+d_increment).allgreyareas=allgreyareas(:,canceledtrials);
        datalign(cnc+d_increment).amplitudes=amplitudes(canceledtrials);
        datalign(cnc+d_increment).peakvels=peakvels(canceledtrials);
        datalign(cnc+d_increment).peakaccs=peakaccs(canceledtrials);
        datalign(cnc+d_increment).bad=badidx(canceledtrials);
        datalign(cnc+d_increment).ssd=ssd(canceledtrials);
        %             datalign(cnc+d_increment).condtimes=condtimes(canceledtrials);
        elseif strcmp(tasktype,'optiloc') && logical(sum(strfind(ol_instruct,'amplitudes')))
        % compare amp distrib with expected distrib, typically [4,12,20]
        if ~sum(hist(abs(amplitudes),[4,12,20])==hist(abs(amplitudes),3))==3 %case when amps are not dixtributed as expected
            [~, apmbounds]=hist(abs(amplitudes),3);
            disp('unequal amp distrib in rdd_rasters_sdf line 515');
            pause;
        else
            shortampslim=4;
            medampslim=12;
            longampslim=20;
        end
        %allamps=(sort(abs(amplitudes)));
        
        shortamps=abs(amplitudes)<shortampslim; %(abs(amplitudes)<allamps(apmdistrib(1)))';
        datalign(cnc).alignlabel=[alignlabel,'4dg'];
        datalign(cnc).rasters=rasters(shortamps,:);
        datalign(cnc).alignidx=aidx;
        datalign(cnc).trials=trialidx(shortamps);
        datalign(cnc).trigtosac=trigtosacs(shortamps);
        datalign(cnc).sactotrig=sactotrigs(shortamps);
        datalign(cnc).trigtovis=trigtovis(shortamps);
        datalign(cnc).vistotrig=vistotrigs(shortamps);
        datalign(cnc).eyeh=eyeh(shortamps,:);
        datalign(cnc).eyev=eyev(shortamps,:);
        datalign(cnc).eyevel=eyevel(shortamps,:);
        datalign(cnc).allgreyareas=allgreyareas(:,shortamps);
        datalign(cnc).amplitudes=amplitudes(shortamps);
        datalign(cnc).peakvels=peakvels(shortamps);
        datalign(cnc).peakaccs=peakaccs(shortamps);
        datalign(cnc).bad=badidx(shortamps);
        
        medamps=abs(amplitudes)<medampslim;
        datalign(cnc+numcodes).alignlabel=[alignlabel,'12dg'];
        datalign(cnc+numcodes).rasters=rasters(medamps,:);
        datalign(cnc+numcodes).alignidx=aidx;
        datalign(cnc+numcodes).trials=trialidx(medamps);
        datalign(cnc+numcodes).trigtosac=trigtosacs(medamps);
        datalign(cnc+numcodes).sactotrig=sactotrigs(medamps);
        datalign(cnc+numcodes).trigtovis=trigtovis(medamps);
        datalign(cnc+numcodes).vistotrig=vistotrigs(medamps);
        datalign(cnc+numcodes).eyeh=eyeh(medamps,:);
        datalign(cnc+numcodes).eyev=eyev(medamps,:);
        datalign(cnc+numcodes).eyevel=eyevel(medamps,:);
        datalign(cnc+numcodes).allgreyareas=allgreyareas(:,medamps);
        datalign(cnc+numcodes).amplitudes=amplitudes(medamps);
        datalign(cnc+numcodes).peakvels=peakvels(medamps);
        datalign(cnc+numcodes).peakaccs=peakaccs(medamps);
        datalign(cnc+numcodes).bad=badidx(medamps);

        longamps=abs(amplitudes)<longampslim;
        datalign(cnc+2*numcodes).alignlabel=[alignlabel,'20dg'];
        datalign(cnc+2*numcodes).rasters=rasters(longamps,:);
        datalign(cnc+2*numcodes).alignidx=aidx;
        datalign(cnc+2*numcodes).trials=trialidx(longamps);
        datalign(cnc+2*numcodes).trigtosac=trigtosacs(longamps);
        datalign(cnc+2*numcodes).sactotrig=sactotrigs(longamps);
        datalign(cnc+2*numcodes).trigtovis=trigtovis(longamps);
        datalign(cnc+2*numcodes).vistotrig=vistotrigs(longamps);
        datalign(cnc+2*numcodes).eyeh=eyeh(longamps,:);
        datalign(cnc+2*numcodes).eyev=eyev(longamps,:);
        datalign(cnc+2*numcodes).eyevel=eyevel(longamps,:);
        datalign(cnc+2*numcodes).allgreyareas=allgreyareas(:,longamps);
        datalign(cnc+2*numcodes).amplitudes=amplitudes(longamps);
        datalign(cnc+2*numcodes).peakvels=peakvels(longamps);
        datalign(cnc+2*numcodes).peakaccs=peakaccs(longamps);
        datalign(cnc+2*numcodes).bad=badidx(longamps);
        
    else
        datalign(cnc).rasters=rasters;
        datalign(cnc).alignidx=aidx;
        datalign(cnc).trials=trialidx;
        datalign(cnc).trigtosac=trigtosacs;
        datalign(cnc).sactotrig=sactotrigs;
        datalign(cnc).trigtovis=trigtovis;
        datalign(cnc).vistotrig=vistotrigs;
        datalign(cnc).eyeh=eyeh;
        datalign(cnc).eyev=eyev;
        datalign(cnc).eyevel=eyevel;
        datalign(cnc).allgreyareas=allgreyareas;
        datalign(cnc).amplitudes=amplitudes;
        datalign(cnc).peakvels=peakvels;
        datalign(cnc).peakaccs=peakaccs;
        datalign(cnc).bad=badidx;
        %             datalign(cnc).condtimes=condtimes;
        if ~isempty(rawsigs)
            datalign(cnc).rawsigs=rawsigs;
            datalign(cnc).alignrawidx=alignrawidx;
        end
    end
    
end

if strcmp(aligntype,'stop') % make additional analysis
     if ATPbuttonnb==6 || ATPbuttonnb==9 % saccade or corrective saccade
%     [p_cancellation,h_cancellation] = cmd_wilco_cancellation(rdd_filename,datalign);
        disp_cmd([rdd_filename,'_Clus',num2str(spikechannel)],datalign,'sac',0); %0, 0: latmatch, no; triplot, no
%     disp_cmd(rdd_filename,datalign,1);
    elseif ATPbuttonnb==7 % target
        disp_cmd([rdd_filename,'_Clus',num2str(spikechannel)],datalign,'tgt',0); % keep triplot off until fixed
     end
        plotrasts=0;
%=========================================================================%
%% Displaying 2AFC Results
%=========================================================================%
elseif strcmp(tasktype, 'twoafc')
    AFC_ver=2;
    %twoafc()
    %uiwait
    InterAxn='BOTH';
    % InterAxn controls what is plotted ->
    % if == TT: plot SS,INS,Rule0,Rule1
    % if == Interaction: plot SS_R0,SS_R1,INS_R0,INS_R1
    % if == BOTH: plots both
    
    switch AFC_ver
        case 1 % Run original version
            disp_2AFC_v1(rdd_filename,datalign,spikechannel,ecodealign);
        case 2 % Run new version (w/ interactions)
            disp_2AFC(rdd_filename,datalign,spikechannel,ecodealign,InterAxn);
        case 3 % Run both versions
            disp_2AFC(rdd_filename,datalign,spikechannel,ecodealign,'BOTH');
            disp_2AFC_v1(rdd_filename,datalign,spikechannel,ecodealign);
    end
    plotrasts=0;
elseif strcmp(aligntype,'ecode') % other task-specific analysis
end

%% Now plotting rasters: no plotting

%% last item: save name: nope
end
