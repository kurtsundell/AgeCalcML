function varargout = Scanlist_Nu_Large_n_Igneous(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn', @Scanlist_Nu_Large_n_Igneous_OpeningFcn,'gui_OutputFcn',@Scanlist_Nu_Large_n_Igneous_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function Scanlist_Nu_Large_n_Igneous_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
H.run = 0;
guidata(hObject, H);

function varargout = Scanlist_Nu_Large_n_Igneous_OutputFcn(hObject, eventdata, H) 
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

samplename = get(H.samplename,'String');
primary = get(H.primary,'String'); %Primary
secondary = get(H.secondary,'String'); %Secondary
tertiary = get(H.tertiary,'String');
quaternary = get(H.quaternary,'String'); 
quinary = get(H.quinary,'String');

for i = 1:100
	S = strcat({'Spot'}, {' '}, num2str(i));
	Names(i,1) = strrep(Names(i,1), S, strcat(samplename, {' '}, num2str(i)));
end

for i = 101:310
	S = strcat({'Spot'}, {' '}, num2str(i));
	Names(i,1) = strrep(Names(i,1), S, primary);
end

for i = 311:335
	S = strcat({'Spot'}, {' '}, num2str(i));
	Names(i,1) = strrep(Names(i,1), S, secondary);
end

for i = 336:360
	S = strcat({'Spot'}, {' '}, num2str(i));
	Names(i,1) = strrep(Names(i,1), S, tertiary);
end

for i = 361:385
	S = strcat({'Spot'}, {' '}, num2str(i));
	Names(i,1) = strrep(Names(i,1), S, quaternary);
end

for i = 386:410
	S = strcat({'Spot'}, {' '}, num2str(i));
	Names(i,1) = strrep(Names(i,1), S, quinary);
end

Unknowns = Names(1:100); 
primary_tmp = Names(101:310); 
secondary_tmp = Names(311:335);
tertiary_tmp = Names(336:360);
quaternary_tmp = Names(361:385);
quinary_tmp = Names(386:410);

[r1 c1] = size(primary_tmp);
shuffledRow1 = randperm(r1);
primary_Sh = primary_tmp(shuffledRow1, :);

[r2 c2] = size(secondary_tmp);
shuffledRow2 = randperm(r2);
secondary_Sh = secondary_tmp(shuffledRow2, :);

[r3 c3] = size(tertiary_tmp);
shuffledRow3 = randperm(r3);
tertiary_Sh = tertiary_tmp(shuffledRow3, :);

[r4 c4] = size(quaternary_tmp);
shuffledRow4 = randperm(r4);
quaternary_Sh = quaternary_tmp(shuffledRow4, :);

[r5 c5] = size(quinary_tmp);
shuffledRow5 = randperm(r5);
quinary_Sh = quinary_tmp(shuffledRow5, :);

for i = 1:100
	OUT((i*2)+(i-1)*2,1) = Unknowns(i,1);
end

for i = 1:201
	OUT(i*2-1,1) = primary_Sh(i,1);
end

for i = 1:25
	OUT((i-1)*16+4,1) = secondary_Sh(i,1);
end

for i = 1:25
	OUT((i-1)*16+8,1) = tertiary_Sh(i,1);
end

for i = 1:25
	OUT((i-1)*16+12,1) = quaternary_Sh(i,1);
end

for i = 1:25
	OUT((i-1)*16+16,1) = quinary_Sh(i,1);
end

OUT2(5:405,1) = OUT;
OUT2(1:4) = primary_Sh(202:205,1);
OUT2(406:410) = primary_Sh(206:210,1);

OUT4(2:length(OUT2(:,1))+1,1) = OUT2;
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

function samplename_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function primary_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function secondary_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function tertiary_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function quaternary_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function quinary_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)
