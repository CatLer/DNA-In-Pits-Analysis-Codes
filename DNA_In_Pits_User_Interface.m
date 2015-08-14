% DNA in pits User interface

function DNA_In_Pits_User_Interface()

f=figure('MenuBar', 'None', 'CloseRequestFcn', ...
    @closing_figure, 'Name', 'DNA In Pits User Interface', 'NumberTitle', 'off');
g = uimenu('Label','Select Samples');
uimenu(g,'Label','Select samples from workspace.','Tag','WSOPT',...
    'Callback',@SelectSamples);    
uimenu(g,'Label','Select samples from .mat files','Tag','COMPOPT',...
    'Callback', @SelectSamples);
B={};

%==================== SAMPLES SELECTION ===================================
%---------------------- Selection options ---------------------------------
    function SelectSamples(s,~)
        if strcmp(get(s,'Tag'),'WSOPT')
            Variables = evalin('base', 'whos(''-regexp'',''Set'')');
            Variables=Variables(strcmp('PitsSample',{Variables.class}));
            Variables={Variables.name};
            if ~isempty(Variables)
            [Selection,~] = listdlg('ListString',Variables);
            B=[B;Variables(Selection)];
            end
        else
            if strcmp(get(s,'Tag'),'COMPOPT')
            [filename, pathname] = uigetfile({'*.mat'},'Select a set');
            Variables=whos(matfile(fullfile(pathname,filename)),...
                '-regexp','Set');
            Variables=Variables(strcmp('PitsSample',{Variables.class}));
            if ~isempty(Variables)
            [Selection,~] = listdlg('ListString',Variables);
            B=[B;{Variables.name}];
            end
            % load in workspace
            end
        end
        % do a function to make copies if repeating names
    end
%--------------------------------------------------------------------------
%==========================================================================
%============================ UICONTROLS ==================================
% add uicontextmenu
%'callback'
% button group
ButtonGroup=uibuttongroup('SelectionChangeFcn',@HandleMyVisibility);
b1=uicontrol(ButtonGroup,'Style','radiobutton','Position',[10 475 300 100],...
    'String','Grid Check','FontSize',14.0);
b2=uicontrol(ButtonGroup,'Style','radiobutton','Position',[10 400 300 100],...
    'String','Background Check','FontSize',14.0);
b3=uicontrol(ButtonGroup,'Style','radiobutton','Position',[10 325 300 100],...
    'String','Intensity Traces','FontSize',14.0);
b4=uicontrol(ButtonGroup,'Style','radiobutton','Position',[10 250 300 100],...
    'String','Statistics','FontSize',14.0);
b5=uicontrol(ButtonGroup,'Style','radiobutton','Position',[10 175 300 100],...
    'String','FRET Analysis','FontSize',14.0);
b6=uicontrol(ButtonGroup,'Style','radiobutton','Position',[10 100 300 100],...
    'String','Diffusion and Tracking','FontSize',14.0);
set(ButtonGroup,'SelectedObject',[]);

uicontrol(f,'Style','pushbutton','Position',[10,625,300,50],...
    'String','Pit(s) Selection Tools','BackgroundColor','cyan',...
    'FontSize',12.0)
uicontrol(f,'Style','pushbutton','Position',[10,700,300,50],...
    'String','Sample(s) Selection Tools','BackgroundColor','green',...
    'FontSize',12.0)
uicontrol(f,'Style','pushbutton','Position',[10,775,300,50],...
    'String','Help','BackgroundColor','magenta',...
    'FontSize',12.0)
%------------------------- Handle Visibility ------------------------------
    function HandleMyVisibility(source,callbackdata)
    buttons=[GridCheck,BackgroundCheck,IntensityTraces,Stats,FretAnalysis,DiffusionTracking]; 
        set(buttons(callbackdata.NewValue-source),'Visible','on');
        set(buttons(callbackdata.OldValue-source),'Visible','off');
    end
%--------------------------------------------------------------------------
%---------------------------- GRID CHECK ----------------------------------

GridCheck = uipanel('Title','Grid Check','FontSize',12,...
             'BackgroundColor','white',...
             'Position',[.25 .1 .67 .67],'Visible','off');
%--------------------------------------------------------------------------
%------------------------- BACKGROUND CHECK -------------------------------

BackgroundCheck = uipanel('Title','Background Check','FontSize',12,...
             'BackgroundColor','white',...
             'Position',[.25 .1 .67 .67],'Visible','off');

%--------------------------------------------------------------------------
%------------------------ PITS SELECTION TOOLS ----------------------------
%--------------------------------------------------------------------------
%------------------------------ TRACES ------------------------------------

IntensityTraces = uipanel('Title','Intensity Traces','FontSize',12,...
             'BackgroundColor','white',...
             'Position',[.25 .1 .67 .67],'Visible','off');
         
%--------------------------------------------------------------------------
%---------------------------- STATISTICS ----------------------------------

Stats = uipanel('Title','Statistics','FontSize',12,...
             'BackgroundColor','white',...
             'Position',[.25 .1 .67 .67],'Visible','off');

%--------------------------------------------------------------------------
%--------------------------- FRET ANALYSIS --------------------------------

FretAnalysis = uipanel('Title','FRET analysis','FontSize',12,...
             'BackgroundColor','white',...
             'Position',[.25 .1 .67 .67],'Visible','off');

%--------------------------------------------------------------------------
%------------------------ DIFFUSION/TRACKING ------------------------------

DiffusionTracking = uipanel('Title','Diffusion and Tracking','FontSize',12,...
             'BackgroundColor','white',...
             'Position',[.25 .1 .67 .67],'Visible','off');

%--------------------------------------------------------------------------
%==========================================================================


end

 