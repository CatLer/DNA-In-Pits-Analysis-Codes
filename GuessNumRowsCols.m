function [Num_rows,Num_cols]=...
    GuessNumRowsCols(Num_objects, Num_rows, Num_cols)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
if Num_objects==0
    warning('No object.');
    return; 
end
D=[1; unique(cumprod(perms(factor(Num_objects)),2))];
% D=divisors(Num_objects);
[~,NR]=sort(abs(D-Num_rows));
DR=D(NR);
[~,NC]=sort(abs(D-Num_cols));
DC=D(NC);  DR=transpose(DR(:));
PosN=[]; 
for j=1:numel(DC)
    PosN=cat(1,PosN,DC(j)*DR);
end
[r,c]=find(PosN==Num_objects);
Set=[r,c];
[~,i]=min(r+c);
Set=Set(i,:);
Num_cols=DC(Set(1));
Num_rows=DR(Set(2));
end

