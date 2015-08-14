function [Intensity] = LevelingMySignals(Intensity)
%LEVELINGMYSIGNALS : Level an intensity trace by defining state levels and
%setting the lower trace as the '0'. 
%   Uses STATELEVELS. Takes in a matrix of traces or a cell array of
%   traces. Should be accumulated along 3rd dimension. Returns the same
%   type.
%=========================== INPUT CLASS ==================================
%-------------------------- cell or matrix --------------------------------
if iscell(Intensity)
Intensity = cellfun(@GetMeNewIntensity,Intensity,'UniformOutput',false); 
Intensity = cellfun(@GetMeNewIntensity,Intensity,'UniformOutput',false);
else
    if size(Intensity,3)>1
Intensity = mat2cell(Intensity,ones(1,size(Intensity,1)),...
ones(1,size(Intensity,2)),size(Intensity,3));
Intensity = cellfun(@GetMeNewIntensity,Intensity,'UniformOutput',false);
Intensity = cellfun(@GetMeNewIntensity,Intensity,'UniformOutput',false);
Intensity = cell2mat(Intensity);
    end
end
%--------------------------------------------------------------------------
%==========================================================================

%======================== LEVELING SIGNALS ================================
%--------------------------- leveling -------------------------------------
    function [intensity] = GetMeNewIntensity(intensity)
        if size(intensity,3)>1
        intensity = permute(intensity,[3,2,1]);
%         figure; subplot(1,2,1); plot(intensity); title('Not Leveled'); hold on;
        levels = statelevels(intensity,100,'mean');
%         plot(levels(1)*ones(size(intensity))); plot(levels(2)*ones(size(intensity)));
        intensity = intensity-levels(1);
%         subplot(1,2,2); plot(intensity); title('Leveled');
        intensity = permute(intensity,[3,2,1]);
        end
    end
%--------------------------------------------------------------------------
%==========================================================================
end

