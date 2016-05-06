function [input,theta,x,y]= Maximize_Intensity_In_Pits(Input,TRC,TLC,BRC,BLC)
%MAXIMIZE_INTENSITY_IN_PITS: Translates and rotates the frame relative to
%previously localized pits to collect total max intensity in the pits.
%   Uses masks to get the intensity in the pits and maximizes it. Doesn't
%   change the dimensions of the pits (radius) or the number of rows or
%   columns (the actual grid).

Rin = imref2d(size(Input));

    function Intensity = move_me(X)
        % X = [x, y, theta]
        tform = affine2d([cos(X(3)),-sin(X(3)),0; sin(X(3)),cos(X(3)),0; X(1),X(2),1]);
        Rout = Rin;
        Rout.XWorldLimits(2) = Rout.XWorldLimits(2)+X(1);
        Rout.YWorldLimits(2) = Rout.YWorldLimits(2)+X(2);
        [input,~] = imwarp(Input,tform,'OutputView',Rout);
        mask = zeros(size(input));
        try
            for j=1:size(TRC,1)
                mask = mask + poly2mask(...
                    [TRC(j,1)+0.5, TLC(j,1)-0.5, BLC(j,1)-0.5, BRC(j,1)+0.5],...
                    [TRC(j,2)-0.5, TLC(j,2)-0.5, BLC(j,2)+0.5, BRC(j,2)+0.5],...
                    size(input,1), size(input,2));
            end
            mask = mask.*input;
            mask = sum(mask(:));
        catch
            mask = 0;
        end
        Intensity = -mask;
    end

[X,fval,exitflag,output] = fminsearch(@move_me,[0,0,0],optimset('TolX',1e-1,'TolFun',1e-2)); %#ok<NASGU,ASGLU>

tform = affine2d([cos(X(3)),-sin(X(3)),0; sin(X(3)),cos(X(3)),0; X(1),X(2),1]);
Rout = Rin;
Rout.XWorldLimits(2) = Rout.XWorldLimits(2)+X(1);
Rout.YWorldLimits(2) = Rout.YWorldLimits(2)+X(2);
[input,~] = imwarp(Input,tform,'OutputView',Rout);

theta = X(3);
x = X(1);
y = X(2);

end
   

   
