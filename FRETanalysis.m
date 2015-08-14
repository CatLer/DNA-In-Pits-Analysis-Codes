classdef FRETanalysis<handle
    %FRETanalysis : Uses Relative Intensities in the green & red channels
    %to calculate the FRET signal for each pit. Analyzes the FRET signals
    %with a Fourier transform, the bandpower, the sfdr, the
    %autocorrelation, and other statistical tests.
    %   The properties include the FRET signals, correlation coefficients
    %   and results in the frequency space, the autocorrelation, and other
    %   signal processing tests.
%%                              PROPERTIES    
    properties
        FRET_Signals=[];
        Correlation_Coefficients=[];
        FRET_Frequency=[];
        FRET_Duration=[];
        FRET_Amplitude=[];
        Warnings={};
    end
%%                               METHODS    
methods
    %========================= CONSTRUCTOR ================================
    function obj=FRETanalysis(varargin)
        if nargin>0
            narginchk(4,4); %check # of input args
            
            %-------------------- Initialization --------------------------
            % Relative intensity in green channel
            % Relative intensity in red channel
            % Intensity of 1 green fluophore
            % Intensity of 1 red fluophore
            RIG=varargin{1};
            RIR=varargin{2};
            I1G=varargin{3};
            I1R=varargin{4};
            %--------------------------------------------------------------
            
            %------------------- FRET Signals -----------------------------
            obj.GenerateFRETSignals(RIG,RIR,I1G,I1R);
            %--------------------------------------------------------------
            
            %----------------FRET Signals Proccessing ---------------------
            obj.AnalyzeFRETSignals();
            %--------------------------------------------------------------
            
        end
    end
    %======================================================================
    
    %====================== FRET SIGNALS GENERATOR ========================
    function obj=GenerateFRETSignals(obj,RIG,RIR,I1G,I1R)
        [Signals,Coeffs]=CalculateFRETSignals(RIG,RIR,I1G,I1R);
        obj.FRET_Signals=Signals;
        obj.Correlation_Coefficients=Coeffs;
    end
    %======================================================================
    
    %======================= FRET SIGNALS ANALYZER ========================
    function obj=AnalyzeFRETSignals(obj)
        % Frequency 
        % Duration
        % Amplitude
    end
    %======================================================================
    
end
    
    methods(Static)
        % to know if a method should be static, use the rule of thumb:
        %   I can invoke the method even if no object of this class has
        %   been created. To analyze data without storing the results
        %   directly in the object properties.        
        
    end
    
end

