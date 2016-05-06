function [] = TracesSelect(varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
WantedDisplaySize=[512,512];
narginchk(0,1);
if nargin==0
    Names=evalin('base','whos(''Set_*'')');  % 'Set_*'  to add a filter
    Classes={Names.class}; I=strcmp(Classes,'PitsSample');
    Names=Names(I); Names={Names.name};
    if isempty(Names)
        warning('No sample found.')
        return;
    end
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

%%
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

%%
    function ShowHistograms(~,~)
        q=questdlg('Show binding histograms?','Histograms','yes','no','no');
        if strcmp(q,'yes')
            evalin('base',strcat(Name,'.PlotHistogramsBinding'));
        end
    end
%%
f1=findall(0,'type','figure');
try
    f11=[f1.Number];
catch
    f11=f1;
end
f11=sort(f11);
evalin('base',strcat(Name,'.CollapseFrames(1)'));
f2=findall(0,'type','figure');
try
    f22=[f2.Number];
catch
    f22=f2;
end
[f22,f2id]=sort(f22); f2=f2(f2id);
NewFigs=f2(setdiff(f22,f11));
evalin('base',strcat(Name,'.GridCheck(1)')); f=gcf;
truesize(f,WantedDisplaySize); 
hold on;
%%
set(gca,'units','pixels'); % set the axes units to pixels
x = get(gca,'position'); % get the position of the axes
Delta_x=x(3)-x(1); Delta_y=x(4)-x(2);
Lim_x=get(gca,'xLim'); Lim_y=get(gca,'yLim');
Norm_x=Delta_x/diff(Lim_x); Norm_y=Delta_y/diff(Lim_y);
% set(gcf,'units','pixels'); % set the figure units to pixels
% y = get(gcf,'position'); % get the figure position
Offset_x=x(1)-Norm_x*Lim_x(1);
Offset_y=x(2)-Norm_y*Lim_y(1);

%%       
POS_GG=evalin('base',strcat(Name,...
    '.Green_Channel_In_Green_Laser.Positions;'));
POS_GR=evalin('base',strcat(Name,...
    '.Red_Channel_In_Green_Laser.Positions;'));
POS_RR=evalin('base',strcat(Name,...
    '.Red_Channel_In_Red_Laser.Positions;'));
POS_BB=evalin('base',strcat(Name,...
    '.Blue_Channel_In_Blue_Laser.Positions;'));
R=evalin('base',strcat(Name,'.Pit_Radius;'));

Frame_G=evalin('base',strcat(Name,...
    '.Time_Average_Relative_Intensity_In_Green_Laser;'));
Frame_B=evalin('base',strcat(Name,...
    '.Time_Average_Relative_Intensity_In_Blue_Laser;'));
ratio_GG=WantedDisplaySize./size(Frame_G);
ratio_GR=WantedDisplaySize./size(Frame_G);
ratio_RR=WantedDisplaySize./size(Frame_G);
ratio_BB=WantedDisplaySize./size(Frame_B);
        
    function GetBindingMatrix()
        BGG=evalin('base',strcat(Name,...
            '.Green_Channel_In_Green_Laser.Binding;'));
        BGR=evalin('base',strcat(Name,...
            '.Red_Channel_In_Green_Laser.Binding;'));
        BRR=evalin('base',strcat(Name,...
            '.Red_Channel_In_Red_Laser.Binding;'));
        BBB=evalin('base',strcat(Name,...
            '.Blue_Channel_In_Blue_Laser.Binding;'));
        
        if ~isempty(BGG)
            Active_Fluophores_GG=fieldnames(BGG);
        else
            Active_Fluophores_GG={};
        end
        if ~isempty(BGR)
            Active_Fluophores_GR=fieldnames(BGR);
        else
            Active_Fluophores_GR={};
        end
        if ~isempty(BRR)
            Active_Fluophores_RR=fieldnames(BRR);
        else
            Active_Fluophores_RR={};
        end
        if ~isempty(BBB)
            Active_Fluophores_BB=fieldnames(BBB);
        else
            Active_Fluophores_BB={};
        end
        Active_Fluophores=unique(cat(1,Active_Fluophores_GG,...
            Active_Fluophores_GR, Active_Fluophores_RR,Active_Fluophores_BB));
        if ~iscell(Active_Fluophores)
            Active_Fluophores={Active_Fluophores};
        end
        Active_Fluophores=cat(1,Active_Fluophores,'All');
        
        BindingMats={};
        for i=1:numel(Active_Fluophores)-1
            Mat=[];
            if ismember(Active_Fluophores{i},Active_Fluophores_GG)
                Mat=eval(strcat('BGG.',Active_Fluophores{i}));
            end
            if ismember(Active_Fluophores{i},Active_Fluophores_GR)
                MatGR=BGR.Active_Fluophores{i};
                if isempty(Mat)
                    Mat=MatGR;
                else
                    Mat=Mat+MatGR;
                end
            end
            if ismember(Active_Fluophores{i},Active_Fluophores_RR)
                MatRR=BRR.Active_Fluophores{i};
                if isempty(Mat)
                    Mat=MatRR;
                else
                    Mat=Mat+MatRR;
                end
            end
            if ismember(Active_Fluophores{i},Active_Fluophores_BB)
                MatBB=BBB.Active_Fluophores{i};
                if isempty(Mat)
                    Mat=MatBB;
                else
                    Mat=Mat+MatBB;
                end
            end
            BindingMats=cat(1,BindingMats,{logical(Mat)});
        end
        if ~isempty(BindingMats)
            BM=BindingMats{1};
            if numel(BindingMats)>2
                for i=2:numel(BindingMats)
                    if ~isempty(BindingMats{i})
                        BM=BM+BindingMats{i};
                    end
                end
            end
            BM=logical(BM);
        else
            BM={};
        end
        BindingMats=cat(1,BindingMats,BM);
        Active_Fluophores=cat(1,Active_Fluophores,' '); 
    end
%%
    function PlayVideo(~,~)
        q=questdlg('Do you want to play the video','yes','yes','no','no');
        if strcmp(q,'yes')
            Video_raw=evalin('base',strcat(Name,'.FullPath'));
            try
                Video=TifSample(Video_raw);
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
                %Use Imagej rather than matlab implay
                %handle=implay(mat2gray(Video));
                %handle.Visual.ColorMap.MapExpression='bone';
                javaaddpath 'C:\Program Files\MATLAB\R2014b\java\jar\mij.jar';
                javaaddpath 'C:\Program Files\MATLAB\R2014b\java\jar\ij.jar';
                MIJ.start('C:\Program Files\ImageJ\plugins');
                MIJ.run('Open...', strcat(strcat('path=[',Video_raw),']'));
                try
                    offset = evalin('base','videoOffset');
                catch
                    offset = 25;
                end    
                xpos = POS_GG{1,1}(1,1) - offset;
                ypos = POS_GG{1,1}(1,2) - offset;
                if xpos < 0
                    xpos = 0;
                end
                if ypos < 0
                    ypos = 0;
                end    
                [rows,columns] = size(POS_GG);
                width = POS_GG{1,columns}(1,1) - xpos + offset;
                if xpos + width > 512
                    width = 512 - xpos;
                end
                height = POS_GG{rows,1}(1,2) - ypos + offset;
                if ypos + height > 512
                    height = 512 - ypos;
                end    
                MIJ.run('Specify...',strcat('width=',num2str(width),' height=',num2str(height),' x=',num2str(xpos),' y=',num2str(ypos)));
                MIJ.run('Duplicate...','duplicate');
                MIJ.run('Grid Overlay',strcat('tile_width=',num2str(width/columns),' tile_height=',num2str(height/rows)));
            end
        end
    end
%%
% get binding matrix
Active_Fluophores_GG=''; BindingMats={}; BM={}; v=viscircles([],[]);
GetBindingMatrix;

%%

uicontrol('Style','popup','String',Active_Fluophores,...
    'Position',[20,20,200,20],'Callback',@ShowBinding,...
    'Value',numel(Active_Fluophores));

    function ShowBinding(a,~)
        try
            id=get(a,'value');
            try
                delete(v);
            catch
            end
            if id<numel(Active_Fluophores)
                Matrix=BindingMats{id};
                Prime={};
                if isempty(Prime) && ~isempty(POS_GG)
                    Prime=POS_GG(Matrix);
                end
                if isempty(Prime) && ~isempty(POS_GR)
                    POS_GR(Matrix);
                end
                if isempty(Prime) && ~isempty(POS_RR)
                    POS_RR(Matrix)
                end
                if isempty(Prime) && ~isempty(POS_BB)
                    POS_BB(Matrix)
                end
                axes(ax); hold on;
                Yellow_Circles=cell2mat(Prime(:));
                v=viscircles(Yellow_Circles,round(R+2).*...
                    ones(size(Yellow_Circles,1),1),'EdgeColor','y');
            end
        catch
            warning('No binding matrix found.');
        end
    end
%..........................................................................
%%
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

    function CreateButton(Position,ratio)
        if ~isempty(Position)          
            uicontrol(f,'style','radiobutton','Position',...
                [Position(1)*ratio(2)+Offset_x-10,Lim_y(2)*ratio(1)-Position(2)*ratio(1)+Offset_y-10,14,14],'Callback',...
                @(a,b)PitSelected(a,b,Position,1));
        end
    end

    function PitSelected(a,~,z,Show)
        try
            aaa=get(a,'Value');
        catch
            aaa=a;
        end
        if aaa==1 %get(a,'Value')
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
                    'ShowMePitVSTraces(%s,%d,%d,''Green'',''Green'',%d);',...
                    Name,r,c,Show);
                evalin('base',Action);
            end
            if sum(PGR(:))==1
                [r,c]=find(PGR);
                Action=sprintf(...
                    'ShowMePitVSTraces(%s,%d,%d,''Red'',''Green'',%d);',...
                    Name,r,c,Show);
                evalin('base',Action);
            end
            if sum(PRR(:))==1
                [r,c]=find(PRR);
                Action=sprintf(...
                    'ShowMePitVSTraces(%s,%d,%d,''Red'',''Red'',%d);',...
                    Name,r,c,Show);
                evalin('base',Action);
            end
            if sum(PBB(:))==1
                [r,c]=find(PBB);
                Action=sprintf(...
                    'ShowMePitVSTraces(%s,%d,%d,''Blue'',''Blue'',%d);',...
                    Name,r,c,Show);
                evalin('base',Action);
            end
        else
        end
    end

