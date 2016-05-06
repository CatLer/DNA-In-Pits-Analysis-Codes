function [w] = DetrendingFRET(varargin)

%======================ORGANIZE DATA=======================================

%--------------------------------------------------------------------------
    if nargin ==1
        x = 1:length(varargin{1});
        x = transpose(x);
        y = varargin{1};
    else
        if nargin==2
            x = varargin{1};
            y = varargin{2};
        else
            error('Too many input arguments');
        end
    end

    if ~iscolumn(x)
        x=transpose(x);
    end
    if ~iscolumn(y)
        y=transpose(y);
    end

%--------------------------------------------------------------------------

%=====================SMOOTHING BASELINE===================================

%---------------------------Smoothing--------------------------------------

    z = smooth(x,y,'rlowess');
 %   z = smooth(x,z,'sgolay');  % in test
    offset = medfilt1(z);

%--------------------------------------------------------------------------

%======================AUTOCORRELATION=====================================

%------------------First order autocorrelation-----------------------------
 
    [r,~] = xcov(offset, 'coeff');
    r = r./max(r);

%--------------------------------------------------------------------------

%-----------------Second order autocorrelation-----------------------------

    [R,lags] = xcov(r,'coeff');
    R = R./max(R);
    
%--------------------------------------------------------------------------

%=================WINDOWSIZE USING PEAKS===================================

%-----------------------find peaks-----------------------------------------
    
    n = 0;

    % discard edges
    a = length(x);
    b = numel(R) - a+1;
    
    % find the peaks
    [M,dx] = findpeaks(smooth(R(a:b)));  % 'MinPeakHeight', 0.05
    m = numel(M);
    lags = lags(a:b);
    positions = lags(dx);
    
    if m==1
        
       [k,~] = xcov(y-offset,'coeff');
       k = k./max(k);
       [K,lags] = xcov(k,'coeff');
       K = K./max(K);
      
       % find the peaks
       [N,dx] = findpeaks(smooth(K(a:b)));
       n = numel(N);
       lags = lags(a:b);
       positions = lags(dx);
        
    end
    
    % mean index between the peaks
    if m>1 || n>1
    mean_distance = mean(diff(positions));
    end
    
%--------------------------------------------------------------------------

%====================MOVING AVERAGE FILTER=================================

    offset_prime = offset;
    
%--------------------------------------------------------------------------
   
    if m>1 || n>1

        % windowsize
        fs = ceil(mean_distance);
        % define uniform weighting vector
        wts = ones(fs,1)./fs;
        L1 = ceil((length(wts)-1)/2);
        L2 = floor((length(wts)-1)/2);

        
        offset_prime = padarray(offset,[L1,0],'symmetric', 'pre'); 
        offset_prime = padarray(offset_prime,[L2,0],'symmetric', 'post'); 
        offset_prime = conv(offset_prime,wts,'valid');
        delta = 1+1/max(m,n);
        
        for k=1:max(m,n)
            
            fs = ceil(fs/delta);
            wts = ones(fs,1)./fs;
            L1 = ceil((length(wts)-1)/2);
            L2 = floor((length(wts)-1)/2);
            
           offset_prime(1) = y(1);
           offset_prime(end) = y(end);
            
            
            offset_prime = padarray(offset_prime,[L1,0],'symmetric', 'pre'); 
            offset_prime = padarray(offset_prime,[L2,0],'symmetric', 'post');
            offset_prime = medfilt1(offset_prime,fs);            
            offset_prime = conv(offset_prime,wts,'valid');

        end
        
        offset_prime = smooth(offset_prime, 'rlowess');
        offset_prime = medfilt1(offset_prime);

    end

%--------------------------------------------------------------------------       

%===================== CURVE SHAPE ========================================
%  offset_prime(1) = y(1);
%  offset_prime(end) = y(end);
Baseline = CurvyBaseline(x,offset_prime);

%=====================REMOVE BASELINE======================================

%------------------Remove the main trend-----------------------------------
    % subtract the trend
   % w = y - offset_prime;
    w = y - Baseline;
    w = w -min(w);
    
%========================== PLOT ==========================================
     figure
     plot(x,y, 'b', x, w, 'm', x, offset_prime, '--r', x, Baseline, '--k','LineWidth', 2.0)  %, x, z, 'k'
     legend('INPUT', 'OUTPUT', 'BASELINE')
     
end

%========================= Enveloppe ======================================
%----------------------Hilbert---------------------------------------------
 
% I find the enveloppe
% k = hilbert(offset);
% env = abs(k);

