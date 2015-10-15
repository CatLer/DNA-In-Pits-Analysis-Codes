function [] = PutAllTifsTogether(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if nargin==0
    foldername=pwd;
else
    foldername=varargin{1};
end
D=dir(foldername); IsDir=[D.isdir];
Subdirectories=D(IsDir); Subdirectories_name={Subdirectories.name};
Files=dir(strcat(foldername,'/*.tif')); 
if ~isempty(Files)
    Files={Files.name};
end
mkdir('All Videos');
Destination=fullfile(foldername,'All Videos');

for i=1:numel(Files)
  copyfile(fullfile(foldername,Files{i}),Destination);  
end
for i=1:numel(Subdirectories)
    cd(fullfile(foldername,Subdirectories_name{i})); 
   Files2=dir('*.tif'); 
   if ~isempty(Files2)
   Files2={Files2.name};
   end
   for j=1:numel(Files2)
copyfile(fullfile(foldername,Subdirectories_name{i},Files2{j}),Destination);
   end
end
end

