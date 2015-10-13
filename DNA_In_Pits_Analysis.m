function []=DNA_In_Pits_Analysis()
%DNA_IN_PITS_ANALYSIS : Automatic analysis of the signals intensity in dual
%view (red & green channel) in the pits, containing DNA. Analyses all *.tif
%samples in the folder 'foldername'. Left hand side is the red channel and
%the right hand side is the green channel. Saves a .mat file containing all
%the analyzed samples for that folder. Saves the samples as objects with
%properties containing experimental conditions, date and time, as well as
%channel objects (red & green) containing intensities
%(absolute,background,relative) for each pit, molecular brightness,
%intensity of the corresponding fluophore, the number of fluophores
%averaged in time or at all times as well as statistics regarding their
%distribution in the pits and diffusion curves with the coefficients. Also
%returns a FRET efficiency object, containing FRET efficiency for all pits
%or selected pits for each pit and averaged. Returns a FRET analysis object
%containing FRET signals (electrocardiogram-like), aswell as correlation
%coefficients, the FRET events frequency/duration/amplitude.
%   From the sample names, deduces the experimental conditions. Some
%   properties are left to be set by the user. Creates PitsChannel objects
%   for each channel, and a FRETefficiency object and a FRETanalysis
%   object. Sets the object PitsSample.
%%                            CLASSIFICATION
%===================== COLLECT SAMPLES TO ANALYZE =========================

% CurrentFolder=pwd;
Experiment=questdlg('What Type Of Experiment Do You Want To Analyze ?',...
    'Dual View','Dual View', 'Single View', 'Single View');
if isempty(Experiment)
    return;
end
Experiment=strrep(Experiment,' ',''); % just removes space
foldername=uigetdir(pwd,'Please Select The Folder Of The Videos To Analyze');
if foldername==0
    return;
end
Grid=[];
q=questdlg('Do you want to use a predefined grid ?', 'Yes','Yes','No','No');
if isempty(q)
    return;
end
% DefaultGrid='';
if strcmp(q,'Yes')
    [FileName,PathName]=uigetfile('*.mat','Select The Grid You Want To Use');
    DefaultGrid=fullfile(PathName,FileName);
    Grid=load(DefaultGrid); Grid=Grid.varargout; 
end
%--------------------------- Detect samples -------------------------------
cd(foldername);
names=dir('*tif'); dates={names.datenum}; names={names.name};
%--------------------------------------------------------------------------

[Selection,ok] = listdlg('ListString',names); %
if ok==0
return;
else
    names=names(Selection);
    dates=dates(Selection);
end

%------------------------------ WaitBar -----------------------------------
perc=0;
h=waitbar(perc/100,'Detecting Laser Color...');
set(h, 'WindowStyle','modal', 'CloseRequestFcn','');
%--------------------------------------------------------------------------

%---------------------- Experiment classification -------------------------
namesR=cellfun(@(x)~isempty(x),regexpi(names,'Rlaser')); % red laser experiments
namesG=cellfun(@(x)~isempty(x),regexpi(names,'Glaser')); % green laser experiments
namesB=cellfun(@(x)~isempty(x),regexpi(names,'Blaser')); % blue laser experiments  % new
% shouldn't be necessary, just to make sure
if iscell(namesR) 
    namesR=cell2mat(namesR);
end
if iscell(namesG) 
    namesG=cell2mat(namesG);
end
if iscell(namesB) % new
    namesB=cell2mat(namesB);
end
Unspecified=ones(1,numel(names))-namesR-namesG-namesB;
namesG=namesG+Unspecified;
namesG=logical(namesG); namesR=logical(namesR); namesB=logical(namesB);
%--------------------------------------------------------------------------

%==========================================================================

%========================EXPERIMENTAL CONDITIONS ==========================

%------------------------------ WaitBar -----------------------------------
perc=10;
waitbar(perc/100,h,'Detecting Objective and Lens Temperatures...');
%--------------------------------------------------------------------------

%------------------------------ OBJ T -------------------------------------
SplittedNames=cellfun(@(X) strsplit(X,'_'),names,'UniformOutput',false);
Obj=cellfun(@(x) strfind(x,'Obj'),SplittedNames,'UniformOutput',false);
Obj=cellfun(@(x) find(~cell2mat(cellfun(@isempty,x,...
    'UniformOutput',false))),Obj,'UniformOutput',false);
OBJ=cell(size(names));
ObjTemp=zeros(size(OBJ));
for i=1:numel(names)
    if isempty(Obj{i})
        OBJ{i}=NaN;
        ObjTemp(i)=NaN;
    else
        OBJ{i}=SplittedNames{i}{Obj{i}};
        [startIndex,endIndex]=regexp(OBJ{i},'\d*p\d*');
        if isempty(startIndex)
            ObjTemp(i)=NaN;
        else
            ObjTemp(i)=str2double(strrep(...
                OBJ{i}(startIndex:endIndex),'p','.'));
        end
    end
