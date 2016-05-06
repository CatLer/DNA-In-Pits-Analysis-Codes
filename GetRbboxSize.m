function [] = GetRbboxSize(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
figure_handle=gcf;
axis_handles=findall(figure_handle,'type','axes');

% for the conversion
set(axis_handles,'units','pixels'); 
P=get(axis_handles,'Position');
X_Lim=get(axis_handles,'xlim'); 
Y_Lim=get(axis_handles,'ylim');
if ~iscell(P)
    P={P};
    X_Lim={X_Lim};
    Y_Lim={Y_Lim};
end
delta_x=cellfun(@(x,y)diff(x)/y(3),X_Lim,P);
delta_y=cellfun(@(x,y)diff(x)/y(4),Y_Lim,P);


waitforbuttonpress;
Rect=rbbox;

Pprime=cellfun(@(x)x(1:2),P,'uniformoutput',false);
Pprime=cell2mat(Pprime);
Index=knnsearch(Pprime,Rect(1:2));
DX=delta_x(Index,:); DY=delta_y(Index,:);
Rect([1,3])=Rect([1,3])*DX;
Rect([2,4])=Rect([2,4])*DY;

% add annotation to keep track
% allow modification of the rectangle
% save binding time
Rect

end

