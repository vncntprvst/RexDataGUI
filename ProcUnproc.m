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

% Last Modified by GUIDE v2.5 23-Aug-2012 00:26:23

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

directory=varargin{1};
slash=varargin{2};

unprocfilelist=varargin{3};

set(findobj('tag','unproclist'),'string',unprocfilelist');

selectedfd=varargin{4};

if strcmp(selectedfd,'displayfbt_files')
    set(findobj('tag','procunprocdf_files'),'value',1);
elseif strcmp(selectedfd,'displayfbt_session')
    set(findobj('tag','procunprocdf_sess'),'value',1);
else %default: files
    set(findobj('tag','procunprocdf_files'),'value',1);
end

selectedmk=varargin{5};

if strcmp(selectedmk,'rigelselect')
    set(findobj('tag','procunproc_rigel'),'value',1);
elseif strcmp(selectedmk,'sixxselect')
    set(findobj('tag','procunproc_sixx'),'value',1);
elseif strcmp(selectedmk,'hildaselect')
    set(findobj('tag','procunproc_hilda'),'value',1);
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
% hObject    handle to unproclist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns unproclist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from unproclist


% --- Executes during object creation, after setting all properties.
function unproclist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unproclist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in processunproc.
function processunproc_Callback(hObject, eventdata, handles)
% hObject    handle to processunproc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
