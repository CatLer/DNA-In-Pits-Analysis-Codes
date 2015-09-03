function [Number_per_pit,Number_per_pit_in_time,Output]=...
    histTestM(Input_signal)
%HISTTESTM : Called in NUMBER_OF_MOLECULES_PER_PIT. Time averages signal
%Input_signal. Input_signal is a MxNxT matrix or a MxNxT_i cell array for
%MxN pits with T the number of frames, T_i is the number of frames for each
%pit. 
%   Uses IMHIST and CLUSTERDATA. Tries to find patterns in the clusters
%   centers.
%============================= HISTOGRAM ==================================
%----------------------------- Initialize ---------------------------------
Output=[]; Relative_error=[];
% average signal
if iscell(Input_signal)
Input = cell2mat(cellfun(@mean,Input_signal,'UniformOutput',false));
else   
Input = mean(Input_signal,3);
end
%--------------------------------------------------------------------------
%--------------------- Generate a histogram -------------------------------
% 256 bins using grayscale
input=mat2gray(Input); 
[counts,binLocations] = imhist(input); %figure; imhist(input)
%--------------------------------------------------------------------------
%==========================================================================
%============================ CLUSTERING ==================================
%------------ Do process with different clusterings -----------------------
% use 2 to 7 clusters  (0,1/0,1,2/0,1,2,3/.../0,1,2,3,4,5,6)
for omega=2:7  
% create clusters 
    I=[];
    for j=1:numel(binLocations)
        I=cat(1,I,repmat(binLocations(j),[counts(j),1,1])*max(Input(:)));
    end
    T=clusterdata(I,'maxclust',omega,'linkage','ward'); 
    U=unique(T); bincounts=histc(T,U);
% poisson distribution
    [LAMBDAHAT, LAMBDACI] = poissfit(bincounts);
    % kstest    
% clusters centers + error
    S=[]; R=[]; 
    for j=1:numel(U)
        if bincounts(j)>1
        S=cat(2,S,mean(I(T==j)));
        R=cat(2,R,std(I(T==j)));
        end
    end    
    [S,ia]=sort(S);
    R=R(ia);
% intensity of 1 molecule using patterns   
    Z=[]; 
    for j=1:numel(S)-1
    Z=cat(1,Z,round(S/S(j)));
    end
  [~,z]=min(abs(mean(diff(Z,1,2),2)-1));
  if isempty(S(z))
  Intensity_of_1_molecule_mean = NaN;
  else
  Intensity_of_1_molecule_mean = S(z);
  end
% relative error  
Relative_error=cat(1,Relative_error,R(z)/Intensity_of_1_molecule_mean);
% accumulate 
Output=cat(1,Output,Intensity_of_1_molecule_mean);
end
%--------------------------------------------------------------------------
%==========================================================================
%============================= BEST MATCH =================================
%------------------------ find best pattern -------------------------------
% min relative error
[~,i]=min(Relative_error);
% corresponding intensity of 1 molecule
Intensity_of_1_molecule=Output(i);  
% set outliers to NaN in the input matrix
Input(round(Input/Intensity_of_1_molecule)>3)=NaN;
Input(round(Input/Intensity_of_1_molecule)<0)=0;
%--------------------------------------------------------------------------
%==========================================================================
%==================== NUMBER OF MOLECULES PER PIT =========================
%------------------- Average number of molecules per pit ------------------
Number_per_pit=round(Input/Intensity_of_1_molecule);
%--------------------------------------------------------------------------
%------------------- Number of molecules per pit in time ------------------
if iscell(Input_signal)
Number_per_pit_in_time = cell2mat(cellfun(@(x)round(x/Intensity_of_1_molecule),...
    Input_signal,'UniformOutput',false));
else   
Number_per_pit_in_time=round(Input_signal/Intensity_of_1_molecule);
end
Number_per_pit_in_time(Number_per_pit_in_time<0)=0;
%--------------------------------------------------------------------------
%==========================================================================
%=========================== SOME STATS ===================================
%---------------------- molecular brightness ------------------------------
Molecular_brightness=var(Input(~isnan(Input)))/mean(Input(~isnan(Input)))-1;  
%--------------------------------------------------------------------------
%---- Intensity of 1 molecule + relative error + molecular brightness -----
Output=[Intensity_of_1_molecule,Relative_error(i),Molecular_brightness];
%--------------------------------------------------------------------------
%---------------------------- Statistics ----------------------------------
% Stats=[unique(Number_per_pit(:)),histc(Number_per_pit(:),...
%     unique(Number_per_pit(:)))];
% Stats=cat(2,Stats,Stats(:,2)/numel(Number_per_pit));
%--------------------------------------------------------------------------
%==========================================================================
end

