function[]=MoveUicontrolWithMouse(~,~)
%UNTITLED2 Summary of this function goes herev
%   Detailed explanation goes here

myUI=gcbo; fig=gcf; 
next_position=get(myUI,'Position');

set(fig,'WindowButtonDownFcn',{@Follow});
set(fig,'WindowButtonUpFcn',{@FollowNot});

    function Follow(~,~)
        set(fig,'WindowButtonMotionFcn',{@LittleMouse});
    end
    function FollowNot(~,~)
        set(fig,'WindowButtonMotionFcn','');
        set(myUI,'Position',next_position);
    end


    function LittleMouse(~,~)
        parent=get(gcf,'Parent');
        pointer=get(parent,'PointerLocation');
        f=get(fig,'Position');
        pointer=pointer-f(1:2);
        previous_position=get(myUI,'Position');
        pointer(1)=min(max(pointer(1),1),f(3)-previous_position(3));
        pointer(2)=min(max(pointer(2),1),f(4)-previous_position(4));        
        next_position=previous_position;
        next_position(1:2)=pointer;
    end

end

