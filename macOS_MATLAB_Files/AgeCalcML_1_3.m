function varargout = AgeCalcML_1_3(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@AgeCalcML_1_3_OpeningFcn,'gui_OutputFcn',...
	@AgeCalcML_1_3_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function AgeCalcML_1_3_OpeningFcn(hObject, eventdata, H, varargin)
imshow('splashs_eQh_icon.ico', 'Parent', H.axes1);
H.output = hObject;
guidata(hObject, H);

function varargout = AgeCalcML_1_3_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;

function nu_upb_Callback(hObject, eventdata, H)
AgeCalcML_Nu_1_6

function nu_upb_tra_Callback(hObject, eventdata, H)
AgeCalcML_Nu_TRA_1_22

function nu_hf_Callback(hObject, eventdata, H)
AgeCalcML_Nu_Hf_1_5

function e2_upb_Callback(hObject, eventdata, H)
AgeCalcML_E2_1_14

function e2_tree_Callback(hObject, eventdata, H)
AgeCalcML_E2_TREE_1_2

function pushbutton46_Callback(hObject, eventdata, H)
AcquisitionTools_1_0

function analysistools_Callback(hObject, eventdata, H)
AnalysisTools_1_0
