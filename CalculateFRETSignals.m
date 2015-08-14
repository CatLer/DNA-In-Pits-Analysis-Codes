function [FRET_Signals,R] = CalculateFRETSignals(GREEN_Signals,RED_Signals,Int_G,Int_R)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% FRET signals
GS=mat2cell(GREEN_Signals,ones(1,size(GREEN_Signals,1)),...
    ones(1,size(GREEN_Signals,2)),size(GREEN_Signals,3));
RS=mat2cell(RED_Signals,ones(1,size(RED_Signals,1)),...
    ones(1,size(RED_Signals,2)),size(RED_Signals,3));
Offset=num2cell(round((mean(RED_Signals,3)./Int_R))-...
    round((mean(GREEN_Signals,3)./Int_G))); % in test
GS=cellfun(@(x) x-mean(x),GS,'UniformOutput',false);
RS=cellfun(@(x) x-mean(x),RS,'UniformOutput',false);
FRET_Signals=cellfun(@(x,y,z) ((x.*y.*sign(x))/(Int_G*Int_R))...
    .*abs(sign(x)-sign(y))/2+z,GS,RS,Offset,'UniformOutput',false);
FRET_Signals=cell2mat(FRET_Signals); 
% FRET_Signals(FRET_Signals<0)=0;
% Correlation coeffcients
R=cellfun(@corrcoef,GS,RS,'UniformOutput',false);
R=cell2mat(cellfun(@(x) x(1,2),R,'UniformOutput',false));
end

%-xcorr(x,y,'coeff')