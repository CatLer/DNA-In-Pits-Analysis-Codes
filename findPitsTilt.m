function [angle,I] = findPitsTilt(I)
%FINDPITSTILT: uses Radon transform to find the angle by which the image
%is rotated. Spots the 'black edge'. Once aligned with it, this is assumed
%to be the angle offset. This is not the angle of transposition between
%the channels. This works for angles with about 0.01 precision. To remove large
%offsets only. Small offsets are removed with Maximize_Intensity_In_Pits.
%   Collapses the array of frames, takes a Radon transform with an angular
%   range of -15:0.01:15 degrees, with a precision of 0.01. Can be changed.
%   Takes the complement of the radon to have the minima as maxima. Detect
%   the black edge at half the image and find the angle by determining
%   where it is angularly (by finding the maximum intensity). Takes the
%   negative of that angle to rotate the image back. Limits: relies on the
%   presence of a black edge. It is assumed that when the frame is rotated,
%   so is the black edge separating both channels. Note: this doesn't align
%   one channel but both. Finer adjustements regarding translations and
%   angles are done in Maximize_Intensity_In_Pits.

% collapsing frames
I= mat2gray(I);
I= mat2gray(sum(I,3));

    try

        % compute Radon transform for a given angle range and take complement
        theta= -15:0.01:15;
        M= imcomplement(radon(I,theta));

        % define zone corresponding to the black edge
        %M= M(floor(end/2),:);
        M= M(floor((end/2)-10):ceil((end/2)+10),:);

        % find the max corresponding to the black edge
        M= max(M,[],1);
        [~,k]= max(M);

        % get the angle
        angle= -theta(k);

        % rotate the image by the angle
        I = imrotate(I,angle,'crop');

    catch

        angle= 0 ;

    end

end

