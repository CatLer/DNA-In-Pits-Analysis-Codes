function [varargout]=ConstructPitsGrid(varargin)
%CONSTRUCTPITSGRID : Uniformizes the background illumination. Uses 2D cross
%correlation to determine where the sample pit (empty & non-empty) repeats
%itself. Determines the angle from the Radon transform of the cross
%correlation, and the approximate positions of the rows and columns. Find
%local maxima closest to these imaginary lines. Recquires GridRegistration
%output (the grid needs to be register once) to generate default grid and
%fit it. Does it for both channels.
%   Detailed explanation goes here

narginchk(3,6);
pitsgrid=varargin{1};
Visualization=varargin{2};
Experiment=varargin{3};
if nargin>=4 && ~isempty(varargin{4})
GridRegistrationFile=varargin{4};
else
    [file,path]=uigetfile('*.mat', 'Pick a Grid Registration file');
    if file==0
        warning('You didn''t select a Grid Registration file!');
        return;
    end
    GridRegistrationFile=fullfile(path,file);    
end
Ver_Horz = varargin{5};
%==========================================================================
% type of experiment
Experiment=char(Experiment);
if nargin>=5
myName=varargin{5};
else
    myName=inputname(1);
end
if nargin==6
    Previous_Grid=varargin{6};
else
    Previous_Grid=[];
end

if ~(strcmpi(strrep(Experiment,' ',''),'DualView') ...
        || strcmpi(strrep(Experiment,' ',''),'SingleView'))
    Experiment='DualView';
end
%------------------------ Grid's parameters  ------------------------------
% collapse video frames
pitsgrid=mat2gray(mean(pitsgrid,3)); 
% pitsgrid=imsharpen(pitsgrid); % new
% load grid parameters
if ischar(GridRegistrationFile)
Variables=load(GridRegistrationFile);
else
    Variables=GridRegistrationFile;
end
% pit's dimension
Radius=Variables.Radius;
% spacings
Horizontal_spacing=Variables.Horizontal_spacing;
Vertical_spacing=Variables.Vertical_spacing;
average_spacing=mean([Horizontal_spacing,Vertical_spacing]);
% pit samples (empty & non-empty in red & green channels)
Template_empty_R=Variables.Template_empty_R;
Template_empty_G=Variables.Template_empty_G;
Template_nonempty_R=Variables.Template_nonempty_R;
Template_nonempty_G=Variables.Template_nonempty_G;
%--------------------------------------------------------------------------
%------------------------ Define channels ---------------------------------
if strcmpi(strrep(Experiment,' ',''),'DualView')
    Experiment='Dual View';
% define Red Channel & Green Channel
[Red_Channel,Green_Channel] = FindChannelSeparation(pitsgrid,Ver_Horz); %new
% offset of green channel (right hand side)
Offset_G=size(Red_Channel,2);
else
     Experiment='Single View';
end
%--------------------------------------------------------------------------
%---------------- Uniformize background illumination ----------------------
if strcmpi(strrep(Experiment,' ',''),'DualView')
% red channel
Red_Channel=UniformBackgroundIllumination(Red_Channel,0);
% green channel
Green_Channel=UniformBackgroundIllumination(Green_Channel,0);
else
    Green_Channel=UniformBackgroundIllumination(pitsgrid,0);
end
%--------------------------------------------------------------------------
%==========================================================================
%------------------------ Generate grids ----------------------------------

% generate pits' positions in green channel
[Pos_G,N_rows_G,N_cols_G,angleG]=ConstructMyGrid(Template_empty_G,Template_nonempty_G,Green_Channel);
if Visualization==1
    if ~isempty(Previous_Grid)
    Previous_Grid_G=Previous_Grid(end-3:end);
    else
        Previous_Grid_G=[];
    end
[Pos_G,N_rows_G,N_cols_G,RadiusG]=ResizeGrid(Pos_G,N_rows_G,N_cols_G,Radius,Green_Channel,angleG,Previous_Grid_G); 
end
N_rows=N_rows_G; N_cols=N_cols_G;

if strcmpi(strrep(Experiment,' ',''),'DualView')
    % generate pits' positions in red channel
    if isempty(Template_empty_R) || isempty(Template_nonempty_R)
        Template_empty_R=Template_empty_G;
        Template_nonempty_R=Template_nonempty_G;
    end
    [Pos_R,N_rows_R,N_cols_R,angleR]=ConstructMyGrid(Template_empty_R,Template_nonempty_R,Red_Channel);
    if Visualization==1
        if ~isempty(Previous_Grid)
        Previous_Grid_R=Previous_Grid(cat(2,1,end-2:end));
        else
            Previous_Grid_R=[];
        end
        [Pos_R,N_rows_R,N_cols_R,RadiusR]=ResizeGrid(Pos_R,N_rows_R,N_cols_R,Radius,Red_Channel,angleR,Previous_Grid_R);
        Radius=max(RadiusG,RadiusR);
    end
    Pos_G(:,1)=Pos_G(:,1)+Offset_G;
    % look for dimension dismatch if N_G~=N_R
else
    if Visualization==1
        Radius=RadiusG;
    end
