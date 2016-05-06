function [Statistics,Distribution_VS_Temperature,Lambda_VS_Temperature]=...
    PoissonDistributions()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Names=evalin('base','whos(''Set_*'')');  % 'Set_*'  to add a filter
Classes={Names.class}; I=strcmp(Classes,'PitsSample');
Names=Names(I); Names={Names.name};
if isempty(Names)
    warning('No sample found.')
    return;
end
j=listdlg('ListString',Names,'SelectionMode','multiple','ListSize',[400,600],...
    'Name','Sample Selection', 'PromptString', 'Please, select a sample.');
if isempty(j)
    return;
end
% Poisson Distribution
fo=fitoptions('Method','NonlinearLeastSquares','Lower',0,'Upper',6,'StartPoint',1);
Poisson_Distribution=fittype('(lambda.^x)*exp(-lambda)./gamma(x+1)',...
    'dependent','y','independent','x','coefficients','lambda','options',fo);
Names=Names(j); figure; ax=gca; hold on; Statistics=cell(numel(Names),4); 
for i=1:numel(Names)
    % temperature
    T_Obj=evalin('base',sprintf('%s.OBJ_T_In_Green_Laser',Names{i}));
    T_Lens=evalin('base',sprintf('%s.LENS_T_In_Green_Laser',Names{i}));
    T=mean([T_Obj,T_Lens]); Statistics{i,4}=round(T);
    % intensity of 1 single molecule
    Intensity_1_Molecule=...
        evalin('base',sprintf(...
        '%s.Green_Channel_In_Green_Laser.Sampled_Intensity_1_Molecule',...
        Names{i}));
    % time average intensity
    Relative_Intensity=...
        evalin('base',sprintf(...
        '%s.Green_Channel_In_Green_Laser.Time_Average_Intensity',...
        Names{i}));
    Relative_Intensity(Relative_Intensity<0)=0;
    % number of molecules
    Distribution_Number=...
        round(Relative_Intensity/Intensity_1_Molecule);
    % remove non-available values (NaN)
    Distribution_Number=Distribution_Number(~isnan(Distribution_Number));
    % fit poisson distribution
    [lambdahat,lambdaci]=poissfit(Distribution_Number);
    Statistics{i,1}=lambdahat; Statistics{i,2}=lambdaci; 
    [N,X]=hist(Distribution_Number,0:6); Statistics{i,3}=[X(:),N(:)];
    plot(ax,X,N,'color',0.8*rand(1,3),'LineStyle',':','Linewidth',2);
end
% title('Number of molecules distribution');
xlabel('Number of molecules','fontsize',14);
ylabel('Number of pits','fontsize',14);
% leg=cellfun(@num2str,Statistics(:,1),'UniformOutput',false);
% legend(leg);
matrix=Statistics(:,1); matrix=cell2mat(matrix); figure; hist(matrix,10);
xlabel('Average number of molecules per pit (\lambda)','fontsize',14);
ylabel('Number of videos','fontsize',14);
average = mean(matrix);
whatever = std(matrix);
legend(strcat(num2str(average),'\pm',num2str(whatever)));
Temperatures=cell2mat(Statistics(:,4)); maximum=0;
Temp=unique(Temperatures,'Stable');
Distribution_VS_Temperature=cell(numel(Temp),2);
num=cell(numel(Temp),1);
for i=1:numel(Temp)
    Distribution_VS_Temperature{i,1}=Temp(i); M=Statistics(:,4); 
    M=cellfun(@(x)isequal(x,Temp(i)),M,'UniformOutput',false);
    if iscell(M)
        M=cell2mat(M);
    end
    num{i}=sum(M);
    M=cell2mat(Statistics(M,3));
    u=unique(M(:,1)); N=zeros(numel(u),2);
    for j=1:numel(u)
        N(j,1)=u(j); N(j,2)=sum(M(M(:,1)==u(j),2));
    end
    Distribution_VS_Temperature{i,2}=N;
    maximum=max(max(N(:,2)),maximum);
end
Lambda_VS_Temperature=[]; figure; k=1; 
dim1=floor(sqrt(numel(Temp))); dim2=ceil(numel(Temp)/dim1);
cellfun(@(x,y,z)PlotHistoVsTemp(x,y,z),Distribution_VS_Temperature(:,1),...
    Distribution_VS_Temperature(:,2),num,'UniformOutput',false);
    function PlotHistoVsTemp(my_temperature,my_distribution,number)
        subplot(dim1,dim2,k); b=bar(my_distribution(:,1),my_distribution(:,2));
        set(b,'facecolor','cyan'); k=k+1; number2=sum(my_distribution(:,2));
        % display poisson fit
        lambda_T=fit(my_distribution(:,1),my_distribution(:,2)/sum(my_distribution(:,2)),...
            Poisson_Distribution); P=feval(lambda_T,-1:0.01:7)*sum(my_distribution(:,2)); 
        lambda_T=coeffvalues(lambda_T); hold on; plot(-1:0.01:7,P,'r','linewidth',2);
        Lambda_VS_Temperature=...
            cat(1,Lambda_VS_Temperature,[my_temperature,lambda_T]); 
        title(strcat('T = ',num2str(my_temperature),' °C , \lambda = ', ...
            num2str(lambda_T)),'fontsize',14); set(gca,'ylim',[0,maximum]); 
        xlabel('Number of molecules per pit','fontsize',12);
        ylabel(sprintf('Number of pits for %d video(s) for a total of %d pits',...
            number,number2),'fontsize',12);
    end
figure;
plot(Lambda_VS_Temperature(:,1),Lambda_VS_Temperature(:,2),'bd:','linewidth',2);
xlabel('T (°C)','fontsize',14); ylabel('\lambda ','fontsize',14);
% title('Expected Number of Molecules Per Pit Against Temperature','fontsize',14);
end

