function [f,F,list] = Fret_efficiency(Intensity_R,Intensity_G)
[r,c] = find(mean(Intensity_G,3)>0 & mean(Intensity_R,3)>0);
F = []; list = [];
num_rows = size(Intensity_R,1);
num_cols = size(Intensity_R,2);
for k=1:numel(r)
    i = r(k);
    j = c(k);
    if i>1 && i<num_rows && j>1 && j<num_cols
        w = 100;
        Int_G = medfilt1(Intensity_G(i,j,:)-mean(Intensity_G(i,j,:)),w) ;
        Int_R = medfilt1((Intensity_R(i,j,:)-mean(Intensity_R(i,j,:))),w);
        Int_G = Int_G(:,:,1+w:size(Int_G,3)-w);
        Int_R = Int_R(:,:,1+w:size(Int_R,3)-w);
        Int_G = permute(Int_G,[3,2,1]);
        Int_R = permute(Int_R,[3,2,1]);
        IntG = Int_G - mean(Int_G);
        IntR = Int_R - mean(Int_R);
        I_G = trapz(IntG);
        I_R = trapz(IntR);
        [Y,X] = xcorr(IntG,-IntR,'coeff');
        Y(Y<0) = 0;
        Error = 100;
        Indices = round(numel(X)/2)-Error:round(numel(X)/2)+Error;
        Y_T = Y(Indices);
        P = findpeaks(Y_T,'minpeakheight',0.33);
        if sign(I_G)*sign(I_R)>0 && numel(P)>=1 
            Ratio = I_R/(I_R+I_G);
            if Ratio<=1
                F = cat(1,F,Ratio);
                figure; plot(Int_G,'g'); hold on; plot(Int_R,'r');
                t = sprintf('In green laser, pit(%d,%d)',i,j);
                title(t);
                legend('Green channel', 'red channel');
                figure; plot(X,Y,'m');
                t = sprintf('Cross correlation, pit(%d,%d)',i,j);
                title(t);
                list = cat(1, list, [i,j]);                       
            end
        end
    end
end
 f = [mean(F), std(F)];
end


% X = cat(1,statelevels(Int_G,1000),statelevels(Int_G,100),statelevels(Int_G,10)) 
% X = diff(cat(1,statelevels(Int_G,1000),statelevels(Int_G,100),statelevels(Int_G,10)),1,2)
% slewrate(Int_G)
% slewrate(Int_R)