end
%--------------------------------------------------------------------------

%----------------------------- LENS T -------------------------------------
Lens=cellfun(@(x) strfind(x,'Lens'),SplittedNames,'UniformOutput',false);
Lens=cellfun(@(x) find(~cell2mat(cellfun(@isempty,x,...
    'UniformOutput',false))),Lens,'UniformOutput',false);
LENS=cell(size(names));
LensTemp=zeros(size(OBJ));
for i=1:numel(names)
    if isempty(Lens{i})
        LENS{i}=NaN;
        LensTemp(i)=NaN;
    else
        LENS{i}=SplittedNames{i}{Lens{i}};
        [startIndex,endIndex]=regexp(LENS{i},'\d*p\d*');
        if isempty(startIndex)
            LensTemp(i)=NaN;
        else
            LensTemp(i)=str2double(strrep(...
                LENS{i}(startIndex:endIndex),'p','.'));
        end
    end
end
%--------------------------------------------------------------------------

%------------------------------ WaitBar -----------------------------------
perc=20;
waitbar(perc/100,h,'Detecting Try Number...');
%--------------------------------------------------------------------------

%----------------------------- TRY # --------------------------------------
Try=cellfun(@(x) strfind(x,'Try'),SplittedNames,'UniformOutput',false);
Try=cellfun(@(x) find(~cell2mat(cellfun(@isempty,x,...
    'UniformOutput',false))),Try,'UniformOutput',false);
TRY=cell(size(names));
TryNum=zeros(size(TRY));
for i=1:numel(names)
    if isempty(Try{i})
        TRY{i}=NaN;
        TryNum(i)=NaN;
    else
        TRY{i}=SplittedNames{i}{Try{i}};
        [startIndex,endIndex]=regexp(TRY{i},'\d*');
        if isempty(startIndex)
            TryNum(i)=NaN;
        else
            TryNum(i)=str2double(TRY{i}(startIndex:endIndex));
        end
    end
end
%--------------------------------------------------------------------------

%------------------------------ WaitBar -----------------------------------
perc=25;
waitbar(perc/100,h,'Detecting Concentrations...');
%--------------------------------------------------------------------------

%--------------------- Quantity of Oligo-----------------------------------
Qty=cellfun(@(x) strfind(x,'Oligo'),SplittedNames,'UniformOutput',false);
Qty=cellfun(@(x) find(~cell2mat(cellfun(@isempty,x,...
    'UniformOutput',false))),Qty,'UniformOutput',false);
QTY=cell(size(names));
qty=zeros(size(QTY));
for i=1:numel(names)
    if isempty(Qty{i})
        QTY{i}=NaN;
        qty(i)=NaN;
    else
        QTY{i}=SplittedNames{i}{Qty{i}};
        [startIndex,endIndex]=regexp(QTY{i},'\d*p\d*\w*M');
        if isempty(startIndex)
            qty(i)=NaN;
        else
            k=QTY{i}(startIndex:endIndex);
            [startIndex,endIndex]=regexp(k,'\d{1,5}p\d{1,5}');
            qty(i)=str2double(strrep(k(startIndex:endIndex),'p','.'));
        end
    end
end
%--------------------------------------------------------------------------

%--------------------- Quantity of Plasmids--------------------------------
Qty2=cellfun(@(x) strfind(x,'pUC19'),SplittedNames,'UniformOutput',false);
Qty2=cellfun(@(x) find(~cell2mat(cellfun(@isempty,x,...
    'UniformOutput',false))),Qty2,'UniformOutput',false);
QTY2=cell(size(names));
qty2=zeros(size(QTY2));
for i=1:numel(names)
    if isempty(Qty2{i})
        QTY2{i}=NaN;
        qty2(i)=NaN;
    else
        QTY2{i}=SplittedNames{i}{Qty2{i}};
        [startIndex,endIndex]=regexp(QTY2{i},'\d*p\d*\w*M');
        if isempty(startIndex)
            qty2(i)=NaN;
        else
            k=QTY2{i}(startIndex:endIndex);
            [startIndex,endIndex]=regexp(k,'\d{1,5}p\d{1,5}');
            qty2(i)=str2double(strrep(k(startIndex:endIndex),'p','.'));
        end
    end
end
%--------------------------------------------------------------------------

%------------------------------ WaitBar -----------------------------------
perc=45;
waitbar(perc/100,h,'Detecting Linking Number...');
%--------------------------------------------------------------------------

%--------------------- Linking Number -------------------------------------
LK=cellfun(@(x) strfind(x,'Lk'),SplittedNames,'UniformOutput',false);
LK=cellfun(@(x) find(~cell2mat(cellfun(@isempty,x,...
    'UniformOutput',false))),LK,'UniformOutput',false);
