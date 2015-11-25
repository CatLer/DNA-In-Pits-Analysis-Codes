function [] = TracesSelect(varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
narginchk(0,1);
if nargin==0
Names=evalin('base','whos(''Set_*'')');  % 'Set_*'  to add a filter
Classes={Names.class}; I=strcmp(Classes,'PitsSample');
Names=Names(I); Names={Names.name};
j=listdlg('ListString',Names,'SelectionMode','single','ListSize',[400,600],...
    'Name','Sample Selection', 'PromptString', 'Please, select a sample.');
if isempty(j)
    return;
end
Name=Names{j};
else
    Sample=varargin{1};

if ischar(Sample)
Name=Sample; 
else
Name=inputname(1);
end
end

try 
    screensize = get(groot,'Screensize');
catch
    screensize = get(0,'Screensize');
end

MoleculeColors=figure('Position',[screensize(3)/2,screensize(4)/4,20,300]); 
hold on;
set(gca,'xLim',[-0.1,0.1],'yLim',[-0.1,3.1],'yTick',0:3,'xTick',[]);
line(get(gca,'xLim'),[0,0],'Color','b','Linewidth',3); 
line(get(gca,'xLim'),[1,1],'Color','g','Linewidth',3);
line(get(gca,'xLim'),[2,2],'Color','m','Linewidth',3);
line(get(gca,'xLim'),[3,3],'Color','c','Linewidth',3);
set(gca,'Color','k');
hold off;
title(sprintf('Number \n Of \n Molecules'));
% legend('0 Molecule','1 Molecule','2 Molecule','3 Molecule');

q=questdlg('Do you want to play the video','yes','yes','no','no');
if strcmp(q,'yes')
Video=evalin('base',strcat(Name,'.FullPath')); 
try
    Video=TifSample(Video); 
catch
     [filename,pathname]=uigetfile('*.tif');
     if filename~=0
     Video=TifSample(fullfile(pathname,filename));
     str=strcat(Name,'.FullPath=','''',fullfile(pathname,filename),'''');
     evalin('base',str); 
     else
         Video=[];
     end
end
if ~isempty(Video)
handle=implay(mat2gray(Video));
handle.Visual.ColorMap.MapExpression='bone';
end
end
q=questdlg('Show binding histograms?','Histograms','yes','no','no');
if strcmp(q,'yes')
evalin('base',strcat(Name,'.PlotHistogramsBinding'));
end
evalin('base',strcat(Name,'.CollapseFrames'));
evalin('base',strcat(Name,'.GridCheck')); f=gcf;
hold on;

set(gca,'units','pixels'); % set the axes units to pixels
x = get(gca,'position'); % get the position of the axes
Delta_x=x(3)-x(1); Delta_y=x(4)-x(2);
Lim_x=get(gca,'xLim'); Lim_y=get(gca,'yLim');
Norm_x=Delta_x/diff(Lim_x); Norm_y=Delta_y/diff(Lim_y); 
% set(gcf,'units','pixels'); % set the figure units to pixels
% y = get(gcf,'position'); % get the figure position
Offset_x=x(1)-Norm_x*Lim_x(1);
Offset_y=x(2)-Norm_y*Lim_y(1);

%Pos=ginputMark()
POS_GG=evalin('base',strcat(Name,...
    '.Green_Channel_In_Green_Laser.Positions'));
POS_GR=evalin('base',strcat(Name,...
    '.Red_Channel_In_Green_Laser.Positions'));
POS_RR=evalin('base',strcat(Name,...
    '.Red_Channel_In_Red_Laser.Positions'));
POS_BB=evalin('base',strcat(Name,...
    '.Blue_Channel_In_Blue_Laser.Positions'));
BGG=evalin('base',strcat(Name,...
    '.Green_Channel_In_Green_Laser.Binding'));
BGR=evalin('base',strcat(Name,...
    '.Red_Channel_In_Green_Laser.Binding'));
BRR=evalin('base',strcat(Name,...
    '.Red_Channel_In_Red_Laser.Binding'));
BBB=evalin('base',strcat(Name,...
    '.Blue_Channel_In_Blue_Laser.Binding'));
R=evalin('base',strcat(Name,'.Pit_Radius'));

BGG=POS_GG(BGG); BGR=POS_GR(BGR); BRR=POS_RR(BRR); BBB=POS_BB(BBB);
BGG=cell2mat(BGG); BGR=cell2mat(BGR); BRR=cell2mat(BRR); BBB=cell2mat(BBB);
viscircles(BGG,round(R+2).*ones(size(BGG,1),1),'EdgeColor','y');
viscircles(BGR,round(R+2).*ones(size(BGR,1),1),'EdgeColor','y');
viscircles(BRR,round(R+2).*ones(size(BRR,1),1),'EdgeColor','y');
viscircles(BBB,round(R+2).*ones(size(BBB,1),1),'EdgeColor','y');

if isempty(POS_GG)
    POS_GG=cell.empty;
end
if isempty(POS_GR)
    POS_GR=cell.empty;
end
if isempty(POS_RR)
    POS_RR=cell.empty;
end
if isempty(POS_BB)
    POS_BB=cell.empty;
end

% Pos_GG=cell(size(POS_GG)); Pos_GG=cellfun(@(x)~isempty(x),Pos_GG);
% Pos_GR=cell(size(POS_GR)); Pos_GR=cellfun(@(x)~isempty(x),Pos_GR);
% Pos_RR=cell(size(POS_RR)); Pos_RR=cellfun(@(x)~isempty(x),Pos_RR);
% Pos_BB=cell(size(POS_BB)); Pos_BB=cellfun(@(x)~isempty(x),Pos_BB);

hold on;
    function CreateButton(Position)
        if ~isempty(Position)           
        uicontrol(f,'style','radiobutton','Position',...
            [Position(1)+Offset_x-10,Lim_y(2)-Position(2)+Offset_y-10,14,14],'Callback',...
            @(a,b)PitSelected(a,b,Position));
        end
    end

    function PitSelected(a,~,z)
        if get(a,'Value')==1
            PGG=cellfun(@(X)isequal(z,X),POS_GG);
            PGR=cellfun(@(X)isequal(z,X),POS_GR);
            PRR=cellfun(@(X)isequal(z,X),POS_RR);
            PBB=cellfun(@(X)isequal(z,X),POS_BB);
            if iscell(PGG)
                PGG=cell2mat(PGG);
            end
            if iscell(PGR)
                PGR=cell2mat(PGR);
            end
            if iscell(PRR)
                PRR=cell2mat(PRR);
            end
            if iscell(PBB)
                PBB=cell2mat(PBB);
            end
            if sum(PGG(:))==1
                [r,c]=find(PGG);               
                Action=sprintf(...
                    'ShowMePitVSTraces(%s,%d,%d,''Green'',''Green'');',...
                    Name,r,c);
                evalin('base',Action)
            end
            if sum(PGR(:))==1
                [r,c]=find(PGR);
                Action=sprintf(...
                    'ShowMePitVSTraces(%s,%d,%d,''Red'',''Green'');',...
                    Name,r,c);
                evalin('base',Action)                
            end
            if sum(PRR(:))==1
                [r,c]=find(PRR);
                Action=sprintf(...
                    'ShowMePitVSTraces(%s,%d,%d,''Red'',''Red'');',...
                    Name,r,c);
                evalin('base',Action)                
            end
            if sum(PBB(:))==1
                [r,c]=find(PBB);
                Action=sprintf(...
                    'ShowMePitVSTraces(%s,%d,%d,''Blue'',''Blue'');',...
                    Name,r,c);
                evalin('base',Action)                
            end
        else
        end
    end

%% Pos_GG 
if ~isempty(POS_GG)
cellfun(@CreateButton,POS_GG);
end
%% Pos_GR
if ~isempty(POS_GR)
cellfun(@CreateButton,POS_GR);
end
%% Pos_RR
if ~isempty(POS_RR)
cellfun(@CreateButton,POS_RR);
end
%% Pos_BB
if ~isempty(POS_BB)
cellfun(@CreateButton,POS_BB);
end
% knnsearch 

end

