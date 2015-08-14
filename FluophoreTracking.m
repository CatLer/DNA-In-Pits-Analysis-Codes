function [D]=FluophoreTracking(Input)
%FluophoreTracking: Estimates the diffusion coefficient from an array of
%images of a single pit (in a bounding box). 
%Uses thresholding and denoising. Convolves a gaussian with sigma set to 2
%pixels, to smooth the intensity distribution and locate hot regions. Uses
%dilatation to locate the maxima. Uses cross-correlation between
%consecutive images to estimate the shifts (displacements) of the points of
%the interest. Determines the average displacement and estimates the
%diffusion coefficient. Doesn't track the molecule(s).
%%                              INPUT TYPE 
% set dx (1 pixel = ? m), set dt (1 frame = ? s)
dx=0.15; dt=50/1000; Length=size(Input,3);
Radius=round(mean(size(Input(:,:,1)))/2);
if size(Input,3)<=1
    return;
end
Center=fliplr(size(Input(:,:,1)));
%------------------------------- Pad Input --------------------------------
Input=cat(2,zeros(size(Input,1),1,size(Input,3)),...
    Input,zeros(size(Input,1),1,size(Input,3)));
Input=cat(1,zeros(1,size(Input,2),size(Input,3)),...
    Input,zeros(1,size(Input,2),size(Input,3)));
%--------------------------------------------------------------------------
    Input=mat2cell(Input,size(Input,1),size(Input,2),ones(1,size(Input,3)));

% add filtering and thresholding, remove noise!!! Kalman filter ? 
% NOISE=mean(cell2mat(cellfun(@(x)bandpower(x(:)),Input,'UniformOutput',false)));
% Input=cellfun(@(x)wiener2(x,[round(Radius/2),round(Radius/2)],NOISE),Input,'UniformOutput',false);
% figure; surf(entropyfilt(Input{1})); shading interp;

% Thresholding
y=Input{:}; y=y(:); Levels=multithresh(y,2); Level=Levels(2);
% Level=mean(y)+std(y); % try to remove whatever is noise!!! even if no
% molecule in the pit. Need a better way of segmenting.
Input=cellfun(@(x)x.*(x>=Level),Input,'UniformOutput',false);
%%                    CONVOLUTION WITH GAUSSIAN
N = Radius; x=-N:N; [X,Y]=meshgrid(x); sigma=2;
Gaussian3D=exp(-(X.^2/(2*sigma^2))-(Y.^2/(2*sigma^2)));
NewInput=cellfun(@(x)FastConv(x,Gaussian3D),Input,'UniformOutput',false);
    function e=FastConv(a,b) 
        m=size(a,1)+size(b,1)-1; 
        n=size(a,2)+size(b,2)-1; 
        c=fft2(a,m,n); d=fft2(b,m,n);
        e=ifft2(c.*d); 
        m1=(size(b,1)-1)/2; n1=(size(b,2)-1)/2; 
        e=e(ceil(m1)+1:end-floor(m1),ceil(n1)+1:end-floor(n1)); 
    end
%%                         PEAKS DETECTION
mat=[1,1,1;1,0,1;1,1,1];
NewInputPrime=cellfun(@(x)x.*(x>imdilate(x,mat)),...
    NewInput,'UniformOutput',false);
NewInputPrime=cellfun(@(x)x.*(x>=0.5*max(x(:))),NewInputPrime,...
    'UniformOutput',false);

Positions=cellfun(@(x)struct2cell(regionprops(logical(x),'Centroid')),...
    NewInputPrime,'UniformOutput',false);
Positions=cellfun(@(x)cell2mat(reshape(x,numel(x),1)),...
    Positions,'UniformOutput',false);
Distances=cellfun(@(x,y)pdist2(x,y),Positions(1:end-1),...
    Positions(2:end),'UniformOutput',false); 
Probabilities=cellfun(@(x)normpdf(x,mean(x(:)),std(x(:))),...
    Distances,'UniformOutput',false);
