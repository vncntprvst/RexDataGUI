function [newecodes, newetimes,clus_names] = replaceecodes2(ecodes,etimes,figs)
if nargin <3
    figs=0;
end

global triggertimes spike2times clustercodes
whentrigs = round(triggertimes.*1e3);
whenspikes = round(spike2times(clustercodes ~= 0).*1e3);
whatcodes = double(clustercodes(clustercodes ~= 0));
clus_names = unique(whatcodes);

%% recast in terms of REX times

starttrigs =  etimes(ecodes == 1001);
    
keep_min_rex = min(starttrigs);
keep_min_spk2 = min(whentrigs);
starttrigs = starttrigs - keep_min_rex + 1;
whentrigs = whentrigs - keep_min_spk2 + 1;
whenspikes = whenspikes - keep_min_spk2 + 1;

rast_starttrigs = 1:max(starttrigs);
rast_whentrigs = 1:max(whentrigs);
rast_starttrigs = double(ismember(rast_starttrigs, starttrigs));
rast_whentrigs = double(ismember(rast_whentrigs, whentrigs));

if length(whentrigs)/sum(ecodes == 1001) == 2 %expected ratio of triggers to trials (2 triggers per trial

    where_max = 0;

else %either spurious codes in token task, or wrong recording sequence (e.g. Spike2 recording started after REX recording)

    disp('Warning! Inconsistent number of triggers. Will attempt to align via cross correlation.');
    [corr_vec,lag_range] = xcorr(rast_starttrigs,rast_whentrigs);
    where_max = lag_range(corr_vec == max(corr_vec));
    %where_max = 0;
    %pause;
    
end
    
    offset = keep_min_rex + where_max(1) - 1;
    
    alltrigs = whentrigs+offset;
    whenspikes = whenspikes +offset;
    
    starttrigs =  etimes(ecodes == 1001);
    newwhentrigs = zeros(size(starttrigs));
    
    for ctrig = 1:length(starttrigs)
        curr_trig = starttrigs(ctrig);
        errors = abs(alltrigs-curr_trig);
        ind = find(errors == min(errors),1);
        newwhentrigs(ctrig) = alltrigs(ind);
        alltrigs(ind) = [];
    end
    
    whentrigs = newwhentrigs;

for wtrig = 1:length(whentrigs)
    slight_offset = whentrigs(wtrig)-starttrigs(wtrig);
    if (wtrig == 1)
        lowmask = whenspikes < whentrigs(wtrig);
        thesespikes = whenspikes(lowmask);
        if ~isempty(thesespikes)
        whenspikes(lowmask) = thesespikes-slight_offset;
        end
    else
        lowmask = whenspikes < whentrigs(wtrig);
        highmask = whenspikes > whentrigs(wtrig-1);
        thesespikes = whenspikes(lowmask & highmask);
        if ~isempty(thesespikes)
        whenspikes(lowmask & highmask) = thesespikes-slight_offset;
        end
    end
end

for whtrig = 1:length(whentrigs)
    slight_offset = whentrigs(whtrig)-starttrigs(whtrig);
    whentrigs(whtrig) = whentrigs(whtrig)-slight_offset;
end

    
if figs
    fprintf('There are %d triggers\n',length(whentrigs));
    fprintf('There are %d start times\n',sum(ecodes == 1001));
    
%     figure(101);
% %     plot(lag_range,corr_vec,'ko');
%     title('Cross correlation of trigger times and trial start times');
    
    figure(99);clf;

    plot(whentrigs,whentrigs.^0,'rd','MarkerSize',20); % red diamonds: spike2 triggers
    hold on;
    plot(etimes(ecodes == 1001),(etimes(ecodes==1001)).^0,'ko','MarkerSize',20); % black circles rex start codes
    ticks = unique([etimes(ecodes == 1001); whentrigs]);
    set(gca,'XTick',ticks)
    set(gca,'XTickLabel',sprintf('%3.0f|',ticks))
    legend('Spk2 trigs','REX start codes');
    
    align_error = zeros(length(starttrigs),1);
    
    for sttrig = 1:length(starttrigs)
        curr_trig = starttrigs(sttrig);
        errors = abs(whentrigs-curr_trig);
        align_error(sttrig) = min(errors);
    end
    error_bar = mean(align_error);
    fprintf('The alignment is %5.2f miliseconds off on average',error_bar);

end



%% Remove old spikes

newecodes = ecodes;
newetimes = etimes;

newetimes(newecodes == 610) = [];
newecodes(newecodes == 610) = [];

%% Remove old references to analog
 atimes = newetimes(newecodes == -112);
 newetimes(newecodes == -112) = [];
 newecodes(newecodes == -112) = [];
 
%% Label new clusters
howmanyclus = length(clus_names);
for hmclus = 1:howmanyclus
    clus_label = 600+clus_names(hmclus);
    thesespikes = whenspikes(whatcodes == clus_names(hmclus)); % Isolate cluster
    addecodes = clus_label.*ones(length(thesespikes),1);
    newecodes = [ newecodes; addecodes];
    newetimes = [ newetimes; thesespikes]; % Add new spikes
end

%% sort

[newetimes,ind] = sort(newetimes);
newecodes = newecodes(ind);

%% add analog references
addacodes = -112.*ones(length(atimes),1);
newetimes = [newetimes; atimes];
newecodes = [newecodes; addacodes];
end
%end

