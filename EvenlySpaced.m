function [Pairs,TRC,TLC,BRC,BLC,numRows,numCols]=...
    EvenlySpaced(Input,Grid_Size,Radius, Pos)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%---------------------------- Spacing -------------------------------------
Spacing_n = Grid_Size(2);
Spacing_m = Grid_Size(1);

%----------------------------- image --------------------------------------
nIm = size(Input,1);
mIm = size(Input,2);

%----------------------- # of cols & rows ---------------------------------
numRows = floor(nIm/Spacing_n);
numCols = floor(mIm/Spacing_m);

%---------------------------- pairs ---------------------------------------
X = 1:Spacing_n:numRows*Spacing_n;
Y = 1:Spacing_m:numCols*Spacing_m;

[p,q] = meshgrid(X,Y);
Pairs = [q(:), p(:)];

%--------------------------- corners --------------------------------------
TRC = cat(2,Pairs(:,1)+...
    ones(size(Pairs,1),1).*Radius,Pairs(:,2)-...
    ones(size(Pairs,1),1).*Radius);
TLC = cat(2,Pairs(:,1)-...
    ones(size(Pairs,1),1).*Radius,Pairs(:,2)-...
    ones(size(Pairs,1),1).*Radius);
BRC = cat(2,Pairs(:,1)+...
    ones(size(Pairs,1),1).*Radius,Pairs(:,2)+...
    ones(size(Pairs,1),1).*Radius);
BLC = cat(2,Pairs(:,1)-...
    ones(size(Pairs,1),1).*Radius,Pairs(:,2)+...
    ones(size(Pairs,1),1).*Radius);

%--------------------- translation optimization ---------------------------

    function gamma = translate_me(X)

        delta_x = X(1);
        delta_y = X(2);
        
        trc = TRC + repmat([delta_x,delta_y],[size(TRC,1),1]);
        tlc = TLC + repmat([delta_x,delta_y],[size(TLC,1),1]);
        brc = BRC + repmat([delta_x,delta_y],[size(BRC,1),1]);
        blc = BLC + repmat([delta_x,delta_y],[size(BLC,1),1]);
        
         mask = zeros(size(Input));
        try
            for j=1:size(trc,1)
                mask = mask + poly2mask(...
                    [trc(j,1)+0.5, tlc(j,1)-0.5, blc(j,1)-0.5, brc(j,1)+0.5],...
                    [trc(j,2)-0.5, tlc(j,2)-0.5, blc(j,2)+0.5, brc(j,2)+0.5],...
                    size(Input,1), size(Input,2));
            end
            mask = mask.*Input;
            mask = sum(mask(:));
        catch
            mask = 0;
        end
            gamma = -mask;
    end

Starting_point = min(Pos,[],1);

X = fminsearch(@translate_me,Starting_point,optimset('TolX',1e-8,'TolFun',1e-08));


        TRC = TRC + repmat([X(1),X(2)],[size(TRC,1),1]);
        TLC = TLC + repmat([X(1),X(2)],[size(TLC,1),1]);
        BRC = BRC + repmat([X(1),X(2)],[size(BRC,1),1]);
        BLC = BLC + repmat([X(1),X(2)],[size(BLC,1),1]);
        
        Pairs = Pairs + repmat([X(1),X(2)],[size(Pairs,1),1]);

end

