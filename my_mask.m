function [Intensity,intensity,Background,Variance_Noise_Filtered,...
    Variance,VarNoise,Positions,bg,intensity_packed] = ...
    my_mask(input,background,num_rows,num_cols,r,Pairs) 
Intensity=[]; intensity=[]; Background=[]; 
Variance_Noise_Filtered=[]; Positions=[];
Variance=[]; VarNoise=[]; bg=[];
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
% mask=imclearborder(mask); %new
% figure; imshow(mask)
%======================= SIGNALS RETRIEVAL ================================
w=min(round(0.1*size(input,3)),100);    
% works only if pits are NOT connected
Pits=bwconncomp(mask);
Labels=cell2mat(reshape(struct2cell(regionprops(Pits,'centroid')),...
    [Pits.NumObjects,1]));
[d,I]=min(pdist2(Pairs,Labels),[],2); 
% needs some improvements in handling # of pits detected and masks
if numel(I)>Pits.NumObjects
I=I(d<r); I=unique(I,'stable'); % not the best solution
end
Pits.PixelIdxList=Pits.PixelIdxList(I);
[Num_rows,Num_cols]=GuessNumRowsCols(Pits.NumObjects, num_rows, num_cols); %new
if abs(Num_rows-num_rows)<=2 && abs(Num_cols-num_cols)<=2 % new
    num_rows=Num_rows; num_cols=Num_cols;
end

if Pits.NumObjects==num_cols*num_rows % check for connectivity
%--------------------- background profile ---------------------------------    
bg=cell2mat(background); bg=mean(bg,3); 
h=fspecial('disk',r); bg=imfilter(bg,h); 
bg(1:2*r,:)=NaN; bg(:,1:2*r)=NaN; 
bg(end-2*r:end,:)=NaN; bg(:,end-2*r:end)=NaN;
bg=bg./max(bg(:)); 
% figure; surf(bg); shading interp; colormap hot; view(2)
%--------------------------------------------------------------------------
%--------------------- background intensity -------------------------------
Background=cell2mat(cellfun(@(x) reshape(cell2mat(struct2cell(...
    regionprops(Pits,x./bg,'MeanIntensity'))),[num_rows,num_cols]),...
    background,'UniformOutput',false));
Background=cell2mat(cellfun(@(x) medfilt1(x,w),...
    mat2cell(Background,ones(1,size(Background,1)),ones(1,size(Background,2)),...
    size(Background,3)),'UniformOutput',false));
Background = Background(:,:,1+w:size(Background,3)-w);
%--------------------------------------------------------------------------
%------------------------ Background normalization ------------------------
% BG=mean(Background,3); BG=BG./max(BG(:));
% fraction=repmat(BG,[1,1,size(Background,3)]); 
%--------------------------------------------------------------------------    
%---------------------- absolute intensity -------------------------------- 
%----------------------- Convert to cell array ----------------------------
input=double(input);
input_packed=Packing(input,min(25,size(input,3)));
input=mat2cell(input,size(input,1),size(input,2),ones(1,size(input,3)));
bg_uniformized_input=cellfun(@(x)x./bg,input,'UniformOutput',false);
input_packed=mat2cell(input_packed,size(input_packed,1),...
    size(input_packed,2),ones(1,size(input_packed,3)));

Histograms=cellfun(@(x,y)AccumulateHistograms(x./bg),input,'UniformOutput',false);
Histograms=cellfun(@RemoveSquishedOligo,Histograms,'UniformOutput',false);
filtered_input=cellfun(@(x,z)EraseSquishedNPits(x./bg,z),...
    input,Histograms,'UniformOutput',false);

% figure; 
% subplot(1,3,1); imshow(input{1},[min(input{1}(:)),max(input{1}(:))]);
% subplot(1,3,2); imshow(filtered_input{1},[min(input{1}(:)),max(input{1}(:))]);
% subplot(1,3,3); imshow(bg_uniformized_input{1},[min(input{1}(:)),max(input{1}(:))]);

Var_Noise=cellfun(@(x)NaNVar(x),filtered_input,'UniformOutput',false);

% figure;
% try
%     plot(permute(Var_Noise,[3,2,1]));
% catch
%     plot(permute(cell2mat(Var_Noise),[3,2,1]));
% end

