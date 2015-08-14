function [] = PlotFRETSignal()
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
A=evalin('base','whos(''-regexp'',''Set'')');
Names={A.name};
% parent='C:\Users\Leslie Lab\Desktop\Active\Shane';
parent=pwd;
for i=1:numel(Names)
    
    newdir=strcat(Names{i},'_FRET_Signals'); mkdir(parent,newdir);
    path=strcat(parent,'\',newdir); cd(path);
    
    expression=strcat(Names{i},'.FRET_Analysis.FRET_Signals');
    FRET_Signals=evalin('base',expression);
%     FRET_Signals=(FRET_Signals(2:end-1,2:end-1,:));
    
    expression=strcat(Names{i},'.Red_Channel_In_Green_Laser.Relative_Intensity');
    Intensity_R=evalin('base',expression);
%     Intensity_R=(Intensity_R(2:end-1,2:end-1,:));
    
    expression=strcat(Names{i},'.Green_Channel_In_Green_Laser.Relative_Intensity');
    Intensity_G=evalin('base',expression);
%     Intensity_G=(Intensity_G(2:end-1,2:end-1,:));
    
    maxLag=max(size(Intensity_R,3),size(Intensity_G,3));
    Lags=-(maxLag-1):maxLag-1; % Lags(Lags>=0),Lags>=0
    
    for j=1:size(FRET_Signals,1)
        for k=1:size(FRET_Signals,2)
            f=figure('Name',Names{i}, 'NumberTitle','off');
            subplot(2,1,1); plot(permute(Intensity_R(j,k,:),[3,2,1]),'r');
            hold on; plot(permute(Intensity_G(j,k,:),[3,2,1]),'g'); 
            title(sprintf('Pit(%d,%d)',j+1,k+1)); legend('Red Channel', 'Green Channel');
            subplot(2,1,2); plot(permute(FRET_Signals(j,k,:),[3,2,1]),'b');
            title('FRET signal');
%             subplot(2,2,3); 
%             plot(Lags,xcorr(permute(FRET_Signals(j,k,:),[3,2,1]),'coeff'));
%             title('Self correlation of FRET Signal');
%             subplot(2,2,4); 
%             mscohere(permute(Intensity_R(j,k,:)-mean(Intensity_R(j,k,:)),[3,2,1]),...
%                 permute(Intensity_G(j,k,:)-mean(Intensity_G(j,k,:)),[3,2,1]));
            str=sprintf('FRET_Signals_Pit(%d,%d)',j+1,k+1);
            print(f,str,'-dpng')
            close(f);            
        end
    end
    
end
end

