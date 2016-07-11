function [] = PutAllTifsTogether(varargin)
%When the folder contains subfolders containing the .tif file and the .txt
%file of a given experiment. Move all the video files into a single folder
%and generates a .csv containing the exposure times of each video. Move all
%the text files into a single folder. Both generated folders are contained
%in the initial folder.
%   Detailed explanation goes here
%%                      Specify folder to treat 
if nargin==0
    foldername=uigetdir();
    if foldername==0;
    return;
    end
else
    foldername=varargin{1};
end
if exist('Folder to analyze','dir')~=7
mkdir(fullfile(foldername,'Folder to analyze'));
end
Destination=fullfile(foldername,'Folder to analyze');
%%                      Filter and store                     
% define exposure times cell array
Exposure_Times={};
% find subfolders
D=dir(foldername); IsDir=[D.isdir];
Subdirectories=D(IsDir); Subdirectories_name={Subdirectories.name};    
Z=cellfun(@(x)isempty(regexp(x,'\.*')),Subdirectories_name,...
    'UniformOutput',false); %#ok<RGXP1>
Z=cell2mat(Z); Subdirectories_name=Subdirectories_name(Z);
% find tif files
TifFiles=dir(strcat(foldername,'/*.tif'));
if ~isempty(TifFiles)
    TifFiles={TifFiles.name};
end

% move the tif files to the folder
for i=1:numel(TifFiles)
    movefile(fullfile(foldername,TifFiles{i}),Destination);
end
wait = waitbar(0,'Please wait...');
for i=1:numel(Subdirectories_name)
    if ~strcmp(Subdirectories_name{i},'Folder to analyze')
    cd(fullfile(foldername,Subdirectories_name{i}));
    TifFiles2=dir('*.tif');
    if ~isempty(TifFiles2)
        TifFiles2={TifFiles2.name};
    end
    for j=1:numel(TifFiles2)
        movefile(fullfile(foldername,Subdirectories_name{i},...
            TifFiles2{j}),Destination);
    end
    GetExposureTimes;
    end
    waitbar(i/numel(Subdirectories_name));
end
%%                      Exposure times & CSV
% create CSV with exposure times
  cd(fullfile(foldername,'Folder to analyze'));
  fid = fopen('ExposureTimes.csv','a+');
  for l=1:size(Exposure_Times,1)
  fprintf(fid,'%s, %f \n',Exposure_Times{l,:});
  end
  fclose(fid);

    function []=GetExposureTimes()
        try
        % find txt files
        TxtFiles=dir('*.txt');
        if ~isempty(TxtFiles)
            TxtFiles={TxtFiles.name};
        end
        ExposureTimes=cell(numel(TxtFiles),2);
        for k=1:numel(TxtFiles)
                A=fileread(TxtFiles{k});
                A=strsplit(A,',');
                B=cellfun(@(x)regexp(x,'"Exposure-ms": \d*'),A,...
                    'UniformOutput',false); %CONFIRMED that this is correct data. 
                B=cellfun(@isempty,B); B=~B; A=A(B);
                if ~isempty(A)
                    A=A{1};
                ExposureTimes{k,1}=strrep(TxtFiles{k},'_metadata.txt','.ome');
                ExposureTimes{k,2}=A;
                [a,b]=regexp(ExposureTimes{k,2},'\d*');
                ExposureTimes{k,2}=str2double(ExposureTimes{k,2}(a:b));
                end
        end
        Exposure_Times=cat(1,Exposure_Times,ExposureTimes);
        catch
        end
    end
    close(wait);
end


