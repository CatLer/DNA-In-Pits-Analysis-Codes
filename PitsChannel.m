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
        % positions of the pits in the channel
        Positions=[];
        % intensities arrays + binding
        Relative_Intensity=[];
        Variance_In_Time=[];
        
        % new
        Sampled_Average_Intensity=[];
        Sampled_Relative_Intensity=[];
        Sampled_Variance=[]
        Sampled_Variance_Lower_Bound=[];
        Sampled_Variance_Upper_Bound=[];
        Sampled_Signals_On_Off=[];
        Sampled_Number_Of_Molecules=[];
        Sampled_Intensity_1_Molecule=[];
        
        Absolute_Intensity=[];
        Background_Intensity=[];
        Absolute_Variance=[];  
        Background_Variance=[]; 
        Background_Illumination_Profile=[]; 
        
        Variance_In_Time_Lower_Bound=[];
        Variance_In_Time_Upper_Bound=[];     
        Variance_In_Time_Variation=[];
        Time_Average_Intensity=[];
        Average_Intensity=[];       
        
        Statistics_Binding=[];
        
        Binding=[];
        
        BindingDetection=[];
        
        % diffusion curves
        Diffusion_Curve=[];
        Diffusion_Coefficient=[];
        
%         % fluophores counting & activity
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
        Offset=[];
        
%         % tracking
%         Tracking_Speed=[];
%         Tracking_Diffusion_Coefficient=[];
%         % videos for tracking
%         Intensity_Maps=[];
      
        % warnings        
        Warnings={};
        Pit_Radius=[];
        Exposure_Time=[];
    end
    %%                                 METHODS
    % Storage & Analysis: some functions can be modified after the creation
    % of the object. Call methods in the corresponding PitsSample object to
    % recalculate. New methods and properties can be added.
    methods
        %======================= CONSTRUCTOR ==============================
        function  obj=PitsChannel(varargin)
            if nargin>0
                narginchk(10,10); % checks # of input args
                
                %------------------- Initialization -----------------------
                % RI: Relative intensity
                % AI: Absolute intensity
                % BI: Background intensity
                RI=varargin{1};
                AI=varargin{2};
                BI=varargin{3};
                MB=varargin{4};
                obj.Positions=varargin{5};
                AV=varargin{6};
                BV=varargin{7};
                BG=varargin{8};
                obj.Pit_Radius=varargin{9};
                obj.BindingDetection=varargin{10};
                %----------------------------------------------------------
                
                %------------------- Intensity data -----------------------
                obj.IntensityData(RI,AI,BI,MB,AV,BV,BG);
                obj.SetZero();
                %----------------------------------------------------------
                
                %------------------- Sptial Variance ----------------------
                obj.SpatialVariance();
                obj.SampledSpatialVariance();
                %----------------------------------------------------------
                
                %-------------------- Fluophore data ----------------------
                obj.CountMoleculesFromSamples(); 
%                 obj.CountTheNumberOfFluophores();
%                 obj.CalculateFluophoreActivity();
                %----------------------------------------------------------
                
                %-------------------- Binding data ------------------------
                %----------------------------------------------------------
                
                %-------------------- Diffusion data ----------------------
                obj.DiffusionAnalysis();
                %----------------------------------------------------------
                
                %-------------------- Tracking data -----------------------
