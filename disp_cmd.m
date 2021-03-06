function [allsdf,allrast,allalignidx,allssd,allviscuetimes,allcomp,protocol]=disp_cmd(recname,datalign,aligntype,plottype)
global directory;
% if latmach
%% first get SSDs and SSRT, to later parse latency-matched trials and CSS according to SSDs

%     load(recname(1:end-6),'allbad','allcodes','alltimes','saccadeInfo'); %
%     alllats=reshape({saccadeInfo.latency},size(saccadeInfo));
%     alllats=alllats';%needs to be transposed because the logical indexing below will be done column by column, not row by row
%     allgoodsacs=~cellfun('isempty',reshape({saccadeInfo.latency},size(saccadeInfo)));
%     %removing bad trials
%     allgoodsacs(logical(allbad),:)=0;
%     %removing stop trials that may be included
%     allgoodsacs(floor(allcodes(:,2)./1000)~=6,:)=0;
%     %indexing good sac trials
%     % if saccade detection corrected, there may two 'good' saccades
%     if max(sum(allgoodsacs,2))>1
%         twogoods=find(sum(allgoodsacs,2)>1);
%         for dblsac=1:length(twogoods)
%             allgoodsacs(twogoods(dblsac),find(allgoodsacs(twogoods(dblsac),:),1))=0;
%         end
%     end
%     sacdelay=(cell2mat(alllats(allgoodsacs')));
%     %get reward time for NSS trials
%     goodsactimes=alltimes(logical(sum(allgoodsacs,2)),:);
%     rewtimes=goodsactimes(allcodes(logical(sum(allgoodsacs,2)),:)==1030);

% find Cmd protocol: fixed SSDs or staircase
if strcmp(aligntype,'ssd')
    allssds=cat(find(size(datalign(1,3).ssd)==max(size(datalign(1,3).ssd))),datalign(1,3:4).ssd);
    [~,ordersstrials]=sort([datalign(1,3:4).trials]);
else
    allssds=cat(find(size(datalign(1,2).ssd)==max(size(datalign(1,2).ssd))),datalign(1,2:3).ssd);
    [~,ordersstrials]=sort([datalign(1,2:3).trials]);
end

allssds=allssds(ordersstrials); %put ssds in the order they occured
sddsteps=diff(allssds);
if std(sddsteps(sddsteps>0))>20
    protocol='multiple fixed ssd';
    
else
    protocol='staircase';
end
    disp(protocol);
    
%% get CSS SSDs
%     ccssd=datalign(2).ssd;
%     if size(ccssd,2)>size(ccssd,1)
%         ccssd=permute(ccssd,[2,1]);
%     end
%     nccssd=datalign(3).ssd;
%     if size(nccssd,2)>size(nccssd,1)
%         nccssd=permute(nccssd,[2,1]);
%     end
%         if size(ccssd,2)>1
%         ccssd=ccssd(:,1);
%         nccssd=nccssd(:,1);
%         end
%     ssdvalues=sort(unique([ccssd;nccssd]));
%     ssdvalues(find(diff(ssdvalues)==1)+1)=ssdvalues(diff(ssdvalues)==1);
%     ssdvalues=ssdvalues(diff(ssdvalues)>0);
%     if sum(diff(ssdvalues)==1) % second turn
%         ssdvalues(diff(ssdvalues)==1)=ssdvalues(diff(ssdvalues)==1)+1;
%         ssdvalues=ssdvalues(diff(ssdvalues)>0);
%     end

%% get SSRT used for alignement

[mssrt,~,ccssd,nccssd,ssdvalues,tachomc,tachowidth,sacdelay,rewtimes]=findssrt(recname(1:end-6),0); %1 is for plotting psychophysic curves
 mssrt=max([mssrt tachomc+tachowidth/2]);

%% find and keep most prevalent ssds
    
    if plottype==3
        [~,ssdhistlims]=hist([ccssd;nccssd],3);
    else
        ccssdval=unique(ccssd);
        while sum(diff(ccssdval)==1)
            ccssdval(diff(ccssdval)==1)=ccssdval(diff(ccssdval)==1)+1;
        end
        ccssdval=unique(ccssdval);

        nccssdval=unique(nccssd);
        while sum(diff(nccssdval)==1)
            nccssdval(diff(nccssdval)==1)=nccssdval(diff(nccssdval)==1)+1;
        end
        nccssdval=unique(nccssdval);
    end
    
if strcmp(aligntype,'correct_slow')
    if plottype==3 %select and pool short SSD, med SSD and long SSD
        resssdvalues(1)=round(ssdhistlims(1)+(ssdhistlims(2)-ssdhistlims(1))/2); %short SSD below that level
        resssdvalues(2)=round(ssdhistlims(3)-(ssdhistlims(3)-ssdhistlims(2))/2); %long SSD above that level
%         resssdvalues(3)=max([ccssd;nccssd]); %not even necessary. Was just to avoid matchlat from bugging
        numplots=3;
    else    
        [ssdtots,ssdtotsidx]=sort((arrayfun(@(x) sum(ccssd<=x+3 & ccssd>=x-3),unique(ccssd))));
        % loops below will iterate through matched sac delays while not removing too many CSS trials 
        numplots=sum(ssdtots>=3);
        resssdvalues=sort(ccssdval(ssdtotsidx(ssdtots>=3)));
    end
elseif strcmp(aligntype,'failed_fast')

    [ssdtots,ssdtotsidx]=sort((arrayfun(@(x) sum(nccssd<=x+3 & nccssd>=x-3),unique(nccssdval))));
    % will iterate through matched sac delays while not removing too many CSS trials
    numplots=sum(ssdtots>=3);
    resssdvalues=sort(nccssdval(ssdtotsidx(ssdtots>=3)));
elseif strcmp(aligntype,'ssd')
    numplots=2;
else
    numplots=1;
end

   
    
%% presets
% need to match latencies in all cases
if strcmp(aligntype,'correct_slow') %ie, aligned to target
    latmach=1;
    if plottype==1 %keep all three struct in datalign %former triplot
    elseif plottype==3
        datalign=datalign(2:3);
    else
        % only two conditions: NSS Vs CSS
        datalign=datalign(1:2); 
    end
    plotstart=200;
    plotstop=600;
    cellkeepsz=size(datalign,2);
elseif strcmp(aligntype,'failed_fast')% aligned to sac  NSS Vs NCSS
    latmach=1;
    datalign=datalign([1 3]);
    plotstart=1000;
    plotstop=1000;
    cellkeepsz=size(datalign,2);
elseif strcmp(aligntype,'ssd') % aligned to ssd, split into two figure: CSS vs slow NSS abd NCSS vs fast CSS
    latmach=1; 
    plotstart=800;
    plotstop=600;
    org_datalign=datalign;
    cellkeepsz=size(datalign,2)/2;
end

 %% preallocs
    allsdf=cell(cellkeepsz,numplots);
    allrast=cell(cellkeepsz,numplots);
    allssd=cell(cellkeepsz,numplots);
    allviscuetimes=cell(cellkeepsz,numplots);
    allalignidx=cell(cellkeepsz,numplots);
    allcomp=cell(cellkeepsz,numplots);
    
%% plots
for plotnum=1:numplots
    
    if strcmp(aligntype,'correct_slow') && plottype~=3
        matchlatidx=sacdelay>resssdvalues(plotnum)+round(mssrt);
        adjmssrt=round(mssrt)-1;
        while sum(matchlatidx)<7 && adjmssrt>=max([70 tachomc])
            matchlatidx=sacdelay>resssdvalues(plotnum)+adjmssrt;
            adjmssrt=adjmssrt-1;
        end
        mssrt=adjmssrt+1;
    elseif strcmp(aligntype,'failed_fast')  
        matchlatidx=sacdelay>resssdvalues(plotnum)+50 & sacdelay<resssdvalues(plotnum)+round(mssrt);  
    elseif strcmp(aligntype,'ssd')
        datalign=org_datalign([plotnum plotnum+2]);
    end
    
%     if triplot
        numrast=size(datalign,2);
%     else
%         numrast=2;
%     end
    fsigma=20;
    cc=lines(numrast);
    numsubplot=numrast*3; %dividing the panel in three compartments with equal number of subplots
    
    %% plotting main figure
    cmdplots(plotnum)=figure('color','white','position',[826    49   524   636]);
    for trialtype=1:numrast
        if (strcmp('tgt',datalign(trialtype).alignlabel) || strcmp('sac',datalign(trialtype).alignlabel)) && ~strcmp(aligntype,'ssd') && latmach
            rasters=datalign(trialtype).rasters(matchlatidx,:);
            alignidx=datalign(trialtype).alignidx;
            greyareas=datalign(trialtype).allgreyareas(matchlatidx);
            matchrewtimes=rewtimes(matchlatidx);            
        elseif (strcmp('stop_cancel',datalign(trialtype).alignlabel) || strcmp('stop_non_cancel',datalign(trialtype).alignlabel)) && ~strcmp(aligntype,'ssd') && latmach
            if plottype==3
                if plotnum==1 %|| plotnum==2
                    ssdidx=datalign(trialtype).ssd<=resssdvalues(1);
                elseif plotnum==2 %|| plotnum==4
                    ssdidx=datalign(trialtype).ssd>=resssdvalues(1) & datalign(trialtype).ssd<=resssdvalues(2);
                elseif plotnum==3 %|| plotnum==6
                    ssdidx=datalign(trialtype).ssd>=resssdvalues(2);
                end                    
            else
                ssdidx=datalign(trialtype).ssd>=resssdvalues(plotnum)-3 & datalign(trialtype).ssd<=resssdvalues(plotnum)+3;
            end
            rasters=datalign(trialtype).rasters(ssdidx,:);
            if strcmp('stop_non_cancel',datalign(trialtype).alignlabel) || plottype==3
                alignidx=datalign(trialtype).alignidx;
                if size(datalign(trialtype).ssd,2)>size(datalign(trialtype).ssd,1)
                    datalign(trialtype).ssd=permute(datalign(trialtype).ssd,[2,1]);
                end
            else
                alignidx=datalign(trialtype).alignidx-(resssdvalues(plotnum)+round(mssrt)); % shifting rasters to target presentation
            end
            greyareas=datalign(trialtype).allgreyareas(ssdidx);
        else
            rasters=datalign(trialtype).rasters;
            alignidx=datalign(trialtype).alignidx;
            greyareas=datalign(trialtype).allgreyareas;
            timetorew=datalign(trialtype).sactotrig;
            if strcmp(datalign(trialtype).alignlabel,'stop_non_cancel')
                if size(datalign(trialtype).ssd,2)>size(datalign(trialtype).ssd,1)
                    datalign(trialtype).ssd=permute(datalign(trialtype).ssd,[2,1]);
                end
            end
        end
        if ~isempty(rasters)
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
        
        hrastplot(trialtype)=subplot(numsubplot,1,trialtype,'Layer','top', ...
            'XTick',[],'YTick',[],'XColor','white','YColor','white', 'Parent', cmdplots(plotnum));
        
        %reducing spacing between rasters
        rastpos=get(gca,'position');
        rastpos(2)=rastpos(2)+rastpos(4)*0.5;
        set(gca,'position',rastpos);
        
        
        % sorting rasters according greytime
        viscuetimes=nan(size(greyareas,2),2);
        sactimes=nan(size(greyareas,2),1);
        for grst=1:size(greyareas,2)
            %         if strcmp('stop_cancel',datalign(i).alignlabel) && latmach
            %             viscuetimes(grst,:)=greyareas{grst}(1,:); % -(resssdvalues(plotnum)+round(mssrt))
            %         else
            viscuetimes(grst,:)=greyareas{grst}(1,:);
            %         end
            sactimes(grst)=greyareas{grst}(2,1)-start;
        end
        if strcmp(datalign(trialtype).alignlabel,'tgt') && ~strcmp(aligntype,'ssd') && latmach 
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
                plot([spiketimes;spiketimes],[ones(size(spiketimes))*j;ones(size(spiketimes))*j-1],'color',cc(trialtype,:),'LineStyle','-');
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
                if strcmp(datalign(trialtype).alignlabel,'stop_non_cancel') && strcmp(aligntype,'failed_fast')
                    plot(greytimes(1)+datalign(trialtype).ssd(j,1),j-0.5,'kd','MarkerSize', 3,'LineWidth', 1.2)
                elseif strcmp(datalign(trialtype).alignlabel,'stop_non_cancel') && strcmp(aligntype,'correct_slow')
                    
                elseif strcmp(datalign(trialtype).alignlabel,'tgt') && strcmp(aligntype,'correct_slow')
                    plot(sactimes(j),j-0.5,'kd','MarkerSize', 3,'LineWidth', 1.5)
                elseif strcmp(datalign(trialtype).alignlabel,'stop_cancel') && strcmp(aligntype,'correct_slow') && ~plottype==3
                    plot(alignidx+resssdvalues(plotnum)-start,j-0.5,'k^','MarkerSize', 2,'LineWidth', 1) % SSD
                    plot(alignidx+resssdvalues(plotnum)+round(mssrt)-start,j-0.5,'kv','MarkerSize', 2,'LineWidth', 1) % SSD +SSRT
                end
            end
        end
        %     if strcmp(datalign(i).alignlabel,'stop_cancel') && latmach
        %         % plot SSD
        %             patch([repmat((alignidx+resssdvalues(plotnum))-2,1,2) repmat((alignidx+resssdvalues(plotnum))+2,1,2)], ...
        %             [[0 currylim(2)] fliplr([0 currylim(2)])], ...
        %             [0 0 0 0],[1 1 1],'EdgeColor','none','FaceAlpha',1);
        %         % plot SSRT
        %             patch([repmat((alignidx+resssdvalues(plotnum)+round(mssrt))-2,1,2) repmat((alignidx+resssdvalues(plotnum)+round(mssrt))+2,1,2)], ...
        %             [[0 currylim(2)] fliplr([0 currylim(2)])], ...
        %             [0 0 0 0],[1 1 1],'EdgeColor','none','FaceAlpha',1);
        %     end
        
        set(hrastplot(trialtype),'xlim',[1 length(start:stop)]);
        if strcmp(datalign(trialtype).alignlabel,'stop_cancel') && ~strcmp(aligntype,'ssd') && latmach && ~plottype==3
            axes(hrastplot(trialtype));
            patch([repmat((alignidx+resssdvalues(plotnum)+round(mssrt)-start)-tachowidth/2,1,2)...
                repmat((alignidx+resssdvalues(plotnum)+round(mssrt)-start)+tachowidth/2,1,2)], ...
                [[0 size(rasters,1)] fliplr([0 size(rasters,1)])], ...
                [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
        end
        axis(gca, 'off'); % axis tight sets the axis limits to the range of the data.
        
        
        %Plot sdf
        sdfplot=subplot(numsubplot,1,(numsubplot/3)+1:(numsubplot/3)+(numsubplot/3),'Layer','top','Parent', cmdplots(plotnum));
        %sdfh = axes('Position', [.15 .65 .2 .2], 'Layer','top');
        title('Spike Density Function','FontName','calibri','FontSize',11);
        hold on;
        if size(rasters,1)<5 && plottype~=3 %if only few good trials
            %sumall=rasters(~isnantrial,start-fsigma:stop+fsigma);
            %useless plotting this
            sumall=NaN;
        elseif plottype==3
            if size(rasters,1)==1
                sumall=(rasters(~isnantrial,start-fsigma:stop+fsigma));
            else
                sumall=sum(rasters(~isnantrial,start-fsigma:stop+fsigma));
            end
        else
            sumall=sum(rasters(~isnantrial,start:stop));
        end
        %     sdf=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead of number of trials
        sdf=fullgauss_filtconv(sumall,fsigma,0)./length(find(~isnantrial)).*1000;
%         sdf=sdf(fsigma+1:end-fsigma);
        
         %% calculate confidence intervals
    lcut_rasters=rasters(~isnantrial,start:stop);
    smoothtrial=zeros(size(lcut_rasters));
    for crsem=1:size(rasters(~isnantrial),1)
        smoothtrial(crsem,:)=fullgauss_filtconv(lcut_rasters(crsem,:),1,0).*1000; 
    end
%     smoothtrial=smoothtrial(:,fsigma+1:end-fsigma);
%     if numrast==2 && rastnum==1  %collect old trials
%           first_smtrials=smoothtrial;
%     end
    rastsem=std(smoothtrial)/ sqrt(size(smoothtrial,1)); %standard error of the mean
    %norminv([.025 .975], mean(smoothtrial), std(smoothtrial));
    rastsem = rastsem * 1.96; % 95% of the data will fall within 1.96 standard deviations of a normal distribution
  
    
        plot(sdf,'Color',cc(trialtype,:),'LineWidth',1.8);
        
        if strcmp(datalign(trialtype).alignlabel,'stop_cancel') && ~strcmp(aligntype,'ssd') && latmach && ~plottype==3
            patch([repmat((alignidx+resssdvalues(plotnum)-start)-1,1,2) repmat((alignidx+resssdvalues(plotnum)-start)+1,1,2)], ...
                [[0 currylim(2)] fliplr([0 currylim(2)])],[0 0 0 0],'k^','EdgeColor','none','FaceAlpha',0.5);
            patch([repmat((alignidx+resssdvalues(plotnum)+round(mssrt)-start)-1,1,2) repmat((alignidx+resssdvalues(plotnum)+round(mssrt)-start)+1,1,2)], ...
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
        
        if ~isempty(rasters) && trialtype==1
            % drawing the alignment bar
            alignbarh=patch([repmat((alignidx-start)-2,1,2) repmat((alignidx-start)+2,1,2)], ...
                [[0 currylim(2)] fliplr([0 currylim(2)])], ...
                [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
        end
        
        %Plot eye velocities
        heyevelplot=subplot(numsubplot,1,(numsubplot*2/3)+1:numsubplot,'Layer','top','Parent', cmdplots(plotnum));
        title('Mean Eye Velocity','FontName','calibri','FontSize',11);
        hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
        
        hold on;
        if ~isempty(rasters)
            eyevel=datalign(trialtype).eyevel;
            eyevel=mean(eyevel(:,start:stop));
            heyevelline(trialtype)=plot(eyevel,'Color',cc(trialtype,:),'LineWidth',1);
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
            curdir{trialtype}=datalign(trialtype).dir;
            rastaligntype{trialtype}=datalign(trialtype).alignlabel;
        else
            curdir{trialtype}='no';
            rastaligntype{trialtype}='data';
        end
        
        %% keep sdf, rasters etc
        allsdf{trialtype,plotnum}=sdf;
        allrast{trialtype,plotnum}=smoothtrial;%(:,start:stop);
        if plottype~=3
            allssd{plotnum}=resssdvalues;
        else
            allssd{trialtype,plotnum}=round([mean(datalign(trialtype).ssd(ssdidx)),std(datalign(trialtype).ssd(ssdidx))]);
        end
        %     alltimetorew{i}=timetorew;
        allalignidx{trialtype,plotnum}=alignidx;
        % get pre-cue 200ms activity
        allviscuetimes{trialtype,plotnum}=viscuetimes(:,1);
        allcomp{trialtype,plotnum}=[datalign(trialtype).alignlabel '_' aligntype];
        end
    end
    
    %% moving up all rasters now
    if size(hrastplot,2)==1
        allrastpos=(get(hrastplot,'position'));
    else
        allrastpos=cell2mat(get(hrastplot,'position'));
    end
    
    disttotop=allrastpos(1,2)+allrastpos(1,4);
    if disttotop<0.99 %if not already close to top of container
        allrastpos(:,2)=allrastpos(:,2)+(1-disttotop)/1.5;
    end
    if size(hrastplot,2)>1
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
    set(heyevelplot,'XTick',0:100:(stop-start));
    set(heyevelplot,'XTickLabel',-plotstart:100:plotstop);
    
    % plot a legend in this last graph
    clear spacer
    spacer(1:size(hrastplot,2),1)={' '};
    %cellfun('isempty',{datalign(:).dir})
    if  logical(sum(cell2mat(strfind(rastaligntype,'error1'))) || sum(cell2mat(strfind(rastaligntype,'error2'))))
        rastaligntype{~cellfun(@(x) (strcmp(x,'error1') || strcmp(x,'error2')), rastaligntype)}=...
            ['good trial ' rastaligntype{~cellfun(@(x) (strcmp(x,'error1') || strcmp(x,'error2')), rastaligntype)}];
        rastaligntype(cellfun(@(x) (strcmp(x,'error1') || strcmp(x,'error2')), rastaligntype))={'wrong trial'};
    end
    if latmach
        legloc='NorthEast';
    else
        legloc='NorthWest';
    end
    if strcmp(rastaligntype{1},'tgt') || strcmp(rastaligntype{1},'sac')
        rastaligntype{1}='no-stop signal';
    end
    if strcmp(rastaligntype{2},'stop_cancel')
        rastaligntype{2}='cancelled stop-signal';
    end
    if strcmp(rastaligntype{2},'stop_non_cancel')
        rastaligntype{2}='non cancelled stop-signal';
    end
    hlegdir = legend(heyevelline, strcat(rastaligntype',spacer,curdir'),'Location',legloc);
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
    
%     %% quantify differential activity
%     
%     fullsdf=cell(numrast,1);
%     
%     for rasts=1:size(hrastplot,2)
%         rasters=allrast{rasts};
%         viscuetimes=allviscuetimes{rasts};
%         
%         allbaseline=zeros(size(rasters,1),200+2*fsigma);
%         for rastunit=1:size(rasters,1) %plotting rasters trial by trial
%             rasters(rastunit,isnan(rasters(rastunit,:)))=0;
%             allbaseline(rastunit,:)=rasters(rastunit, viscuetimes(rastunit)-200-fsigma:viscuetimes(rastunit)-1+fsigma);
%         end
%         %     precuesdf{rasts}=spike_density(nansum(allbaseline),fsigma)./size(rasters,1);
%         precuesdf{rasts}=fullgauss_filtconv(nansum(allbaseline),fsigma,0)./size(rasters,1).*1000;
%         precuesdf{rasts}=precuesdf{rasts}(fsigma+1:end-fsigma);
%         
%         if size(allrast{rasts},1)>1 %if more than one good trial
%             if plotstart==200 %aligned to target
%                 if strcmp('tgt',datalign(rasts).alignlabel) %the NSS trials
%                     sumall=sum(rasters(:,allalignidx{rasts}-(600+fsigma):max(matchrewtimes)+fsigma));
%                 else % base end limit on NSS trial limit
%                     sumall=sum(rasters(:,allalignidx{rasts}-(600+fsigma):size(fullsdf{rasts-1},2)+fsigma+(allalignidx{rasts}-601)));
%                 end
%             else
%                 if strcmp('sac',datalign(rasts).alignlabel) || strcmp('corsac',datalign(rasts).alignlabel) %the NSS trials
%                     sumall=sum(rasters(:,allalignidx{rasts}-(1000+fsigma):max(rewtimes)+fsigma));
%                 else
%                     sumall=sum(rasters(:,allalignidx{rasts}-(1000+fsigma):size(fullsdf{rasts-1},2)+fsigma+(allalignidx{rasts}-1001)));
%                 end
%             end
%         end
%         %     fullsdf{rasts}=spike_density(sumall,fsigma)./size(rasters,1);
%         fullsdf{rasts}=fullgauss_filtconv(sumall,fsigma,0)./size(rasters,1).*1000;
%         fullsdf{rasts}=fullsdf{rasts}(fsigma+1:end-fsigma);
%     end
%     
%     if plotstart==200 %aligned to target
%         precuelevel=floor(mean((floor(fullsdf{1}(401:600))-floor(fullsdf{rasts}(401:600)))));
%         sigthreshold=floor(2*(floor(std(floor(fullsdf{1}(401:600))-floor(fullsdf{rasts}(401:600)))))+precuelevel);
%         diffsdf=ceil(abs([fullsdf{1}]-[fullsdf{rasts}]));
%     else
%         precuelevel=floor(mean(abs(floor(precuesdf{rasts})-floor(precuesdf{1}))));
%         sigthreshold=floor(2*(floor(std(floor(precuesdf{rasts})-floor(precuesdf{1}))))+precuelevel);
%         diffsdf=ceil(abs([fullsdf{rasts}]-[fullsdf{1}]));
%     end
%     
%     sigdiff=diffsdf>=sigthreshold;
%     sigdiffepochs=bwlabel(sigdiff);
%     confsigdiffepochs=zeros(size(sigdiffepochs));
%     % separate plot
%     % figure
%     % plot(fullsdf{1})
%     % hold on
%     % plot(fullsdf{rasts},'r')
%     % plot(diffsdf,'g')
%     % plot(ones(size(diffsdf))*sigthreshold,'m')
%     % foo=6*(std(diffsdf(401:600)))+precuelevel;
%     % plot(ones(size(diffsdf))*foo,'m');
%     
%     if max(sigdiffepochs)
%         for sdenum=1:max(sigdiffepochs)
%             maxdiff=max(diffsdf(sigdiffepochs==sdenum));
%             sigdiffdur=sum(sigdiffepochs==sdenum);
%             if plotstart==200 %aligned to target
%                 if maxdiff>=floor(6*(std(floor(fullsdf{1}(401:600))-floor(fullsdf{rasts}(401:600))))) && sigdiffdur>=30
%                     confsigdiffepochs(find(sigdiffepochs==sdenum,1))=1;
%                 end
%             else
%                 if maxdiff>=floor(6*(floor(std(floor(precuesdf{rasts})-floor(precuesdf{1}))))+precuelevel) && sigdiffdur>=30
%                     confsigdiffepochs(find(sigdiffepochs==sdenum,1))=1;
%                 end
%             end
%         end
%         if max(confsigdiffepochs)
%             figure(cmdplots(plotnum))
%             if plotstart==200 %aligned to target
%                 plot(sdfplot,find(confsigdiffepochs)-400,ones(1,sum(confsigdiffepochs))*10,'xr','markersize',12);
%                 if sum(find(confsigdiffepochs)-400>alignidx+resssdvalues(plotnum)-start &...
%                         find(confsigdiffepochs)-400<alignidx+resssdvalues(plotnum)+round(mssrt)-start)
%                     cancellation_time=alignidx+resssdvalues(plotnum)+round(mssrt)-start-(find(confsigdiffepochs,1)-400);
%                     cancellation_strengh=max(diffsdf(sigdiffepochs==sigdiffepochs(find(confsigdiffepochs,1))));
%                 end
%             else
%                 plot(sdfplot,find(confsigdiffepochs),ones(1,sum(confsigdiffepochs))*10,'xr','markersize',12);
%                 if sum(find(confsigdiffepochs)>alignidx-start)
%                     error_time=find(confsigdiffepochs(alignidx-start:end),1)-1;
%                     %                     cancellation_strengh
%                 end
%             end
%         end
%     end
    
    %% condense plot
    % figuresize=getpixelposition(gcf);
    % figuresize(1:2)=[80 167];
    % figure(1)
    subplots=findobj(cmdplots(plotnum),'Type','axes');
    %  set(subplots,'Units','pixels')
    axespos=cell2mat(get(subplots,'Position'));
    figtitleh = title(subplots(find(axespos(:,2)==max(axespos(:,2)),1)),...
        ['File: ',recname,' - Task: Countermanding - Alignment:',[datalign(1:numrast).alignlabel]]);
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
    
    if strcmp('tgt',datalign(1).alignlabel) && ~strcmp(aligntype,'ssd') && latmach
        comp=['NSSvsCSS_tgt_ssd' num2str(resssdvalues(plotnum))];
    elseif (strcmp('sac',datalign(1).alignlabel) || strcmp('corsac',datalign(1).alignlabel)) && latmach
        if strcmp('sac',datalign(1).alignlabel)
            comp='NSSvsCSS_sac';
        else
            comp='NSSvsCSS_corsac';
        end
    elseif (strcmp('sac',datalign(1).alignlabel) || strcmp('corsac',datalign(1).alignlabel)) && ~latmach
        if strcmp('sac',datalign(1).alignlabel)
            comp='NSSvsNCSS_sac';
        else
            comp='NSSvsNCSS_corsac';  
        end
    elseif strcmp('ssd',aligntype)
        if plotnum==1
            comp='NSSvsCSS_ssd';
        elseif plotnum==2
            comp='NSSvsNCSS_ssd';
        end
    elseif strcmp('stop_cancel',datalign(1).alignlabel)
        comp='CSSvsNCSS';
    end
    exportfigname=[cell2mat(regexp(directory,'\w+:\\\w+\\','match')),'Analysis\Countermanding\',recname,'_',comp];
    %basic png fig:
    newpos =  get(gcf,'Position')/60;
    set(gcf,'PaperUnits','inches','PaperPosition',newpos);
%      print(gcf, '-dpng', '-noui', '-opengl','-r600', exportfigname);
    
%     plot2svg([exportfigname,'.svg'],gcf, 'png');
%      delete(gcf);
end
end
