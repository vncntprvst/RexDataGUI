function disp_2AFC(recname,datalign,spikechannel,aligncode,InterAxn)
% Called from Rex Data GUI when using Ecodes 465 as alignement (collapse
% all directions together when doing that)
% This function will sort data to compare either:
%   - self-selected vs instructed
%   - rule 0 vs rule 1
% (will do sub-comparisons later)
%  We keep only trials where rule-selecting saccade was contralateral (see
%  line 45 or so)
% 8/22/2013 - VP
fprintf(['Running: disp_2AFC.m\n']);
fprintf([' Plotting data for: ' InterAxn '\n']);

% Implicitly setting global variables as can't find where set
global directory output;
output.savfig=1;
output.savsdf=0;

load(recname,'allbad','allcodes','alltimes');  % saccadeInfo probably not needed

ReSize=0;
% ReSize binary controls if the figures rasters are resized

try
    pool = output.sides; % set to 1 for all saccades, 2 for leftward saccades, 3 for rightward saccades (rule selecting)
    poolstr1 = [];
    poolstr2 = [];
    if (pool==1)
        poolstr1 = ', pooled';
        poolstr2 = '_pooled';
    elseif (pool==2)
        poolstr1 = ', leftward';
        poolstr2 = '_leftward';
    else
        poolstr1 = ', rightward';
        poolstr2 = '_rightward';
    end
catch err
    fprintf(' Output.sides appears unset: poolstr set to default\n');
    poolstr1=''; poolstr2=''; pool=[];
end

%% preallocs and definitions
if aligncode == 465;
    alignname = 'RuleStim';
end
if aligncode == 585;
    alignname = 'Refix';
end
AFCplots=nan(2,1);

allsdf=cell(4,1);
allrast=cell(4,1);
alladdevents=cell(4,1);

numrast=4; %Two figures, ploting two sets of data per figure
% numsubplot=numrast/2+numrast; %dividing the panel in two compartments with unequal number of subplots (2/4)
numsubplot=7;
hrastplot=nan(4,1);
sdfplot=nan(4,1);

fsigma=50; %smoothing
cc=lines(numrast); %colors

alignidx=datalign.alignidx;
addevents=datalign.allgreyareas;
plotstart=400; %400 ms before alignment time
plotstop=1000; %1000 ms after alignment time

% aligntype={'Self-selected','Instructed','Rule 0','Rule 1'}; % set alignment types for legend
% fnaligntype={'SSvsINS','R0vsR1'};

%% removing bad trials from codes and times
% first checking we have the right number of good trials
if size(logical(datalign.bad),2)~=size(allbad(~logical(allbad)),2)
    return
end
allgoodcodes=allcodes(~logical(allbad),:); %#ok<NODEF>
allgoodtimes=alltimes(~logical(allbad),:); %#ok<NODEF>

%% keeping trials with contralateral rule-selecting saccade
if (pool==1)
    crsrasts=datalign.rasters;
    crscodes=allgoodcodes;
    crsaddevents=addevents;
elseif (pool==2) % leftward rule selecting saccades
    crsrasts=datalign.rasters(allgoodcodes(:,17)==1901,:); % rasters
    crscodes=allgoodcodes(allgoodcodes(:,17)==1901,:); % ecodes
    crsaddevents=addevents(allgoodcodes(:,17)==1901); % additional events
elseif (pool==3) % rightward rule selecting saccades
    crsrasts=datalign.rasters(allgoodcodes(:,17)==1900,:); % rasters
    crscodes=allgoodcodes(allgoodcodes(:,17)==1900,:); % ecodes
    crsaddevents=addevents(allgoodcodes(:,17)==1900); % additional events
else
    % Original disp_2AFC default
    crsrasts=datalign.rasters(allgoodcodes(:,17)==1901,:); % rasters
    crscodes=allgoodcodes(allgoodcodes(:,17)==1901,:); % ecodes
    crsaddevents=addevents(allgoodcodes(:,17)==1901); % additional events
end

