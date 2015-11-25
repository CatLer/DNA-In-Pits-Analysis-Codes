function [New_Array,Nrows,Ncols,radius] = ResizeGrid(Array,Nrows,Ncols,radius,image,angle_o) 
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Rotation_Matrix=@(a)[cosd(a),-sind(a);sind(a),cosd(a)];
New_Array=Array;
Old_Arrays={Array};
Old_Arrays_strings={'Previous Positions'};
r=radius; angle=0;

f=figure('Menubar','none','Name','GRID RESIZER','NumberTitle','off');
imshow(image); hold on;
v=viscircles(Array,radius*ones(size(Array,1),1),'EdgeColor','c');

Text=sprintf('HOW TO RESIZE THE GRID \n \n Use the sliders to modify the proportions of the grid.');
Text=strcat(Text,sprintf('\n Play with one slider at once.\n Once you''re done with a slider, press ''Keep''.'));
Text=strcat(Text,sprintf('\n By doing this, you keep in memory what you have done.'));
Text=strcat(Text,sprintf('\n If you want to come back to the previous settings, use the list at the bottom left of the figure.'));
Text=strcat(Text,sprintf('\n \n The option of adding and removing is not available yet but shouldn''t be needed.'));
Text=strcat(Text,sprintf('\n \n The previous radius will not be kept in memory like previous pits positions are.'));
Text=strcat(Text,sprintf('\n \n Once you think the grid is well fitted, press ''SAVE DEFAULT GRID'' button.'));
Text=strcat(Text,sprintf('\n A .mat file with the name of the sample and type of experiment will be saved.'));
Text=strcat(Text,sprintf('\n This default grid will be automatically used by DNA_In_Pits_Analysis during the batch run.'));
Text=strcat(Text,sprintf('\n For this reason, the .mat file must not be deleted or moved before the analysis.'));
Text=strcat(Text,sprintf('\n If this happens, the automatic grid or the default grid the user selects when calling DNA_In_Pits_Analysis, will be used for that sample.'));
Text=strcat(Text,sprintf('\n Before it saves the .mat file, it will wait that all the channel(s) have been resized and you will be prompted for a confirmation.'));


uicontrol(f,'style','popupmenu','Position',[1400,700,350,200],'String',Text,'Fontsize',10,'ButtonDownFcn',@MoveUicontrolWithMouse);

u=uicontrol(f,'style','popupmenu','Position',[25,25,250,25],'String',Old_Arrays,'Fontsize',14,'Callback',@GetBack);

uicontrol(f,'style','pushbutton','Position',[25,700,250,50],'String','SAVE DEFAULT GRID','Fontsize',16,'Callback',@SaveDefaultGrid);

uicontrol(f,'style','pushbutton','Position',[25,625,250,25],'String','Add Column','Fontsize',12,'Callback',@AddAColumn); % not there yet
uicontrol(f,'style','pushbutton','Position',[25,600,250,25],'String','Remove Column','Fontsize',12,'Callback',@RemoveAColumn); % not there yet
uicontrol(f,'style','pushbutton','Position',[25,575,250,25],'String','Add Row','Fontsize',12,'Callback',@AddARow); % not there yet
uicontrol(f,'style','pushbutton','Position',[25,550,250,25],'String','Remove Row','Fontsize',12,'Callback',@RemoveARow); % not there yet

uicontrol(f,'style','text','Position',[25,500,250,25],'String','Pit Radius','Fontsize',14);
u1=uicontrol(f,'style','slider','Position',[25,475,250,25],'Callback',@ChangeRadius); set(u1,'Value',0.2);
set(u1,'SliderStep',[0.001 0.001]);
uicontrol(f,'style','pushbutton','Position',[275,475,50,25],'String','Keep','Fontsize',12,'Callback',@KeepRadius);

uicontrol(f,'style','text','Position',[25,275,250,25],'String','Horizontal Spacing','Fontsize',14);
u2=uicontrol(f,'style','slider','Position',[25,250,250,25],'Callback',@ChangeHorizontalSpacing); set(u2,'Value',0.5);
set(u2,'SliderStep',[0.001 0.001]);
uicontrol(f,'style','pushbutton','Position',[275,400,50,25],'String','Keep','Fontsize',12,'Callback',@KeepThat);

