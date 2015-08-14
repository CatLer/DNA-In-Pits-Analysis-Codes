function [] = BackgroundCheck4()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
A=evalin('base','whos(''-regexp'',''Set'')');
Names={A.name};

    colors={'m','b','g','r','k'};
    function str=mycolor(n)
    if isnan(n)
        str=colors{5};
    else
        str=colors{n+1};
    end
    end

for i=1:numel(Names)
%    try
       expression=strcat(Names{i},'.Red_Channel_In_Green_Laser.Relative_Intensity'); 
       Intensity_R=evalin('base',expression);
       Intensity_R=Intensity_R(2:end-1,2:end-1,:);
       
       expression=strcat(Names{i},'.Red_Channel_In_Green_Laser.Background_Intensity'); 
       Background_R=evalin('base',expression);
       Background_R=Background_R(2:end-1,2:end-1,:);
       
       expression=strcat(Names{i},'.Red_Channel_In_Green_Laser.Mean_Number_Of_Fluophores'); 
       N_R=evalin('base',expression);
       
       expression=strcat(Names{i},'.Green_Channel_In_Green_Laser.Relative_Intensity'); 
       Intensity_G=evalin('base',expression);
       Intensity_G=Intensity_G(2:end-1,2:end-1,:);
       
       expression=strcat(Names{i},'.Green_Channel_In_Green_Laser.Background_Intensity'); 
       Background_G=evalin('base',expression);
       Background_G=Background_G(2:end-1,2:end-1,:);
     
       expression=strcat(Names{i},'.Green_Channel_In_Green_Laser.Mean_Number_Of_Fluophores'); 
       N_G=evalin('base',expression);
       
       fig_R=figure('Name',Names{i}, 'NumberTitle','off'); hold on;
       fig_G=figure('Name',Names{i}, 'NumberTitle','off'); hold on;
       Fig_R=figure('Name',Names{i}, 'NumberTitle','off'); hold on;
       Fig_G=figure('Name',Names{i}, 'NumberTitle','off'); hold on;
       
       for j=1:size(Intensity_R,1)
           for k=1:size(Intensity_R,2)
               cR=mycolor(N_R(j,k));
               cG=mycolor(N_G(j,k));
               figure(fig_R);
               plot(permute(Intensity_R(j,k,:),[3,2,1]),cR);
               figure(Fig_R);
               plot(permute(Background_R(j,k,:),[3,2,1]),cR);
               figure(fig_G);
               plot(permute(Intensity_G(j,k,:),[3,2,1]),cG);
               figure(Fig_G);
               plot(permute(Background_G(j,k,:),[3,2,1]),cG);               
           end
       end
       
       figure(fig_R)
       title('Red channel relative intensities','Interpreter','none')
       hold off;

       figure(fig_G)
       title('Green channel relative intensities','Interpreter','none')
       hold off;
       
       figure(Fig_R)
       title('Red channel background intensities','Interpreter','none')
       hold off;

       figure(Fig_G)
       title('Green channel background intensities','Interpreter','none')
       hold off;
       
       print(fig_R,strcat('Red_Channel_Relative_Intensities_',Names{i}),'-dpng')
       print(fig_G,strcat('Green_Channel_Relative_Intensities_',Names{i}),'-dpng')
       print(Fig_R,strcat('Red_Channel_Background_Intensities_',Names{i}),'-dpng')
       print(Fig_G,strcat('Green_Channel_Background_Intensities_',Names{i}),'-dpng')
       
       close all;
%    catch
%        warning(strcat('Couldn''t do a background check for ', Names{i}));
%    end
end

end