%% sort trials: SS vs INS
% allrast{1}=crsrasts(crscodes(:,2)==1700,:); % Self-selected trials
% allrast{2}=crsrasts(crscodes(:,2)==1701,:); % Instructed trials
% 
% alladdevents{1}=crsaddevents(crscodes(:,2)==1700); % Self-selected trials
% alladdevents{2}=crsaddevents(crscodes(:,2)==1701); % Instructed trials
% 
%% sort trials: Rule 0  vs Rule 1
% allrast{3}=crsrasts(crscodes(:,14)==1800,:); % Rule 0 trials
% allrast{4}=crsrasts(crscodes(:,14)==1801,:); % Rule 1 trials
% 
% alladdevents{3}=crsaddevents(crscodes(:,14)==1800); % Rule 0 trials
% alladdevents{4}=crsaddevents(crscodes(:,14)==1801); % Rule 1 trials

%% sort trials: SS vs INS & Rule 0 vs Rule 1
switch InterAxn
    case 'TT'
        aligntype={'Self-selected','Instructed','Rule 0','Rule 1'}; % set alignment types for legend
        % Rast1 = SS
        % Rast2 = INS
        % Rast3 = Rule0
        % Rast4 = Rule1
        allrast{1}=crsrasts(crscodes(:,2)==1700,:); % Self-selected trials
        allrast{2}=crsrasts(crscodes(:,2)==1701,:); % Instructed trials

        alladdevents{1}=crsaddevents(crscodes(:,2)==1700); % Self-selected trials
        alladdevents{2}=crsaddevents(crscodes(:,2)==1701); % Instructed trials

        allrast{3}=crsrasts(crscodes(:,14)==1800,:); % Rule 0 trials
        allrast{4}=crsrasts(crscodes(:,14)==1801,:); % Rule 1 trials

        alladdevents{3}=crsaddevents(crscodes(:,14)==1800); % Rule 0 trials
        alladdevents{4}=crsaddevents(crscodes(:,14)==1801); % Rule 1 trials
    case 'Interaction'
        aligntype={'SS_R0','SS_R1','INS_R0','INS_R1'}; % set alignment types for legend
        % Rast1 = SS_R0
        % Rast2 = SS_R1
        % Rast3 = INS_R0
        % Rast4 = INS_R1
        SS_Trials=crscodes(:,2)==1700;
        INS_Trials=crscodes(:,2)==1701;
        Rule0_Trials=crscodes(:,14)==1800;
        Rule1_Trials=crscodes(:,14)==1801;
         
        allrast{1}=crsrasts(and(SS_Trials,Rule0_Trials),:); % SS_R0
        allrast{2}=crsrasts(and(SS_Trials,Rule1_Trials),:); % SS_R1
        allrast{3}=crsrasts(and(INS_Trials,Rule0_Trials),:); % INS_R0
        allrast{4}=crsrasts(and(INS_Trials,Rule1_Trials),:); % INS_R1
        
        alladdevents{1}=crsaddevents(and(SS_Trials,Rule0_Trials)); 
        alladdevents{2}=crsaddevents(and(SS_Trials,Rule1_Trials)); 
        alladdevents{3}=crsaddevents(and(INS_Trials,Rule0_Trials)); 
        alladdevents{4}=crsaddevents(and(INS_Trials,Rule1_Trials));
    case 'BOTH'
        disp_2AFC(recname,datalign,spikechannel,aligncode,'TT');
        disp_2AFC(recname,datalign,spikechannel,aligncode,'Interaction');
        return;
        
end
%% plotting figures: first instructions then rules
% for fignum=1:2
%     AFCplots(fignum)=figure('color','white','position',[20   300  524   636]);
% end

% Pulls up the figure window with set dimensions
AFCplots=figure('color','white','position',[20   20  760   760]);
NC=1; % Number of columns in the plots

Marker_Types={'k+' 'ko' 'k*' 'k.' 'ks' 'kd'};
Indicators={'Rule_Tgt','Rule_Sac','Refix','Dec_Tgt','Dec_Sac','Rew'}; % Of event types
CheckBox=zeros(numrast,length(Indicators));                           % To keep track of if events occur
% TimeInd is created later and designed to allign exactly with the
% Indicators specified above e.g. Indicators{1} is the data for Rule Tgt
    
