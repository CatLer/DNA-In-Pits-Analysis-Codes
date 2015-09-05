classdef PitsChannel<handle
    %PitsChannel: Object storing data specific to a channel (green or red).
    %Properties include intensities in the pits, fluophores number,
    %statistics and activity, diffusion coefficients and tracking.
    %   Handle object. Methods can be modified and used to recalculate
    %   properties in the object. Include clustering&binning method to
    %   calculate the number of fluophores in the channel with the
    %   intensity of one fluophore (in time and averaged), the molecular
    %   brightness, diffusion coefficients, tracking results, videos of
    %   each pit, relative/absolute/background intensities in each pit,
    %   fluophore activity indicator. Properties can also be added and
    %   calculated after the creation of the object. The user needs to
    %   create the object only once, as long as the intensities were
    %   properly calculated.
    %%                              PROPERTIES
    properties
        Relative_Intensity=[];
        Molecular_Brightness_In_Time=[];
        Absolute_Intensity=[];
        Background_Intensity=[];
        Intensity_Maps=[];
        Time_Average_Intensity=[];
        Average_Intensity=[];
        Binding=[];
        Fluophore_Activity=[];
        Number_of_frames_packed=[];
        Number_Of_Fluophores_packed=[];
        Mean_Number_Of_Fluophores=[];
        Number_Of_Fluophores_In_Time=[];
        Fluophores_Distribution=[];
        Intensity_Of_1_Fluophore=[];
        Mean_Intensity_Of_1_Fluophore=[];
        Molecular_Brightness=[];
        Mean_Molecular_Brightness=[];
        Diffusion_Curve=[];
        Diffusion_Coefficient=[];
        Tracking_Speed=[];
        Tracking_Diffusion_Coefficient=[];
        Offset=[];
        Warnings={};
    end
    %%                                 METHODS
    % Storage & Analysis: some functions can be modified after the creation
    % of the object. Call methods in the corresponding PitsSample object to
    % recalculate. New methods and properties can be added.
    methods
        %======================= CONSTRUCTOR ==============================
        function  obj=PitsChannel(varargin)
            if nargin>0
                narginchk(4,4); % checks # of input args
                
                %------------------- Initialization -----------------------
                % RI: Relative intensity
                % AI: Absolute intensity
                % BI: Background intensity
                RI=varargin{1};
                AI=varargin{2};
                BI=varargin{3};
                MB=varargin{4};
                %----------------------------------------------------------
                
                %------------------- Intensity data -----------------------
                obj.IntensityData(RI,AI,BI,MB);
                %----------------------------------------------------------
                
                %---------------- Molecular brightness --------------------
                obj.SpatialMolecularBrightness(MB);
                %----------------------------------------------------------
                
                %-------------------- Fluophore data ----------------------
                obj.CountTheNumberOfFluophores();
                obj.CalculateFluophoreActivity();
                %----------------------------------------------------------
                
                %-------------------- Diffusion data ----------------------
                obj.DiffusionAnalysis();
                %----------------------------------------------------------
                
                %-------------------- Tracking data -----------------------
                obj.TrackingAnalysis();
                %----------------------------------------------------------
                
            end
        end
        %==================================================================
        
        %===================== INTENSITIES STORAGE ========================
        function obj=IntensityData(obj,RI,AI,BI,MB)
            % shouldn't be modified
            obj.Relative_Intensity=RI;
            obj.Absolute_Intensity=AI;
            obj.Background_Intensity=BI;
            obj.Average_Intensity=mean(RI(:));
            obj.Time_Average_Intensity=mean(RI,3);
            obj.Molecular_Brightness_In_Time=MB;
            % add Photobleaching_cut function
        end
        %==================================================================
        
        %===================== MOLECULAR BRIGHTNESS =======================
        function obj=SpatialMolecularBrightness(obj)
            % can be modified
            try
%                 MB=obj.Molecular_Brightness_In_Time;
            catch
            end
        end
        %==================================================================
        
        %===================== FLUOPHORE ACTIVITY =========================
        function obj=CalculateFluophoreActivity(obj)
            % can be modified
            try
                obj.Fluophore_Activity=...
                    Fluophore_Activity_Index(obj.Relative_Intensity);
            catch
                warning('Couldn''t calculate the fluophore activity index.');
            end
        end
        %==================================================================
        
        %======================= FLUOPHORE COUNT ==========================
        function obj=CountTheNumberOfFluophores(obj)
            % can be modified
            try
                w=min(size(obj.Relative_Intensity,3),100); 
                obj.Number_of_frames_packed=w;
                n=floor(size(obj.Relative_Intensity,3)/w);
                RIprime=obj.Relative_Intensity(:,:,1:n*w);
                RIprime=reshape(RIprime,[size(RIprime,1),...
                    size(RIprime,2),w,n]);
                RIprime=squeeze(mean(RIprime,3));
                N=zeros(size(RIprime));
                INT=zeros(size(RIprime,3),3);
                for i=1:size(RIprime,3)
                    [num,~,intensity]=histTestM(RIprime(:,:,i));
                    N(:,:,i)=num; INT(i,:)=intensity;
                end
                num=mean(INT(:,1));
                NT=round(obj.Relative_Intensity/num); NT(NT<0)=0;
                obj.Number_Of_Fluophores_packed=N;
                obj.Mean_Number_Of_Fluophores=round(nanmean(N,3));
                obj.Number_Of_Fluophores_In_Time=NT;
                obj.Intensity_Of_1_Fluophore=INT(:,1:2);
                obj.Mean_Intensity_Of_1_Fluophore=...
                    [mean(INT(:,1)),mean(INT(:,2))];
                obj.Fluophores_Distribution=[];
                obj.Molecular_Brightness=INT(:,3);
                obj.Mean_Molecular_Brightness=...
                    [mean(INT(:,3)),std(INT(:,3))];
                obj.Offset=obj.Mean_Intensity_Of_1_Fluophore(1)-...
                    obj.Mean_Molecular_Brightness(1);
                obj.Relative_Intensity=obj.Relative_Intensity-obj.Offset; % in test
            catch
                warning('Couldn''t count the number of fluophores.');
            end
        end
        %==================================================================
        
        %======================== DIFFUSION ANALYSIS ======================
        function obj=DiffusionAnalysis(obj)
            % can be modified
            try
                [Signals,Coefficients]=...
                    DiffusionCurve(obj.Relative_Intensity);
                obj.Diffusion_Curve=Signals;
                obj.Diffusion_Coefficient=Coefficients;
            catch
                warning('Couldn''t calculate the diffusion coefficients.');
            end
        end
        %==================================================================
        
        %========================= TRACKING ANALYSIS ======================
        function obj=TrackingAnalysis(obj)
            % can be modified
           try        
               Videos=obj.Intensity_Maps(2:end-1,2:end-1);
            try       
            Videos=Videos(logical(obj.Mean_Number_Of_Fluophores));
            catch
                warning('Couldn''t identify non-empty pits.');
            end
            Output=CalculateDiffusionCoefficients(Videos);
            obj.Tracking_Diffusion_Coefficient=Output(1,:);
            obj.Tracking_Speed=Output(2,:);
           catch
               warning('Couldn''t track molecules in the pits.')
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

