function [TopRightCorner,TopLeftCorner,BottomRightCorner,BottomLeftCorner,R]...
    = Good_Fit_Pit(Input,TRC,TLC,BRC,BLC,Radius)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% maximize # of pixels in pit too
        
        dilate_me = @(Thingy, delta, H_side, V_side) Thingy+delta*repmat([H_side, V_side],[size(Thingy,1),1,1]);
        
        function Corners=dilate_us(trc,tlc,brc,blc,delta)
            trc = dilate_me(trc,delta,1,-1);
            tlc = dilate_me(tlc,delta,-1,-1);
            brc = dilate_me(brc,delta,1,1);
            blc = dilate_me(blc,delta,-1,1);
            Corners = cat(3, trc,tlc,brc,blc);
        end
        
        function mask = my_mask(input, Corners)
            trc = Corners(:,:,1);
            tlc = Corners(:,:,2);
            brc = Corners(:,:,3);
            blc = Corners(:,:,4);
            mask = zeros(size(input));
            for j=1:size(trc,1)
                mask = mask + poly2mask(...
                    [trc(j,1), tlc(j,1), blc(j,1), brc(j,1)],...
                    [trc(j,2), tlc(j,2), blc(j,2), brc(j,2)],...
                    size(input,1), size(input,2));
            end
            mask_prime = imcomplement(mask);
            mask(mask==0)= NaN;
            mask_prime(mask_prime==0)= NaN;
            mask = mask.*input;
            mask_prime = mask_prime.*input;
            mask = mask(:);
            mask_prime = mask_prime(:);
            mask = mask(~isnan(mask));
            mask_prime = mask_prime(~isnan(mask_prime));
            mask = std(mask);
            mask_prime = std(mask_prime);
            mask = mask*mask_prime;        
        end
   
    function intensity = intensity_in_pits(Delta)
        Corners = dilate_us(TRC,TLC,BRC,BLC, Delta);
        intensity = my_mask(Input,Corners);
    end

%R = fminsearch(@intensity_in_pits,5-Radius,optimset('display','iter'));
R = fminbnd(@intensity_in_pits,3-Radius,6-Radius); 


Corners = dilate_us(TRC,TLC,BRC,BLC,R);
TopRightCorner = Corners(:,:,1);
TopLeftCorner = Corners(:,:,2);
BottomRightCorner = Corners(:,:,3);
BottomLeftCorner = Corners(:,:,4);

end



%             molecular_brightness = @(mask) std(mask).^2/trimmean(mask,20)-1;
%             molecular_brightness(mask);
