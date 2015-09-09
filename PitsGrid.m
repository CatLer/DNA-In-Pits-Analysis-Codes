classdef PitsGrid <handle
    %PITSGRID : Draggable and resizable pits grid. 
    %   Uses IMLINE and IMELLIPSE and first pits' positions and size
    %   approximation. Asks the user to drag the grid and resize the pits.
    % use tag to group, pos = api.getPosition()
    
    properties
    % intersections represent pits' centers     
    Intersections=[];
    % radius of a pit (eventually, shape and dimensions instead)
    Radius=[];
    % action
    option=[];
    end
    
    methods
        function obj=PitsGrid(I,PitsCenters,PitRadius,option)
            figure; imshow(I,[]);
%--------------------------------------------------------------------------
            if option==0
                % asks the user how many rows and columns and generates
                % lines
                prompt={'Enter number of rows:','Enter number of columns:'};
                dlg_title='Grid size';
                num_lines=1;
                answer=inputdlg(prompt,dlg_title,num_lines);
                num_rows=str2double(answer{1});
                num_cols=str2double(answer{2});     
                x=1:((size(I,2)-2)/num_cols):size(I,2)-1;
                y=1:((size(I,1)-2)/num_rows):size(I,1)-1;
                for i=1:numel(x)
                    imline(gca,[x(i),x(i)],[0,size(I,1)]);
                end
                for i=1:numel(y)
                    imline(gca,[0,size(I,2)],[y(i),y(i)]);
                end
                [p,q]=meshgrid(x,y);
                Pos=[p(:),q(:)];
                for i=1:size(Pos,1)
                    impoint(gca,Pos(i,1),Pos(i,2));
                end
            end
%--------------------------------------------------------------------------            
            if option==1
                if ~isempty(PitsCenters) && PitRadius>0
                for i=1:size(PitsCenters,1)
                   g=impoint(gca,PitsCenters(i,1),PitsCenters(i,2));
                   h=imellipse(gca,[min(max(PitsCenters(i,1)-PitRadius/2,0),size(I,2)),...
                        min(max(PitsCenters(i,2)-PitRadius/2,0),size(I,1)),...
                        PitRadius,PitRadius]);
                    % constrain the objects to stay inside the frame
                    addNewPositionCallback(g,@(p) title(mat2str(p,3)));
                    addNewPositionCallback(h,@(p) title(mat2str(p,3)));
                    fcn_g = makeConstrainToRectFcn('impoint',get(gca,'XLim'),get(gca,'YLim'));
                    fcn_h = makeConstrainToRectFcn('imellipse',get(gca,'XLim'),get(gca,'YLim'));
                    setPositionConstraintFcn(g,fcn_g);
                    setPositionConstraintFcn(h,fcn_h);
                    % make them move together
                    H=addNewPositionCallback(h,@(h) setConstrainedPosition(g,h(1:2)+[PitRadius,PitRadius]));
                    G=addNewPositionCallback(g,@(g) setConstrainedPosition(h,cat(2,g-[PitRadius,PitRadius],2*PitRadius,2*PitRadius)));
                end
                end
            end
%--------------------------------------------------------------------------                        
            if option==2
                m=msgbox(...
                    'No pits had been detected. Please, manually select pits you want to analyze by clicking. You''ll be able to resize them after the end of this operation. Press ENTER once you''re done.',...
                    'Manual pits selection');
                uiwait(m);
                [x,y]=ginputMark(Inf);
                for i=1:numel(x)
                    impoint(gca,x(i),y(i));
                end 
                PitsCenters=cat(2,x,y);
            end
%--------------------------------------------------------------------------            
            % set intersections and dimensions
            obj.Intersections=PitsCenters;
            obj.Radius=PitRadius;
%--------------------------------------------------------------------------            
        end
    end
    
end

