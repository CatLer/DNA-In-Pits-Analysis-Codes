function [] = ComplexFractionsBarPlot2(varargin)
%COMPLEXFRACTIONSBARPLOT : Can create a database and produce plots (bar and
%scatter plots only, Chris needs to add histograms and/or modify what I
%have done).
%   ### Chris needs to improve this by merging his functions. This function
%   was initially made to create a database. For now, it produces draft
%   plots (to check it works). There are also a lot of missing
%   functionalities such as choosing the bin size (or size of clusters). An
%   attempt at fits was made aswell as an attempt at a draft 3D BAR plot to
%   make sure the function can receive Chris's updates, but to be modified
%   and a HEAT MAP is still needed! Feel free to modify the plots part and
%   temperatures & linking numbers arrays. It is possible to create a data
%   base directly in MATLAB but I prefered an excel file. If you prefer the
%   database, we can change it. For now, it works fine. Prevents memory
%   overload. Once you're done, write a more appropriate description of
%   this function ! :) Thx ### THING TO FIX : unique LK values for 2nd case
%   see line 347. Not a big deal for now. It 
%% ======================== SET DATABASE          
format long
m=warndlg('A database is needed for LK plots.');
%   I can explain monday. of bound complexes against LK.');
uiwait(m); q='No'; % warn the user that a database is needed to plot against LK

if nargin==0 % ask user if a database is needed
q=questdlg('Use a database?','Database','Yes','No','Yes');
end

if nargin==1 || strcmp(q,'Yes')
    %......................................................................
    question=questdlg(...
        'Pick a database. Use...','Database','a new file','an existing file',...
        'an existing file'); % ask user for a database
    %......................................................................
    switch question % 3 possible scenarios depending on the answer
        %..................................................................
        case 'an existing file' % if database selected
            [file,path] = uigetfile({'*.xlsx;*.xls'},'Histogram File');
            if ~ischar(file) && ~ischar(path)
                Filename=''; % no database selected
            else
                Filename=fullfile(path,file); % database address
            end
        %..................................................................    
        case 'a new file' % if new database needed
            [file,path] = uiputfile({'*.xlsx;*.xls'},'Histogram File');
            if ~ischar(file) && ~ischar(path)
                Filename=''; % no database created
            else
                Filename=fullfile(path,file); % database address
                xlswrite(Filename,1,'A1:A1','Test');
            end
        %..................................................................    
        case '' % no option selected
            Filename=''; % ignore database
        %..................................................................    
    end
    %......................................................................
else
    Filename=''; % ignore database
end
%  ========================================================================
%% ========================= PLOT TYPES ===================================
if ~isempty(Filename) % ask what type
opt=questdlg('Plot # of bound complexes against ...','Options','Temperature',...
    'Linking Number', 'Temperature and Linking Number','Temperature and Linking Number');
else
    opt='Temperature';
