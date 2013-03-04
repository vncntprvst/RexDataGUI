function [newecodes, newetimes] = replaceecodes(ecodes,etimes,whenspikes,whentrigs,whatcodes,whichclus)
if nargin == 5
whichclus = 1;
end
global triggertimes spike2times clustercodes
whentrigs = round(triggertimes.*1e3);
whenspikes = round(spike2times.*1e3);
whatcodes = clustercodes;
%% recast in terms of REX times
% find first good trial
a = 0;
foundit = 0;
    trialstart = find(ecodes == 1001);
	lastevent = length(ecodes);
	trialend = [trialstart(2:end);lastevent];
    starttrigs = zeros(length(trialstart),1);
    endtrigs = zeros(length(trialstart),1);
    for co = 1:length(trialstart)
        starttrigs(co) = etimes(trialstart(co))-1;
        nextcodes = ecodes(trialstart(co):trialend(co));
        nexttimes = etimes(trialstart(co):trialend(co));
        d = find(nextcodes == 1502,1);
        if ~isempty(d)
            endtrigs(co) = nexttimes(d);
        else
        d = find(nextcodes == 1030,1);
        if ~isempty(d)
            endtrigs(co) = nexttimes(d);
        else
            endtrigs(co) = NaN;
        end
        end
    end
while ~foundit
    a = a+1;
    nextcodes = ecodes(trialstart(a):trialend(a));
    if ~sum(nextcodes == 17385)
        foundit = 1;
    end
end
int1 = endtrigs-starttrigs;
int3 = int1(a);
triglengths = round(diff(triggertimes).*1e3);
b = find(triglengths>(int3-1)& triglengths<(int3+1));
align = starttrigs(1:a);
align = (align-align(end))./1000;
align = triggertimes(b)+align(1);
align = round(align.*1000);
c = find(whentrigs==align,1);
firsttrig = whentrigs(c);
firststart = etimes(trialstart(a));
offset =firststart-firsttrig;
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

