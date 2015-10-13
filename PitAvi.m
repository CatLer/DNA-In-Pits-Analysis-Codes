function [] = PitAvi(Pit,name)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
g=gcf;
v = VideoWriter(strcat(name,'mpeg-4')); 
v.FrameRate=10; open(v);
set(gca,'nextplot','replacechildren'); 
% Pit=mat2gray(Pit);
for k = 1:size(Pit,3)
   surf(medfilt2(mat2gray(Pit(:,:,k)),[5,5])); view(2); 
   shading interp;  colormap parula;
   frame = getframe;
   writeVideo(v,frame);
end
close(v); close(g);
end

