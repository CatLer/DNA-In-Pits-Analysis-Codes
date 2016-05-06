function [Statistics,BindingMats] = GenerateBindingMatrix(Sampled_Variance,...
    Sampled_Variance_Lower_Bound,Sampled_Variance_Upper_Bound,...
    Sampled_Average_Intensity,Sampled_Number_Of_Molecules,...
    Radius,Exposure_Time,Variance_In_Time,Sampled_Intensity_1_Molecule,...
    Binding_Parameter)   
% obtain time scale for binding events 
% properties of PitsChannel
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%  Filter Variance per number of molecules
% set max number of actives fluophore in a pit
Max_Number=3; N_o=pi*Radius^2; Factor=N_o/(2*pi*Exposure_Time/1000);
% generate nested structures (statistics VS number)
% try
Statistics=struct;
for Number=1:Max_Number;
Stats=GenerateStatistics;
name=sprintf('With_%d_Active_Fluophores',Number);
Statistics.(name)=Stats;
end
% catch
%     sprintf('BrEaKiNg Bad')
%     Statistics=[];
% end
%% Define Unbound Variance Level With Confidence Levels
% try
BindingMats=BindingDetector;
% catch
%     BindingMats=[];
% end
%%  Detecting the number of active fluophores
    function Index=FindIndex(Samples)
        if iscell(Samples)
            Samples=cell2mat(Samples);
        end
        Index=Samples==Number;
    end
%%  Taking only corresponding signals
    function Samples=Sampling(Samples,Index)
        Samples=Samples(Index);
        Samples=Samples(:);
        if iscell(Samples)
            Samples=cell2mat(Samples);
        end
    end
%%  Getting statistics
    function Statistics=GenerateStatistics
        Indexing=cellfun(@FindIndex,Sampled_Number_Of_Molecules,...
            'UniformOutput',false);
        
        Sampled_Variance_Number=cellfun(@(x,y)Sampling(x,y),Sampled_Variance,...
        Indexing,'UniformOutput',false);
        Sampled_Variance_Number=cell2mat(Sampled_Variance_Number(:));
       
        Sampled_Variance_Lower_Bound_Number=cellfun(@(x,y)Sampling(x,y),...
            Sampled_Variance_Lower_Bound,Indexing,'UniformOutput',false);   
        Sampled_Variance_Lower_Bound_Number=...
            cell2mat(Sampled_Variance_Lower_Bound_Number(:));
        
        Sampled_Variance_Upper_Bound_Number=cellfun(@(x,y)Sampling(x,y),...
            Sampled_Variance_Upper_Bound,Indexing,'UniformOutput',false);
        Sampled_Variance_Upper_Bound_Number=...
            cell2mat(Sampled_Variance_Upper_Bound_Number(:));        
        
        Sampled_Average_Intensity_Number=cellfun(@(x,y)Sampling(x,y),...
            Sampled_Average_Intensity,Indexing,'UniformOutput',false); 
        Sampled_Average_Intensity_Number=...
            cell2mat(Sampled_Average_Intensity_Number(:));
        
        SV=[mean(Sampled_Variance_Number),std(Sampled_Variance_Number)];
         
        SVLB=[mean(Sampled_Variance_Lower_Bound_Number),...
            std(Sampled_Variance_Lower_Bound_Number),...
            NaNMin(Sampled_Variance_Lower_Bound_Number)];
        
        SVUB=[mean(Sampled_Variance_Upper_Bound_Number),...
            std(Sampled_Variance_Upper_Bound_Number),...
            NaNMax(Sampled_Variance_Upper_Bound_Number)];
        
        SA=[mean(Sampled_Average_Intensity_Number),...
            std(Sampled_Average_Intensity_Number)];
        
        UnboundDC=((SVLB(1)/(SA(1)^2)+1)/Factor)^(-1);
        BoundDC=((SVUB(1)/(SA(1)^2)+1)/Factor)^(-1);
        
        Statistics=struct('Variance_Average',SV(1),...
            'Variance_Fluctuation',SV(2),...
            'Variance_Lower_Bound_Average',SVLB(1),...
            'Variance_Lower_Bound_Fluctuation',SVLB(2),...
            'Variance_Lower_Bound_Min',SVLB(3),...
            'Variance_Upper_Bound_Average',SVUB(1),...
            'Variance_Upper_Bound_Fluctuation',SVUB(2),...
            'Variance_Upper_Bound_Max',SVUB(3),...
            'Average_Intensity',SA(1),...
            'Average_Fluctuation',SA(2),...
            'Variance',Sampled_Variance_Number,...
            'Variance_Lower_Bound',Sampled_Variance_Lower_Bound_Number,...
            'Variance_Upper_Bound',Sampled_Variance_Upper_Bound_Number,...
            'Average',Sampled_Variance_Number,...
            'Index',{Indexing},...
            'Max_Diffusion_Coefficient',UnboundDC,...
            'Min_Diffusion_Coefficient',BoundDC);
    end
