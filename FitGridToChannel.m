function [Pos_R,R_R,Pos_G,R_G] = FitGridToChannel(Old_Channel,New_Channel,Pos_R,R_R,Pos_G,R_G)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
[optimizer, metric] = imregconfig('monomodal');

% Old_Channel=UniformBackgroundIllumination(Old_Channel,0);
% New_Channel=UniformBackgroundIllumination(New_Channel,0);
tform=imregtform(New_Channel,Old_Channel,'affine',optimizer,metric);

New_Channel_prime = imwarp(New_Channel,tform,'OutputView',imref2d(size(Old_Channel)));
figure;
subplot(1,2,1);
imshowpair(Old_Channel,New_Channel,'Scaling','joint');
title('Before');
subplot(1,2,2);
imshowpair(Old_Channel,New_Channel_prime,'Scaling','joint');
title('After');
end

