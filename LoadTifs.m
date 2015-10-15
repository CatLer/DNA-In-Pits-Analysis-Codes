function [] = LoadTifs()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
List=dir('*.tif'); Names={List.name};
[Selection,~] = listdlg('ListString',Names); 
Names=Names(Selection);
OBJT=num2cell(cellfun(@(x)regexpi(x,'\d{2}p\d{2}OBJT'),Names,'UniformOutput',false));
LENST=num2cell(cellfun(@(x)regexpi(x,'\d{2}p\d{2}LENST'),Names,'UniformOutput',false));
TRYNUM=num2cell(cellfun(@(x)regexpi(x,'Try\d{1}'),Names,'UniformOutput',false));
OBJT=cellfun(@(x,y)x(y{1}:y{1}+8),Names,OBJT,'UniformOutput',false);
LENST=cellfun(@(x,y)x(y{1}:y{1}+9),Names,LENST,'UniformOutput',false);
TRYNUM=cellfun(@(x,y)x(y{1}:y{1}+3),Names,TRYNUM,'UniformOutput',false);
NewNames=cellfun(@(x,y,z)strcat('S_',x,'_',y,'_',z),...
    OBJT,LENST,TRYNUM,'UniformOutput',false);
Expressions=cellfun(@(x,y)strcat(x,'=TifSample(''',y,''');'),...
    NewNames,Names,'UniformOutput',false);
for i=1:numel(Expressions)
    Expressions{i}
    evalin('base',Expressions{i});
end
end

