function varargout = AcquisitionTools_1_0(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, 'gui_Singleton',  gui_Singleton, 'gui_OpeningFcn', @AcquisitionTools_1_0_OpeningFcn, 'gui_OutputFcn',  @AcquisitionTools_1_0_OutputFcn, 'gui_LayoutFcn',  [] , ...
                   'gui_Callback', []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function AcquisitionTools_1_0_OpeningFcn(hObject, eventdata, H, varargin)
imshow('splashs_eQh_icon.ico', 'Parent', H.axes1);
H.output = hObject;
guidata(hObject, H);

function varargout = AcquisitionTools_1_0_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;

function zirconspotfinder_Callback(hObject, eventdata, H)
ZirconSpotFinder_1_4

function scanlistnu_Callback(hObject, eventdata, H)
Scanlist_Nu_1_0

function scanliste2_Callback(hObject, eventdata, H)
Scanlist_E2_1_0
