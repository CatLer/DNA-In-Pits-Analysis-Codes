function [ Dimensions, Success ] = Good_Fit_Grid(Pairs,num_rows,num_cols,Radius,Input,TRC,TLC,BRC,BLC)
%GOOD_FIT_GRID: Measures the success of the grid creation operation.
%Determines if the standard deviation of the distances between the pits
%falls whithin the region of a pit (radius). The distance between 2 pits is
%'distance +/- sqrt(radius)'. Measures the distance between 2 neighbours, not
%along a diagonal. Accounts for edges.
%   Uses PDIST function to find the distances between all the pits (not
%   only neighbours). Using the number of rows and columns, gets the
%   entries which correspond to distances between neighbours, on 2
%   consecutive rows (vertical distance) and 2 consecutive columns
%   (horizontal distance). Accumulates the values in arrays. Finds the
%   standard deviations and divides them by the error (Radius).
%   Success = 0,1, 0: bad-looking grid, 1: good-looking grid. Returns the
%   average horizontal and vertical distances in Dimensions.


%----------------------- Morphology test ----------------------------------
% error ~Radius
Error= Radius;

Spacings = pdist(Pairs, 'cityblock');

% Horizontal distance
M = [];
for j=0:num_rows*(num_cols-1)
    if mod(j+1,num_cols)~=0
        M = cat(2, M, Spacings(1,1+j*(num_cols*num_rows-(j+1)/2)));
    end
end

H = mean(M);

S_h = (std(M)/Error)<1;

% Vertical distance
M = [];
for j=0:num_rows*(num_cols-1)
    if mod(j+1,num_rows)~=0
        M = cat(2, M, Spacings(1,num_cols+j*(num_cols*num_rows-(j+1)/2)));
    end
end

V = mean(M);

S_v = (std(M)/Error)<1;


Success = S_h*S_v;
Dimensions = [H,V];

%-------------------- Intensity Test --------------------------------------

try
    mask = zeros(size(Input));
    for j=1:size(TRC,1)
        mask = mask + poly2mask(...
            [TRC(j,1)+0.5, TLC(j,1)-0.5, BLC(j,1)-0.5, BRC(j,1)+0.5],...
            [TRC(j,2)-0.5, TLC(j,2)-0.5, BLC(j,2)+0.5, BRC(j,2)+0.5],...
            size(Input,1), size(Input,2));
    end
    
    mask_prime = imcomplement(mask);
    
    mask(mask==0)= NaN;
    mask = mask.*Input;
    mask = mask(:);
    mask = mask(~isnan(mask));
    mask = mean(mask);
    
    mask_prime(mask_prime==0)= NaN;
    mask_prime = mask_prime.*Input;
    mask_prime = mask_prime(:);
    mask_prime = mask_prime(~isnan(mask_prime));
    mask_prime = mean(mask_prime);
    
    Seg = multithresh(Input,2);
    Err = abs(diff(Seg))/2;
    Err1 = abs(Seg(1)-mask_prime);
    Err2 = abs(Seg(2)-mask);
    Del = Err1*Err2/(Err^2);    
    
    Intensity_in_pits = Del<0.5;
    
catch
    Intensity_in_pits = 1;
end

Success = Success*Intensity_in_pits;

end
