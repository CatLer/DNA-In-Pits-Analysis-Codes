function [number_of_molecules_per_pit,Average_number_of_molecules_per_pit,num,Intensity_1_molecule] = ...
    Number_of_molecules_per_pit(my_Pits)
%NUMBER_OF_MOLECULES_PER_PIT: Returns an array of size(my_Pits) with the
%AVERAGE number of molecules per pit (number_of_molecules_per_pit), the
%total average number of molecule per pit
%(Average_number_of_molecules_per_pit) using both poisson fit and then
%neglecting higher values, the number of pits with with each the possible
%numbers of molecules (num). num gives the counts for each value
%(0,1,2,3,>3 given by NaN). Doesn't account for photobleaching, entering
%and leaving molecules in time. This is a distribution and consequently the
%returned array may not be 100% right. Compare the number of non-empty pits
%with the sum of all frames of a video, to check for the validity.
%Non-empty pits should appear brighter. ***** Possible finer binning
%recquired ****** to be fixed
%   First stores data into bins of different order of magnitudes. Check for
%   non-uniformity in the bins; if so, stores the average intensities of
%   clusters in that bin (max number of cluster is 3). Generates new bins
%   from the previous action. If the value is greater or equal to the mean
%   intensity, it is considered to be in the bin. Approximates the
%   magnitude of the intensitity of 1 particle. Divides the input array and
%   takes the FLOOR function; returns the number of molecules per pit. Uses
%   the error given by STD on the total array as a relaxation parameter.
%   Negative values are returned as 0, and values greater than 3x the
%   intensity of 1 molecule are returned as NaN, (since 4 should occur with
%   a probability less than 5%, 5 with less than 1% and so on).
%   Difficulties :
%       1. A 'peak' can be splitted into 2 bins, the intensity would be
%       retuned as either the average of the lower 'half', or depending on
%       the number of elements of that peak found in each bin. 
%       2.
%   Suggestions :
%       1. Use PHOTOBLEACHING_CUT function to cut the intensities in each
%       pit where photobleaching occurs. Take the average in time for the
%       active portion only.
%       2. Photobleaching is also a good indicator of the number of
%       molecules. This function mixed with PHOTOBLEACHING_CUT lead to a
%       better approximation of the number of molecules in the pits,
%       featured in NUMBER_OF_MOLECULES_PER_PIT_IN_TIME.
%       3.
%   Also uses POISSFIT to determine the average number of molecules per
%   pit, and HISTC, and KSTEST for an uniform distribution test.

%==========================================================================

%======================== INITIALIZE ======================================

%-------------------- Leveling my signals ---------------------------------
% only if full signal
% my_Pits = LevelingMySignals(my_Pits);
% if iscell(my_Pits)
% my_Pits = cellfun(@mean,my_Pits);    
% else
% my_Pits = mean(my_Pits,3);
% end
%--------------------------------------------------------------------------

%-------------------- Sorting and reshaping -------------------------------
Number_of_pits = numel(my_Pits);
M = sort(my_Pits(:)); M_neg =abs(trimmean(M(M<=0),20)); M(M<0)=0;
%--------------------------------------------------------------------------

%-------------------- Order of magnitude ----------------------------------
Order = @(k,M) k.^(floor(log10(abs(M))/log10(k)));
%--------------------------------------------------------------------------

%-------------------- Expectation value -----------------------------------
% mean should relate to expected number per pit, close to 0 or 1
Expected_value = poissfit(M);
%--------------------------------------------------------------------------

%------------------------ Generate Bins -----------------------------------  
% order of magnitude
% N  : 0,1,10,100,... order of magnitude in base 10 (NOT LEVELED)
% N  : 0,1,2,4,8,16,32,... order of magnitude in base 2 (LEVELED)
N = Order(10,M); N(N<1)=0; 
try
[~,X]=kmeans(M,4); X = sort(X);
catch
    X=[];