if ~iscell(Var_Noise)
    Var_Noise=num2cell(Var_Noise);
end
Var_Noise=medfilt1(cell2mat(Var_Noise),w);
Var_Noise = Var_Noise(:,:,1+w:size(Var_Noise,3)-w);
VarNoise = repmat(Var_Noise,[size(Background,1),size(Background,2),1]);

% figure;
% plot(permute(Var_Noise,[3,2,1]));

%--------------------------------------------------------------------------
intensity=cell2mat(cellfun(@(x) reshape(cell2mat(struct2cell(...
    regionprops(Pits,x,'MeanIntensity'))),[num_rows,num_cols]),...
    bg_uniformized_input,'UniformOutput',false));
intensity=cell2mat(cellfun(@(x) medfilt1(x,w),...
    mat2cell(intensity,ones(1,size(intensity,1)),ones(1,size(intensity,2)),...
    size(intensity,3)),'UniformOutput',false));
intensity = intensity(:,:,1+w:size(intensity,3)-w);

intensity_packed=cell2mat(cellfun(@(x) reshape(cellfun(...
    @DetermineOccupation,struct2cell(regionprops(Pits,x,'PixelValues'))),...
    [num_rows,num_cols]),input_packed,'UniformOutput',false));

Variance=cell2mat(cellfun(@(x) reshape(cellfun(@NaNVarPit,struct2cell(...
    regionprops(Pits,x,'PixelValues'))),[num_rows,num_cols]),...
    bg_uniformized_input,'UniformOutput',false)); % new
Variance=cell2mat(cellfun(@(x) medfilt1(x,w),...
    mat2cell(Variance,ones(1,size(Variance,1)),ones(1,size(Variance,2)),...
    size(Variance,3)),'UniformOutput',false));
Variance = Variance(:,:,1+w:size(Variance,3)-w);
Variance_Noise_Filtered=Variance-VarNoise;
%--------------------------------------------------------------------------
%----------------------- relative intensity -------------------------------
Intensity=intensity-Background;
% Intensity=Intensity./fraction;
% intensity=intensity./fraction;
% Background=Background./fraction;
% Molecular_Brightness=Molecular_Brightness./fraction;
% Variance=Variance./fraction;
% size(Molecular_Brightness)
%--------------------------------------------------------------------------
%-------------------------- Labelling check -------------------------------
% Returns x,y coordinates of the COM of objects (not exact pits positions)
Positions=reshape(struct2cell(regionprops(Pits,'Centroid')),[num_rows,num_cols]);
%--------------------------------------------------------------------------
else
    % Plan B coming soon
    sprintf('Number of found pits doesn''t match dimensions.')
end

    function occupation=DetermineOccupation(Array)
        Array=mat2gray(Array(~isnan(Array)));
        Threshold=multithresh(Array,2);
        Array=Array>Threshold(2);
        Ratio=mean(Array);
        occupation=Ratio<0.25;
    end

% to remove squished oligo
    function Out=AccumulateHistograms(image)
%         image(image>graythresh(image)*max(image(:)))=NaN;
        image=image(~mask); % image=image(~isnan(image));
        [counts,bins] = hist(image);
        Out=cat(2,counts(:),bins(:));
    end
    function Out=RemoveSquishedOligo(Histogram)
        try
        f=fit(Histogram(:,2),Histogram(:,1),'gauss1');
        Coeffs=coeffvalues(f);
        Mean=Coeffs(2); Sigma=Coeffs(3)/sqrt(2);
        Out=Mean+Sigma; % max value allowed
        catch
            warning('No Gaussian Fit For Background Noise');
            M=Histogram(:,1).*Histogram(:,2);
            M=M./sum(Histogram(:,2));
            V=var(M); V=V./sum(Histogram(:,2));
            Out=M+3*sqrt(V);
        end
    end
    function I=EraseSquishedNPits(I,m)
        I(I>m)=NaN;
        I(mask)=NaN;
    end
    function v=NaNVar(x)
        x=x(~isnan(x));
        v=var(x);
    end
    function v=NaNVarPit(x)
        if sum(isnan(x(:)))==0
        v=var(x(:));
        else
            v=NaN;
        end
    end
end

