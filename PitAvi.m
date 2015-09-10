function [] = PitAvi(Pit,name)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
v = VideoWriter(name); open(v);
for i=1:size(Pit,3)
writeVideo(v,Pit(:,:,i));
end
close(v);
end

