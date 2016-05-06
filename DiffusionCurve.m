function [Signal,Coefficient] = DiffusionCurve(Signal)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
N=size(Signal,3);
Signal=mat2cell(Signal,ones(1,size(Signal,1)),...
    ones(1,size(Signal,2)),size(Signal,3));
% Diffusion curve 
Signal=cellfun(@(x)xcov(x)/(mean(x)^2),Signal,'UniformOutput',false); % xcorr or xcov
Signal=cellfun(@(x)x(N:end),Signal,'UniformOutput',false);
Coefficient=cell2mat(cellfun(@FitDiffusionCurve,Signal,'UniformOutput',false));
% Normal diffusion model
    function DiffusionCoeff=FitDiffusionCurve(Signal)
    a=Signal(1,1,1); c=1;
    modelfun=@(Td,x)a*((1+x/Td).*(1+((x/Td).^0.5)*(c^(-2))));
    [beta,R,J,CovB]=nlinfit(0:N-1,permute(Signal(1,1,:),[2,3,1]),modelfun,1);
    DiffusionCoeff=1/(4*beta);
    end
end

