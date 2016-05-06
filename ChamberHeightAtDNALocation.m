%%
% This code was made specifically to make a figure for the nanochannel 
% paper. This code is for finding height of chamber at precise locations of
% the DNA in nanopits.
% Here, we assume that for the different scans, the height map is the same.
% We dont have time to run chamber fitting for all the scans.

% The coordinates are relative to the DNA scan. The DNA scan is smaller
% than dye/fringe scan, but centered about the same position.

DNAScanSize = 2065;

locationDNAScan1 = [592 1074; 879 747; 1475 983; 808 1819; 1694 1101];
locationDNAScan2 = [1152 1560; 1573 756; 1624 695];
locationDNAScan3 = [1684 1283; 1519 690];

locationDNA = [locationDNAScan1;locationDNAScan2;locationDNAScan3];

%% For Dan's Honours Project pit analysis

pitData = load('E:\Daniel Berard\August_23_2013\Analysis\dnaXYN');
locationDNA = pitData.dnaXYN(:,[1,2]);
occupancy = pitData.dnaXYN(:,3);
clear pitData

%% Loop Data Sets
% This is to get the analysis chamber. We just need the height at every
% point.
clear Data
saveDir='E:\Daniel Berard\August_23_2013\Analysis\Dataset';
dirInfo = dir(saveDir);
folderNames={dirInfo.name};
folderNames(1) = []; folderNames(1) = [];


for currSet = 1:length(folderNames)
    name = folderNames{currSet};
    Data{currSet} = DataSet([],[],[],[],name);
    specifyVars = [{'name'}; {'gapHeight'};{'dnaFitStructure'};{'roiPoints'};{'roiImageStruct'};{'xoDyeFit'};{'yoDyeFit'};{'dyeScan'};{'fringeScan'}];
    Data{currSet}.loadVariables(specifyVars,saveDir); %,optionalSaveTag);
end

% The 50nm set lacks the set 9_3, I think, so we have to scale the sets 9_i
% down for i>3.

%% Convert locationDNA so that the coordinates are relative to the dye scan image

locationDNA_relDye = locationDNA+(length(Data{1}.gapHeight)-DNAScanSize)/2;

% Note: locationDNA_relDye is written in format (verti_pixel,horiz_pixel)
%% Display the positions of the DNA on the dyeScan.

% % figure
% % imshow(Data{1, 1}.dyeScan.composedScan,[0 1200]);
% figure
% hold on
% imshow(Data{1, 1}.fringeScan.composedScan,[]);
% % % figure
% hold on
% axis([0 length(Data{1}.gapHeight) 0 length(Data{1}.gapHeight)]);
% plot(length(Data{1}.gapHeight)/2,length(Data{1}.gapHeight)/2,'y.'); % Plot the center
% plot(Data{1}.xoDyeFit,Data{1}.yoDyeFit,'b.'); % Plot the center
% 
% axis([0 length(Data{1}.gapHeight) 0 length(Data{1}.gapHeight)]);
% for row=1:length(locationDNA_relDye)
%     plot(locationDNA_relDye(row,1),locationDNA_relDye(row,2),'r.'); % Plot the DNA points
% %     pause;
% end
% hold off

figure
% Now with the height fit
hold on
imshow(Data{1}.gapHeight,[]);
% % figure
hold on
axis([0 length(Data{1}.gapHeight) 0 length(Data{1}.gapHeight)]);
plot(length(Data{1}.gapHeight)/2,length(Data{1}.gapHeight)/2,'y.'); % Plot the center
% plot(Data{1}.xoDyeFit,Data{1}.yoDyeFit,'b.'); % Plot the center
[C,h]=contour(Data{1}.gapHeight,20,'c');
set(h,'ShowText','on');
axis([0 length(Data{1}.gapHeight) 0 length(Data{1}.gapHeight)]);
for row=1:length(locationDNA_relDye)
    plot(locationDNA_relDye(row,2),locationDNA_relDye(row,1),'r.'); % Plot the DNA points
    %pause;
end

hold off

%% Find height at these positions

for row=1:length(locationDNA_relDye)
    Heights(row,1) = Data{1}.gapHeight(locationDNA_relDye(row,2),locationDNA_relDye(row,1));
end

scaledHeights = Heights*1.35;
figure;
plot(scaledHeights,occupancy,'.b');

%% Sort data and average the heights for each possible occupancy

pitData=sortrows([scaledHeights,occupancy],2);
occupancyHist=hist(occupancy,max(occupancy)-1);

currRow=1;
for i=1:length(occupancyHist)
    meanHeights(i)=mean(pitData([currRow:(currRow+occupancyHist(i)-1)],1));
    meanHeightsError(i)=std(pitData([currRow:(currRow+occupancyHist(i)-1)],1))./sqrt(length(pitData([currRow:(currRow+occupancyHist(i)-1)])));
    currRow=currRow+occupancyHist(i);
end
clear currRow
figure;
herrorbar(meanHeights,[2:max(occupancy)],meanHeightsError,'.b');
hold on
%plot(scaledHeights,occupancy,'.r');
hold off

%% Find radius from the center

pixelSize = 266; %nanometres

% radFromCenter = sqrt((locationDNA_relDye(:,1)-length(Data{1}.gapHeight)/2).^2+(locationDNA_relDye(:,2)-length(Data{1}.gapHeight)/2).^2)
radFromCenter_pixels = sqrt((locationDNA_relDye(:,1)-Data{1}.xoDyeFit).^2+(locationDNA_relDye(:,2)-Data{1}.yoDyeFit).^2);
radFromCenter_microns = radFromCenter_pixels*266/1000;
plot(radFromCenter_microns,Heights,'.')

