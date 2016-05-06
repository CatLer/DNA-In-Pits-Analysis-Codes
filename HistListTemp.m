function [histList] = HistListTemp(varargin)
%MakeTempPlot: This function...
%1) Takes in samples at various temperatures for a fixed Lk;
%2) Makes a list that can be used with TempHist.
%% Displays list in dialog box to select samples.

Names = evalin('base', 'whos(''Set_*'')');
Classes = {Names.class}; I=strcmp(Classes, 'PitsSample');
Names = Names(I); Names={Names.name};
k = listdlg('ListString', Names, 'SelectionMode', 'multiple', 'ListSize', [400,400],...
    'Name', 'Sample Selection', 'PromptString', 'Select samples for a fixed Lk.');

inputArgs=Names(k);

prompt = 'How many active fluorophores (up to 3) are you looking for? For all, enter NaN';
dlg_title = 'Number of fluorophores';
influo= inputdlg(prompt, dlg_title);
nFluo=str2num(influo{1});

%% Total size of histList.
d= size(inputArgs,2);
totalNBC = 0;
for i =1:d
    sample = inputArgs{i};
    nBC = boundcomplexes(sample,nFluo);
    totalNBC = totalNBC + nBC;
end 
    
histList = zeros(totalNBC,1);


%% Iteration over all samples.

m=0; 
t=1;
T1=0;
% histList = 0; %to remove

for i = 1:d
    
    sample = inputArgs{i};
    Blabla = sprintf('%s.OBJ_T_In_Green_Laser;',sample);
    T2=round(evalin('base', Blabla));
    Tup = T1+0.5;
    Tdown = T1-0.5;
    nBC2 = boundcomplexes(sample,nFluo);
    if T2 <= Tup && T2 >= Tdown
       t = t+1;
       w = 1/t;
       nBC1 = (nBC1*(1-w))+nBC2*w;
        m = n+round(nBC1)-1;
       for j=n:m
        histList(j)= T1;
       end
    else 
    T1=T2; t=1;
    nBC1 = nBC2;
%     histListSample = T*ones(nBC,1); %remove
%     if histList==0
%         histList = histListSample;
%     else 
%     histList = horzcat(histList, histListSample); %remove
%     end 
    n = m+1;
    m = n+nBC1-1;
    for j=n:m
        histList(j)= T1;
    end
    end
end
histList( all(~histList,2), : ) = [];
end


%% Local function: boundcomplexes
% Sums elements in Green Channel binding matrix of a sample with given Lk and T.
    function Z = boundcomplexes(sample,nFluo)

if isnan(nFluo)
    
    for i = 1:3
      Blabla=sprintf('%s.Green_Channel_In_Green_Laser.Binding.With_%d_Active_Fluophores;',sample,i);
      if i==1
          X= evalin('base',Blabla);
      else
          X= X+evalin('base', Blabla);
      end
      X = logical(X);
    end
else
    
Blabla=sprintf('%s.Green_Channel_In_Green_Laser.Binding.With_%d_Active_Fluophores;',sample,nFluo);
X=evalin('base', Blabla);
[m,n] = size(X);
end

Y = sum(X,1);
Z = sum(Y,2);

end