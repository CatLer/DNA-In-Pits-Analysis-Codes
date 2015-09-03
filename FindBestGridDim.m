function [ output_args ] = FindBestGridDim(NumPits,Pairs,Input)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Factors=perms(factor(NumPits));
Possibilities=[];
for i=1:size(Factors,1)
    for j=1:size(Factors,2)
   Possibilities=cat(1,Possibilities,[prod(Factors(i,1:j)),prod(Factors(i,j+1:end))]); 
    end
end
Possibilities=unique(Possibilities,'rows')
MinDistance=min(pdist(Pairs)) 

Possibilities.*MinDistance

end

