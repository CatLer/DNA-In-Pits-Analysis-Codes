function [Centers, Radii, A] = EasyDetection(Input, HS, Polarity)   
% EASYDETECTION : Find spots given an array of images 'Input' and if they
% must be found on the RHS ('green') or LHS ('red'). If the input is
% different from these strings, then it will look through the entire
% picture. A negative polarity will look for DARK spots and a positive
% polarity looks for BRIGHT spots. ADD TOPHAT FILTERING ***
    % Uses median/average/gaussian filtering. Uses image enhancement.
    % Negative polarity: just uses the complement image.

warning('off','all');

if strcmpi(HS,'green')
    x = floor(size(Input,2)/2):size(Input,2);
else
if strcmpi(HS,'red')
    x = 1:floor(size(Input,2)/2);
else 
    x = 1:size(Input,2);
end
end

% green region (right hand side)
Centers = [];
Radii = [];

Input = mat2gray(Input);
Input = mat2gray(sum(Input,3));
A = Input(:,x);
Input = Input(:,x);

if Polarity <0
    A = imcomplement(A);
end

%---------------- STEP 1 : FILTERING --------------------------------------

%  subplot(2,3,1)
%  imshow(A,[])

% A = imfilter(A,fspecial('gaussian',[5,5],1));
% A = imfilter(A,fspecial('average',[5,5]));
% A = medfilt2(A,[5,5]);
 
%  subplot(2,3,2)
%  imshow(A,[])

%---------------- STEP 2 : ENHANCEMENT ------------------------------------

A = imsharpen(A);
A = adapthisteq(A,'NBins',2000, 'NumTiles', [4,4],'ClipLimit',0.5); %
A = imadjust(A);
% A = A - imcomplement(A);
% A = adapthisteq(A,'NBins',2000, 'NumTiles', [2,2]); %
 
%  subplot(2,3,3)
%  imshow(A,[])
 
% B = histeq(A);
% A = 2*mat2gray(A)-mat2gray(B);
% A = imadjust(A);

%  subplot(2,3,4)
%  imshow(A,[])

% A = imadjust(2*mat2gray(A)-mat2gray(entropyfilt(A,getnhood(strel('disk',15))))); 

%  subplot(2,3,5)
%  imshow(A,[])


% to improve 
% A = imregionalmax(A);
% A = imclearborder(A);
% A = imopen(A,getnhood(strel('disk',2)));
% A = bwmorph(A,'clean');
A = imfilter(A,fspecial('gaussian',[5,5],1));
% A = imfilter(A,fspecial('average',[5,5]));
% A = medfilt2(A,[5,5]);
%--------------------------------------------------------------------------

% detect circles
[Centers, Radii] = imfindcircles(A,[1,6],'ObjectPolarity', 'bright','sensitivity',0.92); %,'sensitivity',0.8,'method','twostage'
% [centers, radii] = imfindcircles(A,[1,6],'ObjectPolarity', 'dark'); 
% Centers = cat(1,Centers,centers);
% Radii = cat(1, Radii, radii);

%---------- plot --------
% 
% my_color = 'b';
% 
% if strcmpi(HS,'green')
%     my_color = 'g';
% end
% if strcmpi(HS,'red')
%     my_color = 'r';
% end

%   subplot(2,3,6)
%   imshow(Input(:,x,1),[])
%   viscircles(Centers,ones(size(Centers,1),1), 'EdgeColor', my_color);

%--------- x translation----  
  
% Centers(:,1) = Centers(:,1)+min(x);

 figure
   imshow(A,[])
   viscircles(Centers,ones(size(Centers,1),1), 'EdgeColor', 'r');

warning('on','all');

end

%--------------------------------------------------------------------------

%A = imclearborder(A,4);
%A = im2bw(A,graythresh(A));
%A = entropyfilt(A, getnhood(strel('disk',1)));
% get only the circles
%A = imopen(A, strel('disk',1));