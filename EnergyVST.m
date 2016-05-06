function [] = EnergyVST()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
K=1.3806485279*10^(-23); 
[file,path] = uigetfile({'*.xlsx;*.xls'},'Bound complexes file');
if ~ischar(file) && ~ischar(path)
    return;
else
    Filename=fullfile(path,file); 
end
[~,sheets]=xlsfinfo(Filename);
sheetname='FitCoefficientsAgainstT';
s=strcmp(sheetname,sheets);
s=sum(s(:))>0;
if s
    a=xlsread(Filename,'FitCoefficientsAgainstT');
    LKNumbers=a(:,1); LKNumbers=LKNumbers(~isnan(LKNumbers));
    % Log fit
    LogFit=a(:,2);
    LogFitErrors=a(:,3);
    LogFit=reshape(LogFit,1,2,numel(LogFit)/2);
    LogFitErrors=reshape(LogFitErrors,1,2,numel(LogFitErrors)/2);
    EnergiesLogFit=LogFit(:,1,:);
    EnergiesLogFit=-EnergiesLogFit(:)*K;
    EnergiesLogFitErrors=LogFitErrors(:,1,:);
    EnergiesLogFitErrors=EnergiesLogFitErrors(:)*K;
    AmplitudeLogFit=LogFit(:,2,:);
    AmplitudeLogFit=AmplitudeLogFit(:);
    AmplitudeLogFitErrors=LogFitErrors(:,2,:);
    AmplitudeLogFitErrors=AmplitudeLogFitErrors(:);
    % Exp fit
    ExpFit=a(:,4);
    ExpFitErrors=a(:,5);
    ExpFit=reshape(ExpFit,1,2,numel(ExpFit)/2);
    ExpFitErrors=reshape(ExpFitErrors,1,2,numel(ExpFitErrors)/2);
    EnergiesExpFit=ExpFit(:,1,:);
%     EnergiesExpFit=-EnergiesExpFit(:)*K;
    EnergiesExpFit=-EnergiesExpFit(:)/284;
    EnergiesExpFitErrors=ExpFitErrors(:,1,:);
%     EnergiesExpFitErrors=EnergiesExpFitErrors(:)*K;
    EnergiesExpFitErrors=EnergiesExpFitErrors(:)/284;
    AmplitudeExpFit=ExpFit(:,2,:);
    AmplitudeExpFit=AmplitudeExpFit(:);
    AmplitudeExpFitErrors=ExpFitErrors(:,2,:);
    AmplitudeExpFitErrors=AmplitudeExpFitErrors(:);
    
    figure;
    [q,s]=polyfit(abs(LKNumbers),EnergiesExpFit,1)
    p=polyval(q,abs(LKNumbers));
    errorbar(abs(LKNumbers),EnergiesExpFit,EnergiesExpFitErrors,'o');
    hold on; plot(abs(LKNumbers),p,'r')
    legend('Data',sprintf('ax+b \n a=%0.5E, b=%0.5E',q(1),q(2)));
    set(gca, 'FontSize', 20)
    xlabel('Linking number \Delta Lk', 'FontSize', 20)
    ylabel('Energy \Delta G / kT at T=284 K', 'FontSize', 20,'interpreter','tex')
    
    
    figure;
    [q,s]=polyfit(abs(LKNumbers),EnergiesLogFit,1);
    p=polyval(q,abs(LKNumbers));
    errorbar(abs(LKNumbers),EnergiesLogFit,EnergiesLogFitErrors,'o:b');
    hold on; plot(abs(LKNumbers),p,'r')
    legend('Data',sprintf('ax+b \n a=%0.5E, b=%0.5E',q(1),q(2)));
    xlabel('Linking number (\Delta LK)')
    ylabel('Gibbs free energy \Delta G (J)')
else
    return;
end
end

