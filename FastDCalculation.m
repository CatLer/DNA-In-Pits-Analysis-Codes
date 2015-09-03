function [D,S] = FastDCalculation(r,blue)
%FastDCalculation : Select pits you want and give an approximate radius.
%Select by clicking on the pits (as close as possible to the center of the
%pit) and press enter when done.
%   Uses modified version of ginput, logical masks and FluophoreTracking.

w=min(500,size(blue,3)); blue=double(blue(:,:,1:w));
figure; imshow(adapthisteq(mat2gray(sum(mat2gray(blue),3)))); WantedPits=ginputMark(inf);
mask=zeros(size(blue,1),size(blue,2));

for j=1:size(WantedPits,1)
mask=mask+logical(bsxfun(@plus,((1:size(blue,2))-WantedPits(j,1)).^2,...
(transpose(1:size(blue,1))-WantedPits(j,2)).^2) <r^2);
end
mask=logical(mask);

Images=regionprops(mask,'boundingbox');
MyMasks=regionprops(mask,'image');
Images=cell2mat(transpose(struct2cell(Images)));
MyMasks=struct2cell(MyMasks);
MyMasks=cellfun(@double,MyMasks,'UniformOutput',false);
MyPits=cell(1,size(Images,1));


for i=1:size(Images,1)
    MyPits{i}=blue(round(Images(i,2)):round(Images(i,2))+round(Images(i,4))-1,...
        round(Images(i,1)):round(Images(i,1))+round(Images(i,3))-1,:)...
        .*repmat(MyMasks{i},[1,1,w]);
end
H=cellfun(@FluophoreTracking,MyPits,'UniformOutput',false);

D=cell2mat(cellfun(@(x)x(1),H,'UniformOutput',false));
S=cell2mat(cellfun(@(x)x(2),H,'UniformOutput',false));

D={D}; S={S};
end