end

% output

if strcmpi(strrep(Experiment,' ',''),'DualView')
varargout={Pos_R,Pos_G,Radius,N_rows,N_cols,angleG};
else
    varargout={Pos_G,Radius,N_rows,N_cols,angleG};
end

if Visualization>=1
f=figure; 
if strcmpi(strrep(Experiment,' ',''),'DualView')
imshow(cat(2,Red_Channel,Green_Channel));
else
    imshow(Green_Channel);
end
viscircles(Pos_G,Radius*ones(size(Pos_G,1),1),'Edgecolor','g');
if strcmpi(strrep(Experiment,' ',''),'DualView')
viscircles(Pos_R,Radius*ones(size(Pos_R,1),1),'Edgecolor','r');
end
if Visualization==1
uicontrol(f,'String','Save This Grid In A Mat File',...
    'Position',[50,200,250,100],'FontSize',12,'Callback',@SaveMyGrid);
uiwait(f);
end
end

function []=SaveMyGrid(~,~)
Path=uigetdir('Select A Folder Where To Save This Grid...');
if Path~=0
    FileName=strcat(myName,'_DefaultGrid_',Experiment,'.mat');
    FileName=fullfile(Path,FileName);
    save(FileName,'varargout');
    msgbox('The Grid Was Saved.');
end
end

%--------------------------------------------------------------------------
%==========================================================================
%----------------------------- Functions ----------------------------------
% function to generate pits' positions
    function [Pairs,N_rows,N_cols,angle]=ConstructMyGrid(Template_empty,Template_nonempty,Channel)
       
        % find empty pits
        CC_1=normxcorr2(Template_empty,Channel);
        % find non-empty pits
        CC_2=normxcorr2(Template_nonempty,Channel);
        
        % sum peaks        
        EmptySize = size(Template_empty);       
        padLow = floor(EmptySize/2);
        padHigh = EmptySize-padLow-1;
        CC_1=CC_1((1+padLow(1)):(end-padHigh(1)),(1+padLow(2)):(end-padHigh(2)));
        NonEmptySize = size(Template_nonempty);
        padLow = floor(NonEmptySize/2);
        padHigh = NonEmptySize-padLow-1;
        CC_2=CC_2((1+padLow(1)):(end-padHigh(1)),(1+padLow(2)):(end-padHigh(2)));                
        CC=abs(CC_1)+abs(CC_2);
%         figure; surf(CC); shading flat
                
        % collapse peaks into single points using the grid's average spacing
        a=round(2*(average_spacing-Radius));
        if mod(a,2)==1
            mat = ones(a);
        else
            mat=ones(a+1);
        end
        mat(ceil(end/2),ceil(end/2))=0;
        bw = CC > imdilate(CC,mat); bw = CC.*bw;
%                 figure; surf(bw); shading flat;
        % use Radon transform to find the angle of the grid and approximate
        % positions of the imaginary lines
        theta_1=-5:0.5:5; [R_1,x_1]=radon(bw,theta_1);
        theta_2=85:0.5:95; [R_2,x_2]=radon(bw,theta_2);
        
        %         figure; imshow(R,[],'Xdata',theta,'Ydata',x,...
        %           'InitialMagnification','fit'); colormap(hot);
%                 figure; surf(R_1); shading flat;
%                 figure; imshow(R_1,[],'Xdata',theta_1,'Ydata',x_1); colormap(hot);
%                 figure; surf(R_2); shading flat;
%                 figure; imshow(R_2,[],'Xdata',theta_2,'Ydata',x_2); colormap(hot);
                
        N_cols=ceil(size(Channel,2)/Horizontal_spacing); 
        Cols_H=[];
        Cols_P=cell(1,size(R_1,2));
        for i=1:size(R_1,2)
            [P,I]=findpeaks(R_1(:,i),'MinPeakDistance',...
                round(Horizontal_spacing-Radius),'NPeaks',N_cols);
            Cols_H=cat(1,Cols_H,[mean(P),numel(P)]);
            Cols_P{i}=sort(I);
        end
        N_rows=ceil(size(Channel,1)/Vertical_spacing);
        Rows_H=[];
        Rows_P=cell(1,size(R_2,2));
        for i=1:size(R_2,2)
            [P,I]=findpeaks(R_2(:,i),'MinPeakDistance',...
                round(Vertical_spacing-Radius),'NPeaks',N_rows);
            Rows_H=cat(1,Rows_H,[mean(P),numel(P)]);
            Rows_P{i}=sort(I);
        end
        [~,i]=max(Cols_H(:,1)); [~,j]=max(Rows_H(:,1));
        i=round(mean([i,j])); angle=-5+(i-1)*0.5;
        num_rows=Rows_H(i,2); num_cols=Cols_H(i,2);
        
        %offset=floor((size(Channel)+1)/2)
        offset=floor((size(bw)+1)/2);        
        
        x_1=x_1(Cols_P{i}); x_1=x_1+offset(2);
        x_2=x_2(Rows_P{i}); x_2=size(bw,1)-x_2-offset(1);   

