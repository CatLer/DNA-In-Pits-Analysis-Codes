function [] = GridChecks(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
name=varargin{1};
A=evalin('base','whos(''-regexp'',''Set'')');
Names={A.name};
selection=listdlg('ListString',Names);
if isempty(selection)
    return;
else
    Names=Names(selection);
end

parent=pwd;
newdir=name; mkdir(parent,newdir); path=strcat(parent,'\',newdir); cd(path);

for i=1:numel(Names)
   evalin('base',strcat(Names{i},'.GridCheck')); 
   fig=gcf;
   title(Names{i},'interpreter','none');
    print(fig,Names{i},'-dpng')
    close(fig);
    fig=gcf;
    imshow(mat2gray(evalin('base',strcat(Names{i},...
        '.Time_Average_Absolute_Intensity_In_Green_Laser'))));
    title(Names{i},'interpreter','none');
    print(fig,strcat(Names{i},'(2)'),'-dpng')
    close(fig);
end

end

