function [activlevel,activtype,maxmean,profile,dirselective,bestlt]=catstatres(getaligndata)
% categorize results according to stats
% VP 3/29/2013

activcats={'sac','vis','rew'};
[activtype,profile,dirselective]=deal('');
[maxmean,activlevel,bestlt]=deal(0);

alignt_q=find(~cellfun('isempty',(cellfun(@(x) x.trials, arrayfun(@(x) x, getaligndata),'UniformOutput', false))));
for lustat=1:length(alignt_q)
    % reminder of structure organization, top-down:
    % first level: one array for each category: sac, vis, rew
    % second level: one array for each condition, plus one (the last one) for all conditions collapsed
    % third level: in stats structure, three h values, representing
    % comparisons baseline vs pre-event; pre-vent vs post- event; baseline vs peri-event
    
    if arrayfun(@(x) nansum(x{:}.h), {getaligndata{alignt_q(lustat)}(~cellfun(@isempty, {getaligndata{alignt_q(lustat)}.stats})).stats})
 
    % applying qualifier     
    if isempty(activtype)
        activtype=[activtype activcats{alignt_q(lustat)}];
    else
        activtype=['_' activtype activcats{alignt_q(lustat)}];
    end    
   
    % find max activity and min max diff from qualified conditions (with >7
    % trials)
    maxfr=cell(1, size(getaligndata{alignt_q(lustat)},2)-1);
    for condnb=1:size(getaligndata{alignt_q(lustat)},2)-1
        sumall=nansum(getaligndata{alignt_q(lustat)}(condnb).rasters);
        sdf=spike_density(sumall,15)./size(getaligndata{alignt_q(lustat)}(condnb).rasters,1);
        maxfr{condnb}=round(sdf(getaligndata{alignt_q(lustat)}(condnb).alignidx+getaligndata{alignt_q(lustat)}(condnb).peakramp.peaksdft));
        minfr{condnb}=round(sdf(getaligndata{alignt_q(lustat)}(condnb).alignidx+getaligndata{alignt_q(lustat)}(condnb).peakramp.nadirsdft));
    end
    maxmax=round(max([maxfr{:}]));
    minminmax=round(max([maxfr{:}]-[minfr{:}]));
    
    % if several directions: find if direction selectivity
    
%     
%     if logical(nansum(arrayfun(@(x) x{:}.h(1), {getaligndata(~cellfun(@isempty, {getaligndata.stats})).stats})))
%         activreport = [activreport, 'presac_baseline '];
%     end
%     if logical(nansum(arrayfun(@(x) x{:}.h(2), {getaligndata(~cellfun(@isempty, {getaligndata.stats})).stats})))
%         activreport = [activreport, 'presac_postsac '];
%     end
%     if logical(nansum(arrayfun(@(x) x{:}.h(3), {getaligndata(~cellfun(@isempty, {getaligndata.stats})).stats})))
%         activreport = [activreport, 'perisac_baseline'];
%     end

    %% attributes
    % peak cross-correlation time
    
    [~,pkdistrib]=hist(peakcct,4);
    if (pkdistrib(1)<0 && pkdistrib(2)<0) && (pkdistrib(3)>0 && pkdistrib(4)>0)
        if median(abs(peakcct))>10
            peaktime='pre_post';
        else
            peaktime='perisac';
        end
    elseif sum(pkdistrib>0)==4
        if median(peakcct)>10
            peaktime='postsac';
        else
            peaktime='perisac';
        end
    elseif sum(pkdistrib<0)==4
        if median(peakcct)<-10
            peaktime='presac';
        else
            peaktime='perisac';
        end
    else
        if min(pkdistrib)>-10 && max(pkdistrib)<10
            peaktime='perisac';
        else
            peaktime='mixed';
        end
    end
    
    % main sdf peak, within -200/+199 of aligntime
    if sum(logical(hist(peaksdf,length(peaksdf))))>floor(length(peaksdf)/2) && max(peaksdf)>2*min(peaksdf)
        dirselective='dirselect';
    else
        dirselective='nonselect';
    end
    
    % area under curve and slope
    
    if logical(sum(dirslopes>400 & dirauc>2000))
        profile=[profile,'ramp_burst '];
    end
    if logical(sum(dirslopes>400 & dirauc<1500))
        profile=[profile,'burst '];
    end
    if logical(sum((dirslopes<0 & dirslopes>-400) & dirauc<-2000))
        profile=[profile,'suppression '];
    end
    
    % define activity level
    % find peak activity level (absolute FR) and min-max diff. Make index. 
    % add 1 to significant p_rmanov
        if logical(nansum(p_rmanov<0.05))
        end
        
    activstrength=0; 
    activlevel=activlevel+activstrength;
    
    
%         if logical(sum(p_rmanov<0.05))
%             activreport = 'rmanov positive';
%             statinfo={'0.5',activreport};
%         else
%             activreport = 'no sac activity';
%             statinfo={'0',activreport};
%         end

    end 
end
end


