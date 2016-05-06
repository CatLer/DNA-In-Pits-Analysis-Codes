function WaterfallPlotPitData(meanPitInt, spacing, RawOrFilt, Colour, varargin)
%% WaterfallPlotPitData
% This function plots the data exported by the program PitAnalysis.
% meanPitInt is the array output of PitAnalysis. The value of given gives
% the amount by which the sgolay filter will attempt to average the
% data through. The function loops through all the pits in the array and 
% plots them in a waterfall plot. 
% The spacing option allows the user to change the spacing between the 
% traces of each pit.
% RawOrFilt allows the choice of plotting the raw or filtered data,
% specified using a string.
% Colour allows the user to choose what colour to plot the data as, making
% use of Matlab's coded colour strings (ex. 'g' for green, 'r' for red,
% etc.).
% Varargin lets the user specify at which frame the user wants to start, or
% stop, at using StartFrame and StopFrame, respectively.
rowPits = size(meanPitInt,1);
colPits = size(meanPitInt,2);
startF = 1;
stopF = size(meanPitInt, 3);
figure;
numPits = 1;
boxWidth = 39;
graphTitle = 0;
xAxisL = 0;
yAxisL = 0;
%Color = {[0.3 0.3 0.3]; [0 0 0]};

%% Varargins
numvarargin = size(varargin, 2);
if (~isempty(varargin))
    for k=1:numvarargin
        if strcmp(varargin{k}, 'StartFrame')
            startF = varargin{k+1}; 
        elseif strcmp(varargin{k}, 'StopFrame')
            stopF = varargin{k+1}; 
        elseif strcmp(varargin{k}, 'Title')
            graphTitle = 1;
        elseif strcmp(varargin{k}, 'xAxisLabel')
            xAxisL = 1;
        elseif strcmp(varargin{k}, 'yAxisLabel')
            yAxisL = 1;
        end
    end
end

%% Make Waterfall Plot

for j=1:rowPits
    for k = 1:colPits
        hold on;  
        meanData = meanPitInt(j,k,startF:stopF);
        for i=1:(stopF-startF)
            meanData = meanData + (numPits-1)*spacing;
        end
        time = (startF:stopF);
        if strcmp(RawOrFilt, 'Raw')
            plot(time(1,:),squeeze(meanData(1,1,:)),Colour);
        else
            plot(time(1,:),sgolayfilt(squeeze(meanData(1,1,:)),0,boxWidth), Colour, 'LineWidth', 2);
        end
        filtered = sgolayfilt(squeeze(meanData(1,1,:)),0,boxWidth);
        filterSize = size(filtered, 1);
        photobleach = input('When is the sample done photobleaching? ', 's');
        photobleach=str2num(photobleach);
        numSteps = input('How many steps are there? ', 's');
        numSteps = str2num(numSteps);
        medLine = zeros(filterSize, 1);
        if numSteps > 0
            firstStep = input('When is first step? ', 's');
            firstStep = str2num(firstStep);
            lastStep = input('When is last step? ', 's');
            lastStep = str2num(lastStep);
            lineY = median(filtered((filterSize - lastStep):filterSize,1));
            for y = 1:stopF-startF+1
                medLine(y) = lineY;
            end
            plot(time(1,:), medLine(:,1), '--', 'Color', [0.3 0.3 0.3]);
            stepLineY = median(filtered(photobleach:firstStep,1));
            for steps = 1:numSteps
                for y = 1:stopF-startF+1
                    medLine(y)=lineY+steps*(stepLineY-lineY)/numSteps;
                end
                plot(time(1,:), medLine(:,1), '--', 'Color', [0.3 0.3 0.3]);
            end
        elseif numSteps==0
            lineY = median(filtered((filterSize - photobleach):filterSize,1));
            for y = 1:stopF-startF+1
                medLine(y) = lineY;
            end
            plot(time(1,:), medLine(:,1), '--k');            
        end
%         [diffMat, N, edges] = pairwiseDiff(sgolayfilt(squeeze(meanPitInt(1,1,:)),0,39),200,'plotHist','yes');
        numPits = numPits + 1;
    end
end

if xAxisL == 1
    xlabel('Time (frames)');
end
if yAxisL == 1
    ylabel('Intensity (counts)');
end
if graphTitle == 1
    title('Intensity vs. Time');
end