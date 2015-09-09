function [Output]=FluophoreTracking(Input)
%FluophoreTracking: Estimates the diffusion coefficient from an array of
%images of a single pit (in a bounding box). 
%Uses thresholding and denoising. Convolves a gaussian with sigma set to 2
%pixels, to smooth the intensity distribution and locate hot regions. Uses
%dilatation to locate the maxima. Uses cross-correlation between
%consecutive images to estimate the shifts (displacements) of the points of
%the interest. Determines the average displacement and estimates the
%diffusion coefficient. Doesn't track the molecule(s).

%% ======================= INPUT PARAMETERS ===============================

%------------------------- check array length -----------------------------
if size(Input,3)<=1
    warning('Only 1 frame. Couldn''t compute the diffusion coefficient.')
    Output=[];
    return;
end
%--------------------------------------------------------------------------

%--------------------------- set parameters -------------------------------
% set dx (1 pixel = ? µm), set dt (1 frame = ? s), set w (how many frames)
dx=0.15; dt=50/1000; w=1000; Length=min(w,size(Input,3));
Radius=round(mean(size(Input(:,:,1)))/2); Input=Input(:,:,1:Length);
% circle of radius sigma (in pixels) containing ~68% of the intensity of 1
% molecule and relaxation parameter in percentage of the max peak intensity
% to be considered a molecule
sigma=1; relaxation=0.5;
%--------------------------------------------------------------------------

%==========================================================================
%% ================== THRESHOLDING AND DENOISING ==========================

%-------------- pad input frames for local maxima search ------------------
Input=cat(2,zeros(size(Input,1),1,size(Input,3)),...
    Input,zeros(size(Input,1),1,size(Input,3)));
Input=cat(1,zeros(1,size(Input,2),size(Input,3)),...
    Input,zeros(1,size(Input,2),size(Input,3)));
%--------------------------------------------------------------------------

%-------------------- convert input to cell array -------------------------
Input=mat2cell(Input,size(Input,1),size(Input,2),ones(1,size(Input,3)));
%--------------------------------------------------------------------------

%------------------- determine threshold using variance -------------------
y=Input{:}; y=y(:); Level=mean(y)+var(y)/mean(y); % molecular brightness
InputPrime=cellfun(@(x)x.*(x>=Level),Input,'UniformOutput',false);
%--------------------------------------------------------------------------

%---------------- remove noise by applying a wiener filter ----------------
NOISE=mean(cell2mat(cellfun(@(x)bandpower(x(:)),InputPrime,...
    'UniformOutput',false)));
InputPrime=cellfun(@(x)wiener2(x,[1,1]*round(6*sigma),NOISE),...
    InputPrime,'UniformOutput',false);
%--------------------------------------------------------------------------

%==========================================================================
%% ================= CONVOLUTION WITH GAUSSIAN ============================

%------------------------ generate 2D gaussian ----------------------------
N = Radius; x=-N:N; [X,Y]=meshgrid(x);
Gaussian3D=exp(-(X.^2/(2*sigma^2))-(Y.^2/(2*sigma^2)));
%--------------------------------------------------------------------------

%---------------------------- convolution ---------------------------------
NewInput=cellfun(@(x)FastConv(x,Gaussian3D),InputPrime,'UniformOutput',false);
%--------------------------------------------------------------------------

%---------------------------- fast convolution ----------------------------
    function e=FastConv(a,b) 
        m=size(a,1)+size(b,1)-1; 
        n=size(a,2)+size(b,2)-1; 
        c=fft2(a,m,n); d=fft2(b,m,n);
        e=ifft2(c.*d); 
        m1=(size(b,1)-1)/2; n1=(size(b,2)-1)/2; 
        e=e(ceil(m1)+1:end-floor(m1),ceil(n1)+1:end-floor(n1)); 
    end
%--------------------------------------------------------------------------

%==========================================================================
%% ========================= PEAKS DETECTION ==============================

%----------------------------- skewness -----------------------------------
Skewness=cellfun(@(x)skewness(x(:))>0.5,NewInput,'UniformOutput',false);
% 0.5-1.0 moderately positively skewed 
% >1.0 highly positively skewed
%--------------------------------------------------------------------------

%---------------------- collapse local maxima -----------------------------
mat=[1,1,1;1,0,1;1,1,1];
NewInputPrime=cellfun(@(x)x.*(x>imdilate(x,mat)),...
    NewInput,'UniformOutput',false);
%--------------------------------------------------------------------------

%------------------------- maxima selection -------------------------------
NewInputPrime=cellfun(@(x)x.*(x>=relaxation*max(x(:))),NewInputPrime,...
    'UniformOutput',false); 
