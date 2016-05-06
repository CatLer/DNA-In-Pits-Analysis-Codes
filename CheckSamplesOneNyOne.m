function [] = CheckSamplesOneNyOne()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Variables=evalin('base','whos(''Set_*'')');
Variables=Variables(strcmp({Variables.class},'PitsSample'));
Variables={Variables.name};
if isempty(Variables)
    warning('No sample found.')
    return;
end
j=listdlg('ListString',Variables,'SelectionMode','multiple','ListSize',[400,600],...
    'Name','Sample Selection', 'PromptString', 'Please, select a sample.');
if isempty(j)
    return;
end
Variables=Variables(j);
for i=1:numel(Variables)
    m=questdlg(Variables{i},'What''s next...','Keep going','Quit','Quit');
    if strcmp(m,'Quit')
        return;
    end
TracesSelect(Variables{i});
end
end

