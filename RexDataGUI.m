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

% Last Modified by GUIDE v2.5 27-Jun-2012 15:26:39

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

set(hObject,'DefaultTextFontName','Calibri'); %'Color',[0.9 .9 .8]

% use varargin to allow for direct input of the name of the file to be analyzed. 
% see http://www.mathworks.com/help/techdoc/creating_guis/f10-998580.html

% Update handles structure
guidata(hObject, handles);

% determines computer type
archst  = computer('arch');

global directory slash;

if strcmp(archst, 'maci64')
    name = getenv('USER'); 
    if strcmp(name, 'nick')
        directory = '/Users/nick/Dropbox/filesforNick/';
    elseif strcmp(name, 'Frank')
        directory = '/Users/Frank/Desktop/monkeylab/data/';
    end
    slash = '/';
elseif strcmp(archst, 'win32')
    directory = 'B:\data\Recordings\';
    slash = '\';
end


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
set(findobj('Tag','trialnumbdisplay'),'String',num2str(trialnumber));
rdd_trialdata(get(findobj('Tag','filenamedisplay'),'String'), trialnumber);

% --- Executes on button press in arrowforw.
function arrowforw_Callback(hObject, eventdata, handles)
% hObject    handle to arrowforw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
set(findobj('Tag','trialnumbdisplay'),'String',num2str(trialnumber));
rdd_trialdata(get(findobj('Tag','filenamedisplay'),'String'), trialnumber);


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
global directory slash
monkeydirselected=get(get(findobj('Tag','monkeyselect'),'SelectedObject'),'Tag'); 
if strcmp(monkeydirselected,'rigelselect')
    monkeydir = [directory,'Rigel',slash]; %'B:\data\Recordings\Rigel';
    procdir = [directory,'processed',slash,'Rigel',slash];
elseif strcmp(monkeydirselected,'sixxselect')
    monkeydir = [directory,'Sixx',slash]; %'B:\data\Recordings\Sixx';
    procdir = [directory,'processed',slash,'Sixx',slash];
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
        %then update the directory listing
  
        if strcmp(monkeydirselected,'rigelselect')
            dirlisting = dir([directory,'processed',slash,'Rigel',slash]); %('B:\data\Recordings\processed');
        elseif strcmp(monkeydirselected,'sixxselect')
            dirlisting = dir([directory,'processed',slash,'Sixx',slash]); %('B:\data\Recordings\processed');
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
            dirlisting(i)=mat2cell(thisfilename(1:end-4));
        end
        set(findobj('Tag','displaymfiles'),'String',dirlisting);

        
        if outliers
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


% --- Executes on selection (double click) of file in listbox.
% this the function that loads data,  puts name in UserData, and display
% first trial
function displaymfiles_Callback(hObject, eventdata, handles)
% hObject    handle to displaymfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(gcf,'SelectionType'),'normal') % if simple click, just higlight it, don't open
    %set uimenu content for following rightclick
    %SelectionType 'Alternate' (Right click) doesn't work with listbox
    %dispmenu=(get(hObject,'UIContextMenu'));
    listboxcontextmenu=uicontextmenu;
    processedrexfiles = cellstr(get(hObject,'String')); % returns displaymfiles contents as cell array
    rclk_filename = processedrexfiles{get(hObject,'Value')}; %returns selected item from displaymfiles
    filecontent=matfile(rclk_filename);
    filecodes=filecontent.allcodes;
    curtasktype=taskdetect(filecodes);
    if iscell(curtasktype)
    curtasktype=cell2mat(curtasktype);
    end
    disptask=uimenu('Parent',listboxcontextmenu,'Label',curtasktype);
    set(hObject,'UIContextMenu',listboxcontextmenu);
    
elseif strcmp(get(gcf,'SelectionType'),'open')
   
s=dbstatus; %little trick to prevent removal of breakpoints with clear
save('myBreakpoints.mat', 's');
clear functions;
load('myBreakpoints.mat');
dbstop(s);
    
processedrexfiles = cellstr(get(hObject,'String')); % returns displaymfiles contents as cell array
rdd_filename = processedrexfiles{get(hObject,'Value')};%returns selected item from displaymfiles
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

rdd_trialdata(rdd_filename, trialnumber, 1);
dataaligned=rdd_rasters_sdf(rdd_filename, trialdirs);
guidata(findobj('Tag','exportdata'),dataaligned);
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
dataaligned=rdd_rasters_sdf(rdd_filename, trialdirs);
guidata(findobj('Tag','exportdata'),dataaligned);

