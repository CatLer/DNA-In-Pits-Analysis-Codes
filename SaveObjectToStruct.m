function [] = SaveObjectToStruct(filename)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
% load object
A=load(filename); n=fieldnames(A); n=n{1}; A=getfield(A,n); %#ok<GFLD>
% generate a structure
A=struct(A); save(strcat(filename,'_Struct'),'A')
end

