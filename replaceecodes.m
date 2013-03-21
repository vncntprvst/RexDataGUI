function [newecodes, newetimes] = replaceecodes(ecodes,etimes,whenspikes,whentrigs,whatcodes,clust)
if nargin == 5
clust = 1;
end
global triggertimes spike2times clustercodes
whentrigs = triggertimes.*1e3;
whenspikes = floor(spike2times.*1e3);
whatcodes = clustercodes;
%% recast in terms of REX times
starttrigs =  etimes(ecodes == 1001);

if length(whentrigs)/sum(ecodes == 1001)==2 %expected ratio of triggers to trials (2 triggers per trial

    whentrigs=whentrigs(1:2:end); %keep only start trigger times and remove end triggers. Makes for better correlation

else %either spurious codes in token task, or wrong recording sequence (e.g. Spike2 recording started after REX recording)

    disp('Warning! Inconsistent number of triggers. Will attempt to align via cross correlation.');
    pause;
    
end

keep_min_rex = min(starttrigs); 
keep_min_spk2 = min(whentrigs);
starttrigs = starttrigs - keep_min_rex; % align to first trigger in either dataset, to avoid wasting raster space
whentrigs = whentrigs - keep_min_spk2;

rexbins = 0:max(starttrigs);
spk2bins = 0:floor(max(whentrigs)); % convert from vector of trigger times to rasters
rast_starttrigs = hist(starttrigs,rexbins);
rast_whentrigs = hist(whentrigs,spk2bins);

if max(rast_starttrigs) > 1 || max(rast_whentrigs) > 1
    
    disp('Error: Two triggers less than a milisecond apart!');
    pause;
    
end

[corr_vec,lag_range] = xcorr(rast_starttrigs,rast_whentrigs); % cross correlate rasters to find time displacement between the two that has maximum overlap between triggers
which_lag = lag_range(corr_vec == max(corr_vec));
offset = floor(keep_min_rex - keep_min_spk2 + which_lag(1));


if 1
    fprintf('There are %d triggers\n',length(whentrigs));
    fprintf('There are %d start times\n',sum(ecodes == 1001));
    figure(99);clf;
    
    whentrigs = triggertimes.*1e3+offset;
    
    plot(whentrigs,whentrigs.^0,'rd','MarkerSize',20); % red diamonds: spike2 triggers
    hold on;
    plot(etimes(ecodes == 1001),(etimes(ecodes==1001)).^0,'ko','MarkerSize',20); % black circles rex start codes
    ticks = unique([etimes(ecodes == 1001); whentrigs]);
    set(gca,'XTick',ticks)
    set(gca,'XTickLabel',sprintf('%3.0f|',ticks))
    legend('Spk2 trigs','REX start codes');
end

if 0
    
    figure(101);
    plot(lag_range,corr_vec,'ko');
    title('Cross correlation of trigger times and trial start times');

end

whenspikes = whenspikes+offset;

%% Isolate cluster
whenspikes = whenspikes(whatcodes == clust);

%% Remove old spikes and references to analog
newecodes = ecodes;
newetimes = etimes;

newetimes(newecodes == 610) = [];
newecodes(newecodes == 610) = [];
 
 atimes = newetimes(newecodes == -112);
 newetimes(newecodes == -112) = [];
 newecodes(newecodes == -112) = [];

%% Add new spikes and sort
addecodes = 610.*ones(length(whenspikes),1);
newecodes = [ newecodes; addecodes];
newetimes = [ newetimes; whenspikes];

[newetimes,ind] = sort(newetimes);
newecodes = newecodes(ind);

addacodes = -112.*ones(length(atimes),1);
newetimes = [newetimes; atimes];
newecodes = [newecodes; addacodes];
end

