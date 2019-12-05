function varargout = Scanlist_Nu_1_0(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn', @Scanlist_Nu_1_0_OpeningFcn,'gui_OutputFcn',@Scanlist_Nu_1_0_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function Scanlist_Nu_1_0_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
H.run = 0;
guidata(hObject, H);

function varargout = Scanlist_Nu_1_0_OutputFcn(hObject, eventdata, H) 
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

FC1 = get(H.newprimary,'String'); %Primary
R33 = get(H.newsecondary,'String');; %Secondary
Sample = get(H.newname,'String');

if length(IN)-1 == 72
	set(H.num_unknowns, 'Value', 1)
elseif length(IN)-1 == 134
	set(H.num_unknowns, 'Value', 2)
elseif length(IN)-1 == 158
	set(H.num_unknowns, 'Value', 3)
elseif length(IN)-1 == 196
	set(H.num_unknowns, 'Value', 4)
elseif length(IN)-1 == 258
	set(H.num_unknowns, 'Value', 5)	
elseif length(IN)-1 == 320
	set(H.num_unknowns, 'Value', 6)	
elseif length(IN)-1 == 382
	set(H.num_unknowns, 'Value', 7)	
elseif length(IN)-1 == 444
	set(H.num_unknowns, 'Value', 8)	
elseif length(IN)-1 == 506
	set(H.num_unknowns, 'Value', 9)	
elseif length(IN)-1 == 568
	set(H.num_unknowns, 'Value', 10)	
elseif length(IN)-1 == 630
	set(H.num_unknowns, 'Value', 11)	
elseif length(IN)-1 == 692
	set(H.num_unknowns, 'Value', 12)	
elseif length(IN)-1 == 754
	set(H.num_unknowns, 'Value', 13)	
elseif length(IN)-1 == 816
	set(H.num_unknowns, 'Value', 14)	
elseif length(IN)-1 == 878
	set(H.num_unknowns, 'Value', 15)	
elseif length(IN)-1 == 940
	set(H.num_unknowns, 'Value', 16)	
elseif length(IN)-1 == 1002
	set(H.num_unknowns, 'Value', 17)	
elseif length(IN)-1 == 1064
	set(H.num_unknowns, 'Value', 18)	
elseif length(IN)-1 == 1126
	set(H.num_unknowns, 'Value', 19)	
elseif length(IN)-1 == 1188
	set(H.num_unknowns, 'Value', 20)
elseif length(IN)-1 == 1250
	set(H.num_unknowns, 'Value', 21)	
elseif length(IN)-1 == 1312
	set(H.num_unknowns, 'Value', 22)	
elseif length(IN)-1 == 1374
	set(H.num_unknowns, 'Value', 23)	
elseif length(IN)-1 == 1436
	set(H.num_unknowns, 'Value', 24)	
elseif length(IN)-1 == 1498
	set(H.num_unknowns, 'Value', 25)	
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

set(H.num_unknowns,'Enable', 'off')

if get(H.num_unknowns, 'Value') == 1 || get(H.num_unknowns, 'Value') == 2 || get(H.num_unknowns, 'Value') > 3

	for i = n+1:n+n/5+10
		S = strcat({'Spot'}, {' '}, num2str(i));
		Names(i,1) = strrep(Names(i,1), S, FC1);
	end

	for i = n+n/5+11:n+n/5+10+n/25 
		S = strcat({'Spot'}, {' '}, num2str(i));
		Names(i,1) = strrep(Names(i,1), S, R33);
	end
	
	for i = 1:n 
		S = strcat({'Spot'}, {' '}, num2str(i));
		Names(i,1) = strrep(Names(i,1), S, Sample);
	end
	
	Unknowns = Names(1:n); % 1:300 for 300
	FCs = Names(n+1:n+n/5+10); % 301:370 for 300
	R33s = Names(n+n/5+11:n+n/5+10+n/25); % 371:382 for 300

	for i = 1:n/5 %60 for 300
		OUT(i*6+5,1) = FCs(i+5,1);
		OUT(i*6:i*6+4,1) = Unknowns(((i-1)*5)+1:i*5,1);
	end

	for i = 1:n/50 %6 for 300
		OUT3(((i-1)*62)+8:((i-1)*62)+67,1) = OUT(((i-1)*60)+6:((i-1)*60)+65);
		OUT3(((i-1)*62)+6:((i-1)*62)+7) = R33s(i*2-1:i*2);
	end

	OUT3(1:5,1) = FCs(1:5,1);
	OUT3(length(OUT3)+1:length(OUT3)+5) = FCs(length(FCs)-4:length(FCs),1);

end

if get(H.num_unknowns, 'Value') == 3

	for i = 121:154
		S = strcat({'Spot'}, {' '}, num2str(i));
		Names(i,1) = strrep(Names(i,1), S, FC1);
	end

	for i = 155:158
		S = strcat({'Spot'}, {' '}, num2str(i));
		Names(i,1) = strrep(Names(i,1), S, R33);
	end
	
	for i = 1:n 
		S = strcat({'Spot'}, {' '}, num2str(i));
		Names(i,1) = strrep(Names(i,1), S, Sample);
	end
	
	Unknowns = Names(1:n); 
	FCs = Names(121:154); 
	R33s = Names(155:158);
	
	for i = 1:n/5 
		OUT(i*6+5,1) = FCs(i+5,1);
		OUT(i*6:i*6+4,1) = Unknowns(((i-1)*5)+1:i*5,1);
	end	
	
	for i = 1:2 
		OUT3(((i-1)*62)+8:((i-1)*62)+67,1) = OUT(((i-1)*60)+6:((i-1)*60)+65);
		OUT3(((i-1)*62)+6:((i-1)*62)+7) = R33s(i*2-1:i*2);
	end
	
	OUT3(1:5,1) = FCs(1:5,1);
	OUT3(130:153,1) = OUT(126:149,1);
	OUT3(length(OUT3)+1:length(OUT3)+5) = FCs(length(FCs)-4:length(FCs),1);

end

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
if ispc == 1
	dlmcell('C:\Users\NuLab2\Desktop\junk10.scancsv',OUT4)
elseif ismac == 1
	[file,path] = uiputfile('*.scancsv','Save file');
	dlmcell([path,file],OUT4)
end


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
