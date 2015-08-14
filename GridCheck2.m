function [] = GridCheck2(Pos_R,R_R,Pos_G,R_G)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
A=evalin('base','whos(''-regexp'',''Set'')');
Names={A.name};

for i=1:numel(Names)
   try
       GridCheck(Names{i},1,Pos_R,R_R,Pos_G,R_G);
   catch
       warning(strcat('Couldn''t do a grid check for ', Names{i}));
   end
end

end

