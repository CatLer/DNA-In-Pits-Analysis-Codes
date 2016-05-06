function[Array3D]=Packing(Array3D,Packsize)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if size(Array3D,3)>1 || Packsize==1
    Rem=mod(size(Array3D,3),Packsize);
    Number=floor(size(Array3D,3)/Packsize);
    Array3Dprime=Array3D(:,:,1:end-Rem);
    Array3Dprime=reshape(Array3Dprime,size(Array3Dprime,1),...
        size(Array3Dprime,2),Packsize,Number);
    Array3Dprime=sum(Array3Dprime,3);
    Array3Dprime=reshape(Array3Dprime,size(Array3Dprime,1),...
        size(Array3Dprime,2),Number,1);
    Array3D=Array3Dprime;
else
    return;
end
end
