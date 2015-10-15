function [] = ShowMePitVSTraces(Sample,row,column,Video)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
if ischar(Sample)
Name=Sample; 
else
Name=inputname(1);
end
POSG=evalin('base',strcat(Name,sprintf(...
    '.Green_Channel_In_Green_Laser.Positions{%d,%d}',...
    row,column)));
RIG=evalin('base',strcat(Name,sprintf(...
    '.Green_Channel_In_Green_Laser.Relative_Intensity(%d,%d,:)',...
    row,column)));
VARG=evalin('base',strcat(Name,sprintf(...
    '.Green_Channel_In_Green_Laser.Variance_In_Time(%d,%d,:)',...
    row,column)));
f1=figure('Visible','off'); 
subplot(2,1,1); plot(permute(RIG,[3,2,1]),'g'); 
title(sprintf('Spatial Average - Pit(%d,%d)',row,column)); 
subplot(2,1,2); plot(permute(VARG,[3,2,1]),'b'); 
title(sprintf('Spatial Variance - Pit(%d,%d)',row,column));
R=evalin('base',strcat(Name,'.Pit_Radius'))+2;
evalin('base',strcat(Name,'.GridCheck')); hold on;
viscircles(POSG,R,'EdgeColor','m'); hold off;
title(strcat('Collapsed frames - ', Name),'interpreter','none');
f2=gcf; set(f2,'Visible','off');


V=Video(max(0,round(POSG(2)-R)):min(size(Video,1),round(POSG(2)+R)),...
    max(0,round(POSG(1)-R)):min(size(Video,2),round(POSG(1)+R)),50:150);
W=5; 
n=floor(size(V,3)/W); V=V(:,:,1:n*W);
V=reshape(V,size(V,1),size(V,2),W,n); 
V=sum(V,3); V=squeeze(V);
handle=implay(mat2gray(V),2*W); 
handle.Visual.ColorMap.MapExpression='jet';
handle.Visual.Axes.Position=[100,100,4*size(V,2),4*size(V,1)];
figure;
PitAvi(V,Name);
set(f1,'Visible','on'); set(f2,'Visible','on');
end

