function varargout = Welcome(varargin)
% WELCOME MATLAB code for Welcome.fig
%      WELCOME, by itself, creates a new WELCOME or raises the existing
%      singleton*.
%
%      H = WELCOME returns the handle to a new WELCOME or the handle to
%      the existing singleton*.
%
%      WELCOME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WELCOME.M with the given input arguments.
%
%      WELCOME('Property','Value',...) creates a new WELCOME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Welcome_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Welcome_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Welcome

% Last Modified by GUIDE v2.5 28-Aug-2015 12:23:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Welcome_OpeningFcn, ...
                   'gui_OutputFcn',  @Welcome_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Welcome is made visible.
function Welcome_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Welcome (see VARARGIN)

% Choose default command line output for Welcome
handles.output = hObject;
%Stores folder name which user selects, current directory as default
[status,folderPath] = system('cd');
set(handles.FolderName,'String',folderPath);        %update FolderName Static text box
handles.folder = folderPath;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Welcome wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Welcome_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in NewGridReg.
function NewGridReg_Callback(hObject, eventdata, handles)
% hObject    handle to NewGridReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%ask user to select file for Empty Grid
emptyDlg = questdlg(sprintf('Please Select:\nEmpty Grid Movie'),'Empty Grid Movie','Select Movie','Cancel','Select Movie');
switch(emptyDlg)
    case 'Select Movie'
        set(gcf,'Pointer','watch');
        [emptyFileName,emptyPathName] = uigetfile('*.tif','Empty Grid Movie',handles.folder);
        set(gcf,'Pointer','arrow');
        if ~emptyFileName
            return;
        end    
        sEmptyPath = strcat(emptyPathName,emptyFileName);
    otherwise
        return;
end

%ask user to select file for Non Empty Grid
nonEmptyDlg = questdlg(sprintf('Please Select:\nNon Empty Grid Movie'),'Non Empty Grid Movie','Select Movie','Cancel','Select Movie');
switch(nonEmptyDlg)
    case 'Select Movie'
        set(gcf,'Pointer','watch');
        [nonEmptyFileName,nonEmptyPathName] = uigetfile('*.tif','Non Empty Grid Movie',handles.folder);
        set(gcf,'Pointer','arrow');
        if ~nonEmptyFileName
            return;
        end   
        sNonEmptyPath = strcat(nonEmptyPathName,nonEmptyFileName);
    otherwise
        return;
end
%Ask user to confirm, call GridRegistration.m to register grid
gridProceedAns = questdlg(sprintf('Proceed with Grid Registration in \n%s?',handles.folder),'Confirm','Yes','No','Yes');
switch(gridProceedAns)
    case'Yes'
        close all;
        emptyTif = TifSample(sEmptyPath);
        if isempty(emptyTif)
            Welcome();
            return;
        end
        nonEmptyTif = TifSample(sNonEmptyPath);
        if isempty(nonEmptyTif)
            Welcome();
            return;
        end
        status = GridRegistration(emptyTif,nonEmptyTif,handles.folder);
        if status
            analysisProceedAns = questdlg(sprintf('Grid Registration Sucessful \n Proceed with Analysis?'),'Confirm','Yes','No','Yes');
            switch(analysisProceedAns)
                case'Yes'
                    DNA_In_Pits_Analysis(handles.folder);
                case'No'
                    return;
            end
        end    
    case'No'
        return;
end

% --- Executes on button press in ExistingGrid.
function ExistingGrid_Callback(hObject, eventdata, handles)
% hObject    handle to ExistingGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check to see if existing grid 'GridRegistration.mat' file present, allows user to select a file is not present and copy to select folder, analyze if present. 
searchResult = dir(strcat(handles.folder,'\GridRegistration.mat'));
if  isempty(searchResult)
    gridAns = questdlg(sprintf('GridRegistration.mat not found in:\n%s. \nSelect file?',handles.folder),'GridRegistration.mat not found','Select File','Cancel','Select File');
    switch(gridAns)
        case 'Select File'
            [gridFileName,gridPathName] = uigetfile('*.mat','Select GridRegistration.mat File',handles.folder);
            if ~gridFileName
                return;
            end  
            sourceFile = strcat(gridPathName,gridFileName);    
            copyfile(sourceFile,handles.folder);            %copy user selected file to selected folder
        otherwise
            return;
    end
else
    gridAns = questdlg(sprintf('GridRegistration.mat found in:\n%s. \nUse this file?',handles.folder),'GridRegistration.mat found','Use This File','Select Another File','Cancel','Use This File');
    switch(gridAns)
        case 'Select Another File'
            [gridFileName,gridPathName] = uigetfile('*.mat','Select GridRegistration.mat File',handles.folder);
            if ~gridFileName
                return;
            end    
            sourceFile = strcat(gridPathName,gridFileName);   
            copyfile(sourceFile,handles.folder);            %copy user selected file to selected folder
        case 'Use This File'     
            %do nothing, go to analyze the samples
        otherwise
            return;
    end
end
%Analyze samples with select GridRegistration
DNA_In_Pits_Analysis(handles.folder);


% --- Executes on button press in ExistingSample.
function ExistingSample_Callback(hObject, eventdata, handles)
% hObject    handle to ExistingSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SelectFolder.
function SelectFolder_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Opens window for user to select folder
set(gcf,'Pointer','watch');
folderPath = uigetdir();
if folderPath ~= 0
    handles.folder = folderPath;
    set(handles.FolderName,'String',folderPath);
end
guidata(hObject,handles);
set(gcf,'Pointer','arrow');
