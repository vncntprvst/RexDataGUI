function [p_cancellation,h_cancellation] = cmd_wilco_cancellation(recname,datalign)


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
    %matchtolat=prevssds+round(mssrt);
    % starting with the most prevalent
    matchlatidx=sacdelay>ssdvalues(ssdtotsidx(end))+round(mssrt);
    

% test NSS vs CSS, aligned to saccade/SSRT

    rastersNSS=datalign(1).rasters(matchlatidx,:);
    alignNSS=datalign(1).alignidx;

    ssdidx=(datalign(2).ssd==ssdvalues(ssdtotsidx(end)) | datalign(2).ssd==ssdvalues(ssdtotsidx(end))-1 | datalign(2).ssd==ssdvalues(ssdtotsidx(end))+1);
    rastersCSS=datalign(2).rasters(ssdidx,:);
    alignCSS=datalign(2).alignidx;
    
    NSStrials=(nansum(rastersNSS(:,alignNSS-20:alignNSS+20))/41)*1000;
    CSStrials=(nansum(rastersCSS(:,alignCSS-20:alignCSS+20))/41)*1000;
    [p_cancellation,h_cancellation] = signrank(NSStrials, CSStrials);


end