function [activtype,maxmean,profile,dirselective,activlevel]=catstatres(getaligndata)
% categorize results according to stats
% VP 3/29/2013
            
activcats={'sac','vis','rew'};
[activtype,profile,dirselective]=deal('');
[maxmean,activlevel]=deal(0);

alignt_q=find(~cellfun('isempty',(cellfun(@(x) x.trials, arrayfun(@(x) x, getaligndata),'UniformOutput', false))));
for lustat=1:length(alignt_q)
    sumstatsacs{lustat}=sum(arrayfun(@(x) nansum(x{:}.h), {getaligndata{alignt_q(lustat)}(~cellfun(@isempty, {getaligndata{alignt_q(lustat)}.stats})).stats}));
end

if sum([sumstatsacs{:}])

            if logical(sumstatsacs)
                if logical(nansum(arrayfun(@(x) x{:}.h(1), {getaligndata(~cellfun(@isempty, {getaligndata.stats})).stats})))
                    activreport = [activreport, 'presac_baseline '];
                end
                if logical(nansum(arrayfun(@(x) x{:}.h(2), {getaligndata(~cellfun(@isempty, {getaligndata.stats})).stats})))
                    activreport = [activreport, 'presac_postsac '];
                end
                if logical(nansum(arrayfun(@(x) x{:}.h(3), {getaligndata(~cellfun(@isempty, {getaligndata.stats})).stats})))
                    activreport = [activreport, 'perisac_baseline'];
                end
                if logical(nansum(p_rmanov<0.05))
                    statinfo={'2',activreport};
                else
                    statinfo={'1',activreport};
                end
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
                
            else
                if logical(sum(p_rmanov<0.05))
                    activreport = 'rmanov positive';
                    statinfo={'0.5',activreport};
                else
                    activreport = 'no sac activity';
                    statinfo={'0',activreport};
                end
                
            end
end

end

