function [] = GridChecks(name)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
A=evalin('base','whos(''-regexp'',''Set'')');
Names={A.name};
parent=pwd;
newdir=name; mkdir(parent,newdir); path=strcat(parent,'\',newdir); cd(path);

for i=1:numel(Names)
   evalin('base',strcat(Names{i},'.GridCheck')); 
   fig=gcf;
   title(Names{i},'interpreter','none');
    print(fig,Names{i},'-dpng')
    close(fig)
end

end

