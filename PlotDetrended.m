function [] = PlotDetrended(a,b, gArray, rArray)
boxWidth=39;
yg = reshape(gArray(a,b,:), size(gArray,3), 1);
yr = reshape(rArray(a,b,:), size(rArray,3), 1);
GA = DetrendingFRET(yg);
RA = DetrendingFRET(yr);
figure
subplot(2,2,1)
hold on
plot(GA, 'g', 'linewidth', 1.0)
plot(RA, 'r', 'linewidth', 1.0)
title('Output')
hold off
subplot(2,2,2)
hold on
plot(sgolayfilt(squeeze(GA),0,boxWidth), 'g', 'linewidth', 1.0)
plot(sgolayfilt(squeeze(RA),0,boxWidth), 'r', 'linewidth', 1.0)
title('Output')
hold off
subplot(2,2,3)
hold on
plot(yg, 'g', 'linewidth', 1.0)
plot(yr, 'r', 'linewidth', 1.0)
title('Input')
hold off
subplot(2,2,4)
hold on
plot(sgolayfilt(squeeze(yg),0,boxWidth), 'g', 'linewidth', 1.0)
plot(sgolayfilt(squeeze(yr),0,boxWidth), 'r', 'linewidth', 1.0)
title('Input')
hold off
end