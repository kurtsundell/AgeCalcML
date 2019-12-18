%% AGECALCML_E2 MATLAB code for AgeCalcML_E2.fig %%

%% SET DEFAULT COMMAND LINE AND HANDLE STRUCTURE %%
function varargout = AgeCalcML_E2(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@AgeCalcML_E2_OpeningFcn,'gui_OutputFcn',@AgeCalcML_E2_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
gui_mainfcn(gui_State, varargin{:});
end

function AgeCalcML_E2_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
guidata(hObject, H);

function varargout = AgeCalcML_E2_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;
%set(H.FC_conc,'Value', 1)
%set(H.conc3D,'Value', 1)
set(H.conc1s,'Value', 1)
set(H.plot_fract_68,'Value',1)
H.reduced = 0;
set(H.AP,'visible','on');
H.export_fract = 0;
H.export_comp = 0;
H.export_dist = 0;
H.point = 0;
set(H.TREEcalib,'Visible','off')
set(H.TREEnorm,'Visible','off')
set(H.t91500,'Visible','off')
set(H.tMAD559,'Visible','off')
set(H.slider91500,'Visible','off')
set(H.sliderMAD559,'Visible','off')
set(H.calibslider,'Visible','off')
set(H.treeplotter,'Visible','off')
set(H.exporttree,'Visible','off')
set(H.tree,'Visible','off')
set(H.n_plotted,'String','?')

global use_avg_ACF use_235 use_FC_68 use_FC_67 use_SL_68 use_SL_67 use_R33_68 deadtime lowint_238 lin_238 lowint_206 lin_206 lin_232 
use_avg_ACF = 1;
use_235 = 0; 
use_FC_68 = 1; 
use_FC_67 = 1; 
use_SL_68 = 1; 
use_SL_67 = 1; 
use_R33_68 = 1; 
deadtime = 0;
lowint_238 = 0.5*100-50; %slider val
lin_238 = 0.5*100-50; %slider val
lowint_206 = 0.5*100-50; %slider val
lin_206 = 0.5*100-50; %slider val
lin_232 = 0.5*100-50; %slider val

guidata(hObject,H);

%% FILTERS %%
function bestage_cutoff_Callback(hObject, eventdata, H)
if H.reduced == 1
	reduce_data_Callback(hObject, eventdata, H)
end

function filter_err68_Callback(hObject, eventdata, H)
if H.reduced == 1
	reduce_data_Callback(hObject, eventdata, H)
end

function filter_err67_Callback(hObject, eventdata, H)
if H.reduced == 1
	reduce_data_Callback(hObject, eventdata, H)
end

function std_cutoff_Callback(hObject, eventdata, H)
if H.reduced == 1
	reduce_data_Callback(hObject, eventdata, H)
end

function filter_cutoff_Callback(hObject, eventdata, H)
if H.reduced == 1
	reduce_data_Callback(hObject, eventdata, H)
end

function filter_disc_Callback(hObject, eventdata, H)
if H.reduced == 1
	reduce_data_Callback(hObject, eventdata, H)
end

function filter_disc_rev_Callback(hObject, eventdata, H)
if H.reduced == 1
	reduce_data_Callback(hObject, eventdata, H)
end

function filter_204_Callback(hObject, eventdata, H)
if H.reduced == 1
	reduce_data_Callback(hObject, eventdata, H)
end

function browser_Callback(hObject, eventdata, H)
folder_name = uigetdir; %prompt browser and select folder
set(H.filepath, 'String', folder_name); %show path name
H.folder_name = folder_name;
guidata(hObject,H);

function auto_reduce_Callback(hObject, eventdata, H)

if get(H.auto_reduce,'Value') == 1
	set(H.browser,'Enable','off')
	set(H.reduce_data,'Enable','off')
	t = timer;
	set(t, 'ExecutionMode', 'fixedrate');
	set(t, 'Period', 60);
	t.TimerFcn = @(~,~) reduce_data_Callback(hObject, eventdata, H);
	start(t)
end

if get(H.auto_reduce,'Value') == 0
	set(H.browser,'Enable','on');
	set(H.reduce_data,'Enable','on');
	%t = H.t;
	%delete(t)
	timerout = timerfindall;
	delete(timerout);
	reduce_data_Callback(hObject, eventdata, H)
end

%% PUSHBUTTON REDUCE DATA %%
function reduce_data_Callback(hObject, eventdata, H)
H.reduced = 0;
guidata(hObject,H);
folder_name = H.folder_name;
files=dir([folder_name]); %map out the directory to that folder
cla(H.axes_session_fractionation,'reset');
cla(H.axes_comp,'reset');
cla(H.axes_current_intensities,'reset');
cla(H.axes_current_concordia,'reset');
cla(H.axes_distribution,'reset'); 
set(H.listbox1,'String','');
set(H.status,'String','');
set(H.standards_rejected,'String','0');
cla(H.TREEcalib,'reset');
cla(H.TREEnorm,'reset');

global use_avg_ACF use_235 use_FC_68 use_FC_67 use_SL_68 use_SL_67 use_R33_68 deadtime lowint_238 lin_238 lowint_206 lin_206 lin_232 numbers data sample2 factor64 rejectFC rejectSL rejectR33 ...
	odf68 bestage_cutoff filter_cutoff filter_err68 filter_err67 filter_disc filter_disc_rev filter_64  data_count STD1a_idx STD1b_idx STD2_idx sample_idx UPBdata UPB_pre

waitnum = 10;
h = waitbar(0,'Parsing the data. Please wait...');
%set(h, 'Position',[600 1500 300 50]);
waitbar(1/waitnum, h, 'Parsing the data. Please wait...');

for i = 1:size(files,1)
	filenames{i,1} = files(i).name;
end

for i = 1:size(filenames,1)
	if strcmp(filenames(i,1),'.') == 1
		filenames{i,1} = [];
	elseif strcmp(filenames(i,1),'..') == 1
		filenames{i,1} = [];
	end
end

filenames(all(cellfun('isempty',filenames),2),:) = [];

tmp = strfind(filenames(:,1), 'combined');
tmp1 = strfind(filenames(:,1), '.scancsv');

for i = 1:length(filenames)
	if isempty(tmp(~cellfun('isempty',tmp(i,1)))) == 0
		if ispc == 1
			fullpathname_data = char(strcat(folder_name, '\', filenames{i,1}));
		end
		if ismac == 1
			fullpathname_data = char(strcat(folder_name, '/', filenames{i,1}));
		end
	end
end

for i = 1:length(filenames)
	if isempty(tmp(~cellfun('isempty',tmp1(i,1)))) == 0
		if ispc == 1
			fullpathname_names = char(strcat(folder_name, '\', filenames{i,1}));
		end
		if ismac == 1
			fullpathname_names = char(strcat(folder_name, '/', filenames{i,1}));
		end
	end
end

clear tmp tmp1

if ispc == 1
    file_copy = strcat(fullpathname_data, '_copy.csv');
end
if ismac == 1
    file_copy = strcat(fullpathname_data, '_copy');
end
copyfile(fullpathname_data, file_copy, 'f');
d1 = [file_copy];
[numbers text, data] = xlsread(d1);
delete(d1);

%{
data = readtable(char(fullpathname_data));
text = data.Properties.VariableNames;
data = table2cell(data);
numbers = cell2num(data);
numbers = zeros(size(numbers));
for i = 1:length(numbers(:,1))
	for j = 1:length(numbers(1,:))
		if isstring(data{i,j}) == 0 && isnumeric(data{i,j}) == 1
			numbers(i,j) = data{i,j};	
		elseif ischar(data{i,j}) == 1 && isempty(str2num(data{i,j})) == 0
			numbers(i,j) = str2num(data{i,j});
		else
			numbers(i,j) = nan;
		end
	end
end
data(2:length(data(:,1))+1,:) = data;
data(1,:) = text;
%}



if length(numbers(1,:)) == 74
	TREE = 0;
	set(H.plot_fract_68,'Value',1)
	set(H.plot_fract_76,'Value',0)
	set(H.plot_fract_82,'Value',0)
	set(H.tree,'Value',0)
	set(H.TREEcalib,'Visible','off')
	set(H.TREEnorm,'Visible','off')
	set(H.export_fractionation,'Visible','on')
	set(H.export_fractionation,'Visible','on')
elseif length(numbers(1,:)) == 92
	TREE = 1;
	set(H.plot_fract_68,'Value',0)
	set(H.plot_fract_76,'Value',0)
	set(H.plot_fract_82,'Value',0)
	set(H.tree,'Value',1)
	set(H.axes_session_fractionation,'Visible','off')
	set(H.export_fractionation,'Visible','off')
end

folder_name = H.folder_name;
files=dir([folder_name]); %map out the directory to that folder

for i = 1:size(files,1)
	filenames{i,1} = files(i).name;
end

for i = 1:size(filenames,1)
	if strcmp(filenames(i,1),'.') == 1
		filenames{i,1} = [];
	elseif strcmp(filenames(i,1),'..') == 1
		filenames{i,1} = [];
	end
end

filenames(all(cellfun('isempty',filenames),2),:) = [];

tmp = strfind(filenames(:,1), 'combined');
tmp1 = strfind(filenames(:,1), '.scancsv');

for i = 1:length(filenames)
	if isempty(tmp(~cellfun('isempty',tmp(i,1)))) == 0
		if ispc == 1
			fullpathname_data = char(strcat(folder_name, '\', filenames{i,1}));
		end
		if ismac == 1
			fullpathname_data = char(strcat(folder_name, '/', filenames{i,1}));
		end
	end
end

for i = 1:length(filenames)
	if isempty(tmp(~cellfun('isempty',tmp1(i,1)))) == 0
		if ispc == 1
			fullpathname_names = char(strcat(folder_name, '\', filenames{i,1}));
		end
		if ismac == 1
			fullpathname_names = char(strcat(folder_name, '/', filenames{i,1}));
		end
	end
end

clear tmp tmp1
if ispc == 1
    file_copy = strcat(fullpathname_data, '_copy.csv');
end
if ismac == 1
    file_copy = strcat(fullpathname_data, '_copy');
end
copyfile(fullpathname_data, file_copy, 'f');


d1 = [file_copy];
[numbers text, data] = xlsread(d1);
delete(d1);


%{
Data_tmp = importdata(char(fullpathname_data),',',500000);
numbers = num2cell(Data_tmp.data);
numbers_tmp(2:length(numbers(:,1))+1,:) = numbers;
text = Data_tmp.textdata;
data = numbers_tmp;
for i = 1:length(text(:,1))
	for j = 1:length(text(1,:))
		if isempty(text(~cellfun('isempty',text(i,j)))) == 0
			data2(i,j) = text(i,j);
		else
			data(i,j) = numbers_tmp(i,j);
		end
	end
end
numbers = cell2num(numbers);
%}


if TREE == 1

	cla(H.TREEcalib,'reset');
	cla(H.TREEnorm,'reset');
	set(H.exporttree,'Visible','on')
	set(H.tree,'Visible','on')
	perc_MAD559 = get(H.calibslider,'Value');
	perc_91500 = 1 - get(H.calibslider,'Value');
	set(H.slider91500,'String',round(perc_91500*100,1))
	set(H.sliderMAD559,'String',round(perc_MAD559*100,1))

	Chapmanetal2016 = 1;
	HintonUpton1991 = 0;
	Nardietal2013 = 0;
	Sanoetal2002 = 0;
	Tayloretal2015 = 0;

	waitbar(1/waitnum, h, 'Reducing TREE! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

	DataLength = length(numbers(:,1));
	data_count = DataLength/73;

	Names = importdata(fullpathname_names);
	Names = Names(2:end,1);

	for i = 1:data_count
		name_tmp = char(Names(i,1));
		name_tmp_idx = strfind(name_tmp, '"');
		sample{i,:} = name_tmp(1,(name_tmp_idx(1,1)+1):(name_tmp_idx(1,2)-1));
		clear name_tmp name_tmp_idx
	end

	FC = 'FC';
	SLM = 'SLM';
	R33 = 'R33';
	s91500 = '91500';
	MAD559 = 'MAD559';
	NIST612 = 'NIST612';

	FC_idx = strfind(sample, FC);
	SLM_idx = strfind(sample, SLM);
	R33_idx = strfind(sample, R33);
	s91500_idx = strfind(sample, s91500);
	MAD559_idx = strfind(sample, MAD559);
	NIST612_idx = strfind(sample, NIST612);

	FC_idx = abs(cellfun(@isempty,FC_idx)-1);
	SLM_idx = abs(cellfun(@isempty,SLM_idx)-1);
	R33_idx = abs(cellfun(@isempty,R33_idx)-1);
	s91500_idx = abs(cellfun(@isempty,s91500_idx)-1);
	MAD559_idx = abs(cellfun(@isempty,MAD559_idx)-1);
	NIST612_idx = abs(cellfun(@isempty,NIST612_idx)-1);
	sample_idx = abs((FC_idx + SLM_idx + R33_idx + s91500_idx + MAD559_idx + NIST612_idx) - 1);

	Scan = numbers(:,1);
	Time = numbers(:,2) - numbers(1,2);
	ACFm = numbers(:,3)./64;

	ED = zeros(500,1);
	ED(501:DataLength+500,1) = ACFm;
	ED(length(ED)+1:length(ED)+1000,1) = 0;

	ACFavg = zeros(length(ED),1);
	for i = 501:DataLength
		ACFavg(i,1) = mean(nonzeros(ED(i-500:i+500,1)));
	end

	for i = DataLength+1:DataLength+500 %remove this once finished, it takes the mean of zeors at the last 500 
		ACFavg(i,1) = mean(ED(i-500:i+500,1));
	end

	ACFsel = ACFavg(501:500+DataLength); % set options later

	waitbar(2/waitnum, h, 'Reducing TREE! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

	M027 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,4)) == 1	
			tmp = regexp(data(i+1,4),'\d*','Match'); % remove * to not let it calculate ACF
			M027(i,1) = str2double(cell2mat(tmp{1,1}));
			clear tmp
		else
			M027(i,1) = numbers(i,4);
		end
	end

	M029 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,7)) == 1	
			M029(i,1) = numbers(i,8).*ACFsel(i,1);
		else
			M029(i,1) = numbers(i,7);
		end
	end

	M031 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,10)) == 1	
			tmp = regexp(data(i+1,10),'\d*','Match'); % remove * to not let it calculate ACF
			M031(i,1) = str2double(cell2mat(tmp{1,1}));
			clear tmp
		else
			M031(i,1) = numbers(i,10);
		end
	end

	M045 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,13)) == 1	
			M045(i,1) = numbers(i,14).*ACFsel(i,1);
		else
			M045(i,1) = numbers(i,13);
		end
	end

	waitbar(3/waitnum, h, 'Reducing TREE! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

	M049 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,16)) == 1	
			tmp = regexp(data(i+1,16),'\d*','Match'); % remove * to not let it calculate ACF
			M049(i,1) = str2double(cell2mat(tmp{1,1}));
			clear tmp
		else
			M049(i,1) = numbers(i,16);
		end
	end

	M089 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,19)) == 1	
			M089(i,1) = numbers(i,20).*ACFsel(i,1);
		else
			M089(i,1) = numbers(i,19);
		end
	end

	M093 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,22)) == 1	
			tmp = regexp(data(i+1,22),'\d*','Match'); % remove * to not let it calculate ACF
			M093(i,1) = str2double(cell2mat(tmp{1,1}));
			clear tmp
		else
			M093(i,1) = numbers(i,22);
		end
	end

	M139 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,25)) == 1	
			M139(i,1) = numbers(i,26).*ACFsel(i,1);
		else
			M139(i,1) = numbers(i,25);
		end
	end

	waitbar(4/waitnum, h, 'Reducing TREE! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

	M140 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,28)) == 1	
			M140(i,1) = numbers(i,29).*ACFsel(i,1);
		else
			M140(i,1) = numbers(i,28);
		end
	end

	M141 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,31)) == 1	
			M141(i,1) = numbers(i,32).*ACFsel(i,1);
		else
			M141(i,1) = numbers(i,31);
		end
	end

	M146 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,34)) == 1	
			M146(i,1) = numbers(i,35).*ACFsel(i,1);
		else
			M146(i,1) = numbers(i,34);
		end
	end

	M152 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,37)) == 1	
			M152(i,1) = numbers(i,38).*ACFsel(i,1);
		else
			M152(i,1) = numbers(i,37);
		end
	end

	M153 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,40)) == 1	
			M153(i,1) = numbers(i,41).*ACFsel(i,1);
		else
			M153(i,1) = numbers(i,40);
		end
	end

	M157 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,43)) == 1	
			M157(i,1) = numbers(i,44).*ACFsel(i,1);
		else
			M157(i,1) = numbers(i,43);
		end
	end

	M159 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,46)) == 1	
			M159(i,1) = numbers(i,47).*ACFsel(i,1);
		else
			M159(i,1) = numbers(i,46);
		end
	end

	M164 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,49)) == 1	
			M164(i,1) = numbers(i,50).*ACFsel(i,1);
		else
			M164(i,1) = numbers(i,49);
		end
	end

	M165 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,52)) == 1	
			M165(i,1) = numbers(i,53).*ACFsel(i,1);
		else
			M165(i,1) = numbers(i,52);
		end
	end

	M166 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,55)) == 1	
			M166(i,1) = numbers(i,56).*ACFsel(i,1);
		else
			M166(i,1) = numbers(i,55);
		end
	end

	M169 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,58)) == 1	
			M169(i,1) = numbers(i,59).*ACFsel(i,1);
		else
			M169(i,1) = numbers(i,58);
		end
	end

	waitbar(5/waitnum, h, 'Reducing TREE! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

	M174 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,61)) == 1	
			M174(i,1) = numbers(i,62).*ACFsel(i,1);
		else
			M174(i,1) = numbers(i,61);
		end
	end

	M175 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,64)) == 1	
			M175(i,1) = numbers(i,65).*ACFsel(i,1);
		else
			M175(i,1) = numbers(i,64);
		end
	end

	M177 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,67)) == 1	
			M177(i,1) = numbers(i,68).*ACFsel(i,1);
		else
			M177(i,1) = numbers(i,67);
		end
	end

	M181 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,70)) == 1	
			tmp = regexp(data(i+1,70),'\d*','Match'); % remove * to not let it calculate ACF
			M181(i,1) = str2double(cell2mat(tmp{1,1}));
			clear tmp
		else
			M181(i,1) = numbers(i,70);
		end
	end

	M202 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,73)) == 1	
			M202(i,1) = numbers(i,74).*ACFsel(i,1);
		else
			M202(i,1) = numbers(i,73);
		end
	end

	M204 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,76)) == 1	
			M204(i,1) = numbers(i,77).*ACFsel(i,1);
		else
			M204(i,1) = numbers(i,76);
		end
	end

	M206 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,79)) == 1	
			M206(i,1) = numbers(i,80).*ACFsel(i,1);
		else
			M206(i,1) = numbers(i,79);
		end
	end

	M207 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,82)) == 1	
			M207(i,1) = numbers(i,83).*ACFsel(i,1);
		else
			M207(i,1) = numbers(i,82);
		end
	end

	M208 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,85)) == 1	
			M208(i,1) = numbers(i,86).*ACFsel(i,1);
		else
			M208(i,1) = numbers(i,85);
		end
	end

	M232 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,88)) == 1	
			M232(i,1) = numbers(i,89).*ACFsel(i,1);
		else
			M232(i,1) = numbers(i,88);
		end
	end

	M235 = zeros(DataLength,1);
	for i = 1:DataLength
		if isnan(numbers(i,91)) == 1	
			M235(i,1) = numbers(i,92).*ACFsel(i,1);
		else
			M235(i,1) = numbers(i,91);
		end
	end

	M238 = M235*137.82;

	M_All = [M027,M029,M031,M045,M049,M089,M093,M139,M140,M141,M146,M152,M153,M157,M159,M164,M165,M166,M169,M174,M175,M177,M181,M202,M204,M206,M207,M208,M232,M232,M235,M238];

	waitbar(6/waitnum, h, 'Reducing TREE! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

	for i = 1:data_count
		M_Parsed(1:73,:,i) = M_All(73*(i-1)+1:73*i,:);
	end

	for i = 1:59
		for j = 1:32
			for k = 1:data_count
				M_BS(i,j,k) = M_Parsed(i+11,j,k) - mean(M_Parsed(1:9,j,k));
			end
		end
	end

	for j = 1:32
		for k = 1:data_count
			M_BS(60,j,k) = abs(mean(M_BS(3:22,j,k)));
		end
	end
	
	% Si normalization 
	for j = 1:32 
		for k = 1:data_count
			if NIST612_idx(k,1) == 1
				M_BS(61,j,k) = M_BS(60,j,k)/(M_BS(60,2,k)/16069);
			else
				M_BS(61,j,k) = M_BS(60,j,k)/(M_BS(60,2,k)/7178.6);
			end
		end
	end

	for i = 1:data_count
		if s91500_idx(i,1) == 1
			STD_91500(i,1:23) = M_BS(61,1:23,i);
			STD_91500(i,24) = M_BS(61,30,i);
			STD_91500(i,25) = M_BS(61,32,i);
		end
	end
	STD_91500( all(~STD_91500,2), : ) = [];
	STD_91500m = mean(STD_91500,1);

	for i = 1:data_count
		if NIST612_idx(i,1) == 1
			STD_NIST612(i,1:23) = M_BS(61,1:23,i);
			STD_NIST612(i,24) = M_BS(61,30,i);
			STD_NIST612(i,25) = M_BS(61,32,i);
		end
	end
	STD_NIST612( all(~STD_NIST612,2), : ) = [];
	STD_NIST612m = mean(STD_NIST612,1);

	for i = 1:data_count
		if MAD559_idx(i,1) == 1
			STD_MAD559(i,1:23) = M_BS(61,1:23,i);
			STD_MAD559(i,24) = M_BS(61,30,i);
			STD_MAD559(i,25) = M_BS(61,32,i);
		end
	end

	waitbar(9/waitnum, h, 'Reducing TREE! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

	STD_MAD559( all(~STD_MAD559,2), : ) = [];
	STD_MAD559m = mean(STD_MAD559,1);

	scalar = [1	0.04685	1	1	0.0541	1	1	0.9991	0.8845	1	0.172	0.2675	0.5219	0.1565	1	0.2826	1	0.33503	1	0.3183	0.9741	0.186	0.99988	0.9998	0.99274]; 
	chon_norm = [0.86	22.78	0.25	5.92	0.07	1.57	0.24	0.237	0.613	0.0928	0.457	0.148	0.0563	0.199	0.0361	0.246	0.0546	0.16	0.0247	0.161	0.0246	0.103	0.0136	0.029	0.0074];

	Coble91500 = [11	153230	13.9	1.17	4.73	145	2.03	0.015	2.6	0.019	0.23	0.38	0.2	1.8	0.83	10.4	4.6	24.1	6.1	61.4	14.2	6030	0.54	28.6	81.3];
	STD_91500c = Coble91500.*scalar./STD_91500m;

	Jochum = [10900	343000	46.6	39.9	44.0	38.3	38.9	36.0	38.4	37.9	35.5	37.7	35.6	37.3	37.6	35.5	38.3	38.0	36.8	39.2	37.0	36.7	37.6	37.8	37.4];
	STD_NIST612c = Jochum.*scalar./STD_NIST612m;

	CobleMAD559 = [5.4	153230	104	5.6	3.86	532	6.7	0.013	10.2	0.068	1.25	2.5	0.35	11.7	4.2	41.5	14.7	64.6	14.6	137	32.5	17350	1.8	483	3940];
	STD_MAD559c = CobleMAD559.*scalar./STD_MAD559m;

	for k = 1:data_count
		for j = 1:23
			ppm_Balance(k,j) = 0.0000001 + abs(perc_MAD559*M_BS(61,j,k)*STD_MAD559c(1,j) + perc_91500*M_BS(61,j,k)*STD_91500c(1,j));	
		end
		ppm_Balance(k,24) = 0.0000001 + abs(perc_MAD559*M_BS(61,30,k)*STD_MAD559c(1,24) + perc_91500*M_BS(61,30,k)*STD_91500c(1,24));	
		ppm_Balance(k,25) = 0.0000001 + abs(perc_MAD559*M_BS(61,32,k)*STD_MAD559c(1,25) + perc_91500*M_BS(61,32,k)*STD_91500c(1,25));
	end

	ppm_Average = ppm_Balance./scalar;
	ChonNorm_MS95 = ppm_Average./chon_norm;

	Results_ppm{data_count+1,25+1} = [];
	Results_ppm(1,1) = {'Sample'};
	Results_ppm(2:end,1) = sample;
	Isotopes = [{'Al'}	{'Si'}	{'P'}	{'Sc'}	{'Ti'}	{'Y'}	{'Nb'}	{'La'}	{'Ce'}	{'Pr'}	{'Nd'}	{'Sm'}	{'Eu'}	{'Gd'}	{'Tb'}	{'Dy'}	{'Ho'}	{'Er'}	{'Tm'}	{'Yb'}	{'Lu'}	{'Hf'}	{'Ta'}	{'Th'}	{'U'}];
	Results_ppm(1,2:end) = Isotopes;

	Results_ppm(2:end,2:end) = num2cell(ppm_Average);

	for k = 1:data_count
		for j = 1:25
			if  s91500_idx(k,1) == 1
				STD_91500p(k,j) = 100*(ppm_Average(k,j) - Coble91500(1,j)) / Coble91500(1,j);
				ChonNorm91500(k,j) = ChonNorm_MS95(k,j);
			end
			if  MAD559_idx(k,1) == 1
				STD_MAD559p(k,j) = 100*(ppm_Average(k,j) - CobleMAD559(1,j)) / CobleMAD559(1,j);
				ChonNormMAD559(k,j) = ChonNorm_MS95(k,j);
			end
			if  NIST612_idx(k,1) == 1
				STD_NIST612p(k,j) = 100*(ppm_Average(k,j) - Jochum(1,j)) / Jochum(1,j);
				ChonNormNIST612(k,j) = ChonNorm_MS95(k,j);
			end
			if  sample_idx(k,1) == 1
				ChonNormUnknownstmp(k,j) = ChonNorm_MS95(k,j);
			end

		end
	end

	STD_91500p( all(~STD_91500p,2), : ) = [];
	STD_91500pm = mean(STD_91500p,1);
	STD_91500ps = std(STD_91500p,1);

	STD_MAD559p( all(~STD_MAD559p,2), : ) = [];
	STD_MAD559pm = mean(STD_MAD559p,1);
	STD_MAD559ps = std(STD_MAD559p,1);

	STD_NIST612p( all(~STD_NIST612p,2), : ) = [];
	STD_NIST612pm = mean(STD_NIST612p,1);
	STD_NIST612ps = std(STD_NIST612p,1);

	ChonNorm91500( all(~ChonNorm91500,2), : ) = [];
	ChonNormMAD559( all(~ChonNormMAD559,2), : ) = [];
	ChonNormNIST612( all(~ChonNormNIST612,2), : ) = [];

	ChonNormUnknownstmp( all(~ChonNormUnknownstmp,2), : ) = [];

	% for Tree norm plot

	ChonNormAccepted91500 = Coble91500(1,8:21)./chon_norm(1,8:21);
	ChonNormAcceptedMAD559 = CobleMAD559(1,8:21)./chon_norm(1,8:21);
	ChonNormAcceptedNIST612 = Jochum(1,8:21)./chon_norm(1,8:21);
	ChonNormUnknowns = ChonNormUnknownstmp(:,8:21)./chon_norm(1,8:21);

	% for U-Pb

	% for listbox
	name_idx = length(sample); %automatically plot final sample run
	for i=1:length(sample)
		name_char(i,1)=(sample(i,1));
	end
	set(H.listbox1, 'String', name_char);
	set(H.listbox1,'Value',length(sample));

	H.ChonNormUnknowns = ChonNormUnknowns;
end














waitbar(2/waitnum, h, 'Reducing U-Th-Pb! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%


STD1a = 'FC';
STD1b = 'SL';
STD2 = 'R33';

bestage_cutoff = str2num(get(H.bestage_cutoff,'String'));
filter_cutoff = str2num(get(H.filter_cutoff,'String'));
filter_err68 = str2num(get(H.filter_err68,'String'));
filter_err67 = str2num(get(H.filter_err67,'String'));
filter_disc = str2num(get(H.filter_disc,'String'));
filter_disc_rev = str2num(get(H.filter_disc_rev,'String'));
filter_64 = str2num(get(H.filter_204,'String'));
factor64 = str2num(get(H.factor64,'String'));

% FC
STD_FC_68 = 0.18588;
STD_FC_67  = 13.132;
STD_FC_82  =0.05588;
STD_FC_64c = 16.882;
STD_FC_67c = 15.463;
STD_FC_68c = 36.533;
STD_FC_Uppm = 457;
STD_FC_Thppm = 271;
STD_FC_68age = 1099.017663;
STD_FC_67age = 1098.138545;

% SL
STD_SL_68 = 0.09042;
STD_SL_67  = 17.02;
STD_SL_82  = 0.0283;
STD_SL_64c = 17.827;
STD_SL_67c = 15.549;
STD_SL_68c = 37.576;
STD_SL_Uppm = 518;
STD_SL_Thppm = 118;
STD_SL_68age = 558.0205842;
STD_SL_67age = 557.0746252;

% R33
STD_R33_68 = 0.06721;
STD_R33_67  = 18.124;
STD_R33_82  = 0.02096;
STD_R33_64c = 18.073;
STD_R33_67c = 15.574;
STD_R33_68c = 37.856;
STD_R33_Uppm = 175;
STD_R33_Thppm = 125;
STD_R33_68age = 419.3248442;
STD_R33_67age = 418.3465252;

rejectFC = str2num(get(H.std_cutoff,'String'));
rejectSL = str2num(get(H.std_cutoff,'String'));
rejectR33 = str2num(get(H.std_cutoff,'String'));

lowint68 = (lowint_238 + 50)*0.1-5;
lin68 = (lin_238 + 50)*0.1-5;
lowint67 = -(lowint_206+50)*0.005+0.25;
lin67 = -(lin_206 + 50)*0.0005+0.025;
lin82 = lin_232*0.1;

odf68 = str2num(get(H.ODF_68,'String')); %overdispersion factor 6/8
odf67 = str2num(get(H.ODF_67,'String')); %overdispersion factor 6/7
odf82 = str2num(get(H.ODF_82,'String')); %overdispersion factor	8/2



%% FILE INPUT: READ AND REDUCE LASERCHRON E2 .txt FILES %%

DataLength = length(numbers(:,1));
data_count = DataLength/73;

Names = importdata(fullpathname_names);
Names = Names(2:end,1);

for i = 1:data_count
	name_tmp = char(Names(i,1));
	name_tmp_idx = strfind(name_tmp, '"');
	sample{i,:} = name_tmp(1,(name_tmp_idx(1,1)+1):(name_tmp_idx(1,2)-1));
	clear name_tmp name_tmp_idx
end

sample2 = sample;

STD1a_idx = strfind(sample, STD1a);
STD1b_idx = strfind(sample, STD1b);
STD2_idx = strfind(sample, STD2);
	if isempty(STD1a_idx(~cellfun('isempty',STD1a_idx))) == 1 || isempty(STD1b_idx(~cellfun('isempty',STD1b_idx))) == 1
	err_dlg=errordlg('Cound not find the two primary standards. Double check your primary standard selection!','Uh oh!');
	waitfor(err_dlg);
	end
STD1a_idx = abs(cellfun(@isempty,STD1a_idx)-1);
STD1b_idx = abs(cellfun(@isempty,STD1b_idx)-1);
STD2_idx = abs(cellfun(@isempty,STD2_idx)-1);


waitbar(3/waitnum, h, 'Reducing U-Th-Pb! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%


if TREE == 0

sample_idx = abs((STD1a_idx + STD1b_idx + STD2_idx) - 1);

set(H.tree,'Visible','off')

Scan = numbers(:,1);
Time = numbers(:,2) - numbers(1,2);
ACF = numbers(:,3)./64;



M202ap = zeros(DataLength,4);
for i = 1:DataLength
	for m = 1:4
		if isnan(numbers(i,m+7)) == 1
			M202ap(i,m) = 10000000000;
		elseif isnan(numbers(i,m+3)) == 1
			M202ap(i,m) = numbers(i,m+7)*ACF(i,1);
		elseif numbers(i,m+3) == 0 && numbers(i,m+3) > 2000
			M202ap(i,m) = numbers(i,m+7)*ACF(i,1);
		elseif isnan(numbers(i,m+3)) == 1
			tmp = regexp(data(i+1,m+3),'\d*','Match');
			M202ap(i,m) = str2double(cell2mat(tmp{1,1}));
			clear tmp
		else
			M202ap(i,m) = numbers(i,m+3);
		end
	end
end

M204ap = zeros(DataLength,4);
for i = 1:DataLength
	for m = 1:4
		if isnan(numbers(i,m+16)) == 1
			M204ap(i,m) = 10000000000;
		elseif isnan(numbers(i,m+12)) == 1
			M204ap(i,m) = numbers(i,m+16)*ACF(i,1);
		elseif numbers(i,m+12) == 0 && numbers(i,m+12) > 2000
			M204ap(i,m) = numbers(i,m+16)*ACF(i,1);
		elseif isnan(numbers(i,m+12)) == 1
			tmp = regexp(data(i+1,m+12),'\d*','Match');
			M204ap(i,m) = str2double(cell2mat(tmp{1,1}));
			clear tmp
		else
			M204ap(i,m) = numbers(i,m+12);
		end
	end
end

M206ap = zeros(DataLength,4);
for i = 1:DataLength
	for m = 1:4
		if isnan(numbers(i,m+21)) == 1 	
			M206ap(i,m) = numbers(i,m+25).*ACF(i,1);
		elseif numbers(i,m+21) == 0 && numbers(i,m+25) > 2000
			M206ap(i,m) = numbers(i,m+25).*ACF(i,1);
		else
			M206ap(i,m) = numbers(i,m+21);
		end
	end
end

M207ap = zeros(DataLength,4);
for i = 1:DataLength
	for m = 1:4
		if isnan(numbers(i,m+30)) == 1 	
			M207ap(i,m) = numbers(i,m+34).*ACF(i,1);
		elseif numbers(i,m+30) == 0 && numbers(i,m+34) > 2000
			M207ap(i,m) = numbers(i,m+34).*ACF(i,1);
		else
			M207ap(i,m) = numbers(i,m+30);
		end
	end
end

M208ap = zeros(DataLength,4);
for i = 1:DataLength
	for m = 1:4
		if isnan(numbers(i,m+39)) == 1 	
			M208ap(i,m) = numbers(i,m+43).*ACF(i,1);
		elseif numbers(i,m+39) == 0 && numbers(i,m+43) > 2000
			M208ap(i,m) = numbers(i,m+43).*ACF(i,1);
		else
			M208ap(i,m) = numbers(i,m+39);
		end
	end
end

M232ap = zeros(DataLength,4);
for i = 1:DataLength
	for m = 1:4
		if isnan(numbers(i,m+48)) == 1 	
			M232ap(i,m) = numbers(i,m+52).*ACF(i,1);
		elseif numbers(i,m+48) == 0 && numbers(i,m+52) > 2000
			M232ap(i,m) = numbers(i,m+52).*ACF(i,1);
		else
			M232ap(i,m) = numbers(i,m+48);
		end
	end
end

M235ap = zeros(DataLength,4);
for i = 1:DataLength
	for m = 1:4
		if isnan(numbers(i,m+57)) == 1 	
			M235ap(i,m) = numbers(i,m+61).*ACF(i,1);
		elseif numbers(i,m+57) == 0 && numbers(i,m+61) > 2000
			M235ap(i,m) = numbers(i,m+61).*ACF(i,1);
		else
			M235ap(i,m) = numbers(i,m+57);
		end
	end
end

M238ap = zeros(DataLength,4);
for i = 1:DataLength
	for m = 1:4
		if isnan(numbers(i,m+66)) == 1 	
			M238ap(i,m) = numbers(i,m+70).*ACF(i,1);
		elseif numbers(i,m+66) == 0 && numbers(i,m+70) > 10000
			M238ap(i,m) = numbers(i,m+70).*ACF(i,1);
		else
			M238ap(i,m) = numbers(i,m+66);
		end
	end
end

waitbar(4/waitnum, h, 'Reducing U-Th-Pb! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

ED = zeros(DataLength,1);
for i = 1:DataLength
	if max([numbers(i,4:end),M202ap(i,:), M204ap(i,:), M206ap(i,:), M207ap(i,:), M208ap(i,:), M232ap(i,:), M235ap(i,:), M238ap(i,:)]) > 1000000
		ED(i,1) = ACF(i,1);
	else
		ED(i,1) = 0;
	end
end
ED(DataLength+1:DataLength+1000,1) = 0;

ACFavg = zeros(DataLength,1);
for i = 501:DataLength
	ACFavg(i,1) = mean(nonzeros(ED(i-500:i+500,1)));
end
ACFavg(1:500) = ACFavg(801,1);

if use_avg_ACF == 1
	for i = 1:DataLength
		for m = 1:4
			if isnan(numbers(i,m+7)) == 1
				M202ap(i,m) = 10000000000;
			elseif isnan(numbers(i,m+3)) == 1
				M202ap(i,m) = numbers(i,m+7)*ACFavg(i,1);
			elseif numbers(i,m+3) == 0 && numbers(i,m+3) > 2000
				M202ap(i,m) = numbers(i,m+7)*ACFavg(i,1);
			elseif isnan(numbers(i,m+3)) == 1
				tmp = regexp(data(i+1,m+3),'\d*','Match');
				M202ap(i,m) = str2double(cell2mat(tmp{1,1}));
				clear tmp
			else
			M202ap(i,m) = numbers(i,m+3);
			end
		end
	end

	for i = 1:DataLength
		for m = 1:4
			if isnan(numbers(i,m+16)) == 1
				M204ap(i,m) = 10000000000;
			elseif isnan(numbers(i,m+12)) == 1
				M204ap(i,m) = numbers(i,m+16)*ACFavg(i,1);
			elseif numbers(i,m+12) == 0 && numbers(i,m+12) > 2000
				M204ap(i,m) = numbers(i,m+16)*ACFavg(i,1);
			elseif isnan(numbers(i,m+12)) == 1
				tmp = regexp(data(i+1,m+12),'\d*','Match');
				M204ap(i,m) = str2double(cell2mat(tmp{1,1}));
				clear tmp
			else
				M204ap(i,m) = numbers(i,m+12);
			end
		end
	end

	for i = 1:DataLength
		for m = 1:4
			if isnan(numbers(i,m+21)) == 1 	
				M206ap(i,m) = numbers(i,m+25).*ACFavg(i,1);
			elseif numbers(i,m+21) == 0 && numbers(i,m+25) > 2000
				M206ap(i,m) = numbers(i,m+25).*ACFavg(i,1);
			end
		end
	end
	
	for i = 1:DataLength
		for m = 1:4
			if isnan(numbers(i,m+30)) == 1 	
				M207ap(i,m) = numbers(i,m+34).*ACFavg(i,1);
			elseif numbers(i,m+30) == 0 && numbers(i,m+34) > 2000
				M207ap(i,m) = numbers(i,m+34).*ACFavg(i,1);
			end
		end
	end

	for i = 1:DataLength
		for m = 1:4
			if isnan(numbers(i,m+39)) == 1 	
				M208ap(i,m) = numbers(i,m+43).*ACFavg(i,1);
			elseif numbers(i,m+39) == 0 && numbers(i,m+43) > 2000
				M208ap(i,m) = numbers(i,m+43).*ACFavg(i,1);
			end
		end
	end

	for i = 1:DataLength
		for m = 1:4
			if isnan(numbers(i,m+48)) == 1 	
				M232ap(i,m) = numbers(i,m+52).*ACFavg(i,1);
			elseif numbers(i,m+48) == 0 && numbers(i,m+52) > 2000
				M232ap(i,m) = numbers(i,m+52).*ACFavg(i,1);
			end
		end
	end

	for i = 1:DataLength
		for m = 1:4
			if isnan(numbers(i,m+57)) == 1 	
				M235ap(i,m) = numbers(i,m+61).*ACFavg(i,1);
			elseif numbers(i,m+57) == 0 && numbers(i,m+61) > 2000
				M235ap(i,m) = numbers(i,m+61).*ACFavg(i,1);
			end
		end
	end

	for i = 1:DataLength
		for m = 1:4
			if isnan(numbers(i,m+66)) == 1 	
				M238ap(i,m) = numbers(i,m+70).*ACFavg(i,1);
			elseif numbers(i,m+66) == 0 && numbers(i,m+70) > 10000
				M238ap(i,m) = numbers(i,m+70).*ACFavg(i,1);
			end
		end
	end
end

for i = 1:DataLength
	if M202ap(i,1) == 0 || M202ap(i,2) == 0 || M202ap(i,3) == 0 || M202ap(i,4) == 0
		M202(i,1) = (sum(M202ap(i,:)) - max(M202ap(i,:)) - min(M202ap(i,:))) / 2;
	else
		M202(i,1) = mean(M202ap(i,:));
	end
end
	
for i = 1:DataLength
	if M204ap(i,1) == 0 || M204ap(i,2) == 0 || M204ap(i,3) == 0 || M204ap(i,4) == 0
		M204(i,1) = (sum(M204ap(i,:)) - max(M204ap(i,:)) - min(M204ap(i,:))) / 2;
	else
		M204(i,1) = mean(M204ap(i,:));
	end
end

for i = 1:DataLength
	if M206ap(i,1) == 0 || M206ap(i,2) == 0 || M206ap(i,3) == 0 || M206ap(i,4) == 0
		M206(i,1) = (sum(M206ap(i,:)) - max(M206ap(i,:)) - min(M206ap(i,:))) / 2;
	else
		M206(i,1) = mean(M206ap(i,:));
	end
end

for i = 1:DataLength
	if M207ap(i,1) == 0 || M207ap(i,2) == 0 || M207ap(i,3) == 0 || M207ap(i,4) == 0
		M207(i,1) = (sum(M207ap(i,:)) - max(M207ap(i,:)) - min(M207ap(i,:))) / 2;
	else
		M207(i,1) = mean(M207ap(i,:));
	end
end

for i = 1:DataLength
	if M208ap(i,1) == 0 || M208ap(i,2) == 0 || M208ap(i,3) == 0 || M208ap(i,4) == 0
		M208(i,1) = (sum(M208ap(i,:)) - max(M208ap(i,:)) - min(M208ap(i,:))) / 2;
	else
		M208(i,1) = mean(M208ap(i,:));
	end
end

for i = 1:DataLength
	if M232ap(i,1) == 0 || M232ap(i,2) == 0 || M232ap(i,3) == 0 || M232ap(i,4) == 0
		M232(i,1) = (sum(M232ap(i,:)) - max(M232ap(i,:)) - min(M232ap(i,:))) / 2;
	else
		M232(i,1) = mean(M232ap(i,:));
	end
end

for i = 1:DataLength
	if M235ap(i,1) == 0 || M235ap(i,2) == 0 || M235ap(i,3) == 0 || M235ap(i,4) == 0
		M235(i,1) = (sum(M235ap(i,:)) - max(M235ap(i,:)) - min(M235ap(i,:))) / 2;
	else
		M235(i,1) = mean(M235ap(i,:));
	end
end

for i = 1:DataLength
	if M238ap(i,1) == 0 || M238ap(i,2) == 0 || M238ap(i,3) == 0 || M238ap(i,4) == 0
		M238(i,1) = (sum(M238ap(i,:)) - max(M238ap(i,:)) - min(M238ap(i,:))) / 2;
	else
		M238(i,1) = mean(M238ap(i,:));
	end
end

for i = 1:data_count
	values_all(1:73,1:8,i) = [M202(((i-1)*73)+1:((i-1)*73)+73), M204(((i-1)*73)+1:((i-1)*73)+73), M206(((i-1)*73)+1:((i-1)*73)+73), M207(((i-1)*73)+1:((i-1)*73)+73), ...
		M208(((i-1)*73)+1:((i-1)*73)+73), M232(((i-1)*73)+1:((i-1)*73)+73), M235(((i-1)*73)+1:((i-1)*73)+73), M238(((i-1)*73)+1:((i-1)*73)+73)];
end


end



waitbar(5/waitnum, h, 'Reducing U-Th-Pb! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%


for i = 1:data_count
	values_all(1:73,1:8,i) = [M202(((i-1)*73)+1:((i-1)*73)+73), M204(((i-1)*73)+1:((i-1)*73)+73), M206(((i-1)*73)+1:((i-1)*73)+73), M207(((i-1)*73)+1:((i-1)*73)+73), ...
		M208(((i-1)*73)+1:((i-1)*73)+73), M232(((i-1)*73)+1:((i-1)*73)+73), M235(((i-1)*73)+1:((i-1)*73)+73), M238(((i-1)*73)+1:((i-1)*73)+73)];
end



UPBdata = zeros(57,15,data_count);
UPB_pre = zeros(data_count,8);

if TREE == 1
	for i = 1:data_count
		for j = 1:8
			UPB_pre(i,j) = (sum(values_all(1:9,j,i))-max(values_all(1:9,j,i))-min(values_all(1:9,j,i)))/8;
		end
	end
end

if TREE == 0
	for i = 1:data_count
		for j = 1:8
			UPB_pre(i,j) = (sum(values_all(6:15,j,i))-max(values_all(6:15,j,i))-min(values_all(6:15,j,i)))/8;
		end
	end
end

values_all(74:76,:,:) = 0; %add buffer zeros at end for second sliding window

for i = 1:data_count
	for j = 1:4
		UPBdata(j,1,i) = (mean(values_all(17:19+j,1,i))-UPB_pre(i,1))/4.3;
	end
end
for i = 1:data_count
	for j = 1:53
		UPBdata(j+4,1,i) = (mean(values_all(17+j:23+j,1,i))-UPB_pre(i,1))/4.3;
	end
end

for i = 1:data_count
	for j = 1:4
		UPBdata(j,2,i) = (mean(values_all(17:19+j,2,i))-UPB_pre(i,2)-UPBdata(j,1,i));
	end
end
for i = 1:data_count
	for j = 1:53
		UPBdata(j+4,2,i) = (mean(values_all(17+j:23+j,2,i))-UPB_pre(i,2)-UPBdata(j+4,1,i));
	end
end

for i = 1:data_count
	for j = 1:57
		UPBdata(j,3,i) = (values_all(j+16,3,i)-UPB_pre(i,3))/(1-(values_all(j+16,3,i)-UPB_pre(i,3))*deadtime/1000000000);
		UPBdata(j,4,i) = (values_all(j+16,4,i)-UPB_pre(i,4))*(1+lowint67*exp(-1*(values_all(j+16,4,i)-UPB_pre(i,4))/10000) + lin67*(values_all(j+16,4,i)-UPB_pre(i,4))/10000);
		UPBdata(j,5,i) = (values_all(j+16,5,i)-UPB_pre(i,5))/(1-(values_all(j+16,5,i)-UPB_pre(i,5))*deadtime/1000000000);
		UPBdata(j,6,i) = (values_all(j+16,6,i)-UPB_pre(i,6))/(1-(values_all(j+16,6,i)-UPB_pre(i,6))*deadtime/1000000000);
		UPBdata(j,7,i) = (values_all(j+16,7,i)-UPB_pre(i,7))/(1-(values_all(j+16,7,i)-UPB_pre(i,7))*deadtime/1000000000);
		if UPBdata(j,7,i)*137.82 > 5000000
			UPBdata(j,8,i) = UPBdata(j,7,i)*(1+(0.3*lin68*((137.82*UPBdata(j,7,i))^1.5)/100000000000));
		else
			UPBdata(j,8,i) = UPBdata(j,7,i)*(1+0.2*lowint68*exp(-0.000001*(UPBdata(j,7,i)*137.82)));
		end
		UPBdata(j,9,i) = (values_all(j+16,8,i)-UPB_pre(i,8))/(1-(values_all(j+16,8,i)-UPB_pre(i,8))*deadtime/1000000000);
		if UPBdata(j,9,i) > 5000000
			UPBdata(j,10,i) = UPBdata(j,9,i)*(1+(0.3*lin68*(UPBdata(j,9,i)^1.5)/100000000000));
		else
			UPBdata(j,10,i) = UPBdata(j,9,i)*(1+0.2*lowint68*exp(-0.000001*UPBdata(j,9,i)));
		end
	end
end

for i = 1:data_count
	for j = 20:62
		if values_all(j,8,i) > 5000000
			countif(j,i) = 1;
		else
			countif(j,i) = 0;
		end
	end
end
countsum = sum(countif);

for i = 1:data_count
	if mean(UPBdata(4:38,10,i)) < 50000 || mean(UPBdata(4:38,2,i)) > 100000
		mode(i,1) = {'bad'}; 
	elseif countsum(1,i) < 3
		mode(i,1) = {'IC'};
	elseif mean(UPBdata(4:38,10,i)) > 5000000
		mode(i,1) = {'AN'};
	else
		mode(i,1) = {'MI'};
	end
end

for i = 1:data_count
	for j = 1:57
		if UPBdata(j,8,i) == 0 || UPBdata(j,10,i) == 0
			UPBdata(j,11,i) = 1.3;
		elseif strcmp(mode{i,1}, 'IC') == 1
			UPBdata(j,11,i) = UPBdata(j,3,i)/UPBdata(j,10,i);
		else
			UPBdata(j,11,i) = UPBdata(j,3,i)/(UPBdata(j,8,i)*137.82);
		end
	end
end
		
for i = 1:data_count
	for j = 1:57
		if UPBdata(j,3,i)/UPBdata(j,4,i) > 30
			UPBdata(j,12,i) = 30;
		elseif UPBdata(j,3,i)/UPBdata(j,4,i) < 1.5
			UPBdata(j,12,i) = 1.5;
		else
			UPBdata(j,12,i) = UPBdata(j,3,i)/UPBdata(j,4,i);
		end
	end
end

for i = 1:data_count
	for j = 1:57
		if abs(UPBdata(j,3,i)/UPBdata(j,2,i)) > 200000
			UPBdata(j,13,i) = 200000;
		elseif abs(UPBdata(j,3,i)/UPBdata(j,2,i)) < 100
			UPBdata(j,13,i) = 100;
		else
			UPBdata(j,13,i) = abs(UPBdata(j,3,i)/UPBdata(j,2,i));
		end
	end
end

for i = 1:data_count
	for j = 1:57
		UPBdata(j,14,i) = UPBdata(j,5,i)/UPBdata(j,6,i);
	end
end

for i = 1:data_count
	for j = 1:57
		if abs(UPBdata(j,5,i)/UPBdata(j,2,i)) > 10000
			UPBdata(j,15,i) = 10000;
		elseif abs(UPBdata(j,5,i)/UPBdata(j,2,i)) < 10
			UPBdata(j,15,i) = 10;
		else
			UPBdata(j,15,i) = abs(UPBdata(j,5,i)/UPBdata(j,2,i));
		end
	end
end

waitbar(6/waitnum, h, 'Reducing U-Th-Pb! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

if get(H.legacy,'Value') == 0
	%%%%%%%%%%%%%%%% FAST VERSION %%%%%%%%%%%%%%
	for  i = 1:data_count
		[p68(i,:)] = polyfit((1:1:35)',UPBdata(4:38,11,i),1);
		[p82(i,:)] = polyfit((1:1:35)',UPBdata(4:38,14,i),1);
	end

	for  i = 1:data_count
	f68(:,i) = polyval(p68(i,:),(1:1:35)');
	f82(:,i) = polyval(p82(i,:),(1:1:35)');
	end


	for  i = 1:data_count
		f68r(:,i) = f68(:,i) - UPBdata(4:38,11,i); %calculate residual
		f82r(:,i) = f82(:,i) - UPBdata(4:38,14,i); %calculate residual
	end

	fit68_slope = p68(:,1);
	fit82_slope = p82(:,1);
	fit68_corr = p68(:,2);
	fit82_corr = p82(:,2);

	for  i = 1:data_count
		fit68_err(i,1) = (std(f68r(:,i))/sqrt(35))*2;
		fit82_err(i,1) = (std(f82r(:,i))/sqrt(35))*2;
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

if get(H.legacy,'Value') == 1
	%%%%%%%%%%%%% ORIGINAL %%%%%%%%%%%%%%%
	for i = 1:data_count
		tbl = table((1:1:35)',UPBdata(4:38,11,i));
		mdl = fitlm(tbl);
		fit68_corr(i,1) = mdl.Coefficients.Estimate(1,1);
		fit68_err(i,1) = mdl.Coefficients.SE(1,1);
		fit68_slope(i,1) = mdl.Coefficients.Estimate(2,1);
	end


	for i = 1:data_count
		tbl = table((1:1:35)',UPBdata(4:38,14,i));
		mdl = fitlm(tbl);
		fit82_corr(i,1) = mdl.Coefficients.Estimate(1,1);
		fit82_err(i,1) = mdl.Coefficients.SE(1,1);
		fit82_slope(i,1) = mdl.Coefficients.Estimate(2,1);
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

waitbar(7/waitnum, h, 'Reducing U-Th-Pb! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

UPB_reduced = zeros(data_count,18);
for i = 1:data_count
	UPB_reduced(i,1) = abs(mean(UPBdata(4:38,2,i)));
	UPB_reduced(i,2) = abs(mean(UPBdata(4:38,3,i)));
	UPB_reduced(i,3) = abs(mean(UPBdata(4:38,4,i)));
	UPB_reduced(i,4) = abs(mean(UPBdata(4:38,5,i)));
	if mean(UPBdata(4:38,6,i)) < 1000
		UPB_reduced(i,5) = 1;
	else
		UPB_reduced(i,5) = abs(mean(UPBdata(4:38,6,i)));
	end
	if mean(UPBdata(4:38,8,i)) < 1000
		UPB_reduced(i,6) = 1;
	else
		UPB_reduced(i,6) = abs(mean(UPBdata(4:38,8,i)));
	end
	if mean(UPBdata(4:38,10,i)) < 1000
		UPB_reduced(i,7) = 1;
	else
		UPB_reduced(i,7) = abs(mean(UPBdata(4:38,10,i)));
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,8) = 1.3;
	elseif use_235 == 1
		UPB_reduced(i,8) = sum(UPBdata(:,3,i))./(137.82*sum(UPBdata(:,8,i)));
	else
		UPB_reduced(i,8) = sum(UPBdata(:,3,i))./sum(UPBdata(:,10,i));
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,9) = 1;
	elseif 100*fit68_err(i,1)/UPB_reduced(i,8) > 50
		UPB_reduced(i,9) = 50;
	else
		UPB_reduced(i,9) = 100*fit68_err(i,1)/UPB_reduced(i,8);
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,10) = 1;
	else
		UPB_reduced(i,10) = 200*fit68_err(i,1); %should this be multiplied by fit68 slope?
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,11) = 5;
	elseif sum(UPBdata(:,3,i))/sum(UPBdata(:,4,i)) < 1.5
		UPB_reduced(i,11) = 1.5;
	elseif sum(UPBdata(:,3,i))/sum(UPBdata(:,4,i)) > 30
		UPB_reduced(i,11) = 30;
	else
		UPB_reduced(i,11) = sum(UPBdata(:,3,i))/sum(UPBdata(:,4,i));
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,12) = 1;
	elseif 100*std(UPBdata(4:38,12,i))/UPB_reduced(i,11)/sqrt(35) > 50
		UPB_reduced(i,12) = 50;
	else
		UPB_reduced(i,12) = 100*std(UPBdata(4:38,12,i))/UPB_reduced(i,11)/sqrt(35);
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,13) = 1000;
	elseif UPB_reduced(i,2)/UPB_reduced(i,1) < 20
		UPB_reduced(i,13) = 20;
	elseif UPB_reduced(i,2)/UPB_reduced(i,1) < 1000
		UPB_reduced(i,13) = 4*UPB_reduced(i,2)/UPB_reduced(i,1);
	elseif UPB_reduced(i,2)/UPB_reduced(i,1) > 10000
		UPB_reduced(i,13) = 3*UPB_reduced(i,2)/UPB_reduced(i,1);
	else
		UPB_reduced(i,13) = 4*UPB_reduced(i,2)/UPB_reduced(i,1);
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,14) = 1;
	elseif (100*std(UPBdata(4:38,13,i))/UPB_reduced(i,13))/sqrt(35) > 100
		UPB_reduced(i,14) = 100;
	else
		UPB_reduced(i,14) = (100*std(UPBdata(4:38,13,i))/UPB_reduced(i,13))/sqrt(35);
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,15) = 1;
	elseif UPB_reduced(i,4)/UPB_reduced(i,5) > 0.5
		UPB_reduced(i,15) = 0.5;
	else
		UPB_reduced(i,15) = UPB_reduced(i,4)/UPB_reduced(i,5);
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,16) = 1;
	elseif abs(100*fit82_err(i,1)/UPB_reduced(i,15)) > 20
		UPB_reduced(i,16) = 20;
	else
		UPB_reduced(i,16) = abs(100*fit82_err(i,1)/UPB_reduced(i,15));
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,17) = 100;
	elseif UPB_reduced(i,4)/UPB_reduced(i,1) < 100
		UPB_reduced(i,17) = 100;
	else
		UPB_reduced(i,17) = UPB_reduced(i,4)/UPB_reduced(i,1);
	end
end
		
for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,18) = 1;
	elseif 100*std(UPBdata(4:38,15,i))/UPB_reduced(i,17)/sqrt(35) > 50
		UPB_reduced(i,18) = 50;
	else
		UPB_reduced(i,18) = 100*std(UPBdata(4:38,15,i))/UPB_reduced(i,17)/sqrt(35);
	end
end

for i = 1:data_count
	serial{i,1} = i;
end

% Data Export %
Macro1_Output(1:data_count+1,1:22) = {0}; % Preallocate
Macro1_Output(1,1:end) = {'spotname', 'serial', 'Mode', '177 cps', '204 cps', '206 cps', '207 cps', '208 cps', '232 cps', '235 cps', '238 cps', '206/238', ...
	'68 ± %', 'slope', '206/207', '67 ± %', '206/204', '64 ± %', '208/232', '82 ± %', '208/204', '84 ± %'};
Macro1_Output(2:end,1) = sample;
Macro1_Output(2:end,2) = serial;
Macro1_Output(2:end,3) = mode;

Macro1_Output(2:end,5) = num2cell(UPB_reduced(:,1));
Macro1_Output(2:end,6) = num2cell(UPB_reduced(:,2));
Macro1_Output(2:end,7) = num2cell(UPB_reduced(:,3));
Macro1_Output(2:end,8) = num2cell(UPB_reduced(:,4));
Macro1_Output(2:end,9) = num2cell(UPB_reduced(:,5));
Macro1_Output(2:end,10) = num2cell(UPB_reduced(:,6));
Macro1_Output(2:end,11) = num2cell(UPB_reduced(:,7));
Macro1_Output(2:end,12) = num2cell(UPB_reduced(:,8));
Macro1_Output(2:end,13) = num2cell(UPB_reduced(:,9));
Macro1_Output(2:end,14) = num2cell(UPB_reduced(:,10));
Macro1_Output(2:end,15) = num2cell(UPB_reduced(:,11));
Macro1_Output(2:end,16) = num2cell(UPB_reduced(:,12));
Macro1_Output(2:end,17) = num2cell(UPB_reduced(:,13));
Macro1_Output(2:end,18) = num2cell(UPB_reduced(:,14));
Macro1_Output(2:end,19) = num2cell(UPB_reduced(:,15));
Macro1_Output(2:end,20) = num2cell(UPB_reduced(:,16));
Macro1_Output(2:end,21) = num2cell(UPB_reduced(:,17));
Macro1_Output(2:end,22) = num2cell(UPB_reduced(:,18));

% End Macro Import U-Pb %

%% OPTIONAL FILTER FOR 'BAD' STANDARDS %%

rad_on=get(H.uipanel_reject,'selectedobject');
switch rad_on
	case H.reject_yes

STD1a_68 = (STD1a_idx.*UPB_reduced(:,8));
STD1a_67 = (STD1a_idx.*UPB_reduced(:,11));
STD1a_82 = (STD1a_idx.*UPB_reduced(:,15));

STD1b_68 = (STD1b_idx.*UPB_reduced(:,8));
STD1b_67 = (STD1b_idx.*UPB_reduced(:,11));
STD1b_82 = (STD1b_idx.*UPB_reduced(:,15));

STD2_68 = (STD2_idx.*UPB_reduced(:,8));
STD2_67 = (STD2_idx.*UPB_reduced(:,11));
STD2_82 = (STD2_idx.*UPB_reduced(:,15));

STD1a_68_mean = mean(nonzeros(STD1a_idx.*UPB_reduced(:,8)));
STD1a_67_mean = mean(nonzeros(STD1a_idx.*UPB_reduced(:,11)));
STD1a_82_mean = mean(nonzeros(STD1a_idx.*UPB_reduced(:,15)));

STD1b_68_mean = mean(nonzeros(STD1b_idx.*UPB_reduced(:,8)));
STD1b_67_mean = mean(nonzeros(STD1b_idx.*UPB_reduced(:,11)));
STD1b_82_mean = mean(nonzeros(STD1b_idx.*UPB_reduced(:,15)));

STD2_68_mean = mean(nonzeros(STD2_idx.*UPB_reduced(:,8)));
STD2_67_mean = mean(nonzeros(STD2_idx.*UPB_reduced(:,11)));
STD2_82_mean = mean(nonzeros(STD2_idx.*UPB_reduced(:,15)));

STD1a_68_hi = STD1a_68_mean + (str2num(get(H.reject_std,'String')))*.01.*STD1a_68_mean;
STD1a_68_lo = STD1a_68_mean - (str2num(get(H.reject_std,'String')))*.01.*STD1a_68_mean;
STD1a_67_hi = STD1a_67_mean + (str2num(get(H.reject_std,'String')))*.01.*STD1a_67_mean;
STD1a_67_lo = STD1a_67_mean - (str2num(get(H.reject_std,'String')))*.01.*STD1a_67_mean;
STD1a_82_hi = STD1a_82_mean + (str2num(get(H.reject_std,'String')))*.01.*STD1a_82_mean;
STD1a_82_lo = STD1a_82_mean - (str2num(get(H.reject_std,'String')))*.01.*STD1a_82_mean;

STD1b_68_hi = STD1b_68_mean + (str2num(get(H.reject_std,'String')))*.01.*STD1b_68_mean;
STD1b_68_lo = STD1b_68_mean - (str2num(get(H.reject_std,'String')))*.01.*STD1b_68_mean;
STD1b_67_hi = STD1b_67_mean + (str2num(get(H.reject_std,'String')))*.01.*STD1b_67_mean;
STD1b_67_lo = STD1b_67_mean - (str2num(get(H.reject_std,'String')))*.01.*STD1b_67_mean;
STD1b_82_hi = STD1b_82_mean + (str2num(get(H.reject_std,'String')))*.01.*STD1b_82_mean;
STD1b_82_lo = STD1b_82_mean - (str2num(get(H.reject_std,'String')))*.01.*STD1b_82_mean;

STD2_68_hi = STD2_68_mean + (str2num(get(H.reject_std,'String')))*.01.*STD2_68_mean;
STD2_68_lo = STD2_68_mean - (str2num(get(H.reject_std,'String')))*.01.*STD2_68_mean;
STD2_67_hi = STD2_67_mean + (str2num(get(H.reject_std,'String')))*.01.*STD2_67_mean;
STD2_67_lo = STD2_67_mean - (str2num(get(H.reject_std,'String')))*.01.*STD2_67_mean;
STD2_82_hi = STD2_82_mean + (str2num(get(H.reject_std,'String')))*.01.*STD2_82_mean;
STD2_82_lo = STD2_82_mean - (str2num(get(H.reject_std,'String')))*.01.*STD2_82_mean;

STD1_idx_orig = sum(STD1a_idx)+sum(STD1b_idx)+sum(STD2_idx);

for i = 1:data_count
	if STD1a_idx(i,1) == 1 && STD1a_68(i,1) > STD1a_68_hi
		STD1a_idx(i,1) = 0;
	end
	if STD1a_idx(i,1) == 1 && STD1a_68(i,1) < STD1a_68_lo
		STD1a_idx(i,1) = 0;
	end
	if STD1a_idx(i,1) == 1 && STD1a_67(i,1) > STD1a_67_hi
		STD1a_idx(i,1) = 0;
	end
	if STD1a_idx(i,1) == 1 && STD1a_67(i,1) < STD1a_67_lo
		STD1a_idx(i,1) = 0;
	end
	if STD1a_idx(i,1) == 1 && STD1a_82(i,1) > STD1a_82_hi
		STD1a_idx(i,1) = 0;
	end
	if STD1a_idx(i,1) == 1 && STD1a_82(i,1) < STD1a_82_lo
		STD1a_idx(i,1) = 0;
	end
end

for i = 1:data_count
	if STD1b_idx(i,1) == 1 && STD1b_68(i,1) > STD1b_68_hi
		STD1b_idx(i,1) = 0;
	end
	if STD1b_idx(i,1) == 1 && STD1b_68(i,1) < STD1b_68_lo
		STD1b_idx(i,1) = 0;
	end
	if STD1b_idx(i,1) == 1 && STD1b_67(i,1) > STD1b_67_hi
		STD1b_idx(i,1) = 0;
	end
	if STD1b_idx(i,1) == 1 && STD1b_67(i,1) < STD1b_67_lo
		STD1b_idx(i,1) = 0;
	end
	if STD1b_idx(i,1) == 1 && STD1b_82(i,1) > STD1b_82_hi
		STD1b_idx(i,1) = 0;
	end
	if STD1b_idx(i,1) == 1 && STD1b_82(i,1) < STD1b_82_lo
		STD1b_idx(i,1) = 0;
	end
end

for i = 1:data_count
	if STD2_idx(i,1) == 1 && STD2_68(i,1) > STD2_68_hi
		STD2_idx(i,1) = 0;
	end
	if STD2_idx(i,1) == 1 && STD2_68(i,1) < STD2_68_lo
		STD2_idx(i,1) = 0;
	end
	if STD2_idx(i,1) == 1 && STD2_67(i,1) > STD2_67_hi
		STD2_idx(i,1) = 0;
	end
	if STD2_idx(i,1) == 1 && STD2_67(i,1) < STD2_67_lo
		STD2_idx(i,1) = 0;
	end
	if STD2_idx(i,1) == 1 && STD2_82(i,1) > STD2_82_hi
		STD2_idx(i,1) = 0;
	end
	if STD2_idx(i,1) == 1 && STD2_82(i,1) < STD2_82_lo
		STD2_idx(i,1) = 0;
	end
end

STD_idx_rej = STD1_idx_orig - (sum(STD1a_idx)+sum(STD1b_idx)+sum(STD2_idx));
set(H.standards_rejected, 'String', STD_idx_rej);

	case H.reject_no
end

%% START U-Pb Calc Macro %%

for i = 1:data_count %206204 (E2AgeCalc 192 Sheet1 Excel col CY)
	if UPB_reduced(i,13)*factor64 > 20
		CY(i,1) = UPB_reduced(i,13)*factor64;
	else
		CY(i,1) = 20;
	end
end

for i = 1:data_count %initial 68 ff (E2AgeCalc 192 Sheet1 Excel col HK)
	if contains(sample{i,1}, 'FC') == 1 && strcmp(mode{i,1}, 'bad') == 0
		ff68init(i,1) = STD_FC_68/UPB_reduced(i,8)*((CY(i,1)-STD_FC_64c)/CY(i,1));
	elseif contains(sample{i,1}, 'SL') == 1 && strcmp(mode{i,1}, 'bad') == 0
		ff68init(i,1) = STD_SL_68/UPB_reduced(i,8)*((CY(i,1)-STD_FC_64c)/CY(i,1)); % FIX Uses wrong 64c, should be SL
	elseif contains(sample{i,1}, 'R33') == 1 && strcmp(mode{i,1}, 'bad') == 0
		ff68init(i,1) = STD_R33_68/UPB_reduced(i,8)*((CY(i,1)-STD_FC_64c)/CY(i,1)); %FIX Uses wrong 64c, should be R33
	else
		ff68init(i,1) = 0;
	end
end
ff68init(data_count+1:data_count+46,1) = 0;

if length(nonzeros(ff68init(:,1))) > 10 && data_count > 30

for i = 1:13 %initial 68 ff sw (E2AgeCalc 192 Sheet1 Excel col HL, first 13 rows)
	if length(nonzeros(ff68init(1:i+46))) < 4
		ffsw68init(i,1) = mean(nonzeros(ff68init(1:i+46,1)));
	else
		ffsw68init(i,1) = (sum(nonzeros(ff68init(1:i+46,1)))-max(nonzeros(ff68init(1:i+46,1)))-min(nonzeros(ff68init(1:i+46,1))))/(length(nonzeros(ff68init(1:i+46,1)))-2);
	end
end
for i = 14:40 %initial 68 ff sw (E2AgeCalc 192 Sheet1 Excel col HL, row 14 to row 40)
	if length(nonzeros(ff68init(1:i+46))) < 4
		ffsw68init(i,1) = mean(nonzeros(ff68init(6:i+46,1)));
	else
		ffsw68init(i,1) = (sum(nonzeros(ff68init(6:i+46,1)))-max(nonzeros(ff68init(6:i+46,1)))-min(nonzeros(ff68init(6:i+46,1))))/(length(nonzeros(ff68init(6:i+46,1)))-2);
	end
end
for i = 41:data_count %initial 68 ff sw (E2AgeCalc 192 Sheet1 Excel col HL, row 41 to end)
	if length(nonzeros(ff68init(1:i+46))) < 4
		ffsw68init(i,1) = mean(nonzeros(ff68init(i-34:i+46,1)));
	else
		ffsw68init(i,1) = (sum(nonzeros(ff68init(i-34:i+46,1)))-max(nonzeros(ff68init(i-34:i+46,1)))-min(nonzeros(ff68init(i-34:i+46,1))))/(length(nonzeros(ff68init(i-34:i+46,1)))-2);
	end
end

else

for i = 1:data_count  
ffsw68init(i,1) = mean(nonzeros(ff68init));
end

end

for i = 1:data_count %initial 6/8 age (E2AgeCalc 192 Sheet1 Excel col HM)
	Age68init(i,1) = abs(log(UPB_reduced(i,8)*ffsw68init(i,1)+1)/0.000155125);
end

for i = 1:data_count %68 STDS (E2AgeCalc 192 Sheet1 Excel col AC)
	if contains(sample{i,1}, 'FC') == 1 && Age68init(i,1) > (1100+0.01*rejectFC*1100) || contains(sample{i,1}, 'FC') == 1 && Age68init(i,1) < (1100-0.01*rejectFC*1100) || ...
			contains(sample{i,1}, 'SL') == 1 && Age68init(i,1) > (564+0.01*rejectSL*564) || contains(sample{i,1}, 'SL') == 1 && Age68init(i,1) < (564-0.01*rejectSL*564) || ...
			contains(sample{i,1}, 'R33') == 1 && Age68init(i,1) > (420+0.01*rejectR33*420) || contains(sample{i,1}, 'R33') == 1 && Age68init(i,1) < (420-0.01*rejectR33*420)
		reject68(i,1) = 1;
	else
		reject68(i,1) = 0;
	end
end

for i = 1:data_count %67 STDS (E2AgeCalc 192 Sheet1 Excel col AD)
	if contains(sample{i,1}, 'FC') == 1 && UPB_reduced(i,11) > (13.13+0.005*rejectFC*13.13) || contains(sample{i,1}, 'FC') == 1 && UPB_reduced(i,11) < (13.13-0.005*rejectFC*13.13) || ...
			contains(sample{i,1}, 'SL') == 1 && UPB_reduced(i,11) > (16.97+0.01*rejectSL*16.97) || contains(sample{i,1}, 'SL') == 1 && UPB_reduced(i,11) < (16.97-0.01*rejectSL*16.97) || ...
			contains(sample{i,1}, 'R33') == 1 && UPB_reduced(i,11) > (18.12+0.02*rejectR33*18.12) || contains(sample{i,1}, 'R33') == 1 && UPB_reduced(i,11) < (18.12-0.02*rejectR33*18.12)
		reject67(i,1) = 1;
	else
		reject67(i,1) = 0;
	end
end

for i = 1:data_count %U ppm and Th ppm calc measured STDs (E2AgeCalc 192 Sheet1 Excel cols DL, DM, DN and DO)
	if reject68(i,1) == 0 && contains(sample{i,1}, 'FC') == 1
		DL(i,1) = UPB_reduced(i,7);
		DM(i,1) = UPB_reduced(i,5);
		DN(i,1) = STD_FC_Uppm;
		DO(i,1) = STD_FC_Thppm;		
	elseif reject68(i,1) == 0 && contains(sample{i,1}, 'R33') == 1 
		DL(i,1) = UPB_reduced(i,7);
		DM(i,1) = UPB_reduced(i,5);
		DN(i,1) = STD_R33_Uppm;
		DO(i,1) = STD_R33_Thppm;
	else
		DL(i,1) = 0;
		DM(i,1) = 0;
		DN(i,1) = 0;
		DO(i,1) = 0;
	end
end
DLmean = mean(nonzeros(DL));
DMmean = mean(nonzeros(DM));
DNmean = mean(nonzeros(DN));
DOmean = mean(nonzeros(DO));

waitbar(8/waitnum, h, 'Reducing U-Th-Pb! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

for i = 1:data_count %U ppm and Thppm (E2AgeCalc 192 Sheet1 Excel cols AT and AU)
	Uppm(i,1) = UPB_reduced(i,7)*DNmean/DLmean; 
	Thppm(i,1) = UPB_reduced(i,5)*DOmean/DMmean;
end
UTh = Uppm./Thppm; %U/Th ratio (E2AgeCalc 192 Sheet1 Excel col AX)

for i = 1:data_count %68 ff (E2AgeCalc 192 Sheet1 Excel col BX)
	if contains(sample{i,1}, 'FC') == 1 && reject68(i,1) == 0 && use_FC_68 == 1
		ff68(i,1) = STD_FC_68/UPB_reduced(i,8)*((CY(i,1)-STD_FC_64c)/CY(i,1));
	elseif contains(sample{i,1}, 'SL') == 1  && reject68(i,1) == 0 && use_SL_68 == 1
		ff68(i,1) = STD_SL_68/UPB_reduced(i,8)*((CY(i,1)-STD_SL_64c)/CY(i,1));
	elseif contains(sample{i,1}, 'R33') == 1  && reject68(i,1) == 0 && use_R33_68 == 1
		ff68(i,1) = STD_R33_68/UPB_reduced(i,8)*((CY(i,1)-STD_R33_64c)/CY(i,1)); %Uses wrong 64c, should be R33
	else
		ff68(i,1) = 0;
	end
end
ff68(data_count+1:data_count+46,1) = 0;

if length(nonzeros(ff68(:,1))) > 10 && data_count > 30

for i = 1:13 %68 ff sw (E2AgeCalc 192 Sheet1 Excel col BY, first 13 rows)
	if length(nonzeros(ff68(1:i+46))) < 4
		ffsw68(i,1) = mean(nonzeros(ff68(1:i+46,1)));
	else
		ffsw68(i,1) = (sum(nonzeros(ff68(1:i+46,1)))-max(nonzeros(ff68(1:i+46,1)))-min(nonzeros(ff68(1:i+46,1))))/(length(nonzeros(ff68(1:i+46,1)))-2);
	end
end
for i = 14:40 %68 ff sw (E2AgeCalc 192 Sheet1 Excel col BY, row 14 to row 40)
	if length(nonzeros(ff68(1:i+46))) < 4
		ffsw68(i,1) = mean(nonzeros(ff68(6:i+46,1)));
	else
		ffsw68(i,1) = (sum(nonzeros(ff68(6:i+46,1)))-max(nonzeros(ff68(6:i+46,1)))-min(nonzeros(ff68(6:i+46,1))))/(length(nonzeros(ff68(6:i+46,1)))-2);
	end
end
for i = 41:data_count %68 ff sw (E2AgeCalc 192 Sheet1 Excel col BY, row 41 to end)
	if length(nonzeros(ff68(1:i+46))) < 4
		ffsw68(i,1) = mean(nonzeros(ff68(i-34:i+46,1)));
	else
		ffsw68(i,1) = (sum(nonzeros(ff68(i-34:i+46,1)))-max(nonzeros(ff68(i-34:i+46,1)))-min(nonzeros(ff68(i-34:i+46,1))))/(length(nonzeros(ff68(i-34:i+46,1)))-2);
	end
end

for i = 1:13 %68 ff sw se (E2AgeCalc 192 Sheet1 Excel col BZ, first 13 rows)
	ffswse68(i,1) = abs(std(nonzeros(ff68(1:i+26,1)))/(sqrt(length(nonzeros(ff68(1:i+26,1))))));
end
for i = 14:40 %68 ff sw se (E2AgeCalc 192 Sheet1 Excel col BZ, row 14 to row 40)
	ffswse68(i,1) = abs(std(nonzeros(ff68(6:i+39,1)))/(sqrt(length(nonzeros(ff68(6:i+39,1))))));
end
for i = 41:data_count %68 ff sw se (E2AgeCalc 192 Sheet1 Excel col BZ, row 41 to end)
	ffswse68(i,1) = abs(std(nonzeros(ff68(i-34:i+39,1)))/(sqrt(length(nonzeros(ff68(i-34:i+39,1))))));
end

else
	
for i = 1:data_count  
ffsw68(i,1) = mean(nonzeros(ff68));
ffswse68(i,1) = (std(nonzeros([ff68])))/sqrt(length(nonzeros([ff68])));
end

end

ffse68_hi = ffsw68 + ffswse68; %col CA
ffse68_lo = ffsw68 - ffswse68; %col CB

waitbar(9/waitnum, h, 'Reducing U-Th-Pb! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

for i = 1:data_count
	Age68init2(i,1) = log(ffsw68(i,1)*UPB_reduced(i,8)+1)/0.000155125; %col BU
	DA(i,1) = 18.761 - 0.0000001*Age68init2(i,1)*Age68init2(i,1) - 0.0016*Age68init2(i,1); %col DA
	DB(i,1) = 15.671 - 0.00000000009*Age68init2(i,1)*Age68init2(i,1)*Age68init2(i,1)+0.0000002*Age68init2(i,1)*Age68init2(i,1)-0.0003*Age68init2(i,1); %col DB
	DC(i,1) = 38.657  -0.00000003*Age68init2(i,1)*Age68init2(i,1) - 0.0019*Age68init2(i,1); %col DC
end

for i = 1:data_count
	fcbc68(i,1) = abs(UPB_reduced(i,8)*ffsw68(i,1)*((CY(i,1)-DA(i,1))/CY(i,1))); %col CC
end

for i = 1:data_count
	err6864(i,1) = abs(100*(1-((CY(i,1)-(18.761-DA(i,1)))/CY(i,1))/(((CY(i,1)+CY(i,1)*UPB_reduced(i,14)/100)-(18.761-DA(i,1)))/(CY(i,1)+CY(i,1)*UPB_reduced(i,14)/100)))); %col CE
	pbcerr68(i,1) = abs(100*(1-(CY(i,1)-(DA(i,1)/CY(i,1)))/(CY(i,1)-((DA(i,1)-1)/CY(i,1))))); %col CF
	merr68(i,1) = odf68*sqrt(UPB_reduced(i,9)*UPB_reduced(i,9)+err6864(i,1)*err6864(i,1)); %col CD
	
end

for i = 1:data_count %67 ff (E2AgeCalc 192 Sheet1 Excel col CG)
	if contains(sample{i,1}, 'FC') == 1 && reject67(i,1) == 0 && use_FC_67 == 1
		ff67(i,1) = STD_FC_67/((CY(i,1)-DA(i,1))/((CY(i,1)/UPB_reduced(i,11))-DB(i,1)));
	elseif contains(sample{i,1}, 'SL') == 1 && reject67(i,1) == 0 && use_SL_67 == 1
		ff67(i,1) = STD_SL_67/((CY(i,1)-DA(i,1))/((CY(i,1)/UPB_reduced(i,11)-DB(i,1))));
	else
		ff67(i,1) = 0;
	end
end
ff67(data_count+1:data_count+46,1) = 0;

if length(nonzeros(ff67(:,1))) > 10 && data_count > 30

for i = 1:13 %67 ff sw and se (E2AgeCalc 192 Sheet1 Excel cols CH and CI, first 13 rows)
	ffsw67(i,1) = (sum(nonzeros(ff67(1:i+26,1)))-max(nonzeros(ff67(1:i+26,1)))-min(nonzeros(ff67(1:i+26,1))))/(length(nonzeros(ff67(1:i+26,1)))-2);
	ffswse67(i,1) = abs(std(nonzeros(ff67(1:i+26,1)))/(sqrt(length(nonzeros(ff67(1:i+26,1))))));
end
for i = 14:40 %67 ff sw and se (E2AgeCalc 192 Sheet1 Excel cols CH and CI, row 14 to row 40)
	ffsw67(i,1) = (sum(nonzeros(ff67(6:i+39,1)))-max(nonzeros(ff67(6:i+39,1)))-min(nonzeros(ff67(6:i+39,1))))/(length(nonzeros(ff67(6:i+39,1)))-2);
	ffswse67(i,1) = abs(std(nonzeros(ff67(6:i+39,1)))/(sqrt(length(nonzeros(ff67(6:i+39,1))))));
end
for i = 41:data_count %67 ff sw and se (E2AgeCalc 192 Sheet1 Excel cols CH and CI, row 41 to end)
	ffsw67(i,1) = (sum(nonzeros(ff67(i-34:i+39,1)))-max(nonzeros(ff67(i-34:i+39,1)))-min(nonzeros(ff67(i-34:i+39,1))))/(length(nonzeros(ff67(i-34:i+39,1)))-2);
	ffswse67(i,1) = abs(std(nonzeros(ff67(i-34:i+39,1)))/(sqrt(length(nonzeros(ff67(i-34:i+39,1))))));
end

else
	
for i = 1:data_count  
ffsw67(i,1) = mean(nonzeros([ff67]));
ffswse67(i,1) = (std(nonzeros([ff67])))/sqrt(length(nonzeros([ff67])));
end

end

ffse67_hi = ffsw67 + ffswse67; %col CJ
ffse67_lo = ffsw67 - ffswse67; %col CK

for i = 1:data_count
	fcbc67(i,1) = abs(ffsw67(i,1)*((CY(i,1)-DA(i,1))/((CY(i,1)/(UPB_reduced(i,11))-DB(i,1))))); %col CL
end

for i = 1:data_count % cols CN, CO, and CM
	err6764(i,1) = abs(100*(1-((ffsw67(i,1)*((CY(i,1)-DA(i,1))/((CY(i,1)/(UPB_reduced(i,11))-DB(i,1)))))/...
		(ffsw67(i,1)*(((CY(i,1)+CY(i,1)*UPB_reduced(i,14)/100)-(DA(i,1)))/(((CY(i,1)+CY(i,1)*UPB_reduced(i,14)/100)/(UPB_reduced(i,11))-DB(i,1)))))))); %col CN
	pbcerr67(i,1) = abs(100*(1-((ffsw67(i,1)*((CY(i,1)-(DA(i,1)))/((CY(i,1)/(UPB_reduced(i,11))-DB(i,1)))))/(ffsw67(i,1)*(((CY(i,1))-(DA(i,1)-1))/...
		(((CY(i,1))/(UPB_reduced(i,11))-(DB(i,1)-0.3)))))))); %col CO
	re67(i,1) = sqrt(UPB_reduced(i,12)*UPB_reduced(i,12)+err6764(i,1)*err6764(i,1)); %col CM
end

for i = 1:data_count %82 ff (E2AgeCalc 192 Sheet1 Excel col CP)
	if contains(sample{i,1}, 'FC') == 1 && use_FC_67 == 1
		ff82(i,1) = STD_FC_82/(UPB_reduced(i,15)*(((UPB_reduced(i,17)*factor64)-STD_SL_68c)/(UPB_reduced(i,17)*factor64))); %uses te wrong STD 68c, should be FC not SL
	elseif contains(sample{i,1}, 'SL') == 1 && use_SL_67 == 1
		ff82(i,1) = STD_SL_82/(UPB_reduced(i,15)*(((UPB_reduced(i,17)*factor64)-STD_SL_68c)/(UPB_reduced(i,17)*factor64)));
	else
		ff82(i,1) = 0;
	end
end
ff82(data_count+1:data_count+46,1) = 0;

if length(nonzeros(ff82(:,1))) > 10 && data_count > 30

for i = 1:13 %82 ff sw and se (E2AgeCalc 192 Sheet1 Excel cols CQ and CR, first 13 rows)
	ffsw82(i,1) = (sum(nonzeros(ff82(1:i+26,1)))-max(nonzeros(ff82(1:i+26,1)))-min(nonzeros(ff82(1:i+26,1))))/(length(nonzeros(ff82(1:i+26,1)))-2);
	ffswse82(i,1) = abs(std(nonzeros(ff82(1:i+26,1)))/(sqrt(length(nonzeros(ff82(1:i+26,1))))));
end
for i = 14:40 %82 ff sw and se (E2AgeCalc 192 Sheet1 Excel cols CQ and CR, row 14 to row 40)
	ffsw82(i,1) = (sum(nonzeros(ff82(6:i+39,1)))-max(nonzeros(ff82(6:i+39,1)))-min(nonzeros(ff82(6:i+39,1))))/(length(nonzeros(ff82(6:i+39,1)))-2);
	ffswse82(i,1) = abs(std(nonzeros(ff82(6:i+39,1)))/(sqrt(length(nonzeros(ff82(6:i+39,1))))));
end
for i = 41:data_count %82 ff sw and se (E2AgeCalc 192 Sheet1 Excel cols CQ and CR, row 41 to end)
	ffsw82(i,1) = (sum(nonzeros(ff82(i-34:i+39,1)))-max(nonzeros(ff82(i-34:i+39,1)))-min(nonzeros(ff82(i-34:i+39,1))))/(length(nonzeros(ff82(i-34:i+39,1)))-2);
	ffswse82(i,1) = abs(std(nonzeros(ff82(i-34:i+39,1)))/(sqrt(length(nonzeros(ff82(i-34:i+39,1))))));
end

else
	
for i = 1:data_count  
ffsw82(i,1) = mean(nonzeros([ff82]));
ffswse82(i,1) = (std(nonzeros([ff82])))/sqrt(length(nonzeros([ff82])));
end

end

ffse82_hi = ffsw82 + ffswse82; %col CS
ffse82_lo = ffsw82 - ffswse82; %col CT

for i = 1:data_count %col CU
	if contains(sample{i,1}, 'FC') == 1
		fcbc82(i,1) = abs(UPB_reduced(i,15)*ffsw82(i,1));
	else
		fcbc82(i,1) = abs(UPB_reduced(i,15)*ffsw82(i,1)*(((UPB_reduced(i,17)*factor64)-DC(i,1))/(UPB_reduced(i,17)*factor64)));
	end
end

for i = 1:data_count
	err8284(i,1) = abs(100*(1-(((UPB_reduced(i,17)-DC(i,1)))/UPB_reduced(i,17))/((((UPB_reduced(i,17)+UPB_reduced(i,17)*UPB_reduced(i,18)/100)-DC(i,1)))/...
		(UPB_reduced(i,17)+UPB_reduced(i,17)*UPB_reduced(i,18)/100)))); %col CW
	pbcerr82(i,1) = abs(100*(1-(((UPB_reduced(i,17)-DC(i,1))/UPB_reduced(i,17))/((UPB_reduced(i,17)-(DC(i,1)-2))/UPB_reduced(i,17))))); %col CX
	re82(i,1) = sqrt(UPB_reduced(i,16)*UPB_reduced(i,16)+err8284(i,1)*err8284(i,1)); %col CV
end

for i = 1:data_count
	ratio68(i,1) = fcbc68(i,1) -((0.000000000155/0.0000092)*(((1/UTh(i,1))/2.3)-1)); % BE 6/8 ratio
	ratio75(i,1) = (ratio68(i,1)/fcbc67(i,1))*137.82; %col BC
	ratio75err(i,1) = sqrt(merr68(i,1)*merr68(i,1) + re67(i,1)*re67(i,1)); %col BD
	Age68(i,1) = abs(log(ratio68(i,1)+1)/0.000155125); %BH 6/8 age
	Age68err(i,1) = abs((log((ratio68(i,1)+ratio68(i,1)*(merr68(i,1)/100))+1)/0.000155125-log((ratio68(i,1)-ratio68(i,1)*merr68(i,1)/100)+1)/0.000155125)/2); %col BI
	fudge82(i,1) = fcbc82(i,1)*(1+0.1*lin82*exp(-0.000002*UPB_reduced(i,6))); % cols DU and BA
	errcorr(i,1) = (merr68(i,1)*merr68(i,1)+ratio75err(i,1)*ratio75err(i,1)-re67(i,1)*re67(i,1))/(2*merr68(i,1)*ratio75err(i,1)); %col BG
	Age75(i,1) = abs(log(ratio75(i,1)+1)/0.00098485); %col BJ
	Age75err(i,1) = abs((log((ratio75(i,1)+ratio75(i,1)*(ratio75err(i,1)/100))+1)/0.00098485-log((ratio75(i,1)-ratio75(i,1)*ratio75err(i,1)/100)+1)/0.00098485)/2); %col BK
	Age82(i,1) = abs(log(fudge82(i,1)+1)/0.0000495); %col BN
	Age82err(i,1) = abs((log((fudge82(i,1)+fudge82(i,1)*(re82(i,1)/100))+1)/0.0000495-log((fudge82(i,1)-fudge82(i,1)*re82(i,1)/100)+1)/0.0000495)/2); %col BO
end

for i = 1:data_count %col BL
	if 1/fcbc67(i,1) < .04604504 %zero age
		Age67{i,1} = 'NA';
	elseif 1/fcbc67(i,1) >= .556 %older than Earth
		Age67{i,1} = 'NA';
	else
		Age67{i,1} = MyAge76_E2(1/fcbc67(i,1));
	end
end

for i = 1:data_count %col BM
	%if fcbc67(i,1) > 2 && fcbc67(i,1) < 30 && re67(i,1) < 50
	if 1/(fcbc67(i,1)-fcbc67(i,1)*re67(i,1)/100) > .04604504 && 1/(fcbc67(i,1)-fcbc67(i,1)*re67(i,1)/100) < .556 && ...
			1/(fcbc67(i,1)+fcbc67(i,1)*re67(i,1)/100) > .04604504 && 1/(fcbc67(i,1)+fcbc67(i,1)*re67(i,1)/100) < .556
		Age67err{i,1} = abs((MyAge76_E2(1/(fcbc67(i,1)-fcbc67(i,1)*re67(i,1)/100)) - MyAge76_E2(1/(fcbc67(i,1)+fcbc67(i,1)*re67(i,1)/100)))/2);
	else
		Age67err{i,1} = 'NA';
	end
end

for i = 1:data_count %col BP
	if strcmp(Age67err{i,1}, 'NA') == 1   % this should be based on NA of the age, but not currently coded that way in Excel E2AgeCalc v 192
		Best_Age(i,1) = Age68(i,1);
		Best_Age_err(i,1) = Age68err(i,1);
	elseif Age68(i,1) > 400 && (Age68(i,1)+cell2num(Age67(i,1)))/2 > bestage_cutoff
		Best_Age(i,1) = cell2num(Age67(i,1));
		Best_Age_err(i,1) = cell2num(Age67err(i,1));
	else
		Best_Age(i,1) = Age68(i,1);
		Best_Age_err(i,1) = Age68err(i,1);
	end
end

Ages(1:data_count,1:6) = {[]};

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		Ages(i,:) = {'NA'};
	else		
		Ages(i,1) = num2cell(Age68(i,1));
		Ages(i,2) = num2cell(Age68err(i,1));
		Ages(i,3) = Age67(i,1);
		Ages(i,4) = Age67err(i,1);
		Ages(i,5) = num2cell(Age82(i,1));
		Ages(i,6) = num2cell(Age82err(i,1));
	end
end

comment1{data_count, 1} = [];
comment2{data_count, 1} = [];
comment3{data_count, 1} = [];
comment4{data_count, 1} = [];
comment5{data_count, 1} = [];
comment6{data_count, 1} = [];
comment7{data_count, 1} = [];

for i = 1:data_count
    if strcmp(Age67{i,1}, 'NA') == 1
		tmp67{i,1} = 0;
	else
		tmp67(i,1) = Age67(i,1);
	end
end
	
for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		comment1(i,1) = {'bad  '};
	end
	if Age68(i,1) > tmp67{i,1}*(1+filter_disc_rev*0.01) && Age68(i,1) > filter_cutoff
		comment2(i,1) = {'rev discord  '};
	end
	if Age68(i,1) < tmp67{i,1}*(1-filter_disc*0.01) && Age68(i,1) > filter_cutoff
		comment3(i,1) = {'discord  '};
	end
	if UPB_reduced(i,9) > filter_err68
		comment4(i,1) = {'6/8 err  '};
	end
	if Age68(i,1) > filter_cutoff && UPB_reduced(i,12) > filter_err67
		comment5(i,1) = {'6/7 err  '};
	end
	if UPB_reduced(i,13) < filter_64
		comment6(i,1) = {'low 6/4  '};
	end
	if UPB_reduced(i,10) < -0.2
		comment7(i,1) = {'6/8 slope  '};
	end
end
		
comment = strcat(comment1, comment2, comment3, comment4, comment5, comment6, comment7);	

waitbar(10/waitnum, h, 'Reducing U-Th-Pb! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

%% CONCATENATE DATA FOR EXPORT AND PLOTTING %%

AGES_OUT{data_count+1, 6} = [];
AGES_OUT(1,:) = {'6/8 age', '± (Ma)', '6/7 age', '± (Ma)', '8/2 age', '± (Ma)'};
AGES_OUT(2:end,:) = Ages;

REJECTED{data_count+1, 3} = [];
REJECTED(1,:) = {'68 STDS',	'67 STDS',	'Unknowns'};
for i = 1:data_count
	if reject68(i,1) == 1
		REJECTED{i+1,1} = 'xx';
	end
	if reject67(i,1) == 1
		REJECTED{i+1,2} = 'xx';
	end
		REJECTED(i+1,3) = comment(i,1);
end

SAMPLE_CONCORDIA{data_count+1, 13} = [];
SAMPLE_CONCORDIA(1,:) = {'7/5 ratio', '±(%)', '6/8 ratio', '±(%)', 'errcorr', '6/8 age', '±(Ma)', '6/7 age', '±(Ma)', 'BEST AGE', '±(Ma)', '8/2 age', '±(Ma)'};
for i = 1:data_count
if STD1a_idx(i,1) == 0 && STD1b_idx(i,1) == 0 && STD2_idx(i,1) == 0 && isempty(comment{i,1}) == 1 
SAMPLE_CONCORDIA(i+1,:) = [num2cell(ratio75(i,:)), num2cell(ratio75err(i,:)), num2cell(ratio68(i,:)), num2cell(merr68(i,:)), num2cell(errcorr(i,:)), ...
	Age68(i,:), Age68err(i,:), Age67(i,:), Age67err(i,:), Best_Age(i,:), Best_Age_err(i,:), Age82(i,:), Age82err(i,:)];
end
end

CORRECTED_CONC_RATIOS{data_count+1, 15} = [];
CORRECTED_CONC_RATIOS(1,:) = {'sample', 'U (ppm)', 'Th(ppm)', '6/4c', '8/4 ratio', 'U/Th', '6/7 ratio', '±(%)', '8/2 ratio', '±(%)', ...
	'7/5 ratio', '±(%)', '6/8 ratio', '±(%)', 'errcorr'};
CORRECTED_CONC_RATIOS(2:end,:) = [sample, num2cell(Uppm), num2cell(Thppm), num2cell(CY), num2cell(UPB_reduced(:,17)), ...
	num2cell(UTh), num2cell(fcbc67), num2cell(re67), num2cell(fcbc82), num2cell(re82), num2cell(ratio75), num2cell(ratio75err), num2cell(ratio68), ...
	num2cell(merr68), num2cell(errcorr)];

AGES_1SD_RANDOM_ERRORS{data_count+1, 10} = [];
AGES_1SD_RANDOM_ERRORS(1,:) = {'6/8 age', '±(Ma)', '7/5 age', '±(Ma)', '6/7 age', '±(Ma)', '8/2 age', '±(Ma)', 'BEST AGE', '±(Ma)'};
AGES_1SD_RANDOM_ERRORS(2:end,:) = [num2cell(Age68), num2cell(Age68err), num2cell(Age75), num2cell(Age75err), Age67, Age67err, num2cell(Age82), num2cell(Age82err), ...
	num2cell(Best_Age), num2cell(Best_Age_err)];

Macro_1_2_Output = [Macro1_Output, AGES_OUT, REJECTED, SAMPLE_CONCORDIA, CORRECTED_CONC_RATIOS, AGES_1SD_RANDOM_ERRORS];

close(h)

%% DRIFT CORRECTION %%%%%

analysis_num = cell2num(serial);

for i = 1:data_count
	if STD1a_idx(i,1) == 1 && strcmp(mode{i,1}, 'IC') == 1 && reject68(i,1) == 0
		FC_IC_x(i,1) = analysis_num(i,1);
		FC_IC_y(i,1) = STD_FC_68/UPB_reduced(i,8); %col DV
		FC_IC_238(i,1) = UPB_reduced(i,7); %col GF
		FC_IC_OS(i,1) = 100*(Age68(i,1)-STD_FC_68age)/STD_FC_68age; %col GG
	else
		FC_IC_x(i,1) = 0;
		FC_IC_y(i,1) = 0;
		FC_IC_238(i,1) = 0; %col GF
		FC_IC_OS(i,1) = 0; %col GG
	end
	if STD1a_idx(i,1) == 1 && strcmp(mode{i,1}, 'MI') == 1 && reject68(i,1) == 0
		FC_MI_x(i,1) = analysis_num(i,1);
		FC_MI_y(i,1) = STD_FC_68/UPB_reduced(i,8); %col DW
		FC_MI_238(i,1) = UPB_reduced(i,7); %col GH
		FC_MI_OS(i,1) = 100*(Age68(i,1)-STD_FC_68age)/STD_FC_68age; %col GI
	else
		FC_MI_x(i,1) = 0;
		FC_MI_y(i,1) = 0;
		FC_MI_238(i,1) = 0; %col GH
		FC_MI_OS(i,1) = 0; %col GI
	end
	if STD1a_idx(i,1) == 1 && strcmp(mode{i,1}, 'AN') == 1 && reject68(i,1) == 0
		FC_AN_x(i,1) = analysis_num(i,1);
		FC_AN_y(i,1) = STD_FC_68/UPB_reduced(i,8); %col DX
		FC_AN_238(i,1) = UPB_reduced(i,7); %col GJ
		FC_AN_OS(i,1) = 100*(Age68(i,1)-STD_FC_68age)/STD_FC_68age; %col GK
	else
		FC_AN_x(i,1) = 0;
		FC_AN_y(i,1) = 0;
		FC_AN_238(i,1) = 0; %col GJ
		FC_AN_OS(i,1) = 0; %col GK
	end
end
FC_IC_x = nonzeros(FC_IC_x);
FC_IC_y = nonzeros(FC_IC_y);
FC_MI_x = nonzeros(FC_MI_x);
FC_MI_y = nonzeros(FC_MI_y);
FC_AN_x = nonzeros(FC_AN_x);
FC_AN_y = nonzeros(FC_AN_y);
FC_IC_238 = nonzeros(FC_IC_238);
FC_IC_OS = nonzeros(FC_IC_OS);
FC_MI_238 = nonzeros(FC_MI_238);
FC_MI_OS = nonzeros(FC_MI_OS);
FC_AN_238 = nonzeros(FC_AN_238);
FC_AN_OS = nonzeros(FC_AN_OS);

for i = 1:data_count		
	if STD1b_idx(i,1) == 1 && strcmp(mode{i,1}, 'IC') == 1 && reject68(i,1) == 0
		SL_IC_x(i,1) = analysis_num(i,1);
		SL_IC_y(i,1) = STD_SL_68/UPB_reduced(i,8); %col DY
		SL_IC_238(i,1) = UPB_reduced(i,7); %col GP
		SL_IC_OS(i,1) = 100*(Age68(i,1)-STD_SL_68age)/STD_SL_68age; %col GQ		
	else
		SL_IC_x(i,1) = 0;
		SL_IC_y(i,1) = 0;
		SL_IC_238(i,1) = 0; %col GP
		SL_IC_OS(i,1) = 0; %col GQ	
	end
	if STD1b_idx(i,1) == 1 && strcmp(mode{i,1}, 'MI') == 1 && reject68(i,1) == 0
		SL_MI_x(i,1) = analysis_num(i,1);
		SL_MI_y(i,1) = STD_SL_68/UPB_reduced(i,8); %col DZ
		SL_MI_238(i,1) = UPB_reduced(i,7); %col GR
		SL_MI_OS(i,1) = 100*(Age68(i,1)-STD_SL_68age)/STD_SL_68age; %col GS	
	else
		SL_MI_x(i,1) = 0;
		SL_MI_y(i,1) = 0;
		SL_MI_238(i,1) = 0; %col GR
		SL_MI_OS(i,1) = 0; %col GS	
	end
	if STD1b_idx(i,1) == 1 && strcmp(mode{i,1}, 'AN') == 1 && reject68(i,1) == 0
		SL_AN_x(i,1) = analysis_num(i,1);
		SL_AN_y(i,1) = STD_SL_68/UPB_reduced(i,8); %col EA
		SL_AN_238(i,1) = UPB_reduced(i,7); %col GT
		SL_AN_OS(i,1) = 100*(Age68(i,1)-STD_SL_68age)/STD_SL_68age; %col GU	
	else
		SL_AN_x(i,1) = 0;
		SL_AN_y(i,1) = 0;	
		SL_AN_238(i,1) = 0; %col GT
		SL_AN_OS(i,1) = 0; %col GU	
	end
end		
SL_IC_x = nonzeros(SL_IC_x);
SL_IC_y = nonzeros(SL_IC_y);
SL_MI_x = nonzeros(SL_MI_x);
SL_MI_y = nonzeros(SL_MI_y);
SL_AN_x = nonzeros(SL_AN_x);
SL_AN_y = nonzeros(SL_AN_y);
SL_IC_238 = nonzeros(SL_IC_238);
SL_IC_OS = nonzeros(SL_IC_OS);
SL_MI_238 = nonzeros(SL_MI_238);
SL_MI_OS = nonzeros(SL_MI_OS);
SL_AN_238 = nonzeros(SL_AN_238);
SL_AN_OS = nonzeros(SL_AN_OS);

for i = 1:data_count	
	if STD2_idx(i,1) == 1 && strcmp(mode{i,1}, 'IC') == 1 && reject68(i,1) == 0
		R33_IC_x(i,1) = analysis_num(i,1);
		R33_IC_y(i,1) = STD_R33_68/UPB_reduced(i,8); %col EB
		R33_IC_238(i,1) = UPB_reduced(i,7); %col GZ
		R33_IC_OS(i,1) = 100*(Age68(i,1)-STD_R33_68age)/STD_R33_68age; %col HA	
	else
		R33_IC_x(i,1) = 0;
		R33_IC_y(i,1) = 0;		
		R33_IC_238(i,1) = 0; %col GZ
		R33_IC_OS(i,1) = 0; %col HA	
	end		
	if STD2_idx(i,1) == 1 && strcmp(mode{i,1}, 'MI') == 1 && reject68(i,1) == 0
		R33_MI_x(i,1) = analysis_num(i,1);
		R33_MI_y(i,1) = STD_R33_68/UPB_reduced(i,8); %col EC
		R33_MI_238(i,1) = UPB_reduced(i,7); %col HB
		R33_MI_OS(i,1) = 100*(Age68(i,1)-STD_R33_68age)/STD_R33_68age; %col HC	
	else
		R33_MI_x(i,1) = 0;
		R33_MI_y(i,1) = 0;		
		R33_MI_238(i,1) = 0; %col HB
		R33_MI_OS(i,1) = 0; %col HC
	end		
	if STD2_idx(i,1) == 1 && strcmp(mode{i,1}, 'AN') == 1 && reject68(i,1) == 0
		R33_AN_x(i,1) = analysis_num(i,1);
		R33_AN_y(i,1) = STD_R33_68/UPB_reduced(i,8); %col ED
		R33_AN_238(i,1) = UPB_reduced(i,7); %col HD
		R33_AN_OS(i,1) = 100*(Age68(i,1)-STD_R33_68age)/STD_R33_68age; %col HE	
	else
		R33_AN_x(i,1) = 0;
		R33_AN_y(i,1) = 0;
		R33_AN_238(i,1) = 0; %col HD
		R33_AN_OS(i,1) = 0; %col HE	
	end
end
R33_IC_x = nonzeros(R33_IC_x);
R33_IC_y = nonzeros(R33_IC_y);
R33_MI_x = nonzeros(R33_MI_x);
R33_MI_y = nonzeros(R33_MI_y);
R33_AN_x = nonzeros(R33_AN_x);
R33_AN_y = nonzeros(R33_AN_y);
R33_IC_238 = nonzeros(R33_IC_238);
R33_IC_OS = nonzeros(R33_IC_OS);
R33_MI_238 = nonzeros(R33_MI_238);
R33_MI_OS = nonzeros(R33_MI_OS);
R33_AN_238 = nonzeros(R33_AN_238);
R33_AN_OS = nonzeros(R33_AN_OS);

for i = 1:data_count		
	if STD1a_idx(i,1) == 1 && reject67(i,1) == 0 
		FC_67_x(i,1) = analysis_num(i,1);
		FC_67_y(i,1) = ff67(i,1);
		FC_206(i,1) = UPB_reduced(i,2); %col GL
		FC_67_OS(i,1) = 100*(cell2num(Age67(i,1))-STD_FC_67age)/STD_FC_67age; %col GM
	else
		FC_67_x(i,1) = 0;
		FC_67_y(i,1) = 0;
		FC_206(i,1) = 0; %col GL
		FC_67_OS(i,1) = 0; %col GM
	end
	if STD1b_idx(i,1) == 1 && reject67(i,1) == 0 
		SL_67_x(i,1) = analysis_num(i,1);
		SL_67_y(i,1) = ff67(i,1);
		SL_206(i,1) = UPB_reduced(i,2); %col GV
		SL_67_OS(i,1) = 100*(cell2num(Age67(i,1))-STD_SL_67age)/STD_SL_67age; %col GW
	else
		SL_67_x(i,1) = 0;
		SL_67_y(i,1) = 0;
		SL_206(i,1) = 0; %col GV
		SL_67_OS(i,1) = 0; %col GW
	end
	if STD2_idx(i,1) == 1 && reject67(i,1) == 0 
		R33_206(i,1) = UPB_reduced(i,2); %col HF
		R33_67_OS(i,1) = 100*(cell2num(Age67(i,1))-STD_R33_67age)/STD_R33_67age; %col HG
	else
		R33_206(i,1) = 0; %col HF
		R33_67_OS(i,1) = 0; %col HG
	end
end
FC_67_x = nonzeros(FC_67_x);
FC_67_y = nonzeros(FC_67_y);
SL_67_x = nonzeros(SL_67_x);
SL_67_y = nonzeros(SL_67_y);
FC_206 = nonzeros(FC_206);
FC_67_OS = nonzeros(FC_67_OS);
SL_206 = nonzeros(SL_206);
SL_67_OS = nonzeros(SL_67_OS);
R33_206 = nonzeros(R33_206);
R33_67_OS = nonzeros(R33_67_OS);

for i = 1:data_count		
	if STD1a_idx(i,1) == 1 && reject68(i,1) == 0 && reject67(i,1) == 0 
		FC_82_x(i,1) = analysis_num(i,1);
		FC_82_y(i,1) = ff82(i,1);
	else
		FC_82_x(i,1) = 0;
		FC_82_y(i,1) = 0;
	end
	if STD1b_idx(i,1) == 1 && reject68(i,1) == 0 && reject67(i,1) == 0 
		SL_82_x(i,1) = analysis_num(i,1);
		SL_82_y(i,1) = ff82(i,1);
	else
		SL_82_x(i,1) = 0;
		SL_82_y(i,1) = 0;
	end
end
FC_82_x = nonzeros(FC_82_x);
FC_82_y = nonzeros(FC_82_y);
SL_82_x = nonzeros(SL_82_x);
SL_82_y = nonzeros(SL_82_y);

for i = 1:data_count		
	if STD1a_idx(i,1) == 1
		FC_232(i,1) = UPB_reduced(i,5); %col GN
		FC_82_OS(i,1) = 100*(Age82(i,1)-1099)/1099; %col GO
	else
		FC_232(i,1) = 0;
		FC_82_OS(i,1) = 0;
	end
	if STD1b_idx(i,1) == 1
		SL_232(i,1) = UPB_reduced(i,5); %col GX
		SL_82_OS(i,1) = 100*(Age82(i,1)-564)/564; %col GY
	else
		SL_232(i,1) = 0;
		SL_82_OS(i,1) = 0;
	end
	if STD2_idx(i,1) == 1
		R33_232(i,1) = UPB_reduced(i,5); %col HH
		R33_82_OS(i,1) = 100*(Age82(i,1)-420)/420; %col HI
	else
		R33_232(i,1) = 0;
		R33_82_OS(i,1) = 0;
	end
end

FC_232 = nonzeros(FC_232);
FC_82_OS = nonzeros(FC_82_OS);
SL_232 = nonzeros(SL_232);
SL_82_OS = nonzeros(SL_82_OS);
R33_232 = nonzeros(R33_232);
R33_82_OS = nonzeros(R33_82_OS);

%% CALCULATE ERRCORR AND REPLACE 'BAD' (<0 OR >1) CORRELATION COEFFICIENT %%%%%
sigmarule=1.5;
numpoints=50;
errcorr_fix = 0.7;
errcorr_hi = errcorr > 1;
errcorr_lo = errcorr < 0;
errcorr_bad = sum(errcorr_hi) + sum(errcorr_lo);
for i = 1:length(errcorr)
	if errcorr(i,:) < 0
		errcorr_corr(i,:) = errcorr_fix;
	elseif errcorr(i,:) > 1
		errcorr_corr(i,:) = errcorr_fix;
	else
		errcorr_corr(i,:) = errcorr(i,:);
	end
end

STD1a_rho = nonzeros(STD1a_idx.*errcorr_corr);
STD1b_rho = nonzeros(STD1b_idx.*errcorr_corr);
STD2_rho = nonzeros(STD2_idx.*errcorr_corr);
rho = errcorr_corr;

STD1a_concordia_data = [nonzeros(STD1a_idx.*ratio75),nonzeros(STD1a_idx.*ratio75err),nonzeros(STD1a_idx.*ratio68),nonzeros(STD1a_idx.*merr68)];
STD1b_concordia_data = [nonzeros(STD1b_idx.*ratio75),nonzeros(STD1b_idx.*ratio75err),nonzeros(STD1b_idx.*ratio68),nonzeros(STD1b_idx.*merr68)];
STD2_concordia_data = [nonzeros(STD2_idx.*ratio75),nonzeros(STD2_idx.*ratio75err),nonzeros(STD2_idx.*ratio68),nonzeros(STD2_idx.*merr68)];
concordia_data = [ratio75,ratio75err,ratio68,merr68];
All_concordia_data = [ratio75,ratio75err,ratio68,merr68];

center_STD1a = [STD1a_concordia_data(:,1),STD1a_concordia_data(:,3)];
center_STD1b = [STD1b_concordia_data(:,1),STD1b_concordia_data(:,3)];
center_STD2 = [STD2_concordia_data(:,1),STD2_concordia_data(:,3)];
center = [concordia_data(:,1),concordia_data(:,3)];
center_All = [concordia_data(:,1),concordia_data(:,3)];

sigx_abs_STD1a = STD1a_concordia_data(:,1).*STD1a_concordia_data(:,2).*0.01;
sigy_abs_STD1a = STD1a_concordia_data(:,3).*STD1a_concordia_data(:,4).*0.01;

sigx_abs_STD1b = STD1b_concordia_data(:,1).*STD1b_concordia_data(:,2).*0.01;
sigy_abs_STD1b = STD1b_concordia_data(:,3).*STD1b_concordia_data(:,4).*0.01;

sigx_abs_STD2 = STD2_concordia_data(:,1).*STD2_concordia_data(:,2).*0.01;
sigy_abs_STD2 = STD2_concordia_data(:,3).*STD2_concordia_data(:,4).*0.01;

sigx_abs = concordia_data(:,1).*concordia_data(:,2).*0.01;
sigy_abs = concordia_data(:,3).*concordia_data(:,4).*0.01;

sigx_abs_All = concordia_data(:,1).*concordia_data(:,2).*0.01;
sigy_abs_All = concordia_data(:,3).*concordia_data(:,4).*0.01;

sigx_sq_STD1a = sigx_abs_STD1a.*sigx_abs_STD1a;
sigy_sq_STD1a = sigy_abs_STD1a.*sigy_abs_STD1a;

sigx_sq_STD1b = sigx_abs_STD1b.*sigx_abs_STD1b;
sigy_sq_STD1b = sigy_abs_STD1b.*sigy_abs_STD1b;

sigx_sq_STD2 = sigx_abs_STD2.*sigx_abs_STD2;
sigy_sq_STD2 = sigy_abs_STD2.*sigy_abs_STD2;

sigx_sq = sigx_abs.*sigx_abs;
sigy_sq = sigy_abs.*sigy_abs;

sigx_sq_All = sigx_abs.*sigx_abs;
sigy_sq_All = sigy_abs.*sigy_abs;

rho_sigx_sigy_STD1a = sigx_abs_STD1a.*sigy_abs_STD1a.*STD1a_rho;
rho_sigx_sigy_STD1b = sigx_abs_STD1b.*sigy_abs_STD1b.*STD1b_rho;
rho_sigx_sigy_STD2 = sigx_abs_STD2.*sigy_abs_STD2.*STD2_rho;
rho_sigx_sigy = sigx_abs.*sigy_abs.*rho;
rho_sigx_sigy_All = sigx_abs.*sigy_abs.*rho;

%% POPULATE LISTBOX, SAMPLE INTENSITIES, AND PLOT INDIVIDUAL SAMPLE RAW DATA %%
name_idx = length(sample); %automatically plot final sample run

for i=1:length(sample)
	name_char(i,1)=(sample(i,1));
end

Ablate = numbers(1+(73*(name_idx-1)):(73+(73*(name_idx-1))),2) - numbers(1+(73*(name_idx-1)),2);


%% CURRENT STATUS %%

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;

for i = 1:data_count
	if isempty(comment{i,1}) == 1 
		current_status{i,1} = ['Accepted'];
		current_status_num(i,1) = 1;
	else
		current_status{i,1} = ['Rejected: ', comment{i,1}];
		current_status_num(i,1) = 0;
	end
end

current_status_num_orig = current_status_num;

if current_status_num(name_idx,1) == 1
	set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');
elseif current_status_num(name_idx,1) == 0
	set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');
end

for i=1:length(sample)
	if isempty(comment{i,1}) == 0 
		name_char(i,1) = strcat('<html><BODY bgcolor="red">',name_char(i,1),'</span></html>');
	end
end















%% SET HANDLES %%


export_dist = 0;

H.current_status_num = current_status_num; H.SAMPLE_CONCORDIA = SAMPLE_CONCORDIA; H.data_count = data_count; H.sample_idx = sample_idx;
H.ffse68_hi = ffse68_hi; H.ffse68_lo = ffse68_lo; H.ffsw68 = ffsw68; 


H.FC_IC_x = FC_IC_x; H.FC_IC_y = FC_IC_y; H.FC_MI_x = FC_MI_x; H.FC_MI_y = FC_MI_y; H.FC_AN_x = FC_AN_x;
H.FC_AN_y = FC_AN_y; H.SL_IC_x = SL_IC_x; H.SL_IC_y = SL_IC_y; H.SL_MI_x = SL_MI_x; H.SL_MI_y = SL_MI_y; H.SL_AN_x = SL_AN_x; H.SL_AN_y = SL_AN_y; H.R33_IC_x = R33_IC_x;
H.R33_IC_y = R33_IC_y; H.R33_MI_x = R33_MI_x; H.R33_MI_y = R33_MI_y; H.R33_AN_x = R33_AN_x; H.R33_AN_y = R33_AN_y;
H.ffse67_hi = ffse67_hi; H.ffse67_lo = ffse67_lo; H.ffsw67 = ffsw67; H.FC_67_x = FC_67_x; H.FC_67_y = FC_67_y; H.SL_67_x = SL_67_x; H.SL_67_y = SL_67_y;
H.ffse82_hi = ffse82_hi; H.ffse82_lo = ffse82_lo; H.ffsw82 = ffsw82; H.FC_82_x = FC_82_x; H.FC_82_y = FC_82_y; H.SL_82_x = SL_82_x; H.SL_82_y = SL_82_y;

H.sigx_sq_STD1a = sigx_sq_STD1a; H.rho_sigx_sigy_STD1a = rho_sigx_sigy_STD1a; H.sigy_sq_STD1a = sigy_sq_STD1a; H.numpoints = numpoints; H.sigmarule = sigmarule;
H.STD_FC_68 = STD_FC_68; H.STD_FC_67 = STD_FC_67; H.center_STD1a = center_STD1a; H.sigx_sq_STD1b = sigx_sq_STD1b; H.rho_sigx_sigy_STD1b = rho_sigx_sigy_STD1b;
H.sigy_sq_STD1b = sigy_sq_STD1b; H.STD_SL_68 = STD_SL_68; H.STD_SL_67 = STD_SL_67; H.center_STD1b = center_STD1b; H.sigx_sq_STD2 = sigx_sq_STD2; H.rho_sigx_sigy_STD2 = rho_sigx_sigy_STD2;
H.sigy_sq_STD2 = sigy_sq_STD2; H.STD_R33_68 = STD_R33_68; H.STD_R33_67 = STD_R33_67; H.center_STD2 = center_STD2; H.sigx_sq_All = sigx_sq_All; H.rho_sigx_sigy_All = rho_sigx_sigy_All;
H.sigy_sq_All = sigy_sq_All; H.center_All = center_All; H.values_all = values_all; H.current_status = current_status; H.current_status_num_orig = current_status_num_orig; 
H.comment = comment; H.Macro_1_2_Output = Macro_1_2_Output; H.STD1a_idx = STD1a_idx; H.STD1b_idx = STD1b_idx; H.STD2_idx = STD2_idx; H.ratio75 = ratio75; H.ratio75err = ratio75err;
H.ratio68 = ratio68; H.merr68 = merr68; H.Best_Age = Best_Age; H.Best_Age_err = Best_Age_err; H.rho = rho; H.errcorr = errcorr; H.Age82 = Age82; H.Age82err = Age82err;
H.Age68 = Age68; H.Age68err = Age68err; H.Age67 = Age67; H.Age67err = Age67err; H.Macro1_Output = Macro1_Output; H.AGES_OUT = AGES_OUT; 
H.CORRECTED_CONC_RATIOS = CORRECTED_CONC_RATIOS; H.AGES_1SD_RANDOM_ERRORS = AGES_1SD_RANDOM_ERRORS; H.REJECTED = REJECTED;
H.xc = xc; H.yc = yc;  H.pbcerr67 = pbcerr67; H.pbcerr68 = pbcerr68; H.ffswse68 = ffswse68; H.ffsw67 = ffsw67; H.ffswse67 = ffswse67;
H.numbers = numbers; H.sample = sample; 
H.export_dist = export_dist;
reduced = 1;
H.reduced = reduced; H.Ablate = Ablate;
H.UPB_reduced = UPB_reduced;
H.TREE = TREE;

if TREE == 1
	H.STD_NIST612pm = STD_NIST612pm;
	H.STD_NIST612ps = STD_NIST612ps;
	H.STD_91500pm = STD_91500pm;
	H.STD_91500ps = STD_91500ps;
	H.STD_MAD559pm = STD_MAD559pm;
	H.STD_MAD559ps = STD_MAD559ps;
	H.NIST612 = NIST612;
	H.MAD559 = MAD559;
	H.s91500 = s91500;
	H.Isotopes = Isotopes;
	H.ChonNorm91500 = ChonNorm91500;
	H.ChonNormMAD559 = ChonNormMAD559;
	H.ChonNormNIST612 = ChonNormNIST612;
	H.ChonNormAcceptedNIST612 = ChonNormAcceptedNIST612;
	H.ChonNormAccepted91500 = ChonNormAccepted91500;
	H.ChonNormAcceptedMAD559 = ChonNormAcceptedMAD559;
	H.Results_ppm = Results_ppm;
	H.NIST612_idx = NIST612_idx;
	H.Age68 = Age68;
	H.Age67 = Age67;
	H.Best_Age = Best_Age;
end

if get(H.auto_reduce,'Value') == 0
	guidata(hObject,H);
end

plot_session_fract(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)
set(H.listbox1, 'String', name_char);
set(H.listbox1,'Value',length(sample));
listbox1_Callback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)

%% PLOT SESSION FRACTIONATION %%
function plot_session_fract(hObject, eventdata, H)

TREE = H.TREE;
if TREE == 1 && get(H.tree,'Value') == 1

	set(H.plot_fract_68,'Value',0)
	set(H.plot_fract_76,'Value',0)
	set(H.plot_fract_82,'Value',0)
	set(H.tree,'Value',1)
	cla(H.axes_session_fractionation)
	set(H.axes_session_fractionation,'Visible','off')
	set(H.export_fractionation,'Visible','off')
	set(H.TREEcalib,'Visible','on')
	set(H.TREEnorm,'Visible','on')
	set(H.t91500,'Visible','on')
	set(H.tMAD559,'Visible','on')
	set(H.slider91500,'Visible','on')
	set(H.sliderMAD559,'Visible','on')
	set(H.calibslider,'Visible','on')
	set(H.treeplotter,'Visible','on')
	
	STD_NIST612pm = H.STD_NIST612pm;
	STD_NIST612ps = H.STD_NIST612ps;
	STD_91500pm = H.STD_91500pm;
	STD_91500ps = H.STD_91500ps;
	STD_MAD559pm = H.STD_MAD559pm;
	STD_MAD559ps = H.STD_MAD559ps;
	NIST612 = H.NIST612;
	MAD559 = H.MAD559;
	s91500 = H.s91500;
	Isotopes = H.Isotopes;
	ChonNorm91500 = H.ChonNorm91500;
	ChonNormMAD559 = H.ChonNormMAD559;
	ChonNormNIST612 = H.ChonNormNIST612;
	ChonNormAcceptedNIST612 = H.ChonNormAcceptedNIST612;
	ChonNormAccepted91500 = H.ChonNormAccepted91500;
	ChonNormAcceptedMAD559 = H.ChonNormAcceptedMAD559;
	

	axes(H.TREEcalib)
	hold on
	plot([(1:1:25); (1:1:25)], [(STD_NIST612pm+STD_NIST612ps); (STD_NIST612pm-STD_NIST612ps)], '-r', 'Color', 'g', 'LineWidth',4) % Error bars
	plot([(1:1:25); (1:1:25)], [(STD_91500pm+STD_91500ps); (STD_91500pm-STD_91500ps)], '-r', 'Color', 'r', 'LineWidth',4) % Error bars
	plot([(1:1:25); (1:1:25)], [(STD_MAD559pm+STD_MAD559ps); (STD_MAD559pm-STD_MAD559ps)], '-r', 'Color', 'b', 'LineWidth',4) % Error bars
	plot([1:1:25],zeros(1,25),'k','LineWidth',2)
	plot([1:1:25],STD_NIST612pm,'g','LineWidth',2)
	plot([1:1:25],STD_91500pm,'r','LineWidth',2)
	plot([1:1:25],STD_MAD559pm,'b','LineWidth',2)
	s1 = scatter([1:1:25], STD_NIST612pm, 50, 'g', 'filled','s','MarkerEdgeColor','k');
	s2 = scatter([1:1:25], STD_91500pm, 50, 'r', 'filled','d','MarkerEdgeColor','k');
	s3 = scatter([1:1:25], STD_MAD559pm, 50, 'b', 'filled','o','MarkerEdgeColor','k');
	legend([s1 s3 s2], [{NIST612}, {MAD559}, {s91500}], 'Location','northeast');
	xlim ([0.5 25.5]);
	ax1 = gca;
	ax1.XTick = [1:1:25];
	ax1.XTickLabel = Isotopes;
	ylabel('% Residual (Measured - Known)')
	ylim([-100 100])

	axes(H.TREEnorm)
	hold on
	for i = 1:length(ChonNorm91500(:,1))
		plot([1:1:14],ChonNorm91500(i,8:21),'--', 'Color', [.6 0 0], 'LineWidth',1)
	end
	for i = 1:length(ChonNormMAD559(:,1))
		plot([1:1:14],ChonNormMAD559(i,8:21),'--', 'Color', [0 0 .6],'LineWidth',1)
	end
	for i = 1:length(ChonNormNIST612(:,1))
		plot([1:1:14],ChonNormNIST612(i,8:21),'--', 'Color', [0 .6 0], 'LineWidth',1)
	end
	plot([1:1:14],ChonNormAcceptedNIST612,'g','LineWidth',2)
	plot([1:1:14],ChonNormAccepted91500,'r','LineWidth',2)
	plot([1:1:14],ChonNormAcceptedMAD559,'b','LineWidth',2)
	s4 = scatter([1:1:14], ChonNormAcceptedNIST612, 50, 'g', 'filled','s','MarkerEdgeColor','k');
	s5 = scatter([1:1:14], ChonNormAccepted91500, 50, 'r', 'filled','d','MarkerEdgeColor','k');
	s6 = scatter([1:1:14], ChonNormAcceptedMAD559, 50, 'b', 'filled','o','MarkerEdgeColor','k');
	legend([s4 s6 s5], [{'NIST612 Accepted'}, {'MAD559 Accepted'}, {'91500 Accepted'}], 'Location','southeast');
	xlim ([0.5 14.5]);
	ax2 = gca;
	ax2.XTick = [1:1:14];
	ax2.XTickLabel = Isotopes(1,8:21);
	set(gca, 'YScale', 'log')
	ylabel('% Chondrite Normalized REE Concentrations')
end

if get(H.tree,'Value') == 0
if H.export_fract == 1
	figure;
end
if H.export_fract == 0
	cla(H.axes_session_fractionation,'reset');
	axes(H.axes_session_fractionation);	
end
H.export_fract = 0;
guidata(hObject,H);
hold on
if get(H.plot_fract_68,'Value') == 1
	fill([(1:1:H.data_count)';flipud((1:1:H.data_count)')], [H.ffse68_hi; flipud(H.ffse68_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
	plot([(1:1:H.data_count); (1:1:H.data_count)], [(H.ffsw68+H.ffsw68*0.02)'; (H.ffsw68-H.ffsw68*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',.5) % Error bars
	h1 = scatter(H.FC_IC_x, H.FC_IC_y, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
	h2 = scatter(H.FC_MI_x, H.FC_MI_y, 75, 'r', 'd', 'LineWidth', 1.25);
	h3 = scatter(H.FC_AN_x, H.FC_AN_y, 75, 'r', 'x', 'LineWidth', 1.25);
	h4 = scatter(H.SL_IC_x, H.SL_IC_y, 75, 'b', 'filled', 'd', 'LineWidth', 1.25);
	h5 = scatter(H.SL_MI_x, H.SL_MI_y, 75, 'b', 'd', 'LineWidth', 1.25);
	h6 = scatter(H.SL_AN_x, H.SL_AN_y, 75, 'b', 'x', 'LineWidth', 1.25);
	h7 = scatter(H.R33_IC_x, H.R33_IC_y, 75,  'd','MarkerEdgeColor', [0.1 0.7 0.1], 'MarkerFaceColor', [0.1 0.7 0.1], 'LineWidth', 1.25);
	h8 = scatter(H.R33_MI_x, H.R33_MI_y, 75, 'g', 'd','MarkerEdgeColor', [0.1 0.7 0.1], 'LineWidth', 1.25);
	h9 = scatter(H.R33_AN_x, H.R33_AN_y, 75, 'g', 'x', 'MarkerEdgeColor', [0.1 0.7 0.1], 'LineWidth', 1.25);
	if get(H.legon_f,'Value') == 1
		leg = legend([h1 h2 h3 h4 h5 h6 h7 h8 h9],{'FC-IC', 'FC-MI', 'FC-AN', 'SL-IC', 'SL-MI', 'SL-AN', 'R33-IC', 'R33-MI', 'R33-AN'});
	end
	%leg.NumColumns = 3;
	hold off
	xlabel('Analysis number')
	ylabel('Pb206/U238 fractionation factor')
	axis([0 H.data_count+1 min([(H.ffsw68-H.ffsw68*0.02);H.FC_IC_y;H.FC_MI_y;H.FC_AN_y;H.SL_IC_y;H.SL_MI_y;H.SL_AN_y;H.R33_IC_y;H.R33_MI_y;H.R33_AN_y])-...
		0.02*min([(H.ffsw68-H.ffsw68*0.02);H.FC_IC_y;H.FC_MI_y;H.FC_AN_y;H.SL_IC_y;H.SL_MI_y;H.SL_AN_y;H.R33_IC_y;H.R33_MI_y;H.R33_AN_y])...
		max([(H.ffsw68-H.ffsw68*0.02);H.FC_IC_y;H.FC_MI_y;H.FC_AN_y;H.SL_IC_y;H.SL_MI_y;H.SL_AN_y;H.R33_IC_y;H.R33_MI_y;H.R33_AN_y])+...
		0.02*max([(H.ffsw68-H.ffsw68*0.02);H.FC_IC_y;H.FC_MI_y;H.FC_AN_y;H.SL_IC_y;H.SL_MI_y;H.SL_AN_y;H.R33_IC_y;H.R33_MI_y;H.R33_AN_y])])
	box on
end
if get(H.plot_fract_76,'Value') == 1
	fill([(1:1:H.data_count)';flipud((1:1:H.data_count)')], [H.ffse67_hi; flipud(H.ffse67_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
	plot([(1:1:H.data_count); (1:1:H.data_count)], [(H.ffsw67+H.ffsw67*0.02)'; (H.ffsw67-H.ffsw67*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',.5) % Error bars
	h1 = scatter(H.FC_67_x, H.FC_67_y, 85, 'r', 'filled', 's', 'LineWidth', 1.25);
	h2 = scatter(H.SL_67_x, H.SL_67_y, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
	if get(H.legon_f,'Value') == 1
		legend([h1 h2],{'FC', 'SL'});
	end
	hold off
	xlabel('Analysis number')
	ylabel('Pb206/Pb207 fractionation factor')
	axis([0 H.data_count+1 min([(H.ffsw67-H.ffsw67*0.02);H.FC_67_y;H.SL_67_y])-0.02*min([(H.ffsw67-H.ffsw67*0.02);H.FC_67_y;H.SL_67_y]) max([(H.ffsw67-H.ffsw67*0.02);H.FC_67_y;H.SL_67_y])+...
		0.02*max([(H.ffsw67-H.ffsw67*0.02);H.FC_67_y;H.SL_67_y])])
	box on
end
if get(H.plot_fract_82,'Value') == 1
	fill([(1:1:H.data_count)';flipud((1:1:H.data_count)')], [H.ffse82_hi; flipud(H.ffse82_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
	plot([(1:1:H.data_count); (1:1:H.data_count)], [(H.ffsw82+H.ffsw82*0.02)'; (H.ffsw82-H.ffsw82*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',.5) % Error bars
	h1 = scatter(H.FC_82_x, H.FC_82_y, 85, 'r', 'filled', 's', 'LineWidth', 1.25);
	h2 = scatter(H.SL_82_x, H.SL_82_y, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
	if get(H.legon_f,'Value') == 1
		legend([h1 h2],{'FC', 'SL'});
	end
	hold off
	xlabel('Analysis number')
	ylabel('Pb208/Th232 fractionation factor')
	axis([0 H.data_count+1 min([(H.ffsw82-H.ffsw82*0.02);H.FC_82_y;H.SL_82_y])-0.02*min([(H.ffsw82-H.ffsw82*0.02);H.FC_82_y;H.SL_82_y]) max([(H.ffsw82-H.ffsw82*0.02);H.FC_82_y;H.SL_82_y])+...
		0.02*max([(H.ffsw82-H.ffsw82*0.02);H.FC_82_y;H.SL_82_y])])
	box on
end
end

function plot_fract_68_Callback(hObject, eventdata, H)
set(H.plot_fract_68,'Value',1)
set(H.plot_fract_76,'Value',0)
set(H.plot_fract_82,'Value',0)
set(H.tree,'Value',0)
cla(H.TREEcalib)
cla(H.TREEnorm)
set(H.axes_session_fractionation,'Visible','on')
set(H.export_fractionation,'Visible','on')
set(H.TREEcalib,'Visible','off')
set(H.TREEnorm,'Visible','off')
set(H.t91500,'Visible','off')
set(H.tMAD559,'Visible','off')
set(H.slider91500,'Visible','off')
set(H.sliderMAD559,'Visible','off')
set(H.calibslider,'Visible','off')
set(H.treeplotter,'Visible','off')
if H.reduced == 1
	plot_session_fract(hObject, eventdata, H)
end

function plot_fract_76_Callback(hObject, eventdata, H)
set(H.plot_fract_68,'Value',0)
set(H.plot_fract_76,'Value',1)
set(H.plot_fract_82,'Value',0)
set(H.tree,'Value',0)
cla(H.TREEcalib)
cla(H.TREEnorm)
set(H.axes_session_fractionation,'Visible','on')
set(H.export_fractionation,'Visible','on')
set(H.TREEcalib,'Visible','off')
set(H.TREEnorm,'Visible','off')
set(H.t91500,'Visible','off')
set(H.tMAD559,'Visible','off')
set(H.slider91500,'Visible','off')
set(H.sliderMAD559,'Visible','off')
set(H.calibslider,'Visible','off')
set(H.treeplotter,'Visible','off')
if H.reduced == 1
	plot_session_fract(hObject, eventdata, H)
end

function plot_fract_82_Callback(hObject, eventdata, H)
set(H.plot_fract_68,'Value',0)
set(H.plot_fract_76,'Value',0)
set(H.plot_fract_82,'Value',1)
set(H.tree,'Value',0)
cla(H.TREEcalib)
cla(H.TREEnorm)
set(H.axes_session_fractionation,'Visible','on')
set(H.export_fractionation,'Visible','on')
set(H.TREEcalib,'Visible','off')
set(H.TREEnorm,'Visible','off')
set(H.t91500,'Visible','off')
set(H.tMAD559,'Visible','off')
set(H.slider91500,'Visible','off')
set(H.sliderMAD559,'Visible','off')
set(H.calibslider,'Visible','off')
set(H.treeplotter,'Visible','off')
if H.reduced == 1
	plot_session_fract(hObject, eventdata, H)
end

function tree_Callback(hObject, eventdata, H)
set(H.plot_fract_68,'Value',0)
set(H.plot_fract_76,'Value',0)
set(H.plot_fract_82,'Value',0)
set(H.tree,'Value',1)
cla(H.axes_session_fractionation)
set(H.axes_session_fractionation,'Visible','off')
set(H.export_fractionation,'Visible','off')
set(H.TREEcalib,'Visible','on')
set(H.TREEnorm,'Visible','on')
set(H.t91500,'Visible','on')
set(H.tMAD559,'Visible','on')
set(H.slider91500,'Visible','on')
set(H.sliderMAD559,'Visible','on')
set(H.calibslider,'Visible','on')
set(H.treeplotter,'Visible','on')
if H.reduced == 1
	plot_session_fract(hObject, eventdata, H)
end

function export_fractionation_Callback(hObject, eventdata, H)
H.export_fract = 1;
guidata(hObject,H);
plot_session_fract(hObject, eventdata, H)

function standardnames_Callback(hObject, eventdata, H)
plot_session_fract(hObject, eventdata, H)

function legon_f_Callback(hObject, eventdata, H)
plot_session_fract(hObject, eventdata, H)

%% PLOT SESSION COMPARE %%
function plot_compare(hObject, eventdata, H)

if get(H.auto_reduce,'Value') == 0
	timerout = timerfindall;
	delete(timerout);
end

if H.reduced == 1
	if H.export_comp == 1
		figure;
	end
	if H.export_comp == 0
		cla(H.axes_comp,'reset');
		axes(H.axes_comp);	
	end
	H.export_comp = 0;
	guidata(hObject,H);
	hold on
	
	sigx_sq_STD1a = H.sigx_sq_STD1a; rho_sigx_sigy_STD1a = H.rho_sigx_sigy_STD1a; sigy_sq_STD1a = H.sigy_sq_STD1a;	
	STD_FC_68 = H.STD_FC_68; STD_FC_67 = H.STD_FC_67; center_STD1a = H.center_STD1a;sigx_sq_STD1b = H.sigx_sq_STD1b; rho_sigx_sigy_STD1b = H.rho_sigx_sigy_STD1b;
	sigy_sq_STD1b = H.sigy_sq_STD1b; STD_SL_68 = H.STD_SL_68; STD_SL_67 = H.STD_SL_67;	center_STD1b = H.center_STD1b;
	sigx_sq_STD2 = H.sigx_sq_STD2;	rho_sigx_sigy_STD2 = H.rho_sigx_sigy_STD2;	sigy_sq_STD2 = H.sigy_sq_STD2;	
	STD_R33_68 = H.STD_R33_68;	STD_R33_67 = H.STD_R33_67;	center_STD2 = H.center_STD2;sigx_sq_All = H.sigx_sq_All;	rho_sigx_sigy_All = H.rho_sigx_sigy_All;
	sigy_sq_All = H.sigy_sq_All; 	numpoints = H.numpoints; sigmarule = H.sigmarule; center_All = H.center_All; sample_idx = H.sample_idx;
	current_status_num = H.current_status_num;

	dtcut = [5000000, 30; 5000000,-30];
	z = [0, 0; 30000000, 0];
	timemin = 0;
	timemax = 4500000000;
	timeinterval = str2num(get(H.concint,'String'))*1000000;
	time = timemin:timeinterval:timemax;
	x = exp(0.00000000098485.*time)-1;
	y = exp(0.000000000155125.*time)-1;
	
	% CONCORDIAS %
	if get(H.FC_conc,'Value') == 1
		FC75 = STD_FC_68*137.82*(1/STD_FC_67);
		age_labelSTD_x = FC75;
		age_labelSTD_y = STD_FC_68;
		age_labelSTD = {'1098.1'};
		sigx_sq = sigx_sq_STD1a;
		rho_sigx_sigy = rho_sigx_sigy_STD1a;
		sigy_sq = sigy_sq_STD1a;
		center = center_STD1a;
		agelabelmin = 1000000000;
		agelabelint = 10000000;
		agelabelmax = 1200000000;
	end
	if get(H.SL_conc,'Value') == 1
		SL75 = STD_SL_68*137.82*(1/STD_SL_67);
		age_labelSTD_x = SL75;
		age_labelSTD_y = STD_SL_68;
		age_labelSTD = {'558.0'};
		sigx_sq = sigx_sq_STD1b;
		rho_sigx_sigy = rho_sigx_sigy_STD1b;
		sigy_sq = sigy_sq_STD1b;
		center = center_STD1b;
		agelabelmin = 460000000;
		agelabelint = 10000000;
		agelabelmax = 660000000;
	end
	if get(H.R33_conc,'Value') == 1
		R3375 = STD_R33_68*137.82*(1/STD_R33_67);
		age_labelSTD_x = R3375;
		age_labelSTD_y = STD_R33_68;
		age_labelSTD = {'419.3'};
		sigx_sq = sigx_sq_STD2;
		rho_sigx_sigy = rho_sigx_sigy_STD2;
		sigy_sq = sigy_sq_STD2;
		center = center_STD2;
		agelabelmin = 320000000;
		agelabelint = 10000000;
		agelabelmax = 520000000;
	end
	if get(H.Unk_conc,'Value') == 1 
		for i = 1:length(sample_idx)
			if sample_idx(i,1) == 1
				sigx_sq(i,1) = sigx_sq_All(i,1);
				rho_sigx_sigy(i,1) = rho_sigx_sigy_All(i,1);
				sigy_sq(i,1) = sigy_sq_All(i,1);
				center(i,1:2) = center_All(i,1:2);
			else
				sigx_sq(i,1) = 0;
				rho_sigx_sigy(i,1) = 0;
				sigy_sq(i,1) = 0;				
				center(i,1:2) = [0,0];
			end
		end
		agelabelmin = 0;
		agelabelint = str2num(get(H.concint,'String'))*1000000;
		agelabelmax = 4000000000;
		sigx_sq = sigx_sq(any(sigx_sq ~= 0,2),:);
		rho_sigx_sigy = rho_sigx_sigy(any(rho_sigx_sigy ~= 0,2),:);
		sigy_sq = sigy_sq(any(sigy_sq ~= 0,2),:);
		center = center(any(center ~= 0,2),:);
	end
%{	
	if get(H.setax,'Value') == 1
		for i = 1:length(center(:,1))
			if center(i,1) > str2num(get(H.setxmin,'String')) && center(i,1) < str2num(get(H.setxmax,'String')) && center(i,2) > str2num(get(H.setymin,'String')) && ...
					center(i,2) < str2num(get(H.setymax,'String'))
				data(i,:) = data(i,:);
			else
				data(i,1:5) = 0;
			end
		end
	end
%}
	sigmarule1s=1.5;
	sigmarule2s=2.5;
	scalar = .01;
	scaling = 2^9;

	if get(H.FC_conc,'Value') == 1 || get(H.SL_conc,'Value') == 1 || get(H.R33_conc,'Value') == 1 || get(H.Unk_conc,'Value') == 1
		set(H.conct,'enable','on')
		set(H.concmin,'enable','on')
		set(H.concmint,'enable','on')
		set(H.concmax,'enable','on')
		set(H.concmaxt,'enable','on')
		set(H.concint,'enable','on')
		set(H.concintt,'enable','on')

		timemin = 0;
		timemax = 4500000000;
		timeinterval = 5000000;
		time = timemin:timeinterval:timemax;
		xC = exp(0.00000000098485.*time)-1;
		yC = exp(0.000000000155125.*time)-1;

		age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
		age_label_x = exp(0.00000000098485.*age_label_num)-1;
		age_label_y = exp(0.000000000155125.*age_label_num)-1;

		for i=1:length(age_label_num)
			age_label(i,1) = {sprintf('%.0f',age_label_num(1,i)/1000000)};
			age_label2(i,1) = strcat(age_label(i,1),' Ma');
		end
		
	% 1 sigma 2D concordia
	for i = 1:length(center(:,1))
		covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
		[PD,PV]=eig(covmat);
		PV=diag(PV).^.5;
		theta=linspace(0,2.*pi,numpoints)';
		elpt1s=[cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma1s=length(sigmarule1s);
		elpt1s=repmat(elpt1s,1,numsigma1s).*repmat(sigmarule1s(floor(1:.5:numsigma1s+.5)),numpoints,1);
		elpt1s=elpt1s+repmat(center(i,1:2),numpoints,numsigma1s);
		elpt1s_out(:,:,i)=elpt1s+repmat(center(i,1:2),numpoints,numsigma1s);
		if get(H.conc1s,'Value') == 1 && get(H.conc3D,'Value') == 0
			if get(H.Unk_conc,'Value') == 1
				if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
					elpt1s_out_acc(:,:,i) = elpt1s;
					p1 = plot(elpt1s_out_acc(:,1:2:end,i),elpt1s_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
				end
				if sample_idx(i,1) == 1 && current_status_num(i,1) == 0
					elpt1s_out_rej(:,:,i) = elpt1s;
					p2 = plot(elpt1s_out_rej(:,1:2:end,i),elpt1s_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
				end
			end
			if get(H.Unk_conc,'Value') == 0
				plot(elpt1s(:,1:2:end),elpt1s(:,2:2:end),'b','LineWidth', 1);
			end
		end
	end

	% 2 sigma 2D concordia
	for i = 1:length(center(:,1))
		covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
		[PD,PV]=eig(covmat);
		PV=diag(PV).^.5;
		theta=linspace(0,2.*pi,numpoints)';
		elpt2s=[cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma2s=length(sigmarule2s);
		elpt2s=repmat(elpt2s,1,numsigma2s).*repmat(sigmarule2s(floor(1:.5:numsigma2s+.5)),numpoints,1);
		elpt2s=elpt2s+repmat(center(i,1:2),numpoints,numsigma2s);
		elpt2s_out(:,:,i)=elpt2s;
		if get(H.conc2s,'Value') == 1 && get(H.conc3D,'Value') == 0
			if get(H.Unk_conc,'Value') == 1
				if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
					elpt2s_out_acc(:,:,i) = elpt2s;
					p1 = plot(elpt2s_out_acc(:,1:2:end,i),elpt2s_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
				end
				if sample_idx(i,1) == 1 && current_status_num(i,1) == 0
					elpt2s_out_rej(:,:,i) = elpt2s;
					p2 = plot(elpt2s_out_rej(:,1:2:end,i),elpt2s_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
				end
			end
			if get(H.Unk_conc,'Value') == 0
				plot(elpt2s(:,1:2:end),elpt2s(:,2:2:end),'b','LineWidth', 1);
			end
		end
	end
	% set x-y limits
	if min(min(elpt2s_out(:,1,:)))-max(max(elpt2s_out(:,1,:)))*scalar <= 0 
		xlo = 0;
	else
		xlo = min(min(elpt2s_out(:,1,:)))-max(max(elpt2s_out(:,1,:)))*scalar;
	end
	if min(min(elpt2s_out(:,2,:)))-max(max(elpt2s_out(:,2,:)))*scalar <= 0
		ylo = 0;
	else
		ylo = min(min(elpt2s_out(:,2,:)))-max(max(elpt2s_out(:,2,:)))*scalar; 
	end
	xhi = max(max(elpt2s_out(:,1,:)))+max(max(elpt2s_out(:,1,:)))*scalar;
	yhi = max(max(elpt2s_out(:,2,:)))+max(max(elpt2s_out(:,2,:)))*scalar;

	if get(H.conc3D,'Value') == 1
		
		
		
		
		xlo = str2double(get(H.setxmin,'String'))
		xhi = str2double(get(H.setxmax,'String'))

		ylo = str2double(get(H.setymin,'String'))
		yhi = str2double(get(H.setymax,'String'))
		
	xdiff = xhi - xlo;
	ydiff = yhi - ylo;
	xr = xdiff/(scaling);
	yr = ydiff/(scaling);
	xF = xlo:xr:xhi;
	yF = ylo:yr:yhi;
	[X,Y] = meshgrid(xF,yF);

	for k = 1:length(center_All(:,1)) 
		if center_All(k,1) > str2double(get(H.setxmin,'String')) && center_All(k,1) < str2double(get(H.setxmax,'String')) ...
				&& center_All(k,2) > str2double(get(H.setymin,'String')) && center_All(k,2) < str2double(get(H.setymax,'String')) && sample_idx(k,1) == 1	
			sigx_sq2(k,1) = sigx_sq(k,1);
			rho_sigx_sigy2(k,1) = rho_sigx_sigy(k,1);
			%rho_sigx_sigy2(k,1) =rho_sigx_sigy(k,1);
			sigy_sq2(k,1) = sigy_sq(k,1);
			center_All2(k,:) = center_All(k,:);
		else
			sigx_sq2(k,1) = 0;
			rho_sigx_sigy2(k,1) = 0;
			rho_sigx_sigy2(k,1) = 0;
			sigy_sq2(k,1) = 0;
			center_All2(k,:) = [0,0];
		end
	end
		sigx_sq2 = nonzeros(sigx_sq2);
		rho_sigx_sigy2 = nonzeros(rho_sigx_sigy2);
		%rho_sigx_sigy2 = nonzeros(rho_sigx_sigy2);
		sigy_sq2 = nonzeros(sigy_sq2);
		center_All2 = center_All2(any(center_All2 ~= 0,2),:);

	for i = 1:length(center_All2(:,1))	
		covmat2=[sigx_sq2(i,1),rho_sigx_sigy2(i,1);rho_sigx_sigy2(i,1),sigy_sq2(i,1)];
		F = mvnpdf([X(:) Y(:)],center_All2(i,1:2),covmat2);
		F = reshape(F,length(yF),length(xF));
		zmax = max(max(F));
		F_out(:,:,i) = F./sum(F,'All');
	end
	Fsum = sum(F_out,3);
	Fnorm = Fsum./sum(Fsum,'All');
	Fnormmax = max(max(Fnorm));
	H.Fnormmax = Fnormmax;
	F1s = Fnormmax*0.317;
	F2s = Fnormmax*0.05;
	surf(xF,yF,Fnorm);
	caxis([min(Fnorm(:))-.5*range(Fnorm(:)),max(Fnorm(:))]);
	colormap(jet)
	shading interp

	if get(H.conc3D,'Value') == 1 && get(H.conc3D1s,'Value') == 1
		contour3(xF,yF,Fnorm,[F1s F1s], 'b', 'LineWidth', 4)
	end
	if get(H.conc3D,'Value') == 1 && get(H.conc3D2s,'Value') == 1
		contour3(xF,yF,Fnorm,[F2s F2s], 'b', 'LineWidth', 4)
	end

	if get(H.conc1s,'Value') == 1
		for i = 1:length(center(:,1))
			covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
			[PD,PV]=eig(covmat);
			PV=diag(PV).^.5;
			theta=linspace(0,2.*pi,numpoints)';
			elpt1s=[cos(theta),sin(theta)]*diag(PV)*PD';
			numsigma1s=length(sigmarule1s);
			elpt1s=repmat(elpt1s,1,numsigma1s).*repmat(sigmarule1s(floor(1:.5:numsigma1s+.5)),numpoints,1);
			elpt1s=elpt1s+repmat(center(i,1:2),numpoints,numsigma1s);
			zrep1s = repmat(Fnormmax,[length(elpt1s(:,1)),1]);
			plot3(elpt1s(:,1:2:end),elpt1s(:,2:2:end),zrep1s,'b','LineWidth', 0.5);
		end
	end

	if get(H.conc2s,'Value') == 1
		for i = 1:length(center(:,1))
			covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
			[PD,PV]=eig(covmat);
			PV=diag(PV).^.5;
			theta=linspace(0,2.*pi,numpoints)';
			elpt2s=[cos(theta),sin(theta)]*diag(PV)*PD';
			numsigma2s=length(sigmarule2s);
			elpt2s=repmat(elpt2s,1,numsigma2s).*repmat(sigmarule2s(floor(1:.5:numsigma2s+.5)),numpoints,1);
			elpt2s=elpt2s+repmat(center(i,1:2),numpoints,numsigma2s);
			zrep2s = repmat(Fnormmax,[length(elpt2s(:,1)),1]);
			plot3(elpt2s(:,1:2:end),elpt2s(:,2:2:end),zrep2s,'b','LineWidth', 0.5);
		end
	end

	zrep1 = repmat(Fnormmax,[length(xC(1,:)),1]);
	plot3(xC',yC',zrep1,'k','LineWidth',1.4)
	plot3(xC',yC',zrep1.*0.25,'k','LineWidth',0.5)
	plot3(xC',yC',zrep1.*0.5,'k','LineWidth',0.5)
	plot3(xC',yC',zrep1.*0.75,'k','LineWidth',0.5)
		for i = 1:length(age_label_num)
			if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
				scatter3(age_label_x(1,i), age_label_y(1,i), Fnormmax+Fnormmax*.01, 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
				text(age_label_x(1,i)+0.005, age_label_y(1,i),Fnormmax+Fnormmax*.01, age_label2(i,1), 'FontWeight', 'bold')
				plot3([age_label_x(1,i), age_label_x(1,i)], [age_label_y(1,i), age_label_y(1,i)], [0, Fnormmax], 'LineWidth', 1, 'Color', 'k')
			end
		end
	end
	
	if get(H.FC_conc,'Value') == 1 || get(H.SL_conc,'Value') == 1 || get(H.R33_conc,'Value') == 1 || get(H.Unk_conc,'Value') == 1
		if get(H.conc3D,'Value') == 0
			plot(xC,yC,'k','LineWidth',1.4)
			for i = 1:length(age_label_num)
				if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
					scatter3(age_label_x(1,i), age_label_y(1,i), 1, 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
					text(age_label_x(1,i)+0.005, age_label_y(1,i),age_label2(i,1), 'FontWeight', 'bold')
				end
			end
		end
		if get(H.conc3D,'Value') == 0
			if get(H.samplenames,'Value') == 1 || get(H.concpoints,'Value') == 1
				for i = 1:length(H.sample)
					if H.ratio75(i,1) > str2double(get(H.setxmin,'String')) && H.ratio75(i,1) < str2double(get(H.setxmax,'String')) ...
							&& H.ratio68(i,1) > str2double(get(H.setymin,'String')) && H.ratio68(i,1) < str2double(get(H.setymax,'String'))
						if get(H.samplenames,'Value') == 1
							text(H.ratio75(i,1)+0.008, H.ratio68(i,1),1,H.sample(i,1), 'FontWeight', 'bold')
						end	
						if get(H.concpoints,'Value') == 1
							if current_status_num(i,1) == 1
								scatter3(H.ratio75(i,1), H.ratio68(i,1), 1, 50, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b', 'LineWidth', 1.5)
							else
								scatter3(H.ratio75(i,1), H.ratio68(i,1), 1, 50, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', 'LineWidth', 1.5)
							end
						end
					end
				end
			end
		end
		if get(H.conc3D,'Value') == 1
			if get(H.samplenames,'Value') == 1 || get(H.concpoints,'Value') == 1
				for i = 1:length(H.sample)
					if H.ratio75(i,1) > str2double(get(H.setxmin,'String')) && H.ratio75(i,1) < str2double(get(H.setxmax,'String')) ...
							&& H.ratio68(i,1) > str2double(get(H.setymin,'String')) && H.ratio68(i,1) < str2double(get(H.setymax,'String'))
						if get(H.samplenames,'Value') == 1
							text(H.ratio75(i,1)+0.008, H.ratio68(i,1),Fnormmax+Fnormmax*.01,H.sample(i,1), 'FontWeight', 'bold')
						end	
						if get(H.concpoints,'Value') == 1
							if current_status_num(i,1) == 1
								scatter3(H.ratio75(i,1), H.ratio68(i,1), Fnormmax+Fnormmax*.01, 50, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b', 'LineWidth', 1.5)
							else
								scatter3(H.ratio75(i,1), H.ratio68(i,1), Fnormmax+Fnormmax*.01, 50, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', 'LineWidth', 1.5)
							end
						end
					end
				end
			end
		end
	end
	
	%if get(H.Unk_conc,'Value') == 1 && get(H.comp_legon,'Value') == 1
	%	legend([p1,p2],'Accepted Analyses','Rejected Analyses','Location','northwest');
	%end
	
	if get(H.FC_conc,'Value') == 1 || get(H.SL_conc,'Value') == 1 || get(H.R33_conc,'Value') == 1
		if get(H.conc3D,'Value') == 0 && get(H.Unk_conc,'Value') == 0
			p1 = scatter(age_labelSTD_x, age_labelSTD_y,120,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
			if get(H.comp_legon,'Value') == 1
				legend([p1],strcat('Accepted Age:', {' '}, age_labelSTD, {' '}, 'Ma'),'Location','northwest');
			end
		end
		if get(H.conc3D,'Value') == 1 && get(H.Unk_conc,'Value') == 0
			p1 = scatter3(age_labelSTD_x, age_labelSTD_y,Fnormmax+Fnormmax*.02,120,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
			if get(H.comp_legon,'Value') == 1
				legend([p1],strcat('Accepted Age:', {' '}, age_labelSTD, {' '}, 'Ma'),'Location','northwest');
			end
		end
	end

	xlabel('207Pb/235U');
	ylabel('206Pb/238U');
	if get(H.defaultaxes,'Value') == 1
		axis([xlo xhi ylo yhi])
		set(H.setxmin,'String',xlo)
		set(H.setxmax,'String',xhi)
		set(H.setymin,'String',ylo)
		set(H.setymax,'String',yhi)
	end
	if get(H.setax,'Value') == 1
		axis([str2double(get(H.setxmin,'String')) str2double(get(H.setxmax,'String')) str2double(get(H.setymin,'String')) str2double(get(H.setymax,'String'))])
	end
	end
	
	

		

	
	

	
	
	
	
	
	
	
	
	
	if get(H.ageuconc,'Value') == 1 || get(H.ageraddos,'Value') == 1 || get(H.ageuth,'Value') == 1 || get(H.ageconc,'Value') == 1
		set(H.conct,'enable','off')
		set(H.concmin,'enable','off')
		set(H.concmint,'enable','off')
		set(H.concmax,'enable','off')
		set(H.concmaxt,'enable','off')
		set(H.concint,'enable','off')
		set(H.concintt,'enable','off')
		
		
		
		Macro_1_2_Output = H.Macro_1_2_Output;
		for i = 1:length(Macro_1_2_Output(:,1))
			if sum(size(cell2mat(Macro_1_2_Output(i,41)))) > 0 
				age68(i,1) = cell2num(Macro_1_2_Output(i,37));
				age67(i,1) = cell2num(Macro_1_2_Output(i,39));
				bestage(i,1) = cell2num(Macro_1_2_Output(i,41));
				u(i,1) = cell2num(Macro_1_2_Output(i,46));
				th(i,1) = cell2num(Macro_1_2_Output(i,47));
				uth(i,1) = cell2num(Macro_1_2_Output(i,50));
			end
		end

		if get(H.ageuconc,'Value') == 1
			u(~isfinite(u))=0;
			bestage(~isfinite(bestage))=0;
			u = nonzeros(u);
			bestage = nonzeros(bestage);
			axes(H.axes_comp);
			cla(H.axes_comp,'reset');
			s1 = scatter(u, bestage, 50, 'b', 'd', 'LineWidth', 1.25);
			xlabel('U ppm')
			ylabel('Best Age (Ma)')
		end

		if get(H.ageraddos,'Value') == 1 

			u(~isfinite(u))=0;
			th(~isfinite(th))=0;
			bestage(~isfinite(bestage))=0;
			u = nonzeros(u);
			th = nonzeros(th);
			bestage = nonzeros(bestage);
			for i = 1:length(u)
				raddos(i,1) = 8*u(i,1)*(exp(0.000000000155*bestage(i,1)*1000000)-1)+7*(u(i,1)/137.82)*(exp(0.000000000985*bestage(i,1)*1000000)-1)...
					+6*th(i,1)*(exp(0.0000000000495*bestage(i,1)*1000000)-1);
			end
			axes(H.axes_comp);
			cla(H.axes_comp,'reset');
			s1 = scatter(raddos, bestage, 50, 'b', 'd', 'LineWidth', 1.25);
			xlabel('Radiation Dosage (alpha decays/µg)')
			ylabel('Best Age (Ma)')
		end

		if get(H.ageuth,'Value') == 1
			uth(~isfinite(uth))=0;
			bestage(~isfinite(bestage))=0;
			uth = nonzeros(uth);
			bestage = nonzeros(bestage);
			axes(H.axes_comp);
			cla(H.axes_comp,'reset');
			s1 = scatter(uth, bestage, 50, 'b', 'd', 'LineWidth', 1.25);
			xlabel('U/Th')
			ylabel('Best Age (Ma)')
		end

		if get(H.ageconc,'Value') == 1
			age68(~isfinite(age68))=0;
			age67(~isfinite(age67))=0;
			bestage(~isfinite(bestage))=0;
			age68 = nonzeros(age68);
			age67 = nonzeros(age67);
			bestage = nonzeros(bestage);
			for i = 1:length(age68)
				if 100*age68(i,1)/age67(i,1) < 200 && 100*age68(i,1)/age67(i,1) > 10
					concordance(i,1) = 100*age68(i,1)/age67(i,1);
					bestage(i,1) = bestage(i,1);
				else
					concordance(i,1) = 0;
					bestage(i,1) = 0;
				end
			end
			concordance = nonzeros(concordance);
			bestage = nonzeros(bestage);
			axes(H.axes_comp);
			cla(H.axes_comp,'reset');
			s1 = scatter(concordance, bestage, 50, 'b', 'd', 'LineWidth', 1.25);
			xlabel('Concordance (%)')
			ylabel('Best Age (Ma)')
		end
		
		if get(H.comp_legon,'Value') == 1
			legend(s1,'Accepted Unknowns','Location','northeast');
		else
			legend('hide')
		end
		if get(H.defaultaxes,'Value') == 1
			x1 = xlim;
			y1 = ylim;
			set(H.setxmin,'String',x1(1,1))
			set(H.setxmax,'String',x1(1,2))
			set(H.setymin,'String',y1(1,1))
			set(H.setymax,'String',y1(1,2))
		end
		if get(H.setax,'Value') == 1
			axis([str2double(get(H.setxmin,'String')) str2double(get(H.setxmax,'String')) str2double(get(H.setymin,'String')) str2double(get(H.setymax,'String'))])
		end
	end
end
guidata(hObject,H);

function comp_legon_Callback(hObject, eventdata, H)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function setxmin_Callback(hObject, eventdata, H)
set(H.setax,'Value',1)
set(H.defaultaxes,'Value',0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function setxmax_Callback(hObject, eventdata, H)
set(H.setax,'Value',1)
set(H.defaultaxes,'Value',0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function setymin_Callback(hObject, eventdata, H)
set(H.setax,'Value',1)
set(H.defaultaxes,'Value',0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function setymax_Callback(hObject, eventdata, H)
set(H.setax,'Value',1)
set(H.defaultaxes,'Value',0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function concmin_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)

function concmax_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)

function concint_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)

function setax_Callback(hObject, eventdata, H)
set(H.setax,'Value',1)
set(H.defaultaxes,'Value',0)
limx = get(H.axes_comp,'XLim');
limy = get(H.axes_comp,'YLim');
set(H.setxmin,'String',limx(1,1))
set(H.setxmax,'String',limx(1,2))
set(H.setymin,'String',limy(1,1))
set(H.setymax,'String',limy(1,2))

function defaultaxes_Callback(hObject, eventdata, H)
set(H.defaultaxes,'Value',1)
set(H.setax,'Value',0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function conc1s_Callback(hObject, eventdata, H)
%set(H.conc1s,'Value',1)
%set(H.conc2s,'Value',0)
if get(H.FC_conc,'Value') == 0 && get(H.SL_conc,'Value') == 0 && get(H.R33_conc,'Value') == 0 && get(H.Unk_conc,'Value') == 0
	set(H.FC_conc,'Value', 1)
end
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function conc2s_Callback(hObject, eventdata, H)
%set(H.conc1s,'Value',0)
%set(H.conc2s,'Value',1)
if get(H.FC_conc,'Value') == 0 && get(H.SL_conc,'Value') == 0 && get(H.R33_conc,'Value') == 0 && get(H.Unk_conc,'Value') == 0
	set(H.FC_conc,'Value', 1)
end
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function concpoints_Callback(hObject, eventdata, H)
if get(H.FC_conc,'Value') == 0 && get(H.SL_conc,'Value') == 0 && get(H.R33_conc,'Value') == 0 && get(H.Unk_conc,'Value') == 0
	set(H.FC_conc,'Value', 1)
	set(H.conc1s,'Value',1)
end
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function samplenames_Callback(hObject, eventdata, H)
if get(H.FC_conc,'Value') == 0 && get(H.SL_conc,'Value') == 0 && get(H.R33_conc,'Value') == 0 && get(H.Unk_conc,'Value') == 0
	set(H.FC_conc,'Value', 1)
	set(H.conc1s,'Value',1)
end
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function FC_conc_Callback(hObject, eventdata, H)
set(H.FC_conc,'Value', 1)
if get(H.conc1s,'Value') == 0 && get(H.conc2s,'Value') == 0 && get(H.conc3D,'Value') == 0
	set(H.conc1s,'Value', 1)
end
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function SL_conc_Callback(hObject, eventdata, H)
set(H.FC_conc,'Value', 0)
set(H.SL_conc,'Value', 1)
if get(H.conc1s,'Value') == 0 && get(H.conc2s,'Value') == 0 && get(H.conc3D,'Value') == 0
	set(H.conc1s,'Value', 1)
end
set(H.R33_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function R33_conc_Callback(hObject, eventdata, H)
set(H.FC_conc,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 1)
if get(H.conc1s,'Value') == 0 && get(H.conc2s,'Value') == 0 && get(H.conc3D,'Value') == 0
	set(H.conc1s,'Value', 1)
end
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function Unk_conc_Callback(hObject, eventdata, H)
set(H.FC_conc,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.Unk_conc,'Value', 1)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
if get(H.conc1s,'Value') == 0 && get(H.conc2s,'Value') == 0
	set(H.conc1s,'Value', 1)
end
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function Unk_conc_acc_Callback(hObject, eventdata, H)
set(H.FC_conc,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 1)
set(H.Unk_conc_rej,'Value', 0)
if get(H.conc1s,'Value') == 0 && get(H.conc2s,'Value') == 0
	set(H.conc1s,'Value', 1)
end
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function Unk_conc_rej_Callback(hObject, eventdata, H)
set(H.FC_conc,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 1)
if get(H.conc1s,'Value') == 0 && get(H.conc2s,'Value') == 0
	set(H.conc1s,'Value', 1)
end
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function conc3D_Callback(hObject, eventdata, H)
if get(H.FC_conc,'Value') == 0 && get(H.SL_conc,'Value') == 0 && get(H.R33_conc,'Value') == 0 && get(H.Unk_conc,'Value') == 0 && get(H.Unk_conc_acc,'Value') == 0 && get(H.Unk_conc_rej,'Value') == 0
	set(H.FC_conc,'Value', 1)
end
if get(H.conc3D,'Value') == 0 
	set(H.conc3D1s,'Value', 0)
	set(H.conc3D2s,'Value', 0)
end
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function conc3D1s_Callback(hObject, eventdata, H)
if get(H.conc3D,'Value') == 0
	set(H.conc3D,'Value', 1)
end
if get(H.FC_conc,'Value') == 0 && get(H.SL_conc,'Value') == 0 && get(H.R33_conc,'Value') == 0 && get(H.Unk_conc,'Value') == 0 && get(H.Unk_conc_acc,'Value') == 0 && get(H.Unk_conc_rej,'Value') == 0 && get(H.conc3D,'Value') == 0 
	set(H.FC_conc,'Value', 1)
	set(H.conc3D,'Value', 1)
end
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function conc3D2s_Callback(hObject, eventdata, H)
if get(H.conc3D,'Value') == 0
	set(H.conc3D,'Value', 1)
end
if get(H.FC_conc,'Value') == 0 && get(H.SL_conc,'Value') == 0 && get(H.R33_conc,'Value') == 0 && get(H.Unk_conc,'Value') == 0 && get(H.Unk_conc_acc,'Value') == 0 && get(H.Unk_conc_rej,'Value') == 0 && get(H.conc3D,'Value') == 0
	set(H.FC_conc,'Value', 1)
	set(H.conc3D,'Value', 1)
end
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function ageuconc_Callback(hObject, eventdata, H)
set(H.conc1s,'Value', 0)
set(H.conc3D2s,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.FC_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
set(H.conc3D,'Value', 0)
set(H.conc3D1s,'Value', 0)
set(H.conc3D2s,'Value', 0)
set(H.ageuconc,'Value', 1)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function ageraddos_Callback(hObject, eventdata, H)
set(H.conc1s,'Value', 0)
set(H.conc3D2s,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.FC_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
set(H.conc3D,'Value', 0)
set(H.conc3D1s,'Value', 0)
set(H.conc3D2s,'Value', 0)
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 1)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function ageuth_Callback(hObject, eventdata, H)
set(H.conc1s,'Value', 0)
set(H.conc3D2s,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.FC_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
set(H.conc3D,'Value', 0)
set(H.conc3D1s,'Value', 0)
set(H.conc3D2s,'Value', 0)
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 1)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function ageconc_Callback(hObject, eventdata, H)
set(H.conc1s,'Value', 0)
set(H.conc3D2s,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.FC_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
set(H.conc3D,'Value', 0)
set(H.conc3D1s,'Value', 0)
set(H.conc3D2s,'Value', 0)
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 1)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function export_comparison_Callback(hObject, eventdata, H)
H.export_comp = 1;
H.point = 0;
guidata(hObject,H);
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function AP_Callback(hObject, eventdata, H)
global use_avg_ACF use_235 use_FC_68 use_FC_67 use_SL_68 use_SL_67 use_R33_68 deadtime lowint_238 lin_238 lowint_206 lin_206 lin_232 numbers data sample2 factor64 rejectFC rejectSL rejectR33 ...
	odf68 bestage_cutoff filter_cutoff filter_err68 filter_err67 filter_disc filter_disc_rev filter_64 values_all data_count STD1a_idx STD1b_idx STD2_idx sample_idx UPBdata UPB_pre
ACF

%% PLOT INDIVIDUAL SAMPLES %%
function listbox1_Callback(hObject, eventdata, H)
values_all = H.values_all;
Ablate = H.Ablate;
current_status = H.current_status;
current_status_num = H.current_status_num;
current_status_num_orig = H.current_status_num_orig;

name_idx = get(H.listbox1,'Value');

values = values_all(:,:,name_idx);

if current_status_num(name_idx,1) == 1
	set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');
elseif current_status_num(name_idx,1) == 0
	set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');
end



for i = 1:73
	for j = 1:8
		if values(i,j) < 0 
			values2(i,j) = 0.0000000001;
		elseif values(i,j) == 0 
			values2(i,j) = 0.0000000001;
		else
			values2(i,j) = values(i,j);
		end
	end
end
values2(:,9) = values2(:,3)./values2(:,8);
values2(:,10) = values2(:,3)./values2(:,4);
values2(:,11) = values2(:,5)./values2(:,6);

if get(H.log_scale, 'Value') == 1
	plot_vals = log10(values2);
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end

C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[0 1 0],[1 0 1]}; % Cell array of colors

axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

hold on
if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U235,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness, 'color',C{7});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,8),'linewidth', thickness, 'color',C{8});
end
if get(H.chk_Pb206_U238,'Value')==1 
plot(Ablate,plot_vals(:,9),'linewidth', thickness, 'color', 'k');
end
if get(H.chk_Pb206_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,10),'linewidth', thickness, 'color', 'k');
end
if get(H.chk_Pb208_Th232,'Value')==1 
plot(Ablate,plot_vals(:,11),'linewidth', thickness, 'color', 'k');
end

hold off
xlabel('Time (seconds)')

if get(H.chk_Pb206_U238, 'Value') == 0 & get(H.chk_Pb206_Pb207,'Value')==0 || get(H.chk_Pb208_Th232,'Value')==0 
	if get(H.log_scale, 'Value') == 1
		ylabel('Intensity (log10 cps)')
		axis([0 max(Ablate) 1 max(max(plot_vals(:,1:8)))+max(max(plot_vals(:,1:8)))*.05])
	end
end
if get(H.chk_Pb206_U238, 'Value') == 1 || get(H.chk_Pb206_Pb207,'Value')==1 || get(H.chk_Pb208_Th232,'Value')==1 
	if get(H.log_scale, 'Value') == 1 
		ylabel('Intensity (log10 cps)')
	end
end
if get(H.log_scale, 'Value') == 0
    ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])

box on

ratio75 = H.ratio75;
ratio75err = H.ratio75err;
ratio68 = H.ratio68;
merr68 = H.merr68;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
comment = H.comment;

axes(H.axes_current_concordia);
cla(H.axes_current_concordia,'reset');

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
hold on
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age(name_idx,1))}, {' ± '},  {sprintf('%.1f',Best_Age_err(name_idx,1))}, {' Ma'});

concordia_data = [ratio75(name_idx,1), ratio75err(name_idx,1), ratio68(name_idx,1), merr68(name_idx,1)];
center = [concordia_data(:,1),concordia_data(:,3)];
sigx_abs = concordia_data(:,1).*concordia_data(:,2).*0.01;
sigy_abs = concordia_data(:,3).*concordia_data(:,4).*0.01;
sigx_sq = sigx_abs.*sigx_abs;
sigy_sq = sigy_abs.*sigy_abs;
rho_sigx_sigy = sigx_abs.*sigy_abs.*rho(name_idx,1);

covmat=[sigx_sq,rho_sigx_sigy;rho_sigx_sigy,sigy_sq];
[PD,PV]=eig(covmat);
PV = diag(PV).^.5;
theta = linspace(0,2.*pi,numpoints)';
elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
numsigma = length(sigmarule);
elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt_out = elpt + repmat(center,numpoints,numsigma);

plot(elpt_out(:,1:2:end),elpt_out(:,2:2:end),'b','LineWidth',1.2);
hold on
plot(xc,yc,'k','LineWidth',1.4)

xaxismin = ratio75(name_idx,1) - 0.015.*ratio75(name_idx,1);
xaxismax = ratio75(name_idx,1) + 0.015.*ratio75(name_idx,1);
yaxismin = ratio68(name_idx,1) - 0.015.*ratio68(name_idx,1);
yaxismax = ratio68(name_idx,1) + 0.015.*ratio68(name_idx,1);

xaxismin_Myr = log(xaxismin+1)/0.00000000098485/1000000;
xaxismax_Myr = log(xaxismax+1)/0.00000000098485/1000000;
yaxismin_Myr = log(yaxismin+1)/0.000000000155125/1000000;
yaxismax_Myr = log(yaxismax+1)/0.000000000155125/1000000;

diff_avg = ((xaxismax_Myr - xaxismin_Myr) + (yaxismax_Myr - yaxismin_Myr))/2;

if diff_avg > 0.5 && diff_avg < 2
	timeinterval = 500000;
elseif diff_avg > 2 && diff_avg < 5
	timeinterval = 1000000;
elseif diff_avg > 5 && diff_avg < 10
	timeinterval = 2000000;
elseif diff_avg > 10 && diff_avg < 20
	timeinterval = 5000000;
elseif diff_avg > 20 && diff_avg < 50
	timeinterval = 10000000;
elseif diff_avg > 50 && diff_avg < 100
	timeinterval = 25000000;
elseif diff_avg > 100 && diff_avg < 200
	timeinterval = 50000000;
elseif diff_avg > 200
	timeinterval = 100000000;
end

time3 = 1000000*(round(min(xaxismin_Myr,yaxismin_Myr)/(timeinterval/1000000))*(timeinterval/1000000))-20000000:timeinterval:1000000*(round(max(xaxismax_Myr,yaxismax_Myr)/(timeinterval/1000000))*(timeinterval/1000000))+20000000;
x3 = (exp(0.00000000098485.*time3)-1)';
y3 = (exp(0.000000000155125.*time3)-1)';

if diff_avg >= 1
for i=1:length(x3)
age_label3(i,1) = {sprintf('%.0f',time3(1,i)/1000000)};
end
else 
for i=1:length(x3)
age_label3(i,1) = {sprintf('%.1f',time3(1,i)/1000000)};
end
end

for i = 1:length(time3)
if x3(i,1) > min(min(elpt_out(:,1,:))) - min(min(elpt_out(:,1,:)))*.01 && x3(i,1) < max(max(elpt_out(:,1,:))) + max(max(elpt_out(:,1,:)))*.01 ...
	&& y3(i,1) > min(min(elpt_out(:,2,:))) - min(min(elpt_out(:,2,:)))*.01 && y3(i,1) < max(max(elpt_out(:,2,:))) + max(max(elpt_out(:,2,:)))*.01
scatter(x3(i,1), y3(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x3(i,1), y3(i,1), age_label3(i,1), 'SE', .0002);
end
end
axis([min(min(elpt_out(:,1,:))) - min(min(elpt_out(:,1,:)))*.01 max(max(elpt_out(:,1,:))) + max(max(elpt_out(:,1,:)))*.01 ...
	min(min(elpt_out(:,2,:))) - min(min(elpt_out(:,2,:)))*.01 max(max(elpt_out(:,2,:))) + max(max(elpt_out(:,2,:)))*.01]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');

if current_status_num(name_idx,1) == 1 && current_status_num_orig(name_idx,1) == 1 
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');

elseif current_status_num(name_idx,1) == 0 && current_status_num_orig(name_idx,1) == 0 
current_status{name_idx, 1} = comment{name_idx,1};
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');

elseif current_status_num(name_idx,1) == 1 && current_status_num_orig(name_idx,1) == 0 
current_status{name_idx, 1} = strcat({'Accepted with '}, comment{name_idx,1});
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');

elseif current_status_num(name_idx,1) == 0 && current_status_num_orig(name_idx,1) == 1 
current_status{name_idx, 1} = {'Rejected, but originally was accepted'};
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');

end
legend(p3, bestage,  'Location', 'northwest');
box on
guidata(hObject,H);

function accept_reject_Callback(hObject, eventdata, H)

name_idx = get(H.listbox1,'Value');

H.current_status_num(name_idx,1) = abs(H.current_status_num(name_idx,1) - 1);

if H.current_status_num(name_idx,1) == 1 && H.current_status_num_orig(name_idx,1) == 1 
	H.current_status{name_idx, 1} = ['Accepted'];
	set(H.status, 'String', H.current_status{name_idx,1},'ForegroundColor','blue');

elseif H.current_status_num(name_idx,1) == 0 && H.current_status_num_orig(name_idx,1) == 0 
	H.current_status{name_idx, 1} = ['Rejected: ', H.comment{name_idx,1}];
	set(H.status, 'String', H.current_status{name_idx,1},'ForegroundColor','red');

elseif H.current_status_num(name_idx,1) == 1 && H.current_status_num_orig(name_idx,1) == 0 
	H.current_status{name_idx, 1} = strcat({'Accepted with '}, H.comment{name_idx,1});
	set(H.status, 'String', H.current_status{name_idx,1},'ForegroundColor','blue');

elseif H.current_status_num(name_idx,1) == 0 && H.current_status_num_orig(name_idx,1) == 1 
	H.current_status{name_idx, 1} = {'Rejected, but originally was accepted'};
	set(H.status, 'String', H.current_status{name_idx,1},'ForegroundColor','red');
end

currView = get(H.listbox1,'ListBoxTop');
set(H.listbox1,'ListBoxTop',currView)

clear SAMPLE_CONCORDIA

H.SAMPLE_CONCORDIA{H.data_count+1, 13} = [];
H.SAMPLE_CONCORDIA(1,:) = {'7/5 ratio', '±(%)', '6/8 ratio', '±(%)', 'errcorr', '6/8 age', '±(Ma)', '6/7 age', '±(Ma)', 'BEST AGE', '±(Ma)', '8/2 age', '±(Ma)'};

for i = 1:H.data_count
	if H.STD1a_idx(i,1) == 0 && H.STD1b_idx(i,1) == 0 && H.STD2_idx(i,1) == 0 && isempty(H.comment{i,1}) == 1 && H.current_status_num(i,1) == 1 && H.sample_idx(i,1) == 1
		H.SAMPLE_CONCORDIA(i+1,:) = [num2cell(H.ratio75(i,:)), num2cell(H.ratio75err(i,:)), num2cell(H.ratio68(i,:)), num2cell(H.merr68(i,:)), num2cell(H.errcorr(i,:)), ...
			H.Age68(i,:), H.Age68err(i,:), H.Age67(i,:), H.Age67err(i,:), H.Best_Age(i,:), H.Best_Age_err(i,:), H.Age82(i,:), H.Age82err(i,:)];
	end
end

H.Macro_1_2_Output = [H.Macro1_Output, H.AGES_OUT, H.REJECTED, H.SAMPLE_CONCORDIA, H.CORRECTED_CONC_RATIOS, H.AGES_1SD_RANDOM_ERRORS];

plot_distribution(hObject, eventdata, H)

for i=1:length(H.sample)
	name_char(i,1)=(H.sample(i,1));
end

for i=1:length(H.sample)
	if H.current_status_num(i,1) == 0 
		name_char(i,1) = strcat('<html><BODY bgcolor="red">',name_char(i,1),'</span></html>');
	end
end

set(H.listbox1, 'String', name_char);

guidata(hObject,H);

function log_scale_Callback(hObject, eventdata, H)
listbox1_Callback(hObject, eventdata, H)

function thick_lines_Callback(hObject, eventdata, H)
listbox1_Callback(hObject, eventdata, H)

function chk_Hg202_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U235,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end
listbox1_Callback(hObject, eventdata, H)

function chk_Pb204_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U235,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end
listbox1_Callback(hObject, eventdata, H)

function chk_Pb206_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U235,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end
listbox1_Callback(hObject, eventdata, H)

function chk_Pb207_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U235,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end
listbox1_Callback(hObject, eventdata, H)

function chk_Pb208_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U235,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end
listbox1_Callback(hObject, eventdata, H)

function chk_Th232_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U235,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end
listbox1_Callback(hObject, eventdata, H)

function chk_U235_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U235,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end
listbox1_Callback(hObject, eventdata, H)

function chk_U238_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U235,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end
listbox1_Callback(hObject, eventdata, H)

function chk_Pb206_U238_Callback(hObject, eventdata, H)
if get(H.chk_Pb206_U238,'Value')==1 
	set(H.chk_Hg202,'Value', 0);
	set(H.chk_Pb204,'Value', 0);
	set(H.chk_Pb206,'Value', 0);
	set(H.chk_Pb207,'Value', 0);
	set(H.chk_Pb208,'Value', 0);
	set(H.chk_Th232,'Value', 0);
	set(H.chk_U235,'Value', 0);
	set(H.chk_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end
listbox1_Callback(hObject, eventdata, H)

function chk_Pb206_Pb207_Callback(hObject, eventdata, H)
if get(H.chk_Pb206_Pb207,'Value')==1 
	set(H.chk_Hg202,'Value', 0);
	set(H.chk_Pb204,'Value', 0);
	set(H.chk_Pb206,'Value', 0);
	set(H.chk_Pb207,'Value', 0);
	set(H.chk_Pb208,'Value', 0);
	set(H.chk_Th232,'Value', 0);
	set(H.chk_U235,'Value', 0);
	set(H.chk_U238,'Value', 0);
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end
listbox1_Callback(hObject, eventdata, H)

function chk_Pb208_Th232_Callback(hObject, eventdata, H)
if get(H.chk_Pb208_Th232,'Value')==1 
	set(H.chk_Hg202,'Value', 0);
	set(H.chk_Pb204,'Value', 0);
	set(H.chk_Pb206,'Value', 0);
	set(H.chk_Pb207,'Value', 0);
	set(H.chk_Pb208,'Value', 0);
	set(H.chk_Th232,'Value', 0);
	set(H.chk_U235,'Value', 0);
	set(H.chk_U238,'Value', 0);
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
end
listbox1_Callback(hObject, eventdata, H)

%% PLOT DISTRIBUTION %%
function plot_distribution(hObject, eventdata, H)
%if H.reduced == 1
	if H.export_dist == 1
		figure;
	end
	if H.export_dist == 0
		cla(H.axes_distribution, 'reset');
		axes(H.axes_distribution);	
	end
	H.export_dist = 0;
	guidata(hObject,H);
	hold on

	for i = 1:H.data_count
		if H.current_status_num(i,1) == 1 && H.sample_idx(i,1) == 1
			dist_data(i+1,1) = cell2num(H.SAMPLE_CONCORDIA(i+1,10));
			dist_data(i+1,2) = cell2num(H.SAMPLE_CONCORDIA(i+1,11));
			dist_data = dist_data(any(dist_data ~= 0,2),:);
		end
	end
	
	for i = 1:length(dist_data(:,1))
		if dist_data(i,1) > str2double(get(H.xmin,'String')) && dist_data(i,1) < str2double(get(H.xmax,'String'))
			dist_data(i,:) = dist_data(i,:);
		else
			dist_data(i,1:2) = 0;
		end
	end
	
	dist_data = dist_data(any(dist_data ~= 0,2),:);
	
	xmin = str2num(get(H.xmin,'String'));
	xmax = str2num(get(H.xmax,'String'));
	xint = str2num(get(H.xint,'String'));
	bins = str2num(get(H.bins,'String'));
	x=xmin:xint:xmax;
	
	if sum(H.current_status_num) > 0
		if get(H.radio_hist, 'Value') == 1
			bins = str2num(get(H.bins,'String'));
			[counts binCenters] = hist(dist_data(:,1), bins);
			bar(binCenters, counts);
			axis([xmin xmax 0 max(counts)+1])
		end
		if get(H.radio_pdp, 'Value') == 1
			pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
			p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
			lgnd=legend(p, 'Probability Density Plot');
			pdpmax = max(pdp);
			set(lgnd,'Color','w');
			legend boxoff
			xlabel('Age (Ma)','Color','k')
			ylabel('Probability','Color','k')
			axis([xmin xmax 0 pdpmax+0.1*pdpmax])
		end
		if get(H.radio_kde, 'Value') == 1
			if get(H.optimize,'Value') == 1
				xA = transpose(x);
				n = length(dist_data(:,1));
				[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
				kdeA=transpose(interp1(xmesh1, kdeA, xA));
				hl1 = plot(x,kdeA,'Color',[1 0 0]);
				kdemax = max(kdeA);
				axis([xmin xmax 0 kdemax+0.2*kdemax])
				lgnd=legend('Kernel Density Estimate');
				set(hl1,'linewidth',2)
				set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
				set(lgnd,'color','w');
				legend boxoff
				xlabel('Age (Ma)','Color','k')
				ylabel('Probability','Color','k')
			end
			if get(H.Myr_kernel,'Value') == 1
				x=xmin:xint:xmax;
				kernel = str2num(get(H.Myr_Kernel_text,'String'));
				kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
				kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
				hl1 = plot(x,kde1,'Color',[1 0 0]);
				ax1 = gca;
				set(ax1,'XColor','k','YColor','k')
				pdpmax = max(kde1);
				lgnd=legend('Kernel Density Estimate');
				set(hl1,'linewidth',2)
				set(gca,'box','off')
				axis([xmin xmax 0 pdpmax+0.2*pdpmax])
			end
			set(lgnd,'Color','w');
			legend boxoff
			xlabel('Age (Ma)','Color','k')
			ylabel('Probability','Color','k')
		end
		if get(H.radio_pdp_kde, 'Value') == 1
			if get(H.optimize,'Value') == 1
				xA = transpose(x);
				n = length(dist_data(:,1));
				[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
				kdeA=transpose(interp1(xmesh1, kdeA, xA));
				set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
				pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
				pdpmax = max(pdp);
				p1 = plot(x,kdeA*(1/(max(kdeA)/max(pdp))),'Color',[1 0 0]);
				p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
				set(p1,'linewidth',2)
				lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
				axis([xmin xmax 0 pdpmax+0.2*pdpmax])
			end
			if get(H.Myr_kernel,'Value') == 1
				kernel = str2num(get(H.Myr_Kernel_text,'String'));
				kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
				kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint); 
				pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
				pdpmax = max(pdp);
				p1 = plot(x,kde1*(1/(max(kde1)/max(pdp))),'Color',[1 0 0]);
				p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
				set(p1,'linewidth',2)
				axis([xmin xmax 0 pdpmax+0.2*pdpmax])
				lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
				set(p1,'linewidth',2)
			end
			set(lgnd,'Color','w');
			legend boxoff
			xlabel('Age (Ma)','Color','k')
			ylabel('Probability','Color','k')
		end
		if get(H.radio_hist_pdp, 'Value') == 1
			pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
			bins = str2num(get(H.bins,'String'));
			[counts binCenters] = hist(dist_data(:,1), bins);
			bar(binCenters, counts);
			p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
			lgnd=legend(p, 'Probability Density Plot');
			set(lgnd,'color','w');
			legend boxoff
			xlabel('Age (Ma)','Color','k')
			ylabel('Probability','Color','k')
			axis([xmin xmax 0 max(counts)+1])
		end
		if get(H.radio_hist_kde, 'Value') == 1
			if get(H.optimize,'Value') == 1
				[counts binCenters] = hist(dist_data(:,1), bins);
				bar(binCenters, counts);
				xA = transpose(x);
				n = length(dist_data(:,1));
				[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
				kdeA=transpose(interp1(xmesh1, kdeA, xA));
				p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
				kdemax = max(kdeA);
				lgnd=legend(p1,'Kernel Density Estimate');
				set(p1,'linewidth',2)
				set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
				xlabel('Age (Ma)','Color','k')
				ylabel('Number','Color','k')
				axis([xmin xmax 0 max(counts)+1])
			end
			if get(H.Myr_kernel,'Value') == 1
				[counts binCenters] = hist(dist_data(:,1), bins);
				bar(binCenters, counts);
				kernel = str2num(get(H.Myr_Kernel_text,'String'));
				kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
				kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
				p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
				ax1 = gca;
				set(ax1,'XColor','k','YColor','k')
				pdpmax = max(kde1);
				axis([xmin xmax 0 max(counts)+1])
				lgnd=legend(p1,'Kernel Density Estimate');
				set(p1,'linewidth',2)
			end
			set(lgnd,'color','w');
			legend boxoff
			xlabel('Age (Ma)','Color','k')
			ylabel('Number','Color','k')
		end
		if get(H.radio_hist_pdp_kde, 'Value') == 1
			if get(H.optimize,'Value') == 1
				[counts binCenters] = hist(dist_data(:,1), bins);
				bar(binCenters, counts);
				xA = transpose(x);
				n = length(dist_data(:,1));
				[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
				kdeA=transpose(interp1(xmesh1, kdeA, xA));
				p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
				pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
				pdpmax = max(pdp);
				p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
				kdemax = max(kdeA);
				axis([xmin xmax 0 max(counts)+1])
				lgnd=legend([p,p1],'Probability Density Plot','Kernel Density Estimate');
				set(p1,'linewidth',2)
				set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
				xlabel('Age (Ma)','Color','k')
				ylabel('Number','Color','k')
			end
			if get(H.Myr_kernel,'Value') == 1
				[counts binCenters] = hist(dist_data(:,1), bins);
				bar(binCenters, counts);
				kernel = str2num(get(H.Myr_Kernel_text,'String'));
				kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
				kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
				p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
				pdpmax = max(kde1);
				set(p1,'linewidth',2)
				pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
				p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
				axis([xmin xmax 0 max(counts)+1])
				lgnd=legend([p,p1], 'Probability Density Plot','Kernel Density Estimate');
			end
			set(lgnd,'Color','w');
			legend boxoff
			xlabel('Age (Ma)','Color','k')
			ylabel('Number','Color','k')
		end
	end
%end
nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);
H.dist_data = dist_data;
guidata(hObject,H);

function radio_hist_Callback(hObject, eventdata, H)
set(H.radio_hist, 'Value', 1);
set(H.radio_pdp, 'Value', 0);
set(H.radio_kde, 'Value', 0);
set(H.radio_pdp_kde, 'Value', 0);
set(H.radio_hist_pdp, 'Value', 0);
set(H.radio_hist_kde, 'Value', 0);
set(H.radio_hist_pdp_kde, 'Value', 0);
set(H.bins,'Enable','on')
set(H.bins_t,'Enable','on')
set(H.xint,'Enable','on')
set(H.xint_t,'Enable','on')
set(H.Myr_kernel,'Enable','off')
set(H.Myr_Kernel_text,'Enable','off')
set(H.optimize,'Enable','off')
plot_distribution(hObject, eventdata, H)

function radio_pdp_Callback(hObject, eventdata, H)
set(H.radio_hist, 'Value', 0);
set(H.radio_pdp, 'Value', 1);
set(H.radio_kde, 'Value', 0);
set(H.radio_pdp_kde, 'Value', 0);
set(H.radio_hist_pdp, 'Value', 0);
set(H.radio_hist_kde, 'Value', 0);
set(H.radio_hist_pdp_kde, 'Value', 0);
set(H.bins,'Enable','off')
set(H.bins_t,'Enable','off')
set(H.xint,'Enable','on')
set(H.xint_t,'Enable','on')
set(H.Myr_kernel,'Enable','off')
set(H.Myr_Kernel_text,'Enable','off')
set(H.optimize,'Enable','off')
plot_distribution(hObject, eventdata, H)

function radio_kde_Callback(hObject, eventdata, H)
set(H.radio_hist, 'Value', 0);
set(H.radio_pdp, 'Value', 0);
set(H.radio_kde, 'Value', 1);
set(H.radio_pdp_kde, 'Value', 0);
set(H.radio_hist_pdp, 'Value', 0);
set(H.radio_hist_kde, 'Value', 0);
set(H.radio_hist_pdp_kde, 'Value', 0);
set(H.bins,'Enable','off')
set(H.bins_t,'Enable','off')
set(H.xint,'Enable','on')
set(H.xint_t,'Enable','on')
set(H.Myr_kernel,'Enable','on')
set(H.Myr_Kernel_text,'Enable','on')
set(H.optimize,'Enable','on')
plot_distribution(hObject, eventdata, H)

function radio_pdp_kde_Callback(hObject, eventdata, H)
set(H.radio_hist, 'Value', 0);
set(H.radio_pdp, 'Value', 0);
set(H.radio_kde, 'Value', 0);
set(H.radio_pdp_kde, 'Value', 1);
set(H.radio_hist_pdp, 'Value', 0);
set(H.radio_hist_kde, 'Value', 0);
set(H.radio_hist_pdp_kde, 'Value', 0);
set(H.bins,'Enable','off')
set(H.bins_t,'Enable','off')
set(H.xint,'Enable','on')
set(H.xint_t,'Enable','on')
set(H.Myr_kernel,'Enable','on')
set(H.Myr_Kernel_text,'Enable','on')
set(H.optimize,'Enable','on')
plot_distribution(hObject, eventdata, H)

function radio_hist_pdp_Callback(hObject, eventdata, H)
set(H.radio_hist, 'Value', 0);
set(H.radio_pdp, 'Value', 0);
set(H.radio_kde, 'Value', 0);
set(H.radio_pdp_kde, 'Value', 0);
set(H.radio_hist_pdp, 'Value', 1);
set(H.radio_hist_kde, 'Value', 0);
set(H.radio_hist_pdp_kde, 'Value', 0);
set(H.bins,'Enable','on')
set(H.bins_t,'Enable','on')
set(H.xint,'Enable','on')
set(H.xint_t,'Enable','on')
set(H.Myr_kernel,'Enable','off')
set(H.Myr_Kernel_text,'Enable','off')
set(H.optimize,'Enable','off')
plot_distribution(hObject, eventdata, H)

function radio_hist_kde_Callback(hObject, eventdata, H)
set(H.radio_hist, 'Value', 0);
set(H.radio_pdp, 'Value', 0);
set(H.radio_kde, 'Value', 0);
set(H.radio_pdp_kde, 'Value', 0);
set(H.radio_hist_pdp, 'Value', 0);
set(H.radio_hist_kde, 'Value', 1);
set(H.radio_hist_pdp_kde, 'Value', 0);
set(H.bins,'Enable','on')
set(H.bins_t,'Enable','on')
set(H.xint,'Enable','on')
set(H.xint_t,'Enable','on')
set(H.Myr_kernel,'Enable','on')
set(H.Myr_Kernel_text,'Enable','on')
set(H.optimize,'Enable','on')
plot_distribution(hObject, eventdata, H)

function radio_hist_pdp_kde_Callback(hObject, eventdata, H)
set(H.radio_hist, 'Value', 0);
set(H.radio_pdp, 'Value', 0);
set(H.radio_kde, 'Value', 0);
set(H.radio_pdp_kde, 'Value', 0);
set(H.radio_hist_pdp, 'Value', 0);
set(H.radio_hist_kde, 'Value', 0);
set(H.radio_hist_pdp_kde, 'Value', 1);
set(H.bins,'Enable','on')
set(H.bins_t,'Enable','on')
set(H.xint,'Enable','on')
set(H.xint_t,'Enable','on')
set(H.Myr_kernel,'Enable','on')
set(H.Myr_Kernel_text,'Enable','on')
set(H.optimize,'Enable','on')
plot_distribution(hObject, eventdata, H)

function bins_Callback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)

function xmin_Callback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)

function xmax_Callback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)

function xint_Callback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)

function Myr_kernel_Callback(hObject, eventdata, H)
set(H.Myr_kernel, 'Value', 1);
set(H.optimize, 'Value', 0);
plot_distribution(hObject, eventdata, H)

function optimize_Callback(hObject, eventdata, H)
set(H.optimize, 'Value', 1);
set(H.Myr_kernel, 'Value', 0);
plot_distribution(hObject, eventdata, H)

function Myr_Kernel_text_Callback(hObject, eventdata, H)
set(H.Myr_kernel, 'Value', 1);
set(H.optimize, 'Value', 0);
plot_distribution(hObject, eventdata, H)

function export_distribution_Callback(hObject, eventdata, H)
H.export_dist = 1;
guidata(hObject,H);
plot_distribution(hObject, eventdata, H)

%% REJECT STANDARDS AND OVERDISPERSION OPTIONS %%
function reject_std_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)

function reject_no_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)

function reject_yes_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)

function ODF_68_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)

function ODF_67_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)

function ODF_82_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)

%% EXPORT PUSHBUTTONS %%
function savesession_Callback(hObject, eventdata, H)
[file,path] = uiputfile('*.mat','Save file');
save([path file],'H')

function loadsession_Callback(hObject, eventdata, H)
[filename pathname] = uigetfile({'*'},'File Selector','MultiSelect','on');
fullpathname = strcat(pathname, filename);
load(fullpathname,'H')
close(E2AgeCalcML_1_14)

function export_results_Callback(hObject, eventdata, H)
Macro_1_2_Output = H.Macro_1_2_Output;
%[file,path] = uiputfile('*.xls','Save file');
%xlswrite([path file], Macro_1_2_Output);

[file,path] = uiputfile('*.xls','Save file');
%xlswrite([path file], Macro_1_2_Output);
writetable(table(Macro_1_2_Output),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);

function export_geochron_table_Callback(hObject, eventdata, H)
Macro1_Output = H.Macro1_Output; 
Macro_1_2_Output = H.Macro_1_2_Output(2:end,:);

Macro_1_2_Output22222 = H.Macro_1_2_Output;


current_status_num = H.current_status_num;
%STD1_idx = H.STD1_idx;
sample_idx = H.sample_idx;

data_count = H.data_count;
ffsw68 = H.ffsw68;
ffswse68 = H.ffswse68;
pbcerr68 = H.pbcerr68;
%UPB_reduced = H.UPB_reduced;
Age68 = H.Age68;
ffsw67 = H.ffsw67;
ffswse67 = H.ffswse67;
pbcerr67 = H.pbcerr67;


%{
folder_name = H.folder_name;
files=dir([folder_name]); %map out the directory to that folder

for i = 1:size(files,1)
	filenames{i,1} = files(i).name;
end

for i = 1:size(filenames,1)
	if strcmp(filenames(i,1),'.') == 1
		filenames{i,1} = [];
	elseif strcmp(filenames(i,1),'..') == 1
		filenames{i,1} = [];
	end
end

filenames(all(cellfun('isempty',filenames),2),:) = [];
metadata_file = 0;
tmp2 = strfind(filenames(:,1), 'metadata');
for i = 1:length(filenames)
	if isempty(tmp2(~cellfun('isempty',tmp2(i,1)))) == 0
		metadata_file = 1;
		if ispc == 1
			fullpathname_metadata{i,1} = char(strcat(folder_name, '\', filenames{i,1}));
		end
		if ismac == 1
			fullpathname_metadata{i,1} = char(strcat(folder_name, '/', filenames{i,1}));
		end
		fullpathname_metadata = fullpathname_metadata(~cellfun('isempty',fullpathname_metadata));
	end
end


if metadata_file == 1

	[numbers text, data] = xlsread(char(fullpathname_metadata));
	
	tmp3 = strfind(filenames(:,1), '.scancsv');
	for i = 1:length(filenames)
		if isempty(tmp3(~cellfun('isempty',tmp3(i,1)))) == 0
			sample_name = filenames(i,1);
		end
	end
	sample_name = char(sample_name);
	sample_name = sample_name(1:end-8);

	tmp4 = strfind(data(:,1), sample_name);
	for i = 1:length(data(:,1))
		if isempty(tmp4(~cellfun('isempty',tmp4(i,1)))) == 0
			answer{1,1} = sample_name;
			answer{2,1} = data{i,2};
			answer{3,1} = data{i,3};
			answer{4,1} = data{i,7};
			answer{5,1} = data{i,5};
			answer{6,1} = data{i,6};
			answer{7,1} = data{i,9};
			answer{8,1} = data{i,10};
			answer{9,1} = 'N/A';
		end
	end
end
%}

%{
if metadata_file == 0
	prompt = {'Aliquot Name:', 'Stratigraphic Formation Name:', 'Stratigraphic Age:', 'Rock Type', 'Latitude (decimal degrees):',  'Longitude (decimal degrees):', 'Analysis Purpose:', ...
		'Analyst Name:', 'Aliquot Reference:'};
	title = 'Input Metadata';
	dims = [1 35];
	definput = {'20','hsv'};
	answer = inputdlg(prompt, title);
end
%}

% Calculate systematic Uncertainties

%=IF(M3>10,"",SQRT(100*BZ3/BY3*100*BZ3/BY3+CF3*CF3+0.053*0.053+0.2*0.2))

for i = 1:data_count
	if cell2num(Macro_1_2_Output(i,13)) < 10 
		syst_err_68(i,1) = sqrt(100*ffswse68(i,1)/ffsw68(i,1)*100*ffswse68(i,1)/ffsw68(i,1)+pbcerr68(i,1)*pbcerr68(i,1)+0.053*0.053+0.35*0.35);
	else
		syst_err_68(i,1) = 0;
	end
end

systerr68 = 2*mean(nonzeros(syst_err_68));

%=IF(OR(BH3<$V$1,P3>10),"",SQRT(100*CI3/CH3*100*CI3/CH3+(CO3)*(CO3)+0.053*0.053+0.069*0.069+0.2*0.2))

for i = 1:data_count
	if cell2num(Macro_1_2_Output(i,16)) < 10 && Age68(i,1) > str2num(get(H.filter_cutoff,'String'))
		syst_err_67(i,1) = sqrt(100*ffswse67(i,1)/ffsw67(i,1)*100*ffswse67(i,1)/ffsw67(i,1)+(pbcerr67(i,1))*(pbcerr67(i,1))+0.053*0.053+0.069*0.069+0.35*0.35);
	end
end

systerr67 = 2*mean(nonzeros(syst_err_67));

for i = 1:length(current_status_num)
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		export_num(i,1) = 1;
	end
end

geochron_out{sum(export_num)+26, 20} = [];
geochron_out(1:17,1) = [{'Aliquot Name'; 'Stratigraphic Formation Name';'Stratigraphic Age';'Rock Type';'Mineral';'Method';'Latitude';'Longitude';'Internal Uncertainty Level'; ...
	'External Uncertainty 206/238 (% two sigma)';'External Uncertainty 206/207 (% two sigma)';'Analysis Purpose';'Laboratory Name';'Analyst Name'; ...
	'Aliquot Reference';'Aliquot Instrumental Method';'Aliquot Instrumental Reference'}];
%geochron_out(1:4,2) = answer(1:4,1);
geochron_out(5,2) = [{'Zircon'}];
geochron_out(6,2) = [{'U-Pb'}];
%geochron_out(7:8,2) = answer(5:6,1);
%geochron_out(12,2) = answer(7,1);
%geochron_out(14:15,2) = answer(8:9,1);
geochron_out(9,2) = [{'one sigma'}];
geochron_out(10,2) = num2cell(systerr68);
geochron_out(11,2) = num2cell(systerr67);
geochron_out(13,2) = [{'Arizona LaserChron Center'}];
geochron_out(16,2) = [{'LA-ICPMS'}];
geochron_out(17:18,2) = [{'Gehrels, G.E., Valencia, V., Ruiz, J., 2008, Enhanced precision, accuracy, efficiency, and spatial resolution of U-Pb ages by laser ablation-multicollector-inductively coupled plasma-mass spectrometry: Geochemistry, Geophysics, Geosystems, v. 9, Q03017, doi:10.1029/2007GC001805.'; ...
	'Gehrels, G. and Pecha, M., 2014, Detrital zircon U-Pb geochronology and Hf isotope geochemistry of Paleozoic and Triassic passive margin strata of western North America: Geosphere, v. 10 (1), p. 49-65.'}];
geochron_out(23,1:20) = [{'Analysis','U','206Pb','U/Th','206Pb*','±','207Pb*','±','206Pb*','±','error','206Pb*','±','207Pb*','±','206Pb*','±','Best age','±','Conc'}];
geochron_out(24,2:20) = [{'(ppm)','204Pb',' ','207Pb*','(%)','235U','(%)','238U','(%)','corr.','238U','(Ma)','235U','(Ma)','207Pb*','(Ma)','(Ma)','(Ma)','(%)'}];
geochron_out(21,8) = [{'Isotope ratios'}];
geochron_out(21,14) = [{'Apparent ages (Ma)'}];

geochron_out_temp{sum(current_status_num), 69} = [];
for i = 1:length(current_status_num)
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		geochron_out_temp(i,:) = Macro_1_2_Output(i,:);
	end
end

geochron_out_temp(all(cellfun('isempty',geochron_out_temp),2),:) = [];

geochron_out(27:end,1) = geochron_out_temp(:,1);
geochron_out(27:end,2) = geochron_out_temp(:,46);
geochron_out(27:end,3) = geochron_out_temp(:,48);
geochron_out(27:end,4) = geochron_out_temp(:,50);
geochron_out(27:end,5:6) = geochron_out_temp(:,15:16);
geochron_out(27:end,7:11) = geochron_out_temp(:,32:36);
geochron_out(27:end,12:17) = geochron_out_temp(:,60:65);
geochron_out(27:end,18:19) = geochron_out_temp(:,68:69);

for i = 1:length(geochron_out_temp(:,1))
geochron_out(26+i,20) = {(cell2num(geochron_out_temp(i,21))/cell2num(geochron_out_temp(i,23)))*100};
end

[file,path] = uiputfile('*.xls','Save file');
%xlswrite([path file], geochron_out);
writetable(table(geochron_out),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);

function legacycompare_Callback(hObject, eventdata, H)

Macro_1_2_Output = H.Macro_1_2_Output;

for i = 1:length(Macro_1_2_Output(:,1))
	for j = 1:length(Macro_1_2_Output(1,:))
		if cellfun(@isempty,Macro_1_2_Output(i,j)) == 0
			if isnumeric(cell2num(Macro_1_2_Output(i,j)))
				numbers_ML(i,j) = cell2num(Macro_1_2_Output(i,j));
			else
				numbers_ML(i,j) = 0;
			end
		end
	end
end

%numbers_ML(1,:) = [];
%numbers_ML(:,1:2) = [];

numbers_ML(1,:) = [];    %%%%%
numbers_ML(:,1:4) = [];    %%%%%

[filename pathname] = uigetfile({'*'},'Select Original AgeCalc File');
fullpathname = strcat(pathname, filename);


%{
if ispc == 1
	file_copy = strcat(fullpathname, '_copy.csv');
end
if ismac == 1
	file_copy = strcat(fullpathname, '_copy');
end

copyfile(fullpathname, file_copy, 'f');

if ispc == 1
	d1 = [file_copy];[numbers text, data] = csvread(d1);
end
if ismac == 1
	d1 = [file_copy];[numbers text, data] = xlsread(d1);
end
delete(d1);
%}


Data_tmp = importdata(char(fullpathname_data),',',500000);
numbers = num2cell(Data_tmp.data);
numbers_tmp(2:length(numbers(:,1))+1,:) = numbers;
text = Data_tmp.textdata;
data = numbers_tmp;
for i = 1:length(text(:,1))
	for j = 1:length(text(1,:))
		if isempty(text(~cellfun('isempty',text(i,j)))) == 0
			data2(i,j) = text(i,j);
		else
			data(i,j) = numbers_tmp(i,j);
		end
	end
end
numbers = cell2num(numbers);









%numbers(1:2,:) = [];
%numbers(:,73:end) = [];

numbers(1:2,:) = [];    %%%%%
numbers(:,1:3) = [];    %%%%%
numbers(:,66:end) = [];    %%%%%

for i = 1:length(numbers(:,1))
	for j = 1:length(numbers(1,:))
		if isnan(numbers(i,j)) == 0 && isnan(numbers_ML(i,j)) == 0
			Difference(i,j) = numbers_ML(i,j) - numbers(i,j);
		else
			Difference(i,j) = 0;
		end
	end
end

for i = 1:length(numbers(:,1))
	for j = 1:length(numbers(1,:))
		if abs(Difference(i,j)) < 0.0000000001
			Difference(i,j) = 0;
		end
	end
end

idx = ( abs(Difference) > 0 );

XX = reshape(strtrim(cellstr(num2str(Difference(:), '%.7f'))), size(Difference));

for i = 1:length(numbers(:,1))
	for j = 1:length(numbers(1,:))
		if idx(i,j) == 1
			%XX(i,j) = strcat('<html><span style="color: #FF0000; font-weight: bold;">',XX(i,j),'</span></html>');
			XX(i,j) = strcat('<html><BODY bgcolor="red">',XX(i,j),'</span></html>');
		end
		if isnan(numbers(i,j)) == 1 || isnan(numbers_ML(i,j)) == 1
			XX(i,j) = strcat('<html><BODY bgcolor="green">',XX(i,j),'</span></html>');
		end
	end
end

f = figure('Position', [100 100 1000 600], 'NumberTitle', 'off');
t = uitable('Parent', f, 'Position', [50 50 900 500], 'Data', Difference);

if ispc == 1
	head{1,65} = [];
	for i = 1:65
		head(1,i) = Macro_1_2_Output(1,i+2);
	end
end

if ismac == 1
	head{1,65} = [];    
	for i = 1:65    
		head(1,i) = Macro_1_2_Output(1,i+4);
	end
end
t.ColumnName = head;

rownames{length(numbers(:,1)),1} = [];
for i = 1:length(numbers(:,1))
	rownames(i,1) = Macro_1_2_Output(i+1,1);
end
t.RowName = rownames;

set(t, 'Data',XX)

guidata(hObject,H);

function legacy_Callback(hObject, eventdata, H)

function test1_Callback(hObject, eventdata, H)


Macro1_Output = H.Macro1_Output; 
Macro_1_2_Output = H.Macro_1_2_Output(2:end,:);

conc_out = Macro_1_2_Output(:,32:36);

conc_out( all(cellfun(@isempty,conc_out),2), : ) = [];

%% T/REE OPTIONS %%
function calibslider_Callback(hObject, eventdata, H)
perc_MAD559 = get(H.calibslider,'Value');
perc_91500 = 1 - get(H.calibslider,'Value');
set(H.slider91500,'String',round(perc_91500*100,1))
set(H.sliderMAD559,'String',round(perc_MAD559*100,1))
guidata(hObject, H);
%reducedata_Callback(hObject, eventdata, H)

function slider91500_Callback(hObject, eventdata, H)
perc_91500 = str2num(get(H.slider91500,'String'))*.01;
perc_MAD559 = 1 - perc_91500;
set(H.calibslider,'Value',1 - perc_91500)
set(H.sliderMAD559,'String',round(perc_MAD559*100,1))
guidata(hObject, H);
%reducedata_Callback(hObject, eventdata, H)

function sliderMAD559_Callback(hObject, eventdata, H)
perc_MAD559 = str2num(get(H.sliderMAD559,'String'))*.01;
perc_91500 = 1 - perc_MAD559;
set(H.calibslider,'Value',perc_MAD559)
set(H.slider91500,'String',(1 - perc_MAD559)*100)
guidata(hObject, H);
%reducedata_Callback(hObject, eventdata, H)

function treeplotter_Callback(hObject, eventdata, H)

%global Results_OUT

%clear Results_OUT

Results_ppm = H.Results_ppm;
sample_idx = H.sample_idx;
NIST612_idx = H.NIST612_idx;
Age68 = H.Age68;
Age67 = H.Age67;
Best_Age = H.Best_Age;


count = 1;
for i = 1:length(sample_idx)
	if sample_idx(i,1) == 1
		Age_68(count,1) = Age68(i,1);
		%Age_67(count,1) = Age67(i,1);
		BestAge(count,1) = Best_Age(i,1);
		SampleNames(count,1) = Results_ppm(i+1,1);
		SampleData(count,:) = Results_ppm(i+1,2:end);
		count = count+1;
	end
end



Results_OUT{sum(sample_idx)+1,length(Results_ppm(1,:))+2} = [];
Results_OUT(2:end,1) = SampleNames;
Results_OUT(1,1) = Results_ppm(1,1);
Results_OUT(1,2) = {'Age 6/8'};
%Results_OUT(1,3) = {'Age 6/7'};
Results_OUT(1,3) = {'Best Age'};
Results_OUT(1,4:end) = Results_ppm(1,2:end);
Results_OUT(2:end,2) = num2cell(Age_68);
%Results_OUT(2:end,3) = Age_67;
Results_OUT(2:end,3) = num2cell(BestAge);
Results_OUT(2:end,4:end) = SampleData;

setappdata(0,'Results_OUT',Results_OUT);

TREEplotter_1_1_link

function exporttree_Callback(hObject, eventdata, H)
Results_ppm = H.Results_ppm;
sample_idx = H.sample_idx;
NIST612_idx = H.NIST612_idx;
Age68 = H.Age68;
Age67 = H.Age67;
Best_Age = H.Best_Age;
Macro_1_2_Output = H.Macro_1_2_Output;

count = 1;
for i = 1:length(sample_idx)
	if sample_idx(i,1) == 1
		Age_68(count,1) = Age68(i,1);
		Age_67(count,1) = Age67(i,1);
		BestAge(count,1) = Best_Age(i,1);
		Age_68u(count,1) = Macro_1_2_Output(i+1,24);
		Age_67u(count,1) = Macro_1_2_Output(i+1,26);
		BestAgeu(count,1) = Macro_1_2_Output(i+1,69);
		SampleNames(count,1) = Results_ppm(i+1,1);
		SampleData(count,:) = Results_ppm(i+1,2:end);
		count = count+1;
	end
end

Results_OUT2{sum(sample_idx)+1,length(Results_ppm(1,:))+6} = [];
Results_OUT2(2:end,1) = SampleNames;
Results_OUT2(1,1) = Results_ppm(1,1);
Results_OUT2(1,2) = {'Age 6/8'};
Results_OUT2(1,3) = {'Age 6/8 1s'};
Results_OUT2(1,4) = {'Age 6/7'};
Results_OUT2(1,5) = {'Age 6/7 1s'};
Results_OUT2(1,6) = {'Best Age'};
Results_OUT2(1,7) = {'Best Age 1s'};
Results_OUT2(1,8:end) = Results_ppm(1,2:end);
Results_OUT2(2:end,2) = num2cell(Age_68);
Results_OUT2(2:end,3) = Age_68u;
Results_OUT2(2:end,4) = Age_67;
Results_OUT2(2:end,5) = Age_67u;
Results_OUT2(2:end,6) = num2cell(BestAge);
Results_OUT2(2:end,7) = BestAgeu;
Results_OUT2(2:end,8:end) = SampleData;

[file,path] = uiputfile('*.xls','Save file');
writetable(table(Results_OUT2),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);
