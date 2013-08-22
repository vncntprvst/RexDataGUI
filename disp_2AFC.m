function disp_2AFC(recname,datalign)
% Called from Rex Data GUI when using Ecodes 465 as alignement
% This function will sort data to compare either: 
%   - self-selected vs instructed 
%   - rule 1 vs rule 0
% (will do sub-comparisons later)
%  We keep only trials where rule-selecting saccade was contralateral 
% 8/22/2013 - VP

global directory;
load(recname,'allbad','allcodes','alltimes');  % saccadeInfo probably not needed

%% preallocs and definitions
allsdf=cell(4,1);
allrast=cell(4,1);
% allviscuetimes=cell(2,1);
% allalignidx=cell(2,1);

numrast=2; %ploting two sets of data per figure
fsigma=20;
cc=lines(numrast);
numsubplot=numrast*2; %dividing the panel in three compartments with equal number of subplots  

alignidx=datalign.alignidx;
plotstart=400; %200 ms before alignment time
plotstop=1000; %600 ms after alignment time

%% removing bad trials from codes and times
% first checking we have the right number of good trials
if size(logical(datalign.bad),2)~=size(allbad(~logical(allbad)),2)
    return
end
allgoodcodes=allcodes(~logical(allbad),:);
allgoodtimes=alltimes(~logical(allbad),:);

%% keeping trials with contralateral rule-selecting saccade
crsrasts=datalign.rasters(allgoodcodes(:,17)==1901,:); % rasters
crscodes=allgoodcodes(allgoodcodes(:,17)==1901,:); % ecodes

%% sort trials: SS vs INS
allrast{1}=crsrasts(crscodes(:,2)==1700,:); % Self-selected trials
allrast{2}=crsrasts(crscodes(:,2)==1701,:); % Instructed trials

%% sort trials: Rule 0  vs Rule 1
allrast{3}=crsrasts(crscodes(:,14)==1800,:); % Rule 0 trials
allrast{4}=crsrasts(crscodes(:,14)==1801,:); % Rule 1 trials
    
%% plotting figures: first instructions then rules
INSplots=figure('color','white','position',[826    49   524   636]);
for dataset=1:numrast
 
    rasters=allrast{dataset};
%     greyareas %probably won't need it here
    
    start=alignidx - plotstart;
    stop=alignidx + plotstop;

    if start < 1
        start = 1;
    end
    if stop > length(rasters)
        stop = length(rasters);
    end

    %% Plot rasters
    hrastplot(dataset)=subplot(numsubplot,1,dataset,'Layer','top', ...
            'XTick',[],'YTick',[],'XColor','white','YColor','white', 'Parent', INSplots);

    %reducing spacing between rasters
        rastpos=get(gca,'position');
        rastpos(2)=rastpos(2)+rastpos(4)*0.5;
        set(gca,'position',rastpos);

    %pre-alloc variable that keeps track of NaN trials 
        isnantrial=zeros(1,size(rasters,1));  
        
    hold on
    for rastlines=1:size(rasters,1) %plotting rasters trial by trial
        spiketimes=find(rasters(rastlines,start:stop)); %converting from a matrix representation to a time collection, within selected time range
        if isnan(sum(rasters(rastlines,start:stop)))
            isnantrial(rastlines)=1;
            spiketimes(find(isnan(rasters(rastlines,start:stop))))=0; %#ok<FNDSB>
        else
        plot([spiketimes;spiketimes],[ones(size(spiketimes))*rastlines;ones(size(spiketimes))*rastlines-1],'color',cc(dataset,:),'LineStyle','-');
        end
    end
    set(hrastplot(dataset),'xlim',[1 length(start:stop)]);
    axis(gca, 'off'); % axis tight sets the axis limits to the range of the data.
    
    %% Plot sdf
    sdfplot=subplot(numsubplot,1,(numsubplot/2)+1:(numsubplot/2)+(numsubplot/2),'Layer','top','Parent', INSplots);
    %sdfh = axes('Position', [.15 .65 .2 .2], 'Layer','top');
    title('Spike Density Function','FontName','calibri','FontSize',11);
    hold on;
    if size(rasters,1)==1 %if only one good trial,useless plotting this
        sumall=NaN;
    else
        sumall=sum(rasters(~isnantrial,start-fsigma:stop+fsigma));
    end
    sdf=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead of number of trials
    sdf=sdf(fsigma+1:end-fsigma);
    
    plot(sdf,'Color',cc(dataset,:),'LineWidth',1.8);
 
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
 
    %% keep sdf, rasters etc
    allsdf{dataset}=sdf;

end

%% moving rasters if needed
if numrast==1
    allrastpos=(get(hrastplot,'position'));
else
    allrastpos=cell2mat(get(hrastplot,'position'));
end

disttotop=allrastpos(1,2)+allrastpos(1,4);
if disttotop<0.99 %if not already close to top of container
    allrastpos(:,2)=allrastpos(:,2)+(1-disttotop)/1.5;
elseif disttotop>1
    allrastpos(:,2)=allrastpos(:,2)+(1-disttotop)*1.5;
    allrastpos(2,2)=allrastpos(2,2)+(1-disttotop)*1.5;
end

if numrast>1
    allrastpos=mat2cell(allrastpos,ones(1,size(allrastpos,1))); %reconversion to cell .. un brin penible
    set(hrastplot,{'position'},allrastpos);
else
    set(hrastplot,'position',allrastpos);
end

%% quantify differential activity

%% condense plot
% figuresize=getpixelposition(gcf);
% figuresize(1:2)=[80 167];
figure(1)
 subplots=findobj(gcf,'Type','axes');
%  set(subplots,'Units','pixels')
 axespos=cell2mat(get(subplots,'Position'));
 figtitleh = title(subplots(find(axespos(:,2)==max(axespos(:,2)),1)),...
    ['File: ',recname,' - Task: 2AFC - Alignment: SS vs INS' ]);
set(figtitleh,'Interpreter','none');
% tpos=get(figtitleh,'position');
set(figtitleh,'position',[700 30 1]);


%% saving figure
% to check if file already exists and open it:
% eval(['!' exportfigname '.pdf']);
comp='SSvsINS_ruletgt';
exportfigname=[directory,'figures\2AFC\',recname,'_',comp];
%basic png fig:
newpos =  get(gcf,'Position')/60;
set(gcf,'PaperUnits','inches','PaperPosition',newpos);
print(gcf, '-dpng', '-noui', '-opengl','-r600', exportfigname);
plot2svg([exportfigname,'.svg'],gcf, 'png');
delete(gcf);

end
