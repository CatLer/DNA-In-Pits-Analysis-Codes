function [] = GridCheck(my_set,opt,Pos_R,R_R,Pos_G,R_G)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if opt==0
    my_name=inputname(1);
else
    if opt==1
        my_name=my_set;
    end
end

expression=strcat(my_name,'.Average_Intensity_In_Time'); 
Grid=evalin('base',expression);
fig=figure('Name','Grid Check', 'NumberTitle','off');
imshow(adapthisteq(mat2gray(Grid))); hold on;
viscircles(Pos_R,ones(size(Pos_R,1),1)*R_R,'EdgeColor','r');
viscircles(Pos_G,ones(size(Pos_G,1),1)*R_G,'EdgeColor','g');
title(my_name,'Interpreter','none')
hold off;
print(fig,strcat('Grid_Check_',my_name),'-dpng')
close(fig)
end

