function varargout = ProcUnproc(varargin)
% PROCUNPROC MATLAB code for ProcUnproc.fig
%      PROCUNPROC, by itself, creates a new PROCUNPROC or raises the existing
%      singleton*.
%
%      H = PROCUNPROC returns the handle to a new PROCUNPROC or the handle to
%      the existing singleton*.
%
%      PROCUNPROC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCUNPROC.M with the given input arguments.
%
%      PROCUNPROC('Property','Value',...) creates a new PROCUNPROC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProcUnproc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProcUnproc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProcUnproc

% Last Modified by GUIDE v2.5 23-Aug-2012 17:55:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ProcUnproc_OpeningFcn, ...
    'gui_OutputFcn',  @ProcUnproc_OutputFcn, ...
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


% --- Executes just before ProcUnproc is made visible.
function ProcUnproc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProcUnproc (see VARARGIN)

% Choose default command line output for ProcUnproc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

unprocfiles=varargin{1};
selectedmk=varargin{2};
selectedfd=varargin{3};


if strcmp(selectedmk,'rigelselect')
    set(findobj('tag','procunproc_rigel'),'value',1);
    unprocfilelist=unprocfiles{1}';
elseif strcmp(selectedmk,'sixxselect')
    set(findobj('tag','procunproc_sixx'),'value',1);
    unprocfilelist=unprocfiles{2}';
elseif strcmp(selectedmk,'hildaselect')
    set(findobj('tag','procunproc_hilda'),'value',1);
    unprocfilelist=unprocfiles{3}';
end

if isempty(unprocfilelist)
    unprocfilelist={' '};
end

if strcmp(selectedfd,'displayfbt_files')
    set(findobj('tag','procunprocdf_files'),'value',1);
    set(findobj('tag','unproclist'),'string',unprocfilelist);
elseif strcmp(selectedfd,'displayfbt_session')
    set(findobj('tag','procunprocdf_sess'),'value',1);
    sessionnumb = regexpi(unprocfilelist,'^\w\d+', 'match');
    if ~isempty(sessionnumb{1})
        sessionnumb = cellfun(@(x) strrep(x, x{:}(1),' '), sessionnumb, 'UniformOutput', false);
        sesslist = cat(1,sessionnumb{:});
        sesslist = unique(sesslist); % finds unique session numbers
        [~,sessionlistidx]=sort(str2double(sesslist),'descend');
        sesslist = sesslist(sessionlistidx); %sort cell arrays descending
        sesslist = strcat('Session', sesslist);
    else
        sesslist='no unprocessed session';
    end
    set(findobj('tag','unproclist'),'string',sesslist);
else %default: files
    set(findobj('tag','procunprocdf_files'),'value',1);
    set(findobj('tag','unproclist'),'string',unprocfilelist);
end

% UIWAIT makes ProcUnproc wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProcUnproc_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in unproclist.
function unproclist_Callback(hObject, eventdata, handles)

if strcmp(get(gcf,'SelectionType'),'normal') %simple click, do nothing
    
elseif strcmp(get(gcf,'SelectionType'),'open') %double click, process this file or session
    processunproch=get(findobj('tag','processunproc'));
    processunproc_Callback(processunproch,eventdata, handles);
end

% --- Executes on button press in processunproc.
function processunproc_Callback(hObject, eventdata, handles)
global directory slash unprocfiles ;

% get list of selected files or session in the list
unproclisth=findobj('tag','unproclist');

currentuflist = cellstr(get(unproclisth,'String')); % returns file list as cell array
selectionnm = {currentuflist{get(unproclisth,'Value')}}; %returns selected items

% find which subject selected, and associated raw files directory
selectedmk=get(get(findobj('Tag','procunprocsubjpanel'),'SelectedObject'),'tag');

if strcmp(selectedmk,'procunproc_rigel')
    monkeydir = [directory,'Rigel',slash]; %'B:\data\Recordings\Rigel';
    monknum=1;
