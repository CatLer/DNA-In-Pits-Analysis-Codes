function [Ints,StopTimes,StartTimes] = FindLevelsInSignal(Signal,See)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%
%---------------------------- 1-element -----------------------------------
if length(Signal)<2
    StopTimes=[]; StartTimes=[];
    if length(Signal)==1
    Ints=Signal; 
    else
        Ints=[]; 
    end
    return;
end
%--------------------------------------------------------------------------
%%
%----------------------------Settings -------------------------------------
LEVELS={}; Num=6; Minimal_Occupation=0.05*numel(Signal);
%--------------------------------------------------------------------------
%%
%------------------------- Clustering -------------------------------------  
for i=1:Num
    A=medfilt1(...
        double(clusterdata(Signal(:),'linkage','ward','maxclust',i)),3);
    C=unique(A);
    Levels=zeros(1,numel(C));
    for j=1:numel(C)
        Levels(j)=mean(Signal(A==C(j)));
    end
    Levels=sort(Levels); LEVELS=cat(1,LEVELS,{Levels});
end
%--------------------------------------------------------------------------
%%
%-------------------- Put clusters together -------------------------------
LEVELS=[LEVELS{:}]; LEVELS=sort(LEVELS);
Number=max(floor(max(Levels)-min(Levels)),10);
[y,x]=hist(LEVELS,Number); % y=smooth(y);
y=cat(1,0,y(:),0); x=cat(1,x(1)-1,x(:),x(end)+1);
[pks,locs]=findpeaks(y,'MinPeakHeight',1);
Ints=x(locs); K=knnsearch(Ints,Signal(:)); u=unique(K); N=hist(K,u); 
Ints=Ints(N>Minimal_Occupation); locs=locs(N>Minimal_Occupation);
%%
%************* still in progress - filtering levels ***********************
[p1,q1]=meshgrid(Ints);[p2,q2]=meshgrid(1:numel(Ints));
pairs1=[p1(:),q1(:)]; pairs2=[p2(:),q2(:)]; 
K2=knnsearch(Ints,Signal(:));
%%
%-------------------------- Risetimes, Falltimes --------------------------
Delta1=max(Ints)-min(Ints);
Delta2=diff(sort(Ints)); %***
Errors=zeros(numel(Ints),1);
for m=1:numel(Ints)
    Errors(m)=std(Signal(K2==m)); %***
end
LogNum=log10(mean(Ints)); Order=floor(LogNum); 
Rem=round(10^(LogNum-Order-1)); Order=Order+Rem-1;
Uncertainty=max(min(3*std(Signal),0.9*Delta1),10^Order); 
K1=pairs2(abs(diff(pairs1,1,2))>Uncertainty,:);
%......................... NEED TO BE IMPROVED ............................
CutStart=zeros(numel(Signal),1); CutStop=CutStart;
for l=1:size(K1,1)
   IDK1=K2==K1(l,1)|K2==K1(l,2); IDK2=IDK1; Kprime=K2(IDK1);
   IDKprime1=cat(1,diff(Kprime)==diff(K1(l,:)),0);
   IDKprime2=cat(1,0,diff(Kprime)==diff(K1(l,:)));
   IDK1(IDK1==1)=IDKprime1; IDK2(IDK2==1)=IDKprime2;
   CutStart=CutStart+IDK1; CutStop=CutStop+IDK2;
end
CutStartPrime=CutStart; CutStopPrime=CutStop; 
CutStart=logical(CutStart); CutStop=logical(CutStop); 
Times=1:length(Signal); 
StopTimes=Times(CutStart); 
StartTimes=Times(CutStop);
REP=[];
for m=1:numel(StartTimes)
    Rep=CutStopPrime(StartTimes(m))-1;
    Rep=ones(Rep,1)*StartTimes(m);
    REP=cat(1,REP,Rep);
end
StartTimes=sort(cat(1,StartTimes(:),REP(:)));
REP=[];
for m=1:numel(StopTimes)
    Rep=CutStartPrime(StopTimes(m))-1;
    Rep=ones(Rep,1)*StopTimes(m);
    REP=cat(1,REP,Rep);
end
StopTimes=sort(cat(1,StopTimes(:),REP(:)));
StopTimes=cat(1,StopTimes(:),length(Signal));
StartTimes=cat(1,1,StartTimes(:));
%.......................................................................... 
%--------------------------------------------------------------------------
%**************************************************************************
%%
%--------------------------------- Figures --------------------------------
if See>0
figure; subplot(1,2,1); plot(x,y,'Color','b','linewidth',1.5);  hold on; 
plot(x(locs),y(locs),'k^','markerfacecolor','r');
subplot(1,2,2); plot(squeeze(Signal),'color','b','linewidth',1.5); hold on;
x=get(gca,'xlim'); 
for l=1:numel(Ints)
    line(x,[Ints(l),Ints(l)],'color','g','linestyle',':','linewidth',1.5)
end
y=get(gca,'Ylim'); 
stem(double(CutStart)*(y(2)-y(1)+1)+y(1)-1,'color','r',...
    'linestyle',':','linewidth',1.5); 
stem(double(CutStop)*(y(2)-y(1)+1)+y(1)-1,'color','m',...
    'linestyle',':','linewidth',1.5); 
set(gca,'Ylim',y);
end
%--------------------------------------------------------------------------
end