% --- Executes on button press in exportdata.
function exportdata_Callback(hObject, eventdata, handles)
% hObject    handle to exportdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataaligned=guidata(hObject);
savealignname=dataaligned.savealignname;
save(savealignname,'dataaligned','-v7.3');
%save some data to match with SH data analysis
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

rdd_filename=get(findobj('Tag','filenamedisplay'),'String');
recdata=matfile(rdd_filename);
%rex2sh=NaN(length(recdata.allbad),8);
rex2sh.goodtrials=~(recdata.allbad)';
rex2sh.starttrigs=recdata.alltrigin';
rex2sh.endtrigs=recdata.alltrigout';
rex2sh.rewtimes=recdata.allrew';
%prealloc
timefromtrig=nan(size(rex2sh.goodtrials));
timetotrig=nan(size(rex2sh.goodtrials));
trialdir=cell(size(rex2sh.goodtrials));
alignlabel=cell(size(rex2sh.goodtrials));
for i=1:length(dataaligned)
    timefromtrig((dataaligned(i).trials),1)=dataaligned(i).timefromtrig;
    timetotrig((dataaligned(i).trials),1)=dataaligned(i).timetotrig;
    trialdir(dataaligned(i).trials)={dataaligned(i).dir};
    alignlabel(dataaligned(i).trials)={dataaligned(i).alignlabel};
end
    rex2sh.align=alignlabel;
    rex2sh.dir=trialdir;
    rex2sh.timefromtrig=timefromtrig;
    rex2sh.timetotrig=timetotrig;
    
savealignsh=cat(2,savealignname,'_2SH');
save(savealignsh, '-struct','rex2sh','goodtrials','starttrigs',...
    'endtrigs','rewtimes','align','dir','timefromtrig','timetotrig','-v7.3');      

% --- Executes during object creation, after setting all properties.
function displaymfiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displaymfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global directory slash

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% monkeydir= get(get(findobj('Tag','monkeyselect'),'SelectedObject'),'Tag');
% if strcmp(monkeydir,'rigelselect')
dirlisting = dir([directory,'processed',slash,'Rigel',slash]);%('B:\data\Recordings\processed\Rigel');
% elseif strcmp(monkeydir,'sixxselect')
% dirlisting = dir('B:\data\Recordings\processed\Sixx');
% end
    % Order by date
    filedates=cell2mat({dirlisting(:).datenum});
    [filedates,fdateidx] = sort(filedates,'descend');
dirlisting = {dirlisting(:).name};
dirlisting=dirlisting(fdateidx);
dirlisting = dirlisting(~cellfun('isempty',strfind(dirlisting,'mat')));
for i=1:length(dirlisting)
    thisfilename=cell2mat(dirlisting(i));
    dirlisting(i)=mat2cell(thisfilename(1:end-4));
end
set(hObject,'string',dirlisting);



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
function analysis_menu_Callback(hObject, eventdata, handles)
% hObject    handle to analysis_menu (see GCBO)
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
global directory slash
if eventdata.NewValue==findobj('Tag','rigelselect')
    dirlisting = dir([directory,'processed',slash,'Rigel',slash]); %('B:\data\Recordings\processed\Rigel');
elseif eventdata.NewValue==findobj('Tag','sixxselect')
    dirlisting = dir([directory,'processed',slash,'Sixx',slash]); %('B:\data\Recordings\processed\Sixx');
end
    % Order by date
    filedates=cell2mat({dirlisting(:).datenum});
    [filedates,fdateidx] = sort(filedates,'descend');
dirlisting = {dirlisting(:).name};
dirlisting=dirlisting(fdateidx);
dirlisting = dirlisting(~cellfun('isempty',strfind(dirlisting,'mat')));
for i=1:length(dirlisting)
    thisfilename=cell2mat(dirlisting(i));
    dirlisting(i)=mat2cell(thisfilename(1:end-4));
end
set(findobj('Tag','displaymfiles'),'string',dirlisting);
    


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
SummaryPlot(dataaligned,filename,tasktype);


% --- Executes on button press in rastersandsdf_tab.
function rastersandsdf_tab_Callback(hObject, eventdata, handles)
% hObject    handle to rastersandsdf_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.trialdatapanel,'Visible','Off');
set(handles.rasterspanel,'Visible','On');


% --- Executes on button press in trialdata_tab.
function trialdata_tab_Callback(hObject, eventdata, handles)
% hObject    handle to trialdata_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.rasterspanel,'Visible','Off');
set(handles.trialdatapanel,'Visible','On');

% --- Executes on key press with focus on rastersandsdf_tab and none of its controls.
function rastersandsdf_tab_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to rastersandsdf_tab (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over rastersandsdf_tab.
function rastersandsdf_tab_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to rastersandsdf_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
