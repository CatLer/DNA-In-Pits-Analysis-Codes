function [DiffusionCoefficients,Speeds,OBJT,LENST,output] = HelpCalculateD()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
DiffusionCoefficients={}; Speeds={}; output={};
Videos=evalin('base','who(''S_*'')');
OBJT=num2cell(cellfun(@(x)regexpi(x,'\d{2}p\d{2}OBJT'),Videos,'UniformOutput',false));
LENST=num2cell(cellfun(@(x)regexpi(x,'\d{2}p\d{2}LENST'),Videos,'UniformOutput',false));
OBJT=cellfun(@(x,y)x(y{1}:y{1}+4),Videos,OBJT,'UniformOutput',false);
LENST=cellfun(@(x,y)x(y{1}:y{1}+4),Videos,LENST,'UniformOutput',false);
I=[];
for i=1:numel(Videos)
try
sprintf('%d/%d',i,numel(Videos))
[D,S]=FastDCalculation(12,evalin('base',Videos{i}));
DiffusionCoefficients=cat(1,DiffusionCoefficients,D);
Speeds=cat(1,Speeds,S);
I=cat(1,I,i);
waitfor(gcf)
catch
    warning('Failed');
end
end

try
OBJT=reshape(OBJT(I),numel(I),1);
LENST=reshape(LENST(I),numel(I),1);
DiffusionCoefficients=rehsape(DiffusionCoeffients,...
    numel(DiffusionCoefficients),1);
Speeds=rehsape(Speeds,...
    numel(Speeds),1);
D=cellfun(@(x)trimmean(x,10),DiffusionCoefficients,'UniformOutput',false);
S=cellfun(@(x)trimmean(x,10),Speeds,'UniformOutput',false);

output=cat(2,OBJT,LENST,DiffusionCoefficients,D,Speeds,S);
catch
    return;
end

end

