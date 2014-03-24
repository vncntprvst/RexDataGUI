function varargout = SummaryPlot(varargin)
% SUMMARYPLOT MATLAB code for SummaryPlot.fig
%      SUMMARYPLOT, by itself, creates a new SUMMARYPLOT or raises the existing
%      singleton*.
%
%      H = SUMMARYPLOT returns the handle to a new SUMMARYPLOT or the handle to
%      the existing singleton*.
%
%      SUMMARYPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUMMARYPLOT.M with the given input arguments.
%
%      SUMMARYPLOT('Property','Value',...) creates a new SUMMARYPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SummaryPlot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SummaryPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SummaryPlot

% Last Modified by GUIDE v2.5 21-Feb-2013 23:14:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SummaryPlot_OpeningFcn, ...
    'gui_OutputFcn',  @SummaryPlot_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before SummaryPlot is made visible.
function SummaryPlot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SummaryPlot (see VARARGIN)
global directory slash;
if strcmp(getenv('username'),'SommerVD') ||...
        strcmp(getenv('username'),'LabV') || ...
        strcmp(getenv('username'),'Purkinje')|| ...
        strcmp(getenv('username'),'JuanandKimi') || ...
        strcmp(getenv('username'),'vp35')
    directory = 'C:\Data\Recordings\';
elseif strcmp(getenv('username'),'DangerZone')
    directory = 'E:\data\Recordings\';
elseif strcmp(getenv('username'),'Radu')
    directory = 'E:\Spike_Sorting\';
elseif strcmp(getenv('username'),'The Doctor')
    directory = 'C:\Users\The Doctor\Data\';
else
    directory = 'B:\data\Recordings\';
end
slash = '\';

% Choose default command line output for SummaryPlot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using SummaryPlot.
if strcmp(get(hObject,'Visible'),'off')
    %    axes(findobj('Tag','defaultaxes'));
    plot(rand(5));
    set(gca,'XTick',[],'YTick',[],'XColor','white','YColor','white','parent',handles.mainfig);%'YDir','reverse'
    box off;
    cla;
end
% set(gcf,'Color','white')

% get the arguments passed to the GUI
global filename tasktype;

%if length(varargin)>3
if 0
    plotstart=str2num(varargin{4});
    plotstop=str2num(varargin{5});
    fsigma=str2num(varargin{6});
    chrono=varargin{7}; %for plotting rasters in chronological order
    causker=varargin{8}; %kernel shape 
else
    plotstart=1000;
    plotstop=500;
    fsigma=10;
    chrono=0; %for plotting rasters in chronological order
    causker=0;
end
    
if length(varargin)>2
    if iscell(varargin{3})
        if size(varargin{3},1)>1
            tasktype = varargin{3};
        else
            tasktype=cell2mat(varargin{3});
        end
    else
        tasktype = varargin{3};
    end
else
    tasktype=[];
end
if length(varargin)>1
    filename=varargin{2};
else
    filename=[];
end
%% for batch processing
if ischar(varargin{1})
    if strfind(varargin{1},'allcx')
        batchplot_as(varargin,handles); %activity summary, without eye evelocity or rasters
    else
        batchplot(varargin,handles);
    end
    return
end
%% for single file display
if strcmp(tasktype,'optiloc')
    optilocplot(varargin,handles);
    return
end

set(findobj('tag','dispfilename'),'string',filename);
set(findobj('tag','disptaskname'),'string',tasktype);

alignedata=struct(varargin{1});
alignment=cell2mat(unique({alignedata.alignlabel}));
set(findobj('tag','dispalignment'),'string',alignment);

%figdimension=get(findobj('tag','mainfig'),'Position');
figdimension=get(gca,'Position');
rasterdim=[figdimension(1)*1.1 (figdimension(4)*0.66)+figdimension(2)*1.1 figdimension(3)*0.9 figdimension(4)*0.3];

cc=lines(length(alignedata));
if size(cc,1)==8
    cc(8,:)=[0 0.75 0];
end
% if chrono
%     cut_chrasters=zeros(length([alignedata.trials]),plotstart+plotstop+1);
% end
numsubplot=length(alignedata)*3; %dividing the panel in three compartments with wequal number of subplots
if numsubplot==3
    numsubplot=6;
end
%setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]);
%Plot rasters
%rastersh = axes('Position', rasterdim, 'Layer','top','XTick',[],'YTick',[],'XColor','white','YColor','white');
numrast=length(alignedata);
for rastnum=1:numrast
    rasters=alignedata(rastnum).rasters;
    alignidx=alignedata(rastnum).alignidx;
    if chrono
       cut_chrasters=zeros(length([alignedata.trials]),plotstart+plotstop+1);
       %listing relevant trials in a continuous series with other rasters
       chronoidx=ismember(sort([alignedata.trials]),alignedata(rastnum).trials); 
    end
    greyareas=alignedata(rastnum).allgreyareas;
    start=alignidx - plotstart;
    stop=alignidx + plotstop;
    
    if start < 1
        start = 1;
    end
    if stop > length(rasters)
        stop = length(rasters);
    end
    
    %trials = size(rasters,1);
    isnantrial=zeros(1,size(rasters,1));
    
    if chrono
        onerastplot=subplot(numsubplot,1,1:(numsubplot/3),'Layer','top', ...
            'XTick',[],'YTick',[],'XColor','white','YColor','white', 'Parent', handles.mainfig);
    else
        if numrast==1
            hrastplot(rastnum)=subplot(numsubplot,1,1:2,'Layer','top', ...
                'XTick',[],'YTick',[],'XColor','white','YColor','white', 'Parent', handles.mainfig);
        else
            hrastplot(rastnum)=subplot(numsubplot,1,rastnum,'Layer','top', ...
                'XTick',[],'YTick',[],'XColor','white','YColor','white', 'Parent', handles.mainfig);
        end
    end
    %reducing spacing between rasters
    if numrast>1 && ~chrono
        rastpos=get(gca,'position');
        rastpos(2)=rastpos(2)+rastpos(4)*0.5;
        set(gca,'position',rastpos);
    end
    
    % sorting rasters according greytime
    viscuetimes=nan(size(greyareas,2),2);
    for grst=1:size(greyareas,2)
        viscuetimes(grst,:)=greyareas{grst}(1,:);
    end
    
    if ~chrono
        cuestarts=viscuetimes(:,1);
        [~,sortidx]=sort(cuestarts,'descend');
        viscuetimes=viscuetimes(sortidx,:);
        rasters=rasters(sortidx,:);
    end
    
    hold on
    
        cut_rasters = rasters(:,start:stop); % Isolate rasters of interest
        cut_rast_siz = size(cut_rasters);
        isnantrial = isnan(sum(cut_rasters,2)); % Identify nantrials
        cut_rasters(isnan(cut_rasters)) = 0; % take nans out so they don't get plotted
        if chrono
            cut_chrasters(chronoidx,:)=cut_rasters;
            [indy, indx] = ind2sub(size(cut_chrasters),find(cut_chrasters)); %find row and column coordinates of spikes
        else
            [indy, indx] = ind2sub(size(cut_rasters),find(cut_rasters)); %find row and column coordinates of spikes
        end
        
        
            if(size(rasters,1) == 1)
                plot([indx;indx],[indy;indy+1],'color',cc(rastnum,:),'LineStyle','-'); % plot rasters
            else
                plot([indx';indx'],[indy';indy'+1],'color',cc(rastnum,:),'LineStyle','-'); % plot rasters
            end
            
        % drawing the grey areas
        try
            greytimes=viscuetimes-start;
            greytimes(greytimes<0)=0;
            greytimes(greytimes>(stop-start+1))=stop-start+1;
        catch
            greytimes=0;
        end

        if ~sum(sum(isnan(greytimes))) && logical(sum(sum(greytimes))) && ~chrono
            grxlims=[greytimes';greytimes(:,2:-1:1)'];
            grylims=[1:size(grxlims,2);1:size(grxlims,2);2:size(grxlims,2)+1;2:size(grxlims,2)+1];
            patch(grxlims, grylims, [0 0 0], 'EdgeColor', 'none','FaceAlpha', 0.2)
        end

    set(gca,'xlim',[1 length(start:stop)]);
    axis(gca, 'off'); % axis tight sets the axis limits to the range of the data.
    
    
    %% Plot sdf
    sdfplot=subplot(numsubplot,1,(numsubplot/3)+1:(numsubplot/3)+(numsubplot/3),'Layer','top','Parent', handles.mainfig);
    %sdfh = axes('Position', [.15 .65 .2 .2], 'Layer','top');
    title('Spike Density Function','FontName','calibri','FontSize',11);
    hold on;
    if size(rasters(~isnantrial,:),1)<5 %if less than 5 good trials
        %useless plotting this
        sumall=NaN;
    else
        sumall=sum(rasters(~isnantrial,start-fsigma:stop+fsigma));
    end
    %     sdf=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead of number of trials
    sdf=fullgauss_filtconv(sumall,fsigma,causker)./length(find(~isnantrial)).*1000;
    sdf=sdf(fsigma+1:end-fsigma);
    
    %% calculate confidence intervals
    lcut_rasters=rasters(~isnantrial,start-fsigma:stop+fsigma);
    smoothtrial=zeros(size(lcut_rasters));
    for crsem=1:size(rasters(~isnantrial),1)
        smoothtrial(crsem,:)=fullgauss_filtconv(lcut_rasters(crsem,:),fsigma,causker).*1000; 
    end
    smoothtrial=smoothtrial(:,fsigma+1:end-fsigma);
    if numrast==2 && rastnum==1  %collect old trials
          first_smtrials=smoothtrial;
    end
    rastsem=std(smoothtrial)/ sqrt(size(smoothtrial,1)); %standard error of the mean
    %norminv([.025 .975], mean(smoothtrial), std(smoothtrial));
    rastsem = rastsem * 1.96; % 95% of the data will fall within 1.96 standard deviations of a normal distribution
    
    % testif significant diff
    %         differential spike density