% start and stop times
start=alignidx - plotstart; if start < 1, start = 1; end
stop=alignidx + plotstop;   % Modifiable based upon data set.

% These determine which indicators are included
TimeMax=plotstop+plotstart;
TimeMin=-plotstart;

for dataset=1:numrast
    
%     %plot on the correct figure
%     if dataset<3
%         figure(AFCplots(1)); % SS vs INS figure
%     else
%         figure(AFCplots(2)); % Rule 0 vs Rule 1 figure
%     end
    
    % get rasters for that particular dataset
    rasters=allrast{dataset};
    if stop > length(rasters), stop = length(rasters); end
    % and events time
    eventstimes=alladdevents{dataset};
    
%     % start and stop times
%     start=alignidx - plotstart;
%     stop=alignidx + plotstop;
%     
%     if start < 1
%         start = 1;
%     end
%     if stop > length(rasters)
%         stop = length(rasters);
%     end
%     
%     % sorting rasters according saccade times
%         sactimes=cellfun(@(x) x(2,1),eventstimes)-start;      %saccade onset (505y)
%         eyefixtimes=cellfun(@(x) x(1,2),eventstimes)-start;   %eye in fixation pt window (585y),
%                                                         %using hacked tgtoffcode
%         [sactimes,sortidx]=sort(sactimes,'ascend');
%         eyefixtimes=eyefixtimes(sortidx);
%         rasters=rasters(sortidx,:);      
    % sorting rasters according saccade times
    ruletgttimes=cellfun(@(x) x(1,1),eventstimes)-start;  %rule target (tgtcode)
    sactimes=cellfun(@(x) x(2,1),eventstimes)-start;      %saccade onset (505y)
    eyefixtimes=cellfun(@(x) x(1,2),eventstimes)-start;   %eye in fixation pt window (585y:tgtoffcode),
    dectgttimes=cellfun(@(x) x(5,1),eventstimes)-start;   %decision targets (605)
    decsactimes=cellfun(@(x) x(6,1),eventstimes)-start;   %sac to decision targets (645)
    rewtimes=cellfun(@(x) x(4,1),eventstimes)-start;      %reward times (rewcode)
                                                   
    [TimeInd{2},sortidx]=sort(sactimes,'ascend');
    TimeInd{1}=ruletgttimes(sortidx);
    TimeInd{4}=dectgttimes(sortidx);
    TimeInd{5}=decsactimes(sortidx);
    TimeInd{3}=eyefixtimes(sortidx);
    TimeInd{6}=rewtimes(sortidx);
    rasters=rasters(sortidx,:); 
    
    %% Plot rasters
%     hrastplot(dataset)=subplot(numsubplot,1,2-mod(dataset,2),'Layer','top', ...
%         'XTick',[],'YTick',[],'XColor','white','YColor','white', 'Parent', gcf);
%     
%     %reducing spacing between rasters
%     rastpos=get(gca,'position');
%     rastpos(2)=rastpos(2)+rastpos(4)*0.5;
%     set(gca,'position',rastpos);

    hrastplot(dataset)=subplot(numsubplot/NC,NC,dataset,'Layer','top', ...
      'XTick',[],'YTick',[],'XColor','white','YColor','white', 'Parent', gcf);

    
    %pre-alloc variable that keeps track of NaN trials
    isnantrial=zeros(1,size(rasters,1));
    
    hold on
    for rastlines=1:size(rasters,1) %plotting rasters trial by trial
        spiketimes=find(rasters(rastlines,start:stop)); %converting from a matrix representation to a time collection, within selected time range
        if isnan(sum(rasters(rastlines,start:stop)))
            isnantrial(rastlines)=1;
            spiketimes(find(isnan(rasters(rastlines,start:stop))))=0; %#ok<FNDSB>
        else
            plot([spiketimes;spiketimes],[ones(size(spiketimes))*rastlines;ones(size(spiketimes))*rastlines-1],...
                'color',cc(dataset,:),'LineStyle','-','LineWidth',1.5);
        end
