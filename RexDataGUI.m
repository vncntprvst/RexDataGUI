function varargout = RexDataGUI(varargin)
% REXDATAGUI MATLAB code for RexDataGUI.fig
%      Designed to make Rex data analysis easier, more efficient, and nicer to
%      the eye. VP 02/2012
%
%      REXDATAGUI, by itself, creates a new REXDATAGUI or raises the existing
%      singleton*.
%
%      H = REXDATAGUI returns the handle to a new REXDATAGUI or the handle to
%      the existing singleton*.
%
%      REXDATAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REXDATAGUI.M with the given input arguments.
%
%      REXDATAGUI('Property','Value',...) creates a new REXDATAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RexDataGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RexDataGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 07-Mar-2013 23:16:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RexDataGUI_OpeningFcn, ...
    'gui_OutputFcn',  @RexDataGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before RexDataGUI is made visible.
function RexDataGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RexDataGUI (see VARARGIN)

% Choose default command line output for RexDataGUI
handles.output = hObject;
global replacespikes;
replacespikes = 0;
% tiny design changes
set(hObject,'DefaultTextFontName','Calibri'); %'Color',[0.9 .9 .8]
% unprocfilebtxt=sprintf('Unprocessed\rfiles');
% uibutton(findobj('tag','unprocfilebutton'),'string',unprocfilebtxt);


% use varargin to allow for direct input of the name of the file to be analyzed.
% see http://www.mathworks.com/help/techdoc/creating_guis/f10-998580.html

% Update handles structure
guidata(hObject, handles);

% % determines computer type  % moved it to displaym_files_create
% archst  = computer('arch');
%
% global directory slash;
%
% if strcmp(archst, 'maci64')
%     name = getenv('USER');
%     if strcmp(name, 'nick')
%         directory = '/Users/nick/Dropbox/filesforNick/';
%     elseif strcmp(name, 'Frank')
%         directory = '/Users/Frank/Desktop/monkeylab/data/';
%     end
%     slash = '/';
% elseif strcmp(archst, 'win32') || strcmp(archst, 'win64')
%     % for future users, make it name = getenv('username');
%     directory = 'B:\data\Recordings\';
%     slash = '\';
% end


% UIWAIT makes RexDataGUI wait for user response (see UIRESUME)
% uiwait(handles.rdd);


% --- Outputs from this function are returned to the command line.
function varargout = RexDataGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function filenamedisplay_Callback(hObject, eventdata, handles)
% hObject    handle to filenamedisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filenamedisplay as text
%        str2double(get(hObject,'String')) returns contents of filenamedisplay as a double


% --- Executes during object creation, after setting all properties.
function filenamedisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filenamedisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function taskdisplay_Callback(hObject, eventdata, handles)
% hObject    handle to taskdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of taskdisplay as text
%        str2double(get(hObject,'String')) returns contents of taskdisplay as a double

% --- Executes during object creation, after setting all properties.
function taskdisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to taskdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nboftrialsdisplay_Callback(hObject, eventdata, handles)
% hObject    handle to nboftrialsdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nboftrialsdisplay as text
%        str2double(get(hObject,'String')) returns contents of nboftrialsdisplay as a double


% --- Executes during object creation, after setting all properties.
function nboftrialsdisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nboftrialsdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function trialnumbdisplay_Callback(hObject, eventdata, handles)
% hObject    handle to trialnumbdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialnumbdisplay as text
%        str2double(get(hObject,'String')) returns contents of trialnumbdisplay as a double


% --- Executes during object creation, after setting all properties.
function trialnumbdisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialnumbdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in arrowbackw.
function arrowbackw_Callback(hObject, eventdata, handles)
% hObject    handle to arrowbackw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global replacespikes;

showwtrial= get(get(findobj('Tag','showtrials'),'SelectedObject'),'Tag');%selected button's tag
if strcmp(showwtrial,'showalltrials')
    trialnumber=str2num(get(findobj('Tag','trialnumbdisplay'),'String'))-1;
    if trialnumber<1
        trialnumber=str2num(get(findobj('Tag','nboftrialsdisplay'),'String'));
    end
elseif strcmp(showwtrial,'showoutlierstrials')
    outliers=str2num(get(findobj('Tag','outliertrialnb'),'String'));
    currtrial=str2num(get(findobj('Tag','trialnumbdisplay'),'String'));
    if find(outliers==currtrial)==1
        trialnumber=max(outliers);
    else
        trialnumber=outliers(find(outliers==currtrial)-1);
    end
elseif strcmp(showwtrial,'showbadtrials') %another day
elseif strcmp(showwtrial,'showgoodtrials') %another day
end
if ~cellfun('isempty',regexp(get(findobj('Tag','filenamedisplay'),'String'),'\d\d$', 'match')) %'native' filename, without _Sp2 or _REX appendice
    if strcmp(showwtrial,'showoutlierstrials') %was just processed
        if replacespikes
            filename=[get(findobj('Tag','filenamedisplay'),'String') '_Sp2'];
        else
            filename=[get(findobj('Tag','filenamedisplay'),'String') '_REX'];
        end
    else
        filename=get(findobj('Tag','filenamedisplay'),'String')
    end
end
set(findobj('Tag','trialnumbdisplay'),'String',num2str(trialnumber));
rdd_trialdata(filename, trialnumber);

% --- Executes on button press in arrowforw.
function arrowforw_Callback(hObject, eventdata, handles)
% hObject    handle to arrowforw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global replacespikes;

showwtrial= get(get(findobj('Tag','showtrials'),'SelectedObject'),'Tag');%selected button's tag
if strcmp(showwtrial,'showalltrials')
    trialnumber=str2num(get(findobj('Tag','trialnumbdisplay'),'String'))+1;
    if trialnumber>str2num(get(findobj('Tag','nboftrialsdisplay'),'String'))
        trialnumber=1;
    end
elseif strcmp(showwtrial,'showoutlierstrials')
    outliers=str2num(get(findobj('Tag','outliertrialnb'),'String'));
    currtrial=str2num(get(findobj('Tag','trialnumbdisplay'),'String'));
    if find(outliers==currtrial)==length(outliers)
        trialnumber=min(outliers);
    else
        trialnumber=outliers(find(outliers==currtrial)+1);
    end
elseif strcmp(showwtrial,'showbadtrials') %another day
elseif strcmp(showwtrial,'showgoodtrials') %another day
end
if ~cellfun('isempty',regexp(get(findobj('Tag','filenamedisplay'),'String'),'\d\d$', 'match')) %'native' filename, without _Sp2 or _REX appendice
    if strcmp(showwtrial,'showoutlierstrials') %was just processed
        if replacespikes
            filename=[get(findobj('Tag','filenamedisplay'),'String') '_Sp2'];
        else
            filename=[get(findobj('Tag','filenamedisplay'),'String') '_REX'];
        end
    else
        filename=get(findobj('Tag','filenamedisplay'),'String')
    end
