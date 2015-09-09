function [] = CLASSIFY_COLLECT_PITS(foldername)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
cd(foldername);
names=dir('*tif'); dates={names.datenum}; names={names.name};
%============================= CLASSIFY ===================================
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
    ObjTemp(i)=str2double(strrep(OBJ{i}(startIndex:endIndex),'p','.'));
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
    LensTemp(i)=str2double(strrep(LENS{i}(startIndex:endIndex),'p','.'));
    end
    end
end
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
%------------------------------ Laser -------------------------------------
Laser=cellfun(@(x) strfind(x,'laser'),SplittedNames,'UniformOutput',false);
Laser=cellfun(@(x) find(~cell2mat(cellfun(@isempty,x,...
    'UniformOutput',false))),Laser,'UniformOutput',false);
LASER=cell(size(names));
% laser=zeros(size(LASER));
for i=1:numel(names)
    if isempty(Laser{i})
    LASER{i}=NaN;
%     laser(i)=NaN;   
    else
    LASER{i}=SplittedNames{i}{Laser{i}};
%     [startIndex,endIndex]=regexp(LASER{i},'\d*');
%     if isempty(startIndex)
%     laser(i)=NaN;
%     else
%     laser(i)=str2double(LASER{i}(startIndex:endIndex));
%     end    
    end
end
%--------------------------------------------------------------------------
%==========================================================================
%========================= CREATE STRUCTURES ==============================
for i=1:numel(names)
    tic
%-------------------- Generate structures with fields ---------------------
if ~isnan(LENS{i})
   LENS{i}=strcat('_',LENS{i});
end
if ~isnan(TRY{i})
    TRY{i}=strcat('_',TRY{i});
end

Input=double(TifSample(names{i}));

[Pos_R,Pos_G,Radius,num_rows,num_cols]=ConstructPitsGrid(Input); % new
[background,Background]=CalculateBackground(Input,Radius);

my_name=strcat('Set_',OBJ{i},LENS{i},TRY{i});
display(my_name)
A=struct('Green_Channel',struct(),'Red_Channel',struct());

[A.date]=deal(datestr(dates{i}));
[A.Obj_T]=deal(ObjTemp(i));
[A.Lens_T]=deal(LensTemp(i));
[A.Try_Num]=deal(TryNum(i));
[A.Oligo_Concentration]=deal(qty(i));
[A.pUC19_Concentration]=deal(qty2(i));
[A.Linking_Number]=deal(lk(i));
[A.Pit_size]=deal(Pitsize(i));
[A.Time_Per_Frame_ms]=deal(50.00);
[A.Laser]=deal(LASER{i});
[A.FRET_Efficiency]=deal([]);
[A.FRET_Efficiency.Pre_Selected]=deal([]);
[A.FRET_Efficiency.All_Pits]=deal([]);

toc

[Intensity_R,intensity_R,Background_R] = my_mask(Input,background,num_rows,num_cols,Radius,Pos_R);
[A.Red_Channel.Relative_Intensity]=deal(Intensity_R);
[A.Red_Channel.Absolute_Intensity]=deal(intensity_R);
[A.Red_Channel.Background_Intensity]=deal(Background_R);
M=Intensity_R(2:end-1,2:end-1,:); A_R=mean(M(:)); a_R=mean(M,3);
[A.Red_Channel.Mean_Intensity_In_Time]=deal(a_R);
[A.Red_Channel.Mean_Intensity]=deal(A_R);

[FluoIndex_R] = Fluophore_Activity_Index(M);
[A.Red_Channel.Fluophore_Activity]=deal(FluoIndex_R);

[N_R,N_R_T,Inf_R]=histTestM(M);
[A.Red_Channel.Mean_number_per_pit]=deal(N_R);
[A.Red_Channel.Number_per_pit_in_time]=deal(N_R_T);
[A.Red_Channel.Intensity_of_1_molecule]=deal(cell(2));
A.Red_Channel.Intensity_of_1_molecule{1,1}='Intensity';
A.Red_Channel.Intensity_of_1_molecule{1,2}='Relative error';
A.Red_Channel.Intensity_of_1_molecule{2,1}=Inf_R(1);
A.Red_Channel.Intensity_of_1_molecule{2,2}=Inf_R(2);
[A.Red_Channel.Molecular_brightness]=deal(Inf_R(3));

toc

[Intensity_G,intensity_G,Background_G] = my_mask(Input,background,num_rows,num_cols,Radius,Pos_G);
[A.Green_Channel.Relative_Intensity]=deal(Intensity_G);
[A.Green_Channel.Absolute_Intensity]=deal(intensity_G);
[A.Green_Channel.Background_Intensity]=deal(Background_G);
M=Intensity_G(2:end-1,2:end-1,:); A_G=mean(M(:)); a_G=mean(M,3);
[A.Green_Channel.Mean_Intensity_In_Time]=deal(a_G);
[A.Green_Channel.Mean_Intensity]=deal(A_G);

[FluoIndex_G] = Fluophore_Activity_Index(M);
[A.Green_Channel.Fluophore_Activity]=deal(FluoIndex_G);

[N_G,N_G_T,Inf_G]=histTestM(M);
[A.Green_Channel.Mean_number_per_pit]=deal(N_G);
[A.Green_Channel.Number_per_pit_in_time]=deal(N_G_T);
[A.Green_Channel.Intensity_of_1_molecule]=deal(cell(2));
A.Green_Channel.Intensity_of_1_molecule{1,1}='Intensity';
A.Green_Channel.Intensity_of_1_molecule{1,2}='Relative error';
A.Green_Channel.Intensity_of_1_molecule{2,1}=Inf_G(1);
A.Green_Channel.Intensity_of_1_molecule{2,2}=Inf_G(2);
[A.Green_Channel.Molecular_brightness]=deal(Inf_G(3));

toc

[A.FRET_Efficiency.Pre_Selected.Per_Pit]=deal([]);
[A.FRET_Efficiency.Pre_Selected.Average]=deal([]);
Fret=a_R./(a_R+a_G);
[A.FRET_Efficiency.All_Pits.Per_Pit]=deal(Fret);
[A.FRET_Efficiency.All_Pits.Average]=deal(mean(Fret(:)));

[A.Average_Absolute_Intensity_In_Time]=deal(mean(Input,3));
[A.Average_Background_Intensity_In_Time]=deal(mean(Background,3));
[A.Average_Relative_Intensity_In_Time]=deal(mean(Input-Background,3));

[FRET_Signals,Coefficients]=CalculateFRETSignals(Intensity_G,Intensity_R,Inf_G(1),Inf_R(1));
[A.FRET_Signals]=deal(FRET_Signals);
[A.FRET_Coefficients]=deal(Coefficients);

[diffusion_green,coeffG]=DiffusionCurve(Intensity_G);
[diffusion_red,coeffR]=DiffusionCurve(Intensity_R);
[A.Green_Channel.Diffusion_Signal]=deal(diffusion_green);
[A.Red_Channel.Diffusion_Signal]=deal(diffusion_red);
[A.Green_Channel.Diffusion_Coefficient]=deal(coeffG);
[A.Red_Channel.Diffusion_Coefficient]=deal(coeffR);

assignin('base',my_name,A);

toc

end
%==========================================================================

evalin('base','save(''Samples(1).mat'')');

end

