function [FRET, maxG, minG, maxR, minR] = GreenRedPlot(meanGData, meanRData, j, k, time, saveDir, RawOrFilt, boxWidth, varargin)
%% GreenRedPlot
% This function plots green data (meanGData) and red data (meanRData)
% generated from the PitAnalysis function. As such, they must be arrays
% with indices j and k. A time vector must be input as well. The save
% directory, saveDir, is also important. RawOrFilt either lets the user
% keep the data as raw ('Raw'), or filtered ('Filt'). In the latter case, a
% boxWidth value is required by the sgolayfilt filter, which is the one
% used in this program.

%% Initialize Variables       
figure;
hold on;  
graphTitle = strcat('Intensity vs. Time for Pit (', num2str(j), ', ', num2str(k), ')');
startF = 1;
stopF = size(meanGData, 3);

%% Varargins
numvarargin = size(varargin, 2);
if (~isempty(varargin))
    for vararg=1:numvarargin
        if strcmp(varargin{vararg}, 'startF')
            startF = varargin{vararg+1}; 
        elseif strcmp(varargin{vararg}, 'stopF')
            stopF = varargin{vararg+1}; 
        end
    end
end


%% Reduce Green Data
% Subtract intensity from green array to bring it to same scale as red
% array.
minG = min(meanGData(j,k,:), [], 3);
minR = min(meanRData(j,k,:), [], 3);
minDiff = minG-minR;
gData(j,k,:) = meanGData(j,k,:)-minDiff(j,k);
rData(j,k,:) = meanRData(j,k,:);

%% Filter & Plot Data
% Either filter the data using 'Filt', or leave it raw with 'Raw'.
if strcmp(RawOrFilt, 'Raw')
    minG = min(gData(j,k,:), [], 3);
    maxG = max(gData(j,k,:), [], 3);
    minR = min(rData(j,k,:), [], 3);
    maxR = max(rData(j,k,:), [], 3);
    plot(time(1,:),squeeze(gData(j,k,:)),'g');
    plot(time(1,:),squeeze(rData(j,k,:)),'r');
    plot(time(1,:), ones(size(time,2)).*minG, ':g');
    plot(time(1,:), ones(size(time,2)).*maxG, ':g');
    plot(time(1,:), ones(size(time,2)).*minR, ':r');
    plot(time(1,:), ones(size(time,2)).*maxR, ':r');
   % plot(time(1,:),squeeze(ones(size(time,2)))*gBkgd(j,k), ':g');
else
    minG = min(sgolayfilt(gData(j,k,:)), [], 3);
    maxG = max(sgolayfilt(gData(j,k,:)), [], 3);
    minR = min(sgolayfilt(rData(j,k,:)), [], 3);
    maxR = max(sgolayfilt(rData(j,k,:)), [], 3);
    plot(time(1,:),sgolayfilt(squeeze(gData(j,k,:)),0,boxWidth), 'g', 'LineWidth', 2);
    plot(time(1,:),sgolayfilt(squeeze(rData(j,k,:)),0,boxWidth), 'r', 'LineWidth', 2);
    plot(time(1,:), ones(size(time,2)).*minG, ':g');
    plot(time(1,:), ones(size(time,2)).*maxG, ':g');
    plot(time(1,:), ones(size(time,2)).*minR, ':r');
    plot(time(1,:), ones(size(time,2)).*maxR, ':r');
   % plot(time(1,:),squeeze(ones(size(time,2)))*gBkgd(j,k), ':g');
end
title(graphTitle);
xlabel = 'Time (frame)';
ylabel = 'Intensity (counts)';

% set(gca,'xtick',[])
% set(gca,'ytick',[])

%% Fine Adjustments
% This part allows the user to change the green intensity relative to the
% red.
happy = input('Are you okay with this (y/n)? ', 's');
while ~strcmp(happy, 'y') && ~strcmp(happy, 'Y')
    spacing = input('Enter how much you would like to reduce the green trace by: ');
    hold off;
    close; 
    figure;
    hold on;
    title(graphTitle);
    xlabel = 'Time (frame)';
    ylabel = 'Intensity (counts)';
    gData(j,k,:) = gData(j,k,:)-spacing;
   % gBkgd = gBkgd(j,k) - spacing;
    if strcmp(RawOrFilt, 'Raw')
        minG = min(gData(j,k,:), [], 3);
        maxG = max(gData(j,k,:), [], 3);
        minR = min(rData(j,k,:), [], 3);
        maxR = max(rData(j,k,:), [], 3);
        plot(time(1,:),squeeze(gData(j,k,:)),'g');
        plot(time(1,:),squeeze(rData(j,k,:)),'r');
        plot(time(1,:), ones(size(time,2)).*minG, ':g');
        plot(time(1,:), ones(size(time,2)).*maxG, ':g');
        plot(time(1,:), ones(size(time,2)).*minR, ':r');
        plot(time(1,:), ones(size(time,2)).*maxR, ':r');
   %     plot(time(1,:),squeeze(ones(size(time,2)))*gBkgd(j,k), ':g');
    else
        minG = min(sgolayfilt(gData(j,k,:)), [], 3);
        maxG = max(sgolayfilt(gData(j,k,:)), [], 3);
        minR = min(sgolayfilt(rData(j,k,:)), [], 3);
        maxR = max(sgolayfilt(rData(j,k,:)), [], 3);
        plot(time(1,:),sgolayfilt(squeeze(gData(j,k,:)),0,boxWidth), 'g', 'LineWidth', 2);
        plot(time(1,:),sgolayfilt(squeeze(rData(j,k,:)),0,boxWidth), 'r', 'LineWidth', 2);
        plot(time(1,:), ones(size(time,2)).*minG, ':g');
        plot(time(1,:), ones(size(time,2)).*maxG, ':g');
        plot(time(1,:), ones(size(time,2)).*minR, ':r');
        plot(time(1,:), ones(size(time,2)).*maxR, ':r');
    %    plot(time(1,:),squeeze(ones(size(time,2)))*gBkgd(j,k), ':g');
    end
    
%     set(gca,'xtick',[])
%     set(gca,'ytick',[])
    
    happy = input('Are you okay with this (y/n)? ', 's');
end

%% FRET Events
% The final part: we're looking to count FRET events. This also saves the
% plots so that the user can look at them afterwards.
FRET = input('How many FRET events do you see? ');
if FRET > 0 && ~strcmp(saveDir, 'n') && ~strcmp(saveDir, 'no')
    printName = strcat(saveDir, 'pit(',num2str(j), ', ',num2str(k), ')');
    print(printName, '-dpng');
    savefig(printName);
%    print(printName, '-fig');
end
close;