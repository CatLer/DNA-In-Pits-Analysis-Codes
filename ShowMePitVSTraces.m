function [f1,f2] = ShowMePitVSTraces(varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

Sample=varargin{1};
row=varargin{2};
column=varargin{3};
Channel=[]; Laser=[];

if nargin>3
    Channel=varargin{4};  % 'Green' /  'Red'  /  'Blue'
    Laser=varargin{5}; % 'Green' /  'Red'  /  'Blue'
end

if ischar(Sample)
    Name=Sample;
else
    Name=inputname(1);
end

if isempty(Channel)
    List_Channel={'Green Channel','Red Channel','Blue Channel'};
    S=listdlg('ListString',List_Channel,'SelectionMode','Single');
    Channel=List_Channel(S); Channel=strrep(Channel{1},' Channel','');
end

if isempty(Laser)
    List_Laser={'Green Laser','Red Laser','Blue Laser'};
    S=listdlg('ListString',List_Laser,'SelectionMode','Single');
    Laser=List_Laser(S); Laser=strrep(Laser{1},' Laser','');
end

if isempty(Channel) || isempty(Laser)
    return;
end

POS=evalin('base',strcat(Name,sprintf(...
    '.%s_Channel_In_%s_Laser.Positions{%d,%d};',...
    Channel,Laser,row,column))); %#ok<*PFCEL>
RI=evalin('base',strcat(Name,sprintf(...
    '.%s_Channel_In_%s_Laser.Relative_Intensity(%d,%d,:);',...
    Channel,Laser,row,column)));
VAR=evalin('base',strcat(Name,sprintf(...
    '.%s_Channel_In_%s_Laser.Variance_In_Time(%d,%d,:);',...
    Channel,Laser,row,column)));
Number_Of_Molecules=evalin('base',strcat(Name,sprintf(...
    '.%s_Channel_In_%s_Laser.Sampled_Number_Of_Molecules{%d,%d};',...
    Channel,Laser,row,column)));
Sampled_Signals_On_Off=evalin('base',strcat(Name,sprintf(...
    '.%s_Channel_In_%s_Laser.Sampled_Signals_On_Off{%d,%d};',...
    Channel,Laser,row,column)));

%%
% generate colors for number of molecules
    function c=SetColor(num)
        if isnan(num)
            c='';
        else
            if num==0
                c=':db';
            end
            if num==1
                c=':dg';
            end
            if num==2
                c=':dm';
            end
            if num==3
                c=':dc';
            end
        end
    end
    function c=SetColor2(num)
        if isempty(num)
            c='';
        else
            if iscell(num)
                c=cellfun(@SetColor,num,'UniformOutput',false);
            else
                c=cell(1,length(num));
                for i=1:length(num)
                    c{i}=SetColor(num(i));
                end
            end
        end
    end
Colors=SetColor2(Number_Of_Molecules);

% plot the number of molecules
    function PlotNumMolecules(signal)
        for i=1:numel(Colors)
            if ~isempty(Colors{i})
                plot(ceil(Sampled_Signals_On_Off(i,1)):...
                    floor(Sampled_Signals_On_Off(i,2)),...
                    signal(ceil(Sampled_Signals_On_Off(i,1)):...
                    floor(Sampled_Signals_On_Off(i,2)),:),Colors{i},...
                    'MarkerSize',3);
            end
        end
    end
%%
Video=evalin('base',strcat(Name,'.FullPath'));
try
    Video=TifSample(Video);
catch
    try
        [filename,pathname]=uigetfile('*.tif');
        if filename==0
            error('!');
        end
        Video=TifSample(fullfile(pathname,filename));
        str=strcat(Name,'.FullPath=','''',fullfile(pathname,filename),'''');
        evalin('base',str);
    catch
        Video=[];
    end
end

%%
f1=figure('Visible','off');
c = uicontextmenu;

% p1=subplot(2,1,1);  hold on;
% try
%     levels=statelevels(permute(RI,[3,2,1]),100,'mean');
%     line(get(gca,'xLim'),[1,1]*levels(1),'Color',[0.8,0.8,0.8]);
%     line(get(gca,'xLim'),[1,1]*levels(2),'Color',[0.8,0.8,0.8]);
% catch
% end
% plot(permute(RI,[3,2,1]),'k');
% PlotNumMolecules(permute(RI,[3,2,1])); % UNCOMMENT THIS FOR COLORS
% title(sprintf('Pit(%d,%d)',row,column),'fontsize',14);
% xlabel('Frame Number','fontsize',12);
% ylabel('Spatial Average','fontsize',12);
% try
%     set(gca,'yLim',[min(RI),max(RI)]);
% catch
% end
% set(p1,'UIContextMenu',c);

p2=subplot(2,1,1); hold on;
try
    levels=statelevels(permute(VAR,[3,2,1]),100,'mean');
    line(get(gca,'xLim'),[1,1]*levels(1),'Color',[0.8,0.8,0.8]);
    line(get(gca,'xLim'),[1,1]*levels(2),'Color',[0.8,0.8,0.8]);
catch
end
plot(permute(VAR,[3,2,1]),'k');
PlotNumMolecules(permute(VAR,[3,2,1])); % UNCOMMENT THIS FOR COLORS
% title(sprintf('Pit(%d,%d)',row,column),'fontsize',14);
xlabel('Frame Number','fontsize',12);
ylabel('Spatial Variance','fontsize',12);
try
    set(gca,'yLim',[min(VAR),max(VAR)]);
catch
end
set(p2,'UIContextMenu',c);

%Plot Median Filtered Variance
p3=subplot(2,1,2); hold on;
try
    levels=statelevels(permute(VAR,[3,2,1]),100,'mean');
    line(get(gca,'xLim'),[1,1]*levels(1),'Color',[0.8,0.8,0.8]);
    line(get(gca,'xLim'),[1,1]*levels(2),'Color',[0.8,0.8,0.8]);
catch
end


plot(medfilt1(permute(VAR,[3,2,1]),20),'k');
PlotNumMolecules(permute(VAR,[3,2,1])); % UNCOMMENT THIS FOR COLORS
% title(sprintf('Pit(%d,%d)',row,column),'fontsize',14);
xlabel('Frame Number','fontsize',12);
ylabel('Filtered Spatial Variance','fontsize',12);
try
    set(gca,'yLim',[min(VAR),max(VAR)]);
catch
end
set(p3,'UIContextMenu',c);
%--------------------------------------------------------------------------

uimenu(c,'Label','Change x limits','Callback',@setLim);
uimenu(c,'Label','Change y limits','Callback',@setLim);

    function setLim(source,~)
        switch get(source,'Label')
            case 'Change x limits'
                try
                    x=get(gca,'xLim');
                    x_prime=inputdlg({'Enter minimum x',...
                        'Enter maximum x'},'Set x limits');
                    if ~isempty(x_prime)
                        if ~isempty(x_prime{1})
                            x(1)=str2double(x_prime{1});
                        end
                        if ~isempty(x_prime{2})
                            x(2)=str2double(x_prime{2});
                        end
                        set(gca,'xLim',x);
                    end
                catch
                    msgbox('Please, try again.');
                end
            case 'Change y limits'
                try
                    y=get(gca,'yLim');
                    y_prime=inputdlg({'Enter minimum y',...
                        'Enter maximum y'},'Set y limits');
                    if ~isempty(y_prime)
                        if ~isempty(y_prime{1})
                            y(1)=str2double(y_prime{1});
                        end
                        if ~isempty(y_prime{2})
                            y(2)=str2double(y_prime{2});
                        end
                        set(gca,'yLim',y);
                    end
                catch
                    msgbox('Please, try again.');
                end
        end
    end

% get(p1,'Position')
% get(p2,'Position')

%%
if nargin>5 && varargin{6}>0
    R=evalin('base',strcat(Name,'.Pit_Radius'))+2;
    evalin('base',strcat(Name,'.GridCheck')); hold on;
    viscircles(POS,R,'EdgeColor','m'); hold off;
    title(strcat('Collapsed frames - ', Name),'interpreter','none');
    f2=gcf; set(f2,'Visible','off');
    
    if ~isempty(Video)
        V=Video(max(1,round(POS(2)-R)):min(size(Video,1),round(POS(2)+R)),...
            max(1,round(POS(1)-R)):min(size(Video,2),round(POS(1)+R)),:);
        W=5;
        n=floor(size(V,3)/W); V=V(:,:,1:n*W);
        V=reshape(V,size(V,1),size(V,2),W,n);
        V=sum(V,3); V=squeeze(V);
    else
        V=[];
    end
    % handle=implay(mat2gray(V),2*W);
    % try
    % handle.Visual.ColorMap.MapExpression='jet';
    % catch
    %     warning('Cannot Change ColorMap');
    % end
    % try
    % handle.Visual.Axes.Position=[100,100,4*size(V,2),4*size(V,1)];
    % catch
    %     warning('Cannot Zoom In');
    % end
    
    set(f1,'Visible','on'); set(f2,'Visible','on');
    if ~isempty(V)
        uicontrol('Parent',f2,'String','Save A Video Of The Pit',...
            'Callback',@SaveMe,'Position',[20,20,200,20]);
    end
else
    set(f1,'Visible','on');
end
    function SaveMe(~,~)
        A=findall(0,'type','figure');
        %     set(f1,'Visible','off'); set(f2,'Visible','off');
        for i=1:numel(A)
            set(A(i),'Visible','off');
        end
        %     figure;
        PitAvi(V,Name);
        %     set(f1,'Visible','on'); set(f2,'Visible','on');
        for i=1:numel(A)
            set(A(i),'Visible','on');
        end
    end
end

