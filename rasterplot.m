function rasterplot(spiketimes)
% if size(in,1) > size(in,2)
%     in=in';
% end
testbin=size(spiketimes,2);
while ~sum(spiketimes(:,testbin))
testbin=testbin-1;
end
axis([0 testbin+1 -1 size(spiketimes,1)+1]);
hold on
for i=1:size(spiketimes,1)
in=find(spiketimes(i)); %converting from a matrix representation to a time collection
plot([in;in],[ones(size(in))*i;ones(size(in))*i-1],'k-')
end
hold off
set(gca,'TickDir','out') % draw the tick marks on the outside
set(gca,'YTick', []) % don't draw y-axis ticks
set(gca,'PlotBoxAspectRatio',[1 0.05 1]) % short and wide
set(gca,'Color',get(gcf,'Color')) % match figure background
set(gca,'YColor',get(gcf,'Color')) % hide the y axis
box off