elseif strcmp(selectedmk,'procunproc_sixx')
    monkeydir = [directory,'Sixx',slash]; %'B:\data\Recordings\Sixx';
    monknum=2;
elseif strcmp(selectedmk,'procunproc_hilda')
    monkeydir = [directory,'Hilda',slash]; %'B:\data\Recordings\Sixx';
    monknum=3;
end
mrawdir=dir(monkeydir);
rawfilenames = {mrawdir.name};  % Put the file names in a cell array

if get(findobj('Tag','procunprocdf_sess'),'Value')
    % extracting session number
    if iscell(selectionnm)
        sessionNumber=regexpi(selectionnm,'\d+$', 'match');    
        allrftoproc=cell(length(sessionNumber),1);
            for sessnumnum=1:length(sessionNumber)
            rftoproc = regexp(rawfilenames, strcat('^\w',sessionNumber{sessnumnum}{:}),'match');
            rftoproc = rawfilenames(~cellfun(@isempty,rftoproc));  % Get the names of the matching files in a cell array
            rftoproc = regexprep(rftoproc, '(A$)|(E$)',''); %remove A and E from end of names
            rftoproc = unique(rftoproc);
            allrftoproc{sessnumnum}=rftoproc;
            end
        allrftoproc=horzcat(allrftoproc{:});
    else
        sessionNumber = selectionnm(9:end);
    end

else
    allrftoproc=selectionnm;
end

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
%exl.registerevent({'WorkbookBeforeClose',@close_event1})
Quit(exl);

for rftpnb = 1:length(allrftoproc) 
    if exist('log.txt')
        diarydata=fopen('log.txt','w+'); %clears previous diary
        fclose(diarydata);
    end
    diary('log.txt');
    procname=allrftoproc{rftpnb};
    try
        [success,~,rectask]=rex_process_inGUI(procname,monkeydir); %shouldn't need the rfpathname
        % outliers are stored in file now
    catch
        success=0;
        rectask='failed';
    end
    if success
        successtr=['file ',procname,' processed succesfully'];
        disp(successtr);
        
        if sum(ismember(unprocfiles{monknum},procname)) %some files from this session / grid may not have been processed
            if length(ismember(unprocfiles{monknum},procname))>1
                unprocfiles{monknum}=unprocfiles{monknum}(~ismember(unprocfiles{monknum},procname));
            else
                unprocfiles{monknum}={};
            end
        end
        
    else
        successtr=['processing aborted for file ',procname];
        disp(successtr);
    end
    diary off;
    % exporting data to Excel spreadsheet 
        %get data
        %subjectid=regexp(procname,'^\w','match');
        [fnnumbs,fnloc]=regexp(procname,'\d+','match');
        sessionid=fnnumbs{1};
        recdepth=fnnumbs{end};
        recnum=recdepth(end);
        recdepth(end)='0';
        recloc=regexp(procname(length(sessionid)+fnloc:end),'\w\d\w\d','match');
        recloc=recloc{1};
        
        diarydata=fopen('log.txt');
        diarycontent=fscanf(diarydata,'%c',inf);
        fclose(diarydata);
            if iscell(rectask)
                rectask=rectask{:};
            end
            
       %File name, Session Location, Depth, Recording #, Task, Lobule, Layer, Activity, Comparison, Processing notes, Checked   
        writeinfo={procname,sessionid,recloc,' ',recdepth,recnum,rectask,' ',' ',' ',' ',' ',' ',' ',' ',' ',diarycontent};
        %cd to directory and save data in spreadsheet
        cd(directory);
        [~,pfilelist] = xlsread('procdata.xlsx',monknum,['A2:A' num2str(numrows)]);
        if logical(sum(ismember(pfilelist,procname))) %pfile data already. Overwrite to avoid duplicates
            wline=find(ismember(pfilelist,procname))+1;
            numrows=numrows-1;
        else
            wline=numrows+rftpnb;
        end
        xlswrite('procdata.xlsx', writeinfo, monknum, sprintf('A%d',wline)); % first idea: str2num(sessionid)+recnum+1, but it can't work 
        %to make sure text is wrapped, see xlsalign
        
