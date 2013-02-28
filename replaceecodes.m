function [newecodes, newetimes] = replaceecodes(ecodes,etimes,whenspikes,whentrigs,whatcodes,whichclus)
if nargin == 5
whichclus = 1;
end
global triggertimes spike2times clustercodes
whentrigs = triggertimes;
whenspikes = spike2times;
whatcodes = clustercodes;
%% recast in terms of REX times
firststartind = find(ecodes == 1001,1);
firststart = etimes(firststartind);
offset = firststart-whentrigs(1);
if 1
    fprintf('There are %d triggers\n',length(whentrigs));
    fprintf('There are %d start times\n',sum(ecodes == 1001));
    figure(99);clf;
    offwhen = whentrigs+offset;
    plot(offwhen,offwhen.^0,'rd','MarkerSize',20);
    hold on;
    plot(etimes(ecodes == 1001),etimes(ecodes==1001).^0,'ko','MarkerSize',20);
    ticks = unique([etimes(ecodes == 1001); offwhen]);
    set(gca,'XTick',ticks)
    set(gca,'XTickLabel',sprintf('%3.0f|',ticks))
    legend('Spk2 trigs','REX start codes');
end
% while ~(length(whentrigs)==sum(ecodes == 1001))
%     whentrigs(1) = [];
%     offset = firststart-whentrigs(1);
% end

%if (whentrigs+offset)==etimes(ecodes == 1001)
whenspikes = whenspikes+offset;

%% Isolate cluster
whenspikes = whenspikes(whatcodes == whichclus);

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
%end