%                 obj.TrackingAnalysis();
                %----------------------------------------------------------
                
            end
        end
        %==================================================================
        
        %===================== INTENSITIES STORAGE ========================
        function obj=IntensityData(obj,RI,AI,BI,MB,AV,BV,BG)
            % shouldn't be modified
            obj.Relative_Intensity=RI;
            obj.Absolute_Intensity=AI;
            obj.Background_Intensity=BI;
            obj.Average_Intensity=nanmean(RI(:));
            obj.Time_Average_Intensity=mean(RI,3);
            obj.Variance_In_Time=MB;
            obj.Absolute_Variance=AV; % 
            obj.Background_Variance=BV; %
            obj.Background_Illumination_Profile=BG; %            
            % add Photobleaching_cut function
        end
        %==================================================================
        
        %======================== SPATIAL VARIANCE ========================
        function obj=SpatialVariance(obj)
            % can be modified
            if ~isempty(obj.Variance_In_Time)
            obj.Variance_In_Time_Lower_Bound=0*obj.Variance_In_Time(:,:,1);
            obj.Variance_In_Time_Upper_Bound=0*obj.Variance_In_Time(:,:,1);
            obj.Variance_In_Time_Variation=0*obj.Variance_In_Time(:,:,1);
            try
                for p=1:size(obj.Variance_In_Time,1)
                    for q=1:size(obj.Variance_In_Time,2)
                        Levels=statelevels(permute(...
                            obj.Variance_In_Time(p,q,:),[3,2,1]));
                obj.Variance_In_Time_Lower_Bound(p,q)=Levels(1);
                obj.Variance_In_Time_Upper_Bound(p,q)=Levels(2);
                obj.Variance_In_Time_Variation(p,q)=diff(Levels);
                    end
                end
                if ~isempty(obj.Variance_In_Time_Upper_Bound)
                % look at upper bounds in the variance, divide in 2 groups
                VTUB=obj.Variance_In_Time_Upper_Bound(:); IDUB=kmeans(VTUB,2); 
                IDUB=reshape(IDUB,size(obj.Variance_In_Time(:,:,1)));
                IDUB=IDUB==2; 
                % look at differences in levels in variance, divide in 2
                % groups
                VTDB=obj.Variance_In_Time_Variation; IDDB=kmeans(VTDB,2); 
                IDDB=reshape(IDDB,size(obj.Variance_In_Time(:,:,1)));
                IDDB=IDDB==2;                
                obj.Binding=IDUB.*IDDB; % keeps only possible binding events
                end
            catch
                warning('Couldn''t determine binding events.');
            end
            end
        end
        %==================================================================
        
        %======================== Sampled Spatial Varince =================
        function obj=SampledSpatialVariance(obj)
            try
                V=obj.Variance_In_Time; A=obj.Relative_Intensity;
                obj.Sampled_Average_Intensity=cell(size(A,1),size(A,2));
                obj.Sampled_Relative_Intensity=cell(size(A,1),size(A,2));
                obj.Sampled_Signals_On_Off=cell(size(A,1),size(A,2));
                obj.Sampled_Variance=cell(size(V,1),size(V,2));
                obj.Sampled_Variance_Lower_Bound=cell(size(V,1),size(V,2));
                obj.Sampled_Variance_Upper_Bound=cell(size(V,1),size(V,2));
                if ~isempty(V)
                    for p=1:size(V,1)
                        for q=1:size(V,2)
                            [LB,UB,Av,SA,SV,OnOff]=...
                                SamplingSignals(A(p,q,:),V(p,q,:));
                            obj.Sampled_Average_Intensity{p,q}=Av;
                            obj.Sampled_Relative_Intensity{p,q}=SA;
                            obj.Sampled_Variance{p,q}=SV;
                            obj.Sampled_Variance_Lower_Bound{p,q}=LB;
                            obj.Sampled_Variance_Upper_Bound{p,q}=UB;
                            obj.Sampled_Signals_On_Off{p,q}=OnOff;
                            %sprintf('Pit(%d,%d)',p,q)
                        end
                    end
                end
            catch
                warning('Couldn''t sample the signals.');
            end
        end
        %==================================================================
        
        %=================== Count Molecules From Samples =================
        function obj=CountMoleculesFromSamples(obj)
            try
            [obj.Sampled_Number_Of_Molecules,...
                obj.Sampled_Intensity_1_Molecule]=...
                CountMoleculesFromSampledSignals(...
                obj.Sampled_Average_Intensity);
            catch
                warning('Couldn''t calculate the number of molecules from sampled signals.');
            end
        end
        %==================================================================
        
        function obj=SetZero(obj)
            try
            if ~isempty(obj.Time_Average_Intensity)
                R=obj.Time_Average_Intensity(:);
                offset=min(R(R<0));
                if ~isempty(offset)
                obj.Relative_Intensity=obj.Relative_Intensity-offset;
                end
            end
            catch
                warning('Couldn''t level the signals.');
            end
        end
        
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
%                 obj.Relative_Intensity=obj.Relative_Intensity-obj.Offset; % in test
            catch
                warning('Couldn''t count the number of fluophores.');
            end
        end
        %==================================================================
        %======================== STATISTICS VARIANCE =====================
        function obj=GenerateStatisticsBinding(obj,Binding_Parameter)
            [Statistics,BindingMats]=GenerateBindingMatrix(obj.Sampled_Variance,...
                obj.Sampled_Variance_Lower_Bound,obj.Sampled_Variance_Upper_Bound,...
                obj.Sampled_Average_Intensity,obj.Sampled_Number_Of_Molecules,...
                obj.Pit_Radius,obj.Exposure_Time,obj.Variance_In_Time,...
                obj.Sampled_Intensity_1_Molecule,Binding_Parameter);
            obj.Statistics_Binding=Statistics;
            obj.Binding=BindingMats;
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
%            try        
%                Videos=obj.Intensity_Maps(2:end-1,2:end-1);
%             try       
%             Videos=Videos(logical(obj.Mean_Number_Of_Fluophores));
%             catch
%                 warning('Couldn''t identify non-empty pits.');
%             end
%             Output=CalculateDiffusionCoefficients(Videos);
%             obj.Tracking_Diffusion_Coefficient=Output(1,:);
%             obj.Tracking_Speed=Output(2,:);
%            catch
%                warning('Couldn''t track molecules in the pits.')
%            end
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

