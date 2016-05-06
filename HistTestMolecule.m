function [] = HistTestMolecule()
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

A=evalin('base','whos(''-regexp'',''Set'')');
A={A.name};  Green_Int=[]; Red_Int=[]; 

for i=1:numel(A)
    Data=strcat(A{i},'.Green_Channel.Mean_Intensity_In_Time;');
    Data_G=evalin('base',Data); Data_G(Data_G<abs(min(Data_G(:))))=0;
    data_G=mat2gray(Data_G);
    Data=strcat(A{i},'.Red_Channel.Mean_Intensity_In_Time;');
    Data_R=evalin('base',Data); Data_R(Data_R<abs(min(Data_R(:))))=0;
    data_R=mat2gray(Data_R);
    
    [counts_G,binLocations] = imhist(data_G);
    [counts_R,~] = imhist(data_R);
    
    G=[]; R=[];
    for j=1:numel(binLocations)
        G=cat(1,G,repmat(binLocations(j),[counts_G(j),1,1])*max(Data_G(:)));
        R=cat(1,R,repmat(binLocations(j),[counts_R(j),1,1])*max(Data_R(:)));
    end
    
    T_G=clusterdata(G,'maxclust',4); U_G=unique(T_G); bincounts_G=histc(T_G,U_G);
    T_R=clusterdata(G,'maxclust',4); U_R=unique(T_R); bincounts_R=histc(T_R,U_R);
    [~,k_G]=max(bincounts_G); [~,k_R]=max(bincounts_R); k_G=T_G==k_G; k_R=T_R==k_R;
    g=mean(G(k_G));
    r=mean(R(k_R));
    
    [B_G,G]=kmeans(G,2); G=sort(G); % empty or not 
    [B_R,R]=kmeans(R,2); R=sort(R); % empty or not 
    
    
    Green_Int=cat(1,Green_Int,[diff(G),g]); 
    Red_Int=cat(1,Red_Int,[diff(R),r]);
    
   Number_G=round(Data_G./diff(G));
   Number_R=round(Data_R./diff(R));
   
   N=Number_G.*Number_R;
   N=sqrt(N)==round(sqrt(N))
end

[Red_Int,Green_Int, Red_Int./Green_Int]
% mean([Red_Int,Green_Int, Red_Int./Green_Int])
% std([Red_Int,Green_Int, Red_Int./Green_Int])

end