%        plot(sactimes(rastlines),rastlines-0.5,'kd','MarkerSize', 3,'LineWidth', 0.7)
%        plot(eyefixtimes(rastlines),rastlines-0.5,'kx','MarkerSize', 3,'LineWidth', 0.7)

% Plotting indicative marks if they occur with the wanted time
        % window 
        for ii=1:length(TimeInd)
            plot(TimeInd{ii}(rastlines),rastlines-0.5,Marker_Types{ii},'MarkerSize', 3,'LineWidth', 0.7); 
            if (TimeInd{ii}(rastlines)<TimeMax) && (TimeInd{ii}(rastlines)>TimeMin)  
                CheckBox(dataset,ii)=1;
            end
        end
    end
    set(hrastplot(dataset),'xlim',[1 length(start:stop)]);
    axis(gca, 'off'); % axis tight sets the axis limits to the range of the data.
    if dataset==1
        s1=['File: ',recname ' Clus' num2str(spikechannel) ' - Aligned at ', alignname, poolstr1];
        htitle=title(s1);
        set(htitle,'Interpreter','none','FontName','calibri','FontSize',11);
    end
    
    %% Plot sdf
%    sdfplot(dataset)=subplot(numsubplot,1,(numsubplot/2)+1:(numsubplot/2)+(numsubplot/2),'Layer','top','Parent', gcf);
    sdfplot(dataset)=subplot(numsubplot/NC,NC,[numrast+1:numsubplot],'Layer','top','Parent', gcf);
    %sdfh = axes('Position', [.15 .65 .2 .2], 'Layer','top');
    title('Spike Density Function','FontName','calibri','FontSize',11);
    hold on;
    if size(rasters,1)==1 %if only one good trial,useless plotting this
        sumall=NaN;
    else
        sumall=sum(rasters(~isnantrial,start-fsigma:stop+fsigma));
    end
%     sdf=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead
%     of number of trials
    sdf=fullgauss_filtconv(sumall,fsigma,0)./length(find(~isnantrial)).*1000;  %.*1000 to convert to spk/s
    sdf=sdf(fsigma+1:end-fsigma);
    
    sdflines(dataset)=plot(sdf,'Color',cc(dataset,:),'LineWidth',1.8);
    % Adding indicators to the legend. If an indicator is included then it
    % is plotted at 0,0 and added to sdflines and appended to aligntype.
    % This is only done once all of the rasters have already been plotted.
    if dataset==numrast,
        CheckBox=find(logical(sum(CheckBox)));
        for jj=1:length(CheckBox)
            sdflines(dataset+jj)=plot(0,0,Marker_Types{CheckBox(jj)},'MarkerSize', 3,'LineWidth', 0.7);
            aligntype{dataset+jj}=Indicators{CheckBox(jj)};
        end
    end    
    % Calculating standard errors
    sdfgrid = repmat(sdf, size(rasters(~isnantrial, start-fsigma:stop+fsigma), 1), 1);
    indsdf = spike_density(rasters(~isnantrial, start-fsigma:stop+fsigma), fsigma);
