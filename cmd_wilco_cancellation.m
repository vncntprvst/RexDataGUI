function [p_cancellation,h_cancellation,xctr] = cmd_wilco_cancellation(recname,datalign)


    %% first get SSDs and SSRT, to later parse latency-matched trials and CSS according to SSDs

    load(recname,'allbad','allcodes','alltimes','saccadeInfo'); % 
    alllats=reshape({saccadeInfo.latency},size(saccadeInfo));
    alllats=alllats';%needs to be transposed because the logical indexing below will be done column by column, not row by row
    allgoodsacs=~cellfun('isempty',reshape({saccadeInfo.latency},size(saccadeInfo)));
    %removing bad trials
    allgoodsacs(logical(allbad),:)=0;
    %keeping sac info of non-canceled SS trials
    allncsacs=allgoodsacs;
    allncsacs(floor(allcodes(:,2)./1000)==6,:)=0; % nullifying NSS trials
    allncsacs(datalign(1,2).trials,:)=0; % nullifying CSS trials
    %then removing stop trials from allgoodsac
    allgoodsacs(floor(allcodes(:,2)./1000)~=6,:)=0;
    %indexing good sac trials
    % if saccade detection corrected, there may two 'good' saccades
    if max(sum(allgoodsacs,2))>1
        twogoods=find(sum(allgoodsacs,2)>1);
        for dblsac=1:length(twogoods)
            allgoodsacs(twogoods(dblsac),find(allgoodsacs(twogoods(dblsac),:),1))=0;
        end
    end
    sacdelay=cell2mat(alllats(allgoodsacs'));
    ncsacdelay=cell2mat(alllats(allncsacs'));
    
    %% get CSS SSDs
    ccssd=datalign(2).ssd;
    nccssd=datalign(3).ssd;
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
    % find and keep most prevalent ssds
    [ssdtots,ssdtotsidx]=sort((arrayfun(@(x) sum(ccssd==x | ccssd==x-1 | ccssd==x+1),ssdvalues))+...
    (arrayfun(@(x) sum(nccssd==x | nccssd==x-1 | nccssd==x+1),ssdvalues)));
    prevssds=sort(ssdvalues(ssdtotsidx(ssdtots>ceil(median(ssdtots))+1)));
    [~,~,mssrt]=findssrt(recname);
    
    %% get tychometric curve
    SSDRTs=inf(length([datalign(1,1).trials datalign(1,2).trials datalign(1,3).trials]),3); % may differ from sum(~allbad)
    ccssd(find(ismember(ccssd,unique(ccssd-1))))=ccssd(find(ismember(ccssd,unique(ccssd-1))))+1;
    SSDRTs(datalign(1,2).trials,1)=ccssd;
    nccssd(find(ismember(nccssd,unique(nccssd-1))))=nccssd(find(ismember(nccssd,unique(nccssd-1))))+1;
    SSDRTs(datalign(1,3).trials,1)=nccssd;
    SSDRTs(datalign(1,1).trials,2)=sacdelay;
    SSDRTs(datalign(1,3).trials,2)=ncsacdelay;
    SSDRTs(datalign(1,3).trials,3)=0;
    SSDRTs([datalign(1,1).trials datalign(1,2).trials],3)=1;
    [xctr xtach tach rPTc rPTe] = tachCM2(SSDRTs);
    
    % compare inhibition function and tychometric curve
    figure(21);
    probaresp_diff=hist(nccssd,prevssds)'./(hist(nccssd,prevssds)'+hist(ccssd,prevssds)');
    subplot(2,2,3);
    plot(prevssds,probaresp_diff,'LineWidth',1.8);   
    title('Inhibition function','FontName','calibri','FontSize',15);
    hxlabel=xlabel(gca,'SSD (ms)','FontName','calibri','FontSize',12);
    set(gca,'Xlim',[0 500],'XTick',[min(xtach):50:max(xtach)],'TickDir','out','box','off'); %'XTickLabel',[50:50:400]
    hylabel=ylabel(gca,'Fraction cancelled','FontName','calibri','FontSize',12);
    set(gca,'Ylim',[0 1],'TickDir','out','box','off');
    
    subplot(2,2,1);
    plot(xtach,tach,'LineWidth',1.8);
    title('Tachometric function','FontName','calibri','FontSize',15);
    hxlabel=xlabel(gca,'rPT (ms)','FontName','calibri','FontSize',12);
    set(gca,'Xlim',[min(xtach) max(xtach)],'XTick',[min(xtach):50:max(xtach)],'TickDir','out','box','off'); %'XTickLabel',[50:50:400]
    hylabel=ylabel(gca,'Fraction cancelled','FontName','calibri','FontSize',12);
    set(gca,'Ylim',[0 1],'TickDir','out','box','off');
    
    % plot rPTs and NSS sac delays
    % first rPTs
    subplot(2,2,2);
    plot(xtach,rPTc,'r')
    hold on
    plot(xtach,rPTe,'b')
    title('Distribution of rPTs','FontName','calibri','FontSize',15);
    hxlabel=xlabel(gca,'rPT values','FontName','calibri','FontSize',12);
    set(gca,'Xlim',[min(xtach) max(xtach)],'XTick',[min(xtach):50:max(xtach)],'TickDir','out','box','off'); %'XTickLabel',[50:50:400]
    hylabel=ylabel(gca,'N','FontName','calibri','FontSize',12);
    set(gca,'TickDir','out','box','off');
    legend('rPTc','rPTe');
    %then prepare and plot saccade latency frequency
    
    [saclatquant,saclatxlims]=hist(sacdelay,[0:25:500]);
    saclatfreq=saclatquant./sum(saclatquant);
    
    subplot(2,2,4);
    plot(saclatxlims,saclatfreq,'Color','k','LineWidth',1.8);
    title('Saccade Latency','FontName','calibri','FontSize',15);
    hxlabel=xlabel(gca,'Saccade latency','FontName','calibri','FontSize',12);
    set(gca,'Xlim',[0 500],'XTick',[0:50:500],'TickDir','out','box','off'); %'XTickLabel',[50:50:400]
    hylabel=ylabel(gca,'Proportion','FontName','calibri','FontSize',12);
    curylim=get(gca,'YLim');
    set(gca,'Ylim',[0 curylim(2)],'TickDir','out','box','off');
    
%% matching latency to delays    
    %matchtolat=prevssds+round(mssrt);
    % starting with the most prevalent
    matchlatidx=sacdelay>ssdvalues(ssdtotsidx(end))+round(mssrt);
    
%% test no-stop signal (NSS) vs canceled stop-signal (CSS), aligned to saccade/SSRT

    rastersNSS=datalign(1).rasters(matchlatidx,:);
    alignNSS=datalign(1).alignidx;

    ssdidx=(datalign(2).ssd==ssdvalues(ssdtotsidx(end)) | datalign(2).ssd==ssdvalues(ssdtotsidx(end))-1 | datalign(2).ssd==ssdvalues(ssdtotsidx(end))+1);
    rastersCSS=datalign(2).rasters(ssdidx,:);
    alignCSS=datalign(2).alignidx;
    
    % keep 41ms around alignement
    NSStrials=(nansum(rastersNSS(:,alignNSS-20:alignNSS+20))/41)*1000;
    CSStrials=(nansum(rastersCSS(:,alignCSS-20:alignCSS+20))/41)*1000;
    [p_cancellation,h_cancellation] = signrank(NSStrials, CSStrials);


end