end
binranges = unique(N); [Number,Bins] = histc(N,binranges);
%--------------------------------------------------------------------------

%==========================================================================

%========================= OPTIMIZE =======================================

%-------------------- Store data into bins --------------------------------
% generate new bins 
Bin = cell(1,numel(Number));
binranges = [];
for i=1:numel(Number)
Bin{i} = M(Bins==i);
try
% check for uniformity 
X_uni=(Bin{i}-min(Bin{i}))/(max(Bin{i})-min(Bin{i})); 
X_norm=norminv(X_uni);
h=kstest(X_norm);
if h==1
   % if non-uniform, find center
   T = clusterdata(Bin{i},'linkage','ward','maxclust',3);
   t = unique(T);
   [n,~] = histc(T,t);
   n=n>=sum(n)/3;
   t = t(n>0);
   for j=1:numel(t)
   binranges = cat(2,binranges,mean(Bin{i}(T==t(j))));
   end
end
catch
end
end
try
if numel(binranges)<=1
    [~,binranges]=kmeans(M,3);
    binranges = reshape(binranges,[1,numel(binranges)]);
end
catch
end
binranges(binranges<=M_neg)=0; binranges=cat(2,0,binranges);
binranges = unique(sort(binranges));

%-------------- Approximate the intensity of 1 molecule -------------------
s = binranges./cat(2,0,(1:numel(binranges)-1)); s = s(~isnan(s));
if std(s)/mean(s)<std(M)/mean(M) && numel(binranges)<=4
s = mean(s);
else
s = [];
end
%--------------------------------------------------------------------------

N = M;
for i=1:numel(binranges)-1
    N(N>=binranges(i) & N<binranges(i+1)) = binranges(i);
end
if ~isempty(binranges)
N(N>=binranges(end))=binranges(end);
end
[Number,~] = histc(N,binranges);

%--------------------------------------------------------------------------

%--------------------- Intensity for 1 molecule ---------------------------
if numel(Number)>1
%******************** IMPROVE THIS ****************************************
try    
% check for 'in-between' states    
% get the 2 bins with highest number of counts
[~,k] = max(Number);
[~,g]= min(abs(binranges-Expected_value));
if numel(X)>1
    X=X(2);
else
    X=[];
end
Intensity_1_molecule = trimmean([binranges(k),s,binranges(g),X],50); 
catch
    try
    [~,g]= min(abs(binranges-Expected_value));
    Intensity_1_molecule = binranges(g);
    catch
        Intensity_1_molecule = Inf;
    end
end
else
    Intensity_1_molecule = Inf; % NaN
%**************************************************************************    
end
%--------------------------------------------------------------------------

%==========================================================================

%============================ RESULTS =====================================

%------------------- Number of molecules per pit --------------------------
% introduce a relaxation parameter 
Parameter = std(my_Pits(:))/mean(my_Pits(:));
number_of_molecules_per_pit = floor(my_Pits/Intensity_1_molecule) +...
round(min(0,mod(my_Pits,Intensity_1_molecule)/Intensity_1_molecule-Parameter)); 
number_of_molecules_per_pit(number_of_molecules_per_pit<0) = 0;
number_of_molecules_per_pit(number_of_molecules_per_pit>3) = NaN;
%--------------------------------------------------------------------------

%----------------- Average number of molecules per pit --------------------
Average_number_of_molecules_per_pit = ...
    cat(2,poissfit(Number/Number_of_pits),...
    nanmean(number_of_molecules_per_pit(:)));
%--------------------------------------------------------------------------

%------------------ Counts per possible value -----------------------------
x = number_of_molecules_per_pit(:);
y = unique(x); y = y(~isnan(y));
num = histc(x,y);
num = cat(1,num,sum(isnan(x)));
num = cat(2,cat(1,y,NaN),num);
%--------------------------------------------------------------------------

%==========================================================================

% close all
% figure; hist(N,binranges)

end