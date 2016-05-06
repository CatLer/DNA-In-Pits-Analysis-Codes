function [meanPitInt, pitGridStruct, exclusionList] = PitAnalysis(movieArray, varargin)
% This function takes a 3D movie array of a pit experiment and analyzes
% the intensity over time present in each pit. It does so by applying a
% mask to the movie, hiding the non-pit part of the coverslip, and 
% analyzing the intensity individually. It comes equipped with a GUI that
% allows the user to upload an image and choose where the pits can be found
% (either fringe image, or actual data).

%% Initialize Variables
% Declare variables herey
happy = 'n';
pitHappy = 'n';
frames = size(movieArray, 3);
%height = size(movieArray, 1);
%width = size(movieArray, 2);
%mask = zeros(height, width);
rect = zeros(3,4);
leftL1 = ''; rightL1 = ''; downL1 = ''; upL1 = '';
leftL2 = ''; rightL2 = ''; downL2 = ''; upL2 = '';
leftL3 = ''; rightL3 = ''; downL3 = ''; upL3 = '';

%% Varargin
numvarargin = size(varargin, 2);
if (~isempty(varargin))
    for k=1:numvarargin
        if strcmp(varargin{k}, 'MinInt')
            minInt = varargin{k+1}; 
        elseif strcmp(varargin{k}, 'MaxInt')
            maxInt = varargin{k+1}; 
        end
    end
end

