function varargout = HafniumPlotter_FAQs(varargin)
% HAFNIUMPLOTTER_FAQS MATLAB code for HafniumPlotter_FAQs.fig
%      HAFNIUMPLOTTER_FAQS, by itself, creates a new HAFNIUMPLOTTER_FAQS or raises the existing
%      singleton*.
%
%      H = HAFNIUMPLOTTER_FAQS returns the handle to a new HAFNIUMPLOTTER_FAQS or the handle to
%      the existing singleton*.
%
%      HAFNIUMPLOTTER_FAQS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HAFNIUMPLOTTER_FAQS.M with the given input arguments.
%
%      HAFNIUMPLOTTER_FAQS('Property','Value',...) creates a new HAFNIUMPLOTTER_FAQS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HafniumPlotter_FAQs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HafniumPlotter_FAQs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HafniumPlotter_FAQs

% Last Modified by GUIDE v2.5 10-Oct-2019 07:26:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HafniumPlotter_FAQs_OpeningFcn, ...
                   'gui_OutputFcn',  @HafniumPlotter_FAQs_OutputFcn, ...
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


% --- Executes just before HafniumPlotter_FAQs is made visible.
function HafniumPlotter_FAQs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HafniumPlotter_FAQs (see VARARGIN)

% Choose default command line output for HafniumPlotter_FAQs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HafniumPlotter_FAQs wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HafniumPlotter_FAQs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
