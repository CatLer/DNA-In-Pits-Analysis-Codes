classdef PitsSample<handle
    %PitsSample : Load the .tif file and stores the analysis results in
    %objects included in its properties and experimental conditions in its
    %properties.
    %   Calls the function TifSample to load .tif file. Calls the function
    %   ConstructPitsGrid to fit a grid to the pits in both channels. Needs
    %   GridRegistration.mat to be in the folder. If not available, call
    %   GridRegistration function and follow the steps at the screen. Calls
    %   the function CalculateBackground to estimate the background
    %   intensity locally. Calls the function my_mask to collect the
    %   intensities (relative,absolute,background) in the pits. my_mask
    %   normalizes the background illumination. Sets the objects
    %   PitsChannel and FRETefficiency and FRETanalysis.
    %%                           PROPERTIES
    properties
        Date=NaN;
        OBJ_T_In_Green_Laser=NaN;
        LENS_T_In_Green_Laser=NaN;
        OBJ_T_In_Blue_Laser=NaN;
        LENS_T_In_Blue_Laser=NaN; 
        
        Try_Num=NaN; % add in green laser
        Oligo_Concentration=NaN;
        pUC19_Concentration=NaN;
        Linking_Number=NaN;
        Exposure_Time_In_Green_Laser=NaN;
        Exposure_Time_In_Blue_Laser=NaN;
        Pit_Size=NaN;
        Buffer=NaN;
        
        Time_Average_Relative_Intensity_In_Green_Laser=[];
        Time_Average_Absolute_Intensity_In_Green_Laser=[];
        Time_Average_Background_Intensity_In_Green_Laser=[];       
        Time_Average_Relative_Intensity_In_Blue_Laser=[];
        Time_Average_Absolute_Intensity_In_Blue_Laser=[];
        Time_Average_Background_Intensity_In_Blue_Laser=[];
        
        Grid_Information=[];
        Cross_Talk_Coefficients=[];
        
        Green_Channel_In_Green_Laser=PitsChannel();
        Red_Channel_In_Green_Laser=PitsChannel();
        Red_Channel_In_Red_Laser=PitsChannel();
        Blue_Channel_In_Blue_Laser=[];
        OBJ_T_Red_Laser=[];
        LENS_T_Red_Laser=[];
        Exposure_Time_In_Red_Laser=[];
        
        FRET_Efficiency=FRETefficiency();
        FRET_Analysis=FRETanalysis();
        
        Pits_Positions_Red_Channel=[]; % move to grid information
        Pits_Positions_Green_Channel=[]; % move to grid information
        Pits_Positions_Blue_Channel=[];
        Pit_Radius=[]; % move to grid information
        Number_Of_Rows=0; % move to grid information
        Number_Of_Columns=0; % move to grid information
        
        Warnings={};
        
    end
    %%                              METHODS
    methods(Static)
        % to know if a method should be static, use the rule of thumb:
        %   I can invoke the method even if no object of this class has
        %   been created. To analyze data without storing the results
        %   directly in the object properties.
        %========================= STORE VIDEOS OF PITS ===================
        function intensityMap=IntensityMap(Positions,Radius,...
                numRows,numCols,Data)
            intensityMap=cell(numRows,numCols);
            for i=1:numCols
                for j=1:numRows
                    x=max(1,round(Positions((i-1)*numRows+j,1)-Radius)):...
                        min(round(Positions((i-1)*numRows+j,1)+Radius),...
                        size(Data,2));
                    y=max(1,round(Positions((i-1)*numRows+j,2)-Radius)):...
                        min(round(Positions((i-1)*numRows+j,2)+Radius),...
                        size(Data,1));
                    intensityMap{j,i}=Data(x,y,:);
                end
            end
        end
        %==================================================================
    end
    
    methods
        %============================ CONSTRUCTOR =========================
        function obj=PitsSample(varargin) 
            
            narginchk(1,2); %new
            SampleName=varargin{1}; %new
            Experiment='DualView'; %new
            if nargin==2 %new
                Experiment=varargin{2};
            end
            
            %--------------------- Load video -----------------------------
            Input=double(TifSample(SampleName));
            %--------------------------------------------------------------
            
            %-------------------- Generate grid ---------------------------
            obj.GeneratePitsGrid(Input);
            %--------------------------------------------------------------
            
            %------------------ Collect intensities -----------------------
            obj.CollectIntensitiesInPits(Input);
            %--------------------------------------------------------------    
            
            switch Experiment
            
                case 'DualView'
           
            %-------------------- FRET generator --------------------------
            obj.FRETGenerator();
            %--------------------------------------------------------------
            
                case 'SingleView'
            
            %-------------- Tracking, diffusion, binding ------------------
            
            %--------------------------------------------------------------
            
            end
            
            %-------------------- Save Pits videos ------------------------
            obj.SavePitsVideos(Input);
            %--------------------------------------------------------------
            
            % if red laser, take the grid of the corresponding green laser
            % experiment(?). Make sure to order the names such that all
            % green laser experiments are analyzed firt.
            
        end
        %==================================================================
        
        %============================ GENERATE GRID =======================
        function obj=GeneratePitsGrid(obj,Input)
            try
                obj.Grid_Information=load('GridRegistration.mat');
            catch
                error(sprintf('GridRegistration.mat wasn''t found. \n Make sure the file is in the folder to be analyzed and the grid was properly registered.')) %#ok<SPERR>
            end
            try
                [Pos_R,Pos_G,Radius,num_rows,num_cols]=...
                    ConstructPitsGrid(Input);
                obj.Pit_Radius=Radius;
                obj.Pits_Positions_Red_Channel=Pos_R;
                obj.Pits_Positions_Green_Channel=Pos_G;
                obj.Number_Of_Rows=num_rows;
                obj.Number_Of_Columns=num_cols;
            catch
                error('Couldn''t detect the pits. Can''t move forward in the analysis.')
            end
        end
        %==================================================================
        
        %======================== INTENSITIES COLLECTION ==================
        function obj=CollectIntensitiesInPits(obj,Input)
            % background
            [background,Background]=...
                CalculateBackground(Input,obj.Pit_Radius);
            obj.Time_Average_Relative_Intensity_In_Green_Laser=mean(Input-Background,3);
            obj.Time_Average_Absolute_Intensity_In_Green_Laser=mean(Input,3);
            obj.Time_Average_Background_Intensity_In_Green_Laser=mean(Background,3);
            % intensities collection
            [RIR,AIR,BIR,MBR]=...
                my_mask(Input,background,obj.Number_Of_Rows,...
                obj.Number_Of_Columns,obj.Pit_Radius,...
                obj.Pits_Positions_Red_Channel);
            [RIG,AIG,BIG,MBG]=...
                my_mask(Input,background,obj.Number_Of_Rows,...
                obj.Number_Of_Columns,obj.Pit_Radius,...
                obj.Pits_Positions_Green_Channel);
            % remove pits on the edges
            RIR=RIR(2:end-1,2:end-1,:); RIG=RIG(2:end-1,2:end-1,:);
            AIR=AIR(2:end-1,2:end-1,:); AIG=AIG(2:end-1,2:end-1,:);
            BIR=BIR(2:end-1,2:end-1,:); BIG=BIG(2:end-1,2:end-1,:);
            MBR=MBR(2:end-1,2:end-1,:); MBG=MBG(2:end-1,2:end-1,:);
            % store data in channels
            obj.Red_Channel_In_Green_Laser=PitsChannel(RIR,AIR,BIR,MBR);
            obj.Green_Channel_In_Green_Laser=PitsChannel(RIG,AIG,BIG,MBG);
        end
        %==================================================================
        
        %=========================== FRET PROCESSING ======================
        function obj=FRETGenerator(obj)
            try
                obj.Cross_Talk_Coefficients=load('CrossTalkCoeffs.mat');
            catch
                warning('CrossTalkCoeffs.mat not found.')
            end
            try
                obj.FRET_Efficiency=FRETefficiency(...
                    obj.Green_Channel_In_Green_Laser.Time_Average_Intensity,...
                    obj.Red_Channel_In_Green_Laser.Time_Average_Intensity,...
                    obj.Green_Channel_In_Green_Laser.Mean_Number_Of_Fluophores,...
                    obj.Red_Channel_In_Green_Laser.Mean_Number_Of_Fluophores);
            catch
                warning('Couldn''t compute the FRET efficiencies.')
            end
            try
                obj.FRET_Analysis=FRETanalysis(...
                    obj.Green_Channel_In_Green_Laser.Relative_Intensity,...
                    obj.Red_Channel_In_Green_Laser.Relative_Intensity,...
                    obj.Green_Channel_In_Green_Laser.Mean_Intensity_Of_1_Fluophore(1),...
                    obj.Red_Channel_In_Green_Laser.Mean_Intensity_Of_1_Fluophore(1));
            catch
                warning('Couldn''t analyze the FRET signals.')
            end
        end
        %==================================================================
        
        %=========================== SAVE PITS VIDEOS =====================
        function obj=SavePitsVideos(obj,Input)
                try
            obj.Red_Channel_In_Green_Laser.Intensity_Maps=...
                PitsSample.IntensityMap(obj.Pits_Positions_Red_Channel,...
                obj.Pit_Radius,obj.Number_Of_Rows, obj.Number_Of_Columns,Input);
                catch
                    warning('Couldn''t save videos of pits in the red channel.');
                end
                try
            obj.Green_Channel_In_Green_Laser.Intensity_Maps=...
                PitsSample.IntensityMap(obj.Pits_Positions_Green_Channel,...
                obj.Pit_Radius,obj.Number_Of_Rows,obj.Number_Of_Columns,Input);
                catch
                    warning('Couldn''t save videos of pits in the green channel.');
                end
        end
        %==================================================================
        
        %======================= RED CHANNEL IN RED LASER =================
        function obj=RedChannelInRedLaser(obj,RedLaserExpName)
            try
                RedLaserExp=double(TifSample(RedLaserExpName));
                % background
                [background,~]=...
                    CalculateBackground(RedLaserExp,obj.Pit_Radius);
                % intensities collection
                [RIR,AIR,BIR]=...
                    my_mask(RedLaserExp,background,obj.Number_Of_Rows,...
                    obj.Number_Of_Columns,obj.Pit_Radius,...
                    obj.Pits_Positions_Red_Channel);
                % remove pits on the edges
                RIR=RIR(2:end-1,2:end-1,:);
                AIR=AIR(2:end-1,2:end-1,:);
                BIR=BIR(2:end-1,2:end-1,:);
                % store data in channel
                obj.Red_Channel_In_Red_Laser=PitsChannel(RIR,AIR,BIR);
            catch
                warning('Couldn''t analyze the corresponding Red laser experiment.');
            end
        end
        %==================================================================
        
        %========================= GENERATE GRID CHECK ====================
        function GridCheck(obj)
            figure; imshow(adapthisteq(mat2gray(...
                obj.Time_Average_Absolute_Intensity_In_Green_Laser)));
            viscircles(obj.Pits_Positions_Red_Channel,...
                ones(size(obj.Pits_Positions_Red_Channel,1),1)...
                *obj.Pit_Radius,'EdgeColor','r');
            viscircles(obj.Pits_Positions_Green_Channel,...
                ones(size(obj.Pits_Positions_Green_Channel,1),1)...
                *obj.Pit_Radius,'EdgeColor','g');
        end
        %==================================================================
        
        %========================== RECOUNT MOLECULES =====================
        function obj=RecountMolecules(obj)
            CountTheNumberOfFluophores(obj.Green_Channel_In_Green_Laser);
            CountTheNumberOfFluophores(obj.Red_Channel_In_Green_Laser);
        end
        %==================================================================
        
        %=================== RECALCULATE DIFFUSION COEFFICIENTS ===========
        function obj=TrackingDiffusionAnalysis(obj)
            TrackingAnalysis(obj.Green_Channel_In_Green_Laser);
            TrackingAnalysis(obj.Red_Channel_In_Green_Laser);
        end
        
        function obj=IntensityDiffusionAnalysis(obj)
            DiffusionAnalysis(obj.Green_Channel_In_Green_Laser);
            DiffusionAnalysis(obj.Red_Channel_In_Green_Laser);
        end
        %==================================================================
    end
    
    
end

