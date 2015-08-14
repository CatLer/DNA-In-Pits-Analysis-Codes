function []=PlotMeMoleculesInIntensity(Intensity_G,Intensity_R,Int_G,Int_R)
% PLOTMEMOLECULESININTENSITY : Uses the intensity of 1 green fluophore and
% 1 red fluophore (Int_G & Int_R) to draw the intensity levels above the
% traces.

Intensity_G = LevelingMySignals(Intensity_G);
Intensity_R = LevelingMySignals(Intensity_R);
figure; 
title('Cy3 & Cy5 fluophores number','fontsize',14)
xlabel('Time')
ylabel('Intensity relative to background')
hold on;
p1 = plot(medfilt1(permute(Intensity_G,[3,2,1]),100),'g');
p2 = plot(medfilt1(permute(Intensity_R,[3,2,1]),100),'r');
p3 = plot(Int_G*ones(1,size(Intensity_G,3)),'m--','linewidth',1.5);
p4 = plot(2*Int_G*ones(1,size(Intensity_G,3)),'m--','linewidth',1.5);
p5 = plot(3*Int_G*ones(1,size(Intensity_G,3)),'m--','linewidth',1.5);
p6 = plot(mean(Intensity_G,3)*ones(1,size(Intensity_G,3)),'g','linewidth',2);
p7 = plot(Int_R*ones(1,size(Intensity_R,3)),'b--','linewidth',1.5);
p8 = plot(2*Int_R*ones(1,size(Intensity_R,3)),'b--','linewidth',1.5);
p9 = plot(3*Int_R*ones(1,size(Intensity_R,3)),'b--','linewidth',1.5);
p10 = plot(mean(Intensity_R,3)*ones(1,size(Intensity_R,3)),'r','linewidth',2);
p11 = plot(zeros(1,size(Intensity_G,3)),'k--','linewidth',1.5);
hold off;
legend([p1,p2,p3,p6,p7,p10,p11],'Green signal','Red signal',...
    'Mean intensity of n-green fluophores', ...
    'Mean intensity of green signal', ...
    'Mean intensity of n-red fluophores', 'Mean intensity of red signal',...
    '0 fluophore');
end