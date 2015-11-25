function [names] = ImportAnalyzedSamples()
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
foldername=uigetdir(pwd,'Please Select The Folder Of The Analyzed Samples');
if foldername==0
    return;
end
cd(foldername);
expression='*mat';
names=dir(expression); names={names.name};
id=cellfun(@(x)~isempty(regexp(x,'Set_*','once')),...
    names,'UniformOutput',false);
if iscell(id)
    id=cell2mat(id);
end
names=names(id);
[Selection,ok] = listdlg('ListString',names,'ListSize',[500,600],...
    'Name','Videos Selection', 'PromptString', 'Please, select videos.'); %
if ok==0
    return;
else
    names=names(Selection);
end

cellfun(@LoadSamplesInWorkspace,names,'UniformOutput',false);

    function LoadSamplesInWorkspace(name)
        m=matfile(name); Var=whos(m); Var=Var.name;
        m=load(name); eval(sprintf('m=m.%s;',Var));
        assignin('base',Var,m);
    end

end

