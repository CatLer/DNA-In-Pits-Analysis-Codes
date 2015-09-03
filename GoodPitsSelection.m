function [My_pits,Selected_Pits,Statistics]=GoodPitsSelection(Intensity_G,Intensity_R)
%GOODPITSELECTION : Returns a cell array containing information of each pit
%regarding the green and red fluophores present in the pit (My_pits). Also
%returns a binary matrix where 1 means selected pit and 0 means not
%selected. The selection includes chosing pits with only 1 active fluophore
%of each species, with total intensity in time greater than the background
%(positive relative intensity).
%   Calls PHOTOBLEACHING_CUT to remove photobleached portions of the
%   signals. Calculates the total intensity in time for each fluophore
%   using TRAPZ (numerical integration method). Calls
%   NUMBER_OF_MOLECULES_PER_PIT to find the number of green and red
%   fluophores in the pit. Calls FLUOPHORE_ACTIVITY_INDEX to get the
%   fluophores' activity in the pit. Store the above in the cell
%   corresponding to the pit in the array My_pits. If a pit has 1 green and
%   1 red fluophore, but alive and the relative intensity compared to the
%   background is positive, then the corresponding entry in the array
%   Selected_Pits is set to 1, otherwise, remains 0.

%************************** FIX THIS **************************************
% add intensities of fluophores
% add FRET efficiencies 
%**************************************************************************

%===================== DEFINE CRITERIA ====================================

%------------------- Leveling the signals ---------------------------------
Intensity_G = LevelingMySignals(Intensity_G);
Intensity_R = LevelingMySignals(Intensity_R);
%--------------------------------------------------------------------------

%--------------------- Photobleaching -------------------------------------
% remove photobleached fluophores signals
% using Photobleaching_cut function
% cut the signal where the GREEN/RED fluophores die
[Intensity_G,Intensity_R]=Photobleaching_cut(Intensity_G,Intensity_R);
%--------------------------------------------------------------------------

%------------------ Intensity to background -------------------------------
% find total intensity under traces and check sign
% using numerical integration
% total intensity in the GREEN channel
Total_Intensity_G=cellfun(@trapz,Intensity_G);
% total intensity in the RED channel
Total_Intensity_R=cellfun(@trapz,Intensity_R);
% GREEN fluophores intensity greater than background?
TIG_sign = sign(Total_Intensity_G);
% RED fluophores intensity greater than background?
TIR_sign = sign(Total_Intensity_R);
%--------------------------------------------------------------------------

%---------------- Number of molecules per pit -----------------------------
% find the number of molecules per pit averaged in time
% using Number_of_molecules_per_pit function
% average intensity in the GREEN channel
Average_Intensity_G=cellfun(@mean,Intensity_G); % or use trapz?
% average intensity in the RED channel
Average_Intensity_R=cellfun(@mean,Intensity_R);
% number of GREEN fluophores in the pit
[Num_G,Av_num_G,num_G,IntGFluo]=Number_of_molecules_per_pit(Average_Intensity_G);
% number of RED fluophores in the pit
[Num_R,Av_num_R,num_R,IntRFluo]=Number_of_molecules_per_pit(Average_Intensity_R);
% find the number of molecules per pit in time
%--------------------------------------------------------------------------

%-------------------- Fluophore activity ----------------------------------
% find interacting molecules 
% using cross-correlation
% GREEN fluophores activity index
Green_Fluophore_Activity=cellfun(@Fluophore_Activity_Index,Intensity_G);
% RED fluophores activity index
Red_Fluophore_Activity=cellfun(@Fluophore_Activity_Index,Intensity_R);
%--------------------------------------------------------------------------

%===================== PITS SELECTION =====================================

%------------------------ Pit's information -------------------------------
My_pits = cell(size(Intensity_G));
Selected_Pits = zeros(size(My_pits));
[My_pits{:}]=deal(cell(5,3));
for i=1:size(Intensity_G,1)
    for j=1:size(Intensity_G,2)
        My_pits{i,j}{1,1} = 'Fluophore';
        My_pits{i,j}{1,2} = 'Green';
        My_pits{i,j}{1,3} = 'Red';
        My_pits{i,j}{2,1} = 'Photobleaching Start Time';
        My_pits{i,j}{2,2} = numel(Intensity_G{i,j});
        My_pits{i,j}{2,3} = numel(Intensity_R{i,j});
        My_pits{i,j}{3,1} = 'Total Intensity';
        My_pits{i,j}{3,2} = Total_Intensity_G(i,j);
        My_pits{i,j}{3,3} = Total_Intensity_R(i,j);
        My_pits{i,j}{4,1} = 'Average Number Of Fluophores';
        My_pits{i,j}{4,2} = Num_G(i,j);
        My_pits{i,j}{4,3} = Num_R(i,j);
        My_pits{i,j}{5,1} = 'Fluophore Activity';
        My_pits{i,j}{5,2} = Green_Fluophore_Activity(i,j);
        My_pits{i,j}{5,3} = Red_Fluophore_Activity(i,j);
        % 1 molecule with 2 fluophores (RED & GREEN) alive
        if TIG_sign(i,j)*TIR_sign(i,j)>0 && ...
                Green_Fluophore_Activity(i,j)>0.1 ...
                && Red_Fluophore_Activity(i,j)>0.1 && ...
                Num_G(i,j)*Num_R(i,j)==1
            My_pits{i,j}{6,1} = 'Selected';
            Selected_Pits(i,j)=1;
        else
            My_pits{i,j}{6,1} = 'Not Selected';
        end
    end
end
%--------------------------------------------------------------------------

%---------------------- Statistics ----------------------------------------
Statistics = cell(2,2);
Statistics{1,1}='Average number of fluophores per pit';
Statistics{1,2}=cell(2,2);
Statistics{1,2}{1,1} = 'Green fluophore';
Statistics{1,2}{1,2} = cell(2,2);
Statistics{1,2}{1,2}{1,1}='Using Poisson distribution';
Statistics{1,2}{1,2}{1,2}= Av_num_G(1);
Statistics{1,2}{1,2}{2,1}='Average neglecting NaN (>3)';
Statistics{1,2}{1,2}{2,2}= Av_num_G(2);
Statistics{1,2}{2,1} = 'Red fluophore';
Statistics{1,2}{2,2} = cell(2,2);
Statistics{1,2}{2,2}{1,1}='Using Poisson distribution';
Statistics{1,2}{2,2}{1,2}= Av_num_R(1);
Statistics{1,2}{2,2}{2,1}='Average neglecting NaN (>3)';
Statistics{1,2}{2,2}{2,2}= Av_num_R(2);
Statistics{2,1}='Counts per number of fluophores';
Statistics{2,2}=cell(2,2);
Statistics{2,2}{1,1} = 'Green fluophore';
Statistics{2,2}{1,2} = num_G;
Statistics{2,2}{2,1} = 'Red fluophore';
Statistics{2,2}{2,2} = num_R;
%--------------------------------------------------------------------------

%=================== VISUALIZATION TOOL ===================================
% interactive pits grid with values of the different criteria above
% allow user input

%------------------------- UITABLE ----------------------------------------
%--------------------------------------------------------------------------
end