%% Pos_GG
if ~isempty(POS_GG)
    cellfun(@(x)CreateButton(x,ratio_GG),POS_GG);
end
%% Pos_GR
if ~isempty(POS_GR)
    cellfun(@(x)CreateButton(x,ratio_GR),POS_GR);
end
%% Pos_RR
if ~isempty(POS_RR)
    cellfun(@(x)CreateButton(x,ratio_RR),POS_RR);
end
%% Pos_BB
if ~isempty(POS_BB)
    cellfun(@(x)CreateButton(x,ratio_BB),POS_BB);
end
% knnsearch
%% UITABLE
    function AssignBindingMatrixToTable()
        if isempty(BM)
            %     Size1=size(POS_GG); Size2=size(POS_GR); Size3=size(POS_RR); Size4=size(POS_BB);
            Data_Binding=zeros(size(POS_GG)); % consider each case
        else
            Data_Binding=BM;
        end
    end
Data_Binding={}; 
AssignBindingMatrixToTable;
t=uitable('Data',logical(Data_Binding),'ColumnEditable',true,...
    'Position',[x(1)+x(3)+50,x(2),30*size(Data_Binding,2)+50,...
    20*size(Data_Binding,1)+50],'ColumnWidth',{30},...
    'CellEditCallback', @SetBindingMatrix);
    function SetBindingMatrix(~,a)
        Indices=a.Indices; NewData=a.NewData;
        for r=1:numel(BindingMats)
            BindingMats{r}(Indices(1),Indices(2))=NewData; % consider # of active fluophores
        end
    end
