function [] = closing_figure(~,~)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%         nf=length(findall(0,'type','figure','name','DNA In Pits User Interface'));  % with visibility on & off
%         if nf==1  ||  length(findobj(0, 'type', 'figure','DNA In Pits User Interface'))>1
            delete(gcf)
%         end

end

