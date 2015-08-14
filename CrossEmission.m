function [CEC,CrossEmissionCoefficients]=CrossEmission(folder,option)
%CrossEmission : Takes the name of the folder containing the samples to be
%analyzed (only green fluophores present in the sample) as input argument.
%Returns the cross emission factor as a percentage of the signal in the
%green channel bleeding through the red channel. Returns also an array with
%the temperatures in the first column and the ratios in the second column
%to check for temperature dependency.
%   Calls DNA_In_Pits_Analysis(folder). Takes the ratio of the molecular
%   brightness of the green & red channels and the temperature of the
%   sample. 
cd(folder);
if option==1
DNA_In_Pits_Analysis(pwd);
end
W=what; W=W.mat; K=regexp(W,'Samples analyzed');
K=cellfun(@(x)~isempty(x),K); W=W(K); 

if ~isempty(W)
    CrossEmissionCoefficients=[];
    for i=1:numel(W)
        Var=load(W{i}); VarNames=fieldnames(Var);
        for j=1:numel(VarNames)
            try
        MBG=strcat(VarNames{j},...
            '.Green_Channel_In_Green_Laser.Mean_Molecular_Brightness(1);');
        MBR=strcat(VarNames{j},...
            '.Red_Channel_In_Green_Laser.Mean_Molecular_Brightness(1);');
        MBG=evalin('caller',MBG); MBR=evalin('caller',MBR);
        Ratio=MBR/MBG;
        TOBJ=strcat(VarNames{j},'.OBJ_T_In_Green_Laser;');
        TLENS=strcat(VarNames{j},'.LENS_T_In_Green_Laser;');
        TOBJ=evalin('caller',TOBJ); TLENS=evalin('caller',TLENS); T=mean([TOBJ,TLENS]);
        CrossEmissionCoefficients=cat(1,CrossEmissionCoefficients,[T,Ratio]);
            catch
                warning(strcat(...
                    'Couldn''t calculate cross-emission coefficient of sample ',...
                    VarNames{j}));
            end
        end
    end
    CEC=mean(CrossEmissionCoefficients(:,2));
    figure; 
    plot(CrossEmissionCoefficients(:,1),CrossEmissionCoefficients(:,2),'O--b');
    title('Cross emission coefficient against temperature');
    ylabel('Ratio (bleedthrough of the green signal in the red channel)');
    xlabel('Temperature (°C)');
else
    warning('No samples analyzed.')
    CEC=[];
    CrossEmissionCoefficients=[];
end

end

