function [Output] = SpatioTemporalCorr(Input)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
T=size(Input,3);
q=5;
Output=cell(T,q);
for i=1:T
    for j=i:min(i+q-1,T)
    Output{i,j-i+1}=xcorr2(Input(:,:,i),Input(:,:,j));
    end
end
end