end

% --- Executes during object creation, after setting all properties.
function unproclist_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes when selected file display is changed in procunprocdfpanel.
function procunprocdfpanel_SelectionChangeFcn(hObject, eventdata, handles)
global unprocfiles;

selectedmk=get(get(findobj('Tag','procunprocsubjpanel'),'SelectedObject'),'tag');

if strcmp(selectedmk,'procunproc_rigel')
    unprocfilelist=unprocfiles{1}';
elseif strcmp(selectedmk,'procunproc_sixx')
    unprocfilelist=unprocfiles{2}';
elseif strcmp(selectedmk,'procunproc_hilda')
    unprocfilelist=unprocfiles{3}';
end

if isempty(unprocfilelist)
    unprocfilelist={' '};
end

if strcmp(get(hObject,'tag'),'procunprocdf_files')
    if strcmp(unprocfilelist,' ')
        unprocfilelist='no unprocessed files';
    end
    set(findobj('tag','unproclist'),'string',unprocfilelist);
elseif strcmp(get(hObject,'tag'),'procunprocdf_sess')
    sessionnumb = regexpi(unprocfilelist,'^\w\d+', 'match');
    sessionnumb = sessionnumb(~cellfun(@isempty,sessionnumb));
    if ~isempty(sessionnumb{1})
        sessionnumb = cellfun(@(x) strrep(x, x{:}(1),' '), sessionnumb, 'UniformOutput', false);
        sesslist = cat(1,sessionnumb{:});
        sesslist = unique(sesslist); % finds unique session numbers
        [~,sessionlistidx]=sort(str2double(sesslist),'descend');
        sesslist = sesslist(sessionlistidx); %sort cell arrays descending
        sesslist = strcat('Session', sesslist);
    else
        sesslist='no unprocessed session';
    end
    set(findobj('tag','unproclist'),'string',sesslist);
else %default: files
    set(findobj('tag','unproclist'),'string',unprocfilelist);
end


% --- Executes when selected subject (monkey) is changed in procunprocsubjpanel.
function procunprocsubjpanel_SelectionChangeFcn(hObject, eventdata, handles)

global directory slash unprocfiles;

if strcmp(get(hObject,'tag'),'procunproc_rigel')
    unprocfilelist=unprocfiles{1}';
elseif strcmp(get(hObject,'tag'),'procunproc_sixx')
    unprocfilelist=unprocfiles{2}';
elseif strcmp(get(hObject,'tag'),'procunproc_hilda')
    unprocfilelist=unprocfiles{3}';
end

if isempty(unprocfilelist)
    unprocfilelist={' '};
end

selectedfd=get(get(findobj('Tag','procunprocdfpanel'),'SelectedObject'),'tag');

if strcmp(selectedfd,'procunprocdf_files')
    if strcmp(unprocfilelist,' ')
        unprocfilelist='no unprocessed files';
    end
    set(findobj('tag','unproclist'),'string',unprocfilelist);
elseif strcmp(selectedfd,'procunprocdf_sess')
    sessionnumb = regexpi(unprocfilelist,'^\w\d+', 'match');
    if ~isempty(sessionnumb{1})
        sessionnumb = cellfun(@(x) strrep(x, x{:}(1),' '), sessionnumb, 'UniformOutput', false);
        sesslist = cat(1,sessionnumb{:});
        sesslist = unique(sesslist); % finds unique session numbers
        [~,sessionlistidx]=sort(str2double(sesslist),'descend');
        sesslist = sesslist(sessionlistidx); %sort cell arrays descending
        sesslist = strcat('Session', sesslist);
    else
        sesslist='no unprocessed session';
    end
    set(findobj('tag','unproclist'),'string',sesslist);
else %default: files
    set(findobj('tag','unproclist'),'string',unprocfilelist);
end

