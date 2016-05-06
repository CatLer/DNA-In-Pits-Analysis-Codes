function [LOWER_BOUND,UPPER_BOUND,Average,SampledAverage,...
    SampledVariance,OnOff] = SamplingSignals(average,variance)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
warning('off','all');

average=average(:); variance=variance(:);
ID=isnan(average)|isnan(variance);
T=1:numel(average); T(ID)=[]; average(ID)=[]; variance(ID)=[];


if numel(T)>1
    
% [~,LTR,UTR]=risetime(average,T);[~,LTF,UTF]=falltime(average,T);
% StopSignal=cat(1,LTR(:),UTF(:),length(average)); StopSignal=sort(StopSignal);
% StartSignal=cat(1,1,UTR(:),LTF(:)); StartSignal=sort(StartSignal);

[~,StopSignal,StartSignal]=FindLevelsInSignal(average,-1);

SampledAverage=cell(1,length(StopSignal));
SampledVariance=cell(1,length(StopSignal));
OnOff=[StartSignal(:),StopSignal(:)];

for i=1:length(StopSignal)
    SampledAverage{1,i}=average(StartSignal(i):StopSignal(i));
    SampledVariance{1,i}=variance(StartSignal(i):StopSignal(i));
end


Average=cellfun(@mean,SampledAverage,'UniformOutput',false);
LEVELS=cellfun(@(x)FindLevelsInSignal(x,-1),SampledVariance,...
    'UniformOutput',false);
% DefineStateLevels

LOWER_BOUND=cellfun(@(x)GetLevel(x,-1),LEVELS);
UPPER_BOUND=cellfun(@(x)GetLevel(x,1),LEVELS);

else
    
    LOWER_BOUND={}; UPPER_BOUND={}; Average={};
    SampledAverage={}; SampledVariance={}; OnOff={};
    
end

warning('on','all');

%     function Levels=DefineStateLevels(sample)
%         if length(sample)>1
%             Levels=statelevels(sample);
%         else
%             Levels=sample*[1,1];
%         end
%     end
end
function z=GetLevel(x,which)
try
    if which<0
    z=x(1);
    else
        z=x(end);
    end
catch
    z=NaN;
end
end
