function [newecodes, newetimes] = replaceecodes(ecodes,etimes,figs)
if nargin <3
    figs=0;
end

global triggertimes spike2times clustercodes
whentrigs = round(triggertimes.*1e3);
whenspikes = round(spike2times.*1e3);
whatcodes = clustercodes;
howmanyclus = double(max(whatcodes));

%% recast in terms of REX times
starttrigs =  etimes(ecodes == 1001);

if length(whentrigs)/sum(ecodes == 1001) == 2 %expected ratio of triggers to trials (2 triggers per trial

    whentrigs=whentrigs(1:2:end); %keep only start trigger times and remove end triggers. Makes for better correlation

else %either spurious codes in token task, or wrong recording sequence (e.g. Spike2 recording started after REX recording)

    disp('Warning! Inconsistent number of triggers. Will attempt to align via cross correlation.');
    pause;
    
end
    
keep_min_rex = min(starttrigs);
keep_min_spk2 = min(whentrigs);
starttrigs = starttrigs - keep_min_rex + 1;
whentrigs = whentrigs - keep_min_spk2 + 1;

rast_starttrigs = 1:max(starttrigs);
rast_whentrigs = 1:max(whentrigs);
rast_starttrigs = double(ismember(rast_starttrigs, starttrigs));
rast_whentrigs = double(ismember(rast_whentrigs, whentrigs));

[corr_vec,lag_range] = xcorr(rast_starttrigs,rast_whentrigs);
where_max = lag_range(corr_vec == max(corr_vec));
offset = keep_min_rex - keep_min_spk2 + where_max(1);

if figs
    fprintf('There are %d triggers\n',length(whentrigs));
    fprintf('There are %d start times\n',sum(ecodes == 1001));
    
    figure(101);
    plot(lag_range,corr_vec,'ko');
    title('Cross correlation of trigger times and trial start times');
    
    figure(99);clf;

    whentrigs = whentrigs + where_max(1) + keep_min_rex - 1;
    
    plot(whentrigs,whentrigs.^0,'rd','MarkerSize',20); % red diamonds: spike2 triggers
    hold on;
    plot(etimes(ecodes == 1001),(etimes(ecodes==1001)).^0,'ko','MarkerSize',20); % black circles rex start codes
    ticks = unique([etimes(ecodes == 1001); whentrigs]);
    set(gca,'XTick',ticks)
    set(gca,'XTickLabel',sprintf('%3.0f|',ticks))
    legend('Spk2 trigs','REX start codes');

    starttrigs = etimes(ecodes == 1001);
    align_error = zeros(length(starttrigs),1);
    for a = 1:length(starttrigs)
        curr_trig = starttrigs(a);
        errors = abs(whentrigs-curr_trig);
        align_error(a) = min(errors);
    end
    error_bar = mean(align_error);
    fprintf('The alignment is %5.2f miliseconds off on average',error_bar);

end

whenspikes = whenspikes + offset;

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
for a = 1:howmanyclus
    clus_label = 600+a;
    thesespikes = whenspikes(whatcodes == a); % Isolate cluster
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

