function disp_cmd(recname,datalign,latmach,triplot)
global directory;
% if latmach
    %% first get SSDs and SSRT, to later parse latency-matched trials and CSS according to SSDs

    load(recname,'allbad','allcodes','alltimes','saccadeInfo'); % 
    alllats=reshape({saccadeInfo.latency},size(saccadeInfo));
    alllats=alllats';%needs to be transposed because the logical indexing below will be done column by column, not row by row
    allgoodsacs=~cellfun('isempty',reshape({saccadeInfo.latency},size(saccadeInfo)));
    %removing bad trials
    allgoodsacs(logical(allbad),:)=0;
    %removing stop trials that may be included
    allgoodsacs(floor(allcodes(:,2)./1000)~=6,:)=0;
    %indexing good sac trials
    % if saccade detection corrected, there may two 'good' saccades
    if max(sum(allgoodsacs,2))>1
        twogoods=find(sum(allgoodsacs,2)>1);
        for dblsac=1:length(twogoods)
            allgoodsacs(twogoods(dblsac),find(allgoodsacs(twogoods(dblsac),:),1))=0;
        end
    end
    sacdelay=(cell2mat(alllats(allgoodsacs')));
    %get reward time for NSS trials
    goodsactimes=alltimes(logical(sum(allgoodsacs,2)),:);
    rewtimes=goodsactimes(allcodes(logical(sum(allgoodsacs,2)),:)==1030);
    
    %% get CSS SSDs
    ccssd=datalign(2).ssd;
    if size(ccssd,2)>size(ccssd,1)
        ccssd=permute(ccssd,[2,1]);
    end
    nccssd=datalign(3).ssd;
    if size(nccssd,2)>size(nccssd,1)
        nccssd=permute(nccssd,[2,1]);
    end
        if size(ccssd,2)>1
        ccssd=ccssd(:,1);
        nccssd=nccssd(:,1);
        end
    ssdvalues=sort(unique([ccssd;nccssd]));
    ssdvalues(find(diff(ssdvalues)==1)+1)=ssdvalues(diff(ssdvalues)==1);
    ssdvalues=ssdvalues(diff(ssdvalues)>0);
    if sum(diff(ssdvalues)==1) % second turn
        ssdvalues(diff(ssdvalues)==1)=ssdvalues(diff(ssdvalues)==1)+1;
        ssdvalues=ssdvalues(diff(ssdvalues)>0);
    end

    %% get SSRT used for alignement
        [overallMeanSSRT,meanIntSSRT,meanSSRT,~,~,tachomc,tachowidth]=findssrt(recname,1);
    mssrt=[overallMeanSSRT,meanIntSSRT,meanSSRT];
    mssrt=round(nanmean(mssrt(mssrt>40 & mssrt<150)));
    if isnan(mssrt) || ~(mssrt>50 & mssrt<150) %get tachomc and lookup SSRT/tachomc fit. If fit missing, run SSRT_TachoMP
        try
            load([recname(1),'_tachoSSRTfit'],'fit');
        catch
            %SSRT_TachoMP
        end
        %get tacho curve midpoint
            tachomc=mean(tachomc);
        if tachomc<20 || isnan(tachomc)
            tachomc=20;
        end
        % find reciprocal SSRT value
        mssrt=max([round(tachomc*fit.coeff(1)+fit.coeff(2)) 50]);
    end
    if ~(mssrt>50 & mssrt<150)
        load([recname(1),'_evolSSRT'],'evolSSRT','foSSRT');
        session=regexp(recname,'\d+','match');
        if min(abs(evolSSRT(2,:)-str2num(session{1})))<=5
            mssrt=round(mssrt/3+(evolSSRT(1,find(abs(evolSSRT(2,:)-str2num(session{1}))==min(abs(evolSSRT(2,:)-str2num(session{1}))),1)))*2/3);
        else
            mssrt=round(mssrt/3+foSSRT*2/3);
        end
    end
    
    %% find and keep most prevalent ssds
    [ssdtots,ssdtotsidx]=sort((arrayfun(@(x) sum(ccssd==x | ccssd==x-1 | ccssd==x+1),ssdvalues))); %+...
%     (arrayfun(@(x) sum(nccssd==x | nccssd==x-1 | nccssd==x+1),ssdvalues)));
    prevssds=sort(ssdvalues(ssdtotsidx(ssdtots>ceil(median(ssdtots))+1)));
    % starting with the one that remove the less (N)CSS trials
    matchlatidx=sacdelay>ssdvalues(ssdtotsidx(end))+round(mssrt);
% end  
    
if latmach %ie, aligned to target
    if ~triplot % only two conditions: NSS Vs CSS
        datalign=datalign(1:2); 
    end
    plotstart=200;
    plotstop=600;
else % aligned to sac
    % NSS Vs NCSS
    datalign=datalign([1 3]);
    plotstart=1000;
    plotstop=400;
end

%% preallocs and definitions
allsdf=cell(2,1);
allrast=cell(2,1);
allviscuetimes=cell(2,1);
allalignidx=cell(2,1);
    
cmdplots=figure('color','white','position',[826    49   524   636]);
if triplot
    numrast=3;
else
    numrast=2;
end
fsigma=20;
cc=lines(numrast);
numsubplot=numrast*3; %dividing the panel in three compartments with wequal number of subplots  
    
%% plotting figure
for i=1:numrast
    if strcmp('tgt',datalign(i).alignlabel) && latmach
        rasters=datalign(i).rasters(matchlatidx,:);
        alignidx=datalign(i).alignidx;
        greyareas=datalign(i).allgreyareas(matchlatidx);
        matchrewtimes=rewtimes(matchlatidx);
    elseif (strcmp('stop_cancel',datalign(i).alignlabel) || strcmp('stop_non_cancel',datalign(i).alignlabel)) && latmach
        ssdidx=(datalign(i).ssd==ssdvalues(ssdtotsidx(end)) | datalign(i).ssd==ssdvalues(ssdtotsidx(end))-1 | datalign(i).ssd==ssdvalues(ssdtotsidx(end))+1);
       	rasters=datalign(i).rasters(ssdidx,:);
        if strcmp('stop_non_cancel',datalign(i).alignlabel)
            alignidx=datalign(i).alignidx;
        else
            alignidx=datalign(i).alignidx-(ssdvalues(ssdtotsidx(end))+round(mssrt)); % shifting rasters to target presentation, using most prevalent SSD
        end
        greyareas=datalign(i).allgreyareas(ssdidx);
    else
        rasters=datalign(i).rasters;
        alignidx=datalign(i).alignidx;
        greyareas=datalign(i).allgreyareas;
        timetorew=datalign(i).sactotrig;
        if strcmp(datalign(i).alignlabel,'stop_non_cancel')
            if size(datalign(i).ssd,2)>size(datalign(i).ssd,1)
                datalign(i).ssd=permute(datalign(i).ssd,[2,1]);
            end
        end
    end
    
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
    

    hrastplot(i)=subplot(numsubplot,1,i,'Layer','top', ...
            'XTick',[],'YTick',[],'XColor','white','YColor','white', 'Parent', cmdplots);

    %reducing spacing between rasters
        rastpos=get(gca,'position');
        rastpos(2)=rastpos(2)+rastpos(4)*0.5;
        set(gca,'position',rastpos);

    
    % sorting rasters according greytime
    viscuetimes=nan(size(greyareas,2),2);
    sactimes=nan(size(greyareas,2),1);
    for grst=1:size(greyareas,2)
%         if strcmp('stop_cancel',datalign(i).alignlabel) && latmach
%             viscuetimes(grst,:)=greyareas{grst}(1,:); % -(ssdvalues(ssdtotsidx(end))+round(mssrt))
%         else
            viscuetimes(grst,:)=greyareas{grst}(1,:);
%         end
            sactimes(grst)=greyareas{grst}(2,1)-start;
    end
    if strcmp(datalign(i).alignlabel,'tgt') && latmach
            [sactimes,sortidx]=sort(sactimes,'ascend');
            viscuetimes=viscuetimes(sortidx,:);
            rasters=rasters(sortidx,:);
    else
            cuestarts=viscuetimes(:,1);
            [~,sortidx]=sort(cuestarts,'descend');
            viscuetimes=viscuetimes(sortidx,:);
            rasters=rasters(sortidx,:);
    end
    
    %axis([0 stop-start+1 0 size(rasters,1)]);
    hold on
    for j=1:size(rasters,1) %plotting rasters trial by trial
        spiketimes=find(rasters(j,start:stop)); %converting from a matrix representation to a time collection, within selected time range
        if isnan(sum(rasters(j,start:stop)))
            isnantrial(j)=1;
            spiketimes(find(isnan(rasters(j,start:stop))))=0; %#ok<FNDSB>
        else
        plot([spiketimes;spiketimes],[ones(size(spiketimes))*j;ones(size(spiketimes))*j-1],'color',cc(i,:),'LineStyle','-');
        end

        % drawing the grey areas
        try
            greytimes=viscuetimes(j,:)-start;
            greytimes(greytimes<0)=0;
            greytimes(greytimes>(stop-start))=stop-start;
        catch %grey times out of designated period's limits
            greytimes=0;
        end
        %         diffgrey = find(diff(greytimes)>1); % In case the two grey areas overlap, it doesn't discriminate.
        %                                             % But that's not a problem
        %         diffgreytimes = greytimes(diffgrey);
        if ~sum(isnan(greytimes)) && logical(sum(greytimes))
            patch([greytimes(1) greytimes(end) greytimes(end) greytimes(1)],[j j j-1 j-1],...
                [0 0 0], 'EdgeColor', 'none','FaceAlpha', 0.3);
                    % if NCSS, plot diamong at SSD
            if strcmp(datalign(i).alignlabel,'stop_non_cancel')
                plot(greytimes(1)+datalign(i).ssd(j,1),j-0.5,'gd','MarkerSize', 3,'LineWidth', 1.2)
            elseif strcmp(datalign(i).alignlabel,'tgt') && latmach
                plot(sactimes(j),j-0.5,'kd','MarkerSize', 3,'LineWidth', 1.5)
            elseif strcmp(datalign(i).alignlabel,'stop_cancel') && latmach
                plot(alignidx+ssdvalues(ssdtotsidx(end))-start,j-0.5,'k^','MarkerSize', 2,'LineWidth', 1) % SSD
                plot(alignidx+ssdvalues(ssdtotsidx(end))+round(mssrt)-start,j-0.5,'kv','MarkerSize', 2,'LineWidth', 1) % SSD +SSRT
            end
        end  
    end
%     if strcmp(datalign(i).alignlabel,'stop_cancel') && latmach
%         % plot SSD
%             patch([repmat((alignidx+ssdvalues(ssdtotsidx(end)))-2,1,2) repmat((alignidx+ssdvalues(ssdtotsidx(end)))+2,1,2)], ...
%             [[0 currylim(2)] fliplr([0 currylim(2)])], ...
%             [0 0 0 0],[1 1 1],'EdgeColor','none','FaceAlpha',1);
%         % plot SSRT
%             patch([repmat((alignidx+ssdvalues(ssdtotsidx(end))+round(mssrt))-2,1,2) repmat((alignidx+ssdvalues(ssdtotsidx(end))+round(mssrt))+2,1,2)], ...
%             [[0 currylim(2)] fliplr([0 currylim(2)])], ...
%             [0 0 0 0],[1 1 1],'EdgeColor','none','FaceAlpha',1);
%     end
    
    set(hrastplot(i),'xlim',[1 length(start:stop)]);
    if strcmp(datalign(i).alignlabel,'stop_cancel') && latmach
    axes(hrastplot(i));
            patch([repmat((alignidx+ssdvalues(ssdtotsidx(end))+round(mssrt)-start)-tachowidth/2,1,2)...
                repmat((alignidx+ssdvalues(ssdtotsidx(end))+round(mssrt)-start)+tachowidth/2,1,2)], ...
            [[0 size(rasters,1)] fliplr([0 size(rasters,1)])], ...
            [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
    end
    axis(gca, 'off'); % axis tight sets the axis limits to the range of the data.

    
    %Plot sdf
    sdfplot=subplot(numsubplot,1,(numsubplot/3)+1:(numsubplot/3)+(numsubplot/3),'Layer','top','Parent', cmdplots);
    %sdfh = axes('Position', [.15 .65 .2 .2], 'Layer','top');
    title('Spike Density Function','FontName','calibri','FontSize',11);
    hold on;
    if size(rasters,1)==1 %if only one good trial
        %sumall=rasters(~isnantrial,start-fsigma:stop+fsigma);
        %useless plotting this
        sumall=NaN;
    else
        sumall=sum(rasters(~isnantrial,start-fsigma:stop+fsigma));
    end
    sdf=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead of number of trials
    sdf=sdf(fsigma+1:end-fsigma);
    
    plot(sdf,'Color',cc(i,:),'LineWidth',1.8);
    
            if strcmp(datalign(i).alignlabel,'stop_cancel') && latmach
                        patch([repmat((alignidx+ssdvalues(ssdtotsidx(end))-start)-1,1,2) repmat((alignidx+ssdvalues(ssdtotsidx(end))-start)+1,1,2)], ...
            [[0 currylim(2)] fliplr([0 currylim(2)])],[0 0 0 0],'k^','EdgeColor','none','FaceAlpha',0.5);
                         patch([repmat((alignidx+ssdvalues(ssdtotsidx(end))+round(mssrt)-start)-1,1,2) repmat((alignidx+ssdvalues(ssdtotsidx(end))+round(mssrt)-start)+1,1,2)], ...
            [[0 currylim(2)] fliplr([0 currylim(2)])],[0 0 0 0],'k^','EdgeColor','none','FaceAlpha',0.5);
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
    heyevelplot=subplot(numsubplot,1,(numsubplot*2/3)+1:numsubplot,'Layer','top','Parent', cmdplots);
    title('Mean Eye Velocity','FontName','calibri','FontSize',11);
    hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
    
    hold on;
    if ~isempty(rasters)
        eyevel=datalign(i).eyevel;
        eyevel=mean(eyevel(:,start:stop));
        heyevelline(i)=plot(eyevel,'Color',cc(i,:),'LineWidth',1);
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
        curdir{i}=datalign(i).dir;
        aligntype{i}=datalign(i).alignlabel;
    else
        curdir{i}='no';
        aligntype{i}='data';
    end
    
    %% keep sdf, rasters etc
    allsdf{i}=sdf;
    allrast{i}=rasters;
%     alltimetorew{i}=timetorew;
    allalignidx{i}=alignidx;
    % get pre-cue 200ms activity
    allviscuetimes{i}=viscuetimes(:,1);

end

%% moving up all rasters now
if numrast==1
    allrastpos=(get(hrastplot,'position'));
else
    allrastpos=cell2mat(get(hrastplot,'position'));
end

disttotop=allrastpos(1,2)+allrastpos(1,4);
if disttotop<0.99 %if not already close to top of container
    allrastpos(:,2)=allrastpos(:,2)+(1-disttotop)/1.5;
end
if numrast>1
    allrastpos=mat2cell(allrastpos,ones(1,size(allrastpos,1))); %reconversion to cell .. un brin penible
    set(hrastplot,{'position'},allrastpos);
else
    set(hrastplot,'position',allrastpos);
end

%% moving down the eye velocity plot
eyevelplotpos=get(heyevelplot,'position');
eyevelplotpos(1,2)=eyevelplotpos(1,2)-(eyevelplotpos(1,2))/1.5;
set(heyevelplot,'position',eyevelplotpos);
% x axis tick labels
set(heyevelplot,'XTick',[0:100:(stop-start)]);
set(heyevelplot,'XTickLabel',[-plotstart:100:plotstop]);

% plot a legend in this last graph
clear spacer
spacer(1:numrast,1)={' '};
%cellfun('isempty',{datalign(:).dir})
if  logical(sum(cell2mat(strfind(aligntype,'error1'))) || sum(cell2mat(strfind(aligntype,'error2'))))
    aligntype{~cellfun(@(x) (strcmp(x,'error1') || strcmp(x,'error2')), aligntype)}=...
        ['good trial ' aligntype{~cellfun(@(x) (strcmp(x,'error1') || strcmp(x,'error2')), aligntype)}];
    aligntype(cellfun(@(x) (strcmp(x,'error1') || strcmp(x,'error2')), aligntype))={'wrong trial'};
end
if latmach
    legloc='NorthEast';
else
    legloc='NorthWest';
end
if strcmp(aligntype{1},'tgt') || strcmp(aligntype{1},'sac')
    aligntype{1}='no-stop signal';
end
if strcmp(aligntype{2},'stop_cancel')
    aligntype{2}='cancelled stop-signal';
end
if strcmp(aligntype{2},'stop_non_cancel')
    aligntype{2}='non cancelled stop-signal';
end
hlegdir = legend(heyevelline, strcat(aligntype',spacer,curdir'),'Location',legloc);
set(hlegdir,'Interpreter','none', 'Box', 'off','LineWidth',1.5,'FontName','calibri','FontSize',9);

% setting sdf plot y axis
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

%% quantify differential activity

fullsdf=cell(2,1);

for rasts=1:2
    rasters=allrast{rasts};
    viscuetimes=allviscuetimes{rasts};

    allbaseline=zeros(size(rasters,1),200+2*fsigma);
    for rastunit=1:size(rasters,1) %plotting rasters trial by trial
        rasters(rastunit,isnan(rasters(rastunit,:)))=0;
        allbaseline(rastunit,:)=rasters(rastunit, viscuetimes(rastunit)-200-fsigma:viscuetimes(rastunit)-1+fsigma);
    end
    precuesdf{rasts}=spike_density(nansum(allbaseline),fsigma)./size(rasters,1);
    precuesdf{rasts}=precuesdf{rasts}(fsigma+1:end-fsigma);
    
   if size(allrast{rasts},1)>1 %if more than one good trial
       if plotstart==200 %aligned to target
           if strcmp('tgt',datalign(rasts).alignlabel) %the NSS trials
               sumall=sum(rasters(:,allalignidx{rasts}-(600+fsigma):max(matchrewtimes)+fsigma));
           else % base end limit on NSS trial limit
               sumall=sum(rasters(:,allalignidx{rasts}-(600+fsigma):size(fullsdf{rasts-1},2)+fsigma+(allalignidx{rasts}-601)));
           end
       else
           if strcmp('sac',datalign(rasts).alignlabel) %the NSS trials
               sumall=sum(rasters(:,allalignidx{rasts}-(1000+fsigma):max(rewtimes)+fsigma));
           else
               sumall=sum(rasters(:,allalignidx{rasts}-(1000+fsigma):size(fullsdf{rasts-1},2)+fsigma+(allalignidx{rasts}-1001)));
           end
       end
   end
    fullsdf{rasts}=spike_density(sumall,fsigma)./size(rasters,1);
    fullsdf{rasts}=fullsdf{rasts}(fsigma+1:end-fsigma);
end
    
if plotstart==200 %aligned to target
    precuelevel=floor(mean((floor(fullsdf{1}(401:600))-floor(fullsdf{2}(401:600)))));
    sigthreshold=floor(2*(floor(std(floor(fullsdf{1}(401:600))-floor(fullsdf{2}(401:600)))))+precuelevel);
    diffsdf=ceil(abs([fullsdf{1}]-[fullsdf{2}]));
else
    precuelevel=floor(mean(abs(floor(precuesdf{2})-floor(precuesdf{1}))));
    sigthreshold=floor(2*(floor(std(floor(precuesdf{2})-floor(precuesdf{1}))))+precuelevel);
    diffsdf=ceil(abs([fullsdf{2}]-[fullsdf{1}]));
end

sigdiff=diffsdf>=sigthreshold;
sigdiffepochs=bwlabel(sigdiff);
confsigdiffepochs=zeros(size(sigdiffepochs));
% separate plot 
% figure
% plot(fullsdf{1})
% hold on
% plot(fullsdf{2},'r')
% plot(diffsdf,'g')
% plot(ones(size(diffsdf))*sigthreshold,'m')  
% foo=6*(std(diffsdf(401:600)))+precuelevel;
% plot(ones(size(diffsdf))*foo,'m');

if max(sigdiffepochs)
    for sdenum=1:max(sigdiffepochs)
        maxdiff=max(diffsdf(sigdiffepochs==sdenum));
        sigdiffdur=sum(sigdiffepochs==sdenum);
        if plotstart==200 %aligned to target
            if maxdiff>=floor(6*(std(floor(fullsdf{1}(401:600))-floor(fullsdf{2}(401:600))))) && sigdiffdur>=30
                confsigdiffepochs(find(sigdiffepochs==sdenum,1))=1;
            end
        else
            if maxdiff>=floor(6*(floor(std(floor(precuesdf{2})-floor(precuesdf{1}))))+precuelevel) && sigdiffdur>=30
                confsigdiffepochs(find(sigdiffepochs==sdenum,1))=1;
            end
        end
    end
    if max(confsigdiffepochs)
        figure(1)
        if plotstart==200 %aligned to target
            plot(sdfplot,find(confsigdiffepochs)-400,ones(1,sum(confsigdiffepochs))*10,'xr','markersize',12);
            if sum(find(confsigdiffepochs)-400>alignidx+ssdvalues(ssdtotsidx(end))-start &...
                find(confsigdiffepochs)-400<alignidx+ssdvalues(ssdtotsidx(end))+round(mssrt)-start)
                    cancellation_time=alignidx+ssdvalues(ssdtotsidx(end))+round(mssrt)-start-(find(confsigdiffepochs,1)-400)
                    cancellation_strengh=max(diffsdf(sigdiffepochs==sigdiffepochs(find(confsigdiffepochs,1)))) 
            end
        else
            plot(sdfplot,find(confsigdiffepochs),ones(1,sum(confsigdiffepochs))*10,'xr','markersize',12);
            if sum(find(confsigdiffepochs)>alignidx-start)
                    error_time=find(confsigdiffepochs(alignidx-start:end),1)-1
%                     cancellation_strengh
            end
        end
    end
end

%% condense plot
% figuresize=getpixelposition(gcf);
% figuresize(1:2)=[80 167];
figure(1)
 subplots=findobj(gcf,'Type','axes');
%  set(subplots,'Units','pixels')
 axespos=cell2mat(get(subplots,'Position'));
 figtitleh = title(subplots(find(axespos(:,2)==max(axespos(:,2)),1)),...
    ['File: ',recname,' - Task: Countermanding - Alignment:',datalign(1).alignlabel,'_Vs_',datalign(2).alignlabel ]);
set(figtitleh,'Interpreter','none');
% tpos=get(figtitleh,'position');
set(figtitleh,'position',[700 130 1]);

% addspace=figuresize(4)./8;
% figuresize(4)=figuresize(4)+addspace;
% set(gcf,'position',figuresize);

%     % find sdf plot and move it up
%     sdfplotnb=axespos(:,2)==min(axespos(axespos(:,2)>min(axespos(:,2)),2));
%     sdfplotpos=axespos(sdfplotnb,:);
%     sdfplotpos(2)=min(axespos(axespos(:,2)>axespos(sdfplotnb,2),2))-1;
% set(subplots(sdfplotnb),'Color', 'none');
% set(subplots(sdfplotnb),'position',sdfplotpos);
% title(subplots(sdfplotnb),'');
%     % find legend and move it up too 
%     legnb=find(axespos(:,2)==min(axespos(:,2)));
%     legplotpos=axespos(legnb,:);
%     legplotpos(2)=sdfplotpos(2)-75;
%     legplotpos(1)=figuresize(3)/2-legplotpos(3)/2;
%     set(subplots(legnb),'position',legplotpos);
% %move everybody down
% axespos=cell2mat(get(subplots,'Position'));
% axespos(:,2)=axespos(:,2)-min(axespos(:,2))+25;
% axespos=mat2cell(axespos,ones(size(axespos,1),1)); %reconversion
% set(subplots,{'Position'},axespos);

%% saving figure
% to check if file already exists and open it:
% eval(['!' exportfigname '.pdf']);
if strcmp('tgt',datalign(1).alignlabel) && latmach
    comp='NSSvsCSS_tgt';
elseif strcmp('sac',datalign(1).alignlabel) && latmach
    comp='NSSvsCSS_sac';
elseif strcmp('sac',datalign(1).alignlabel) && ~latmach
    comp='NSSvsNCSS_sac';
end
exportfigname=[directory,'figures\cmd\',recname,'_',comp];
%basic png fig:
newpos =  get(gcf,'Position')/60;
set(gcf,'PaperUnits','inches','PaperPosition',newpos);
print(gcf, '-dpng', '-noui', '-opengl','-r600', exportfigname);
plot2svg([exportfigname,'.svg'],gcf, 'png');
delete(gcf);
end