uicontrol(f,'style','text','Position',[25,200,250,25],'String','Vertical Spacing','Fontsize',14);
u3=uicontrol(f,'style','slider','Position',[25,175,250,25],'Callback',@ChangeVerticalSpacing); set(u3,'Value',0.5);
set(u3,'SliderStep',[0.001 0.001]);
uicontrol(f,'style','pushbutton','Position',[275,325,50,25],'String','Keep','Fontsize',12,'Callback',@KeepThat);

uicontrol(f,'style','text','Position',[25,425,250,25],'String','Translate In X','Fontsize',14);
u4=uicontrol(f,'style','slider','Position',[25,400,250,25],'Callback',@TranslateInX); set(u4,'Value',0.5);
set(u4,'SliderStep',[0.001 0.001]);
uicontrol(f,'style','pushbutton','Position',[275,250,50,25],'String','Keep','Fontsize',12,'Callback',@KeepThat);

uicontrol(f,'style','text','Position',[25,350,250,25],'String','Translate In Y','Fontsize',14);
u5=uicontrol(f,'style','slider','Position',[25,325,250,25],'Callback',@TranslateInY); set(u5,'Value',0.5);
set(u5,'SliderStep',[0.001 0.001]);
uicontrol(f,'style','pushbutton','Position',[275,175,50,25],'String','Keep','Fontsize',12,'Callback',@KeepThat);

