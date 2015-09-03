function [A] = TifSample(input_args)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
splitPath = strsplit(input_args,'\');
wb = waitbar(0,sprintf('Loading: %s, Pleast Wait...',strrep(splitPath{length(splitPath)},'_','\_')));
warning('off','all')
info = imfinfo(input_args);
mIm = info(1).Width;
nIm = info(1).Height;
numIm = numel(info);
frameStart = 1;
frameEnd = numIm;
 
TifLink = Tiff(input_args, 'r');
A=zeros(nIm, mIm, frameEnd-frameStart+1, 'uint16');

for k = frameStart:frameEnd
   waitbar(k/frameEnd);
   TifLink.setDirectory(k);
   A(:,:,k-frameStart+1)=TifLink.read();
end
TifLink.close();
warning('on','all')
close(wb)
end

