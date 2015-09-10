function [Pos_R,Pos_G,Radius,N_rows,N_cols] = ConstructPitsGrid(pitsgrid)
%CONSTRUCTPITSGRID : Uniformizes the background illumination. Uses 2D cross
%correlation to determine where the sample pit (empty & non-empty) repeats
%itself. Determines the angle from the Radon transform of the cross
%correlation, and the approximate positions of the rows and columns. Find
%local maxima closest to these imaginary lines. Recquires GridRegistration
%output (the grid needs to be register once) to generate default grid and
%fit it. Does it for both channels.
%   Detailed explanation goes here
%==========================================================================
%------------------------ Grid's parameters  ------------------------------
% collapse video frames
pitsgrid=mat2gray(mean(pitsgrid,3));
% load grid parameters
Variables=load('GridRegistration.mat');
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
% define Red Channel & Green Channel
[Red_Channel,Green_Channel] = FindChannelSeparation(pitsgrid); %new
% offset of green channel (right hand side)
Offset_G=size(Red_Channel,2);
%--------------------------------------------------------------------------
%---------------- Uniformize background illumination ----------------------
% red channel
Red_Channel=UniformBackgroundIllumination(Red_Channel,0);
% green channel
Green_Channel=UniformBackgroundIllumination(Green_Channel,0);
%--------------------------------------------------------------------------
%==========================================================================
%------------------------ Generate grids ----------------------------------
% generate pits' positions in red channel
[Pos_R,N_rows_R,N_cols_R]=ConstructMyGrid(Template_empty_R,Template_nonempty_R,Red_Channel);
% generate pits' positions in green channel
[Pos_G,N_rows_G,N_cols_G]=ConstructMyGrid(Template_empty_G,Template_nonempty_G,Green_Channel);
Pos_G(:,1)=Pos_G(:,1)+Offset_G;

if N_rows_R==N_rows_G && N_cols_R==N_cols_G
    N_rows=N_rows_R; N_cols=N_cols_R;
else
    error('Not same grid dimensions for both channels.');
%     [Nr,nr]=max(N_rows_R,N_rows_G);
%     [Nc,nc]=max(N_cols_R,N_cols_G);
%     do something !!! 
end

% visualization
% figure; imshow(pitsgrid);
% viscircles(Pos_G,Radius*ones(size(Pos_G,1),1),'Edgecolor','g');
% viscircles(Pos_R,Radius*ones(size(Pos_R,1),1),'Edgecolor','r');
% compare grids in both channels
% number of rows and columns
%--------------------------------------------------------------------------
%==========================================================================
%----------------------------- Functions ----------------------------------
% function to generate pits' positions
    function [Pairs,N_rows,N_cols]=ConstructMyGrid(Template_empty,Template_nonempty,Channel)
       
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
%                 figure; surf(R_2); shading flat;
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
        offset=floor((size(Channel)+1)/2);
        x_1=x_1(Cols_P{i})+offset(2);
        x_2=x_2(Rows_P{i})+offset(1);        
        x_2=x_2-((x_1(end)-x_1(1))*sind(angle))/2;
        x_1=x_1-((x_2(end)-x_2(1))*sind(angle))/2;
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
        R = [cosd(angle),-sind(angle);sind(angle),cosd(angle)];Pairs=Pairs*R;
%         figure; imshow(Channel); %viscircles(Pairs,Radius*ones(size(Pairs,1),1),'EdgeColor','m');
               
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
        % remove incomplete pits (DONE IN MY_MASK)
%         PairsPrime=mat2cell(Pairs,ones(size(Pairs,1),1),2); % new
%         PairsPrime=reshape(PairsPrime,[N_rows,N_cols]); % new
%         Use this in my_mask to keep track of what is removed!
%       figure; imshow(Channel);  viscircles(Pairs,Radius*ones(size(Pairs,1),1),'EdgeColor','b');
    end
%--------------------------------------------------------------------------
%==========================================================================
end