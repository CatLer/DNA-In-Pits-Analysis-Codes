function photobleachArray = PlotPitData(meanPitInt,varargin)
%% PlotPitData
% This function plots the data exported by the program PitAnalysis.
% meanPitInt is the array output of PitAnalysis. It also exports the number
% of molecules present in each pit. It does so by looping through
% all the pits in the array and has the user count how many molecules are
% in each pit. Varagins allow set BoxWidths, and a StartFrame.
rowPits = size(meanPitInt,1);
colPits = size(meanPitInt,2);
frames = size(meanPitInt, 3);
photobleachArray = zeros([rowPits colPits 1])-1; %initialize as -1 so can resume at first -1.  there may be 0 molecs in a pit sometimes

exclusionList = [];0

startF = 1;
boxWidth = 19;
saveFilename = '';
makePlot = 1;
meanPitInt2 = [];
for iVa = 1:length(varargin)
    if any(strcmpi(varargin{iVa},{'exclusionList','exclude','pitsToExclude','excludePits','excludeList','skipList','pitsToSkip'}))
        exclusionList = varargin{iVa+1};
    elseif strcmpi(varargin{iVa}, 'StartFrame')
        startF = varargin{iVa+1};
    elseif strcmpi(varargin{iVa}, 'BoxWidth')
        boxWidth = varargin{iVa+1};
    elseif strcmpi(varargin{iVa}, 'SaveFilename')
        saveFilename = varargin{iVa+1};
    elseif strcmpi(varargin{iVa}, 'MakePlot')
        makePlot = varargin{iVa+1};
    elseif strcmpi(varargin{iVa}, 'SecondChannel')
        meanPitInt2 = varargin{iVa+1};
    end
end

if exist('saveFilename', 'file')==2
    disp(['File ' saveFilename ' already exists. Resuming at first uncompleted entry.']);
    photobleachArray = load(saveFilename,'photobleachArray');
end

for j=1:rowPits
    for k = 1:colPits
        if ~isempty(exclusionList) && any(all(repmat([j,k],size(exclusionList,1),1)==exclusionList,2),1) %if any items (rows) in exclusionList match exactly
            photobleachArray(j,k,1) = NaN;
        elseif photobleachArray(j,k,1) ~= -1
            % Already done.  Skip
        else
            titleStr = sprintf('Intensity vs. Time for Pit %g, %g', j, k);
            time = (startF:frames);
            hf = figure;
            data = squeeze(meanPitInt(j,k,startF:end));
            smoothData = sgolayfilt(data,0,boxWidth); %box avg
            if isempty(meanPitInt2)
                subplot(1,2,1)
                xlabel('Time (frames)');
                ylabel('Intensity (counts)');
            else
                data2 = squeeze(meanPitInt2(j,k,startF:end));
                smoothData2 = sgolayfilt(data2,0,boxWidth); 
                subplot(2,2,3)
                plot(time, data2, '-b');
                hold on;
                plot(time, smoothData2, '-r');
                xlabel('Time (frames)');
                ylabel('Intensity (counts)');
                xlim([time(1) time(end)]);
                %set up next plot
                subplot(2,2,1)
            end
            plot(time, data, '-r');
            hold on;
            plot(time, smoothData,'-b');
            xlim([time(1) time(end)]);
            title(titleStr);
            %position of intensity trace in order to position histogram
            yLimits = get(gca,'YLim');
            yOffset = smoothData(end) - yLimits(1);
            yRange = yLimits(2)-yLimits(1);
            if isempty(meanPitInt2)
                subplot(1,2,2)
            else
                subplot(2,2,2)
            end
            [~, N, edges] = pairwiseDiff(smoothData); %makes histogram of pairwise diffs of intensity (I_t1-I_t2)
            centers=(edges(1:end-1)+edges(2:end))./2;
            barh(centers,N);
            ylim([-yOffset -yOffset+yRange])
            
            nMolValidFlag = 0;
            while(nMolValidFlag==0)
                nMolString = input('How many molecules are in this pit? ', 's');
                nMol = str2num(nMolString); %#ok<ST2NM>
                if isempty(nMol)
                    disp(['Entry ' nMolString ' not convertible to numeric. Please reenter.'])
                elseif isnumeric(nMol) || isnan(nMol)
                    nMolValidFlag = 1;
                    if nMol==-1
                        warning(['Entering -1 marks pit ' int2str(j) ',' int2str(k) ' as uncompleted.']);
                    end
                end
            end
            photobleachArray(j,k,1) = nMol;
            close(hf);
        end
        if ~isempty(saveFilename)
            save(saveFilename,'photobleachArray');
        end
    end
end

%% Make plot
if makePlot == 1
    linPBA = photobleachArray(:);
    x = 0:ceil(max(linPBA));
    hcounts = hist(linPBA,x);
    totCounts = sum(hcounts);
    pd = fitdist(linPBA(~isnan(linPBA)),'Poisson');
    figure; hold on;
    bar(x,hcounts);
    stem(x,totCounts.*pdf(pd,x),'r','LineWidth',2);
    title(['Fit param lambda = ' num2str(pd.lambda)]) 
    set(gca,'FontSize',16);
    ylabel('counts','FontSize',16);
    xlabel('pit occupancy','FontSize',16);
end