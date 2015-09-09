function [Output] = CalculateDiffusionCoefficients(Videos)
%CalculateDiffusionCoefficients : Videos is a cell array with the videos of
%the pits in each cell. Use the method in SamplePit to generate the
%intensity maps in cell array if not properly done before. Calls the
%function FluophoreTracking. Set the parameters in FluophoreTracking.m.
%   Applies FluophoreTracking in each cell. Returns a STEM plot of the
%   speeds and the diffusion coefficients. Returns the mean diffusion
%   coefficient with the error. Returns the mean speed with the error.
if ~iscell(Videos)
warning('Input should be a cell array.'); Output=zeros(2,0);
return;
end
Output=cellfun(@FluophoreTracking,Videos,'UniformOutput',false);
DiffusionCoefficients=cell2mat(cellfun(@(x)x(1),Output,...
    'UniformOutput',false));
Speeds=cell2mat(cellfun(@(x)x(2),Output,'UniformOutput',false));
DiffusionCoefficients=DiffusionCoefficients(~isnan(DiffusionCoefficients));
Speeds=Speeds(~isnan(Speeds));
figure; 
subplot(1,2,1); stem(DiffusionCoefficients(:));
subplot(1,2,2); stem(Speeds(:));
Output=[mean(DiffusionCoefficients(:)),std(DiffusionCoefficients(:));...
    mean(Speeds(:)),std(Speeds(:))];
end

