%% PitFRETAnalysis
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
addpath(genpath('C:\Users\Leslie Lab\Documents\GitHub\LabAnalysisCodes'));
boxWidth = 39;
dataDir = '';
dataName = '5p3nMCy5mpUC19_Glaser_27p99ObjT_27p95LensT_Postbleach_1_MMStack.ome';
saveDir = strcat(dataDir,'\');
%Color = {[0.3 0.3 0.3]; [0 0 0]};

%% Import Movies

movie = ImportVideo(dataDir, dataName);

%% Define Pit Arrays
gArray = PitAnalysis(movie);
close;
%%
rArray = PitAnalysis(movie);
close;
rowPits = size(gArray,1);
colPits = size(gArray,2);
FRETArray = zeros(rowPits, colPits);

%% Background Determination
% Need to subtract the background from each channel. Will estimate
% background using a double exponential.
startF = 1;
stopF = size(gArray, 3);
%%
greenBg = BackgroundArray(movie, saveDir, 'startF', startF, 'stopF', stopF);
%%
redBg = BackgroundArray(movie, saveDir, 'startF', startF, 'stopF', stopF);
%%
% DetrendingFRET works only on individual pits, not adequate for this code
% format 
for i = startF:stopF
    cutGData(:,:,i) = gArray(:,:,i) - greenBg(1,1,i);
    cutRData(:,:,i) = rArray(:,:,i) - redBg(1,1,i);
end
%%
cutGData1 = zeros(size(cutGData));
cutRData1 = zeros(size(cutRData));
for i=1:size(cutGData,2)
    for j=1:size(cutGData,1)
        cutGData1(j,i,:) = medfilt1(cutGData(j,i,:),100);
        cutRData1(j,i,:) = medfilt1(cutRData(j,i,:),100);
    end
end

%% Make Plot
time = (startF:stopF);
for j=1:rowPits
    for k = 1:colPits
        FRETArray(j,k) = GreenRedPlot(cutGData1, cutRData1, j, k, time, saveDir, 'Filt', boxWidth, 'startF', startF, 'stopF', stopF); %Filt
    end
end
%%
saveName = strcat(saveDir, 'FRETArray');
save(saveName, 'FRETArray', 'gArray', 'rArray', 'dataName');