function [Index] = Fluophore_Activity_Index(Intensity)
%FLUOPHORE_ACTIVITY_INDEX : Returns an index between 0 and 1, with 0 being
%close to noise only. The normalization depends on the sample itself.
%   The index is proportional to the bandpower and spurious free dynamic
%   range both normalized, of the fluctuations in the detrended enveloppe
%   of the signal.
%   Theory:
%       1. Bandpower: average power in the input signal. A greater value
%       indicates greater amplitude in the fluctuations.
%       2. Spurious free dynamic range : strength ratio of the fundamental
%       signal and the most proeminent harmonic. Generally used for
%       sinuosidal signals. However, in this case, a larger value probably
%       means a cleaner signal.

%================== CHECK INPUT CLASS & CONVERT ===========================
%----------------------- CHECK INPUT CLASS --------------------------------   
I = mat2cell(Intensity,ones(1,size(Intensity,1)),...
ones(1,size(Intensity,2)),size(Intensity,3));
%--------------------------------------------------------------------------
%==========================================================================

%========================= RETURN INDEX ===================================
%-------------------- BANDPOWER & SFDR PER PIT ----------------------------
I=cellfun(@SignalQuality,I,'UniformOutput',false);
I=cell2mat(I);
BANDPOWER=I(:,:,1);
SFDR=I(:,:,2);
%--------------------------------------------------------------------------
%---------------------------- NORMALIZE ----------------------------------- 
BANDPOWER=BANDPOWER/mean(BANDPOWER(:));
SFDR=SFDR/mean(SFDR(:));
%--------------------------------------------------------------------------
%----------------------------- INDEX --------------------------------------
Index=BANDPOWER.*SFDR;
std(Index(:))/sqrt(numel(Index));
%--------------------------------------------------------------------------
%==========================================================================

    function [Output]=SignalQuality(intensity)
        %========================= SIGNAL QUALITY =========================
        %-------------- BANDPOWER & SFDR OF FLUCTUATIONS ------------------
        intensity = permute(intensity,[3,2,1]);
        % Signal Enveloppe
        intensity = abs(hilbert(intensity));
        % Remove offset
        intensity = intensity-mean(intensity);
        % Bandpower (greater, better)
        BANDPOWER = bandpower(intensity);
        % Spurious free dynamic range
        SFDR = sfdr(intensity);
        Output = cat(3,BANDPOWER,SFDR);
        %------------------------------------------------------------------
        %==================================================================
    end
end