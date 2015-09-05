function [Intensity_of_1_molecule,Offset] = Intensity1Molecule(Y)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
Z=[];
for i=3:7
[N,C]=hist(Y,i);
X=sort(pdist(transpose(C)));
S=[];
for j=1:numel(X)
s=mean(mod(X,X(j)));
S=cat(1,S,s);
end
[S,I]=min(S); 
Z=cat(1,Z,[C(1),X(I),S]);
end
[~,i]=min(Z(:,3));
Offset=Z(i,1);
Intensity_of_1_molecule=Z(i,2);
% subplot(1,2,1)
% hist(Y,4)
% subplot(1,2,2)
% hist(Y,i+2)
end

