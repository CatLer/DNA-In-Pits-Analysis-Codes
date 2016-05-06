function [Pairs, TRC, TLC, BRC, BLC, Centers, Radii, num_rows, num_cols,Input,Radius ] = FirstGrid( Input, HS, Polarity )
%FIRSTGRID: Creates the appropriate pits grid to the sample frames by k-clustering.
%Although most of the time, k-clustering is not necessary, false pits may
%have been localized because of image noise. This function will absorb the
%false pits.
%   It minimizes the offset between the grid points and the pre-localized
%   centers. Returns the angle in degrees, the grid points (Pairs), the
%   corners of each pit (trc, tlc, brc, blc), the pre-localized pits
%   (centers) with their radii given by imfindcircles (circular Hough
%   transform), and the number of rows and columns of the grid. Input is an
%   array of frames (nIm, mIm, N), HS specifies which side ('green', or
%   'red'), Polarity specifies if looking for bright (+) or dark(-) spots.
%   Uses fminbnd. Should work for any delta (distance cutoff between the
%   clusters) between the boundaries. Delta is generally close to 15. The
%   boundaries are 10-25, can be moved apart but not recommanded (longer).
        
        [Centers,Radii, Input]= EasyDetection(Input, HS, Polarity);
        
        %--------
        function [Pairs, TRC, TLC, BRC, BLC, num_rows, num_cols,Radius]=Create_me(delta)
        [X,ix] = sortrows(Centers(:,1));
        [Y,iy] = sortrows(Centers(:,2));
        T = pdist(X,'cityblock');
        R = linkage(T,'average');
        Sx = cluster(R,'cutoff',delta, 'criterion', 'distance');
        [C,~,ic]= unique(Sx);
        Vertical_lines = [];
        Radii_v = [];
        for i=1:numel(C)
            Vertical_lines = cat(1,Vertical_lines,mean(X(ic==C(i),:),1));
            Radii_v = cat(1, Radii_v, mean(Radii(ix(ic))));
        end
        T = pdist(Y,'cityblock');
        R = linkage(T,'average');
        S = cluster(R,'cutoff',delta, 'criterion', 'distance');
        [C,~,ic]= unique(S);
        Horizontal_lines = [];
        Radii_h = [];
        for i=1:numel(C)
            Horizontal_lines = cat(1,Horizontal_lines,mean(Y(ic==C(i),:),1));
            Radii_h = cat(1, Radii_h, mean(Radii(iy(ic))));
        end
        Horizontal_lines =sort(Horizontal_lines);
        Vertical_lines = sort(Vertical_lines);
        [p,q] = meshgrid(Horizontal_lines, Vertical_lines);
        Pairs = [q(:) p(:)];
        
        Radius = mean([Radii_v(:);Radii_h(:)]);
        % needs some improvments
        Radius = min([Radius,15]);
        Radius = max([Radius,3]);
        
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
        
      num_cols = numel(Vertical_lines);
      num_rows = numel(Horizontal_lines);   
        end
      %----------
      
        function s = findRightDelta(delta)
        [Pairs,~,~,~,~,~,~,~]=Create_me(delta);    
        D = pdist2(Pairs,Centers, 'cityblock', 'Smallest', size(Pairs,1)*size(Pairs,2));   
        s = mean(D(1,:),2);
        end
            
      myDelta= fminbnd(@findRightDelta,10,25, optimset('TolX',0.1));  
      
      [Pairs, TRC, TLC, BRC, BLC, num_rows, num_cols,Radius]=Create_me(myDelta)

end


% old_size = size(Input,1);
% [Angle,Input]= findPitsTilt(Input);
% Input = imrotate(Input,Angle,'crop');
% new_size = size(Input,1);
% Input = imresize(Input, old_size/new_size);