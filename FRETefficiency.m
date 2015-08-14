classdef FRETefficiency<handle
    %FRETefficiency : Returns proximity ratios with modifications for the
    %cross talks (cross emission of green to red - cy5 in red channel-,
    %cross excitation of red by the green - cy3 excited by green laser).
    %Returns true FRET using red laser experiments. If no cross talk
    %coefficients are available, returns the relative FRET ratio.
    %   Acceptor/Donor ratio : (relative FRET ratio -> alpha,Beta =0)
    %        (I_RG-alpha*IGG)/(I_RG+(1-alpha)I_GG+Beta)
    %   Acceptor emission method :
    %        [(I_RG-alpha*I_GG)*epsilon_RR-I_RR*epsilon_RG]/I_RR*epsilon_GG
    %  http://www.fluortools.com/software/ae/documentation/tools/FRET    
    % Lifetimes method not available, Donor emission method not available
%%                           PROPERTIES    
    properties  
    Calculation_With_All_Pits=[];
    Calculation_With_All_Pits_Average=[];
    
    %***this is wrong, I'll use the number in time***
    % total of 2 green fluophores in the pit before fretting
    Calculation_With_1_G_1_R_Pits=[];
    Calculation_With_1_G_1_R_Pits_Average=[];  
    
    Calculation_With_Red_Laser_Experiment=[];
    
    Warnings={};
    end
%%                             METHODS    
    methods
%============================= CONSTRUCTOR ================================ 
        function obj=FRETefficiency(varargin)
            if nargin>0
                narginchk(4,6); % checks # of input args
                
                %------------------- Initialization -----------------------
                % RIG : Time averaged relative intensity green channel
                % RIR : Time averaged relative intensity red channel
                % NG : Average number of green fluophores 
                % NR : Average number of red fluophores                  
                % Cross_Emission_Green_To_Red : Cross emission G to R 
                % Cross_Excitation_Red_By_Green : Cross excitation R by G             
                RIG=varargin{1};
                RIR=varargin{2};
                NG=varargin{3};
                NR=varargin{4};
                if nargin>4
                Cross_Emission_Green_To_Red=varargin{5};
                if nargin>5
                Cross_Excitation_Red_by_Green=varargin{6};
                end
                else
                    Cross_Emission_Green_To_Red=0;
                    Cross_Excitation_Red_by_Green=0;
                end
                %----------------------------------------------------------
                
                %----------------- FRET efficiencies ----------------------
                % modified proximity ratio
                obj.CalculateFRETefficiencies(RIG,RIR,NG,NR,...
                    Cross_Emission_Green_To_Red,Cross_Excitation_Red_by_Green);
                % true FRET ratio coming soon!!!
                %----------------------------------------------------------
            end
        end
        %==================================================================
        
        %================= CALCULATE FRET EFFICIENCIES ====================
        function obj=CalculateFRETefficiencies(obj,RIG,RIR,NG,NR,...
                Cross_Emission_Green_To_Red,Cross_Excitation_Red_by_Green)
            % modified proximity ratio
            % All pits
            CalculationFRET=...
                (RIR-Cross_Emission_Green_To_Red*RIG).*...
                (RIR+(1-Cross_Emission_Green_To_Red)*RIG+...
                Cross_Excitation_Red_by_Green).^(-1);
            CalculationFRET(CalculationFRET<0)=NaN;
            obj.Calculation_With_All_Pits=CalculationFRET;
            obj.Calculation_With_All_Pits_Average=...
                nanmean(CalculationFRET(:));           
            % Selected Pits
            % 1 red fluophore & 1 green fluophore on average
            % fluophore activity index > threshold
            NRprime=double(NR==1); NRprime(NRprime==0)=NaN;
            RIRprime=RIR.*NRprime;
            NGprime=double(NG==1); NGprime(NGprime==0)=NaN;
            RIGprime=RIG.*NGprime;
            CalculationFRET=...
                (RIRprime-Cross_Emission_Green_To_Red*RIGprime).*...
                (RIRprime+(1-Cross_Emission_Green_To_Red)*RIGprime+...
                Cross_Excitation_Red_by_Green).^(-1);
            CalculationFRET(CalculationFRET<0)=NaN;
            obj.Calculation_With_1_G_1_R_Pits=CalculationFRET;
            obj.Calculation_With_1_G_1_R_Pits_Average=...
                nanmean(CalculationFRET(:));
        end
        %==================================================================
        
        %========== CALCULATE FRET EFFICIENCY WITH RED CHANNEL ============
        function obj=CalculateFRETWithRedLaser(obj,RIR_G,RIR_R,...
                epsilon_RR,epsilon_RG,epsilon_GG)
            try
            % invoke red laser experiment
            CalculationFRET=...
                (RIR_G*epsilon_RR-RIR_R*epsilon_RG)./(RIR_R*epsilon_GG);
            obj.Calculation_With_Red_Laser_Experiment=CalculationFRET;
            catch
                warning('Couldnt'' calculate FRET efficiency using Red Laser experiment.');
            end
        end
        %==================================================================
    end
    
    methods(Static)
        % to know if a method should be static, use the rule of thumb:
        %   I can invoke the method even if no object of this class has
        %   been created. To analyze data without storing the results
        %   directly in the object properties.
        
    end
    
end

