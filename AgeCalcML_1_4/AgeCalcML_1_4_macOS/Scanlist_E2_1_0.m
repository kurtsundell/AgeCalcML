function varargout = Scanlist_E2_1_0(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn', @Scanlist_E2_1_0_OpeningFcn,'gui_OutputFcn',@Scanlist_E2_1_0_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function Scanlist_E2_1_0_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
H.run = 0;
guidata(hObject, H);

function varargout = Scanlist_E2_1_0_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;

function loadscancsv_Callback(hObject, eventdata, H)
[file,path,indx] = uigetfile({'*.scancsv'},'Select a File');
H.fullpathname_names = [path,file];
set(H.filepath, 'String', H.fullpathname_names); %show path name
guidata(hObject, H);
run(hObject, eventdata, H)

function run(hObject, eventdata, H)

Names = importdata(H.fullpathname_names);
IN = Names;
Names = Names(2:end,1);
set(H.listbox1,'String',IN)

FC1 = 'FC1'; %Primary
SLM = 'SLM'; %Secondary
R33 = 'R33'; %Tertiary
Sample = get(H.newname,'String');

for i = 1:36 
	S = strcat({'Spot'}, {' '}, num2str(i));
	Names(i,1) = strrep(Names(i,1), S, FC1);
end

for i = 37:72
	S = strcat({'Spot'}, {' '}, num2str(i));
	Names(i,1) = strrep(Names(i,1), S, SLM);
end

for i = 73:82
	S = strcat({'Spot'}, {' '}, num2str(i));
	Names(i,1) = strrep(Names(i,1), S, R33);
end

for i = 83:397
	S = strcat({'Spot'}, {' '}, num2str(i));
	Names(i,1) = strrep(Names(i,1), S, strcat(Sample, {' '}, num2str(i-82)));
end

FCs_tmp = Names(1:36);
SLMs_tmp = Names(37:72);
R33s_tmp = Names(73:82);
Samples = Names(83:397);

[r c] = size(FCs_tmp);
shuffledRow = randperm(r);
FCs = FCs_tmp(shuffledRow, :);
	
[r2 c2] = size(SLMs_tmp);
shuffledRow2 = randperm(r2);
SLMs = SLMs_tmp(shuffledRow2, :);

[r3 c3] = size(R33s_tmp);
shuffledRow3 = randperm(r3);
R33s = R33s_tmp(shuffledRow3, :);

for i = 1:3 
	OUT(i*2-1,1) = FCs(i,1);
end
for i = 1:2
	OUT(i*2-1+384,1) = FCs(i+3,1);
end
for i = 1:31 
	OUT(i*12,1) = FCs(i+5,1);
end

for i = 1:3 
	OUT(i*2,1) = SLMs(i,1);
end
for i = 1:2
	OUT(i*2+382,1) = SLMs(i+3,1);
end	
for i = 1:31 
	OUT((i-1)*12+18,1) = SLMs(i+5,1);
end

for i = 1:63 
	OUT((i-1)*6+7:(i-1)*6+11,1) = Samples((i-1)*5+1:i*5,1);
end

for i = 1:10 
	OUT2((i-1)*37+42,1) = R33s(i,1);
end
for i = 1:8 
	OUT((i-1)*6+7:(i-1)*6+11,1) = Samples((i-1)*5+1:i*5,1);
end

OUT2(1:41,1) = OUT(1:41,1);
OUT2(43:78,1) = OUT(42:77,1);
OUT2(80:115,1) = OUT(78:113,1);
OUT2(117:152,1) = OUT(114:149,1);
OUT2(154:189,1) = OUT(150:185,1);
OUT2(191:226,1) = OUT(186:221,1);
OUT2(228:263,1) = OUT(222:257,1);
OUT2(265:300,1) = OUT(258:293,1);
OUT2(302:337,1) = OUT(294:329,1);
OUT2(339:374,1) = OUT(330:365,1);
OUT2(376:397,1) = OUT(366:387,1);

OUT3 = OUT2;
OUT3(3,1) = OUT2(375,1);
OUT3(375,1) = OUT2(3,1);

OUT4(2:length(OUT3(:,1))+1,1) = OUT3;
OUT4(1,1) = IN(1,1);

set(H.listbox2,'String',OUT4)

H.OUT4 = OUT4;
H.run = 1;
guidata(hObject, H);

function listbox1_Callback(hObject, eventdata, H)
function listbox2_Callback(hObject, eventdata, H)
function popupmenu2_Callback(hObject, eventdata, H)
function savefile_Callback(hObject, eventdata, H)
OUT4 = H.OUT4;
[file,path] = uiputfile('*.scancsv','Save file');
dlmcell([path,file],OUT4)


function num_unknowns_Callback(hObject, eventdata, H)
if H.run == 1
	run(hObject, eventdata, H)
end

if get(H.num_unknowns, 'Value') == 1
	n = 50;
	n_p = n/5+10;
	n_s = n/25;
	n_all = n + n_p + n_s;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)
elseif get(H.num_unknowns, 'Value') == 2
	n = 100;
	n_p = n/5+10;
	n_s = n/25;
	n_all = n + n_p + n_s;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)	
elseif get(H.num_unknowns, 'Value') == 3
	n = 120;
	n_p = 34;
	n_s = 4;
	n_all = 158;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)
end
if get(H.num_unknowns, 'Value') > 3
	n = (get(H.num_unknowns,'Value')-1)*50;
	n_p = n/5+10;
	n_s = n/25;
	n_all = n + n_p + n_s;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)
end

function pushbutton3_Callback(hObject, eventdata, H)

set(H.filepath,'String','')
set(H.listbox1,'String',[])
set(H.listbox2,'String',[])
set(H.num_unknowns,'Enable', 'on')
H.run = 0;
guidata(hObject, H);

function newname_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function newprimary_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function newsecondary_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)
