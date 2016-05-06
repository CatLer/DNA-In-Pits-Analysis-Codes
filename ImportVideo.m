function movieArray = ImportVideo(dataDir, fileName, varargin)
% This function imports a video into Matlab and makes it into a 3d array.
% Possible varargin include 'startFrame' and 'endFrame', allowing the user
% to choose the first and last frames to upload. Used portions of a code
% from the website
% http://www.matlabtips.com/how-to-load-tiff-stacks-fast-really-fast/ to
% quickly load in movies. 

%% Initialize Variables
% Initialize and deal with varargin.
startFrame = 1;
data = [dataDir '\' fileName '.tif'];
imageInfo=imfinfo(data);
mImage=imageInfo(1).Width;
nImage=imageInfo(1).Height;
numImages=length(imageInfo);
numvarargin = size(varargin, 2);

if (~isempty(varargin))
    for k=1:numvarargin
        if strcmp(varargin{k}, 'StartFrame')
            startFrame = varargin{k+1}; 
            numImages = endFrame-startFrame + 1;       
        elseif strcmp(varargin{k}, 'EndFrame')
            endFrame = varargin{k+1};
            numImages = endFrame-startFrame + 1;  
        end
    end
end
movieArray=zeros(nImage,mImage,numImages,'uint16');
%% Import video
% Count the number of images, and import them all.
 
for k=1:numImages
   movieArray(:,:,k)=imread(data,'Index',startFrame+k-1,'Info',imageInfo);
end