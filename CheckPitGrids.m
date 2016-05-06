function [] = CheckPitGrids(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if nargin==0 || ~ischar(varargin{1}) || ~strcmpi(strrep(varargin{1},' ',''),'DualView') ...
        && ~strcmpi(strrep(varargin{1},' ',''),'SingleView') 
    choices={'Dual View','Single View'};
    [Selection,ok] = listdlg('ListString',choices,'Name',...
        'Type of Experiment', 'PromptString', ...
        'Select a type of experiment.','SelectionMode','single'); %
if ok==0
    return;
else
    Experiment=choices{Selection};
end
else
    Experiment=varargin{1};
end

PossibleExps=cellfun(@iscell,varargin,'UniformOutput',false);
if iscell(PossibleExps)
    PossibleExps=cell2mat(PossibleExps);
end
names=varargin(PossibleExps); 
if ~isempty(names)
    names=names{1};
end

if isempty(names)

foldername=uigetdir(pwd,'Please Select The Folder Of The Videos To Analyze');
if foldername==0
    return;
end
cd(foldername);
expression='*tif';
names=dir(expression); names={names.name};

quest=questdlg('Show me...','What''s next', ...
    'Unfitted Grids','All Grids','Fitted Grids','Fitted Grids');

if strcmp(quest,'Unfitted Grids') || strcmp(quest,'Fitted Grids')
    FittedGrids=dir('*mat'); FittedGrids={FittedGrids.name};
    N=cellfun(@RemExt,names,'UniformOutput',false);
    FG=cellfun(@RemExt,FittedGrids,'UniformOutput',false);
    
    Check=cellfun(@(x)strncmp(x,FG,length(x)),N,'UniformOutput',false);
    Check=cellfun(@(x)logical(sum(x)),Check,'UniformOutput',false);
    if iscell(Check)
        Check=cell2mat(Check);
    end
    if strcmp(quest,'Unfitted Grids')
        names=names(~Check);
    else
        names=names(Check);
    end
end

if isempty(names)
    errordlg('No Video Matches Criteria');
    return;
end

[Selection,ok] = listdlg('ListString',names,'ListSize',[500,600],...
    'Name','Videos Selection', 'PromptString', 'Please, select videos.'); %
if ok==0
    return;
else
    names=names(Selection);
end

end

names_prime=cellfun(@RemExt,names,'UniformOutput',false);

    function name=RemExt(name)
    s=regexp(name,'\.\w*');
    if ~isempty(s)
    name=name(1:s(1)-1);
    end
    end
Previous_Grid=[]; 
if strcmp(Experiment,'Dual View')
    N=5;
else
    N=4;
end
Previous_Grid_Prime=cell(1,N);
for i=1:numel(names)
    myName=strcat('S_',names_prime{i}(1:min(end,61)));
    expression=sprintf('%s=double(TifSample(''%s''));',myName,names{i});
    evalin('caller',expression);
    m=questdlg(names_prime{i},'What''s next...','Keep going','Quit','Quit'); 
%     uiwait(m)
    if strcmp(m,'Quit')
        e=sprintf('clear(''%s'')',char(myName)); evalin('caller',e);
        return;
    end
    [Previous_Grid_Prime{:}]=ConstructPitsGrid(evalin('caller',myName),1,...
        Experiment,'',names_prime{i},Previous_Grid);
    e=sprintf('clear(''%s'')',char(myName)); evalin('caller',e);
    Previous_Grid=Previous_Grid_Prime;
end

end

