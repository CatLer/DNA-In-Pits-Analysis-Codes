function [NumMols,Int1Mol] = CountMoleculesFromSampledSignals(SampledAverages)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
warning('off','all');
%------------------ put all sampled averages together ---------------------
Averages=[];
if ~isempty(SampledAverages)
    for p=1:size(SampledAverages,1)
        for q=1:size(SampledAverages,2)
            a=SampledAverages{p,q};
            if iscell(a)
                a=cell2mat(a);
            end
            Averages=cat(2,Averages,a);
        end
    end
end
Averages=sort(Averages);
%---------------------- find intensity of 1 molecule ----------------------
Output=[]; Relative_error=[];

% 256 bins using grayscale
input=Averages;
[counts,binLocations] = hist(input,256);
% figure; hist(input,256)

f=fit(binLocations(:),counts(:),'gauss4');
Coeffs=coeffvalues(f);
Means=Coeffs(2:3:11);
Sigmas=Coeffs(3:3:12);
Amps=Coeffs(1:3:10);
[~,i]=max(Amps);
Int_1=Means(i);

% clustering
for omega=2:7
    
    % create clusters
    I=[];
    for j=1:numel(binLocations)
        I=cat(1,I,repmat(binLocations(j),[counts(j),1,1]));
    end
    T=clusterdata(I,'maxclust',omega,'linkage','ward');
    U=unique(T); bincounts=histc(T,U);
    
%     % poisson distribution
%     [LAMBDAHAT, LAMBDACI] = poissfit(bincounts);
    
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

% min relative error
[~,i]=min(Relative_error);

% corresponding intensity of 1 molecule
Int1Mol=max(Output(i),Int_1);

% count number of molecules
NumMols=cellfun(@FindNumMol,SampledAverages,'UniformOutput',false);


    function Num=FindNumMol(Sample)
        if iscell(Sample)
            Num=cellfun(@(x)RoundNum(x),Sample,'UniformOutput',false);
            Num=cellfun(@RemoveAggregatesAndNegatives,Num,'UniformOutput',false);
        else
            Num=RoundNum(Sample);
            Num=RemoveAggregatesAndNegatives(Num);
        end
    end

    function x=RemoveAggregatesAndNegatives(x)
            x(x>3|x<0)=NaN;
    end

    function N=RoundNum(Num)
       N=floor(Num/Int1Mol);
       fraction=mod(Num,Int1Mol)/Int1Mol;
       if fraction>0.7;
           N=N+1;
       end
    end
warning('on','all');
end

% % cleaning
% f=fit(binLocations,counts,'gauss3');
% Coeffs=coeffvalues(f);
% MaxValue=max(Averages);
% Mean1=Coeffs(2); Width1=Coeffs(3)/sqrt(2);
% Mean2=Coeffs(5); Width2=Coeffs(6)/sqrt(2); % Maybe useful
% Mean3=Coeffs(8); Width3=Coeffs(9)/sqrt(2); % Maybe useful
% Averages(Averages>(Mean1+3*Width1)*MaxValue)=[];

% % 256 bins using grayscale - filtered
% input=mat2gray(Averages);
% [counts,binLocations] = imhist(input);
% % figure; imhist(input)