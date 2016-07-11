function [Channel_prime,Fraction] = UniformBackgroundIllumination(Channel,Visualization)
%input video data and a logical. The video data will be put through a 
%2D convolution with a uniform matrix to find the background illumination,
%which will then be subtracted from the video. The logical indicates whether
%or not plots of this process are wanted in order to visualize it.

%=============== APPROXIMATE BACKGROUND ILLUMINATION ======================
%------------------------- 2D Convolution ---------------------------------
% define window size to be 5% of the longest edge of the channel
window = round(0.05*max(size(Channel)));
%if window has an even number of pixels, add 1
if mod(window,2)==0
    window=window+1;
end

if Visualization>0
%************************* Visualization **********************************
figure; surf(Channel); shading flat
%**************************************************************************
end

Channel_prime=imfilter(Channel,ones(window));
Fraction=mat2gray(Channel_prime);

%see the background illumination
if Visualization>0
%************************* Visualization **********************************
figure; surf(Channel_prime); shading flat
figure; surf(Fraction); shading flat
%**************************************************************************
end

%--------------------- Remove non-uniform illumination --------------------
%why times 2? It seems to work better. Idk.
Channel_prime=2*mat2gray(Channel)-mat2gray(Channel_prime);

if Visualization>0
%************************* Visualization **********************************
figure;subplot(1,3,1);imshow(Channel,[]);
subplot(1,3,2); imshow(Channel_prime,[]);
subplot(1,3,3);imshow(imsharpen(adapthisteq(mat2gray(Channel_prime))),[]);
%**************************************************************************
end

%sharpen and enhance contrast
Channel_prime = imsharpen(adapthisteq(mat2gray(Channel_prime)));
end

