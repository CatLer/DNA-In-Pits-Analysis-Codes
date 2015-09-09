function [A] = TifSample(input_args)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
abort = false;
wb = waitbar(0,'Loading Movie, Please Wait...','CreateCancelBtn',@exit);
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
   if abort
       A = [];
       close all force;
       return;
   end    
   TifLink.setDirectory(k);
   A(:,:,k-frameStart+1)=TifLink.read();
end
TifLink.close();
warning('on','all')
delete(wb)

function exit(a1,a2)
    abort = true;
end    
end
