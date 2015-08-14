function [] = BackgroundCheck2(my_set,opt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if opt==0
my_name=inputname(1);
else 
    if opt==1
my_name=my_set;
    end
end
expression=strcat(my_name,'.Red_Channel.Relative_Intensity'); 
Intensity_R=evalin('base',expression);
expression=strcat(my_name,'.Green_Channel.Relative_Intensity'); 
Intensity_G=evalin('base',expression);
expression=strcat(my_name,'.Red_Channel.Absolute_Intensity'); 
intensity_R=evalin('base',expression);
expression=strcat(my_name,'.Green_Channel.Absolute_Intensity'); 
intensity_G=evalin('base',expression);
expression=strcat(my_name,'.Red_Channel.Background_Intensity'); 
Background_R=evalin('base',expression);
expression=strcat(my_name,'.Green_Channel.Background_Intensity'); 
Background_G=evalin('base',expression);
BackgroundCheck(Intensity_R,Intensity_G,intensity_R,intensity_G,Background_R,Background_G,my_name);
end