NewInputPrime=cellfun(@(x,y)x*y,NewInputPrime,Skewness,'UniformOutput',...
    false);
%--------------------------------------------------------------------------

%--------------------------- peaks detection ------------------------------
Positions=cellfun(@(x)struct2cell(regionprops(logical(x),'Centroid')),...
    NewInputPrime,'UniformOutput',false);
Positions=cellfun(@(x)cell2mat(reshape(x,numel(x),1)),...
    Positions,'UniformOutput',false);
Positions=cellfun(@ifEmpty,Positions,'UniformOutput',false); % for later
    function x=ifEmpty(x)
       if isempty(x)
           x=zeros(0,2);
       end
    end
%--------------------------------------------------------------------------

%==========================================================================
%% ======================== PROBABILITIES =================================

%---------- all possible displacements in a pair of frames ----------------
Distances=cellfun(@(x,y)pdist2(x,y),Positions(1:end-1),...
    Positions(2:end),'UniformOutput',false);
%--------------------------------------------------------------------------

%----------------------- gaussian distribution ----------------------------
Probabilities=cellfun(@(x)normpdf(x,mean(x(:)),std(x(:))),...
    Distances,'UniformOutput',false);
Probabilities=cellfun(@ifNaN,Probabilities,'UniformOutput',false);
    function x=ifNaN(x)
        x(isnan(x))=1;
    end
%--------------------------------------------------------------------------

%==========================================================================
%% ==================== EXPECTED DISPLACEMENTS ============================

%------------------ expected displacement per frame -----------------------
Distances=cellfun(@(x,y)x.*y,Distances,Probabilities,...
    'UniformOutput',false);
Distances=cellfun(@(x)x(~isnan(x)),Distances,'UniformOutput',false);
Distances=permute(cell2mat(cellfun(@mySum,Distances,...
    'UniformOutput',false)),[3,2,1]);
    function x=mySum(x)
        if ~isempty(x)
            x=sum(x);
        else
            x=NaN;
        end
    end
Distances=Distances(~isnan(Distances))*dx;
%--------------------------------------------------------------------------

%----------------- expected x displacement per frame ----------------------
XDistances=cellfun(@(x)x(:,1),Positions,'UniformOutput',false);
XDistances=cellfun(@(x,y)pdist2(x,y),XDistances(1:end-1),...
    XDistances(2:end),'UniformOutput',false);
XDistances=cellfun(@(x,y)x.*y,XDistances,Probabilities,...
    'UniformOutput',false);
XDistances=cellfun(@(x)x(~isnan(x)),XDistances,'UniformOutput',false);
XDistances=permute(cell2mat(cellfun(@mySum,XDistances,...
    'UniformOutput',false)),[3,2,1]);
XDistances=XDistances(~isnan(XDistances))*dx;
%--------------------------------------------------------------------------

%----------------- expected y displacement per frame ----------------------
YDistances=cellfun(@(x)x(:,2),Positions,'UniformOutput',false);
YDistances=cellfun(@(x,y)pdist2(x,y),YDistances(1:end-1),...
    YDistances(2:end),'UniformOutput',false);
YDistances=cellfun(@(x,y)x.*y,YDistances,Probabilities,...
    'UniformOutput',false);
YDistances=cellfun(@(x)x(~isnan(x)),YDistances,'UniformOutput',false);
YDistances=permute(cell2mat(cellfun(@mySum,YDistances,...
    'UniformOutput',false)),[3,2,1]);
YDistances=YDistances(~isnan(YDistances))*dx;
%--------------------------------------------------------------------------

%==========================================================================
%%                    DIFFUSION COEFFICIENT METHOD 1
Distance=mean(Distances);
Distance_error=std(Distances);
Speed=Distance/dt;
Speed_error=Distance_error/dt;
D=(Distance)^2/(4*dt);
D_error=Distance_error/(2*dt);
Output=[D,Speed];

