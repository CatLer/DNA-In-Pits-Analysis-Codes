function MY_FRET_EFFICIENCY = FRET_Efficiency_VS_Temperature()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

A=evalin('base','whos(''-regexp'',''Set'')');
Names={A.name};
Classes=strcmpi('PitsSample',{A.class});
MY_FRET_EFFICIENCY=[];
for i=1:numel(Names)
    if Classes(i)==1
       
       expression=strcat(Names{i},'.FRET_Efficiency.Calculation_With_All_Pits_Average');
       FRET_efficiency=evalin('base',expression);  
       expression=strcat(Names{i},'.LENS_T');
       TLens=evalin('base',expression);
       expression=strcat(Names{i},'.OBJ_T');
       TObj=evalin('base',expression);
       if isnan(TLens)
           TLens=[];
       end
       if isnan(TObj)
           TObj=[];
       end       
       T=mean([TLens,TObj]);       
       MY_FRET_EFFICIENCY=cat(1,MY_FRET_EFFICIENCY,[T,FRET_efficiency]);
    end
end
% try
figure;
plot(MY_FRET_EFFICIENCY(:,1),MY_FRET_EFFICIENCY(:,2),'-bo');
title('FRET efficiency against temperature');
xlabel('Temperature(°C)');
ylabel('FRET efficiency');
% catch
%     error('Couldn''t plot the FRET efficiency curve');
% end

end

