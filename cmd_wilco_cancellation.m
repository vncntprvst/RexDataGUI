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
    if length(prevssds)<2
        prevssds=sort(ssdvalues(ssdtotsidx(ssdtots>ceil(median(ssdtots)))));
    end
    [~,~,mssrt]=findssrt(recname);
    
        try
        probaresp_diff=hist(nccssd,prevssds)'./(hist(nccssd,prevssds)'+hist(ccssd,prevssds)');
        fullprobaresp_diff=hist(nccssd,ssdvalues)'./(hist(nccssd,ssdvalues)'+hist(ccssd,ssdvalues)');

        % fit sigmoid through inhibition function
        fitresult = sigmoidfit(prevssds, probaresp_diff);
        yfitval=fitresult(50:10:400); 
        % get SSD value at midpoint of IF
        midptSSD=mean([50+(find(yfitval>0.5,1)-2)*10 50+(find(yfitval>0.5,1)-1)*10]); %get SSD value for midpoint IF 
        
        catch
%             if ~sum(hist(ccssd,ssdvalues)) || ~sum(hist(nccssd,ssdvalues))
                [probaresp_diff,fullprobaresp_diff,yfitval,midptSSD]=deal(NaN);
%             end
        end

    %% get tychometric curve. Build matrix with 1. SSDs 2. RTs 3. success 
    SSDRTs=inf(length(allbad),3); % may differ from sum(~allbad)
    ccssd(ismember(ccssd,unique(ccssd-1)))=ccssd(ismember(ccssd,unique(ccssd-1)))+1;
    SSDRTs(datalign(1,2).trials,1)=ccssd;
    nccssd(find(ismember(nccssd,unique(nccssd-1))))=nccssd(find(ismember(nccssd,unique(nccssd-1))))+1;
    SSDRTs(datalign(1,3).trials,1)=nccssd;
    SSDRTs(datalign(1,1).trials,2)=sacdelay;
    SSDRTs(datalign(1,3).trials,2)=ncsacdelay;
    SSDRTs(datalign(1,3).trials,3)=0;
    SSDRTs(logical(allbad),3)=0;
    SSDRTs([datalign(1,1).trials datalign(1,2).trials],3)=1;
    [xctr xtach tach rPTc rPTe] = tachCM2(SSDRTs);
    
    % compare inhibition function and tychometric curve
    figure(21);

    subplot(2,2,1);
    plot(xtach,tach,'LineWidth',1.8);
    title('Tachometric function','FontName','calibri','FontSize',15);
    hxlabel=xlabel(gca,'rPT (ms)','FontName','calibri','FontSize',12);
    set(gca,'Xlim',[min(xtach) max(xtach)],'XTick',[min(xtach):50:max(xtach)],'TickDir','out','box','off'); %'XTickLabel',[50:50:400]
    hylabel=ylabel(gca,'Fraction cancelled','FontName','calibri','FontSize',12);
    set(gca,'Ylim',[0 1],'TickDir','out','box','off');
    
    subplot(2,2,3);
    plot(ssdvalues,fullprobaresp_diff,'-.k');   
    hold on
    plot(prevssds,probaresp_diff,'LineWidth',1.8);
    plot([50:10:400],yfitval,'Color',[0.2 0.4 0.6],'LineStyle',':');
    title('Inhibition function','FontName','calibri','FontSize',15);
    legend('full inhibition function','IF over most prevalent SSDs','sigmoid fit');
    hxlabel=xlabel(gca,'SSD (ms)','FontName','calibri','FontSize',12);
    set(gca,'Xlim',[0 500],'XTick',[min(xtach):50:max(xtach)],'TickDir','out','box','off'); %'XTickLabel',[50:50:400]
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
    %then prepare and plot saccade latency frequency, overall and split
    %into trial-history categories
    
    [saclatquant,saclatxlims]=hist(sacdelay,[0:25:500]);
    saclatfreq=saclatquant./sum(saclatquant);
 
    prevtrial=datalign(1,1).trials-1; %find trials preceding a NSS trial
    prevtrial=prevtrial(prevtrial>0);
    sdprevnsst=sacdelay(ismember(prevtrial,datalign(1,1).trials)); %get sacdelay when previous trial was a NSS trial
    prevsst=ismember(prevtrial,datalign(1,2).trials) | ismember(prevtrial,datalign(1,3).trials);
    sdprevsst=sacdelay(prevsst); %get sacdelay when previous trial was a SS trial
    sdprevsst_omp=sdprevsst(SSDRTs(prevtrial(prevsst),1)>midptSSD); %sac delay of NSS trials which previous trial was a SS with SSD > IF midpoint
    sdprevsst_ump=sdprevsst(SSDRTs(prevtrial(prevsst),1)<=midptSSD); %sac delay of NSS trials which previous trial was a SS with SSD > IF midpoint
    
    [pnssaclatquant,pnssaclatxlims]=hist(sdprevnsst,0:25:500);
    pnssaclatfreq=pnssaclatquant./sum(pnssaclatquant);
    [psssaclatquant,psssaclatxlims]=hist(sdprevsst,0:25:500);
    psssaclatfreq=psssaclatquant./sum(psssaclatquant);
    [omp_psssaclatquant,omp_psssaclatxlims]=hist(sdprevsst_omp,0:25:500);
    omd_psssaclatfreq=omp_psssaclatquant./sum(omp_psssaclatquant);
    [ump_psssaclatquant,ump_psssaclatxlims]=hist(sdprevsst_ump,0:25:500);
    umd_psssaclatfreq=ump_psssaclatquant./sum(ump_psssaclatquant);

    figure(21)
    subplot(2,2,4);
    plot(saclatxlims,saclatfreq,'Color','k','LineWidth',2);
    hold on;
    plot(pnssaclatxlims,pnssaclatfreq,'Color','r');
    plot(psssaclatxlims,psssaclatfreq,'Color','b'); 