LKK=cell(size(names));
lk=zeros(size(LK));
for i=1:numel(names)
    if isempty(LK{i})
        LKK{i}=NaN;
        lk(i)=NaN;
    else
        LKK{i}=SplittedNames{i}{LK{i}};
        [startIndex,endIndex]=regexp(LKK{i},'Lk\d*');
        if isempty(startIndex)
            lk(i)=NaN;
        else
            k=LKK{i}(startIndex:endIndex);
            [startIndex,endIndex]=regexp(k,'Lk\d{1,2}');
            lk(i)=str2double(strrep(k(startIndex:endIndex),'p','.'));
        end
    end
end
%--------------------------------------------------------------------------

%------------------------------ WaitBar -----------------------------------
perc=50;
waitbar(perc/100,h,'Detecting Grid Size...');
%--------------------------------------------------------------------------

%------------------------------ Grid size ---------------------------------
GridSize=cellfun(@(x) strfind(x,'um'),SplittedNames,'UniformOutput',false);
GridSize=cellfun(@(x) find(~cell2mat(cellfun(@isempty,x,...
    'UniformOutput',false))),GridSize,'UniformOutput',false);
GRIDSIZE=cell(size(names));
Pitsize=zeros(size(GRIDSIZE));
for i=1:numel(names)
    if isempty(GridSize{i})
        GRIDSIZE{i}=NaN;
        Pitsize(i)=NaN;
    else
        GRIDSIZE{i}=SplittedNames{i}{GridSize{i}};
        [startIndex,endIndex]=regexp(GRIDSIZE{i},'\d*');
        if isempty(startIndex)
            Pitsize(i)=NaN;
        else
            Pitsize(i)=str2double(GRIDSIZE{i}(startIndex:endIndex));
        end
    end
end
%--------------------------------------------------------------------------

%==========================================================================

%%                              ANALYSIS
%===================== CREATE SAMPLE OBJECTS ==============================

%------------------------------ WaitBar -----------------------------------
perc=55;
waitbar(perc/100,h,'Grouping Experimental Conditions For Each Sample...');
%--------------------------------------------------------------------------

%------------------------- Define type of experiment ----------------------
% green laser experiments
names_G=names(namesG);
dates_G=dates(namesG);
ObjTemp_G=ObjTemp(namesG);
LensTemp_G=LensTemp(namesG);
TryNum_G=TryNum(namesG);
qty_G=qty(namesG);
qty2_G=qty2(namesG);
lk_G=lk(namesG);
Pitsize_G=Pitsize(namesG);
LENS_G=LENS(namesG);
TRY_G=TRY(namesG);
OBJ_G=OBJ(namesG);

% red laser experiments
% only prebleach experiments
namesRR=cellfun(@isempty,regexpi(names(namesR),'Postbleach'));
names_R=names(namesR);
names_R=names_R(namesRR);
ObjTemp_R=ObjTemp(namesR);
ObjTemp_R=ObjTemp_R(namesRR);
LensTemp_R=LensTemp(namesR);
LensTemp_R=LensTemp_R(namesRR);

% blue laser experiments  % new
names_B=names(namesB);
dates_B=dates(namesB);
ObjTemp_B=ObjTemp(namesB);
LensTemp_B=LensTemp(namesB);
TryNum_B=TryNum(namesB);
qty_B=qty(namesB);
qty2_B=qty2(namesB);
lk_B=lk(namesB);
Pitsize_B=Pitsize(namesB);
LENS_B=LENS(namesB);
TRY_B=TRY(namesB);
OBJ_B=OBJ(namesB);

% compare average T
TR=nanmean([ObjTemp_R(:),LensTemp_R(:)],2);
TG=nanmean([ObjTemp_G(:),LensTemp_G(:)],2);
TRR=createns(TR); [IDR,DeltaT]=knnsearch(TRR,TG);
% use IDR to order 
names_R=names_R(IDR);
ObjTemp_R=ObjTemp_R(IDR);
LensTemp_R=LensTemp_R(IDR);

%--------------------------------------------------------------------------

%------------------------------ WaitBar -----------------------------------
perc=70;
waitbar(perc/100,h,'Creating the PitsSample objects...');
%--------------------------------------------------------------------------

%---------------------------- Create sample -------------------------------
% for each experiment in green laser, create an object to store data

for i=1:numel(names_G)
    
%------------------------------ WaitBar -----------------------------------
t=strrep(sprintf('Green laser experiments %d/%d : %s',i,...
    numel(names_G),names_G{i}),'_','\_');
