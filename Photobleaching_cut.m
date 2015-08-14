function [Intensity_G, Intensity_R] = ...
    Photobleaching_cut( Intensity_G, Intensity_R )
%PHOTOBLEACHING_CUT : Filers excessivily the traces, defines statelevels,
%search for risetimes and falltimes to find the last possible
%photobleaching start time. Returns a cell array with cut signals. The
%ultimate goal of this function is to remove portions of the signals
%involving photobleaching. ***** Multiple photobleaching events possible **
%   Suggestions :
%       1. Use Multiple_Photobleaching (not yet created) to find multiple
%       photobleaching events (not all of them precisely). It would use
%       this function in a loop, cutting at the signal at the last event
%       start time at each run. It would cut until the plateau follows a
%       rise.
%   Difficulties :
%       1. Takes about 1 sec per pit for 8000 frames. For 200 pits, this
%       takes 1m40s, and for 84 pits, this takes about 1m24s, for the
%       FOLLOW_ME function only. For 2 traces, this gives 3m20s and 2m48s
%       respectively. Overall, the expected time of operation is between
%       4-5 min. 2. Statelevels definition may be an issue; if many
%       photobleaching events, the upper level may be close to the median.

%==========================================================================
%======================= PHOTOBLEACH SEARCH ===============================

% check both matrices have same number of pits
if size(Intensity_G)~=size(Intensity_R)
    error('Input arrays don''t have the same size');
end

%------------------------ Search each pit ---------------------------------
% convert to cell array for different signal length
Intensity_G = mat2cell(Intensity_G,ones(1,size(Intensity_G,1)),...
ones(1,size(Intensity_G,2)),size(Intensity_G,3));
Intensity_R = mat2cell(Intensity_R,ones(1,size(Intensity_R,1)),...
    ones(1,size(Intensity_R,2)),size(Intensity_R,3));
% find photobleaching start points
P_1 = cell2mat(cellfun(@follow_me,Intensity_G,'UniformOutput',false));
P_2 = cell2mat(cellfun(@follow_me,Intensity_R,'UniformOutput',false));
% define matrix with photobleaching occurrences P, P_1,P_2 are start times

%**************************************************************************
% conditions for photobleaching : 
%       green photobleaches, red may decrease  =>  g<0, r<=0  
%       red photobleaches, green increases  =>  g>0, r<0
%       both photobleach, both decrease     =>  g<0, r<0
%**************************************************************************

p1 = sign(P_1); p2 = sign(P_2); P_1 = abs(P_1); P_2 = abs(P_2);
P = -ones(size(p1)); P(p1>0 & p2<0)=1; P(p1<0 & p2<=0)=1; 
%--------------------------------------------------------------------------

%======================= CUTTING SIGNALS ==================================

%----------- Cut signal for each pit with photobleaching ------------------
for a=1:size(Intensity_G,1)
    for b=1:size(Intensity_G,2)
        if P(a,b)>0
            % photobleaching in the pit(a,b)
            try
            % define where to cut
            if P_1(a,b)==0
                P_1(a,b)=numel(Intensity_G{a,b});
            end
            if P_2(a,b)==0
                P_2(a,b)=numel(Intensity_R{a,b});
            end
            time = round(min(P_1(a,b),P_2(a,b)));
            % cut
            Intensity_G{a,b} = Intensity_G{a,b}(:,:,1:time);
            Intensity_R{a,b} = Intensity_R{a,b}(:,:,1:time);
            catch
            end
        end
    end
end
%--------------------------------------------------------------------------

%======================= PHOTOBLEACH CRITERIA =============================

    function [Photobleaching]=follow_me(Intensity)

        %---------------------- Clean input signal ------------------------
        % or use SLEWWRATE
        intensity = permute(Intensity,[2,3,1]);
        % divides the signal in 10 pieces and filter
        w = round(0.1*numel(intensity));
        intensity = medfilt1(padarray(intensity,[0,w],'replicate','both'),w);
        intensity = intensity(w+1:end-w);
        % defines statelevels
        levels = statelevels(intensity,100,'mean'); 
        
        %******************************************************************
