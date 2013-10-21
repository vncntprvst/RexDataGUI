function PlotRawSigRasters(rawsigs,alignrawidx)
numtrial=size(rawsigs,1);
chrono=1;
plotstart=50000;
plotstop=25000;
numsubplot=numtrial;
rawsigrastplot=figure('color','white');
hold on 
for rtrial=1:numtrial
    rrasters=rawsigs(rtrial,:);
    alignidx=alignrawidx(rtrial);

    start=alignidx - plotstart;
    stop=alignidx + plotstop;
    
    if start < 1
        start = 1;
    end
    if stop > length(rrasters)
        stop = length(rrasters);
    end
    
%   too many trial to subplots, so superimpose them
%     hrastplot(rtrial)=subplot(numsubplot,1,rtrial,'Layer','top', ...
%                 'XTick',[],'YTick',[],'XColor','white','YColor','white');
    rrasters=rrasters(start:stop); 
    plot(rrasters);
    set(gca,'xlim',[1 length(start:stop)]);
    axis(gca, 'off'); % axis tight sets the axis limits to the range of the data.
    
end