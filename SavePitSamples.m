function []=SavePitSamples(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
narginchk(0,2);
Names=evalin('base','whos(''Set_*'')');  % 'Set_*'  to add a filter
Classes={Names.class}; I=strcmp(Classes,'PitsSample');
Names=Names(I); Names={Names.name};
if isempty(Names)
    warning('No sample found.')
    return;
end
second_input = false;
try narginchk(0,1)
catch
    second_input = true;
end
if ~second_input
    j=listdlg('ListString',Names,'SelectionMode','multiple','ListSize',[400,600],...
        'Name','Sample Selection', 'PromptString', 'Please, select a sample.');
    if isempty(j)
        return;
    end   
    Names=Names(j);
    if ~iscell(Names)
        Names={Names};
    end
end    
    if nargin==1
        str='.SaveSample(1);';
    else
        str='.SaveSample;';
    end    
wait = waitbar(0,'Saving Samples');    
for i=1:numel(Names)
    expression=strcat(Names{i},str);
    evalin('base',expression);
    waitbar(i/numel(Names));
end
close(wait);
end