end
set(findobj('Tag','trialnumbdisplay'),'String',num2str(trialnumber));
rdd_trialdata(filename, trialnumber);


% --- Executes on selection change in SacDirToDisplay.
function SacDirToDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to SacDirToDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SacDirToDisplay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SacDirToDisplay


% --- Executes during object creation, after setting all properties.
function SacDirToDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SacDirToDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in OpenRawFile.
function OpenRawFile_Callback(hObject, eventdata, handles)
% hObject    handle to OpenRawFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global directory slash unprocfiles replacespikes;

monkeydirselected=get(get(findobj('Tag','monkeyselect'),'SelectedObject'),'Tag');
if strcmp(monkeydirselected,'rigelselect')
    monkeydir = [directory,'Rigel',slash]; %'B:\data\Recordings\Rigel';
    procdir = [directory,'processed',slash,'Rigel',slash];
elseif strcmp(monkeydirselected,'sixxselect')
    monkeydir = [directory,'Sixx',slash]; %'B:\data\Recordings\Sixx';
    procdir = [directory,'processed',slash,'Sixx',slash];
elseif strcmp(monkeydirselected,'hildaselect')
    monkeydir = [directory,'Hilda',slash]; %'B:\data\Recordings\Sixx';
    procdir = [directory,'processed',slash,'Hilda',slash];
end

% determines computer type
archst  = computer('arch');
if strcmp(archst, 'maci64')
    [rfname, rfpathname]=uigetfile({'*.*','All Files';'*A','A Files'},'raw files directory',...
        monkeydir);
else
    [rfname, rfpathname]=uigetfile({'*A','A Files';'*.*','All Files'},'raw files directory',...
        monkeydir);
end

%check if file exists already
rfname=rfname(1:length(rfname)-1);
overwrite = 1;
if strcmp(monkeydirselected,'rigelselect')
    if ~strcmp(rfname(1),'R')
        procname=cat(2,'R', rfname);
        set(findobj('Tag','filenamedisplay'),'String',procname);
    else
        procname=rfname;
        set(findobj('Tag','filenamedisplay'),'String',rfname);
    end
elseif strcmp(monkeydirselected,'sixxselect')
    if ~strcmp(rfname(1),'S')
        procname=cat(2,'S', rfname);
        set(findobj('Tag','filenamedisplay'),'String',procname);
    else
        procname=rfname;
        set(findobj('Tag','filenamedisplay'),'String',rfname);
    end
elseif strcmp(monkeydirselected,'hildaselect')
    if ~strcmp(rfname(1),'H')
        procname=cat(2,'H', rfname);
        set(findobj('Tag','filenamedisplay'),'String',procname);
    else
        procname=rfname;
        set(findobj('Tag','filenamedisplay'),'String',rfname);
    end
end
if exist(cat(2,procdir, procname,'.mat'), 'file')==2 %'B:\data\Recordings\processed\',
    % Construct question dialog
    choice = questdlg('File already processed. Overwrite?','File found','Yes','Cancel','Yes');
    switch choice
        case 'Yes'
            overwrite = 1;
        case 'Cancel'
            overwrite = 0;
    end
end
if overwrite
    [success,outliers]=rex_process_inGUI(rfname,monkeydir); %shouldn't need the rfpathname
    if success
        if replacespikes
            rfname=[rfname '_Sp2'];
        else
            rfname=[rfname '_REX'];
        end
        %then update the directory listing
        if strcmp(monkeydirselected,'rigelselect')
            dirlisting = dir([directory,'processed',slash,'Rigel',slash]); %('B:\data\Recordings\processed');
            monknum=1;
        elseif strcmp(monkeydirselected,'sixxselect')
            dirlisting = dir([directory,'processed',slash,'Sixx',slash]); %('B:\data\Recordings\processed');
            monknum=2;
        elseif strcmp(monkeydirselected,'hildaselect')
            dirlisting = dir([directory,'processed',slash,'Hilda',slash]); %('B:\data\Recordings\processed');
            monknum=3;
        end
        % Order by date
        filedates=cell2mat({dirlisting(:).datenum});
        [filedates,fdateidx] = sort(filedates,'descend');
        dirlisting = {dirlisting(:).name};
        dirlisting=dirlisting(fdateidx);
        dirlisting = dirlisting(cellfun('isempty',strfind(dirlisting,'myBreakpoints')));
        dirlisting = dirlisting(~cellfun('isempty',strfind(dirlisting,'mat')));
        for i=1:length(dirlisting)
            thisfilename=cell2mat(dirlisting(i));
            dirlisting(i)={thisfilename(1:end-4)};
        end
        set(findobj('Tag','displaymfiles'),'String',dirlisting);
        
        %remove newly processed file(s) from unprocessed variable
        if ismember(unprocfiles{monknum},rfname)
            if length(ismember(unprocfiles{monknum},rfname))>1
                unprocfiles{monknum}=unprocfiles{monknum}(~ismember(unprocfiles{monknum},rfname));
            else
                unprocfiles{monknum}={};
            end
        end
        
        if outliers
            if ~get(findobj('Tag','displayfbt_session'),'Value') %show dialog only if processing individual trial
                % make dialogue to inspect ouliers
                dlgtxt=cat(2,'Found outlier saccades in trials ', num2str(outliers), '. Display them?');
                outlierbt = questdlg(dlgtxt,'Found outliers','Yes','No','Yes');
                switch outlierbt
                    case 'Yes'
                        dispoutliers = 1;
                    case 'No'
                        dispoutliers = 0;
                end
                
                if dispoutliers
                    set(findobj('Tag','outliertrialnb'),'String',num2str(outliers));
                    set(findobj('Tag','trialnumbdisplay'),'String',num2str(outliers(1)));
                    set(findobj('Tag','showoutlierstrials'),'Value',1.0);
                    rdd_trialdata(rfname, outliers(1));
                end
            end
        end
    end
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over OpenRawFile.
function OpenRawFile_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to OpenRawFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in savechg.
function savechg_Callback(hObject, eventdata, handles)
% hObject    handle to savechg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function rigthclickcallback
processedrexfiles = cellstr(get(findobj('tag','displaymfiles'),'String')); % returns displaymfiles contents as cell array
rclk_filename = processedrexfiles{get(findobj('tag','displaymfiles'),'Value')};

