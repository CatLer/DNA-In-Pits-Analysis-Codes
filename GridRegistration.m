function status = GridRegistration(pitsgrid_empty,pitsgrid_non_empty,destFolder)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
pitsgrid_empty=mat2gray(sum(mat2gray(pitsgrid_empty),3));
pitsgrid_non_empty=mat2gray(sum(mat2gray(pitsgrid_non_empty),3));
%=========================== Enhance image ================================
% pitsgrid_empty_R=SelectSample(' the red channel.',pitsgrid_empty);
% pitsgrid_empty_G=SelectSample(' the green channel.',pitsgrid_empty);
% pitsgrid_non_empty_R=SelectSample(' the red channel.',pitsgrid_non_empty);
% pitsgrid_non_empty_G=SelectSample(' the green channel.',pitsgrid_non_empty);

pitsgrid_empty_R=pitsgrid_empty(:,1:floor(end/2));
pitsgrid_empty_G=pitsgrid_empty(:,ceil(end/2):end);
pitsgrid_non_empty_R=pitsgrid_non_empty(:,1:floor(end/2));
pitsgrid_non_empty_G=pitsgrid_non_empty(:,ceil(end/2):end);

%------------------ Uniformize background illumination --------------------
if ~isempty(pitsgrid_empty_R)
    pitsgrid_empty_R=UniformBackgroundIllumination(pitsgrid_empty_R,0);
end
if ~isempty(pitsgrid_empty_G)
    pitsgrid_empty_G=UniformBackgroundIllumination(pitsgrid_empty_G,0);
end
if ~isempty(pitsgrid_non_empty_R)
    pitsgrid_non_empty_R=UniformBackgroundIllumination(pitsgrid_non_empty_R,0);
end
if ~isempty(pitsgrid_non_empty_G)
    pitsgrid_non_empty_G=UniformBackgroundIllumination(pitsgrid_non_empty_G,0);
end
%--------------------------------------------------------------------------
%==========================================================================
Template_empty_R=[]; Template_empty_G=[];
Template_nonempty_R=[]; Template_nonempty_G=[];
Radius_empty_R=[]; Radius_empty_G=[];
Radius_nonempty_R=[]; Radius_nonempty_G=[];
Horizontal_spacing_R=[]; Horizontal_spacing_G=[];
Vertical_spacing_R=[]; Vertical_spacing_G=[];
try
    if ~isempty(pitsgrid_empty_R)
        Template_empty_R=SelectSample('a single empty pit in the red channel.',pitsgrid_empty_R);
        [Template_empty_R,Radius_empty_R]=detectPit(Template_empty_R);
    end
    if ~isempty(pitsgrid_empty_G)
        Template_empty_G=SelectSample('a single empty pit in the green channel.',pitsgrid_empty_G);
        [Template_empty_G,Radius_empty_G]=detectPit(Template_empty_G);
    end
    if ~isempty(pitsgrid_non_empty_R)
        Template_nonempty_R=SelectSample('a single non empty pit in the red channel.',pitsgrid_non_empty_R);
        [Template_nonempty_R,Radius_nonempty_R]=detectPit(Template_nonempty_R);
    end
    if ~isempty(pitsgrid_non_empty_G)
        Template_nonempty_G=SelectSample('a single non empty pit in the green channel.',pitsgrid_non_empty_G);
        [Template_nonempty_G,Radius_nonempty_G]=detectPit(Template_nonempty_G);
    end
    if ~isempty(pitsgrid_empty_R) && ~isempty(Template_empty_R)
        Template_2pits_Hon_R=SelectSample(' 2 horizontal empty pits in the red channel.',pitsgrid_empty_R);
        Horizontal_spacing_R=EstimateSpacing(Template_2pits_Hon_R,Template_empty_R,Radius_empty_R);
        Template_2pits_Vet_R=SelectSample(' 2 vertical empty pits in the red channel.',pitsgrid_empty_R);
        Vertical_spacing_R=EstimateSpacing(Template_2pits_Vet_R,Template_empty_R,Radius_empty_R);
    end
    if ~isempty(pitsgrid_empty_G) && ~isempty(Template_empty_G)
        Template_2pits_Hon_G=SelectSample(' 2 horizontal empty pits in the green channel.',pitsgrid_empty_G);
        Horizontal_spacing_G=EstimateSpacing(Template_2pits_Hon_G,Template_empty_G,Radius_empty_G);
        Template_2pits_Vet_G=SelectSample(' 2 vertical empty pits in the green channel.',pitsgrid_empty_G);
        Vertical_spacing_G=EstimateSpacing(Template_2pits_Vet_G,Template_empty_G,Radius_empty_G);
    end
catch ME
    errordlg('Grid Registration Failed');
    status = false;
    return;
end    

