function [ListOfNames] = CheckBadGrids()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
A=evalin('base','whos(''-regexp'',''Set'')');
Names={A.name}; ListOfNames={};

for i=1:numel(Names)
    GCGL=evalin('base',...
        strcat(Names{i},'.Green_Channel_In_Green_Laser.Positions'));
    RCGL=evalin('base',...
        strcat(Names{i},'.Red_Channel_In_Green_Laser.Positions'));
    RCRL=evalin('base',...
        strcat(Names{i},'.Red_Channel_In_Red_Laser.Positions'));
    BCBL=evalin('base',...
        strcat(Names{i},'.Blue_Channel_In_Blue_Laser.Positions'));
    GCGL=isempty(GCGL); RCGL=isempty(RCGL);
    RCRL=isempty(RCRL); BCBL=isempty(BCBL);
    Condition=GCGL*RCGL*RCRL*BCBL;
    SampleName=evalin('base',strcat(Names{i},'.FullPath'));
    [pathstr,name,ext] = fileparts(SampleName);
    SampleName=strcat(name,ext);
    if i==1
        cd(pathstr);
    end
    if Condition==1
        ListOfNames=cat(1,ListOfNames,SampleName);
    end
    
end
if ~isempty(ListOfNames)
CheckPitGrids(ListOfNames);
end

end

