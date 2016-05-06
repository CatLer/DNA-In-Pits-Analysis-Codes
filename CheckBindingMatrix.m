function [Sheep] = CheckBindingMatrix(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
 Names=evalin('base','whos(''Set_*'')');  % 'Set_*'  to add a filter
    Classes={Names.class}; I=strcmp(Classes,'PitsSample');
    Names=Names(I); Names={Names.name};
    if isempty(Names)
        warning('No sample found.')
        return;
    end
    j=listdlg('ListString',Names,'SelectionMode','multiple','ListSize',[400,600],...
        'Name','Sample Selection', 'PromptString', 'Please, select a sample.');
    if isempty(j)
        return;
    end
    Name=Names(j);
    
    Sheep='';
  
    
NumInArgs=nargin;

switch NumInArgs
 
    case 0
        
    for i=1:numel(Name)
        expression=sprintf('%s.Green_Channel_In_Green_Laser.Binding;',Name{i});
        out=evalin('base', expression);
        if isempty(out)
            Sheep=cat(1,Sheep,Name{i});
            expression=sprintf('%s.GiveMeBindingStatistics(0,NaN);',Name{i});
            evalin('base',expression);
        end
        
    end
    
    case 1
        
        for i = 1:numel(Name)
                expression=sprintf('%s.GiveMeBindingStatistics(0,NaN);',Name{i});
                evalin('base',expression);       
        end
        
        Sheep='Done!';

end

end

