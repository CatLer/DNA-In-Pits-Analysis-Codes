function [ ] = SV2(FileTif )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,NumberImages,'uint16');

[path,~,~] = fileparts(FileTif);
new_name = fullfile(path, 'Sample100.tif');

TifLink = Tiff(FileTif, 'r');
for i=1:100
    TifLink.setDirectory(i);
    FinalImage(:,:,i)=TifLink.read();
    
    if i==1
        imwrite(FinalImage(:,:,i), new_name);
    else
        imwrite(FinalImage(:,:,i),new_name, 'WriteMode', 'append');
    end
end
TifLink.close();
end