uicontrol(f,'style','text','Position',[25,125,250,25],'String','Rotation angle','Fontsize',14);
u6=uicontrol(f,'style','slider','Position',[25,100,250,25],'Callback',@SetAngle); set(u6,'Value',0.5);
set(u6,'SliderStep',[0.001 0.001]);
uicontrol(f,'style','pushbutton','Position',[275,100,50,25],'String','Keep','Fontsize',12,'Callback',@KeepThat);

    function GetBack(a,~)
        i=get(a,'Value');
        Array=Old_Arrays{i};
        delete(v); figure(f);
        v=viscircles(Array,radius*ones(size(Array,1),1),...
            'EdgeColor','c');         
    end

    function KeepThat(~,~)
        Old_Arrays=cat(2,Old_Arrays,Array);
        Array=New_Array;
        Old_Arrays_strings=cat(2,Old_Arrays_strings,'Previous Positions');
        set(u,'String',Old_Arrays_strings);
    end

    function KeepRadius(~,~)
        radius=r;
    end

    function AddAColumn(~,~)
        Temp_array=Array*Rotation_Matrix(-angle-angle_o);
        Temp_array=permute(reshape(transpose(Temp_array),...
            [2,Nrows,Ncols]),[2,1,3]);
        Interval=mean(mean(diff(Temp_array(:,1,:),1,3)));
        Temp_array=cat(3,Temp_array,Temp_array(:,:,end));
        Temp_array(:,1,end)=Temp_array(:,1,end)+Interval;
        Ncols=Ncols+1;        
        Temp_array=reshape(permute(Temp_array,[1,3,2]),[Ncols*Nrows,2,1]);
        Array=Temp_array*Rotation_Matrix(angle+angle_o); 
        New_Array=Array;
        delete(v); figure(f);
        v=viscircles(Array,radius*ones(size(Array,1),1),...
            'EdgeColor','c');
    end

    function RemoveAColumn(~,~) 
        if Ncols>2
        Temp_array=Array*Rotation_Matrix(-angle-angle_o);
        Temp_array=permute(reshape(transpose(Temp_array),...
            [2,Nrows,Ncols]),[2,1,3]);
        Temp_array(:,:,end)=[];
        Ncols=Ncols-1;        
        Temp_array=reshape(permute(Temp_array,[1,3,2]),[Ncols*Nrows,2,1]);
        Array=Temp_array*Rotation_Matrix(angle+angle_o); 
        New_Array=Array;
        delete(v); figure(f);
        v=viscircles(Array,radius*ones(size(Array,1),1),...
            'EdgeColor','c');  
        end
    end

    function AddARow(~,~)
        Temp_array=Array*Rotation_Matrix(-angle-angle_o);
        Temp_array=permute(reshape(transpose(Temp_array),...
            [2,Nrows,Ncols]),[2,1,3]);
        Interval=mean(mean(diff(Temp_array(:,2,:),1,1)));
        Temp_array=cat(1,Temp_array,Temp_array(end,:,:));
        Temp_array(end,2,:)=Temp_array(end,2,:)+Interval;        
        Nrows=Nrows+1;        
        Temp_array=reshape(permute(Temp_array,[1,3,2]),[Ncols*Nrows,2,1]);
        Array=Temp_array*Rotation_Matrix(angle+angle_o); 
        New_Array=Array;
        delete(v); figure(f);
        v=viscircles(Array,radius*ones(size(Array,1),1),...
            'EdgeColor','c');          
    end

    function RemoveARow(~,~)
        if Nrows>2
        Temp_array=Array*Rotation_Matrix(-angle-angle_o);
        Temp_array=permute(reshape(transpose(Temp_array),...
            [2,Nrows,Ncols]),[2,1,3]);
        Temp_array(end,:,:)=[];
        Nrows=Nrows-1;        
        Temp_array=reshape(permute(Temp_array,[1,3,2]),[Ncols*Nrows,2,1]);
        Array=Temp_array*Rotation_Matrix(angle+angle_o); 
        New_Array=Array;
        delete(v); figure(f);
        v=viscircles(Array,radius*ones(size(Array,1),1),...
            'EdgeColor','c');     
        end
    end

    function ChangeRadius(a,~)
        r=get(a,'Value')*5*radius;
        delete(v); figure(f);
        v=viscircles(New_Array,r*ones(size(New_Array,1),1),...
            'EdgeColor','c');
    end

    function ChangeHorizontalSpacing(a,~)
      HS=(-1+2*get(a,'Value'))*size(image,2)/(2*Ncols); 
      Temp_array=Array*Rotation_Matrix(-angle-angle_o);
      Temp_array=permute(reshape(transpose(Temp_array),...
          [2,Nrows,Ncols]),[2,1,3]);
      Modification=repmat(permute((0:Ncols-1).*HS,[1,3,2]),[Nrows,1,1]);
      Temp_array(:,1,:)=Temp_array(:,1,:)+Modification;
      Temp_array=reshape(permute(Temp_array,[1,3,2]),[size(Array,1),2,1]);
      New_Array=Temp_array*Rotation_Matrix(angle+angle_o);
        delete(v); figure(f); 
        v=viscircles(New_Array,radius*ones(size(New_Array,1),1),...
            'EdgeColor','c');       
    end

    function ChangeVerticalSpacing(a,~)
      VS=(-1+2*get(a,'Value'))*size(image,1)/(2*Nrows);
      Temp_array=Array*Rotation_Matrix(-angle-angle_o);
      Temp_array=permute(reshape(transpose(Temp_array),...
          [2,Nrows,Ncols]),[2,1,3]);
      Modification=repmat(permute((0:Nrows-1).*VS,[2,1,3]),[1,1,Ncols]);      
      Temp_array(:,2,:)=Temp_array(:,2,:)+Modification; 
      Temp_array=reshape(permute(Temp_array,[1,3,2]),[size(Array,1),2,1]);
      New_Array=Temp_array*Rotation_Matrix(angle+angle_o);
        delete(v); figure(f); 
        v=viscircles(New_Array,radius*ones(size(New_Array,1),1),...
            'EdgeColor','c');            
    end

    function SetAngle(a,~)
        angle=(-1+2*get(a,'Value'))*5;  
        New_Array=Array*Rotation_Matrix(angle); 
        delete(v); figure(f); 
        v=viscircles(New_Array,radius*ones(size(New_Array,1),1),...
            'EdgeColor','c'); 
    end

    function TranslateInX(a,~)
        x=(-1+2*get(a,'Value'))*size(image,2)/10;
        New_Array=Array+repmat([x,0],[size(Array,1),1]); 
        delete(v); figure(f); 
        v=viscircles(New_Array,radius*ones(size(New_Array,1),1),...
            'EdgeColor','c'); 
    end

    function TranslateInY(a,~)
        y=(-1+2*get(a,'Value'))*size(image,1)/10;
        New_Array=Array+repmat([0,y],[size(Array,1),1]); 
        delete(v); figure(f); 
        v=viscircles(New_Array,radius*ones(size(New_Array,1),1),...
            'EdgeColor','c'); 
    end

uiwait(f);

    function SaveDefaultGrid(~,~)
       uiresume(f);
       close(f);
    end

end

