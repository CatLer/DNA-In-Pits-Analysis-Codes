function [h] = TempHist(varargin)
%MakeTempPlot: This function...
%1) Takes in samples at various temperatures for a fixed Lk;
%2) Plots a histogram: number of bound complexes versus temperature, fixed Lk. 

%% Displays list in dialog box to select samples.

histList = HistListTemp();

prompt = 'What is the linking number for this sample?';
dlg_title = 'Sample supercoiling';
in1= inputdlg(prompt, dlg_title);
Lk=str2num(in1{1});

% prompt = 'How many bins are desired?';
% dlg_title = 'Bin number';
% in2= inputdlg(prompt, dlg_title);
% nbin=str2num(in2{1});

prompt = 'What is the bin size desired (1 degree is suggested)?';
dlg_title = 'Bin size';
in3= inputdlg(prompt, dlg_title);
binsize=str2num(in3{1});

prompt = 'What is the lowest temperature?';
dlg_title = 'Lower Temperature';
in4= inputdlg(prompt, dlg_title);
lowerbinlim=str2num(in4{1})-0.5;

prompt = 'What is the highest temperature?';
dlg_title = 'Higher Temperature';
in5= inputdlg(prompt, dlg_title);
upperbinlim=str2num(in5{1})+0.5;

%nbin = max(histList)-min(histList)+2;
% upperbinlim = round(max(histList))+0.5;
% lowerbinlim = round(min(histList))-0.5;
nbin = upperbinlim-lowerbinlim;

h = histogram(histList, nbin, 'BinLimits', [lowerbinlim, upperbinlim]);
grid on
str = sprintf('Bound complexes for Lk= %d', Lk);
title(str);
ylabel('Number of bound complexes');
xlabel('Temperature (Celsius degrees)');
    
end