%     indsdf = fullgauss_filtconv(rasters(~isnantrial, start-fsigma:stop+fsigma), fsigma,0);
    indsdf = indsdf(:, fsigma+1:end-fsigma);
    sd = sqrt(sum((indsdf-sdfgrid).^2)./size(rasters(~isnantrial, start-fsigma:stop+fsigma), 1))./sqrt(size(rasters(~isnantrial, start-fsigma:stop+fsigma), 1));

    sdlines(dataset, 1)=plot(sdf+sd, ':', 'Color',cc(dataset, :), 'LineWidth', 1);
    sdlines(dataset, 2)=plot(sdf-sd, ':', 'Color',cc(dataset, :), 'LineWidth', 1);
    
    axis(gca,'tight');
    box off;
    set(gca,'Color','white','TickDir','out','FontName','calibri','FontSize',8);
    hylabel=ylabel(gca,'Firing rate (spikes/s)','FontName','calibri','FontSize',8);
    currylim=get(gca,'YLim');
    
    if ~isempty(rasters) % drawing the alignment bar
        patch([repmat((alignidx-start)-2,1,2) repmat((alignidx-start)+2,1,2)], ...
            [[0 currylim(2)] fliplr([0 currylim(2)])], ...
            [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
    end
    
    
    %% keep sdf
    allsdf{dataset}=sdf;
    clear TimeInd; % Just in case    
end

%% last adjustments and save - routine for multiple figures produced
% for fignum=1:2
%     
%     %% moving rasters if needed
%     if numrast==1
%         allrastpos=get(hrastplot(2*fignum-1:2*fignum),'position');
%         sdfpos=get(sdfplot(2*fignum-1:2*fignum),'position');
%     else
%         allrastpos=cell2mat(get(hrastplot(2*fignum-1:2*fignum),'position'));
%         sdfpos=cell2mat(get(sdfplot(2*fignum-1:2*fignum),'position'));
%     end
%     
%     disttosdf=allrastpos(1,2)-(sdfpos(1,2)+sdfpos(1,4));
%     if disttosdf>0.2
%         allrastpos(:,2)=allrastpos(:,2)-disttosdf/3;
%         if numrast>1
%             allrastpos=mat2cell(allrastpos,ones(1,size(allrastpos,1))); %reconversion to cell .. un brin penible
%             set(hrastplot(2*fignum-1:2*fignum),{'position'},allrastpos);
%         else
%             set(hrastplot(2*fignum-1:2*fignum),'position',allrastpos);
%         end
%     end
%     
%     %% plot a legend in SDF graph
%     
%     hlegdir = legend(sdflines(2*fignum-1:2*fignum), aligntype(2*fignum-1:2*fignum)','Location','NorthEast');
%     set(hlegdir,'Interpreter','none', 'Box', 'off','LineWidth',1.5,'FontName','calibri','FontSize',9);
%     
%     %% setting sdf plot y axis
%     ylimdata=get(findobj(sdfplot(fignum*2),'Type','line'),'YDATA');
%     if ~iscell(ylimdata)
%         ylimdata={ylimdata};
%     end
%     if sum((cell2mat(cellfun(@(x) logical(isnan(sum(x))), ylimdata, 'UniformOutput', false)))) %if NaN data
%         ylimdata=ylimdata(~(cell2mat(cellfun(@(x) logical(isnan(sum(x))),...
%             ylimdata, 'UniformOutput', false))));
%     end
%     if sum(logical(cellfun(@(x) length(x),ylimdata)-1))~=length(ylimdata) %some strange data with a single value
%         ylimdata=ylimdata(logical(cellfun(@(x) length(x),ylimdata)-1));
%     end
%     newylim=[0, ceil(max(max(cell2mat(ylimdata)))/10)*10]; %rounding up to the decimal
%     set(sdfplot(2*fignum-1:2*fignum),'YLim',newylim);
%     % x axis tick labels
%     set(sdfplot(2*fignum-1:2*fignum),'XTick',[0:100:(stop-start)]);
%     set(sdfplot(2*fignum-1:2*fignum),'XTickLabel',[-plotstart:100:plotstop]);
%     
%     %% quantify differential activity
%     
%     %% set title
%     subplots=findobj(AFCplots(fignum),'Type','axes');
%     axespos=cell2mat(get(subplots,'Position'));
%     figtitleh = title(subplots(find(axespos(:,2)==max(axespos(:,2)),1)),...
%         ['File ',recname,' Clus',num2str(spikechannel),' Alignment: ',aligntype{2*fignum-1},' vs ',...
%         aligntype{2*fignum}, ' Aligned at ', alignname, poolstr1]);
%     set(figtitleh,'Interpreter','none');
%     
%     %% condense plot
%     %     set(subplots,'Units','pixels');
%     %     figuresize=getpixelposition(AFCplots(fignum));
%     %     figuresize(4)=figuresize(4)*0.9;
%     %     set(gcf,'position',figuresize);
%     
%     %% save figure
%     % to check if file already exists and open it:
%     % eval(['!' exportfigname '.pdf']);
% if output.savfig
%     comp=fnaligntype{fignum};
%     exportfigname=[directory,'figures\2AFC\',recname,'_',comp,'_Clus',num2str(spikechannel), '_', alignname, poolstr2];
%     %basic png fig:
%     newpos =  get(AFCplots(fignum),'Position')/60;
%     set(AFCplots(fignum),'PaperUnits','inches','PaperPosition',newpos);
%     print(AFCplots(fignum), '-dpng', '-noui', '-opengl','-r600', exportfigname);
%     %vector graphics if needed
%     %     plot2svg([exportfigname,'.svg'],AFCplots(fignum), 'png');
%     delete(AFCplots(fignum)); %if needed
% end
% end

%% last adjustments and save
if ReSize==1
    % 1) Get figure positions
    allrastpos=cell2mat(get(hrastplot,'position'));
    sdfpos=cell2mat(get(sdfplot,'position'));

    disttosdf=allrastpos(numrast,2)-sdfpos(1,2);
    % Note: sdfpos(1,2) is fine as all y elements are identical we'll grab #1

    % This code pushes down all the rasters to be immediate superior to the SDF
    % plot - not sure the reason for this implementation? Cancelled for now.
    if disttosdf>0.2
        allrastpos(:,2)=allrastpos(:,2)-disttosdf/numsubplot;
        allrastpos=mat2cell(allrastpos,ones(1,size(allrastpos,1))); %reconversion to cell .. un brin penible
        set(hrastplot,{'position'},allrastpos);
    end
end

%% plot a legend in SDF graph

hlegdir = legend(sdflines, aligntype','Location','NorthEast');
set(hlegdir,'Interpreter','none', 'Box', 'off','LineWidth',1.5,'FontName','calibri','FontSize',9);

%% setting sdf plot y axis
ylimdata=get(findobj(sdfplot,'Type','line'),'YDATA');
if ~iscell(ylimdata)
    ylimdata={ylimdata};
end
if sum((cell2mat(cellfun(@(x) logical(isnan(sum(x))), ylimdata, 'UniformOutput', false)))) %if NaN data
    ylimdata=ylimdata(~(cell2mat(cellfun(@(x) logical(isnan(sum(x))),...
        ylimdata, 'UniformOutput', false))));
end
if sum(logical(cellfun(@(x) length(x),ylimdata)-1))~=length(ylimdata) %some strange data with a single value
    ylimdata=ylimdata(logical(cellfun(@(x) length(x),ylimdata)-1));
end
newylim=[0, ceil(max(max(cell2mat(ylimdata)))/10)*10]; %rounding up to the decimal
set(sdfplot,'YLim',newylim);
% x axis tick labels
set(sdfplot,'XTick',[0:100:(stop-start)]);
set(sdfplot,'XTickLabel',[-plotstart:100:plotstop]);

%% condense plot
%     set(subplots,'Units','pixels');
%     figuresize=getpixelposition(AFCplots(fignum));
%     figuresize(4)=figuresize(4)*0.9;
%     set(gcf,'position',figuresize);

%% save figure
% to check if file already exists and open it:
% eval(['!' exportfigname '.pdf']);

if output.savfig
    exportfigname=[directory,'figures\2AFC\',recname,'_Clus',num2str(spikechannel), '_', InterAxn '_' alignname, poolstr2];
    %basic png fig:
    newpos =  get(AFCplots,'Position')/60;
    set(AFCplots,'PaperUnits','inches','PaperPosition',newpos);
    print(AFCplots, '-dpng', '-noui', '-opengl','-r600', exportfigname);
    fprintf(' Saved figure\n');
    %vector graphics if needed
    %     plot2svg([exportfigname,'.svg'],AFCplots(fignum), 'png');
    delete(AFCplots); %if needed
end

sdfsave = [directory, 'SDFs/',recname,'_Clus', num2str(spikechannel), '_',alignname, poolstr2, '_SDFs'];
if output.savsdf
    save(sdfsave, 'allsdf');
end
end
