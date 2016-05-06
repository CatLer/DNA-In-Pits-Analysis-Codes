function [] = SaveObjectToStrut()
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
names=ImportAnalyzedSamples;
for i=1:numel(names)
    expression=sprintf('struct(%s)',names{i});
    s=evalin('base',expression)
end
end

