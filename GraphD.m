function [output,T,S,D] = GraphD(DiffusionCoefficients,Speeds,OBJT,LENST)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
LT=cellfun(@(x)strrep(x,'p','.'),LENST,'UniformOutput',false);
OT=cellfun(@(x)strrep(x,'p','.'),OBJT,'UniformOutput',false);
T=cellfun(@(x,y)mean([str2double(x),str2double(y)]),OT,LT,'UniformOutput',false);
D=cellfun(@(x)trimmean(x,10),DiffusionCoefficients,'UniformOutput',false);
S=cellfun(@(x)trimmean(x,10),Speeds,'UniformOutput',false);
output=cat(2,OT,LT,T,DiffusionCoefficients,D,Speeds,S);
output{1,1}='OBJ Temperature'; output{1,2}='LENS Temperature';
output{1,3}='Average Temperature'; output{1,4}='DiffusionCoefficients';
output{1,4}='Diffusion Coefficients'; output{1,5}='Trimmed Mean (-10%)';
output{1,6}='Speeds'; output{1,7}='Trimmed Mean (-10%)';

T=cell2mat(T); D=cell2mat(D); S=cell2mat(S);
P=pdist2(T,T); P=P<=1; 

Temp=[]; Dif=[]; Spe=[];
for i=1:size(P,2)
   t=mean(T(P(:,i))); Temp=cat(1,Temp,t);
   d=trimmean(D(P(:,i)),100/sum(P(:,i))); Dif=cat(1,Dif,d);
   s=trimmean(S(P(:,i)),100/sum(P(:,i))); Spe=cat(1,Spe,s);
end
[T,Itemp,~]=unique(Temp); D=Dif(Itemp); S=Spe(Itemp);

% figure; plot(T,D,'--om')
% figure; plot(T,S,'--om')
end