end
%..........................................................................
switch opt % 3 different scenarios
    %......................................................................   
    case 'Temperature'   % plot # of bound complexes VS T
        %..................................................................
        % ask the user for the linking number
        LK=[];
        while isempty(LK) % until user specifies a linking number
            LK=inputdlg('Linking Number');
        end
        %..................................................................
        if ~isempty(Filename) % if specified excel file
            %..............................................................
            Sheet=strcat('LK',LK); Sheet=char(Sheet); % can make an excel sheet           
            [~,sheets,~] = xlsfinfo(Filename); % finds excel sheets
            id_sheets=cellfun(@(x)goodsheet(regexp(x,strcat('LK-?',LK),'once')),....
                sheets,'UniformOutput',false); 
            % find sheets corresponding the specified liinking number
            if iscell(id_sheets)
                id_sheets=cell2mat(id_sheets);
            end
            sheets=sheets(id_sheets); % take only corresponding sheets
            if ~isempty(sheets) % if there are sheets at that LK...
                % ask user to select wanted sheet
                selection=listdlg('PromptString',...
                    'Select a sheet or cancel to make a new one',...
                    'ListString',sheets','SelectionMode','single'); % do a search first?
                if ~isempty(selection) % if user selected a sheet
                    Sheet=sheets{selection}; % wanted sheet 
                end
                % otherwise, a new sheet will be made 
            end
            s=strcmp(Sheet,sheets); % if wanted sheet already exists
            if iscell(s)
                s=cell2mat(s);
            end
            if sum(s)==1 % then reads the infos
                [~,LIST,~]=xlsread(Filename,Sheet,'A:A'); % samples names
                [~,DATES,~]=xlsread(Filename,Sheet,'B:B'); % exp dates
                TEMPERATURES=xlsread(Filename,Sheet,'C:C'); % temperatures
                COMPLEXFRAC=xlsread(Filename,Sheet,'D:D'); % number of binding events
                % check all arrays have the same length
                L=numel(LIST); D=numel(DATES); T=numel(TEMPERATURES); C=numel(COMPLEXFRAC);
                u=unique([L,D,T,C]);
                if numel(u)>1 % if not, returns error
                    error('Make sure the excel file is complete! Remove incomplete rows.');
                end               
            else % if new excel sheet needed, no current samples
                LIST=[];
                DATES=[];
                TEMPERATURES=[];
                COMPLEXFRAC=[];
            end
            %..............................................................
        else % no database wanted
            %..............................................................
            LIST=[];
            DATES=[];
            TEMPERATURES=[];
            COMPLEXFRAC=[];
            %..............................................................
        end
        %..................................................................
        % look for samples in the workspace
        Names=evalin('base','whos(''Set_*'')');
        Classes={Names.class}; I=strcmp(Classes,'PitsSample');
        Names=Names(I); Names={Names.name};
        if isempty(Names) && isempty(LIST) % no sample found in workspace and database, return
            warning('No sample found.')
            return;
        end
        % ask user to select wanted samples
        if ~isempty(Names)
        j=listdlg('ListString',Names,'SelectionMode','multiple','ListSize',[400,600],...
            'Name','Sample Selection', 'PromptString', 'Please, select a sample.');
        if isempty(j) && isempty(LIST)
            return; % no sample selected in workspace and found in database
        end
        list=Names(j); % take only selected samples
        else
            list={};
        end
        dates=cellfun(@GetDate,list,'UniformOutput',false); % get exp dates, see GetDate
        %..................................................................
        if ~isempty(LIST) % only if samples present in the database!
            %..............................................................
            % look for elements that are already in the database
            [Old_Elements,id_list_in,id_LIST]=intersect(list,LIST);
            if ~isempty(Old_Elements)
                % ask user if he wants to replace or not (eventually)
            end
            % look for elements not in the database
            [New_Elements,id_list]=setdiff(list,LIST);
            % get exp dates for samples in the database
            DATES=cellfun(@FilterDate,DATES,'UniformOutput',false);
            % exp dates of samples in both the database and workspace
            DATES_prime=DATES(id_LIST); dates_prime=dates(id_list_in);
            % convert date strings to computer time
            DATES_prime=cellfun(@datenum,DATES_prime(:),'UniformOutput',false);
            dates_prime=cellfun(@datenum,dates_prime(:),'UniformOutput',false);
            % take most recently analyzed samples
            ID=cellfun(@(x,y)UpToDate(x,y),DATES_prime,dates_prime,'UniformOutput',false);
            if iscell(ID)
                ID=cell2mat(ID);
            end
            % Samples re-analyzed
            Refresh_New_ID=id_list_in(ID);
            % Samples to be processed (not in the database or too old)
            New_Elements_id=unique(cat(1,Refresh_New_ID(:),id_list(:)));
            list=list(New_Elements_id); dates=dates(New_Elements_id);
            % Samples in the database that shouldn't be replaced
            Replace_Old_id=id_LIST(ID);
            Not_Replace_Old_id=setdiff(1:numel(LIST),Replace_Old_id);
            %..............................................................
        else
            %..............................................................
            Not_Replace_Old_id=[];
            %..............................................................
        end
        %..................................................................
        % set temperature and number of bound complexes arrays
        Temperatures=zeros(1,numel(list));
        BindingNum=zeros(1,numel(list));
        %..................................................................
        % for all new samples in the workspace 
        for i=1:numel(list)
            %..............................................................
            T_obj=evalin('base',sprintf('%s.OBJ_T_In_Green_Laser',list{i}));
            % objective temperature
            T_lens=evalin('base',sprintf('%s.LENS_T_In_Green_Laser',list{i}));
            % lens temperature
            T=(T_obj+T_lens)/2; Temperatures(i)=T; % temperature, take average
            % get binding matrices for all # of active fluophores
            Fieldnames=evalin('base',sprintf('fieldnames(%s.Green_Channel_In_Green_Laser.Binding)',list{i}));
            % get # of pits
            [m,n]=evalin('base',sprintf('size(%s.Green_Channel_In_Green_Laser.Positions)',list{i}));
            % set total binding matrix or ask user for wanted # (### Chris needs to add it)
            Binding=zeros(m,n);
            % add all matrices (### Chris will add the other options)
            for j=1:numel(Fieldnames) % for all pits no matter the # of molecules
                B=evalin('base',sprintf('%s.Green_Channel_In_Green_Laser.Binding.%s',list{i},Fieldnames{j}));
                Binding=Binding+B;
            end
            % set binding matrix to logical and count # of pits with
            % binding (NB : / total # of pits may be more appropriate!)
            Binding=logical(Binding); Binding=sum(Binding(:)); 
            BindingNum(i)=100*Binding/(m*n); % ### rescaled number of bound complexes
            %..............................................................
        end
        Temperatures_Prime=round(Temperatures); % round temperatures
        %..................................................................
        % add T and # of bound complexes in the database to the plots
        TEMPERATURES=TEMPERATURES(Not_Replace_Old_id); % samples not to replace in database
        COMPLEXFRAC=COMPLEXFRAC(Not_Replace_Old_id);
        Temperatures_Prime=cat(1,Temperatures_Prime(:),TEMPERATURES(:));
        BindingNum_Prime=cat(1,BindingNum(:),COMPLEXFRAC(:));
        %..................................................................
        % ### Chris should merge his functions here (the following is
        % temporary !!!) ###   
        %..................................................................    Start HERE    
        TPU=unique(Temperatures_Prime); % temperatures reported
        ComplexFrac=zeros(1,numel(TPU)); % average # of bound complexes
        ComplexFracStd=zeros(1,numel(TPU)); % standard deviation
        for i=1:numel(TPU)
            % average # of bound complexes for all samples with same T
            ComplexFrac(i)=mean(BindingNum_Prime(Temperatures_Prime==TPU(i))); % average
            ComplexFracStd(i)=sqrt(var(BindingNum_Prime(...
                Temperatures_Prime==TPU(i)))/numel(...
                BindingNum_Prime(Temperatures_Prime==TPU(i)))); % standard deviation (statistical errors)
        end
        %..................................................................
        if numel(TPU)>1 % if more than 1 temperature
            % power fit # of bound complexes VS temperature
            [f,g,o]=fit(TPU(:),ComplexFrac(:),'b*exp(a/x)') %#ok<NOPRT>   Boltzmann FIT VS temperature
            CoefficientValues=coeffvalues(f); % fit coefficients
            [Q,R] = qr(o.Jacobian,0); % using Jacobian
            Rinv = inv(R); 
            CoeffErrors=sqrt(sum(Rinv.*Rinv,2)*g.rmse/g.dfe); % get errors on coefficients
            ExpCoefficients=[CoefficientValues(:),CoeffErrors(:)];
            f=feval(f,TPU(1):0.01:TPU(end)); % evaluation with coeffs
        else
            f=[]; % otherwise, neglect the fit
        end
        %..................................................................
        % 2D bar plot
        figure; bar(TPU,ComplexFrac,'facecolor','c'); hold on; % plot bars
        if ~isempty(f)
            plot(TPU(1):0.01:TPU(end),f,'r:','linewidth',1.5);
            legend('Data',sprintf('b exp(a/T) \n a = %f, b=%f',CoefficientValues))
        end
        errorbar(TPU,ComplexFrac(:),ComplexFracStd(:),'ro','linewidth',1.5); % errorbars using STD
        xlabel('T (°C)' ,'fontsize',20);
        ylabel('<Number of bound complexes>, for 100 pits','fontsize',20);
        title(strcat('LK = ',LK),'fontsize',24);
        set(gca,'FontSize',18)
        %..................................................................
        % 2D scatter plot
%         figure; scatter(TPU,ComplexFrac); hold on;
%         if ~isempty(f)
%             plot(TPU(1):0.01:TPU(end),f,'r:','linewidth',1.5);
%         end
%         xlabel('T (°C)','fontsize',14); 
%         ylabel('<Number of bound complexes> for 100 pits','fontsize',14);
%         title(strcat('LK =',LK),'fontsize',14);
        if ~isempty(f)
            good=ComplexFrac>0; my_x=TPU(good); my_y=ComplexFrac(good);
            my_x=my_x(:); my_y=log(my_y(:)); [p,s]=polyfit(1./my_x,my_y,1);
            std=sqrt(diag(inv(s.R)*inv(s.R')).*s.normr.^2./s.df);
            FitCoeffients=[p(:),std(:)];
            p_prime=polyval(p,1./my_x(:)); res=my_y-p_prime;
            figure; subplot(2,1,1); plot(1./my_x,my_y,'bd:','linewidth',2);
            hold on; plot(1./my_x,p_prime,'m','linewidth',2);
            legend('Data, ln(N)= a/T + ln(b), N = b exp(a/T)',...
                sprintf('ln(N) = %f/T + %f', p(:)));
            subplot(2,1,2); bb=bar(1./my_x,res); set(bb,'facecolor','r');
            title('Residuals'); 
        end
        if ~isempty(Filename) && ~isempty(f)
            [~,BlackSheep]=xlsfinfo(Filename);
            BlackSheep=sum(strcmp('FitCoefficientsAgainstT',BlackSheep));
            if BlackSheep>0
                a=xlsread(Filename,'FitCoefficientsAgainstT');
                try
                nRows=find(a(:,1)==str2double(LK)); 
                catch
                    nRows='';
                end
                if ~isempty(nRows)
                    q='';
                    while isempty(q)
                    q=questdlg('Fits with the same LK were found.','New fits','Replace','Add','Add');
                    end
                    if strcmp(q,'Add')
                        nRows='';
                    end
                end
                if isempty(nRows)
                    nRows=(size(a,1));
                    nRows=nRows+1;
                end
            else
                nRows=2;
            end
            expr=sprintf('B%d:C%d',nRows,nRows+1);
            xlswrite(Filename,FitCoeffients,'FitCoefficientsAgainstT',expr);
            expr=sprintf('D%d:E%d',nRows,nRows+1);
            xlswrite(Filename,ExpCoefficients,'FitCoefficientsAgainstT',expr);
            xlswrite(Filename,LK,'FitCoefficientsAgainstT',sprintf('A%d',nRows));
        end
        %..................................................................
        if ~isempty(Filename) && ~isempty(list) % if an excel file was specified
            %..............................................................
            % update the list of samples with dates
            LIST=LIST(Not_Replace_Old_id);
            DATES=DATES(Not_Replace_Old_id);
            list=cat(1,list(:),LIST(:));
            dates=cat(1,dates(:),DATES(:));
            % write the list to the excel file 
            expr=sprintf('A1:A%d',numel(list)); % 1st column
            xlswrite(Filename,list,Sheet,expr); % sample names
            expr=sprintf('B1:B%d',numel(dates)); % 2nd column
            xlswrite(Filename,dates,Sheet,expr); % last modification date
            expr=sprintf('C1:C%d',numel(Temperatures_Prime)); % 3rd column
            xlswrite(Filename,Temperatures_Prime,Sheet,expr); % temperatures
            expr=sprintf('D1:D%d',numel(BindingNum_Prime)); % 4th column
            xlswrite(Filename,BindingNum_Prime(:),Sheet,expr); % # of binding
            %..............................................................
        end
%..........................................................................       
    case 'Linking Number'  % plot # of bound complexes VS LK
        %..................................................................
        if ~isempty(Filename) % if specified excel file
            %..............................................................
            [~,sheets,~] = xlsfinfo(Filename); % finds excel sheets
            % sheets with reported LK numbers
            sheets_id=cellfun(@(x)~isempty(regexp(x,'LK-?\d*','once')),sheets,...
                'UniformOutput',false); 
            if iscell(sheets_id)
                sheets_id=cell2mat(sheets_id);
            end
            % take only sheets with LK numbers
            sheets=sheets(sheets_id);
            if isempty(sheets) % if no sheets, warn the user
                warning('Check sheets are correctly named.');
                return; % user should check the names and retry
            end
            % ask user to select the LK numbers wanted from the sheets
            selection=listdlg('PromptString',...
                'Select a sheet or cancel to make a new one',...
                'ListString',sheets,'SelectionMode','multiple');
            selected_sheets=sheets(selection); % selected sheets
            %..............................................................
            if ~isempty(selected_sheets) % if sheets were selected
                %..........................................................
                % set an array for LK # and an array for temperatures
                All_T=[]; All_LK=zeros(1,numel(selected_sheets));
                % set a cell array for data per LK number (sheet contents)
                Bound_Complexes=cell(1,numel(selected_sheets));
                %..........................................................
                for i=1:numel(selected_sheets) % for all selected sheets
                    %......................................................
                    % read temperatures
                    T=xlsread(Filename,selected_sheets{i},'C:C');
                    % read # of bound complexes
                    BC=xlsread(Filename,selected_sheets{i},'D:D');
                    % find the LK number of the sheet
                    LK=regexp(selected_sheets{i},'LK-?\d*');
                    LK=selected_sheets{i}(LK+2:end); LK=str2double(LK);
                    % assign the LK number
                    All_LK(i)=LK;
                    % check each temperature has a # of bound complexes
                    if numel(T)~=numel(BC)
                        error('Make sure the excel file is complete!');
                    end
                    if ~isempty(T) % if data is found in the sheet
                        Bound_Complexes{i}=cat(2,T(:),BC(:));
                        % assign it to the cell array
                    else
                        Bound_Complexes{i}=[NaN,NaN];
                        % otherwise assign 'not available'
                    end
                    All_T=cat(1,All_T,T(:)); 
                    % add the reported temperatures to the array of
                    % temperatures
                    %......................................................
                end
                All_T=unique(All_T); % temperatures reported 
                if isempty(All_T) % no data
                    warning('No temperature!');
                    return;
                end
                % ask user to select a temperature
                selection=listdlg('PromptString','Select a temperature',...
                    'ListString',num2str(All_T),'SelectionMode','single');
                %..........................................................
                if ~isempty(selection)
                    % put non-unique LK sheets together
                   Temperature=All_T(selection); % selected temperature
                   Bound_Complexes_Std=cellfun(@(x)...
                       sqrt(var(x(x(:,1)==Temperature,2))/numel(...
                       x(:,1)==Temperature)),Bound_Complexes,...
                       'UniformOutput',false);                   
                   Bound_Complexes=cellfun(@(x)mean(x(x(:,1)==Temperature,2)),...
                       Bound_Complexes,'UniformOutput',false);
                   % take average of # of bound complexes at that
                   % temperature for each LK
                   if iscell(Bound_Complexes)
                       Bound_Complexes=cell2mat(Bound_Complexes);
                   end
                   if iscell(Bound_Complexes_Std)
                       Bound_Complexes_Std=cell2mat(Bound_Complexes_Std);
                   end                   
                   %.......................................................
                   % REPEATED LK VALUES FIX ###
                   Sign=sign(All_LK); % remove sign of LK for fit purposes
                   All_LK=All_LK.*Sign;
                   [All_LK,ID]=sort(All_LK); % sort LK
                   Bound_Complexes=Bound_Complexes(ID);
                   Bound_Complexes_Std=Bound_Complexes_Std(ID);
                   %.......................................................
                   if numel(All_LK)>1 % if more than 1 LK
                       % power fit # of bound complexes VS LK
                       f=fit(All_LK(:),Bound_Complexes(:),'exp1');
                       f=feval(f,All_LK(1):0.01:All_LK(end));
                   else
                       f=[]; % otherwise, neglect the fit
                   end
                   %.......................................................
                   % 2D bar plot
                   figure; bar(All_LK,Bound_Complexes,'facecolor','c'); hold on;
                   if ~isempty(f)
                       plot(All_LK(1):0.01:All_LK(end),f,'r:','linewidth',1.5);
                   end
                   errorbar(All_LK,Bound_Complexes(:),Bound_Complexes_Std(:),'ro','linewidth',1.5);
                   xlabel('Linking number \Delta Lk', 'Fontsize', 20); 
                   ylabel('<Number of bound complexes> for 100 pits', 'FontSize', 20);
                   title(strcat('T=',num2str(Temperature),'^oC'),'FontSize',24);
                   set(gca,'FontSize',20)
                   %.......................................................
                   % 2D scatter plot
%                    figure; scatter(All_LK,Bound_Complexes); hold on;
%                    if ~isempty(f)
%                        plot(All_LK(1):0.01:All_LK(end),f,'r:','linewidth',1.5);
%                    end
%                    xlabel('LK'); ylabel('# of bound complexes');
%                    title(strcat('T=',num2str(Temperature),'^oC'));
                   %.......................................................
                else % no temperature was selected
                    %......................................................
                    warning('No temperature selected!');
                    return; 
                    %......................................................
                end
                %..........................................................
            else % no sheet was found
                %..........................................................
                warning('No sheet selected or available!');
                return; 
                %..........................................................
            end
                %..........................................................
        else % no database was selected!!!
            %..............................................................
            warning('No database available.');
            return;
            %..............................................................
        end
%..........................................................................         
    case 'Temperature and Linking Number'  % plot # of bound complexes VS T & LK
        %..................................................................
        if ~isempty(Filename) % if specified excel file
            %..............................................................
            [~,sheets,~] = xlsfinfo(Filename); % finds excel sheets
            % ask user to select wanted sheet
            sheets_id=cellfun(@(x)~isempty(regexp(x,'LK-?\d*','once')),sheets,...
                'UniformOutput',false);
            if iscell(sheets_id)
                sheets_id=cell2mat(sheets_id);
            end
            sheets=sheets(sheets_id);
            if isempty(sheets)
                warning('Check sheets are correctly named.');
                return;
            end
            selection=listdlg('PromptString',...
                'Select a sheet or cancel to make a new one',...
                'ListString',sheets,'SelectionMode','multiple');
            selected_sheets=sheets(selection);
            %..............................................................
            if ~isempty(selected_sheets)
                %..........................................................
                All_LK=zeros(1,numel(selected_sheets));
                Bound_Complexes=cell(1,numel(selected_sheets));
                for i=1:numel(selected_sheets)
                    %......................................................
                    T=xlsread(Filename,selected_sheets{i},'C:C');
                    BC=xlsread(Filename,selected_sheets{i},'D:D');
                    LK=regexp(selected_sheets{i},'LK-?\d*');
                    LK=selected_sheets{i}(LK+2:end); LK=str2double(LK);
                    All_LK(i)=LK;
                    if numel(T)~=numel(BC)
                        error('Make sure the excel file is complete!');
                    end
                    if ~isempty(T)
                        Bound_Complexes{i}=cat(2,T(:),LK*ones(numel(T),1),BC(:));
                    else
                        Bound_Complexes{i}=[NaN,NaN,NaN];
                    end
                    %......................................................
                end
                %..........................................................
                % put all data together (T,LK,# of bound complexes)
                Bound_Complexes=cell2mat(Bound_Complexes(:));
                % find rows (temperature, LK) that are repeated 
                [~,IDD,ID]=unique(Bound_Complexes(:,1:2),'rows','stable');
                % find unique rows (temperature, LK) address
                ID2=unique(ID);
                % initialize data points
                DataPoints=zeros(numel(ID2),3);
                % for each unique row address, take the average if the # of
                % bound complexes with same temperature & LK
                for i=1:numel(ID2) % for all unique rows
                    % find repeated rows (T & LK) and average # of bound
                    % complexes
                    DataPoints(i,3)=nanmean(Bound_Complexes(ID==ID2(i),3));
                    % assign T & LK to the averaged # of bound complexes
                    DataPoints(i,1:2)=Bound_Complexes(IDD(i),1:2);
                end
                % DataPoints has unique pairs of T & LK with corresponding
                % averaged # of bound complexes
                %..........................................................
                % ### Chris may have a better solution  than data
                % interpolation but I'll give it a try just in case ###
                %..........................................................
                % 3D bar plot
                % unique temperatures and unique LK numbers
                All_LK=unique(All_LK); All_T=unique(DataPoints(:,1));
                % make all possible pairs
                [T,LK]=meshgrid(All_T,All_LK); Pairs=[T(:),LK(:)];
                % create a new data matrix with all the pairs
                Modified_Data=cat(2,Pairs,zeros(size(Pairs,1),1)*NaN);
                % assign the # of bound complexes to those we know
                [~,IDA,IDB]=intersect(DataPoints(:,1:2),Pairs,'rows');
                Modified_Data(IDB,3)=DataPoints(IDA,3);
                % Modified_Data is an uniform array of data points (same
                % length histograms for each LK) with NaN whenever it was
                % verified experimentally
                % sort the data points with the LK number
                [~,SortMe]=sort(Modified_Data(:,2));
                Modified_Data=Modified_Data(SortMe,:);
                % reshape the # of bound complexes array for the 3D bar
                % plot and get the x axis and y axis
                Z=reshape(Modified_Data(:,3),numel(All_T),numel(All_LK));
                X=Modified_Data(1:numel(All_T),1); Y=All_LK; 
                Y=num2cell(Y); Y=cellfun(@num2str,Y,'UniformOutput',false);
                % produces 3 plots just for fun
                figure; bar3(X,Z); set(gca,'XTickLabel',Y);
                ylabel('Temperature (°C)','FontSize',15)
                xlabel('Linking number (LK)','FontSize',15)
                zlabel('<Number of bound complexes> for 100 pits', 'FontSize', 15)
                set(gca,'FontSize',13);
                
                % ATTEMPT AT SURFACE PLOTS---------------------------------
                [xg, yg] = meshgrid(min(DataPoints(:,1)):.5:max(DataPoints(:,1)), min(DataPoints(:,2)):.5:max(DataPoints(:,2)));
                vq = griddata(DataPoints(:,1),DataPoints(:,2), DataPoints(:,3), xg, yg);
                
                % Surface plot
                figure;
                surf(xg, yg, vq);
                colorbar;
                xlabel('Temperature (°C)','FontSize',15)
                ylabel('Linking number (LK)','FontSize',15)
                zlabel('<Number of bound complexes> for 100 pits', 'FontSize',15)
                hold on;
                plot3(DataPoints(:,1), DataPoints(:,2),DataPoints(:,3),'o');
                set(gca,'FontSize',14);
                
                % Grid surface
                figure;
                mesh(xg, yg, vq);
                colorbar;
                xlabel('Temperature (°C)','FontSize',16)
                ylabel('Linking number (LK)','FontSize',16)
                zlabel('<Number of bound complexes> for 100 pits', 'FontSize',16)
                hold on;
                plot3(DataPoints(:,1), DataPoints(:,2),DataPoints(:,3),'o');
                set(gca,'FontSize',18);
                
                % Same thing, xy plane.
                figure;
                surf(xg, yg, vq);
                colorbar;
                view([0,90]);
                xlabel('Temperature (°C)', 'FontSize',20);
                ylabel('Linking number (LK)', 'FontSize',20);
                zlabel('<Number of bound complexes> for 100 pits', 'FontSize',20)
                hold on;
                plot3(DataPoints(:,1), DataPoints(:,2),DataPoints(:,3),'o');
                set(gca,'FontSize',18);
                
                
                figure;
                mesh(xg, yg, vq);
                colorbar;
                view([0, 90]);
                xlabel('Temperature (°C)','FontSize',20)
                ylabel('Linking number (LK)','FontSize',20)
                zlabel('<Number of bound complexes> for 100 pits', 'FontSize',20)
                hold on;
                plot3(DataPoints(:,1), DataPoints(:,2),DataPoints(:,3),'o');
                set(gca,'FontSize',18);
             
                %----------------------------------------------------------
                
                % Heat map???
%                 Interpolation WELL it doesn't super work right now LOL
%                 xq= min(DataPoints(:,1)):1:max(DataPoints(:,1))
%                 yq=min(DataPoints(:,2)):5:max(DataPoints(:,2))
%                 InterpolatedData=griddata(DataPoints(:,1),...
%                     DataPoints(:,2),DataPoints(:,3),xq,yq)
%                 figure; surf(xq,yq,InterpolatedData);
                %..........................................................
            else % no sheet selected
                %..........................................................
                warning('No sheet selected or available!');
                return;
                %..........................................................
            end
            %..............................................................                
        else % no database available
            %..............................................................
            warning('No database available.');
            return;
            %..............................................................
        end        
end
%  ========================================================================
%% ======================== RANDOM FUNCTIONS ==============================
    function date=GetDate(name)
        % look for last modification date first
        x=evalin('base',sprintf('%s.Last_Modification_Date;',name));
        if ~ischar(x) || isempty(x)
        x=evalin('base',sprintf('%s.MatFileName;',name));
        else
            date=x; return;
        end
        if ~ischar(x) || isempty(x)
            error('No analysis date was found for %s',name);
        else
        id=regexp(x,'*? analyzed on ','once');
        date=x(id+13:end); date=regexprep(date,'*?.mat','');
        date=FilterDate(date);            
        end
    end
    function date=FilterDate(date)
        id=regexp(date,'\d_\D'); date(id+1)='-';
        id=regexp(date,'\D_\d'); date(id+1)='-';
        id=regexp(date,'\d_\d'); date(id+1)=':';
    end
    function id=UpToDate(n1,n2)
        [~,id]=max([n1,n2]); id=logical(id-1);
    end
    function x=goodsheet(x)
        if iscell(x)
            x=cell2mat(x);
        end
        x=~isempty(x);
    end
%  ========================================================================
end