% --- Executes on selection (double click) of file in listbox.
% this the function that loads data,  puts name in UserData, and display
% first trial
function displaymfiles_Callback(hObject, eventdata, handles)
% hObject    handle to displaymfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global directory slash replacespikes ; %unprocfiles rexloadedname

monkeydirselected=get(get(findobj('Tag','monkeyselect'),'SelectedObject'),'Tag');
if strcmp(monkeydirselected,'rigelselect')
    monkeydir = [directory,'Rigel',slash]; %'B:\data\Recordings\Rigel';
    procdir = [directory,'processed',slash,'Rigel',slash];
elseif strcmp(monkeydirselected,'sixxselect')
    monkeydir = [directory,'Sixx',slash]; %'B:\data\Recordings\Sixx';
    procdir = [directory,'processed',slash,'Sixx',slash];
elseif strcmp(monkeydirselected,'hildaselect')
    monkeydir = [directory,'Hilda',slash]; %'B:\data\Recordings\Hilda';
    procdir = [directory,'processed',slash,'Hilda',slash];
end

if strcmp(get(gcf,'SelectionType'),'normal') && ~strcmp(eventdata,'rightclkevt') % if simple click, just higlight it, don't open
    if get(findobj('Tag','displayfbt_files'),'Value') % works only with individual file display
        %set uimenu content for following rightclick
        %SelectionType 'Alternate' (Right click) doesn't work with listbox
        %dispmenu=(get(hObject,'UIContextMenu'));
        set(findobj('tag','displaymfiles'),'Max',1)
        clear rightclkevt;
        clear global tasktype;
        listboxcontextmenu=uicontextmenu;
        processedrexfiles = cellstr(get(hObject,'String')); % returns displaymfiles contents as cell array
        rclk_filename = processedrexfiles{get(hObject,'Value')}; %returns selected item from displaymfiles
        filecontent=matfile([procdir,rclk_filename,'.mat']);
        filecodes=filecontent.allcodes;
        curtasktype=taskdetect(filecodes);
        if iscell(curtasktype)
            curtasktype=cell2mat(curtasktype);
        end
        disptask=uimenu('Parent',listboxcontextmenu,'Label',curtasktype);
        set(hObject,'UIContextMenu',listboxcontextmenu);
    else
        set(hObject,'Max',2);
        rightclkevt='rightclkevt';
        multianalyzepopup=uicontextmenu();
        set(hObject,'uicontextmenu',multianalyzepopup);
        item1 = uimenu(multianalyzepopup,'Label','Analyze','Callback',{@(src,evt,handles) displaymfiles_Callback(hObject,rightclkevt,handles),hObject});  %disp(get(hObject,'Value'))
        %displaymfiles_Callback(hObject, eventdata, handles)
    end
