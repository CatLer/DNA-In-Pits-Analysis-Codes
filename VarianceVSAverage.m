function [] = VarianceVSAverage()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
A=evalin('base','whos(''-regexp'',''Set'')');
Names={A.name};
% parent='C:\Users\Leslie Lab\Desktop\Active\Shane';
parent=pwd;
for i=1:numel(Names)
    newdir=strcat(Names{i},'_Molecular_Brightness_VS_Relative_Intensity'); 
    mkdir(parent,newdir);
    path=strcat(parent,'\',newdir); cd(path);
    
    expression=strcat(Names{i},'.Green_Channel_In_Green_Laser.Relative_Intensity');
    Intensity_G=evalin('base',expression);
    expression=strcat(Names{i},'.Green_Channel_In_Green_Laser.Molecular_Brightness_In_Time');
    Variance_G=evalin('base',expression);   
    
%     expression=strcat(Names{i},'.Red_Channel_In_Green_Laser.Relative_Intensity');
%     Intensity_R=evalin('base',expression);
%     expression=strcat(Names{i},'.Red_Channel_In_Green_Laser.Molecular_Brightness_In_Time');
%     Variance_R=evalin('base',expression);       
    
%     Y=Variance_G(:); [~,Offset]=Intensity1Molecule(Y); 
%     Variance_G=Variance_G-Offset;
    
    for a=1:size(Intensity_G,1)
        for b=1:size(Intensity_G,2)
    f=figure;
    subplot(1,2,1)
    plot(permute(Variance_G(a,b,:),[3,2,1]),'m');
    str=sprintf('Pit(%d,%d) in green channel - Spatial Standard Deviation',a+1,b+1);
     title(str);
    subplot(1,2,2)
    plot(permute(Intensity_G(a,b,:),[3,2,1]),'g');   
%     legend('Molecular Brightness','Mean Relative Intensity'); 
            str=sprintf('Pit(%d,%d) in green channel - Relative Spatial Average',a+1,b+1);
            title(str);
%     subplot(2,1,2)
%     plot(permute(Variance_R(a,b,:),[3,2,1]),'m');
%     hold on;
%     plot(permute((mat2gray(Intensity_R(a,b,:))),[3,2,1]),'r');   
%     legend('Molecular Brightness','Mean Relative Intensity'); 
%             str=sprintf('Pit(%d,%d) in red channel',a+1,b+1);
%             title(str);    
    
    
%     [y,lags]=xcorr(Intensity_G(a,b,:),Variance_G(a,b,:),'coeff');
%     plot(permute(y(lags>0),[3,2,1]),'g');     
%     hold on
%     [y,lags]=xcorr(Intensity_G(a,b,:),'coeff');
%     plot(permute(y(lags>0),[3,2,1]),'b');   
%     hold on
%     [y,lags]=xcorr(Variance_G(a,b,:),'coeff');
%     plot(permute(y(lags>0),[3,2,1]),'m');    
%     legend('<RI,MB>','<RI,RI>','<MB,MB>')
%             str=sprintf('Pit(%d,%d)',a+1,b+1);
%             title(str);
            print(f,str,'-dpng')
            close(f);
        end
    end
end
end

