function [RedChannel,GreenChannel] = FindChannelSeparation(projection,Ver_Horz)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
if (strcmp(Ver_Horz,'Vertical'))
w=ceil(size(projection,2)/5); % give a region where it should be 
A=mat2gray(projection); A=sum(A,1); Length=size(A,2);
a=floor(Length/2-w); b=ceil(Length/2+w); A=A(a:b);
[minimum,~]=min(A); [r,c]=find(A==minimum); i=r.*c; 
[~,j]=min(abs(i-numel(A)/2)); Separation=i(j); 
Separation=a+Separation-1;
RedChannel=projection(:,1:Separation); 
GreenChannel=projection(:,Separation:end); 
else
% FOR Mack
warndlg('Select Red Channel');
pause(0.5);
figure;
RedChannel=imcrop(projection);
close all;
warndlg('Select Green Channel');
pause(0.5);
figure;
GreenChannel=imcrop(projection);
close all;
end


end

