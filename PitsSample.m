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
        Last_Modification_Date=NaN;
        OBJ_T_In_Green_Laser=NaN;
        LENS_T_In_Green_Laser=NaN;
        OBJ_T_Red_Laser=NaN;
        LENS_T_Red_Laser=NaN;     
        OBJ_T_In_Blue_Laser=NaN;
        LENS_T_In_Blue_Laser=NaN;
        Laser=NaN;
        
        Try_Num=NaN; % add in green laser
        Oligo_Concentration=NaN;
        pUC19_Concentration=NaN;
        Linking_Number=NaN;
        Exposure_Time_In_Green_Laser=NaN;
        Exposure_Time_In_Red_Laser=NaN; 
        Exposure_Time_In_Blue_Laser=NaN;        
        Pit_Size=NaN;
        Buffer=NaN;
        Experiment=[];
        
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
        Blue_Channel_In_Blue_Laser=PitsChannel();    
        
        FRET_Efficiency=FRETefficiency();
        FRET_Analysis=FRETanalysis();
        
        Default_Grid_Used=[];
        Pits_Positions_Red_Channel=[]; 
        Pits_Positions_Green_Channel=[]; 
        Pits_Positions_Blue_Channel=[];
        Pit_Radius=[]; 
        Number_Of_Rows=0; 
        Number_Of_Columns=0; 
        
        MatFileName={};
        FullPath={};
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
            if ~isempty(varargin)
            narginchk(3,5);
            GridRegistrationFile=varargin{1};
            MainLaser=varargin{2};
            obj.Laser=MainLaser;
            SampleName=varargin{3}; 
            obj.Experiment='DualView'; 
            if nargin>=4
                obj.Experiment=varargin{4};
                if nargin==5
                    obj.Default_Grid_Used=varargin{5};
                end
            end
            
            %--------------------- Load video -----------------------------
            Input=double(TifSample(SampleName));
            %--------------------------------------------------------------
            
            if isempty(obj.Default_Grid_Used)
            %-------------------- Generate grid ---------------------------
            obj.GeneratePitsGrid(Input,MainLaser,GridRegistrationFile);
            %--------------------------------------------------------------
            else
                if size(obj.Default_Grid_Used,2)==5
                obj.Pit_Radius=obj.Default_Grid_Used{3};
                obj.Pits_Positions_Red_Channel=obj.Default_Grid_Used{1};
                obj.Pits_Positions_Green_Channel=obj.Default_Grid_Used{2};
                obj.Number_Of_Rows=obj.Default_Grid_Used{4};
                obj.Number_Of_Columns=obj.Default_Grid_Used{5};   
                else
                    if size(obj.Default_Grid_Used,2)==4
                obj.Pit_Radius=obj.Default_Grid_Used{2};
                if strcmpi(MainLaser,'Green Laser')
                obj.Pits_Positions_Green_Channel=obj.Default_Grid_Used{1};
                end
                if strcmpi(MainLaser,'Blue Laser')
                obj.Pits_Positions_Blue_Channel=obj.Default_Grid_Used{1};
                end                
                obj.Number_Of_Rows=obj.Default_Grid_Used{3};
                obj.Number_Of_Columns=obj.Default_Grid_Used{4};                          
                    end
                end
            end
            
            %------------------ Collect intensities -----------------------
            obj.CollectIntensitiesInPits(Input,MainLaser);
            %--------------------------------------------------------------    
            
            switch obj.Experiment
            
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
            
            obj.FullPath=which(SampleName);
            
            end
        end
        %==================================================================
        
        %============================ GENERATE GRID =======================
        function obj=GeneratePitsGrid(obj,Input,MainLaser,GridRegistrationFile)
            try
                if strcmpi(obj.Experiment,'DualView')
                [Pos_R,Pos_G,Radius,num_rows,num_cols]=...
                    ConstructPitsGrid(Input,0,obj.Experiment,GridRegistrationFile);
                else
                [Pos_G,Radius,num_rows,num_cols]=...
                    ConstructPitsGrid(Input,0,obj.Experiment,GridRegistrationFile);
                Pos_R=[];
                end
                obj.Pit_Radius=Radius;
                obj.Pits_Positions_Red_Channel=Pos_R;
                if strcmp(MainLaser, 'Blue Laser')
                    obj.Pits_Positions_Blue_Channel=Pos_G;
                    obj.Pits_Positions_Green_Channel=[];
                else
                    if strcmp(MainLaser, 'Green Laser')
                        obj.Pits_Positions_Blue_Channel=[];
                        obj.Pits_Positions_Green_Channel=Pos_G;
                    end
                end
                obj.Number_Of_Rows=num_rows;
                obj.Number_Of_Columns=num_cols;
            catch
                error('Couldn''t detect the pits. Can''t move forward in the analysis.')
            end
        end
        %==================================================================
        
        %======================== INTENSITIES COLLECTION ==================
        function obj=CollectIntensitiesInPits(obj,Input,MainLaser)
            % background
            [background,Background]=...
                CalculateBackground(Input,obj.Pit_Radius);
            if strcmp(MainLaser,'Green Laser')
                obj.Time_Average_Relative_Intensity_In_Green_Laser=mean(Input-Background,3);
                obj.Time_Average_Absolute_Intensity_In_Green_Laser=mean(Input,3);
                obj.Time_Average_Background_Intensity_In_Green_Laser=mean(Background,3);
            else
                if strcmp(MainLaser,'Blue Laser')
                    obj.Time_Average_Relative_Intensity_In_Blue_Laser=mean(Input-Background,3);
                    obj.Time_Average_Absolute_Intensity_In_Blue_Laser=mean(Input,3);
                    obj.Time_Average_Background_Intensity_In_Blue_Laser=mean(Background,3);
                end
            end
            % intensities collection
            if ~isempty(obj.Pits_Positions_Red_Channel)
            [RIR,AIR,BIR,RVR,AVR,BVR,POSR,BGR,IPR]=... 
                my_mask(Input,background,obj.Number_Of_Rows,...
                obj.Number_Of_Columns,obj.Pit_Radius,...
                obj.Pits_Positions_Red_Channel);
            else
                RIR=[]; AIR=[]; BIR=[]; 
                RVR=[]; AVR=[]; BVR=[]; 
                POSR=[]; BGR=[]; IPR=[];
            end 
            if ~isempty(obj.Pits_Positions_Green_Channel)
            [RIG,AIG,BIG,RVG,AVG,BVG,POSG,BGG,IPG]=... 
                my_mask(Input,background,obj.Number_Of_Rows,...
                obj.Number_Of_Columns,obj.Pit_Radius,...
                obj.Pits_Positions_Green_Channel);
            else
                RIG=[]; AIG=[]; BIG=[]; 
                RVG=[]; AVG=[]; BVG=[]; 
                POSG=[]; BGG=[]; IPG=[];
            end
            if ~isempty(obj.Pits_Positions_Blue_Channel)
            [RIB,AIB,BIB,RVB,AVB,BVB,POSB,BGB,IPB]=... 
                my_mask(Input,background,obj.Number_Of_Rows,...
                obj.Number_Of_Columns,obj.Pit_Radius,...
                obj.Pits_Positions_Blue_Channel);
            else
                RIB=[]; AIB=[]; BIB=[]; 
                RVB=[]; AVB=[]; BVB=[]; 
                POSB=[]; BGB=[]; IPB=[];
            end  
            % store data in channels            
            obj.Blue_Channel_In_Blue_Laser=PitsChannel(...
                RIB,AIB,BIB,RVB,POSB,AVB,BVB,BGB,obj.Pit_Radius,IPB);   
            obj.Green_Channel_In_Green_Laser=PitsChannel(...
                RIG,AIG,BIG,RVG,POSG,AVG,BVG,BGG,obj.Pit_Radius,IPG);
            obj.Red_Channel_In_Green_Laser=PitsChannel(...
                RIR,AIR,BIR,RVR,POSR,AVR,BVR,BGR,obj.Pit_Radius,IPR);
        end
        %==================================================================
        %============== BINDING STATISTICS ===========**********===========
        function obj=GiveMeBindingStatistics(obj,ExposureTime,Binding_Parameter)
            MainLaser=obj.Laser; Type=obj.Experiment;
            if isempty(ExposureTime) || isnan(ExposureTime) %%%%%%
                ExposureTime=50;
            end
            if strcmp(MainLaser,'Green Laser')
                if isempty(obj.Exposure_Time_In_Green_Laser)||...
                    isnan(obj.Exposure_Time_In_Green_Laser)
                obj.Exposure_Time_In_Green_Laser=ExposureTime;
                else
                    ExposureTime=obj.Exposure_Time_In_Green_Laser;
                end
            else 
                if strcmp(MainLaser,'Blue Laser')
                    if isempty(obj.Exposure_Time_In_Blue_Laser)||...
                    isnan(obj.Exposure_Time_In_Blue_Laser)
                    obj.Exposure_Time_In_Blue_Laser=ExposureTime;
                    else
                        ExposureTime=obj.Exposure_Time_In_Blue_Laser;
                    end
                else
                    if strcmp(MainLaser,'Red Laser')
                        if isempty(obj.Exposure_Time_In_Red_Laser)||...
                    isnan(obj.Exposure_Time_In_Red_Laser)
                        obj.Exposure_Time_In_Red_Laser=ExposureTime;
                        else
                            ExposureTime=obj.Exposure_Time_In_Red_Laser;
                        end
                    end
                end
            end                    
                       
            if strcmp(Type,'DualView')
                if strcmp(MainLaser,'Green Laser')
                    Expr=sprintf(...
                        'obj.Green_Channel_In_Green_Laser.Exposure_Time=%f;',...
                        ExposureTime);
                    eval(Expr);
                    Expr=sprintf(...
                        'obj.Green_Channel_In_Green_Laser.GenerateStatisticsBinding(%f);',Binding_Parameter);
                    eval(Expr);
                    Expr=sprintf(...
                        'obj.Red_Channel_In_Green_Laser.Exposure_Time=%f;',...
                        ExposureTime);
                    eval(Expr);
                    Expr=sprintf(...
                        'obj.Red_Channel_In_Green_Laser.GenerateStatisticsBinding(%f);',Binding_Parameter);
                    eval(Expr);
                end
            else
                if strcmp(Type,'SingleView')
                    if strcmp(MainLaser,'Green Laser')
                        Expr=sprintf(...
                            'obj.Green_Channel_In_Green_Laser.Exposure_Time=%f;',...
                            ExposureTime);
                        eval(Expr);
                        Expr=sprintf(...
                            'obj.Green_Channel_In_Green_Laser.GenerateStatisticsBinding(%f);',Binding_Parameter);
                        eval(Expr);
                    else
                        if strcmp(MainLaser,'Blue Laser')
                            Expr=sprintf(...
                                'obj.Blue_Channel_In_Blue_Laser.Exposure_Time=%f;',...
                                ExposureTime);
                            eval(Expr);
                            Expr=sprintf(...
                                'obj.Blue_Channel_In_Blue_Laser.GenerateStatisticsBinding(%f);',Binding_Parameter);
                            eval(Expr);
                        end
                    end
                end
            end
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
                % store data in channel
                obj.Red_Channel_In_Red_Laser=PitsChannel(RIR,AIR,BIR);
            catch
                warning('Couldn''t analyze the corresponding Red laser experiment.');
            end
        end
        %==================================================================
        
        %========================= GENERATE GRID CHECK ====================
        function GridCheck(obj,varargin)
            WantedDisplaySize=[512,512];
            f=figure;
            MainLaser=obj.Laser;
            if strcmp(MainLaser,'Green Laser')
                imshow(adapthisteq(mat2gray(...
                    obj.Time_Average_Absolute_Intensity_In_Green_Laser)),...
                    'InitialMagnification','fit');
                truesize(gcf,WantedDisplaySize);
                viscircles(obj.Pits_Positions_Red_Channel,...
                    ones(size(obj.Pits_Positions_Red_Channel,1),1)...
                    *obj.Pit_Radius,'EdgeColor','r');
                viscircles(obj.Pits_Positions_Green_Channel,...
                    ones(size(obj.Pits_Positions_Green_Channel,1),1)...
                    *obj.Pit_Radius,'EdgeColor','g');
            else
                if strcmp(MainLaser,'Blue Laser')
                    imshow(adapthisteq(mat2gray(...
                        obj.Time_Average_Absolute_Intensity_In_Blue_Laser)));
                    viscircles(obj.Pits_Positions_Blue_Channel,...
                        ones(size(obj.Pits_Positions_Blue_Channel,1),1)...
                        *obj.Pit_Radius,'EdgeColor','b');
                end
            end
            if nargin>1
                set(f,'visible','off');
            end
        end
        %==================================================================
        
        %========================== COLLAPSED IMAGES ======================
        function CollapseFrames(obj,varargin)
            if nargin>1
            figure('visible','off');
            else
                figure;
            end
            MainLaser=obj.Laser;
            if strcmp(MainLaser,'Green Laser')
                subplot(1,3,1);                
                surf(obj.Time_Average_Absolute_Intensity_In_Green_Laser);
                shading interp; colormap hot; view(2);
                set(gca,'xLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Green_Laser,2)]);
                set(gca,'yLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Green_Laser,1)]);                
                title('Absolute Intensity');
                subplot(1,3,2);                
                surf(obj.Time_Average_Relative_Intensity_In_Green_Laser);
                shading interp; colormap hot; view(2);
                set(gca,'xLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Green_Laser,2)]); 
                set(gca,'yLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Green_Laser,1)]);                
                title('Relative Intensity');
                subplot(1,3,3);
                surf(obj.Time_Average_Background_Intensity_In_Green_Laser);
                shading interp; colormap hot; view(2);   
                set(gca,'xLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Green_Laser,2)]);  
                set(gca,'yLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Green_Laser,1)]);                
                title('Background Intensity');
                if nargin>1
                figure('visible','off');
                else
                    figure;
                end
                surf(obj.Green_Channel_In_Green_Laser.Background_Illumination_Profile);
                shading interp; colormap hot; view(3)
                title('Background Illumination Profile');
            else
                if strcmp(MainLaser,'Blue Laser')
                subplot(1,3,1);
                surf(obj.Time_Average_Absolute_Intensity_In_Blue_Laser);
                shading interp; colormap hot; view(2);
                set(gca,'xLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Blue_Laser,2)]);
                set(gca,'yLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Blue_Laser,1)]);                
                title('Absolute Intensity');
                subplot(1,3,2);               
                surf(obj.Time_Average_Relative_Intensity_In_Blue_Laser);
                shading interp; colormap hot; view(2); 
                set(gca,'xLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Blue_Laser,2)]);  
                set(gca,'yLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Blue_Laser,1)]);                
                title('Relative Intensity');
                subplot(1,3,3);
                surf(obj.Time_Average_Background_Intensity_In_Blue_Laser);
                shading interp; colormap hot; view(2);  
                set(gca,'xLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Blue_Laser,2)]); 
                set(gca,'yLim',...
                    [1,size(obj.Time_Average_Absolute_Intensity_In_Blue_Laser,1)]);                
                title('Background Intensity');
                surf(obj.Blue_Channel_In_Blue_Laser.Background_Illumination_Profile);
                shading interp; colormap hot; view(3)
                title('Background Illumination Profile');                
                end
            end            
        end
        %==================================================================
        
        %========================== RECOUNT MOLECULES =====================
        function obj=RecountMolecules(obj)
            CountTheNumberOfFluophores(obj.Green_Channel_In_Green_Laser);
            CountMoleculesFromSamples(obj.Green_Channel_In_Green_Laser);
            CountTheNumberOfFluophores(obj.Red_Channel_In_Green_Laser);
            CountMoleculesFromSamples(obj.Red_Channel_In_Green_Laser);
            CountTheNumberOfFluophores(obj.Red_Channel_In_Red_Laser);
            CountMoleculesFromSamples(obj.Red_Channel_In_Red_Laser);
            CountTheNumberOfFluophores(obj.Blue_Channel_In_Blue_Laser);
            CountMoleculesFromSamples(obj.Blue_Channel_In_Blue_Laser); 
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
        
        %==================================================================
        function obj=PlotHistogramsBinding(obj)
            laser=strrep(obj.Laser,' Laser','');
            if strcmp(laser,'Blue')
                channel='Blue';
            else
                if strcmp(laser,'Green')
                    channel='Green';
                end    
            end
%             List_Channel={'Green Channel','Red Channel','Blue Channel'};
%             S=listdlg('ListString',List_Channel,'SelectionMode','Single');
%             channel=List_Channel(S); channel=strrep(channel{1},' Channel','');
            if isempty(channel) || isempty(laser)
                return;
            end
            VAR_UB=eval(sprintf(...
                'obj.%s_Channel_In_%s_Laser.Variance_In_Time_Upper_Bound;',...
                channel,laser)); %#ok<*PFCEL>            
            VAR_LB=eval(sprintf(...
                'obj.%s_Channel_In_%s_Laser.Variance_In_Time_Lower_Bound;',...
                channel,laser)); 
            VAR_DB=eval(sprintf(...
                'obj.%s_Channel_In_%s_Laser.Variance_In_Time_Variation;',...
                channel,laser));
            figure; 
            subplot(1,3,1); hist(VAR_LB(:)); set(get(gca,'child'),'FaceColor','c');
            title('Spatial Variance Lower Bound','fontsize',14);
            subplot(1,3,2); hist(VAR_UB(:)); set(get(gca,'child'),'FaceColor','g');
            title('Spatial Variance Upper Bound','fontsize',14);
            subplot(1,3,3); hist(VAR_DB(:)); set(get(gca,'child'),'FaceColor','m');
            title('Spatial Average Variation','fontsize',14);
        end
        %==================================================================
        
        function obj=DetectBinding(obj,Recalculate,Showme)
            if Recalculate==1
           SampledSpatialVariance(obj.Green_Channel_In_Green_Laser);
           CountMoleculesFromSamples(obj.Green_Channel_In_Green_Laser);
           SampledSpatialVariance(obj.Red_Channel_In_Green_Laser);
           CountMoleculesFromSamples(obj.Red_Channel_In_Green_Laser);
           SampledSpatialVariance(obj.Red_Channel_In_Red_Laser);
           CountMoleculesFromSamples(obj.Red_Channel_In_Red_Laser);
           SampledSpatialVariance(obj.Blue_Channel_In_Blue_Laser);
           CountMoleculesFromSamples(obj.Blue_Channel_In_Blue_Laser);
            end
        
            if Showme==1
            List_Channel={'Green Channel','Red Channel','Blue Channel'};
            S=listdlg('ListString',List_Channel,'SelectionMode','Single');
            channel=List_Channel(S); channel=strrep(channel{1},' Channel','');
            List_Laser={'Green Laser','Red Laser','Blue Laser'};
            S=listdlg('ListString',List_Laser,'SelectionMode','Single');
            laser=List_Laser(S); laser=strrep(laser{1},' Laser','');
            if isempty(channel) || isempty(laser)
                return;
            end
            
            Av=eval(sprintf(...
                'obj.%s_Channel_In_%s_Laser.Sampled_Average_Intensity;',...
                channel,laser));
            AV=[];
            if ~isempty(Av)
                for p=1:size(Av,1)
                    for q=1:size(Av,2)
                        a=Av{p,q};
                        if iscell(a)
                            a=cell2mat(a);
                        end
                   AV=cat(2,AV,a);
                    end
                end
            end            
            
            lb=eval(sprintf(...
                'obj.%s_Channel_In_%s_Laser.Sampled_Variance_Lower_Bound;',...
                channel,laser));
            LB=[];
            if ~isempty(lb)
                for p=1:size(lb,1)
                    for q=1:size(lb,2)
                        a=lb{p,q};
                        if iscell(a)
                            a=cell2mat(a);
                        end
                   LB=cat(1,LB,a(:));
                    end
                end
            end            
            
            ub=eval(sprintf(...
                'obj.%s_Channel_In_%s_Laser.Sampled_Variance_Upper_Bound;',...
                channel,laser));
            UB=[];
            if ~isempty(ub)
                for p=1:size(ub,1)
                    for q=1:size(ub,2)
                        a=ub{p,q};
                        if iscell(a)
                            a=cell2mat(a);
                        end
                   UB=cat(1,UB,a(:));
                    end
                end
            end                       
            
            eval(sprintf(...
                'obj.%s_Channel_In_%s_Laser.CountMoleculesFromSamples();',...
                channel,laser));
            
            figure; subplot(1,3,1); hist(AV); 
            subplot(1,3,2); hist(LB); subplot(1,3,3); hist(UB);       
            end
            
        end
        
        %==================================================================
        function obj=RecalculateUsingNewGrid(obj,Video)
%             
%             if nargin==0
%             Input=double(TifSample(obj.FullPath));
%             else
%                 Video=varargin{1};
            %--------------------- Load video -----------------------------
            Input=double(TifSample(Video));
            %--------------------------------------------------------------
%             end
            
            %------------------ Collect intensities -----------------------
            obj.CollectIntensitiesInPits(Input);
            %-------------------------------------------------------------- 
            
%             if nargin==1
%             obj.FullPath=which(Video);
%             end
            
        end
        %==================================================================
        function SaveSample(obj,varargin)
            narginchk(1,2);
            myname=inputname(1);
            myfile='';
            if nargin==1
                if isempty(obj.MatFileName)
                    [FileName,PathName]=uiputfile('*.mat',myname);
                    if isequal(FileName,0)
                        sprintf('No file!!! (^<')
                        return;
                    end
                    myfile=fullfile(PathName,FileName);
                else
                    myfile=obj.MatFileName;
                end
            else
                if ischar(varargin{1})
                else
                    [FileName,PathName]=uiputfile('*.mat',myname);
                    if isequal(FileName,0)
                        sprintf('No file!!! (^<')
                        return;
                    end
                    myfile=fullfile(PathName,FileName);
                end
            end
            if isempty(myfile)
                return;
            else
                % save object
                obj.MatFileName=myfile;
                obj.Last_Modification_Date=datestr(now);
                expression=strcat('save(''',myfile,''',''',myname,''')');
                evalin('base',expression);
                sprintf('Done!')
            end
        end
        
    end
    
    
end

