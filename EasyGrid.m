function [Positions,Dimensions,Success,Input,Rotation,Translation,...
    num_rows,num_cols,Radius, Grid_Size] = EasyGrid(Input,HS,Polarity)
%EASYGRID : given the outputs of EasyDetection, generates a grid with the
%positions of the pits and their dimensions.
%   Calls findPitsTilt, FirstGrid, Good_Fit_Pit,
%   Maximize_Intensity_In_Pits, Good_Fit_Grid, EvenlySpaced if necessary,
%   and returns a measure of success so PitsMesh can decide the outcome.

% EXPECTED RANGE 
% (17-20) x (7-10)
%======================= GRID CREATION ====================================
Angle = 0;
Theta = 0;
X = 0;
Y = 0;
%----------------------- Frame Alignment ----------------------------------
 [Angle,Input]= findPitsTilt(Input);
%------------------------- Segmentation -----------------------------------
% Seg = multithresh(Input,2);
% Input(Input<Seg(1))= trimmean(Input(:),10);
% Input = imquantize(Input,multithresh(Input,2));
%------------------------- Clustering -------------------------------------
[Pairs, TopRightCorner, TopLeftCorner, BottomRightCorner,...
    BottomLeftCorner,~,~,num_rows,num_cols,Input,Radius]= ...
    FirstGrid(Input, HS, Polarity);
%------------------------- Pit's Size -------------------------------------
 [TopRightCorner, TopLeftCorner, BottomRightCorner,...
     BottomLeftCorner,R]= Good_Fit_Pit( Input, TopRightCorner,...
     TopLeftCorner, BottomRightCorner, BottomLeftCorner, Radius);
 Radius = Radius+R;
%----------------------- Grid Optimization --------------------------------
% [Input,Theta,X,Y] = Maximize_Intensity_In_Pits(Input, TopRightCorner,...
%     TopLeftCorner, BottomRightCorner, BottomLeftCorner);
%---------------------- Grid Success --------------------------------------
[Grid_Size,Success]= Good_Fit_Grid(Pairs,num_rows,num_cols,Radius,...
    Input,TopRightCorner,TopLeftCorner,BottomRightCorner,BottomLeftCorner);
%---------------------- Evenly spaced -------------------------------------
% intended for bad-looking grids only
% if Success==0
% [Pairs,TopRightCorner,TopLeftCorner,BottomRightCorner,BottomLeftCorner,...
%     num_rows,num_cols]= EvenlySpaced(Input,Grid_Size,Radius,Pairs);
% [~,Success]= Good_Fit_Grid(Pairs,num_rows,num_cols,Radius,...
%     Input,TopRightCorner,TopLeftCorner,BottomRightCorner,BottomLeftCorner);
% end
%================= PITS POSITIONS & DIMENSIONS ============================
%---------------------- Positions -----------------------------------------
Positions = Pairs;
%---------------------- Dimensions ----------------------------------------
Dimensions = cat(3,BottomRightCorner, TopLeftCorner, TopRightCorner,...
    BottomLeftCorner);
%===================== CHANNEL SETTINGS ===================================
%----------------------- Rotation -----------------------------------------
Rotation = Angle + Theta;
%---------------------- Translation ---------------------------------------
Translation = [X, Y];
%======================== VISUALIZATION =================================== 
%------------------------ Plotting ----------------------------------------
figure
imshow(Input, [])
    hold on
    % viscircles(Positions, ones(size(Positions,1),1), 'EdgeColor', 'y');
    for i=1:size(Positions,1)
        line(reshape(Dimensions(i,1,[1;3;2;4;1]),1,5), ...
            reshape(Dimensions(i,2,[1;3;2;4;1]),1,5),'color','m')
    end

end
%==========================================================================