elseif strcmp(get(gcf,'SelectionType'),'open') || strcmp(eventdata,'rightclkevt')
    cd(directory);
    s=dbstatus; %little trick to prevent removal of breakpoints with clear
    save('myBreakpoints.mat', 's');
    clear functions;
    clear rightclkevt;
    load('myBreakpoints.mat');
    dbstop(s);
    
    processedrexfiles = cellstr(get(hObject,'String')); % returns displaymfiles contents as cell array
    selectionnm = {processedrexfiles{get(hObject,'Value')}}; %returns selected item from displaymfiles
    
    %% very different actions (for the moment) between display buttons files and session/grid:
    % the 'normal' one will display the file (which was already processed)
    % the others will process the requested combination of files, but not
    % display them, since for the moment GUI is designed to display only one
    % file at a time
    if ~get(findobj('Tag','displayfbt_files'),'Value') % if session or grid is selected
        selectedrawdir=dir(monkeydir);
        fileNames = {selectedrawdir.name};  % Put the file names in a cell array
        
        if get(findobj('Tag','displayfbt_session'),'Value')
            sessionNumber=regexpi(selectionnm,'\d+$', 'match');
            allftoanlz=cell(length(sessionNumber),1);
            for sessnumnum=1:length(sessionNumber)
                ftoanlz = regexp(fileNames, strcat('^\w',sessionNumber{sessnumnum}{:}),'match');
                ftoanlz = fileNames(~cellfun(@isempty,ftoanlz));  % Get the names of the matching files in a cell array
                ftoanlz = regexprep(ftoanlz, '(A$)|(E$)',''); %remove A and E from end of names
                ftoanlz = unique(ftoanlz);
                allftoanlz{sessnumnum}=ftoanlz;
            end
            allftoanlz=horzcat(allftoanlz{:});
            
        elseif get(findobj('Tag','displayfbt_grid'),'Value')
            allftoanlz=cell(length(selectionnm),1);
            for sessnumnum=1:length(selectionnm)
                ftoanlz = regexp(fileNames, selectionnm{sessnumnum}); %regexp(fileNames, strcat('^\w',gridNumber{sessnumnum}{:}),'match');
                ftoanlz = fileNames(~cellfun(@isempty,ftoanlz));  % Get the names of the matching files in a cell array
                ftoanlz = regexprep(ftoanlz, '(A$)|(E$)',''); %remove A and E from end of names
                ftoanlz = unique(ftoanlz);
                allftoanlz{sessnumnum}=ftoanlz;
            end
            allftoanlz=horzcat(allftoanlz{:});
        end
        
        
        if strcmp(monkeydirselected,'rigelselect')
            monknum=1;
        elseif strcmp(monkeydirselected,'sixxselect')
            monknum=2;
        elseif strcmp(monkeydirselected,'hildaselect')
            monknum=3;
        end
        
        
        overwriteAll = 0; % This switch should stay hardcoded, no need for user option 
        if  overwriteAll %(exist(strcat({procdir},rfname,{'.mat'}), 'file')==2)
            % Construct question dialog
            choice = questdlg('Do you want to overwrite processed files?','Reprocess files?','Overwrite all','Skip','Skip'); %'Overwrite this file'
            switch choice
                case 'Overwrite all'
                    overwrite = 1;
                    %                                 overwriteAll = 1;
                    %                             case 'Overwrite this file'
                    %                                 overwrite = 1;
                    %                                 overwriteAll = 0;
                case 'Skip'
                    overwrite = 0;
                    %                                 overwriteAll = 0;
            end
        else
            overwrite=0;
        end
        
        for i = 1:length(allftoanlz)
            procname=allftoanlz{i};
            
            if overwrite
                [success,outliers]=rex_process_inGUI(procname,monkeydir); %shouldn't need the rfpathname
                % outliers are stored in file now
                
                if success
                    successtr=['file ',procname,' processed succesfully'];
                    disp(successtr);
                    
                    if ismember(unprocfiles{monknum},procname) %some files from this session / grid may not have been processed
                        if length(ismember(unprocfiles{monknum},procname))>1
                            unprocfiles{monknum}=unprocfiles{monknum}(~ismember(unprocfiles{monknum},procname));
                        else
                            unprocfiles{monknum}={};
                        end
                    end
                    
                else
                    successtr=['processing aborted for file ',procname'];
                    disp(successtr);
                end
            end
            % load file
            clear global tasktype;
            if replacespikes
                procname=[procname '_Sp2'];
            else
                procname=[procname '_REX'];
            end
            
            try
                [~, trialdirs] = data_info(procname, 1, 1); %reload file: yes (shouldn't happen, though), skip unprocessed files: yes
            catch
                continue
            end
            % process file, aligning to sac, cue, reward
            alignmtname={'mainsacalign','tgtshownalign','rewardalign'};
            alignbh=get( findobj('Tag','aligntimepanel'),'children');
            for alignmt=1:3
            set(findobj('Tag','aligntimepanel'),'SelectedObject',alignbh(strcmp(get(alignbh,'tag'),alignmtname{alignmt})))            
            getaligndata{alignmt} = rdd_rasters_sdf(procname, trialdirs, 0); % align data, don't plot rasters
            
            %% statistics on rasters: do stats on collapsed data and individual direction, if > 7 trials 
            if length([getaligndata{alignmt}.trials])>=7
                getaligndata{alignmt}=getaligndata{alignmt}(~cellfun('isempty',{getaligndata{alignmt}.alignidx})); % remove empty conditions
                % main stats
                [p_sac,h_sac,p_rmanov,mcstats]=eventraststats(getaligndata{alignmt},alignmtname{alignmt});
                for psda=1:length(getaligndata{alignmt})+1
                    getaligndata{alignmt}(psda).stats.p=p_sac(psda,:);
                    getaligndata{alignmt}(psda).stats.h=h_sac(psda,:);
                end
                %additional measures: cc and auc
                % cross-correlation values: pretty reliable indicator to sort out pre-event, peri-event and post-event activities
                % possible limits are:
                % pressac <-10ms before sac , >-10ms perisac <+10ms, <10ms postsac
                [peakcct, peaksdf]=crosscorel(procname,getaligndata{alignmt},'all',0); %Get peakcc for all directions. Don't plot
                % area under curve: separate cells with low baseline FR and sharp burst from higher baseline neurons, especially ramping ones
                % possible limit at 2000
                [dirauc, dirslopes, peaksdft]=findauc(procname,getaligndata{alignmt},'all'); %Get auc, slopes, peaksdft for all directions
                
                getaligndata{alignmt}(psda).peakramp.peakcct=peakcct; % peak cross-correlation time
                getaligndata{alignmt}(psda).peakramp.peaksdf=peaksdf; % main sdf peak, within -200/+199 of aligntime
                getaligndata{alignmt}(psda).peakramp.peaksdf=peaksdft; %
                getaligndata{alignmt}(psda).peakramp.auc=dirauc; % area under curve
                getaligndata{alignmt}(psda).peakramp.slopes=dirslopes; % slope of activity to peak (or drought, if negative)
                
                for psda=1:length(getaligndata{alignmt})
                    getaligndata{alignmt}(psda).stats.p=p_sac(psda,:);
                    getaligndata{alignmt}(psda).stats.h=h_sac(psda,:);
                    getaligndata{alignmt}(psda).stats.p_rmanov=p_rmanov(psda,:);
                    getaligndata{alignmt}(psda).stats.mcstats=mcstats(psda,:);
                end
                
            end
            end
                % export data
                if isempty(cellfun(@(x) x.savealignname, arrayfun(@(x) x, getaligndata),'UniformOutput', false))
                    getaligndata{1}(1).savealignname = cat( 2, directory, 'processed',slash, 'aligned',slash, procname, '_', getaligndata{1}(1).alignlabel);
                end
                guidata(findobj('Tag','exportdata'),getaligndata);
                exportdata_Callback(findobj('tag','exportdata'), eventdata, handles);
                
                % check if statistically significant event related activity in any alignment
            if sum(~cellfun('isempty',(cellfun(@(x) x.trials, arrayfun(@(x) x, getaligndata),'UniformOutput', false))))
                
                [activlevel,activtype,maxmean,profile,dirselective,bestlt]=catstatres(getaligndata);

            else
                [activtype,profile,dirselective]=deal('');
                [maxmean,activlevel]=deal(0);
            end

            % print vignette figure of statistically significant result
            if activlevel
            SummaryPlot(activtype,procname,tasktype);
            end
            
            % crude segmentation: set depth limits for top cortex / dentate / bottom cortex
            if monknum==1
                cdn_depth=19000;
                bcx_depth=22000;
            elseif monknum==2
                cdn_depth=11000;
                bcx_depth=17000;
            elseif monknum==3
                cdn_depth=19000;
                bcx_depth=26000;
            end
            recdepth=regexp(procname,'_\d+_','match');
            recdepth=str2num([recdepth{:}(2:end-2) '0']);
            if (recdepth<cdn_depth)
            compart={'top_cortex'};
            elseif (recdepth>=cdn_depth && recdepth<=bcx_depth)
            compart={'dentate'};
            elseif (recdepth>bcx_depth)
            compart={'bottom_cortex'};
            end
            
            % write result to excel file
            
            % get number of row in "database"
            exl = actxserver('excel.application');
            exlWkbk = exl.Workbooks;
            exlFile = exlWkbk.Open([directory 'procdata.xlsx']);
            exlSheet = exlFile.Sheets.Item(monknum);% e.g.: 2 = Sixx
            robj = exlSheet.Columns.End(4);
            numrows = robj.row;
            if numrows==1048576 %empty document
                numrows=1;
            end
            Quit(exl);
                        
            cd(directory);
            [~,pfilelist] = xlsread('procdata.xlsx',monknum,['A2:A' num2str(numrows)]);
            if logical(sum(ismember(pfilelist,procname))) %file has to have been processed already, but if for some reason not, then do not go further
                wline=find(ismember(pfilelist,procname))+1;
            else
                continue
            end
            xlswrite('procdata.xlsx', compart, monknum, sprintf('H%d',wline));
            xlswrite('procdata.xlsx', activlevel, monknum, sprintf('K%d',wline));
            xlswrite('procdata.xlsx', activtype, monknum, sprintf('L%d',wline));
            xlswrite('procdata.xlsx', maxmean, monknum, sprintf('M%d',wline));
            xlswrite('procdata.xlsx', profile, monknum, sprintf('N%d',wline));
            xlswrite('procdata.xlsx', dirselective, monknum, sprintf('O%d',wline));
            xlswrite('procdata.xlsx', bestlt, monknum, sprintf('P%d',wline));
        end
    else
        %% normal method
        
        %         selecteprocdir=dir(procdir);
        %          {selecteprocdir.name};  % Put the file names in a cell array
        rdd_filename =selectionnm{:};
        [rdd_nt, trialdirs] = data_info( rdd_filename, 1);% load file
        trialnumber = rex_first_trial( rdd_filename, rdd_nt, 1);
        if trialnumber == 0
            msgbox( 'There are no good trials (no trials, or all are marked BAD) for this set of Rex data.', 'Loading data', 'modal' );
            return;
        end;
        set(findobj('Tag','trialnumbdisplay'),'String',num2str(trialnumber));
        %set(findobj('Tag','outliertrialnb'),'String',[]);
        set(findobj('Tag','showalltrials'),'Value',1.0);
        %set(gcbf,'UserData',whatever might be needed);
        %disp ('File name set to Figure UserData');
        %now send data to Trial Data panel, to display first trial
        %trialdatapanelH = findobj('Tag','fulltrialdata');
        %set(trialdatapanelH,'UserData',whatever might be needed);
        
        rdd_trialdata(rdd_filename, trialnumber); % add 1 to make sure it reloads file
        dataaligned=rdd_rasters_sdf(rdd_filename, trialdirs,1); %align data, plot rasters
        dataaligned=dataaligned(~cellfun('isempty',{dataaligned.alignidx}));
        %% do stats
        [p_sac,h_sac,p_rmanov,mcstats]=raststats(dataaligned);
        for psda=1:length(dataaligned)
            dataaligned(psda).stats.p=p_sac(psda,:);
            dataaligned(psda).stats.h=h_sac(psda,:);
        end
        
        %additional measures: cc and auc
        % cross-correlation values: pretty reliable indicator to sort out presac, perisac and postsac activities
        % possible limits are:
        % pressac <-10ms before sac , >-10ms perisac <+10ms, <10ms postsac
        %             [peakcct, peaksdf]=crosscorel(rdd_filename,dataaligned,'all',0); %Get peakcc for all directions. Don't plot
        % area under curve: separate cells with low baseline FR and sharp burst from higher baseline neurons, especially ramping ones
        % possible limit at 2000
        %             [dirauc, dirslopes, peaksdft]=findauc(rdd_filename,dataaligned,'all'); %Get auc, slopes, peaksdft for all directions
        
        
        %% Present statistics
        pdata = {};
        stat_dir = {};
        set(findobj('Tag','wilcoxontable'),'Data',pdata,'RowName',[]); %Clears previous table
        
        % Create table data
        if any(sum(h_sac,1))
            pdata=num2cell(p_sac);
            stat_dir ={dataaligned.dir};
            set(findobj('Tag','wilcoxontable'),'Data',pdata,'RowName',stat_dir);
        end
        
        guidata(findobj('Tag','exportdata'),dataaligned);
    end
end

% --- Executes on button press in replotbutton.
function replotbutton_Callback(hObject, eventdata, handles)
s=dbstatus;  %little trick to prevent removal of breakpoints with clear
save('myBreakpoints.mat', 's');
clear functions;
load('myBreakpoints.mat');
dbstop(s);
rdd_filename=get(findobj('Tag','filenamedisplay'),'String');
[rdd_nt, trialdirs] = data_info( rdd_filename );
dataaligned=rdd_rasters_sdf(rdd_filename, trialdirs,1);
guidata(findobj('Tag','exportdata'),dataaligned);

% --- Executes on button press in exportdata.
function exportdata_Callback(hObject, eventdata, handles)
% hObject    handle to exportdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataaligned=guidata(hObject);
if iscell(dataaligned) %multiple alignements
    snames=cellfun(@(x) x.savealignname, arrayfun(@(x) x, dataaligned),'UniformOutput', false);
    savealignname=[dataaligned{1}(1).savealignname(1:end-3) cell2mat(cellfun(@(x) regexp(x,'\w\w\w$','match'),snames))];
else
savealignname=dataaligned.savealignname;
end
save(savealignname,'dataaligned','-v7.3');

%save some data to match with SH / Spike2 data analysis
% about dataaligned:
% datalign.timefromtrig and datalign.timetotrig represent time from start
% or to the end of the trial with respect to the alignment time
% respectively. Depending on whether there is a trigger ecode,
% they represent different things.
% No trigger ecode: time from the first trigger(in case there's a trigger
% channel, otherwise it's useless), and time to the  end-of-trial reward delivery
% Trigger ecode: time from onset of first trigger (beggining of trial),
% and time to onset of second trigger (end of trial).
% for Rigel: no trigger ecode until R146 included
% for Sixx: no trigger ecode until S102 included

if iscell(dataaligned) %multiple alignements: keep only sac alignement
    dataaligned=dataaligned(strcmp(cellfun(@(x) x.alignlabel, arrayfun(@(x) x, dataaligned),'UniformOutput',false),'sac'));
    dataaligned=dataaligned{:};
end

rdd_filename=get(findobj('Tag','filenamedisplay'),'String');
recdata=matfile(rdd_filename);
%rex2sh=NaN(length(recdata.allbad),8);
rex2sh.goodtrials=~(recdata.allbad)';
rex2sh.starttrigs=recdata.alltrigin';
rex2sh.endtrigs=recdata.alltrigout';
rex2sh.rewtimes=recdata.allrew';
%prealloc
trigtosac=nan(size(rex2sh.goodtrials));
sactotrig=nan(size(rex2sh.goodtrials));
trigtovis=nan(size(rex2sh.goodtrials));
vistotrig=nan(size(rex2sh.goodtrials));
trialdir=cell(size(rex2sh.goodtrials));
alignlabel=cell(size(rex2sh.goodtrials));

if logical(sum(rex2sh.goodtrials))
    for i=1:length(dataaligned)
        if ~isempty(dataaligned(i).trials)
            trigtosac((dataaligned(i).trials),1)=dataaligned(i).trigtosac;
            sactotrig((dataaligned(i).trials),1)=dataaligned(i).sactotrig;
            trigtovis((dataaligned(i).trials),1)=dataaligned(i).trigtovis;
            vistotrig((dataaligned(i).trials),1)=dataaligned(i).vistotrig;
            trialdir(dataaligned(i).trials)={dataaligned(i).dir};
            alignlabel(dataaligned(i).trials)={dataaligned(i).alignlabel};
        end
    end
end
rex2sh.align=alignlabel;
rex2sh.dir=trialdir;
rex2sh.trigtosac=trigtosac;
rex2sh.sactotrig=sactotrig;
rex2sh.trigtovis=trigtovis;
rex2sh.vistotrig=vistotrig;

savealignsh=cat(2,savealignname,'_2SH');
save(savealignsh, '-struct','rex2sh','goodtrials','starttrigs',...
    'endtrigs','rewtimes','align','dir','trigtosac','sactotrig','trigtovis','vistotrig','-v7.3');

% --- Executes during object creation, after setting all properties.
function displaymfiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displaymfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global directory slash unprocfiles;

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% determines computer type
archst  = computer('arch');

if strcmp(archst, 'maci64')
    name = getenv('USER');
    if strcmp(name, 'nick')
        directory = '/Users/nick/Dropbox/filesforNick/';
    elseif strcmp(name, 'Frank')
        directory = '/Users/Frank/Desktop/monkeylab/data/';
    end
    slash = '/';
elseif strcmp(archst, 'win32') || strcmp(archst, 'win64')
    if strcmp(getenv('username'),'SommerVD') || strcmp(getenv('username'),'LabV')
        directory = 'C:\Data\Recordings\';
    elseif strcmp(getenv('username'),'DangerZone')
        directory = 'E:\data\Recordings\';
    elseif strcmp(getenv('username'),'Radu')
        directory = 'E:\Spike_Sorting\';
    else
        directory = 'B:\data\Recordings\';
    end
    slash = '\';
end

%setting process directory
monkeydir= get(get(findobj('Tag','monkeyselect'),'SelectedObject'),'Tag');
if strcmp(monkeydir,'rigelselect')
    monknum=1;
elseif strcmp(monkeydir,'sixxselect')
    monknum=2;
elseif strcmp(monkeydir,'hildaselect')
    monknum=3;
end
dirlisting{1} = dir([directory,'processed',slash,'Rigel',slash]);%('B:\data\Recordings\processed\Rigel');
dirlisting{2} = dir([directory,'processed',slash,'Sixx',slash]);
dirlisting{3} = dir([directory,'processed',slash,'Hilda',slash]);

%%  add subject ID letter in front of file names for sessions >= 100
%   change hyphens into underscores
%   output unprocessed file list

rawdirs=[{[directory,'Rigel',slash]};{[directory,'Sixx',slash]};{[directory,'Hilda',slash]}];
idletters=['R';'S';'H'];
olddir=pwd; %keep current dir in memory

%preallocate
indfilenames=cell(length(rawdirs),1);
unprocfiles=cell(length(rawdirs),1);

for rwadirnum=1:length(rawdirs)
    rawdir=rawdirs{rwadirnum};
    idletter=idletters(rwadirnum);
    cd(rawdir); %move to raw files directory
    rawdirlisting=dir(rawdir);
    dirfileNames = {rawdirlisting.name};
    
    %add subject ID letter in front of file names
    noidfiles=regexpi(dirfileNames,'^\d+','match'); % output file names that start with digits
    noidindex=find(~cellfun(@isempty,noidfiles));
    if logical(sum(noidindex))
        % Loop through each
        for id = 1:length(noidindex)
            movefile(dirfileNames{noidindex(id)}, [idletter,dirfileNames{noidindex(id)}]);
        end
    end
    
    %change hyphen into underscores
    hyphenfiles=regexpi(dirfileNames,'^\w+-','match'); % output file names that start with digits
    hyphenindex=find(~cellfun(@isempty,hyphenfiles));
    if logical(sum(hyphenindex))
        % Loop through each
        for id = 1:length(hyphenindex)
            movefile(dirfileNames{hyphenindex(id)},...
                [dirfileNames{hyphenindex(id)}(1:length(hyphenfiles{hyphenindex(id)}{:})-1),'_',dirfileNames{hyphenindex(id)}(length(hyphenfiles{hyphenindex(id)}{:})+1:end)]);
        end
    end
    
    % refresh dirfileNames
    rawdirlisting=dir(rawdir);
    dirfileNames = {rawdirlisting.name};
    
    [rawfilenames,filematch]=regexpi(dirfileNames,'\w*A$','match'); % output file names that end with A
    rawfilenames=rawfilenames(~cellfun('isempty',filematch));
    rawfilenames=cellfun(@(x) x{:}, rawfilenames, 'UniformOutput', false);
    indfilenames{rwadirnum}=cellfun(@(x) x(1:end-1), rawfilenames, 'UniformOutput', false);
    
    cd(olddir); %go back to original dir
    
    % Order by date
    procdirlist=dirlisting{rwadirnum};
    filedates=cell2mat({procdirlist(:).datenum});
    [filedates,fdateidx] = sort(filedates,'descend');
    procdirlist = {procdirlist(:).name};
    procdirlist = procdirlist(fdateidx);
    procdirlist = procdirlist(~cellfun('isempty',strfind(procdirlist,'mat')));
    procdirlist = procdirlist(cellfun('isempty',strfind(procdirlist,'myBreakpoints')));
    procdirlist = cellfun(@(x) x(1:end-4), procdirlist, 'UniformOutput', false);
    dirlisting{rwadirnum}=procdirlist;
    if sum(~ismember(indfilenames{rwadirnum},procdirlist))
        % beware if length of ismember is 1, the ~ will make a null
        % subscript ... Shouldn't happen.
        unprocfiles{rwadirnum}=indfilenames{rwadirnum}([~ismember(indfilenames{rwadirnum},procdirlist)]);
    end
end
set(hObject,'string',dirlisting{monknum});

% --- Executes on button press in LoadFile.
function LoadFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in aligntimepanel.
function aligntimepanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in aligntimepanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
% if hObject==handles.rasterreplot
%     set(eventdata.OldValue, 'BackgroundColor', [0.99 0.92 0.8]);
%     set(eventdata.NewValue, 'BackgroundColor', [0.93 0.84 0.84]);
% else
set(eventdata.OldValue, 'BackgroundColor', [0.99 0.92 0.8]);
set(eventdata.NewValue, 'BackgroundColor', [0.73 0.83 0.96]);
%     set(handles.rasterreplot, 'BackgroundColor', [0.93 0.84 0.84]);
% end
% for replot: get selectd file's name
% listboxH = findobj('Tag','displaymfiles');
% lbindex_selected = get(listboxH,'Value');
% lblist = get(listboxH,'String');
% lbitem_selected = lblist{lbindex_selected}; % Convert from cell array to string

% --- Executes when selected object is changed in aligntimepanel.
function secaligntimepanel_SelectionChangeFcn(hObject, eventdata, handles)
% if eventdata.NewValue==eventdata.OldValue
%     set(eventdata.OldValue, 'BackgroundColor', [0.99 0.92 0.8]);
%     set(eventdata.OldValue, 'Value', [0.0]);
% else
set(eventdata.OldValue, 'BackgroundColor', [0.99 0.92 0.8]);
set(eventdata.NewValue, 'BackgroundColor', [0.73 0.83 0.96]);
% end

function msbefore_Callback(hObject, eventdata, handles)
% hObject    handle to msbefore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of msbefore as text
%        str2double(get(hObject,'String')) returns contents of msbefore as a double


% --- Executes during object creation, after setting all properties.
function msbefore_CreateFcn(hObject, eventdata, handles)
% hObject    handle to msbefore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function msafter_Callback(hObject, eventdata, handles)
% hObject    handle to msafter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of msafter as text
%        str2double(get(hObject,'String')) returns contents of msafter as a double


% --- Executes during object creation, after setting all properties.
function msafter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to msafter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function binwidth_Callback(hObject, eventdata, handles)
% hObject    handle to binwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binwidth as text
%        str2double(get(hObject,'String')) returns contents of binwidth as a double

% --- Executes during object creation, after setting all properties.
function binwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sigma_Callback(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma as text
%        str2double(get(hObject,'String')) returns contents of sigma as a double

% --- Executes during object creation, after setting all properties.
function sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in alignspececodes.
function alignspececodes_Callback(hObject, eventdata, handles)
% hObject    handle to alignspececodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns alignspececodes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from alignspececodes

% --- Executes during object creation, after setting all properties.
function alignspececodes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alignspececodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function binwidthval_Callback(hObject, eventdata, handles)
% hObject    handle to binwidthval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binwidthval as text
%        str2double(get(hObject,'String')) returns contents of binwidthval as a double

% --- Executes during object creation, after setting all properties.
function binwidthval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binwidthval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sigmaval_Callback(hObject, eventdata, handles)
% hObject    handle to sigmaval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigmaval as text
%        str2double(get(hObject,'String')) returns contents of sigmaval as a double

% --- Executes during object creation, after setting all properties.
function sigmaval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigmaval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in greycue.
function greycue_Callback(hObject, eventdata, handles)
% hObject    handle to greycue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of greycue

% --- Executes on button press in greyemvt.
function greyemvt_Callback(hObject, eventdata, handles)
% hObject    handle to greyemvt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of greyemvt

% --- Executes on button press in greyfix.
function greyfix_Callback(hObject, eventdata, handles)
% hObject    handle to greyfix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of greyfix

% --------------------------------------------------------------------
function optiloc_menu_Callback(hObject, eventdata, handles)
% hObject    handle to optiloc_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in disprastsdf.
function disprastsdf_Callback(hObject, eventdata, handles)
% hObject    handle to disprastsdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in dispeyevel.
function dispeyevel_Callback(hObject, eventdata, handles)
% hObject    handle to dispeyevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function outliertrialnb_Callback(hObject, eventdata, handles)
% hObject    handle to outliertrialnb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outliertrialnb as text
%        str2double(get(hObject,'String')) returns contents of outliertrialnb as a double

% --- Executes during object creation, after setting all properties.
function outliertrialnb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outliertrialnb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in marktrialg.
function marktrialg_Callback(hObject, eventdata, handles)
% hObject    handle to marktrialg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
recfile=matfile(get(findobj('Tag','filenamedisplay'),'String'));
recfile.Properties.Writable = true;
recfile.allbad(1,str2num(get(findobj('Tag','trialnumbdisplay'),'String')))=0;
rdd_trialdata(get(findobj('Tag','filenamedisplay'),'String'),...
    str2num(get(findobj('Tag','trialnumbdisplay'),'String')),1);

% --- Executes on button press in marktrialw.
function marktrialw_Callback(hObject, eventdata, handles)
% hObject    handle to marktrialw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

recfile=matfile(get(findobj('Tag','filenamedisplay'),'String'));
recfile.Properties.Writable = true;
recfile.allbad(1,str2num(get(findobj('Tag','trialnumbdisplay'),'String')))=1;
rdd_trialdata(get(findobj('Tag','filenamedisplay'),'String'),...
    str2num(get(findobj('Tag','trialnumbdisplay'),'String')),1);

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes when selected object is changed in monkeyselect.
function monkeyselect_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in monkeyselect
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

% find selected display file button
dfbth=findobj('Tag',get(get(findobj('Tag','displayfbox'),'SelectedObject'),'tag'));
% adjusting eventdata, even though it's not used
dfbted=eventdata;
dfbted.OldValue=dfbth;
dfbted.NewValue=dfbth;

displayfbox_SelectionChangeFcn(dfbth, dfbted, handles);

% --- Executes on button press in sumplotrast.
function sumplotrast_Callback(hObject, eventdata, handles)
% hObject    handle to sumplotrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sumplotrast

% --- Executes on button press in sumplotsdf.
function sumplotsdf_Callback(hObject, eventdata, handles)
% hObject    handle to sumplotsdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sumplotsdf

% --- Executes on button press in sumploteyevel.
function sumploteyevel_Callback(hObject, eventdata, handles)
% hObject    handle to sumploteyevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sumploteyevel

% --- Executes on button press in plotsummary.
function plotsummary_Callback(hObject, eventdata, handles)
% hObject    handle to plotsummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename=get(findobj('Tag','filenamedisplay'),'String');
tasktype=get(findobj('Tag','taskdisplay'),'String');
dataaligned=guidata(findobj('Tag','exportdata'));
if strcmp(tasktype,'optiloc')
    SummaryPlot_ol(dataaligned,filename,tasktype);
else
    SummaryPlot(dataaligned,filename,tasktype);
end

% --- Executes on button press in rastersandsdf_tab.
function rastersandsdf_tab_Callback(hObject, eventdata, handles)
% hObject    handle to rastersandsdf_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(findobj('Tag','trialdatapanel'),'visible','off')
set(findobj('Tag','statisticspanel'),'visible','off')
set(findobj('Tag','rasterspanel'),'visible','on')

% --- Executes on button press in trialdata_tab.
function trialdata_tab_Callback(hObject, eventdata, handles)
% hObject    handle to trialdata_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(findobj('Tag','rasterspanel'),'visible','off')
set(findobj('Tag','statisticspanel'),'visible','off')
set(findobj('Tag','trialdatapanel'),'visible','on')

% --- Executes on button press in statistics_tab.
function statistics_tab_Callback(hObject, eventdata, handles)
% hObject    handle to statistics_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(findobj('Tag','rasterspanel'),'visible','off')
set(findobj('Tag','trialdatapanel'),'visible','off')
set(findobj('Tag','statisticspanel'),'visible','on')

% --- Executes during object creation, after setting all properties.
function monkeyselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to monkeyselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function sixxselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sixxselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes when selected object is changed in centralpaneldisp.
function centralpaneldisp_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in centralpaneldisp
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if eventdata.NewValue==findobj('Tag','rastersandsdf_tab')
    set(findobj('Tag','trialdatapanel'),'visible','off');
    set(findobj('Tag','statisticspanel'),'visible','off');
    set(findobj('Tag','rasterspanel'),'visible','on');
elseif eventdata.NewValue==findobj('Tag','trialdata_tab')
    set(findobj('Tag','rasterspanel'),'visible','off')
    set(findobj('Tag','statisticspanel'),'visible','off')
    set(findobj('Tag','trialdatapanel'),'visible','on')
elseif eventdata.NewValue==findobj('Tag','statistics_tab')
    set(findobj('Tag','rasterspanel'),'visible','off')
    set(findobj('Tag','trialdatapanel'),'visible','off')
    set(findobj('Tag','statisticspanel'),'visible','on')
end


% --- Executes on button press in unprocfilebutton.
function unprocfilebutton_Callback(hObject, eventdata, handles)
% hObject    handle to unprocfilebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global unprocfiles;

% find which type of file display
selfd=get(get(findobj('Tag','displayfbox'),'SelectedObject'),'tag');

% find which monkey selected
selmk=get(get(findobj('Tag','monkeyselect'),'SelectedObject'),'tag');

% call unprocessed files GUI
ProcUnproc(unprocfiles, selmk, selfd);



% --- Executes when selected object is changed in displayfbox.
function displayfbox_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in displayfbox
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global directory slash;

% set(eventdata.OldValue, 'BackgroundColor', [0.9608    0.9216    0.9216]);

if get(findobj('Tag','rigelselect'),'Value')
    dirlisting = dir([directory,'processed',slash,'Rigel',slash]); %('B:\data\Recordings\processed\Rigel');
elseif get(findobj('Tag','sixxselect'),'Value')
    dirlisting = dir([directory,'processed',slash,'Sixx',slash]); %('B:\data\Recordings\processed\Sixx');\
elseif get(findobj('Tag','hildaselect'),'Value')
    dirlisting = dir([directory,'processed',slash,'Hilda',slash]); %('B:\data\Recordings\processed\Sixx');
end
fileNames = {dirlisting.name};  % Put the file names in a cell array

if hObject==findobj('Tag','displayfbt_files')
    
    % Order by date
    filedates=cell2mat({dirlisting(:).datenum});
    [filedates,fdateidx] = sort(filedates,'descend');
    dirlisting = {dirlisting(:).name};
    dirlisting = dirlisting(fdateidx);
    dirlisting = dirlisting(~cellfun('isempty',strfind(dirlisting,'mat')));
    dirlisting = dirlisting(cellfun('isempty',strfind(dirlisting,'myBreakpoints')));
    dirlisting = cellfun(@(x) x(1:end-4), dirlisting, 'UniformOutput', false);
    set(findobj('Tag','displaymfiles'),'string',dirlisting);
    
elseif hObject==findobj('Tag','displayfbt_session')
    
    if get(findobj('Tag','rigelselect'),'Value')
        index = regexpi(fileNames,...              % Match a file name if it begins
            '^R\d+','match');           % with the letter 'R' followed by a set of digits 1 or larger
        inFiles = index(~cellfun(@isempty,index));  % Get the names of the matching files in a cell array
        sessionNumbers = cellfun(@(x) strrep(x, 'R', ' '), inFiles, 'UniformOutput', false);
    elseif get(findobj('Tag','sixxselect'),'Value')
        index = regexpi(fileNames,...              % Match a file name if it begins
            '^S\d+', 'match');           % with the letter 'S' followed by a set of digits 1 or larger
        inFiles = index(~cellfun(@isempty,index));  % Get the names of the matching files in a cell array
        sessionNumbers = cellfun(@(x) strrep(x, 'S', ' '), inFiles, 'UniformOutput', false);
    elseif get(findobj('Tag','hildaselect'),'Value')
        index = regexpi(fileNames,...              % Match a file name if it begins
            '^H\d+', 'match');           % with the letter 'S' followed by a set of digits 1 or larger
        inFiles = index(~cellfun(@isempty,index));  % Get the names of the matching files in a cell array
        sessionNumbers = cellfun(@(x) strrep(x, 'H', ' '), inFiles, 'UniformOutput', false);
    end
    
    if ~isempty(sessionNumbers)
        dispsession = cat(1,sessionNumbers{:});
        dispsession = unique(dispsession); % finds unique session numbers
        [~,sessionidx]=sort(str2double(dispsession),'descend');
        dispsession = dispsession(sessionidx); %sort cell arrays descending
        dispsession = strcat('Session', dispsession);
        set(findobj('Tag','displaymfiles'),'string', dispsession);
    else
        set(findobj('Tag','displaymfiles'),'string','');
    end
    
elseif hObject==findobj('Tag','displayfbt_grid')
    
    index = regexpi(fileNames,...              % Match a file name if it begins
        '[a-z]\d[a-z]\d','match');           % with the letter 'R' followed by a set of digits 1 or larger
    gridLocations = index(~cellfun(@isempty,index));  % Get the names of the matching files in a cell array
    
    if ~isempty(gridLocations)
        displocation = cat(1,gridLocations{:});
        displocation = unique(displocation); % finds unique session numbers
        [~,sessionidx]=sort(str2double(displocation),'descend');
        displocation = displocation(sessionidx); %sort cell arrays descending
        set(findobj('Tag','displaymfiles'),'string', displocation);
    else
        set(findobj('Tag','displaymfiles'),'string','');
    end
    
end


% --- Executes during object creation, after setting all properties.
function optiloc_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optiloc_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in optiloc_popup.
function optiloc_popup_Callback(hObject, eventdata, handles)
% no action to do.


% --- Executes during object creation, after setting all properties.
function hildaselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hildaselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in usespike2.
function usespike2_Callback(hObject, eventdata, handles)
% hObject    handle to usespike2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global replacespikes %directory slash
if get(hObject,'Value')
    replacespikes = 1;
    set(findobj('tag','whichclus'),'Enable','on')
else
    replacespikes = 0;
    set(findobj('tag','whichclus'),'Enable','off')
end

function whichclus_Callback(hObject, eventdata, handles)
% hObject    handle to whichclus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function whichclus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whichclus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function text27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in chanelspanel.
function chanelspanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in chanelspanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