%% Import Separate Pit File
% Sometimes, it is difficult to determine where the pits are in a movie, so
% this allows the user to open another movie file with well defined pits.
otherPitFile = input('Do you want to import a different movie or image file to determine where pits are? (y/n): ', 's');
if strcmp(otherPitFile, 'y') || strcmp(otherPitFile,'Y')
    [pitName, pitPath] = uigetfile('.tif');
    pitDirectory = [pitPath '\' pitName];
    pitImage = imread(pitDirectory);
end

%% Define Pits
% Show the first image in the movie and ask the user to click a few pits.

while ~strcmp(pitHappy,'y') || strcmp(pitHappy, 'Y')
    figure;
    if exist('minInt', 'var')
        if strcmp(otherPitFile, 'y') || strcmp(otherPitFile, 'Y')
            imshow(pitImage(:,:,1), [minInt maxInt]);
        else
            imshow(mat2gray(sum(mat2gray(movieArray),3)), [minInt maxInt]);
        end
    else
        if strcmp(otherPitFile, 'y') || strcmp(otherPitFile, 'Y')
            imshow(pitImage(:,:,1), []);
        else
            imshow(mat2gray(sum(mat2gray(movieArray),3)), []);
        end
    end

    disp('Draw a box around a pit in the upper left corner.');
    while ~strcmp(happy, 'y') && ~strcmp(happy, 'Y')
        hold on;
        delete(leftL1);delete(rightL1);delete(downL1);delete(upL1);
        rect(1,:) = getrect;
        downL1 = line([rect(1,1) rect(1,1)+rect(1,3)],[rect(1,2) rect(1,2)], 'Color','r');
        upL1 = line([rect(1,1) rect(1,1)+rect(1,3)],[rect(1,2)+rect(1,4) rect(1,2)+rect(1,4)], 'Color', 'r');
        leftL1 = line([rect(1,1) rect(1,1)],[rect(1,2) rect(1,2)+rect(1,4)], 'Color', 'r');
        rightL1 = line([rect(1,1)+rect(1,3) rect(1,1)+rect(1,3)],[rect(1,2) rect(1,2)+rect(1,4)], 'Color', 'r');
        happy = input('Are you happy with this box? (y/n): ', 's');
    end

    happy = 'n';
    disp('Draw a box around a pit in the same row as, but as far as possible from, the pit in the upper left corner. ');
    while ~strcmp(happy, 'y') && ~strcmp(happy, 'Y')
        hold on;
        delete(leftL2);delete(rightL2);delete(downL2);delete(upL2);
        rect(2,:) = getrect;
        downL2 = line([rect(2,1) rect(2,1)+rect(2,3)],[rect(2,2) rect(2,2)], 'Color','r');
        upL2 = line([rect(2,1) rect(2,1)+rect(2,3)],[rect(2,2)+rect(2,4) rect(2,2)+rect(2,4)], 'Color', 'r');
        leftL2 = line([rect(2,1) rect(2,1)],[rect(2,2) rect(2,2)+rect(2,4)], 'Color', 'r');
        rightL2 = line([rect(2,1)+rect(2,3) rect(2,1)+rect(2,3)],[rect(2,2) rect(2,2)+rect(2,4)], 'Color', 'r');
        happy = input('Are you happy with this box? (y/n): ', 's');
    end
    colDist = str2double(input('How many pits are to the left of this pit, not including the one you just drew? ', 's'));

    happy = 'n';
    disp('Draw a box around a pit in the same column a, but as far as possible from, the pit in the upper left corner.');
    while ~strcmp(happy, 'y') && ~strcmp(happy, 'Y')
        hold on;
        delete(leftL3);delete(rightL3);delete(downL3);delete(upL3);
        rect(3,:) = getrect;
        downL3 = line([rect(3,1) rect(3,1)+rect(3,3)],[rect(3,2) rect(3,2)], 'Color','r');
        upL3 = line([rect(3,1) rect(3,1)+rect(3,3)],[rect(3,2)+rect(3,4) rect(3,2)+rect(3,4)], 'Color', 'r');
        leftL3 = line([rect(3,1) rect(3,1)],[rect(3,2) rect(3,2)+rect(3,4)], 'Color', 'r');
        rightL3 = line([rect(3,1)+rect(3,3) rect(3,1)+rect(3,3)],[rect(3,2) rect(3,2)+rect(3,4)], 'Color', 'r');
        happy = input('Are you happy with this box? (y/n): ', 's');
    end
    
    happy = 'n';
    rowDist = str2double(input('How many pits are above this pit, not including the one you just drew? ', 's'));
    meanPitInt = zeros([rowDist, colDist, frames]);
    close;
%% Pit Grid
% Using the user input generated above, create a grid and verify that it
% fits the pits on the image.

    pitAvg = mean(rect,1);
    pitColX = -(rect(1,1)-rect(2,1))/colDist;
    pitColY = -(rect(1,2)-rect(2,2))/colDist;
    pitRowX = -(rect(1,1)-rect(3,1))/rowDist;
    pitRowY = -(rect(1,2)-rect(3,2))/rowDist;
    pitAvgX = pitAvg(3);
    pitAvgY = pitAvg(4);
    pitGridStruct.UL = rect(1,1:2); %upper-left corner of upper-left pit (x, y = col, row)
    pitGridStruct.WH = pitAvg(3:4); %width and height (col, row = x, y) of pits
    pitGridStruct.spacing = [pitColX, pitColY, pitRowX, pitRowY];
    pitGridStruct.numColRow = [colDist+1 rowDist+1];
    
    hfig = figure; imshow(mat2gray(sum(mat2gray(movieArray),3)), []); hold on;
    pitUL = zeros(rowDist+1,colDist+1,2); %first two dims are row, col. third dim is coords (x,y) of UL corner of rect
    for i=1:(rowDist+1)
        for j=1:(colDist+1)
            pitUL(i,j,1) = rect(1,1)+(j-1)*pitColX+(i-1)*pitRowX;
            pitUL(i,j,2) = rect(1,2)+(j-1)*pitColY+(i-1)*pitRowY;
            line([rect(1,1)+(j-1)*pitColX+(i-1)*pitRowX  rect(1,1)+pitAvgX+(i-1)*pitRowX+(j-1)*pitColX],[rect(1,2)+(j-1)*pitColY+(i-1)*pitRowY rect(1,2)+(j-1)*pitColY+(i-1)*pitRowY], 'Color', 'r');
            line([rect(1,1)+(j-1)*pitColX+(i-1)*pitRowX  rect(1,1)+pitAvgX+(i-1)*pitRowX+(j-1)*pitColX],[rect(1,2)+(j-1)*pitColY+(i-1)*pitRowY+pitAvgY rect(1,2)+(j-1)*pitColY+(i-1)*pitRowY+pitAvgY], 'Color', 'r');
            line([rect(1,1)+(j-1)*pitColX+(i-1)*pitRowX  rect(1,1)+(i-1)*pitRowX+(j-1)*pitColX],[rect(1,2)+(j-1)*pitColY+(i-1)*pitRowY rect(1,2)+(j-1)*pitColY+(i-1)*pitRowY+pitAvgY], 'Color', 'r');
            line([rect(1,1)+(j-1)*pitColX+(i-1)*pitRowX+pitAvgX  rect(1,1)+(i-1)*pitRowX+(j-1)*pitColX+pitAvgX],[rect(1,2)+(j-1)*pitColY+(i-1)*pitRowY rect(1,2)+(j-1)*pitColY+(i-1)*pitRowY+pitAvgY], 'Color', 'r');
        end
    end
    pitGridStruct.pitUL = pitUL;
    pitHappy = input('Is this grid the right size? (y/n) ', 's');
end

%% Eliminate unsuitable pits
    exclusionList = [];
    str = 'y';
    hPit = zeros(rowDist+1,colDist+1);
    while ~(strcmpi(str,'n') || strcmpi(str,'no'))
        str = input('Draw a rectangle to eliminate pits? [y]/n: ','s'); % 's' arg specifies that INPUT returns string
        if strcmpi(str,'n') || strcmpi(str,'no')
            break;
        else
            rectCoords = getrect(hfig);
            xR = rectCoords(1);
            yR = rectCoords(2);
            wR = rectCoords(3);
            hR = rectCoords(4);
            try
                hRect = rectangle('Position', rectCoords, 'EdgeColor', [1 1 1]);
            catch
                disp('Error drawing rectangle.')
                continue 
            end
            killEmAllStr = input('Eliminate all pits at least partially in this rectangle? y/[n]: ', 's');
            if strcmpi(killEmAllStr,'y') || strcmpi(killEmAllStr,'yes')
                killEmAllFlag = 1;
            else
                killEmAllFlag = 0;
            end
            for i=1:(rowDist+1)
                for j=1:(colDist+1)
                    if ((pitUL(i,j,1)<=xR+wR) && (pitUL(i,j,1)+pitAvg(3)>=xR) ... %UL is to left of right edge of rect and LR is to right of left edge of rect
                       && (pitUL(i,j,2)<=yR+hR) && (pitUL(i,j,2)+pitAvg(4)>=yR)) % and UL is above (smaller y coord) bottom of rect and LR is below top of rect
                        hPit(i,j) = rectangle('Position',[squeeze(pitUL(i,j,1:2))' pitAvg(3:4)]);
                        if killEmAllFlag
                            % don't need to identify and query
                        else
                            set(hPit(i,j),'EdgeColor',[1 1 1])
                            queryText = 'Eliminate pit (colored in white)? y/[n]: ';
                            elimYN = input(queryText,'s');
                        end
                        if killEmAllFlag || strcmpi(elimYN,'y') || strcmpi(elimYN,'yes')
                            set(hPit(i,j),'EdgeColor',[.2 .2 .2]);
                            exclusionList = cat(1,exclusionList,[i j]);
                        else
                            set(hPit(i,j),'EdgeColor','r');
                        end
                    else %skip pit
                    end
                end
            end %loop over pits in rectangle
            
            %erase rectangle
            delete(hRect);
        end
    end
    


%% Mean Intensity Per Pit
% Using the above information, calculate the mean intensity in each pit as
% a function of time.
for i=1:(rowDist+1)
	for j=1:(colDist+1)
       % for t=1:frames
            pitArray = movieArray(rect(1,2)+(j-1)*pitColY+(i-1)*pitRowY:rect(1,2)+(j-1)*pitColY+(i-1)*pitRowY+pitAvgY, rect(1,1)+(j-1)*pitColX+(i-1)*pitRowX:rect(1,1)+pitAvgX+(i-1)*pitRowX+(j-1)*pitColX, 1:frames);
            meanPitInt(i,j,1:frames)= mean(mean(pitArray,1),2);
       % end
	end
end