%     following two plots split up RTs following low or high SSD
%     plot(omp_psssaclatxlims,omd_psssaclatfreq,'Color','b','LineWidth',1.5,'LineStyle','-.');
%     plot(ump_psssaclatxlims,umd_psssaclatfreq,'Color','b','LineWidth',1.5,'LineStyle',':');
    title('Saccade latencies in no-stop signal trials','FontName','calibri','FontSize',15);
    legend('overall RTs','RTs after NSS trial','RTs after SS trial','RTs after high SSD trial','RTs after low SSD trial')
    hxlabel=xlabel(gca,'Saccade latency','FontName','calibri','FontSize',12);
    set(gca,'Xlim',[0 500],'XTick',[0:50:500],'TickDir','out','box','off'); %'XTickLabel',[50:50:400]
    hylabel=ylabel(gca,'Proportion','FontName','calibri','FontSize',12);
    curylim=get(gca,'YLim');
    set(gca,'Ylim',[0 curylim(2)],'TickDir','out','box','off');
    
        % look at RTs increase across the session, to see if they are
    % driven by learning induced by gradual increase in SSD
    figure(22)
    subplot(4,1,1) %trialtype
    bar(SSDRTs(:,1)==Inf & logical(SSDRTs(:,3)));
    hold on
    bar(SSDRTs(:,1)~=Inf & logical(SSDRTs(:,3)),'g');
    bar(SSDRTs(:,1)~=Inf & ~logical(SSDRTs(:,3)),'r');
    title('trial type: blue, NSS - green, CSS - red, NCSS')
    set(gca,'Xlim',[0 size(SSDRTs,1)],'XTick',[0:50:size(SSDRTs,1)],'TickDir','out','box','off');
    set(gca,'TickDir','out','box','off');
    
    subplot(4,1,2) %NSS sac delays
    bar(SSDRTs(:,1)~=Inf & logical(SSDRTs(:,3)),'g');
    hold on
    bar(SSDRTs(:,1)~=Inf & ~logical(SSDRTs(:,3)),'r');
    set(gca,'Xlim',[0 size(SSDRTs,1)],'XTick',[0:50:size(SSDRTs,1)],'TickDir','out','box','off');
    set(gca,'TickDir','out','box','off');
    ssbarh=gca;
    nsstrials=datalign(1,1).trials;
    nssallsacdh=axes('Position',get(ssbarh,'Position'));
    plot(nsstrials,sacdelay,'k','LineWidth',2)
    title('overall RTs')
    set(nssallsacdh,'Ylim',[0 max(sacdelay)+50],'YAxisLocation','right','Color','none','XTickLabel',[],'TickDir','out','box','off')
    set(nssallsacdh,'XLim',get(ssbarh,'XLim'),'Layer','top')
    
    subplot(4,1,3)
    plot(nsstrials(ismember(prevtrial,datalign(1,1).trials)),sdprevnsst)
    title('RTs following NSS')
    set(gca,'Xlim',[0 size(SSDRTs,1)],'XTick',[0:50:size(SSDRTs,1)],'TickDir','out','box','off');
    set(gca,'Ylim',[0 max(sacdelay)+50],'TickDir','out','box','off');
    
    subplot(4,1,4)
    plot(nsstrials(prevsst),sdprevsst,'c')
    title('RTs following SS')
    set(gca,'Xlim',[0 size(SSDRTs,1)],'XTick',[0:50:size(SSDRTs,1)],'TickDir','out','box','off');
    set(gca,'Ylim',[0 max(sacdelay)+50],'TickDir','out','box','off');
    
    figure(23)
    nss_nss_cdf=cdfplot(sdprevnsst)
    hold on
    ss_nss_cdf=cdfplot(sdprevsst)
    
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