%  function exceeded by 2 SD the mean difference in activity
%  during the 600-ms interval before target presentation, pro
% vided the difference reached 6 SD and remained >2 SD
% threshold for 50 ms.

        if numrast==2 && rastnum==numrast
        diff_trials=mean(first_smtrials)-mean(smoothtrial);
        diff_preal_epoch=diff_trials(alignidx-start-200:alignidx-start);
        difftime_preal=find(abs(diff_preal_epoch)>2*(std(diff_preal_epoch)),1);
        diff_postal_epoch=diff_trials(alignidx-start:alignidx-start+200);
        difftime_postal=find(abs(diff_postal_epoch)>2*(std(diff_postal_epoch)),1);
            if ~isempty(difftime_preal)
                %recursive time search
                difftime_preal=difftime_preal-find(abs(diff_trials(alignidx-start-200+difftime_preal+1:-1:1))<=2*(std(diff_preal_epoch)),1);
                difftime_preal=alignidx-start-200+1+difftime_preal;
            end
            if ~isempty(difftime_postal)
                %recursive time search
                difftime_postal=difftime_postal-find(abs(diff_trials(alignidx-start+difftime_postal+1:-1:1))<=2*(std(diff_preal_epoch)),1);
                difftime_postal=alignidx-start+1+difftime_postal;
            end
        else
            difftime_preal=[];
            difftime_postal=[];
        end
  if size(rasters(~isnantrial,:),1)>=5      
     %    plot confidence intervals
    patch([1:length(sdf),fliplr(1:length(sdf))],[sdf-rastsem,fliplr(sdf+rastsem)],cc(rastnum,:),'EdgeColor','none','FaceAlpha',0.1);
    %plot sdf
    plot(sdf,'Color',cc(rastnum,:),'LineWidth',1.8);
    
     if ~isempty(difftime_preal)
         plot(difftime_preal,max([sdf(difftime_preal)-40 1]),'r*')
     end
     if ~isempty(difftime_postal)
         plot(difftime_postal,max([sdf(difftime_postal)-40 1]),'r*')
     end
  end
  
    % axis([0 stop-start 0 200])
    axis(gca,'tight');
    box off;
    set(gca,'Color','white','TickDir','out','FontName','calibri','FontSize',8); %'YAxisLocation','rigth'
    %     hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
    %     set(hxlabel,'Position',get(hxlabel,'Position') - [180 -0.2 0]); %doesn't stay there when export !
    hylabel=ylabel(gca,'Firing rate (spikes/s)','FontName','calibri','FontSize',8);
    currylim=get(gca,'YLim');
    
    if ~isempty(rasters)
        % drawing the alignment bar
        patch([repmat((alignidx-start)-2,1,2) repmat((alignidx-start)+2,1,2)], ...
            [[0 currylim(2)] fliplr([0 currylim(2)])], ...
            [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
    end
    
    %Plot eye velocities
    heyevelplot=subplot(numsubplot,1,(numsubplot*2/3)+1:numsubplot,'Layer','top','Parent', handles.mainfig);
    title('Mean Eye Velocity','FontName','calibri','FontSize',11);
    hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
    
    hold on;
    if ~isempty(rasters)
        eyevel=alignedata(rastnum).eyevel;
        eyevel=mean(eyevel(:,start:stop));
        heyevelline(rastnum)=plot(eyevel,'Color',cc(rastnum,:),'LineWidth',1);
        %axis(gca,'tight');
        eyevelymax=max(eyevel);
        if eyevelymax>0.8
            eyevelymax=eyevelymax*1.1;
        else
            eyevelymax=0.8;
        end
        axis([0 stop-start 0 eyevelymax]);
        set(gca,'Color','none','TickDir','out','FontSize',8,'FontName','calibri','box','off');
        ylabel(gca,'Eye velocity (deg/ms)','FontName','calibri','FontSize',8);
        patch([repmat((alignidx-start)-2,1,2) repmat((alignidx-start)+2,1,2)], ...
            [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
            [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
        
        % get directions for the legend
        curdir{rastnum}=alignedata(rastnum).dir;
        aligntype{rastnum}=alignedata(rastnum).alignlabel;
    else
        curdir{rastnum}='no';
        aligntype{rastnum}='data';
    end
end
%moving up all rasters now
if chrono
    allrastpos=get(onerastplot,'position');
else
    if numrast==1
        allrastpos=get(hrastplot,'position');
    else
        allrastpos=cell2mat(get(hrastplot,'position'));
    end
end

disttotop=allrastpos(1,2)+allrastpos(1,4);
if disttotop<0.99 %if not already close to top of container
    allrastpos(:,2)=allrastpos(:,2)+(1-disttotop)/1.5;
end
if chrono
    set(onerastplot,'position',allrastpos);
else
    if numrast>1
        allrastpos=mat2cell(allrastpos,ones(1,size(allrastpos,1))); %reconversion to cell .. un brin penible
        set(hrastplot,{'position'},allrastpos);
    else
        set(hrastplot,'position',allrastpos);
    end
end
%moving down the eye velocity plot
eyevelplotpos=get(heyevelplot,'position');
eyevelplotpos(1,2)=eyevelplotpos(1,2)-(eyevelplotpos(1,2))/1.5;
set(heyevelplot,'position',eyevelplotpos);
% x axis tick labels
set(heyevelplot,'XTick',[0:100:(stop-start)]);
set(heyevelplot,'XTickLabel',[-plotstart:100:plotstop]);

% plot a legend in this last graph
clear spacer
spacer(1:numrast,1)={' '};
%cellfun('isempty',{alignedata(:).dir})
if  logical(sum(cell2mat(strfind(aligntype,'error1'))) || sum(cell2mat(strfind(aligntype,'error2'))))
    aligntype{~cellfun(@(x) (strcmp(x,'error1') || strcmp(x,'error2')), aligntype)}=...
        ['good trial ' aligntype{~cellfun(@(x) (strcmp(x,'error1') || strcmp(x,'error2')), aligntype)}];
    aligntype(cellfun(@(x) (strcmp(x,'error1') || strcmp(x,'error2')), aligntype))={'wrong trial'};
    
end
hlegdir = legend(heyevelline, strcat(aligntype',spacer,curdir'),'Location','NorthWest');
set(hlegdir,'Interpreter','none', 'Box', 'off','LineWidth',1.5,'FontName','calibri','FontSize',9);


% setting sdf plot y axis
ylimdata=get(findobj(sdfplot,'Type','line'),'YDATA');
if ~iscell(ylimdata)
    ylimdata={ylimdata};
end
if sum((cell2mat(cellfun(@(x) logical(isnan(sum(x))), ylimdata, 'UniformOutput', false)))) %if NaN data
%     ylimdata=ylimdata(~(cell2mat(cellfun(@(x) logical(isnan(sum(x))),...
%         ylimdata, 'UniformOutput', false)))); 
% I think I went overboard with that one. Much simpler:
ylimdata={ylimdata{1}(~isnan(ylimdata{:}))};
end
if sum(logical(cellfun(@(x) length(x),ylimdata)-1))~=length(ylimdata) %some strange data with a single value
    ylimdata=ylimdata(logical(cellfun(@(x) length(x),ylimdata)-1));
end
newylim=[0, ceil(max(max(cell2mat(ylimdata)))/10)*10]; %rounding up to the decimal
set(sdfplot,'YLim',newylim);
% x axis tick labels
set(sdfplot,'XTick',[0:100:(stop-start)]);
set(sdfplot,'XTickLabel',[-plotstart:100:plotstop]);



function batchplot_as(arguments,handles)
global directory slash;
if ~isdir([directory,'figures',slash,arguments{1}])
    mkdir([directory,'figures',slash,arguments{1}]);
end
filelist=arguments{2};
infolist=arguments{3};
algdir=[directory,'processed',slash,'aligned',slash];
for algfile=1:length(filelist)
    filename=filelist{algfile};
    fileinfo=infolist(algfile,:);
    set(findobj('tag','dispfilename'),'string',filename);
    set(findobj('tag','disptaskname'),'string',fileinfo{1});
    
    load([algdir,filename,'_sac.mat']);
    alignment=dataaligned(1,1).savealignname(max(strfind(dataaligned(1,1).savealignname,'_'))+1:end);
    set(findobj('tag','dispalignment'),'string',alignment);
    
    figuresize=getpixelposition(handles.mainfig);
    figuresize(1:2)=[80 167];
    exportfigname=[directory,'figures',slash,arguments{1},slash,filename,'_',fileinfo{1},'_',fileinfo{2}];
    exportfig=figure('color','white','position',figuresize);
    %figdimension=get(findobj('tag','mainfig'),'Position');
    
    %   rasterdim=[figuresize(1)*1.1 (figuresize(4)*0.66)+figuresize(2)*1.1 figuresize(3)*0.9 figuresize(4)*0.3];
    
    plotstart=600;
    plotstop=500;
    fsigma=20;
    causeker = 0;
    cc=lines(length(dataaligned));
    
    % numsubplot=length(dataaligned)*3; %dividing the panel in three compartments with wequal number of subplots
    % if numsubplot==3
    %     numsubplot=6;
    % end
    %
    numrast=length(dataaligned);
    % failed=zeros(numrast,1);
    clear hsdfline aligntype curdir;
    
    %% Plot sdf for best direction
    gooddirs=find(arrayfun(@(x) nansum(x{:}.h), {dataaligned(~cellfun(@isempty, {dataaligned.stats})).stats}));
    maxmeandiffs=arrayfun(@(x) max(x{:}.p), {dataaligned(gooddirs).stats});
    bestdir=gooddirs(maxmeandiffs==max(maxmeandiffs));
    
    bdrasters=dataaligned(bestdir).rasters;
    bdalignidx=dataaligned(bestdir).alignidx;
    
    if ~ isempty(bdrasters)
        start=bdalignidx - plotstart;
        stop=bdalignidx + plotstop;
        if start < 1
            start = 1;
        end
        if stop > length( bdrasters )
            stop = length( bdrasters );
        end
        
        isnantrial=zeros(1,size(bdrasters,1));
        
        for rastpos=1:size(bdrasters,1) %plotting rasters trial by trial
            if isnan(sum(bdrasters(rastpos,start:stop)))
                isnantrial(rastpos)=1;
                bdrasters(rastpos,isnan(bdrasters(rastpos,:)))=0;
            end
        end
        
        sdfplot_bestdir=subplot(3,1,1,'Layer','top');%,'Parent', handles.mainfig
        %sdfh = axes('Position', [.15 .65 .2 .2], 'Layer','top');
        %title('SDF: best direction','FontName','calibri','FontSize',11);
        hold on;
        if size(bdrasters,1)==1 %if only one good trial
            sumall=bdrasters(~isnantrial,start-fsigma:stop+fsigma);
        else
            sumall=sum(bdrasters(~isnantrial,start-fsigma:stop+fsigma));
        end
        %             bdsdf=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead of number of trials
        bdsdf=fullgauss_filtconv(sumall,fsigma,causker)./length(find(~isnantrial)).*1000;
        bdsdf=bdsdf(fsigma+1:end-fsigma);
        
        bdsdfline=plot(bdsdf,'Color',[0.4389    0.1111    0.2581],'LineWidth',1.8);
        % axis([0 stop-start 0 200])
        axis(gca,'tight');
        %             currylim=get(gca,'YLim');
        %             set(gca,'Ylim',[0 currylim(2)]);
        box off;
        set(gca,'Color','white','TickDir','out','FontName','calibri','FontSize',8); %'YAxisLocation','rigth'
        %     hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
        %     set(hxlabel,'Position',get(hxlabel,'Position') - [180 -0.2 0]); %doesn't stay there when export !
        hylabel=ylabel(gca,'Firing rate (spikes/s)','FontName','calibri','FontSize',8);
        currylim=get(gca,'YLim');
        
        % drawing the alignment bar
        patch([repmat((bdalignidx-start)-2,1,2) repmat((bdalignidx-start)+2,1,2)], ...
            [[0 currylim(2)] fliplr([0 currylim(2)])], ...
            [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
        axis(gca,'tight');
        ylimst=round(currylim(2)/10)*10;
        %              hlegbdsdf = legend(bdsdfline, 'Best Direction' ,'Location','NorthEast'); % strcat(aligntype',spacer,curdir')
        %              set(hlegbdsdf,'Interpreter','none', 'Box', 'off','LineWidth',1.5,'FontName','calibri','FontSize',9);
        text(50,ylimst,['Active: ',num2str(fileinfo{9})],'Interpreter','none','LineWidth',1.5,'FontName','calibri','FontSize',9);
        text(50,ylimst*(85/100),['MMD: ',num2str(fileinfo{10})],'Interpreter','none','LineWidth',1.5,'FontName','calibri','FontSize',9);
        text(50,ylimst*(71/100),fileinfo{2},'Interpreter','none','LineWidth',1.5,'FontName','calibri','FontSize',9);
        text(50,ylimst*(57/100),fileinfo{3},'Interpreter','none','LineWidth',1.5,'FontName','calibri','FontSize',9);
        text(200,ylimst*(57/100),fileinfo{4},'Interpreter','none','LineWidth',1.5,'FontName','calibri','FontSize',9);
        %text(150,200,fileinfo{5},'Interpreter','none','LineWidth',1.5,'FontName','calibri','FontSize',9);
        text(50,ylimst*(42/100),fileinfo{6},'Interpreter','none','LineWidth',1.5,'FontName','calibri','FontSize',9);
        text(50,ylimst*(28/100),fileinfo{7},'Interpreter','none','LineWidth',1.5,'FontName','calibri','FontSize',9);
        
    end
    %% Plot sdf for all directions collapsed together
    colsdf=nan(numrast,abs(plotstart-plotstop)+1);
    for rstplt=1:numrast
        colrasters=dataaligned(rstplt).rasters;
        colalignidx=dataaligned(rstplt).alignidx;
        
        if ~ isempty(colrasters)
            start=colalignidx - plotstart;
            stop=colalignidx + plotstop;
            if start < 1
                start = 1;
            end
            if stop > length( colrasters )
                stop = length( colrasters );
            end
            
            isnantrial=zeros(1,size(colrasters,1));
            
            for rastpos=1:size(colrasters,1) %plotting rasters trial by trial
                if isnan(sum(colrasters(rastpos,start:stop)))
                    isnantrial(rastpos)=1;
                    colrasters(rastpos,isnan(colrasters(rastpos,:)))=0;
                end
            end
            
            if size(colrasters,1)==1 %if only one good trial
                sumall=colrasters(~isnantrial,start:stop);
            else
                sumall=sum(colrasters(~isnantrial,start:stop));
            end
            
            colsdf(rstplt,1:length(sumall))=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead of number of trials
            
        end
    end
    colsdf=nansum(colsdf)./size(colsdf,1);
    colplot_alldir=subplot(3,1,2,'Layer','top');%,'Parent', handles.mainfig
    %sdfh = axes('Position', [.15 .65 .2 .2], 'Layer','top');
    title('SDF: all directions collapsed','FontName','calibri','FontSize',11);
    hold on;
    
    colsdfline=plot(colsdf,'Color',[0.8212    0.0154    0.0430],'LineWidth',1.8);
    % axis([0 stop-start 0 200])
    axis(gca,'tight');
    %             currylim=get(gca,'YLim');
    %             set(gca,'Ylim',[0 currylim(2)]);
    box off;
    set(gca,'Color','white','TickDir','out','FontName','calibri','FontSize',8); %'YAxisLocation','rigth'
    %     hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
    %     set(hxlabel,'Position',get(hxlabel,'Position') - [180 -0.2 0]); %doesn't stay there when export !
    hylabel=ylabel(gca,'Firing rate (spikes/s)','FontName','calibri','FontSize',8);
    currylim=get(gca,'YLim');
    
    % drawing the alignment bar
    patch([repmat((colalignidx-start)-2,1,2) repmat((colalignidx-start)+2,1,2)], ...
        [[0 currylim(2)] fliplr([0 currylim(2)])], ...
        [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
    axis(gca,'tight');
    
    hlegcolsdf = legend(colsdfline, 'all directions' ,'Location','NorthWest'); % strcat(aligntype',spacer,curdir')
    set(hlegcolsdf,'Interpreter','none', 'Box', 'off','LineWidth',1.5,'FontName','calibri','FontSize',9);
    
    %% plot sdf for all directions separately
    
    sdfplot=subplot(3,1,3,'Layer','top');%,'Parent', handles.mainfig
    %sdfh = axes('Position', [.15 .65 .2 .2], 'Layer','top');
    title('SDF: all directions','FontName','calibri','FontSize',11);
    hold on;
    
    for rstplt=1:numrast
        rasters=dataaligned(rstplt).rasters;
        alignidx=dataaligned(rstplt).alignidx;
        %         greyareas=dataaligned(rstplt).allgreyareas;
        
        if ~ isempty(rasters)
            start=alignidx - plotstart;
            stop=alignidx + plotstop;
            if start < 1
                start = 1;
            end
            if stop > length( rasters )
                stop = length( rasters );
            end
            
            trials = size(rasters,1);
            isnantrial=zeros(1,size(rasters,1));
            %% plotting rasters (removed)
            %     if numrast==1
            %         hrastplot(rstplt)=subplot(numsubplot,1,1:2,'Layer','top', ...
            %         'XTick',[],'YTick',[],'XColor','white','YColor','white');%'Parent', handles.mainfig
            %     else
            %         hrastplot(rstplt)=subplot(numsubplot,1,rstplt,'Layer','top', ...
            %         'XTick',[],'YTick',[],'XColor','white','YColor','white');%'Parent', handles.mainfig
            %     end
            %     %reducing spacing between rasters
            %     if numrast>1
            %         rastpos=get(gca,'position');
            %         rastpos(2)=rastpos(2)+rastpos(4)*0.5;
            %         set(gca,'position',rastpos);
            %     end
            %
            %     % sorting rasters according greytime
            %     viscuetimes=nan(size(greyareas,2),2);
            %     for grst=1:size(greyareas,2)
            %         viscuetimes(grst,:)=greyareas{grst}(1,:);
            %     end
            %     cuestarts=viscuetimes(:,1);
            %     try
            %         [cuestarts,sortidx]=sort(cuestarts,'descend');
            %     catch
            %         sortidx=[1:size(viscuetimes,1)];
            %     end
            %     viscuetimes=viscuetimes(sortidx,:);
            %     if size(rasters,1)<length(sortidx)
            %         % ca deconne
            %         size(rasters,1)
            %     else
            %     rasters=rasters(sortidx,:);
            %     end
            %
            %     %axis([0 stop-start+1 0 size(rasters,1)]);
            %     hold on
            %     for rastpos=1:size(rasters,1) %plotting rasters trial by trial
            %         if isnan(sum(rasters(rastpos,start:stop)))
            %             isnantrial(rastpos)=1;
            %             rasters(rastpos,isnan(rasters(rastpos,:)))=0;
            %         end
            %         spiketimes=find(rasters(rastpos,start:stop)); %converting from a matrix representation to a time collection, within selected time range
            %         plot([spiketimes;spiketimes],[ones(size(spiketimes))*rastpos;ones(size(spiketimes))*rastpos-1],'color',cc(rstplt,:),'LineStyle','-');
            %
            %         % drawing the grey areas
            %         try
            %             greytimes=viscuetimes(rastpos,:)-start;
            %             greytimes(greytimes<0)=0;
            %             greytimes(greytimes>(plotstart+plotstop))=plotstart+plotstop;
            %         catch %grey times out of designated period's limits
            %             greytimes=0;
            %         end
            % %         diffgrey = find(diff(greytimes)>1); % In case the two grey areas overlap, it doesn't discriminate.
            % %                                             % But that's not a problem
            % %         diffgreytimes = greytimes(diffgrey);
            %         if ~sum(isnan(greytimes)) && logical(sum(greytimes))
            %         patch([greytimes(1) greytimes(end) greytimes(end) greytimes(1)],[rastpos rastpos rastpos-1 rastpos-1],...
            %             [0 0 0], 'EdgeColor', 'none','FaceAlpha', 0.3);
            %         end
            % %         if diffgreytimes % multiple grey areas
            % %             %we'll see that later
            % %             diffgreytimes
            % %             pause
            % %         end
            %
            %     end
            %     axis(gca, 'off', 'tight');
            
            
            %%
            %     if exist('sdfplot','var')
            %         clf(sdfplot);
            %     end
            % for rastpos=1:size(rasters,1)
            
            if size(rasters,1)==1 %if only one good trial
                sumall=rasters(~isnantrial,start:stop);
            else
                sumall=sum(rasters(~isnantrial,start:stop));
            end
            sdfline=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead of number of trials
            
            hsdfline(rstplt)=plot(sdfline,'Color',cc(rstplt,:),'LineWidth',1.8);
            % axis([0 stop-start 0 200])
            axis(gca,'tight');
            box off;
            set(gca,'Color','white','TickDir','out','FontName','calibri','FontSize',8); %'YAxisLocation','rigth'
            %     hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
            %     set(hxlabel,'Position',get(hxlabel,'Position') - [180 -0.2 0]); %doesn't stay there when export !
            hylabel=ylabel(gca,'Firing rate (spikes/s)','FontName','calibri','FontSize',8);
            currylim=get(gca,'YLim');
            
            % drawing the alignment bar
            patch([repmat((alignidx-start)-2,1,2) repmat((alignidx-start)+2,1,2)], ...
                [[0 currylim(2)] fliplr([0 currylim(2)])], ...
                [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
            %% get directions for the legend
            %curdir{rstplt}=dataaligned(rstplt).dir;
            sacdeg=nan(size(dataaligned(1,rstplt).trials,2),1);
            for eyetr=1:size(dataaligned(1,rstplt).trials,2)
                thissach=dataaligned(1,rstplt).eyeh(eyetr,dataaligned(1,rstplt).alignidx:dataaligned(1,rstplt).alignidx+100);
                thissacv=dataaligned(1,rstplt).eyev(eyetr,dataaligned(1,rstplt).alignidx:dataaligned(1,rstplt).alignidx+100);
                minwidth=5;
                [~, ~, thissacvel, ~, ~, ~] = cal_velacc(thissach,thissacv,minwidth);
                peakvel=find(thissacvel==max(thissacvel),1);
                sacendtime=peakvel+find(thissacvel(peakvel:end)<=...
                    (min(thissacvel(peakvel:end))+(max(thissacvel(peakvel:end))-min(thissacvel(peakvel:end)))/10),1);
                try
                    sacdeg(eyetr)=abs(atand((thissach(sacendtime)-thissach(1))/(thissacv(sacendtime)-thissacv(1))));
                catch
                    thissacv;
                end
                
                % sign adjustements
                if thissacv(sacendtime)<thissacv(1) % negative vertical amplitude -> vertical flip
                    sacdeg(eyetr)=180-sacdeg(eyetr);
                end
                if thissach(sacendtime)>thissach(1)%inverted signal: leftward is in postive range. Correcting to negative.
                    sacdeg(eyetr)=360-sacdeg(eyetr); % mirror image;
                end
            end
            % a quick fix to be able to put "upwards" directions together
            distrib=hist(sacdeg,3); %floor(length(sacdeg)/2)
            if max(bwlabel(distrib,4))>1 && distrib(1)>1 && distrib(end)>1 %=bimodal distribution with more than 1 outlier
                sacdeg=sacdeg+45;
                sacdeg(sacdeg>360)=-(360-(sacdeg(sacdeg>360)-45));
                sacdeg(sacdeg>0)= sacdeg(sacdeg>0)-45;
            end
            sacdeg=abs(median(sacdeg));
            
            if sacdeg>45/2 && sacdeg <= 45+45/2
                curdir{rstplt}='up_right';
            elseif sacdeg>45+45/2 && sacdeg <= 90+45/2
                curdir{rstplt}='rightward';
            elseif sacdeg>90+45/2 && sacdeg <= 135+45/2
                curdir{rstplt}='down_right';
            elseif sacdeg>135+45/2 && sacdeg < 180+45/2
                curdir{rstplt}='downward';
            elseif sacdeg>=180+45/2 && sacdeg <= 225+45/2
                curdir{rstplt}='down_left';
            elseif sacdeg>225+45/2 && sacdeg <= 270+45/2
                curdir{rstplt}='leftward';
            elseif sacdeg>270+45/2 && sacdeg <= 315+45/2
                curdir{rstplt}='up_left';
            else
                curdir{rstplt}='upward';
            end
            %get alignement type
            aligntype{rstplt}=dataaligned(rstplt).alignlabel;
        else
            curdir{rstplt}='data';
            aligntype{rstplt}='no';
            failed(rstplt)=1;
        end
        %% Plot eye velocities
        %     heyevelplot=subplot(numsubplot,1,(numsubplot*2/3)+1:numsubplot,'Layer','top');%,'Parent', handles.mainfig
        %     title('Mean Eye Velocity','FontName','calibri','FontSize',11);
        %     hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
        %
        %     hold on;
        %
        %     eyevel=dataaligned(rstplt).eyevel;
        %     eyevel=mean(eyevel(:,start:stop));
        %     heyevelline(rstplt)=plot(eyevel,'Color',cc(rstplt,:),'LineWidth',1);
        %     %axis(gca,'tight');
        %     eyevelymax=max(eyevel);
        %     if eyevelymax>0.8
        %         eyevelymax=eyevelymax*1.1;
        %     else
        %         eyevelymax=0.8;
        %     end
        %     axis([0 stop-start 0 eyevelymax]);
        %     set(gca,'Color','none','TickDir','out','FontSize',8,'FontName','calibri','box','off');
        %     ylabel(gca,'Eye velocity (deg/ms)','FontName','calibri','FontSize',8);
        %     patch([repmat((alignidx-start)-2,1,2) repmat((alignidx-start)+2,1,2)], ...
        %         [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
        %         [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
        
    end
    %moving up all rasters now
    %     if numrast==1
    %         allrastpos=(get(hrastplot,'position'));
    %     else
    %         allrastpos=cell2mat(get(hrastplot(~failed),'position'));
    %     end
    %
    %     disttotop=allrastpos(1,2)+allrastpos(1,4);
    %     if disttotop<0.99 %if not already close to top of container
    %         allrastpos(:,2)=allrastpos(:,2)+(1-disttotop)/1.5;
    %     end
    %     if numrast>1
    %         allrastpos=mat2cell(allrastpos,ones(1,size(allrastpos,1))); %reconversion to cell .. un brin penible
    %         set(hrastplot(~failed),{'position'},allrastpos);
    %     else
    %         set(hrastplot,'position',allrastpos);
    %     end
    %
    %     %moving down the eye velocity plot
    %     eyevelplotpos=get(heyevelplot,'position');
    %     eyevelplotpos(1,2)=eyevelplotpos(1,2)-(eyevelplotpos(1,2))/1.5;
    %     set(heyevelplot,'position',eyevelplotpos);
    
    % plot a legend in this last graph
    clear spacer
    spacer(1:numrast,1)={' '};
    hlegdir = legend(hsdfline, strcat(aligntype',spacer,curdir'),'Location','NorthWest');
    set(hlegdir,'Interpreter','none', 'Box', 'off','LineWidth',1.5,'FontName','calibri','FontSize',9);
    
    % setting sdf plot y axis
    newylim=[0, ceil(max(max(cell2mat(get(findobj(sdfplot,'Type','line'),'YDATA'))))/10)*10]; %rounding up to the decimal
    set(sdfplot,'YLim',newylim);
    %eventdata={algfile,aligntype};
    %exportfig_Callback(findobj('tag','exportfig'), eventdata, handles);
    %% copied from export_callback
    
    % for k=1:length(subplots)
    %     copyobj(subplots(k),exportfig);
    % end
    %increase figure height to leave space for the title
    %first change axes units to pixels, so that they don't rescale
    allaxes=findobj(exportfig,'Type','axes');
    %     set(allaxes,'Units','pixels');
    %     figuresize(4)=figuresize(4)+20;
    %     set(exportfig,'position',figuresize);
    %putting title
    axespos=cell2mat(get(allaxes,'Position'));
    figtitleh = title(allaxes(find(axespos(:,2)==max(axespos(:,2)),1)),...
        ['File: ',filename,' - Task: ',fileinfo{1},' - Location: ',fileinfo{3}]);
    set(figtitleh,'Interpreter','none'); %that prevents underscores turning charcter into subscript
    % and moving everything up a bit
    %     axespos(:,2)=axespos(:,2)+5; %units in pixels now
    %     axespos=mat2cell(axespos,ones(size(axespos,1),1)); %reconversion
    %     set(allaxes,{'Position'},axespos);
    %and the title a little bit more
    titlepos=get(figtitleh,'position');
    titlepos(2)=titlepos(2)+titlepos(2)/10;
    set(figtitleh,'position',titlepos,'FontName','calibri','FontSize',11);
    %changing units back to relative, in case we want to resize the figure
    set(allaxes,'Units','normalized')
    % remove time label on first two sdf plot
    %     set(allaxes(4),'XTickLabel','');
    %     set(allaxes(5),'XTickLabel','');
    %% saving figure
    %basic png fig:
    print(gcf, '-dpng', '-noui', '-opengl','-r600', exportfigname);
    delete(exportfig);
    %% end copied section
    % figure(guifigh);
    % allcurax=findall(guifigh,'type','axes');
    % for axnum=1:length(allcurax)
    % cla(allcurax(axnum))
    % end
    %clf('reset')
end

% UIWAIT makes SummaryPlot wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function batchplot(arguments,handles)
global directory slash;
if ~isdir([directory,'figures',slash,arguments{1}])
    mkdir([directory,'figures',slash,arguments{1}])
end
if size(arguments(2),1)==1
    filelist=arguments(2);
else
    filelist=arguments{2};
end
tasklist=arguments{3};
algdir=[directory,'processed',slash,'aligned',slash];
for algfile=1:length(filelist)
    filename=filelist{algfile};
    if size(tasklist, 1) == 1
        tasktype=tasklist;
    else
        tasktype=tasklist{algfile};
    end
    set(findobj('tag','dispfilename'),'string',filename);
    set(findobj('tag','disptaskname'),'string',tasktype);
    if length(arguments)<4
        load([algdir,filename,'_sac.mat']);
        alignment=dataaligned(1,1).savealignname(max(strfind(dataaligned(1,1).savealignname,'_'))+1:end);
    else
        dataaligned=arguments{4};
        alignment=arguments{1};
    end
    
    set(findobj('tag','dispalignment'),'string',alignment);
    
    %alignment=get(findobj('tag','dispalignment'),'string');
    
    %findobj(handles.mainfig,'Type','axes','Tag','legend')
    figuresize=getpixelposition(handles.mainfig);
    figuresize(1:2)=[80 167];
    exportfigname=[directory,'figures',slash,arguments{1},slash,filename,'_',tasktype,'_',alignment];
    exportfig=figure('color','white','position',figuresize);
    %figdimension=get(findobj('tag','mainfig'),'Position');
    
    %figure(guifigh);
    %cla(findall(guifigh,'type','axes'))
    %handles.mainfig
    %axes(plotaxh);
    %plotaxh=axes('Position',initaxdim);
    %set(gca,'Position',initaxdim);
    rasterdim=[figuresize(1)*1.1 (figuresize(4)*0.66)+figuresize(2)*1.1 figuresize(3)*0.9 figuresize(4)*0.3];
    
    plotstart=1000;
    plotstop=500;
    fsigma=20;
    causker = 0;
    cc=lines(length(dataaligned));
    
    numsubplot=length(dataaligned)*3; %dividing the panel in three compartments with wequal number of subplots
    if numsubplot==3
        numsubplot=6;
    end
    %setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]);
    %Plot rasters
    %rastersh = axes('Position', rasterdim, 'Layer','top','XTick',[],'YTick',[],'XColor','white','YColor','white');
    numrast=length(dataaligned);
    failed=zeros(numrast,1);
    clear heyevelline aligntype curdir;
    for rstplt=1:numrast
        rasters=dataaligned(rstplt).rasters;
        alignidx=dataaligned(rstplt).alignidx;
        greyareas=dataaligned(rstplt).allgreyareas;
        start=alignidx - plotstart;
        stop=alignidx + plotstop;
        
        if ~ isempty(rasters)
            
            if start < 1
                start = 1;
            end
            if stop > length( rasters )
                stop = length( rasters );
            end
            
            trials = size(rasters,1);
            isnantrial=zeros(1,size(rasters,1));
            
            if numrast==1
                hrastplot(rstplt)=subplot(numsubplot,1,1:2,'Layer','top', ...
                    'XTick',[],'YTick',[],'XColor','white','YColor','white');%'Parent', handles.mainfig
            else
                hrastplot(rstplt)=subplot(numsubplot,1,rstplt,'Layer','top', ...
                    'XTick',[],'YTick',[],'XColor','white','YColor','white');%'Parent', handles.mainfig
            end
            %reducing spacing between rasters
            if numrast>1
                rastpos=get(gca,'position');
                rastpos(2)=rastpos(2)+rastpos(4)*0.5;
                set(gca,'position',rastpos);
            end
            
            % sorting rasters according greytime
            viscuetimes=nan(size(greyareas,2),2);
            for grst=1:size(greyareas,2)
                viscuetimes(grst,:)=greyareas{grst}(1,:);
            end
            cuestarts=viscuetimes(:,1);
            try
                [cuestarts,sortidx]=sort(cuestarts,'descend');
            catch
                sortidx=[1:size(viscuetimes,1)];
            end
            viscuetimes=viscuetimes(sortidx,:);
            if size(rasters,1)<length(sortidx)
                % ca deconne
                size(rasters,1)
            else
                rasters=rasters(sortidx,:);
            end
            
            %axis([0 stop-start+1 0 size(rasters,1)]);
            hold on
            for rastpos=1:size(rasters,1) %plotting rasters trial by trial
                if isnan(sum(rasters(rastpos,start:stop)))
                    isnantrial(rastpos)=1;
                    rasters(rastpos,isnan(rasters(rastpos,:)))=0;
                end
                spiketimes=find(rasters(rastpos,start:stop)); %converting from a matrix representation to a time collection, within selected time range
                plot([spiketimes;spiketimes],[ones(size(spiketimes))*rastpos;ones(size(spiketimes))*rastpos-1],'color',cc(rstplt,:),'LineStyle','-');
                
                % drawing the grey areas
                try
                    greytimes=viscuetimes(rastpos,:)-start;
                    greytimes(greytimes<0)=0;
                    greytimes(greytimes>(plotstart+plotstop))=plotstart+plotstop;
                catch %grey times out of designated period's limits
                    greytimes=0;
                end
                %         diffgrey = find(diff(greytimes)>1); % In case the two grey areas overlap, it doesn't discriminate.
                %                                             % But that's not a problem
                %         diffgreytimes = greytimes(diffgrey);
                if ~sum(isnan(greytimes)) && logical(sum(greytimes))
                    patch([greytimes(1) greytimes(end) greytimes(end) greytimes(1)],[rastpos rastpos rastpos-1 rastpos-1],...
                        [0 0 0], 'EdgeColor', 'none','FaceAlpha', 0.3);
                end
                %         if diffgreytimes % multiple grey areas
                %             %we'll see that later
                %             diffgreytimes
                %             pause
                %         end
                
            end
            axis(gca, 'off', 'tight');
            
            %Plot sdf
            %     if exist('sdfplot','var')
            %         clf(sdfplot);
            %     end
            sdfplot=subplot(numsubplot,1,(numsubplot/3)+1:(numsubplot/3)+(numsubplot/3),'Layer','top');%,'Parent', handles.mainfig
            %sdfh = axes('Position', [.15 .65 .2 .2], 'Layer','top');
            title('Spike Density Function','FontName','calibri','FontSize',11);
            hold on;
            if size(rasters,1)==1 %if only one good trial
                sumall=rasters(~isnantrial,start-fsigma:stop+fsigma);
                sumall(isnan(sumall))=0;
            else
                sumall=sum(rasters(~isnantrial,start-fsigma:stop+fsigma));
                sumall(isnan(sumall))=0;
            end
            %             sdf=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead of number of trials
            sdf=fullgauss_filtconv(sumall,fsigma,causker)./length(find(~isnantrial)).*1000;
            sdf=sdf(fsigma+1:end-fsigma);
            
            plot(sdf,'Color',cc(rstplt,:),'LineWidth',1.8);
            % axis([0 stop-start 0 200])
            axis(gca,'tight');
            box off;
            set(gca,'Color','white','TickDir','out','FontName','calibri','FontSize',8); %'YAxisLocation','rigth'
            %     hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
            %     set(hxlabel,'Position',get(hxlabel,'Position') - [180 -0.2 0]); %doesn't stay there when export !
            hylabel=ylabel(gca,'Firing rate (spikes/s)','FontName','calibri','FontSize',8);
            currylim=get(gca,'YLim');
            
            % drawing the alignment bar
            patch([repmat((alignidx-start)-2,1,2) repmat((alignidx-start)+2,1,2)], ...
                [[0 currylim(2)] fliplr([0 currylim(2)])], ...
                [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
            
            %Plot eye velocities
            heyevelplot=subplot(numsubplot,1,(numsubplot*2/3)+1:numsubplot,'Layer','top');%,'Parent', handles.mainfig
            title('Mean Eye Velocity','FontName','calibri','FontSize',11);
            hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
            
            hold on;
            
            eyevel=dataaligned(rstplt).eyevel;
            eyevel=mean(eyevel(:,start:stop));
            heyevelline(rstplt)=plot(eyevel,'Color',cc(rstplt,:),'LineWidth',1);
            %axis(gca,'tight');
            eyevelymax=max(eyevel);
            if eyevelymax>0.8
                eyevelymax=eyevelymax*1.1;
            else
                eyevelymax=0.8;
            end
            axis([0 stop-start 0 eyevelymax]);
            set(gca,'Color','none','TickDir','out','FontSize',8,'FontName','calibri','box','off');
            ylabel(gca,'Eye velocity (deg/ms)','FontName','calibri','FontSize',8);
            patch([repmat((alignidx-start)-2,1,2) repmat((alignidx-start)+2,1,2)], ...
                [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
                [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
            
            % get directions for the legend
            %curdir{rstplt}=dataaligned(rstplt).dir;
            sacdeg=nan(size(dataaligned(1,rstplt).trials,2),1);
            for eyetr=1:size(dataaligned(1,rstplt).trials,2)
                thissach=dataaligned(1,rstplt).eyeh(eyetr,dataaligned(1,rstplt).alignidx:dataaligned(1,rstplt).alignidx+100);
                thissacv=dataaligned(1,rstplt).eyev(eyetr,dataaligned(1,rstplt).alignidx:dataaligned(1,rstplt).alignidx+100);
                minwidth=5;
                [~, ~, thissacvel, ~, ~, ~] = cal_velacc(thissach,thissacv,minwidth);
                peakvel=find(thissacvel==max(thissacvel),1);
                sacendtime=peakvel+find(thissacvel(peakvel:end)<=...
                    (min(thissacvel(peakvel:end))+(max(thissacvel(peakvel:end))-min(thissacvel(peakvel:end)))/10),1);
                try
                    sacdeg(eyetr)=abs(atand((thissach(sacendtime)-thissach(1))/(thissacv(sacendtime)-thissacv(1))));
                catch
                    thissacv;
                end
                
                % sign adjustements
                if thissacv(sacendtime)<thissacv(1) % negative vertical amplitude -> vertical flip
                    sacdeg(eyetr)=180-sacdeg(eyetr);
                end
                if thissach(sacendtime)>thissach(1)%inverted signal: leftward is in postive range. Correcting to negative.
                    sacdeg(eyetr)=360-sacdeg(eyetr); % mirror image;
                end
            end
            % a quick fix to be able to put "upwards" directions together
            distrib=hist(sacdeg,3); %floor(length(sacdeg)/2)
            if max(bwlabel(distrib,4))>1 && distrib(1)>1 && distrib(end)>1 %=bimodal distribution with more than 1 outlier
                sacdeg=sacdeg+45;
                sacdeg(sacdeg>360)=-(360-(sacdeg(sacdeg>360)-45));
                sacdeg(sacdeg>0)= sacdeg(sacdeg>0)-45;
            end
            sacdeg=abs(median(sacdeg));
            
            if sacdeg>45/2 && sacdeg <= 45+45/2
                curdir{rstplt}='up_right';
            elseif sacdeg>45+45/2 && sacdeg <= 90+45/2
                curdir{rstplt}='rightward';
            elseif sacdeg>90+45/2 && sacdeg <= 135+45/2
                curdir{rstplt}='down_right';
            elseif sacdeg>135+45/2 && sacdeg < 180+45/2
                curdir{rstplt}='downward';
            elseif sacdeg>=180+45/2 && sacdeg <= 225+45/2
                curdir{rstplt}='down_left';
            elseif sacdeg>225+45/2 && sacdeg <= 270+45/2
                curdir{rstplt}='leftward';
            elseif sacdeg>270+45/2 && sacdeg <= 315+45/2
                curdir{rstplt}='up_left';
            else
                curdir{rstplt}='upward';
            end
            %get alignement type
            aligntype{rstplt}=dataaligned(rstplt).alignlabel;
        else
            curdir{rstplt}='data';
            aligntype{rstplt}='no';
            failed(rstplt)=1;
        end
    end
    %moving up all rasters now
    if numrast==1 || ~iscell(get(hrastplot(~failed),'position'))
        allrastpos=(get(hrastplot,'position'));
    else
        allrastpos=cell2mat(get(hrastplot(~failed),'position'));
    end
    
    disttotop=allrastpos(1,2)+allrastpos(1,4);
    if disttotop<0.99 %if not already close to top of container
        allrastpos(:,2)=allrastpos(:,2)+(1-disttotop)/1.5;
    end
    if numrast>1
        allrastpos=mat2cell(allrastpos,ones(1,size(allrastpos,1))); %reconversion to cell .. un brin penible
        set(hrastplot(~failed),{'position'},allrastpos);
    else
        set(hrastplot,'position',allrastpos);
    end
    
    %moving down the eye velocity plot
    eyevelplotpos=get(heyevelplot,'position');
    eyevelplotpos(1,2)=eyevelplotpos(1,2)-(eyevelplotpos(1,2))/1.5;
    set(heyevelplot,'position',eyevelplotpos);
    
    % plot a legend in this last graph
    clear spacer
    spacer(1:numrast,1)={' '};
    hlegdir = legend(heyevelline, strcat(aligntype',spacer,curdir'),'Location','NorthWest');
    set(hlegdir,'Interpreter','none', 'Box', 'off','LineWidth',1.5,'FontName','calibri','FontSize',9);
    
    % setting sdf plot y axis
    try
        newylim=[0, ceil(max(max(cell2mat(get(findobj(sdfplot,'Type','line'),'YDATA'))))/10)*10]; %rounding up to the decimal
    catch
        newylim=[0, ceil(max(max(get(findobj(sdfplot,'Type','line'),'YDATA')))/10)*10]; %rounding up to the decimal
    end
    
    set(sdfplot,'YLim',newylim);
    %eventdata={algfile,aligntype};
    %exportfig_Callback(findobj('tag','exportfig'), eventdata, handles);
    %% copied from export_callback
    
    % for k=1:length(subplots)
    %     copyobj(subplots(k),exportfig);
    % end
    %increase figure height to leave space for the title
    %first change axes units to pixels, so that they don't rescale
    allaxes=findobj(exportfig,'Type','axes');
    set(allaxes,'Units','pixels');
    addspace=figuresize(4)./8;
    figuresize(4)=figuresize(4)+addspace;
    set(exportfig,'position',figuresize);
    %putting title
    axespos=cell2mat(get(allaxes,'Position'));
    figtitleh = title(allaxes(find(axespos(:,2)==max(axespos(:,2)),1)),...
        ['File: ',filename,' - Task: ',tasktype,' - Alignment: ',alignment]);
    set(figtitleh,'Interpreter','none'); %that prevents underscores turning charcter into subscript
    % and moving everything up a bit
    axespos(:,2)=axespos(:,2)+addspace/2; %units in pixels now
    axespos=mat2cell(axespos,ones(size(axespos,1),1)); %reconversion
    set(allaxes,{'Position'},axespos);
    %and the title a little bit more if needed
    subplots=findobj(gcf,'Type','axes');
    if size(subplots,1)>5
        titlepos=get(figtitleh,'position');
        titlepos(2)=titlepos(2)+addspace/10;
        set(figtitleh,'position',titlepos);
    end
    %changing units back to relative, in case we want to resize the figure
    set(allaxes,'Units','normalized')
    % remove time label on sdf plot
    set(allaxes(2),'XTickLabel','');
    %% saving figure
    %basic png fig:
    
    newpos =  get(gcf,'Position')/60;
    set(gcf,'PaperUnits','inches','PaperPosition',newpos);
    print(gcf, '-dpng', '-noui', '-opengl','-r600', exportfigname);
    delete(exportfig);
    %% end copied section
    % figure(guifigh);
    % allcurax=findall(guifigh,'type','axes');
    % for axnum=1:length(allcurax)
    % cla(allcurax(axnum))
    % end
    %clf('reset')
end

function optilocplot(arguments,handles)
global directory slash;
filename=arguments{2};
tasktype=arguments{3};
%algdir=[directory,'processed',slash,'aligned',slash];
set(findobj('tag','dispfilename'),'string',filename);
set(findobj('tag','disptaskname'),'string',tasktype);

alignedata=struct(arguments{1});
alignment=alignedata(1,1).savealignname(max(strfind(alignedata(1,1).savealignname,'_'))+1:end);
set(findobj('tag','dispalignment'),'string',alignment);

%figdimension=get(findobj('tag','mainfig'),'Position');
%figdimension=get(gca,'Position');
%rasterdim=[figdimension(1)*1.1 (figdimension(4)*0.66)+figdimension(2)*1.1 figdimension(3)*0.9 figdimension(4)*0.3];

plotstart=450;
plotstop=200;
fsigma=20;
cc=lines(length(alignedata));
if size(cc,1)==8
    cc(8,:)=[0 0.75 0];
end

%setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]);
%Plot rasters
%rastersh = axes('Position', rasterdim, 'Layer','top','XTick',[],'YTick',[],'XColor','white','YColor','white');
numrast=length(alignedata);
%figure1 = figure;

%% define axes positions
Positions={0,0,1,1;...
    0.51,0.58,0.13,0.10;...
    0.60,0.68,0.13,0.10;...
    0.72,0.80,0.13,0.10;...
    %
    0.56,0.45,0.13,0.10;...
    0.70,0.45,0.13,0.10;...
    0.84,0.45,0.13,0.10;...
    %
    0.51,0.32,0.13,0.10;...
    0.60,0.22,0.13,0.10;...
    0.72,0.10,0.13,0.10;...
    %
    0.30,0.60,0.13,0.10;...
    0.20,0.70,0.13,0.10;...
    0.10,0.80,0.13,0.10;...
    %
    0.40,0.50,0.13,0.10;...
    0.20,0.50,0.13,0.10;...
    0.10,0.50,0.13,0.10;...
    %
    0.30,0.30,0.13,0.10;...
    0.20,0.20,0.13,0.10;...
    0.10,0.10,0.13,0.10};

%% draw bull's eye
olaxes{1}=axes('Parent',handles.mainfig,'Position',[Positions{1,:}]);
viscircles([100 100; 100 100; 100 100], [12;36;60],'EdgeColor','b'); %12,36,60 = 4,12,20 *3

%% plot individual sdf
for i=1:numrast
    olaxes{i+1}=axes('Parent',handles.mainfig,'Position',[Positions{i+1,:}],...
        'XTick',[],'YTick',[],'XColor','white','YColor','white','XTickLabel',[],'YTickLabel',[]);
    box(olaxes{i+1},'off');
    rasters=alignedata(i).rasters;
    alignidx=alignedata(i).alignidx;
    greyareas=alignedata(i).allgreyareas;
    start=alignidx - plotstart;
    stop=alignidx + plotstop;
    
    if start < 1
        start = 1;
    end
    if stop > length(rasters)
        stop = length(rasters);
    end
    
    isnantrial=zeros(1,size(rasters,1));
    for rastpos=1:size(rasters,1) %checking raster trial by trial
        if isnan(sum(rasters(rastpos,start:stop)))
            isnantrial(rastpos)=1;
            rasters(rastpos,isnan(rasters(rastpos,:)))=0;
        end
    end
    % can't subplot raster, an object of class axes, can not be a child of class axes.
    %hrastplot{i}=subplot(3,1,1,'Layer','top','XTick',[],'YTick',[],'XColor','white','YColor','white', 'Parent',olaxes{i+1});
    
    %Plot sdf
    if size(rasters,1)==1 %if only one good trial
        sumall=rasters(~isnantrial,start-fsigma:stop+fsigma);
    else
        sumall=sum(rasters(~isnantrial,start-fsigma:stop+fsigma));
    end
    %     sdf=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead of number of trials
    sdf=fullgauss_filtconv(sumall,fsigma,causker)./length(find(~isnantrial)).*1000;
    sdf=sdf(1+fsigma:end-fsigma);
    
    plot(sdf,'Color',cc(i,:),'LineWidth',1.8);
    %title('Spike Density Function','FontName','calibri','FontSize',11);
    % axis([0 stop-start 0 200])
    axis(gca,'tight');
    box off;
    set(gca,'Color','white','TickDir','out','FontName','calibri','FontSize',8); %'YAxisLocation','rigth'
    %     hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
    %     set(hxlabel,'Position',get(hxlabel,'Position') - [180 -0.2 0]); %doesn't stay there when export !
    %hylabel=ylabel(gca,'Firing rate (spikes/s)','FontName','calibri','FontSize',8);
    currylim=get(gca,'YLim');
    
    if ~isempty(rasters)
        % drawing the alignment bar
        patch([repmat((alignidx-start)-5,1,2) repmat((alignidx-start)+5,1,2)], ...
            [[0 currylim(2)] fliplr([0 currylim(2)])], ...
            [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
    end
    
    % setting sdf plot y axis
    % ylimdata=get(findobj(sdfplot,'Type','line'),'YDATA');
    % if ~iscell(ylimdata)
    %     ylimdata={ylimdata};
    % end
    % if sum((cell2mat(cellfun(@(x) logical(isnan(sum(x))), ylimdata, 'UniformOutput', false)))) %if NaN data
    %     ylimdata=ylimdata(~(cell2mat(cellfun(@(x) logical(isnan(sum(x))),...
    %         ylimdata, 'UniformOutput', false))));
    % end
    % if sum(logical(cellfun(@(x) length(x),ylimdata)-1))~=length(ylimdata) %some strange data with a single value
    %     ylimdata=ylimdata(logical(cellfun(@(x) length(x),ylimdata)-1));
    % end
    % newylim=[0, ceil(max(max(cell2mat(ylimdata)))/10)*10]; %rounding up to the decimal
    % set(sdfplot,'YLim',newylim);
    % x axis tick labels
    set(gca,'XTick',[0:100:(stop-start)]);
    set(gca,'XTickLabel',[-plotstart:100:plotstop]);
    
end


% --- Outputs from this function are returned to the command line.
function varargout = SummaryPlot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.figaxesh);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        plot(rand(5));
    case 2
        plot(sin(1:0.01:25.99));
    case 3
        bar(1:.5:10);
    case 4
        plot(membrane);
    case 5
        surf(peaks);
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});



function dispfilename_Callback(hObject, eventdata, handles)
% hObject    handle to dispfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dispfilename as text
%        str2double(get(hObject,'String')) returns contents of dispfilename as a double


% --- Executes during object creation, after setting all properties.
function dispfilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function disptaskname_Callback(hObject, eventdata, handles)
% hObject    handle to disptaskname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of disptaskname as text
%        str2double(get(hObject,'String')) returns contents of disptaskname as a double


% --- Executes during object creation, after setting all properties.
function disptaskname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to disptaskname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in combinealign.
function combinealign_Callback(hObject, eventdata, handles)
% hObject    handle to combinealign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in undocombine.
function undocombine_Callback(hObject, eventdata, handles)
% hObject    handle to undocombine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in exportfig.
function exportfig_Callback(hObject, eventdata, handles)
% hObject    handle to exportfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename tasktype directory;
alignment=get(findobj('tag','dispalignment'),'string');
subplots=findobj(handles.mainfig,'Type','axes');
figuresize=getpixelposition(handles.mainfig);
figuresize(1:2)=[80 167];
%% look if output plot is condensed and adjust plot
if get(findobj('tag','pb_condensed'),'value') %condensed: superpose rasters and sdf, remove eye vel
    szeyevelplot=cellfun(@(x) x(4),get(subplots,'position'));
    szeyevelplot=szeyevelplot(cellfun(@(x) x(2),get(subplots,'position'))==min(cellfun(@(x) x(2),get(subplots,'position'))));
    subplots=subplots(cellfun(@(x) x(2),get(subplots,'position'))~=min(cellfun(@(x) x(2),get(subplots,'position'))));
    curlegpos=get(subplots(subplots==findobj(handles.mainfig,'Type','axes','Tag','legend')),'position');
    % curlegpos(2)=curlegpos(2)+szeyevelplot;
    % set(findobj(handles.mainfig,'Type','axes','Tag','legend'),'position',curlegpos);
    % figuresize(4)=figuresize(4)-szeyevelplot*figuresize(4);
end
%%
if size(filename,1)>1
    exportfn=filename{eventdata{1}};
    exporttsk=tasktype{eventdata{1}};
    alignment=eventdata{2}{1};
else
    exportfn=filename;
    exporttsk=tasktype;
end
selclus_order = get(findobj('Tag','whichclus'),'Value'); %Which element of the list
selclus = get(findobj('Tag','whichclus'),'String');
if iscell(selclus)
    selclus = str2double(selclus{selclus_order}(1));
else
    selclus = str2double(selclus);
end
exportfigname=[directory,'figures\',exportfn,'_cl_',num2str(selclus),'_',exporttsk,'_',alignment];
exportfig=figure('color','white','position',figuresize);
for k=1:length(subplots)
    copyobj(subplots(k),exportfig);
end
%increase figure height to leave space for the title
%first change axes units to pixels, so that they don't rescale
transferedaxes=findobj(exportfig,'Type','axes');
set(transferedaxes,'Units','pixels')
addspace=figuresize(4)./8;
figuresize(4)=figuresize(4)+addspace;
set(exportfig,'position',figuresize);
%putting title
axespos=cell2mat(get(transferedaxes,'Position'));
figtitleh = title(transferedaxes(find(axespos(:,2)==max(axespos(:,2)),1)),...
    ['File: ',exportfn,' - Task: ',exporttsk,' - Alignment: ',alignment]);
set(figtitleh,'Interpreter','none'); %that prevents underscores turning charcter into subscript
% and moving everything up or down
if get(findobj('tag','pb_condensed'),'value')
    % find sdf plot and move it up
    sdfplotnb=axespos(:,2)==min(axespos(axespos(:,2)>min(axespos(:,2)),2));
    sdfplotpos=axespos(sdfplotnb,:);
    sdfplotpos(2)=min(axespos(axespos(:,2)>axespos(sdfplotnb,2),2))-1;
    set(transferedaxes(sdfplotnb),'Color', 'none');
    set(transferedaxes(sdfplotnb),'position',sdfplotpos);
    title(transferedaxes(sdfplotnb),'');
    % find legend and move it up too
    legnb=find(axespos(:,2)==min(axespos(:,2)));
    legplotpos=axespos(legnb,:);
    legplotpos(2)=sdfplotpos(2)-75;
    legplotpos(1)=figuresize(3)/2-legplotpos(3)/2;
    set(transferedaxes(legnb),'position',legplotpos);
    %move everybody down
    axespos=cell2mat(get(transferedaxes,'Position'));
    axespos(:,2)=axespos(:,2)-min(axespos(:,2))+25;
    axespos=mat2cell(axespos,ones(size(axespos,1),1)); %reconversion
    set(transferedaxes,{'Position'},axespos);
else
    %move everybody up
    axespos(:,2)=axespos(:,2)+addspace/2; %units in pixels now
    axespos=mat2cell(axespos,ones(size(axespos,1),1)); %reconversion
    set(transferedaxes,{'Position'},axespos);
end
%and the title a little bit more if needed
if size(subplots,1)>5
    titlepos=get(figtitleh,'position');
    titlepos(2)=titlepos(2)+addspace/10;
    set(figtitleh,'position',titlepos);
end


%final adjustements
if ~get(findobj('tag','pb_condensed'),'value')
    % remove time label on sdf plot
    set(transferedaxes(2),'XTickLabel','');
else
    set(figtitleh,'units','pixels');
    titpos=get(figtitleh,'position');
    figpos=get(exportfig,'position');
    figpos(4)=axespos{sdfplotnb}(2)+titpos(1)+50;
    set(exportfig,'position',figpos);
    set(figtitleh,'units','data');
end

%changing units back to relative, in case we want to resize the figure
set(transferedaxes,'Units','normalized')
%% saving figure
% to check if file already exists and open it:
% eval(['!' exportfigname '.pdf']);

%print png
if get(findobj('tag','pngexport'),'value')
    %basic png fig:
    newpos =  get(gcf,'Position')/60;
    set(gcf,'PaperUnits','inches','PaperPosition',newpos);
    print(gcf, '-dpng', '-noui', '-opengl','-r600', exportfigname);
    % -noui stands for: suppress the printing of user interface (ui) controls.
end

%print pdf
%reasonably low size / good definition pdf figure (but patch transparency not supported by ghostscript to generate pdf):
%print(gcf, '-dpdf', '-noui', '-painters','-r600', exportfigname);

%print svg
if get(findobj('tag','svgexport'),'value')
    plot2svg([exportfigname,'.svg'],gcf, 'png'); %only vector graphic export function that preserves alpha transparency
end
% to preserve transparency, may use tricks with eps files. See: http://blogs.mathworks.com/loren/2007/12/11/making-pretty-graphs/

% export_fig solves the font embedding problem for illustrator (not adobe reader though), but is slower. Use -nocrop
% option to prevent border cropping
%export_fig(exportfigname,'-pdf','-transparent','-painters','-r300',exportfig);
%for eps, use: print2eps(exportfigname,exportfig, '-noui', '-painters','-r300');

% for higher (possibly) reso, could use print '-depsc2' format
% people used to include the '-adobecset' option for export to AI, but it
% seems obsolete now
% see painter's option explanations here:
% http://www.mathworks.com/help/techdoc/creating_plots/f3-84337.html#f3-102410

delete(exportfig);


% --- Executes on button press in p_rasters.
function p_rasters_Callback(hObject, eventdata, handles)
% hObject    handle to p_rasters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p_rasters


% --- Executes on button press in p_sdf.
function p_sdf_Callback(hObject, eventdata, handles)
% hObject    handle to p_sdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p_sdf


% --- Executes on button press in p_eyevel.
function p_eyevel_Callback(hObject, eventdata, handles)
% hObject    handle to p_eyevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p_eyevel


% --- Executes during object creation, after setting all properties.
function figaxesh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figaxesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate figaxesh


% --- Executes on button press in replot.
function replot_Callback(hObject, eventdata, handles)
% hObject    handle to replot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%When replotting,use uistack to reorder visual stacking order of objects if
%necessary


% --- Executes on button press in openfile.
function openfile_Callback(hObject, eventdata, handles)
% hObject    handle to openfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function mainfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

mainfig = uipanel('BorderType','none',...
    'BackgroundColor','white',...
    'Units','points',...
    'Position',[0.032 0.02 0.595 0.925],...
    'Parent',gcf);



function dispalignment_Callback(hObject, eventdata, handles)
% hObject    handle to dispalignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dispalignment as text
%        str2double(get(hObject,'String')) returns contents of dispalignment as a double


% --- Executes during object creation, after setting all properties.
function dispalignment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispalignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_condensed.
function pb_condensed_Callback(hObject, eventdata, handles)
% hObject    handle to pb_condensed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pb_condensed


% --- Executes on button press in pngexport.
function pngexport_Callback(hObject, eventdata, handles)
% hObject    handle to pngexport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pngexport


% --- Executes on button press in svgexport.
function svgexport_Callback(hObject, eventdata, handles)
% hObject    handle to svgexport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of svgexport
