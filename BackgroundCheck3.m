function [] = BackgroundCheck3()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
A=evalin('base','whos(''-regexp'',''Set'')');
Names={A.name};

for i=1:numel(Names)
   try
       BackgroundCheck2(Names{i},1);
%        zip(strcat(Names{i},'.zip'),Names{i});
%        rmdir(Names{i});
   catch
       warning(strcat('Couldn''t do a background check for ', Names{i}));
   end
end

end

