function bgArray = BackgroundArray(movieArray, varargin)
% This function takes a movie array and calculates the mean, min, max, or
% media background for a user defined square in each frame. Various
% varargin allow users to define the start frame via the string 'startF',
% followed by the frame number to start on. Users may define a stop frame
% via the string 'stopF', followed by the frame number to stop on.
startF = 1;
stopF = size(movieArray, 3);
up = ''; down = ''; left = ''; right = '';
happy = 'n';

%% Varargin
numvarargin = size(varargin, 2);
if (~isempty(varargin))
    for k=1:numvarargin
        if strcmp(varargin{k}, 'startF')
            startF = varargin{k+1}; 
        elseif strcmp(varargin{k}, 'stopF')
            stopF = varargin{k+1}; 
        end
    end
end

%% Draw Background Subtraction Area
% Users draw a rectangle on the start frame of the movie over which the
% background will be calculated.
while ~strcmp(happy, 'y') && ~strcmp(happy, 'Y')
    imshow(movieArray(:,:,1), []);
    disp('Draw a rectangle around the area where you would like to calculate the background.');    
    hold on;
    delete(left);delete(right);delete(down);delete(up);
    rect = getrect;
    down = line([rect(1) rect(1)+rect(3)],[rect(2) rect(2)], 'Color','r');
    up = line([rect(1) rect(1)+rect(3)],[rect(2)+rect(4) rect(2)+rect(4)], 'Color', 'r');
    left = line([rect(1) rect(1)],[rect(2) rect(2)+rect(4)], 'Color', 'r');
    right = line([rect(1)+rect(3) rect(1)+rect(3)],[rect(2) rect(2)+rect(4)], 'Color', 'r');
    happy = input('Are you happy with the background being calculated here? (y/n) ', 's');
    close;
end

%% Background vs Time
% Display the calculated background vs time, and plot a negative
% exponential function fit. Used background calculation code taken from Dr.
% Jason Leith in his object code MovieSet.m.
bg = double(movieArray(rect(2):rect(2)+rect(4), rect(1):rect(1)+rect(3), :));
pctTrimOut = 5;
smoothingType = 'gaussian';
filterSize = [5 5]; sigma = 1;
smfilter = fspecial(smoothingType, filterSize, sigma);
bkgd2d = trimmean(bg,pctTrimOut,'weighted',1); %1 is for along the first dim
bkgd1d = trimmean(bkgd2d,pctTrimOut,'weighted',2); %2 is for along the second dim
bgArray = imfilter(bkgd1d, smfilter, 'replicate');