%%                          STATISTICS
% StatsSpeedx=[mean(XDistances/dt),std(XDistances/dt),...
%     skewness(XDistances/dt),kurtosis(XDistances/dt)];
% StatsSpeedy=[mean(YDistances/dt),std(YDistances/dt),...
%     skewness(YDistances/dt),kurtosis(YDistances/dt)];
% StatsSpeed=[mean(Distances/dt),std(Distances/dt),...
%     skewness(Distances/dt),kurtosis(Distances/dt)];
%%                           VISUALIZATION
% figure; % component velocity distributions
% subplot(1,3,1);
% T=1:numel(XDistances); 
% % Time=1:size(Input,3); Time=Time*dt; Time=Time(CatchMe);
% % Time=Time(1:0.1*numel(T):numel(T));
% % Time=num2cell(Time); Time=cellfun(@num2str,Time,'UniformOutput',false);
% plot(T,XDistances/dt,'--ob');
% ylabel('Speed (µm/s)','FontSize',14); xlabel('Time (s)','FontSize',14);
% title('x-Component','FontSize',16);
% % set(gca,'Xtick',1:0.1*numel(T):numel(T),'XTickLabel',Time);
% subplot(1,3,2);
% T=1:numel(YDistances);
% plot(T,YDistances/dt,'--om');
% ylabel('Speed (µm/s)','FontSize',14); xlabel('Time (s)','FontSize',14);
% title('y-Component','FontSize',16);
% subplot(1,3,3);
% T=1:numel(Distances);
% plot(T,Distances/dt,'--om');
% ylabel('Speed (µm/s)','FontSize',14); xlabel('Time (s)','FontSize',14);
% title('Norm','FontSize',16);
% % set(gca,'Xtick',1:0.1*numel(T):numel(T),'XTickLabel',Time);
% figure; 
% subplot(1,3,1); 
% try
%     histfit(XDistances/dt,10);
% t=sprintf('Mean: %f \n std: %f \n skewness: %f \n kurtosis: %f',StatsSpeedx);
% h = annotation('textbox',[0.36,0.64,0.1,0.14],'String',t); set(h,'FontSize',12);
% title('x-Component','FontSize',16); 
% ylabel('Counts','FontSize',14); xlabel('Speed (µm/s)','FontSize',14);
% catch
% end
% subplot(1,3,2); 
% try
%     histfit(YDistances/dt,10);
% t=sprintf('Mean: %f \n std: %f \n skewness: %f \n kurtosis: %f',StatsSpeedy);
% h = annotation('textbox',[0.80,0.66,0.1,0.14],'String',t); set(h,'FontSize',12);
% title('y-Component','FontSize',16); 
% ylabel('Counts','FontSize',14); xlabel('Speed (µm/s)','FontSize',14);
% catch
% end
% subplot(1,3,3); 
% try
%     figure;
% histfit(Distances/dt,10);
% t=sprintf('Mean: %f \n std: %f \n skewness: %f \n kurtosis: %f',StatsSpeed);
% h = annotation('textbox',[0.80,0.66,0.1,0.14],'String',t); set(h,'FontSize',12);
% title('Norm','FontSize',16); 
% ylabel('Counts','FontSize',14); xlabel('Speed (µm/s)','FontSize',14);
% catch
% end
%=========================== DEMONSTRATION ================================
% Frame= round(rand(1)*(Length-2));
% figure;
% subplot(4,3,1); surf(Input{Frame}); 
% shading interp; axis tight; view(2); title('Frame 1');
% subplot(4,3,2); surf(Input{Frame+1}); 
% shading interp; axis tight; view(2); title('Frame 2')
% subplot(4,3,3); surf(Input{Frame+2}); 
% shading interp; axis tight; view(2); title('Frame 3')
% subplot(4,3,4); surf(InputPrime{Frame}); 
% shading interp; axis tight; view(2); title('Frame 1');
% subplot(4,3,5); surf(InputPrime{Frame+1}); 
% shading interp; axis tight; view(2); title('Frame 2')
% subplot(4,3,6); surf(InputPrime{Frame+2}); 
% shading interp; axis tight; view(2); title('Frame 3')
% subplot(4,3,7); surf(NewInput{Frame}); 
% shading interp; axis tight; view(2); title('Frame 1');
% subplot(4,3,8); surf(NewInput{Frame+1}); 
% shading interp; axis tight; view(2); title('Frame 2')
% subplot(4,3,9); surf(NewInput{Frame+2}); 
% shading interp; axis tight; view(2); title('Frame 3')
% subplot(4,3,10); surf(NewInputPrime{Frame}); 
% shading interp; axis tight; view(2); title('Frame 1');
% subplot(4,3,11); surf(NewInputPrime{Frame+1}); 
% shading interp; axis tight; view(2); title('Frame 2')
% subplot(4,3,12); surf(NewInputPrime{Frame+2}); 
% shading interp; axis tight; view(2); title('Frame 3')
% colormap hot;
%==========================================================================
%%                      DIFFUSION COEFFICIENT
% [Ax,Lags]=xcorr(Speeds_x,'coeff'); [Ay,~]=xcorr(Speeds_y,'coeff');
% A=Ax+Ay; A=A(Lags>=0); Lags=Lags(Lags>=0); figure; plot(Lags,A,'--or');
% Dprime=sum(A)*dt/4;
end

