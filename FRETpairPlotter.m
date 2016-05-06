% make figure showing FRETting pairs

row = 1;
col = 5;
xlims = [900 3000];

boxWidth = 11;

greenTrace = squeeze(green56MPI(row,col,xlims(1):xlims(2)));
redTrace = squeeze(green56redMPI(row,col,xlims(1):xlims(2)));

framesPerSec = 20;
times = ((xlims(1):xlims(2))-xlims(1))/framesPerSec; %in seconds, starting at zero

spacing = 0.01;

figure; 
subplot(2,1,1); plot(times,greenTrace,'g-')
hold on; plot(times,sgolayfilt(greenTrace,0,boxWidth),'k-')
box off;
set(gca,'XTickLabel',{})
set(gca,'LineWidth',2,'FontSize',16)
ylabel('Intensity (AU)','FontSize',16)
xlim([times(1) times(end)])
pos1 = get(gca,'Position');

subplot(2,1,2); plot(times,redTrace,'r-')
hold on; subplot(2,1,2); plot(times,sgolayfilt(redTrace,0,boxWidth),'k-')
box off;
set(gca,'LineWidth',2,'FontSize',16)
ylabel('Intensity (AU)','FontSize',16)
xlabel('seconds','FontSize',16)
xlim([times(1) times(end)])
pos2 = get(gca,'Position');
set(gca,'Position',[pos2(1) pos1(2)-(pos2(4)+spacing) pos2(3) pos2(4)]);