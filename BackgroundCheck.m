function []=BackgroundCheck(Intensity_R,Intensity_G,intensity_R,intensity_G,Background_R,Background_G,name)
parent='C:\Users\Leslie Lab\Desktop\Active\Shane';
newdir=name; mkdir(parent,newdir); path=strcat(parent,'\',newdir); cd(path);
%cd('C:\Users\Leslie Lab\Desktop\Active\Shane\NonEmpty');
for i=1:size(Intensity_R,1)
    for j=1:size(Intensity_R,2)
fig = figure; plot(permute(Intensity_R(i,j,:),[3,2,1]),'r');hold on;plot(permute(Intensity_G(i,j,:),[3,2,1]),'g');
title(sprintf('Pit(%d,%d)',i,j))
legend('Red channel', 'Green channel')
name = sprintf('Pit(%d,%d) Red VS Green',i,j);
print(fig,name,'-dpng')
close(fig)
fig = figure; plot(permute(intensity_R(i,j,:),[3,2,1]),'r');hold on;plot(permute(Background_R(i,j,:),[3,2,1]),'b');
title(sprintf('Pit(%d,%d)',i,j))
legend('Red channel', 'Background')
name = sprintf('Pit(%d,%d) Red VS Background',i,j);
print(fig,name,'-dpng')
close(fig)
fig = figure; plot(permute(intensity_G(i,j,:),[3,2,1]),'g');hold on;plot(permute(Background_G(i,j,:),[3,2,1]),'b');
title(sprintf('Pit(%d,%d)',i,j))
legend('Green channel', 'Background')
name = sprintf('Pit(%d,%d) Green VS Background',i,j);
print(fig,name,'-dpng')
close(fig)
    end
end

end