%         x_2=x_2-((x_1(end)-x_1(1))*sind(angle))/2;
%         x_1=x_1-((x_2(end)-x_2(1))*sind(angle))/2;
        
        a=mean(mod(x_1,Horizontal_spacing));
        b=mean(mod(x_2,Vertical_spacing));
%         Maybe useful?
        a=[Horizontal_spacing-a,a]; [~,ia]=min(abs(a)); a=a(ia)*(-1)^ia; % in test
        b=[Horizontal_spacing-b,b]; [~,ib]=min(abs(b)); b=b(ib)*(-1)^ib; % in test       

        % generate default grid using imaginary lines and angle
        x=0:Horizontal_spacing:size(Channel,2); x=x+a;
        y=0:Vertical_spacing:size(Channel,1); y=y+b; 
        
        x=x(x>=0 & x<=size(Channel,1)); % new
%         y=y(y>=0 & y<=size(Channel,2));

        [p,q]=meshgrid(x,y);Pairs=[p(:),q(:)];Pairs=sortrows(Pairs);
        R=[cosd(angle),-sind(angle);sind(angle),cosd(angle)];Pairs=Pairs*R;
%         figure; imshow(Channel); viscircles(Pairs,Radius*ones(size(Pairs,1),1),'EdgeColor','m');
               
        % adjust grid by fitting it better to the peaks (but keep grid's parameters)
        stats=regionprops(logical(bw),bw,'WeightedCentroid','MaxIntensity');
        values={stats.MaxIntensity}; values=values(:); values=cell2mat(values);
        peaks={stats.WeightedCentroid};peaks=peaks(:);peaks=cell2mat(peaks);
        N=min(size(peaks,1),num_rows*num_cols);
        [~,I]=NExtrema(values,N,'max'); peaks=peaks(I(:,1),:);
        X=createns(Pairs);I=knnsearch(X,peaks);Differences=Pairs(I,:)-peaks;
        Differences(sqrt(sum(Differences.^2,2))>average_spacing-Radius,:)=[];
        offset=trimmean(Differences,5,1);
        Pairs(:,1)=Pairs(:,1)-offset(1);
        Pairs(:,2)=Pairs(:,2)-offset(2);
        
%         Pairs = Pairs(Pairs(:,1)>=0,:); % new
%         Pairs = Pairs(size(Channel,1)>=0,:); % new

        [N_rows,N_cols]=...
            GuessNumRowsCols(size(Pairs,1), N_rows, N_cols); % new
        
        PairsPrime=permute(reshape(transpose(Pairs),...
            [2,N_rows,N_cols]),[2,1,3]);
        PP=sign(PairsPrime);
        n_rows=N_rows; n_cols=N_cols;
        
        for p=1:size(PP,1)
           if min(PP(p,2,:))==-1
                PP(p,:,:)=NaN;
                n_rows=n_rows-1;
           end
        end

        for q=1:size(PP,3)
           if min(PP(:,1,q))==-1
                PP(:,:,q)=NaN;
                n_cols=n_cols-1;
           end
        end        

        PP=~isnan(PP); PP=reshape(permute(PP,[1,3,2]),[N_cols*N_rows,2,1]);
        Pairs=Pairs(PP(:,1),:); N_rows=n_rows; N_cols=n_cols;
        
     
%       if Visualization==1
%       figure; imshow(Channel);  viscircles(Pairs,Radius*ones(size(Pairs,1),1),'EdgeColor','b');
%       end
      
    end
%--------------------------------------------------------------------------
%==========================================================================
end


% MinR=min(PairsPrimeR,[],1); MinG=min(PairsPrimeG,[],1); %new
% MaxR=max(PairsPrimeR,[],1); MaxG=max(PairsPrimeG,[],1); %new
% X=[MinR(1),MinG(1);MaxR(1),MaxG(1)]; MinX=max(X(1,:)); MaxX=min(X(2,:)); %new
% Y=[MinR(2),MinG(2);MaxR(2),MaxG(2)]; MinY=max(Y(1,:)); MaxY=min(Y(2,:)); %new
% MinX=max(MinX-Radius,0); %new
% MaxX=min(MaxX+Radius,min(size(Red_Channel,2),size(Green_Channel,2))); %new
% MinY=max(MinY-Radius,0); %new
% MaxY=min(MaxY+Radius,min(size(Red_Channel,1),size(Green_Channel,1))); %new
% XR=PairsPrimeR(:,1)<MinX | PairsPrimeR(:,1)>MaxX; Pos_R(XR,:)=NaN; %new
% YR=PairsPrimeR(:,2)<MinY | PairsPrimeR(:,2)>MaxY; Pos_R(YR,:)=NaN; %new
% XG=PairsPrimeG(:,1)<MinX | PairsPrimeG(:,1)>MaxX; Pos_G(XG,:)=NaN; %new
% YG=PairsPrimeG(:,2)<MinY | PairsPrimeG(:,2)>MaxY; Pos_G(YG,:)=NaN; %new
% Pos_R(isnan(sum(Pos_R,2)),:)=[]; Pos_G(isnan(sum(Pos_G,2)),:)=[]; %new