waitbar(perc/100,h,t);
%--------------------------------------------------------------------------
    
    if ~isnan(OBJ_G{i})
        OBJ_G{i}=strcat('_',OBJ_G{i});
    end
    if ~isnan(LENS_G{i})
        LENS_G{i}=strcat('_',LENS_G{i});
    end
    if ~isnan(TRY_G{i})
        TRY_G{i}=strcat('_',TRY_G{i});
    end
    tic
    mydate=datestr(dates_G{i}); mydate=strrep(mydate,' ','_');
    mydate=strrep(mydate,':','_'); mydate=strrep(mydate,'-','_');
    my_name=strcat('Set_',mydate,OBJ_G{i},LENS_G{i},TRY_G{i});
    my_name=strrep(my_name,'.','_'); % remove it just for tests
    display(my_name)
    A=PitsSample(names_G{i},Experiment,Grid);
    A.Date=datestr(dates_G{i});
    A.OBJ_T_In_Green_Laser=ObjTemp_G(i);
    A.LENS_T_In_Green_Laser=LensTemp_G(i);
    A.Try_Num=TryNum_G(i);
    A.Oligo_Concentration=qty_G(i);
    A.pUC19_Concentration=qty2_G(i);
    A.Linking_Number=lk_G(i);
    A.Pit_Size=Pitsize_G(i);
    A.Exposure_Time_In_Green_Laser=50.00;
    A.Buffer=NaN;
    toc
    % try to associate a red laser experiment for true FRET efficiency
    if ~isempty(names_R)
        if DeltaT(i)<=1
            A.RedChannelInRedLaser(names_R{i});
            A.OBJ_T_Red_Laser=ObjTemp_R(i);
            A.LENS_T_Red_Laser=LensTemp_R(i);
            A.Exposure_Time_In_Red_Laser=50.00;
            CalculateFRETWithRedLaser(A.FRET_Efficiency,...
                A.Red_Channel_In_Green_Laser.Time_Average_Intensity,...
                A.Red_Channel_In_Red_Laser.Time_Average_Intensity,...
                1,1,1);
        else
            warning('No red laser experiment could be associated with this sample.')
        end
    else
        warning('No red laser experiment could be associated with this sample.')
    end
    assignin('base',my_name,A);
end
%--------------------------------------------------------------------------

for i=1:numel(names_B)
    
%------------------------------ WaitBar -----------------------------------
t=strrep(sprintf('Blue laser experiments %d/%d : %s',i,...
    numel(names_B),names_B{i}),'_','\_');
waitbar(perc/100,h,t);
%--------------------------------------------------------------------------

    if ~isnan(OBJ_B{i})
        OBJ_B{i}=strcat('_',OBJ_B{i});
    end
    if ~isnan(LENS_B{i})
        LENS_B{i}=strcat('_',LENS_B{i});
    end
    if ~isnan(TRY_B{i})
        TRY_B{i}=strcat('_',TRY_B{i});
    end
    tic
    mydate=datestr(dates_B{i}); mydate=strrep(mydate,' ','_');
    mydate=strrep(mydate,':','_'); mydate=strrep(mydate,'-','_');
    my_name=strcat('Set_',mydate,OBJ_B{i},LENS_B{i},TRY_B{i});
    my_name=strrep(my_name,'.','_'); % remove it just for tests
    display(my_name)
    A=PitsSample(names_B{i},Experiment,Grid);
    A.Date=datestr(dates_B{i});
    A.OBJ_T_In_Blue_Laser=ObjTemp_B(i);
    A.LENS_T_In_Blue_Laser=LensTemp_B(i);
    A.Try_Num=TryNum_B(i);
    A.Oligo_Concentration=qty_B(i);
    A.pUC19_Concentration=qty2_B(i);
    A.Linking_Number=lk_B(i);
    A.Pit_Size=Pitsize_B(i);
    A.Exposure_Time_In_Blue_Laser=50.00;
    A.Buffer=NaN;
    toc
    assignin('base',my_name,A);
end

%==========================================================================

%========================= SAVE SAMPLES ===================================

%------------------------------ WaitBar -----------------------------------
perc=95;
waitbar(perc/100,h,'Saving Variables Generated In Workspace...');
%--------------------------------------------------------------------------

%----------------------- Save to mat file ---------------------------------
name=datestr(now); name=strrep(name,':','_'); name=strrep(name,'-','_');
expression=sprintf('save(''Samples analyzed on %s'')',name);
evalin('base',expression);
%--------------------------------------------------------------------------
%==========================================================================

%------------------------------ WaitBar -----------------------------------
perc=100;
waitbar(perc/100,h,'The Analysis Of The Selected Samples Is Complete.');
set(h, 'WindowStyle','modal', 'CloseRequestFcn','closereq');
%--------------------------------------------------------------------------

% IF THERE IS AN ISSUE THE WAITBAR OR ANY FIGURE (CANT BE CLOSED), PLEASE 
% USE :     
%                       delete(findall(0)); 


end