%%Clear Selection
    function ClearSelection(~,~)
        Empty_Table = zeros(size(Data_Binding,1),(size(Data_Binding,2)));
        set(t,'Data',logical(Empty_Table));
    end    
%%
uicontrol('callback',@AssignBindingLevel,...
    'Position',[x(1)+x(3)+200, x(2)+20*size(Data_Binding,1)+50,100,50],'string','Binding Level');
questions=cell(1,2); questions{1}='Enter value'; questions{2}='Enter order';

    function AssignBindingLevel(~,~)
        answers=inputdlg(questions,'',1);
        a=cellfun(@(x)~isempty(x),answers);
        if iscell(a)
            a=cell2mat(a);
        end
        a=sum(a);
        if a==2
            level=str2double(answers{1})*10^(str2double(answers{2}));
            expression=sprintf('%s.GiveMeBindingStatistics(0,%f);',Name,level);
            evalin('base',expression);
            GetBindingMatrix;
            AssignBindingMatrixToTable;
            set(t,'Data',Data_Binding);
        end
    end
%%
    function SetVideoGridOffset(~,~)
        answer = inputdlg('Offset:');
        assignin('base','videoOffset',answer{1});
    end
    function CloseVideos(~,~)
        MIJ.closeAllWindows;
        MIJ.exit;
    end    
