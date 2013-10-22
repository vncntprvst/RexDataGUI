function varargout = twoafc(varargin)
% TWOAFC MATLAB code for twoafc.fig
%      TWOAFC, by itself, creates a new TWOAFC or raises the existing
%      singleton*.
%
%      H = TWOAFC returns the handle to a new TWOAFC or the handle to
%      the existing singleton*.
%
%      TWOAFC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TWOAFC.M with the given input arguments.
%
%      TWOAFC('Property','Value',...) creates a new TWOAFC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before twoafc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to twoafc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help twoafc

% Last Modified by GUIDE v2.5 21-Oct-2013 13:36:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @twoafc_OpeningFcn, ...
                   'gui_OutputFcn',  @twoafc_OutputFcn, ...
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

% --- Executes just before twoafc is made visible.
function twoafc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to twoafc (see VARARGIN)

% Choose default command line output for twoafc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes twoafc wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = twoafc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in whichdirs.
function whichdirs_Callback(hObject, eventdata, handles)
% hObject    handle to whichdirs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns whichdirs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from whichdirs
global sides
contents1 = cellstr(get(hObject,'String'));
sides = find(ismember(contents1, contents1{get(hObject,'Value')}));


% --- Executes during object creation, after setting all properties.
function whichdirs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whichdirs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global sides
sides = 1;


% --- Executes on button press in savefig.
function savefig_Callback(hObject, eventdata, handles)
% hObject    handle to savefig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of savefig

% --- Executes on button press in savesdfs.
function savesdfs_Callback(hObject, eventdata, handles)
% hObject    handle to savesdfs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of savesdfs

% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global output
global plots
global sides
global aligncd
global contents2
output.savfig = get(findobj('Tag','savefig'),'Value');
output.savsdf = get(findobj('Tag','savesdfs'), 'Value');
output.plots = plots;
output.sides = sides;
output.aligncode = aligncd;
output.allalign = contents2;
uiresume
close(handles.figure1);

% --- Executes on button press in ssall.
function ssall_Callback(hObject, eventdata, handles)
% hObject    handle to ssall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ssall
global plots
plots(1) = get(hObject,'Value');

% --- Executes on button press in allr0.
function allr0_Callback(hObject, eventdata, handles)
% hObject    handle to allr0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of allr0
global plots
plots(3) = get(hObject,'Value');

% --- Executes on button press in ssr0.
function ssr0_Callback(hObject, eventdata, handles)
% hObject    handle to ssr0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ssr0
global plots
plots(5) = get(hObject,'Value');

% --- Executes on button press in insr0.
function insr0_Callback(hObject, eventdata, handles)
% hObject    handle to insr0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of insr0
global plots
plots(7) = get(hObject,'Value');

% --- Executes on button press in ssr1.
function ssr1_Callback(hObject, eventdata, handles)
% hObject    handle to ssr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ssr1
global plots
plots(6) = get(hObject,'Value');

% --- Executes on button press in insall.
function insall_Callback(hObject, eventdata, handles)
% hObject    handle to insall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of insall
global plots
plots(2) = get(hObject,'Value');

% --- Executes on button press in insr1.
function insr1_Callback(hObject, eventdata, handles)
% hObject    handle to insr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of insr1
global plots
plots(8) = get(hObject,'Value');

% --- Executes on button press in allr1.
function allr1_Callback(hObject, eventdata, handles)
% hObject    handle to allr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of allr1
global plots
plots(4) = get(hObject,'Value');

% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global plots
plots = zeros(8,1);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
global aligncd
global contents2
contents2 = cellstr(get(hObject,'String'));
align = find(ismember(contents2, contents2{get(hObject,'Value')}));
codelist = [425 465 505 585 605 645 103];
aligncd = codelist(align);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