%         figure; statelevels(intensity,100,'mean');
        %******************************************************************
        
        %------------------------------------------------------------------
        
        %-------------------- Rises and falls search ----------------------
        
        %--------------------------- fall ---------------------------------
        [F,LT,~]=falltime(intensity,'statelevels',levels,'PctRefLevels',[3,97]);
        
        %******************************************************************
%         figure; falltime(intensity,'statelevels',levels,'PctRefLevels',[3,97]);
        %******************************************************************
        
        falltimes = [LT-F,LT];
        % minimum photobleaching time
        % falltimes = falltimes(numel(intensity)-LT>100);
        if ~isempty(falltimes)
            for i=1:size(falltimes,1)
                delta_1 = round(falltimes(i,1));
                delta_2 = round(falltimes(i,2));
                new_levels_1 = statelevels(intensity(1: delta_1),100,'mean');
                new_levels_2 = statelevels(intensity(delta_2:end),100,'mean');
                %-------------- Conditions if I am photobleaching ---------
                % condition 1
                Condition_1 = abs((new_levels_2(2)-new_levels_1(1))/diff(new_levels_1))>1;
                % condition 2 
                Condition_2 = abs(diff(new_levels_1)-diff(new_levels_2))/diff(new_levels_1)<1;
                % condition 3
                Condition_3 = new_levels_2(2)<new_levels_1(1);
                % condition 4
                Condition_4 = sqrt((diff(new_levels_1)/diff(levels))*diff(new_levels_2)/diff(levels))<0.5;
                I_am_photobleaching = Condition_1*Condition_2*Condition_3*Condition_4;
                %----------------------------------------------------------

                %**********************************************************
%                 figure; statelevels(intensity(1:delta_1),100,'mean');
                %**********************************************************

                 if ~(I_am_photobleaching) %#ok<BDLGI>
                    falltimes(i,:)=NaN;
                end
            end
            falltimes=falltimes(~isnan(falltimes(:,1)),:);
            if ~isempty(falltimes)
            falltimes = falltimes(end,1);
            else
                falltimes=0;
            end
        else
            falltimes=0;
        end
        %------------------------------------------------------------------
        
        %---------------------------- rise --------------------------------
        [R,~,UT]=risetime(intensity,'statelevels',levels,'PctRefLevels',[3,97]);
        
        %******************************************************************
%         figure; risetime(intensity,'statelevels',levels,'PctRefLevels',[3,97]);
        %******************************************************************
        
        risetimes = [UT-R,UT];
        % minimum photobleaching time
        % risetimes = risetimes(numel(intensity)-UT>100);
        if ~isempty(risetimes)
            for i=1:size(risetimes,1)
                delta_1 = round(risetimes(i,1));
                delta_2 = round(risetimes(i,2));
                 new_levels_1 = statelevels(intensity(1: delta_1),100,'mean');                
                 new_levels_2 = statelevels(intensity(delta_2:end),100,'mean'); 
                %---------- Conditions if my friend is photobleaching -----
                % condition 1
                Condition_1 = abs((new_levels_2(2)-new_levels_1(1))/diff(new_levels_1))>1;
                % condition 2 
                Condition_2 = abs(diff(new_levels_1)-diff(new_levels_2))/diff(new_levels_1)<1;
                % condition 3
                Condition_3 = new_levels_2(2)>new_levels_1(1);
                % condition 4
                Condition_4 = sqrt((diff(new_levels_1)/diff(levels))*diff(new_levels_2)/diff(levels))<0.5;
                My_friend_is_photobleaching = Condition_1*Condition_2*Condition_3*Condition_4;
                %----------------------------------------------------------
                
                %**********************************************************
%                 figure; statelevels(intensity(1:delta_1),100,'mean');
                %**********************************************************
                
                if ~(My_friend_is_photobleaching) %#ok<BDLGI>
                    risetimes(i,:) = NaN;
                end
            end
            risetimes=risetimes(~isnan(risetimes(:,1)),:);
          if ~isempty(risetimes)  
            risetimes = risetimes(end,1);
          else
              risetimes=0;
          end
        else
            risetimes=0;
        end
        %------------------------------------------------------------------
        
        %-------------------- Behaviour at the end ------------------------
        [photo_t,j]=max([falltimes,risetimes]); 
        %   negative is related to fall, positive is related to rise
        Photobleaching = photo_t*(-1)^j;
        %------------------------------------------------------------------
        
    end
%==========================================================================
end