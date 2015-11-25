function [] = MickeyUI(a,b)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if strcmp(get(a,'Label'),'Move')
set(gco,'ButtonDownFcn',@MoveUicontrolWithMouse);
end
if strcmp(get(a,'Label'),'Stop')
set(gco,'ButtonDownFcn','');
set(gcf,'WindowButtonUpFcn','');
end
end

