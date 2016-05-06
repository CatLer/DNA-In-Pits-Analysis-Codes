function [] = SaveAviFromTiff()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% g=gcf;
g=figure;
[file,path]=uigetfile('*.tif');
name=fullfile(path,file);
nameprime=strrep(name,'.tif','.avi');
v=VideoWriter(nameprime); 
v.FrameRate=20; open(v);
set(gca,'nextplot','replacechildren'); 
Video=TifSample(name);
Video=mat2gray(Video);
for k = 1:size(Video,3)
   imshow(Video(:,:,k))
   frame = getframe;
   writeVideo(v,frame);
end
close(v); close(g);
end