Radius=min([Radius_empty_R,Radius_nonempty_R,Radius_empty_G,Radius_nonempty_G]);
Horizontal_spacing=mean([Horizontal_spacing_R,Horizontal_spacing_G]); %#ok<*NASGU>
Vertical_spacing=mean([Vertical_spacing_R,Vertical_spacing_G]);

save(strcat(destFolder,'\GridRegistration.mat'),'Horizontal_spacing','Vertical_spacing',...
    'Radius', 'Template_nonempty_R','Template_empty_R',...
    'Template_nonempty_G','Template_empty_G');
%==========================================================================
%--------------------- Spacing estimation function ------------------------
    function spacing=EstimateSpacing(Template,Template_empty,Radius_empty)
        try
            CC=normxcorr2(Template_empty,Template);
            a=round(2*Radius_empty);
            if mod(a,2)==1
                mat = ones(a);
            else
                mat=ones(a+1);
            end
            mat(ceil(end/2),ceil(end/2))=0;
            bw = CC > imdilate(CC,mat); bw = CC.*bw;
            stats=regionprops(logical(bw),bw,'WeightedCentroid','MaxIntensity');
            peaks={stats.WeightedCentroid}; peaks=peaks(:); peaks=cell2mat(peaks);
            heights={stats.MaxIntensity}; heights=heights(:); heights=cell2mat(heights);
            [~,indices]=NExtrema(heights,2,'max'); peaks=peaks(indices(:,1),:);
            spacing=sqrt(sum(diff(peaks,1,1).^2));
%             figure; surf(CC); shading flat
        catch ME
            sprintf(ME.identifier);
        end
    end
%--------------------------------------------------------------------------
%==========================================================================

%==========================================================================
%---------------------- Sample selection function  ------------------------
    function Template=SelectSample(str,pitsgrid)
        Template=[];
        while isempty(Template)
            string=strcat(...
                'Please, select the cleanest region enclosing ',str,...
                'Double-click once you''re done.');
            choice = ...
                questdlg(string,'Pit(s) Selection','Ok','No','No');
            switch choice
                case 'Ok'
                    set(gcf,'MenuBar','None','Name',...
                        'Select Sample Pit(s)','NumberTitle','off');
                    Template = imcrop(pitsgrid);
                otherwise
                    close(gcf);error('Grid Registration Failed');
            end
        end
        close(gcf);
    end
%--------------------------------------------------------------------------
%==========================================================================
%---------------------- Pit Detection Function ----------------------------
    function [Template,Radius]=detectPit(Template)
        warning('off','all');
        [c_bright,r_bright]=imfindcircles(Template,[2,15],'ObjectPolarity',...
            'bright','sensitivity',0.9,'method','TwoStage');
        [c_dark,r_dark]=imfindcircles(Template,[2,15],'ObjectPolarity','dark',...
            'sensitivity',0.9,'method','TwoStage');
        if isempty(c_dark)
            Center=c_bright; Radius=r_bright;
        else
            [~,Center]=kmeans(cat(1,c_dark,c_bright),1);
            Center_dark=repmat(Center,size(c_dark,1),1);
            Center_bright=repmat(Center,size(c_bright,1),1);
            Radius=max(max(sqrt(sum((c_dark-Center_dark).^2,2))+...
                r_dark,[],1),max(sqrt(sum((c_bright-Center_bright).^2,2))+r_bright,[],1));
        end
        Fig = figure('Name','Template'); imshow(Template); h=viscircles(Center,Radius,'EdgeColor','b');
        string=strcat(...
            'Is this the right size?');
        choice = ...
            questdlg(string,'Pit Dimension','Ok','No','No');
        switch choice
            case 'Ok'
                Template=imcrop(Template,...
                    [Center(1)-Radius,Center(2)-Radius,2*Radius,2*Radius]);
                close(gcf)
            case 'No'
                helpDlg = helpdlg('Resize the circle to enclose the pit (outside). Double-click once you''re done.');
                figure(Fig);        %Go to Fig with template, so ellipse won't be placed on helpdlg
                delete(h);
                h=imellipse(gca,[Center(1)-Radius,Center(2)-Radius,2*Radius,2*Radius]);
                figure(helpDlg);
                setColor(h,'m'); %h.Deletable = false; 
                setFixedAspectRatioMode(h,true);
                fcn = makeConstrainToRectFcn('imellipse',get(gca,'XLim'),get(gca,'YLim'));
                setPositionConstraintFcn(h,fcn); wait(h); x=getPosition(h);
                Radius=mean(x(3:4))/2; Template=imcrop(Template,x); close(gcf); delete(h);
            otherwise
                close all; error('Grid Registration Failed');
        end
        
        warning('on','all');
    end
%--------------------------------------------------------------------------
%==========================================================================
status = true;
end