%%
uicontrol('Callback',@SaveBinding,...
    'Position',[x(1)+x(3)+350, x(2)+20*size(Data_Binding,1)+50,100,50],'string','Save');
    function SaveBinding(~,~)
        ghost_var='GhostBindingMatrices';
        g=evalin('base',sprintf('exist(''%s'')',ghost_var));
        if g==1
            h=1;
            while g==1
                ghost_var_prime=strcat(ghost_var,'_',num2str(h));
                g=evalin('base',sprintf('exist(''%s'')',ghost_var_prime));
                h=h+1;
            end
            ghost_var=ghost_var_prime;
        end
        assignin('base',ghost_var,BindingMats);
        for k=1:numel(Active_Fluophores_GG)
            expr=sprintf(...
                '%s.Green_Channel_In_Green_Laser.Binding.%s=%s{%d}',...
                Name,Active_Fluophores_GG{k},ghost_var,k);
            evalin('base',expr);
        end
        evalin('base',sprintf('clear(''%s'')',ghost_var));
        SavePitSamples([],[]);
        try
        MIJ.closeAllWindows;
        MIJ.exit;
        catch
        end
    end
%%
F=figure('Menubar','none','Toolbar','figure','Numbertitle','off','Name',...
    'Binding Visualization Tool','colormap',colormap('bone'),'Position',...
    [2500,200,1200,700]);
u1=uipanel('visible','on');
try
    h1=copyobj(get(f,'Children'),u1,'legacy');
catch
    h1=copyobj(get(f,'Children'),u1);
end
t=findall(h1,'type','uitable');
close(f); ax=findall(u1,'type','axes');
u2=uipanel('visible','off');
try
    copyobj(get(NewFigs(1),'Children'),u2,'legacy');
catch
    copyobj(get(NewFigs(1),'Children'),u2);
end
close(NewFigs(1));
u3=uipanel('visible','off');
try
    copyobj(get(NewFigs(2),'Children'),u3,'legacy');
catch
    copyobj(get(NewFigs(2),'Children'),u3);
end
close(NewFigs(2));
% ax1=findall(get(u1,'children'),'type','axes'); % had to remove this!
% for w=1:numel(ax1)
%     shading(ax1(w),'interp');
% end
% ax2=findall(get(u2,'children'),'type','axes');
% for w=1:numel(ax2)
%     shading(ax2(w),'interp');
% end
% ax3=findall(get(u3,'children'),'type','axes');
% for w=1:numel(ax3)
%     shading(ax3(w),'interp');
% end
U=uimenu('Label','Select Panel');
uimenu(U,'Label','Select Pits','Callback',@setpanel,'Separator','on');
uimenu(U,'Label','Illumination Profile','Callback',@setpanel);
uimenu(U,'Label','Collapsed Frames','Callback',@setpanel)
Z=uimenu('Label','Colormap');
uimenu(Z,'Label','Bone','Callback',@setColormap);
uimenu(Z,'Label','Jet','Callback',@setColormap);
uimenu(Z,'Label','Hot','Callback',@setColormap);
uimenu(Z,'Label','Blue','Callback',@setColormap);
blue_change=0:0.05:1; blue_change=blue_change(:);
Map_Blue=cat(2,zeros(size(blue_change)),...
    zeros(size(blue_change)),blue_change);
    function setColormap(a,~)
        String=get(a,'label');
        if strcmp(String,'Blue')
            set(F,'Colormap',colormap(Map_Blue));
        else
            set(F,'Colormap',colormap(String));
        end
    end
uimenu('Label','Play Video','Callback',@PlayVideo);
uimenu('Label','Histograms','Callback',@ShowHistograms);
    function setpanel(a,~)
        my_label=get(a,'label');
        switch my_label
            case 'Select Pits'
                set(u2,'visible','off');
                set(u3,'visible','off');
                set(u1,'visible','on');
            case 'Collapsed Frames'
                set(u1,'visible','off');
                set(u3,'visible','off');
                set(u2,'visible','on');
            case 'Illumination Profile'
                set(u1,'visible','off');
                set(u2,'visible','off');
                set(u3,'visible','on');
        end
    end
%%
uimenu('Label','Check Binding Events','Callback',@VisualizationBinding);
    function VisualizationBinding(~,~)
        [S1,S2]=size(POS_GG);
        for s1=1:S1
            for s2=1:S2
                [Selection,ok]=listdlg('ListString',{'Continue','Quit'});
                if ok==1 && Selection==1
                    DetectBinding(POS_GG{s1,s2})
                else
                    return;
                end
            end
        end
    end
    function DetectBinding(My_Position)
        PitSelected(1,0,My_Position,-1); my_figure=gcf;
        uicontrol('style','popup','String',{'No','Yes'});
        waitfor(my_figure);
    end
uimenu('Label','Clear Pit Selections','Callback',@ClearSelection);
uimenu('Label','Close Videos','Callback',@CloseVideos);
uimenu('Label','Set Video Grid Offset','Callback',@SetVideoGridOffset);
end

