
function [Intensity,intensity,Background,Molecular_Brightness] = ...
    my_mask(input,background,num_rows,num_cols,r,Pairs) 
Intensity=[]; intensity=[]; Background=[];
%====================== DIMENSIONS CHECK ==================================
% coming soon
%==========================================================================
%=========================== MASKS ========================================
mask=zeros(size(input,1),size(input,2)); 
r = ceil(r); 
for j=1:size(Pairs,1)
mask=mask+logical(bsxfun(@plus,((1:size(input,2))-Pairs(j,1)).^2,...
    (transpose(1:size(input,1))-Pairs(j,2)).^2) <r^2);
end
mask=logical(mask); 
%======================= SIGNALS RETRIEVAL ================================
w=min(round(0.1*size(input,3)),100); 
% works only if pits are NOT connected
Pits=bwconncomp(mask);
Labels=cell2mat(reshape(struct2cell(regionprops(Pits,'centroid')),...
    [Pits.NumObjects,1]));
[~,I]=min(pdist2(Pairs,Labels),[],2); Pits.PixelIdxList=Pits.PixelIdxList(I);

if Pits.NumObjects==num_cols*num_rows % check for connectivity
%---------------------- absolute intensity -------------------------------- 
%----------------------- Convert to cell array ----------------------------
input=double(input);
input=mat2cell(input,size(input,1),size(input,2),ones(1,size(input,3)));
%--------------------------------------------------------------------------
intensity=cell2mat(cellfun(@(x) reshape(cell2mat(struct2cell(...
    regionprops(Pits,x,'MeanIntensity'))),[num_rows,num_cols]),...
    input,'UniformOutput',false));
intensity=cell2mat(cellfun(@(x) medfilt1(x,w),...
    mat2cell(intensity,ones(1,size(intensity,1)),ones(1,size(intensity,2)),...
    size(intensity,3)),'UniformOutput',false));
intensity = intensity(:,:,1+w:size(intensity,3)-w);

% apparent molecular brightness
Variance=cell2mat(cellfun(@(x) reshape(cellfun(@var,struct2cell(...
    regionprops(Pits,x,'PixelValues'))),[num_rows,num_cols]),...
    input,'UniformOutput',false));
Variance=cell2mat(cellfun(@(x) medfilt1(x,w),...
    mat2cell(Variance,ones(1,size(Variance,1)),ones(1,size(Variance,2)),...
    size(Variance,3)),'UniformOutput',false));
Variance = Variance(:,:,1+w:size(Variance,3)-w);
Molecular_Brightness=Variance./intensity;

%--------------------------------------------------------------------------
%--------------------- background intensity -------------------------------
Background=cell2mat(cellfun(@(x) reshape(cell2mat(struct2cell(...
    regionprops(Pits,x,'MeanIntensity'))),[num_rows,num_cols]),...
    background,'UniformOutput',false));
Background=cell2mat(cellfun(@(x) medfilt1(x,w),...
    mat2cell(Background,ones(1,size(Background,1)),ones(1,size(Background,2)),...
    size(Background,3)),'UniformOutput',false));
Background = Background(:,:,1+w:size(Background,3)-w);
%--------------------------------------------------------------------------
%------------------------ Background normalization ------------------------
BG=mean(Background,3); BG=BG./max(BG(:));
fraction=repmat(BG,[1,1,size(Background,3)]); 
%--------------------------------------------------------------------------
%----------------------- relative intensity -------------------------------
Intensity=intensity-Background;
Intensity=Intensity./fraction;
intensity=intensity./fraction;
Background=Background./fraction;
%--------------------------------------------------------------------------
%-------------------------- Labelling check -------------------------------
% Returns x,y coordinates of the COM of objects (not exact pits positions)
% blabla=reshape(struct2cell(regionprops(Pits,'Centroid')),[num_rows,num_cols]);
% celldisp(Label)
%--------------------------------------------------------------------------
else
    % Plan B coming soon
end
end

