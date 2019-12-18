function varargout = AgeCalcML(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@AgeCalcML_OpeningFcn,'gui_OutputFcn',...
	@AgeCalcML_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function AgeCalcML_OpeningFcn(hObject, eventdata, H, varargin)
imshow('splashs_eQh_icon.ico', 'Parent', H.axes1);
H.output = hObject;
guidata(hObject, H);

function varargout = AgeCalcML_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;

function nu_upb_Callback(hObject, eventdata, H)
AgeCalcML_Nu_IAM

function nu_upb_tra_Callback(hObject, eventdata, H)
AgeCalcML_Nu_TRA

function nu_hf_Callback(hObject, eventdata, H)
AgeCalcML_Nu_Hf

function e2_upb_Callback(hObject, eventdata, H)
AgeCalcML_E2

function e2_tree_Callback(hObject, eventdata, H)
AgeCalcML_E2_TREE

function scanlistnu_Callback(hObject, eventdata, H)
Scanlist_Nu

function scanliste2_Callback(hObject, eventdata, H)
Scanlist_E2

function zirconspotfinder_Callback(hObject, eventdata, H)
ZirconSpotFinder

function concordia_Callback(hObject, eventdata, H)
ConcordiaPlotter

function stackedconconcordias_Callback(hObject, eventdata, H)
StackedConcordiaPlotter

function agedistribution_Callback(hObject, eventdata, H)
DistributionPlotter

function stackedagedistributions_Callback(hObject, eventdata, H)
StackedDistributionPlotter

function weightedmean_Callback(hObject, eventdata, H)
WeightedMeanPlotter
