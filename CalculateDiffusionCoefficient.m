function [DiffusionCoefficients] = CalculateDiffusionCoefficient(folder,option)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
cd(folder);
if option==1
DNA_In_Pits_Analysis(pwd);
end
W=what; W=W.mat; K=regexp(W,'Samples analyzed');
K=cellfun(@(x)~isempty(x),K); W=W(K); 

if ~isempty(W)
    DiffusionCoefficients=[];
    for i=1:numel(W)
        Var=load(W{i}); VarNames=fieldnames(Var);
        for j=1:numel(VarNames)
%             try
        MNG=strcat(VarNames{j},...
            '.Green_Channel_In_Green_Laser.Mean_Number_Of_Fluophores;');
        MNG=evalin('caller',MNG); 
        IMG=strcat(VarNames{j},...
            '.Green_Channel_In_Green_Laser.Intensity_Maps;');
        IMG=evalin('caller',IMG); IMG=IMG(2:end-1,2:end-1); 
        NonEmpty=IMG(logical(MNG)); Empty=IMG(~logical(MNG)); 
        tic; toc
        NonEmpty=cellfun(@FluophoreTracking,NonEmpty,'UniformOutput',false);
        Empty=cellfun(@FluophoreTracking,Empty,'UniformOutput',false);
        toc
        TOBJ=strcat(VarNames{j},'.OBJ_T_In_Green_Laser;');
        TLENS=strcat(VarNames{j},'.LENS_T_In_Green_Laser;');
        TOBJ=evalin('caller',TOBJ); TLENS=evalin('caller',TLENS); T=mean([TOBJ,TLENS]);        
        DiffusionCoefficients=cat(3,DiffusionCoefficients,{T,NonEmpty,Empty});
%             catch
%                 warning(strcat(...
%                     'Couldn''t calculate diffusion coefficients of sample ',...
%                     VarNames{j}));
%             end
        end
    end

else
    warning('No samples analyzed.')
end

end

