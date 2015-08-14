function [Channel_prime,Fraction] = UniformBackgroundIllumination(Channel,Visualization)
%UNIFORMBACKGROUNDILLUMINATION : Summary of this function goes here
%   Detailed explanation goes here

%=============== APPROXIMATE BACKGROUND ILLUMINATION ======================
%------------------------- 2D Convolution ---------------------------------
% define window size
window = round(0.05*max(size(Channel)));
if mod(window,2)==0
    window=window+1;
end

if Visualization>0
%************************* Visualization **********************************
figure; surf(Channel); shading flat
%**************************************************************************
end

% dilate the image for the convolution 
Channel_prime = padarray(padarray(Channel,[1,1]*floor(window/2),...
    'replicate','pre'),[1,1]*floor(window/2),'replicate','post');
% convolution to smooth the surface
Channel_prime = conv2(Channel_prime,ones(window),'valid');
Fraction=mat2gray(Channel_prime);

if Visualization>0
%************************* Visualization **********************************
figure; surf(Channel_prime); shading flat
% [counts,binlocations]=imhist(mat2gray(Channel_prime));
% counts(counts<iqr(counts))=0; binlocations(counts==0)=[]; 
% minimum=min(binlocations)*max(Channel_prime(:));
% maximum=max(binlocations)*max(Channel_prime(:));
% Channel_prime(Channel_prime<minimum)=minimum; 
% Channel_prime(Channel_prime>maximum)=maximum;
% figure; surf(Channel_prime); shading flat
figure; surf(Fraction); shading flat
%**************************************************************************
end

%--------------------------------------------------------------------------
%--------------------- Remove non-uniform illumination --------------------
Channel_prime=2*mat2gray(Channel)-mat2gray(Channel_prime);

if Visualization>0
%************************* Visualization **********************************
figure;subplot(1,3,1);imshow(Channel,[]);
subplot(1,3,2); imshow(Channel_prime,[]);
subplot(1,3,3);imshow(imsharpen(adapthisteq(mat2gray(Channel_prime))),[]);
%**************************************************************************
end

Channel_prime = imsharpen(adapthisteq(mat2gray(Channel_prime)));

%--------------------------------------------------------------------------
%==========================================================================

% use morphological opening
% use histeq 
% use adapthisteq

end

