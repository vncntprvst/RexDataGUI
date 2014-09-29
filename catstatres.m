function [activlevel,activtype,maxmax,profile,dirselective,bestlt]=catstatres(getaligndata)
% categorize results according to stats
% VP 3/29/2013

activcats={'sac','vis','rew'};
alignt_q=find(~cellfun('isempty',(cellfun(@(x) x.trials, arrayfun(@(x) x, getaligndata),'UniformOutput', false))));
[activtype,profile,dirselective,maxmax,maxminmax,activlevel,bestlt]=deal(cell(length(alignt_q),1));

for lustat=1:length(alignt_q)
    % reminder of structure organization, top-down:
    % first level: one array for each category: sac, vis, rew
    % second level: one array for each condition, plus one (the last one) for all conditions collapsed
    % third level: in stats structure, three h values, representing
    % comparisons baseline vs pre-event; pre-vent vs post- event; baseline vs peri-event
    
    if arrayfun(@(x) nansum(x{:}.h), {getaligndata{alignt_q(lustat)}(~cellfun(@isempty, {getaligndata{alignt_q(lustat)}.stats})).stats})
        
        % find max activity and min max diff from qualified conditions (with >7
        % trials)
        maxfr=cell(1, size(getaligndata{alignt_q(lustat)},2)-1);
        minfr=cell(1, size(getaligndata{alignt_q(lustat)},2)-1);
        conddir=cell(1, size(getaligndata{alignt_q(lustat)},2)-1);
        for condnb=1:size(getaligndata{alignt_q(lustat)},2)-1
            sumall=nansum(getaligndata{alignt_q(lustat)}(condnb).rasters);
%             sdf=spike_density(sumall,15)./size(getaligndata{alignt_q(lustat)}(condnb).rasters,1);
              sdf=fullgauss_filtconv(sumall,15,0)./size(getaligndata{alignt_q(lustat)}(condnb).rasters,1).*1000;
            if ~isnan(getaligndata{alignt_q(lustat)}(condnb).peakramp.peaksdft)
                maxfr{condnb}=round(sdf(getaligndata{alignt_q(lustat)}(condnb).alignidx+getaligndata{alignt_q(lustat)}(condnb).peakramp.peaksdft));
                if ~isnan(getaligndata{alignt_q(lustat)}(condnb).peakramp.nadirsdft)
                    minfr{condnb}=round(sdf(getaligndata{alignt_q(lustat)}(condnb).alignidx+getaligndata{alignt_q(lustat)}(condnb).peakramp.nadirsdft));
                else
                    minfr{condnb}=maxfr{condnb};
                end
            end
            conddir{condnb}=getaligndata{alignt_q(lustat)}(condnb).dir;
        end
        maxmax{alignt_q(lustat)}=round(max([maxfr{:}]));            
        maxminmax{alignt_q(lustat)}=round(max([maxfr{:}]-[minfr{:}]));
        
        % if several directions: find if direction selectivity
        if sum(~cellfun('isempty', conddir))
            if max(maxfr{~cellfun('isempty', conddir)})/min(maxfr{~cellfun('isempty', conddir)})>1.2
                dirselective{alignt_q(lustat)}=conddir{[maxfr{:}]==max([maxfr{:}])};
            end
        else
            dirselective{alignt_q(lustat)}='no';
        end
        
%         peakcct=cell(1, size(getaligndata{alignt_q(lustat)},2)-1);
        auc=cell(1, size(getaligndata{alignt_q(lustat)},2)-1);
        slope=cell(1, size(getaligndata{alignt_q(lustat)},2)-1);
        for condnb=1:size(getaligndata{alignt_q(lustat)},2)-1
%             peakcct{condnb}=getaligndata{alignt_q(lustat)}(condnb).peakramp.peakcct;
            auc{condnb}=getaligndata{alignt_q(lustat)}(condnb).peakramp.auc;
            slope{condnb}=getaligndata{alignt_q(lustat)}(condnb).peakramp.slopes;
        end
        
        
        %% caracterize profile with area under curve and slope
        
        slopes=[slope{:}];
        if sum(slopes(1,:)<100)==length(slopes(1,:))
            profile{alignt_q(lustat)}=[profile{alignt_q(lustat)},'ramp'];
        else
            profile{alignt_q(lustat)}=[profile{alignt_q(lustat)},'mixed'];
        end
        
        % for bursty cells
        bsl_prevt=arrayfun(@(x) x{:}.h(1), {getaligndata{alignt_q(lustat)}(~cellfun(@isempty, {getaligndata{alignt_q(lustat)}.stats})).stats});
        bsl_perievt=arrayfun(@(x) x{:}.h(3), {getaligndata{alignt_q(lustat)}(~cellfun(@isempty, {getaligndata{alignt_q(lustat)}.stats})).stats});
        if sum((bsl_perievt-bsl_prevt)>0) %significant peri vs baseline but not pre baseline: signature of sharp burst
            getstats={getaligndata{alignt_q(lustat)}(~cellfun(@isempty, {getaligndata{alignt_q(lustat)}.stats})).stats};
            burststrength=round(max(cellfun(@(x) x.p(6), getstats((bsl_perievt-bsl_prevt)>0)))); %p(6) is diff between mean alignemnt and mean baseline. See eventraststats.
        else
            burststrength=0;
        end
        
        burstyarr=(bsl_perievt(1:size(getaligndata{alignt_q(lustat)},2)-1)-bsl_prevt(1:size(getaligndata{alignt_q(lustat)},2)-1))>0;
        peakarea=[auc{burstyarr}]./[maxfr{burstyarr}];
        
        if burststrength>100 && peakarea <100
            profile{alignt_q(lustat)}=[profile{alignt_q(lustat)},'_burst'];
        end
        
        if sum(slopes(2,:)<-100)==length(slopes(2,:))
            profile{alignt_q(lustat)}=[profile{alignt_q(lustat)},'_suppression'];
        end
        
        
        %% define activity level
        
        % find peak activity level (absolute FR) and min-max diff. Make index.

        % absolute strength
        if maxmax{alignt_q(lustat)} > 125
            activlevel{alignt_q(lustat)}=3;
        elseif maxmax{alignt_q(lustat)} > 100
            activlevel{alignt_q(lustat)}=2;
        elseif maxmax{alignt_q(lustat)} > 75
            activlevel{alignt_q(lustat)}=1;
        else
            activlevel{alignt_q(lustat)}=0;
        end
        
        % inhibition strength
        if maxmax{alignt_q(lustat)}/maxminmax{alignt_q(lustat)} < 1.5
            activlevel{alignt_q(lustat)}=activlevel{alignt_q(lustat)}+2;
        elseif maxmax{alignt_q(lustat)}/maxminmax{alignt_q(lustat)} < 2
            activlevel{alignt_q(lustat)}=activlevel{alignt_q(lustat)}+1;
        end
        
        % add 1 for significant p_rmanov
%         pmanov=arrayfun(@(x) (x{:}.p_rmanov)<0.05, {getaligndata{alignt_q(lustat)}(~cellfun(@isempty, {getaligndata{alignt_q(lustat)}.stats})).stats});
%         if sum(pmanov)>=size(getaligndata{alignt_q(lustat)},2)-1
%             activlevel{alignt_q(lustat)}=activlevel{alignt_q(lustat)}+1;
%         end
        
        % applying qualifier
        if activlevel{alignt_q(lustat)}>1
        activtype{alignt_q(lustat)}=activcats{alignt_q(lustat)};
        end
        
    end
end
end


