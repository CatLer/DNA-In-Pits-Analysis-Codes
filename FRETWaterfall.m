%% FRETWaterfall
% This function plots green and red data exported by the program 
% PitAnalysis. meanGPitInt is the green array output of PitAnalysis, while 
% meanRPitInt is the red array output. The function loops through all the 
% pits in both arrays and plots them against each other in a plot.
% RawOrFilt allows the choice of plotting the raw or filtered data,
% specified using a string.
% The variable saveName allows each figure to be saved using the string
% saveName. If you don't want to save, replace this with the string 'n' or
% 'no'
% Varargin lets the user specify at which frame the user wants to start, or
% stop, at using StartFrame and StopFrame, respectively.
addpath(genpath('C:\Users\Leslie Lab\Documents\GitHub\LabAnalysisCodes\DNA in pits'));
boxWidth = 39;
saveDir = 'C:\Users\Leslie Lab\Desktop\Active\Shane\20nMCy5mpUC19_5p3nMShortoligo_Glaser_31p02ObjT_31p06LensT_1\';
%Color = {[0.3 0.3 0.3]; [0 0 0]};

%% Import Movies
movie = ImportVideo('C:\Users\Leslie Lab\Desktop\Active\Shane\20nMCy5mpUC19_5p3nMShortoligo_Glaser_31p02ObjT_31p06LensT_1', '20nMCy5mpUC19_5p3nMShortoligo_Glaser_31p02ObjT_31p06LensT_1_MMStack.ome');

%% Define Pit Arrays
gArray = PitAnalysis(movie);
rArray = PitAnalysis(movie);
rowPits = size(gArray,1);
colPits = size(gArray,2);
FRETArray = zeros(rowPits, colPits);
startF = 1;
stopF = size(gArray, 3);

%% Background Arrays
% Calculate the minimum background present in each channel.
%gBkgd(:,:) = min(gBkgdArray(:,:,:), [], 3);

%% Make Plot
meanGData = gArray(:,:,startF:stopF);
meanRData = rArray(:,:,startF:stopF);
time = (startF:stopF);

for j=21:rowPits
    for k = 1:colPits
        FRETArray(j,k) = GreenRedPlot(meanGData, meanRData, j, k, time, saveDir, 'Filt', boxWidth);
    end
end
saveName = strcat(saveDir, 'FRETArray');
save(saveName, 'FRETArray', 'gArray', 'rArray', 'movie');