Distances=cellfun(@(x,y)x.*y,Distances,Probabilities,...
    'UniformOutput',false);
Distances=cellfun(@(x)x(~isnan(x)),Distances,'UniformOutput',false);

XDistances=cellfun(@(x)x(:,1),Positions,'UniformOutput',false);
XDistances=cellfun(@(x,y)pdist2(x,y),XDistances(1:end-1),XDistances(2:end),'UniformOutput',false);
XDistances=cellfun(@(x,y)x.*y,XDistances,Probabilities,...
    'UniformOutput',false);
XDistances=cellfun(@(x)x(~isnan(x)),XDistances,'UniformOutput',false);
XDistances=permute(cell2mat(cellfun(@sum,XDistances,'UniformOutput',false)),[3,2,1]);
YDistances=cellfun(@(x)x(:,2),Positions,'UniformOutput',false);
YDistances=cellfun(@(x,y)pdist2(x,y),YDistances(1:end-1),YDistances(2:end),'UniformOutput',false);
YDistances=cellfun(@(x,y)x.*y,YDistances,Probabilities,...
    'UniformOutput',false);
YDistances=cellfun(@(x)x(~isnan(x)),YDistances,'UniformOutput',false);
YDistances=permute(cell2mat(cellfun(@sum,YDistances,'UniformOutput',false)),[3,2,1]);

Distance=permute(cell2mat(cellfun(@sum,Distances,'UniformOutput',false)),[3,2,1]);
Distance=mean(Distance);

XDistance=mean(XDistances);
YDistance=mean(YDistances);
D=(Distance*dx)^2/(4*dt);

% Speedy=cellfun(@(x,y)xcorr2(x,y),NewInputPrime(1:end-1),...
%     NewInputPrime(2:end),'UniformOutput',false); % or use SpatioTemporalCorr
% Speedy=cellfun(@(x)x.*(1+sign(x))/2,Speedy,'UniformOutput',false);
% Speeds=cellfun(@(x)struct2cell(regionprops(logical(x),'Centroid')),...
%     Speedy,'UniformOutput',false);
% Speeds=cellfun(@(x)cell2mat(reshape(x,numel(x),1)),...
%     Speeds,'UniformOutput',false);
% CatchMe=permute(cell2mat(cellfun(@(x)~isempty(x),Speeds,...
%     'UniformOutput',false)),[1,3,2]); % just for the graph for now
% Speeds=cellfun(@ifEmpty,Speeds,'UniformOutput',false); 
%     function x=ifEmpty(x)
%         if isempty(x)
%             x=zeros(0,2);
%         end
%     end
% Speeds=cellfun(@(x)x-repmat(Center,size(x,1),1),Speeds,...
%     'UniformOutput',false);
% Speeds_x=cellfun(@(x)abs(x(:,1)),Speeds,'UniformOutput',false);
% Speeds_y=cellfun(@(x)abs(x(:,2)),Speeds,'UniformOutput',false);
% %%                     AVERAGE VELOCITY COMPONENTS
% Speeds_x=cellfun(@(x)trimmean(x,10),Speeds_x,'UniformOutput',false);
% Speeds_y=cellfun(@(x)trimmean(x,10),Speeds_y,'UniformOutput',false);
% Speeds_x=cellfun(@removeNAN,Speeds_x,'UniformOutput',false);
% Speeds_y=cellfun(@removeNAN,Speeds_y,'UniformOutput',false);
%     function x=removeNAN(x)
%         if isnan(x)
%             x=[];
%         end
%     end
% Speeds_x=permute(cell2mat(Speeds_x),[3,2,1]); Speeds_x=Speeds_x.*(dx/dt);
% Speeds_y=permute(cell2mat(Speeds_y),[3,2,1]); Speeds_y=Speeds_y.*(dx/dt);
%%                          STATISTICS
StatsSpeedx=[mean(XDistances),std(XDistances),...
    skewness(XDistances),kurtosis(XDistances)];