%%
function out=NaNMax(in)
out=max(in(~isnan(in)));
if isempty(out)
    out=NaN;
end
end
%%
function out=NaNMin(in)
out=min(in(~isnan(in)));
if isempty(out)
    out=NaN;
end
end
        
%%
    function BindingMatrix=BindingDetector()
        Fields=fieldnames(Statistics);
        NumberOfFields=numel(Fields);
        BindingMatrix=struct();
        for i=1:NumberOfFields
            
            myfield=sprintf('With_%d_Active_Fluophores',i);
            
            if (Statistics.(Fields{i}).('Variance_Upper_Bound_Max')-...
                    Statistics.(Fields{i}).('Variance_Lower_Bound_Min'))...
                    /Statistics.(Fields{i}).('Variance_Lower_Bound_Min')...
                    >0.2 % pick a relaxation parameter, here 10%
            Level=...
                Statistics.(Fields{i}).('Variance_Upper_Bound_Max')-...
                Statistics.(Fields{i}).('Variance_Upper_Bound_Fluctuation');
            Level_prime=...
                Statistics.(Fields{i}).('Variance_Lower_Bound_Min')+...
                Statistics.(Fields{i}).('Variance_Lower_Bound_Fluctuation');            
            
            Relaxed_Level_Low=Level_prime+0.8*(Level-Level_prime);
            Relaxed_Level_High=Level_prime+0.8*(Level-Level_prime);
            
            if ~isnan(Binding_Parameter)
               Relaxed_Level_Low=Binding_Parameter;
               Relaxed_Level_High=Binding_Parameter;
            end
            
            Index=Statistics.(Fields{i}).('Index');
            
            Processed_SVUP=cellfun(@(x,y)Sampling(x,y),...
                Sampled_Variance_Upper_Bound, Index,'UniformOutput',false);
            Processed_SVLO=cellfun(@(x,y)Sampling(x,y),...
                Sampled_Variance_Lower_Bound, Index,'UniformOutput',false);            
            
%             Processed_SVUP=cellfun(@(x)x(x>Relaxed_Level),Processed_SVUP,'UniformOutput',false);        

            Processed_SVUP=cellfun(@(x,y)CheckBindingLevel(x,y,Relaxed_Level_Low,Relaxed_Level_High),Processed_SVUP,Processed_SVLO,'UniformOutput',false);           
            Processed_SVUP=cellfun(@(x)length(x)>2,Processed_SVUP,'UniformOutput',false);
                      
            
            if iscell(Processed_SVUP)
                Processed_SVUP=cell2mat(Processed_SVUP);
            end
                BindingMatrix.(myfield)=Processed_SVUP;
            else
                BindingMatrix.(myfield)=zeros(size(Sampled_Variance));
            end
            
        end
    end

    function Check=CheckBindingLevel(xup,xlo,RLLO,RLUP)
        xup=xup>RLUP;
        xlo=xlo>RLLO;
        if ~isempty(xlo) && ~isempty(xup)            
            Check=xup|xlo;
        else
            Check=[];
        end
        Check=xup(Check);
    end
end