StatsSpeedy=[mean(YDistances),std(YDistances),...
    skewness(YDistances),kurtosis(YDistances)];
%%                           VISUALIZATION
figure; % component velocity distributions
subplot(1,2,1);
T=1:numel(XDistances); 
% Time=1:size(Input,3); Time=Time*dt; Time=Time(CatchMe);
% Time=Time(1:0.1*numel(T):numel(T));
% Time=num2cell(Time); Time=cellfun(@num2str,Time,'UniformOutput',false);
plot(T,XDistances,'--ob');
ylabel('Speed (µm/s)','FontSize',14); xlabel('Time (s)','FontSize',14);
title('x-Component','FontSize',16);
% set(gca,'Xtick',1:0.1*numel(T):numel(T),'XTickLabel',Time);
subplot(1,2,2);
T=1:numel(YDistances);
plot(T,YDistances,'--om');
ylabel('Speed (µm/s)','FontSize',14); xlabel('Time (s)','FontSize',14);
title('y-Component','FontSize',16);
% set(gca,'Xtick',1:0.1*numel(T):numel(T),'XTickLabel',Time);
figure; 
subplot(1,2,1); histfit(XDistances,100);
t=sprintf('Mean: %f \n std: %f \n skewness: %f \n kurtosis: %f',StatsSpeedx);
h = annotation('textbox',[0.36,0.64,0.1,0.14],'String',t); set(h,'FontSize',12);
title('x-Component','FontSize',16); 
ylabel('Counts','FontSize',14); xlabel('Speed (µm/s)','FontSize',14);
subplot(1,2,2); histfit(YDistances,100);
t=sprintf('Mean: %f \n std: %f \n skewness: %f \n kurtosis: %f',StatsSpeedy);
h = annotation('textbox',[0.80,0.66,0.1,0.14],'String',t); set(h,'FontSize',12);
title('y-Component','FontSize',16); 
ylabel('Counts','FontSize',14); xlabel('Speed (µm/s)','FontSize',14);

%=========================== DEMONSTRATION ================================
Frame= round(rand(1)*Length);
figure;
subplot(3,3,1); surf(Input{Frame}); 
shading interp; axis tight; title('Frame 1');
subplot(3,3,2); surf(Input{Frame+1}); 
shading interp; axis tight; title('Frame 2')
subplot(3,3,3); surf(Input{Frame+2}); 
shading interp; axis tight; title('Frame 3')
subplot(3,3,4); surf(NewInput{Frame}); 
shading interp; axis tight; title('Frame 1');
subplot(3,3,5); surf(NewInput{Frame+1}); 
shading interp; axis tight; title('Frame 2')
subplot(3,3,6); surf(NewInput{Frame+2}); 
shading interp; axis tight; title('Frame 3')
subplot(3,3,7); surf(NewInputPrime{Frame}); 
shading interp; axis tight; title('Frame 1');
subplot(3,3,8); surf(NewInputPrime{Frame+1}); 
shading interp; axis tight; title('Frame 2')
subplot(3,3,9); surf(NewInputPrime{Frame+3}); 
shading interp; axis tight; title('Frame 3')
% figure;
% subplot(1,2,1); surf(Speedy{1}); shading interp; axis tight; 
% title('Cross-Correlation of Frame 1 and Frame 2');
% subplot(1,2,2); surf(Speedy{2}); shading interp; axis tight; 
% title('Cross-Correlation of Frame 2 and Frame 3')
%==========================================================================

%%                      DIFFUSION COEFFICIENT
% [Ax,Lags]=xcorr(Speeds_x,'coeff'); [Ay,~]=xcorr(Speeds_y,'coeff');
% A=Ax+Ay; A=A(Lags>=0); Lags=Lags(Lags>=0); figure; plot(Lags,A,'--or');
% Dprime=sum(A)*dt/4;

% Dx=dt*mean(Speeds_x.^2)/4;
% Dy=dt*mean(Speeds_y.^2)/4;
% Dprime=mean([Dx,Dy]);
end

