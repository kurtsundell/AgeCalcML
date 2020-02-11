%% AGECALCML_NU_IAM MATLAB code for AgeCalcML_Nu_IAM.fig %%
function varargout = AgeCalcML_Nu_IAM(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AgeCalcML_Nu_IAM_OpeningFcn, ...
                   'gui_OutputFcn',  @AgeCalcML_Nu_IAM_OutputFcn, ...
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


%% SET DEFAULT COMMAND LINE AND HANDLE STRUCTURE %%
function AgeCalcML_Nu_IAM_OpeningFcn(hObject, eventdata, H, varargin)

H.output = hObject;
guidata(hObject, H);

function varargout = AgeCalcML_Nu_IAM_OutputFcn(hObject, eventdata, H) 
%imshow('splashs_eQh_icon.ico', 'Parent', H.axes50);
reduced = 0;
H.reduced = reduced;

%set(H.pc_1, 'Enable', 'off'); set(H.pc_2, 'Enable', 'off'); set(H.pc_3, 'Enable', 'off'); set(H.pc_4, 'Enable', 'off'); set(H.pc_5, 'Enable', 'off'); set(H.pc_6, 'Enable', 'off'); 
%set(H.pc_7, 'Enable', 'off'); set(H.reject68, 'Enable', 'off'); set(H.reject67, 'Enable', 'off'); set(H.reject82, 'Enable', 'off'); set(H.standards_rejected, 'Enable', 'off');

%set(H.summary, 'Enable', 'off'); 

%set(H.save_session, 'Enable', 'off'); 

%set(H.AgeCalc_comp, 'Enable', 'off'); set(H.build_rep, 'Enable', 'off');

guidata(hObject,H);
varargout{1} = H.output;

%% PUSHBUTTON BROWSER %%
function browser_Callback(hObject, eventdata, H)
%{
answer = questdlg('Set up for automatic reduction?', ...
	'Quick question:', ...
	'Yes, automatic reduction','No, regular reduction','No, regular reduction');
% Handle response
switch answer
    case 'Yes, automatic reduction'
		set(H.auto_reduce,'Enable','on')
        %disp([answer ' coming right up.'])
        auto = 1;
    case 'No, regular reduction'
		set(H.auto_reduce,'Enable','off')
        %disp([answer ' coming right up.'])
        auto = 0;
end
%}

%if auto == 0
	[filename pathname] = uigetfile({'*'},'File Selector','MultiSelect','on');
	fullpathname = strcat(pathname, filename);
	folder_path = pathname;
	set(H.filepath, 'String', fullpathname); %show path name
	if ~iscell(filename)
		filename = {filename};
	end %now filename is a cell array regardless of the number of selected files.
	if ~iscell(fullpathname)
		fullpathname = {fullpathname};
	end %now fullpathname is a cell array regardless of the number of selected files.
%end
%{
if auto == 1
	set(H.browser,'Enable','off')
	set(H.reduce_data,'Enable','off')
	[filename pathname] = uigetfile({'*'},'File Selector','MultiSelect','on');
	fullpathname = strcat(pathname, filename);
	set(H.filepath, 'String', fullpathname);
	if ~iscell(filename)
		filename = {filename};
	end %now filename is a cell array regardless of the number of selected files.
	if ~iscell(fullpathname)
		fullpathname = {fullpathname};
	end %now fullpathname is a cell array regardless of the number of selected files.
	folder_path = uigetdir;
end
%}
H.filename = filename;
H.folder_path = folder_path;
H.fullpathname = fullpathname;
guidata(hObject,H);

function auto_reduce_Callback(hObject, eventdata, H)
fullpathname = H.fullpathname;
filename = H.filename;
folder_path = H.folder_path;

if get(H.auto_reduce,'Value') == 1
	set(H.browser,'Enable','off')
	set(H.reduce_data,'Enable','off')
	
	t = timer;
	set(t, 'ExecutionMode', 'fixedrate');
	set(t, 'Period', 15);
	t.TimerFcn = @(~,~) reduce_data_Callback(hObject, eventdata, H);
	start(t)
end

if get(H.auto_reduce,'Value') == 0
	set(H.browser,'Enable','on');
	set(H.reduce_data,'Enable','on');
	t = H.t;
	delete(t)
	%reduce_data_Callback(hObject, eventdata, H);
	
if length(filename) == 1
    if ispc == 1
        fullpathname = char(strcat(folder_path, '\', filename));
    end
    if ismac == 1
        fullpathname = char(strcat(folder_path, '/', filename));
    end
end	

if length(filename) > 1	
	for i = 1:length(filename)
        if ispc == 1
            tmp = char(strcat(folder_path, '\', filename(1,i)));
        end
        if ismac == 1
            tmp = char(strcat(folder_path, '/', filename(1,i)));
        end
		fullpathname(1,i) = {tmp};
	end
end
	%set(H.auto_reduce,'Enable','off')
end

H.fullpathname = fullpathname;
H.t = t;
guidata(hObject,H);

%% CHECKBOX REDUCE DATA FOR AUTOREDUCE %%
function reduce_data_Callback(hObject, eventdata, H)
filename = H.filename;
%fullpathname = H.fullpathname;
folder_path = H.folder_path;

%% FILE INPUT: READ AND REDUCE LASERCHRON NU .txt FILE(S) %%

for i = 1:length(filename)
	
	if ispc == 1
		fullpathname = char(strcat(folder_path, '\', filename{1,i}));
	end
	
	if	ismac == 1
		fullpathname = char(strcat(folder_path, '/', filename{1,i}));
	end

	%if get(H.auto_reduce,'Value') == 0
        Data = importdata(char(fullpathname),',',500000);
	%end
	
	if i == 1
		data_length = 0;
	end
	
	SampleNameIs = strfind(Data(:,1), 'Sample Name is');
	EndAnalysis = strfind(Data(:,1), 'End of Analysis');
	
	for j = 1:length(Data(:,1))
		if isempty(SampleNameIs(~cellfun('isempty',SampleNameIs(j,1)))) == 0
			data_parse(j,1) = 1;
		end
	end

	for j = 1:length(Data(:,1))
		if isempty(EndAnalysis(~cellfun('isempty',EndAnalysis(j,1)))) == 0
			data_parse(j,1) = 2;
		end
	end

	data_parse = data_parse(1:find(data_parse==2, 1,'last'),1);
	
	d = strfind(Data(:,1), 'End of Analysis');

	for i = 1:length(Data(:,1))
		if isempty(d(~cellfun('isempty',d(i,1)))) == 0
			dd(i,1) = i;
		else
			dd(i,1) = 0;
		end
	end

	dd = nonzeros(dd);

	if dd(1,1) == 32
		Ablate = [(1:1:9)'];
		INT = 9;
		%set(H.intg, 'String', '9 s')
	elseif dd(1,1) == 35
		Ablate = [(1:1:12)'];
		INT = 12;
		%set(H.intg, 'String', '12 s')
	elseif dd(1,1) == 38
		Ablate = [(1:1:15)'];
		INT = 15;
		%set(H.intg, 'String', '15 s')
	elseif dd(1,1) == 43
		Ablate = [(1:1:20)'];
		INT = 20;
		%set(H.intg, 'String', '20 s')
	end

	s = strfind(Data(1,1), 'FAR');

	if isempty(s(cellfun('isempty',s(1,1)))) == 1
		FAR = 1;
		IC = 0;
		%set(H.mode, 'String', 'Faraday Acquisition')
	end

	if isempty(s(cellfun('isempty',s(1,1)))) == 0
		FAR = 0;
		IC = 1;
		%set(H.mode, 'String', 'Ion Counter Acquisition')
	end
		
	for j = 1:length(data_parse(:,1))
		if data_parse(j,1) == 1 && data_parse(j+INT+1,1) == 2
			sample_start_idx(j,1) = j;
			sample_end_idx(j,1) = j+INT+1;
		end
	end
	
	sample_start_idx = nonzeros(sample_start_idx);
	sample_end_idx = nonzeros(sample_end_idx);
	
	data_count = length(sample_start_idx(:,1));

	for j = 1:data_count
		values_all_cell = regexp(Data(sample_start_idx(j,1)+1:sample_end_idx(j,1)-1), ',', 'split');
		for k = 1:INT
			values_all(k,1:32,j+data_length) = str2num(cell2mat(values_all_cell{k,1}(1,1:32)));
		end
	end

	for j = 1:data_count
		name_tmp(j,1) = Data(sample_start_idx(j,1), 1);
	end

	name_tmp2 = char(name_tmp);
	for j = 1:data_count
		sample{j+data_length,:} = name_tmp2(j, 18:cell2mat(strfind(name_tmp(j,:), '<>'))-2);
	end

	data_length = length(values_all(1,1,:));
	
	clear sample_start_idx sample_end_idx data_parse data_count name_tmp name_tmp2 fullpathname

end	
	




data_count = length(sample);


if get(H.primary, 'Value') == 1
	STD1 = 'SL';
elseif get(H.primary, 'Value') == 2
	STD1 = 'BLS';
elseif get(H.primary, 'Value') == 3
	STD1 = 'WSM';
end

if get(H.secondary, 'Value') == 1
	STD2 = 'R33';
elseif get(H.secondary, 'Value') == 9
	STD2 = '554';
end

STD1_idx = strfind(sample, STD1);
STD2_idx = strfind(sample, STD2);
	if isempty(STD1_idx(~cellfun('isempty',STD1_idx))) == 1
	err_dlg=errordlg('Cound not find any reference material data. Double check your primary standard selection.','Uh oh!');
	waitfor(err_dlg);
%	elseif isempty(STD2_idx(~cellfun('isempty',STD2_idx))) == 1
%	err_dlg=errordlg('Cound not find any reference material data. Double check your secondary standard selection.','Ummmm...?');
%	waitfor(err_dlg);
	end
STD1_idx = abs(cellfun(@isempty,STD1_idx)-1);
STD2_idx = abs(cellfun(@isempty,STD2_idx)-1);
sample_idx = abs((STD1_idx + STD2_idx) - 1);

%set(H.STD1g_num, 'String', sum(STD1_idx));
%set(H.STD2g_num, 'String', sum(STD2_idx));
%set(H.unkg_num, 'String', sum(sample_idx));


%% RESET AND READ IN USER SETTINGS %%

cla(H.axes_distribution,'reset'); 


set(H.status,'String','');
cla reset
cla(H.axes_session_fractionation,'reset');
cla(H.axes_session,'reset');
%cla(H.axes_secondary,'reset');
cla(H.axes_current_intensities,'reset');
cla(H.axes_current_concordia,'reset');
cla(H.axes_distribution,'reset'); 
set(H.standards_rejected,'String','0');
%set(H.primary_reference,'String','');
%set(H.secondary_reference,'String','');
set(H.listbox1,'String','');
%set(H.listbox4,'String','');

cla reset

%set(H.age_int_05, 'Value', 0);
%set(H.age_int_1, 'Value', 0);
%set(H.age_int_2, 'Value', 0);
%set(H.age_int_5, 'Value', 0);
%set(H.age_int_10, 'Value', 0);
%set(H.age_int_25, 'Value', 0);
%set(H.age_int_50, 'Value', 0);
%set(H.age_int_100, 'Value', 0);

STD1_rename = {'std'}; 
bestage_cutoff = str2num(get(H.bestage_cutoff,'String'));
filter_cutoff = str2num(get(H.filter_cutoff,'String'));
filter_err68 = str2num(get(H.filter_err68,'String'));
filter_err67 = str2num(get(H.filter_err67,'String'));
filter_disc = str2num(get(H.filter_disc,'String'));
filter_disc_rev = str2num(get(H.filter_disc_rev,'String'));
filter_204 = str2num(get(H.filter_204,'String'));
factor64 = str2num(get(H.factor64,'String'));

if get(H.primary, 'Value') == 1
	STD1 = 'SL';
	STD1_68 = 0.09145;
	STD1_67  = 16.973;
	STD1_82  = 0.0283;
	STD1_64c = 17.827;
	STD1_67c = 15.549;
	STD1_68c = 37.576;
	STD1_Uppm = 518;
	STD1_Thppm = 118;
end

if get(H.primary, 'Value') == 2
	STD1 = 'BLS';
	STD1_68 = 0.1769;
	STD1_67  = 13.4560;
	STD1_82  = 0.0533;
	STD1_64c = 16.971;
	STD1_67c = 15.472;
	STD1_68c = 36.629;
	STD1_Uppm = 1050;
	STD1_Thppm = 118;
end

if get(H.primary, 'Value') == 3
	STD1 = 'WSM';
	STD1_68 = 0.0682;
	STD1_67  = 18.0860;
	STD1_82  = 0.0212;
	STD1_64c = 18.065;
	STD1_67c = 15.573;
	STD1_68c = 37.846;
	STD1_Uppm = 424;
	STD1_Thppm = 118;
end

%{
BLS	0.1769	13.4560	0.0533	16.971	15.472	36.629	1050
	206238	206207	208232	64c	67c	68c	Uppm
WSM	0.0682	18.0860	0.0212	18.065	15.573	37.846	424
MMHB	0.0846	17.29	0.02624	17.895	15.556	37.655	523.5
BRAG	0.06105	18.425	0.01908	18.135	15.5806	37.927	382
MAD	0.07818	17.595	0.02429	17.961	15.562	37.728	485
%}






if get(H.secondary, 'Value') == 1
	STD2 = 'R33';
	STD2_68 = 0.0671;
	STD2_67 = 0.05522;
	STD2_75 = 0.511;
	STD2_82 = 0.0557219220349821; % NOT CORRECT! THIS IS THE RATIO FOR PLESOVICE
	STD2_Pb206_U238_known_err = 1;
	STD2_Pb207_Pb206_known_err = 1;
	STD2_Pb207_U235_known_err = 1;
	STD2_Pb208_Th232_known_err = 1; % NOT CORRECT! THIS IS THE UNC FOR PLESOVICE
end

if get(H.secondary, 'Value') == 9
	STD2 = '554';
	STD2_68 = 0.0671;
	STD2_67 = 0.05522;
	STD2_75 = 0.511;
	STD2_82 = 0.0557219220349821; % NOT CORRECT! THIS IS THE RATIO FOR PLESOVICE
	STD2_Pb206_U238_known_err = 1;
	STD2_Pb207_Pb206_known_err = 1;
	STD2_Pb207_U235_known_err = 1;
	STD2_Pb208_Th232_known_err = 1; % NOT CORRECT! THIS IS THE UNC FOR PLESOVICE
end

for i = 1:data_count
	if STD1_idx(i,1) == 1
		stds(i,1) = sample(i,1);
		sample(i,1) = STD1_rename;
	end
end

%serial_tmp = char(text(22, 1));
serial = sample;
%clear serial_tmp

if FAR == 1
% Extract Faraday data
for i = 1:data_count
Data_Far_All(:,1:2,i) = values_all(:,1:2,i);
Data_Far_All(:,3:6,i) = values_all(:,10:13,i);
Data_Far_All(:,7,i) = values_all(:,15,i);
Data_Far_All(:,8:9,i) = values_all(:,17:18,i);
Data_Far_All(:,10:13,i) = values_all(:,26:29,i);
Data_Far_All(:,14,i) = values_all(:,31,i);
end
end

if IC == 1
% Extract Ion Counter data
for i = 1:data_count
Data_IC_All(:,1:2,i) = values_all(:,1:2,i);
Data_IC_All(:,3:8,i) = values_all(:,13:18,i);
Data_IC_All(:,9:12,i) = values_all(:,29:32,i);
end
end

if FAR == 1
% Baseline subtract (BLS) Faraday
for i = 1:data_count
BLS_238(:,i) = Data_Far_All(:,8,i) - Data_Far_All(:,1,i);
BLS_232(:,i) = Data_Far_All(:,9,i) - Data_Far_All(:,2,i);
BLS_208(:,i) = Data_Far_All(:,10,i) - Data_Far_All(:,3,i);
BLS_207(:,i) = Data_Far_All(:,11,i) - Data_Far_All(:,4,i);
BLS_206(:,i) = Data_Far_All(:,12,i) - Data_Far_All(:,5,i);
BLS_202(:,i) = Data_Far_All(:,14,i) - Data_Far_All(:,7,i);
BLS_204(:,i) = Data_Far_All(:,13,i) - Data_Far_All(:,6,i) - (BLS_202(:,i)./4.34);
end
end

if IC == 1 
% Baseline subtract (BLS) Ion Counter
for i = 1:data_count
BLS_238(:,i) = Data_IC_All(:,7,i) - Data_IC_All(:,1,i);
BLS_232(:,i) = Data_IC_All(:,8,i) - Data_IC_All(:,2,i);
BLS_208(:,i) = Data_IC_All(:,9,i) - Data_IC_All(:,3,i);
BLS_207(:,i) = Data_IC_All(:,10,i) - Data_IC_All(:,4,i);
BLS_206(:,i) = Data_IC_All(:,11,i) - Data_IC_All(:,5,i);
BLS_204(:,i) = Data_IC_All(:,12,i) - Data_IC_All(:,6,i);
end
end

if FAR == 1
Data_All = Data_Far_All(:,8:14,:);
end
if IC == 1
Data_All = Data_IC_All(:,7:12,:);
Data_All(1:end,7,1:end) = 0;
end

if IC == 1 && max(Ablate) == 9
BLS_238(10:15,:,:) = BLS_238(4:9,:,:);
BLS_232(10:15,:,:) = BLS_232(4:9,:,:);
BLS_208(10:15,:,:) = BLS_208(4:9,:,:);
BLS_207(10:15,:,:) = BLS_207(4:9,:,:);
BLS_206(10:15,:,:) = BLS_206(4:9,:,:);
BLS_204(10:15,:,:) = BLS_204(4:9,:,:);
end

if FAR == 1
for i = 1:data_count
BLS_68(:,i) = BLS_206(:,i)./BLS_238(:,i); %ActiveCell.FormulaR1C1 = "=RC[-3]/RC[-7]"
BLS_67(:,i) = BLS_206(:,i)./BLS_207(:,i); %ActiveCell.FormulaR1C1 = "=RC[-4]/RC[-5]"
BLS_64(:,i) = abs(BLS_206(:,i)./BLS_204(:,i)); %ActiveCell.FormulaR1C1 = "=ABS(RC[-5]/RC[-4])"
BLS_82(:,i) = abs(BLS_208(:,i)./BLS_232(:,i)); %ActiveCell.FormulaR1C1 = "=RC[-8]/RC[-9]"
BLS_84(:,i) = abs(BLS_208(:,i)./BLS_204(:,i)); %ActiveCell.FormulaR1C1 = "=ABS(RC[-9]/RC[-6])"
end
end

if IC == 1
for i = 1:data_count
BLS_68(:,i) = sort(BLS_206(:,i)./BLS_238(:,i)); %ActiveCell.FormulaR1C1 = "=RC[-3]/RC[-7]"
BLS_67(:,i) = sort(BLS_206(:,i)./BLS_207(:,i)); %ActiveCell.FormulaR1C1 = "=RC[-4]/RC[-5]"
BLS_64(:,i) = sort(abs(BLS_206(:,i)./BLS_204(:,i))); %ActiveCell.FormulaR1C1 = "=ABS(RC[-5]/RC[-4])"
BLS_82(:,i) = sort(abs(BLS_208(:,i)./BLS_232(:,i))); %ActiveCell.FormulaR1C1 = "=RC[-8]/RC[-9]"
BLS_84(:,i) = sort(abs(BLS_208(:,i)./BLS_204(:,i))); %ActiveCell.FormulaR1C1 = "=ABS(RC[-9]/RC[-6])"
end
end

% Calculate intensities in counts per second (CPS)
for i = 1:data_count
if FAR == 1
CPS_202(1,i) = abs(80000000*mean(BLS_202(:,i)));
CPS_204(1,i) = abs(80000000*mean(BLS_204(:,i)));
end
if IC == 1
CPS_204(1,i) = abs(8000000*mean(BLS_204(:,i))); % removed 0
end
CPS_206(1,i) = 80000000*mean(BLS_206(:,i));
CPS_207(1,i) = 80000000*mean(BLS_207(:,i));
CPS_208(1,i) = 80000000*mean(BLS_208(:,i));
CPS_232(1,i) = 80000000*mean(BLS_232(:,i));
CPS_238(1,i) = 80000000*mean(BLS_238(:,i));
end

% Sort BLS 67, 64, and 84
for i = 1:data_count
BLS_67_sort(:,i) = sort(BLS_67(:,i));
BLS_64_sort(:,i) = sort(BLS_64(:,i));
BLS_84_sort(:,i) = sort(BLS_84(:,i));
end

if FAR == 1
% Downhole fractionation correction 68
for i = 1:data_count
if INT == 15
tbl = table((1:1:13)',BLS_68(3:15,i));
end
mdl = fitlm(tbl);
BLS_68_corr(i,1) = abs(mdl.Coefficients.Estimate(1,1));
BLS_68_err(i,1) = abs(300.*((mdl.Coefficients.SE(1,1))./BLS_68_corr(i,1)));
BLS_68_slope(i,1) = 1000*mdl.Coefficients.Estimate(2,1);
end
end

if IC == 1
% Downhole fractionation correction 68
for i = 1:data_count
if INT == 9
tbl = table((1:1:10)',BLS_68(6:15,i));
end
mdl = fitlm(tbl);
BLS_68_corr(i,1) = abs(mdl.Coefficients.Estimate(1,1));
BLS_68_err(i,1) = abs(300.*((mdl.Coefficients.SE(1,1))./BLS_68_corr(i,1)));
BLS_68_slope(i,1) = 1000*mdl.Coefficients.Estimate(2,1);
%waitbar(i/data_count)
end
end

for i = 1:data_count
BLS_67_sort_mean(i,1) = mean(BLS_67_sort(3:13,i));
BLS_67_sort_err(i,1) = 100*(std(BLS_67_sort(3:13,i))/BLS_67_sort_mean(i,1));
if FAR == 1
BLS_64_sort_mean(i,1) = 0.85.*(mean(BLS_64_sort(3:13,i))); % Reduced by 0.85 because IC0 gain of 0.85
end
if IC == 1
BLS_64_sort_mean(i,1) = 10.*(mean(BLS_64_sort(3:13,i))); % Reduced by 0.85 because IC0 gain of 0.85
end
BLS_64_sort_err(i,1) = 100*(std(BLS_64_sort(3:13,i))/BLS_64_sort_mean(i,1));
end

if FAR == 1
% Downhole fractionation correction 82
for i = 1:data_count
if INT == 15
tbl = table((1:1:13)',BLS_82(3:15,i));
end
mdl = fitlm(tbl);
BLS_82_corr(i,1) = abs(mdl.Coefficients.Estimate(1,1));
BLS_82_err(i,1) = abs(300.*((mdl.Coefficients.SE(1,1))./BLS_82_corr(i,1)));
end
end

if IC == 1
% Downhole fractionation correction 82
for i = 1:data_count
if INT == 9
tbl = table((1:1:10)',BLS_82(6:15,i));
end
mdl = fitlm(tbl);
BLS_82_corr(i,1) = abs(mdl.Coefficients.Estimate(1,1));
BLS_82_err(i,1) = abs(300.*((mdl.Coefficients.SE(1,1))./BLS_82_corr(i,1)));
end
end

for i = 1:data_count
BLS_84_sort_mean(i,1) = mean(BLS_84_sort(3:13,i)); 
BLS_84_sort_err(i,1) = 100*(std(BLS_84_sort(3:13,i))/BLS_84_sort_mean(i,1));
end

% Data Export %
Macro1_Output(1:data_count+1,1:20) = {0}; % Preallocate
Macro1_Output(1,1:end) = {'sample', 'serial', '202 (cps)', '204 (cps)', '206 (cps)', '207 (cps)', '208 (cps)', '232 (cps)', '238 (cps)', '206238', '68 ± %', 'm68', ...
	'206207', '67 ± %', '206204', '64 ± %', '208232', '82 ± %', '208204', '84 ± %'};
Macro1_Output(2:end,1) = sample;
Macro1_Output(2:end,2) = {serial};
if FAR == 1
Macro1_Output(2:end,3) = num2cell(CPS_202);
else 
Macro1_Output(2:end,3) = {'NA'};
end
Macro1_Output(2:end,4) = num2cell(CPS_204);
Macro1_Output(2:end,5) = num2cell(CPS_206);
Macro1_Output(2:end,6) = num2cell(CPS_207);
Macro1_Output(2:end,7) = num2cell(CPS_208);
Macro1_Output(2:end,8) = num2cell(CPS_232);
Macro1_Output(2:end,9) = num2cell(CPS_238);
Macro1_Output(2:end,10) = num2cell(BLS_68_corr);
Macro1_Output(2:end,11) = num2cell(BLS_68_err);
Macro1_Output(2:end,12) = num2cell(BLS_68_slope);
Macro1_Output(2:end,13) = num2cell(BLS_67_sort_mean);
Macro1_Output(2:end,14) = num2cell(BLS_67_sort_err);
Macro1_Output(2:end,15) = num2cell(BLS_64_sort_mean);
Macro1_Output(2:end,16) = num2cell(BLS_64_sort_err);
Macro1_Output(2:end,17) = num2cell(BLS_82_corr);
Macro1_Output(2:end,18) = num2cell(BLS_82_err);
Macro1_Output(2:end,19) = num2cell(BLS_84_sort_mean);
Macro1_Output(2:end,20) = num2cell(BLS_84_sort_err);

% End Macro 1 %

%% OPTIONAL FILTER FOR 'BAD' STANDARDS %%

rad_on=get(H.uipanel_reject,'selectedobject');
switch rad_on
	case H.reject_yes

STD68 = (STD1_idx.*BLS_68_corr);
STD67 = (STD1_idx.*BLS_67_sort_mean);
STD82 = (STD1_idx.*BLS_82_corr);

STD68_median = median(nonzeros(STD1_idx.*BLS_68_corr));
STD67_median = median(nonzeros(STD1_idx.*BLS_67_sort_mean));
STD82_median = median(nonzeros(STD1_idx.*BLS_82_corr));

STD68_hi = STD68_median + (str2num(get(H.reject68,'String')))*.01.*STD68_median;
STD68_lo = STD68_median - (str2num(get(H.reject68,'String')))*.01.*STD68_median;
STD67_hi = STD67_median + (str2num(get(H.reject67,'String')))*.01.*STD67_median;
STD67_lo = STD67_median - (str2num(get(H.reject67,'String')))*.01.*STD67_median;
STD82_hi = STD82_median + (str2num(get(H.reject82,'String')))*.01.*STD82_median;
STD82_lo = STD82_median - (str2num(get(H.reject82,'String')))*.01.*STD82_median;

STD1_idx_orig = sum(STD1_idx);

for i = 1:data_count
if STD1_idx(i,1) == 1 && STD68(i,1) > STD68_hi
STD1_idx(i,1) = 0;
end
end

for i = 1:data_count
if STD1_idx(i,1) == 1 && STD68(i,1) < STD68_lo
STD1_idx(i,1) = 0;
end
end

for i = 1:data_count
if STD1_idx(i,1) == 1 && STD67(i,1) > STD67_hi
STD1_idx(i,1) = 0;
end
end

for i = 1:data_count
if STD1_idx(i,1) == 1 && STD67(i,1) < STD67_lo
STD1_idx(i,1) = 0;
end
end

for i = 1:data_count
if STD1_idx(i,1) == 1 && STD82(i,1) > STD82_hi
STD1_idx(i,1) = 0;
end
end

for i = 1:data_count
if STD1_idx(i,1) == 1 && STD82(i,1) < STD82_lo
STD1_idx(i,1) = 0;
end
end

STD1_idx_rej = STD1_idx_orig - sum(STD1_idx);
set(H.standards_rejected, 'String', STD1_idx_rej);

	case H.reject_no
end

%% START MACRO 2 %%
for i = 1:data_count
if STD1_idx(i,1) == 1
STD1_238(i,1) = CPS_238(1,i);
STD1_232(i,1) = CPS_232(1,i);
ff68(i,1) = STD1_68./(BLS_68_corr(i,1).*(((BLS_64_sort_mean(i,1)*factor64)-STD1_64c)./(BLS_64_sort_mean(i,1)*factor64))); %Column CC;
stdfc67(i,1) = STD1_67./((((BLS_64_sort_mean(i,1)*factor64)-STD1_64c)/((BLS_64_sort_mean(i,1).*factor64./BLS_67_sort_mean(i,1))-(STD1_67c)))); %Column CL;
stdfc82(i,1) = STD1_82/(BLS_82_corr(i,1)*(((BLS_84_sort_mean(i,1)*1)-STD1_68c)/(BLS_84_sort_mean(i,1)*factor64))); %Column CU;
else
STD1_238(i,1) = 0;
STD1_232(i,1) = 0;
ff68(i,1) = 0;
stdfc67(i,1) = 0;
stdfc82(i,1) = 0;
end
end

STD1_238_mean = mean(nonzeros(STD1_238));
STD1_232_mean = mean(nonzeros(STD1_232));

%% Sliding window calculations %%

if length(nonzeros(ff68(:,1))) > 10 && data_count > 30

for i = 1:5
ffsw68(i,1) = mean(nonzeros([ff68(1:15+i,1)]));
ffse68(i,1) = (std(nonzeros([ff68(1:15+i,1)])))/sqrt(length(nonzeros([ff68(1:15+i,1)])));
stdfcsw67(i,1) = mean(nonzeros([stdfc67(1:15+i,1)]));
stdswse67(i,1) = (std(nonzeros([stdfc67(1:15+i,1)])))/sqrt(length(nonzeros([stdfc67(1:15+i,1)])));
stdfcsw82(i,1) = mean(nonzeros([stdfc82(1:15+i,1)]));
stdswse82(i,1) = (std(nonzeros([stdfc82(1:15+i,1)])))/sqrt(length(nonzeros([stdfc82(1:15+i,1)])));
end

for i = 1:4
ffsw68(5+i,1) = mean(nonzeros([ff68(2:20+i,1)]));
ffse68(5+i,1) = (std(nonzeros([ff68(2:20+i,1)])))/sqrt(length(nonzeros([ff68(2:20+i,1)])));
stdfcsw67(5+i,1) = mean(nonzeros([stdfc67(2:20+i,1)]));
stdswse67(5+i,1) = (std(nonzeros([stdfc67(2:20+i,1)])))/sqrt(length(nonzeros([stdfc67(2:20+i,1)])));
stdfcsw82(5+i,1) = mean(nonzeros([stdfc82(2:20+i,1)]));
stdswse82(5+i,1) = (std(nonzeros([stdfc82(2:20+i,1)])))/sqrt(length(nonzeros([stdfc82(2:20+i,1)])));
end

for i = 1:9
ffsw68(9+i,1) = mean(nonzeros([ff68(3:24+i,1)]));
ffse68(9+i,1) = (std(nonzeros([ff68(3:24+i,1)])))/sqrt(length(nonzeros([ff68(3:24+i,1)])));
stdfcsw67(9+i,1) = mean(nonzeros([stdfc67(3:24+i,1)]));
stdswse67(9+i,1) = (std(nonzeros([stdfc67(3:24+i,1)])))/sqrt(length(nonzeros([stdfc67(3:24+i,1)])));
stdfcsw82(9+i,1) = mean(nonzeros([stdfc82(3:24+i,1)]));
stdswse82(9+i,1) = (std(nonzeros([stdfc82(3:24+i,1)])))/sqrt(length(nonzeros([stdfc82(3:24+i,1)])));
end

% Make temporary variables for sliding window %
ff68_tmp = ff68;
ff67_tmp = stdfc67;
ff82_tmp = stdfc82;
ff68_tmp(length(ff68)+1:length(ff68)+15,1) = 0;
ff67_tmp(length(stdfc67)+1:length(stdfc67)+15,1) = 0;
ff82_tmp(length(stdfc82)+1:length(stdfc82)+15,1) = 0;

for i = 1:length(ff68) - 18
ffsw68(18+i,1) = (sum(ff68_tmp(3+i:33+i),1) - max(nonzeros(ff68_tmp(3+i:33+i))) -  min(nonzeros(ff68_tmp(3+i:33+i)))) ...
	./ (numel(nonzeros(ff68_tmp(3+i:33+i)))-2); %Column CD

ffse68(18+i,1) = std(nonzeros(ff68_tmp(3+i:33+i)))/sqrt(length(nonzeros([ff68_tmp(3+i:33+i)])));



stdfcsw67(18+i,1) = (sum(ff67_tmp(3+i:33+i),1) - max(nonzeros(ff67_tmp(3+i:33+i))) -  min(nonzeros(ff67_tmp(3+i:33+i)))) ...
	./ (numel(nonzeros(ff67_tmp(3+i:33+i)))-2); %Column CM
stdswse67(18+i,1) = std(nonzeros(ff67_tmp(3+i:33+i)))/sqrt(length(nonzeros([ff67_tmp(3+i:33+i)])));
stdfcsw82(18+i,1) = (sum(ff82_tmp(3+i:33+i),1) - max(nonzeros(ff82_tmp(3+i:33+i))) -  min(nonzeros(ff82_tmp(3+i:33+i)))) ...
	./ (numel(nonzeros(ff82_tmp(3+i:33+i)))-2); %Column CV
stdswse82(18+i,1) = std(nonzeros(ff82_tmp(3+i:33+i)),1)/sqrt(length(nonzeros([ff82_tmp(3+i:33+i)])));
end



%% Filter for bad sliding window calculations, if NaN or Inf is replaced with last successful calcualtion %%

else

for i = 1:data_count  
ffsw68(i,1) = mean(nonzeros(ff68));
ffse68(i,1) = (std(nonzeros([ff68])))/sqrt(length(nonzeros([ff68])));
stdfcsw67(i,1) = mean(nonzeros([stdfc67]));
stdswse67(i,1) = (std(nonzeros([stdfc67])))/sqrt(length(nonzeros([stdfc67])));
stdfcsw82(i,1) = mean(nonzeros([stdfc82]));
stdswse82(i,1) = (std(nonzeros([stdfc82])))/sqrt(length(nonzeros([stdfc82])));
end

end

for i = 1:data_count
    if isinf(ffsw68(i,1)) == 1 || isnan(ffsw68(i,1)) == 1
        ffsw68(i,1) = ffsw68(i-1,1);
    end  
end

for i = 1:data_count
    if isinf(stdfcsw67(i,1)) == 1 || isnan(stdfcsw67(i,1)) == 1
        stdfcsw67(i,1) = stdfcsw67(i-1,1);
    end  
end

for i = 1:data_count
    if isinf(stdfcsw82(i,1)) == 1 || isnan(stdfcsw82(i,1)) == 1
        stdfcsw82(i,1) = stdfcsw82(i-1,1);
    end  
end





%% Sliding window uncertainties %% 
ffse68_hi = ffsw68 + ffse68;
ffse68_lo = ffsw68 - ffse68;

ffse67_hi = stdfcsw67 + stdswse67;
ffse67_lo = stdfcsw67 - stdswse67;

ffse82_hi = stdfcsw82 + stdswse82;
ffse82_lo = stdfcsw82 - stdswse82;

analysis_num = (1:1:data_count)'; % Set analysis numbers

for i = 1:data_count
if STD1_idx(i,1) == 1
STD1_num(i,1) = analysis_num(i,1);
ff68_num(i,1) = ff68(i,1);
ff67_num(i,1) = stdfc67(i,1);
ff82_num(i,1) = stdfc82(i,1);
end
end

STD1_num = nonzeros(STD1_num);
ff68_num = nonzeros(ff68_num);
ff67_num = nonzeros(ff67_num);
ff82_num = nonzeros(ff82_num);


%% Start common Pb correction %%

if get(H.commonpbcorr,'Value') == 1

	for i = 1:data_count
		BZ(i,1) = log(ffsw68(i,1).*BLS_68_corr(i,1)+1)/0.000155125; %Column BZ
		DF(i,1) = (18.761-0.0000001.*BZ(i,1).*BZ(i,1)-0.0016.*BZ(i,1)); %Column DF
		DG(i,1) = 15.671-0.00000000009*BZ(i,1)*BZ(i,1)*BZ(i,1)+0.0000002*BZ(i,1)*BZ(i,1)-0.0003*BZ(i,1); %Column DG
		DH(i,1) = 38.657-0.00000003*BZ(i,1)*BZ(i,1)-0.0019*BZ(i,1); %Column DH
	end

	for i = 1:data_count
		fcbc68(i,1) = BLS_68_corr(i,1).*ffsw68(i,1).*(((BLS_64_sort_mean(i,1)*factor64)-DF(i,1))/(BLS_64_sort_mean(i,1)*factor64)); %Column CH
		fcbc67(i,1) = stdfcsw67(i,1).*(((BLS_64_sort_mean(i,1)*factor64)-DF(i,1))/(((BLS_64_sort_mean(i,1)*factor64)./(BLS_67_sort_mean(i,1))-DG(i,1)))); %Column CQ
		fcbc82(i,1) = BLS_82_corr(i,1)*stdfcsw82(i,1)*(((BLS_84_sort_mean(i,1)*1)-DH(i,1))/(BLS_84_sort_mean(i,1)*1)); %Column CZ
	end
	
else
	
	for i = 1:data_count
		fcbc68(i,1) = BLS_68_corr(i,1).*ffsw68(i,1).*(((BLS_64_sort_mean(i,1)*factor64))/(BLS_64_sort_mean(i,1)*factor64)); %Column CH
		fcbc67(i,1) = stdfcsw67(i,1).*(((BLS_64_sort_mean(i,1)*factor64))/(((BLS_64_sort_mean(i,1)*factor64)./(BLS_67_sort_mean(i,1))))); %Column CQ
		fcbc82(i,1) = BLS_82_corr(i,1)*stdfcsw82(i,1)*(((BLS_84_sort_mean(i,1)*1))/(BLS_84_sort_mean(i,1)*1)); %Column CZ
	end
	
end

%% Calculate final ratios and ages and uncertainties %%
for i = 1:data_count
ppm238(i,1) = CPS_238(1,i).*STD1_Uppm/STD1_238_mean; %Column AY
ppm232(i,1) = CPS_232(1,i).*(STD1_Thppm/STD1_232_mean); %Column AZ
end

UTh = ppm238./ppm232; %Column BC

for i = 1:data_count
ratio68(i,1) = fcbc68(i,1)-((0.000000000155/0.0000092)*(((1/UTh(i,1))/2.3)-1)); %Column BJ
ratio75(i,1) = (ratio68(i,1)/fcbc67(i,1))*137.88; %Column BH
end

for i = 1:data_count
if ratio68(i,1) < 0
Age68{i,1} = 'NA';
else
Age68{i,1} = log(ratio68(i,1)+1)/0.000155125;
end
end

for i = 1:data_count
if 1/fcbc67(i,1) < .04604504 %zero age
Age67{i,1} = 'NA';
elseif 1/fcbc67(i,1) > .55 %older than Earth
Age67{i,1} = 'NA';
else
Age67{i,1} = MyAge76(1/fcbc67(i,1));
end
end

for i = 1:data_count
if ratio75(i,1) < 0
Age75{i,1} = 'NA';
else
Age75{i,1} = log(ratio75(i,1)+1)/0.00098485;
end
end

for i = 1:data_count
if fcbc82(i,1) < 0
Age82{i,1} = 'NA';
else
Age82{i,1} = log(fcbc82(i,1)+1)/0.0000495;
end
end

DD = BLS_64_sort_mean*factor64;



% Common Pb calcs for uncertainties

if get(H.commonpbcorr,'Value') == 1
	
	for i = 1:data_count
		err6864(i,1) = abs(100*(1-((DD(i,1)-(18.761-DF(i,1)))/DD(i,1))/(((DD(i,1)+DD(i,1)*BLS_64_sort_err(i,1)/100)-...
			(18.761-DF(i,1)))/(DD(i,1)+DD(i,1)*BLS_64_sort_err(i,1)/100)))); %Column CJ
		pbcerr68(i,1) = abs(100*(1-(DD(i,1)-(DF(i,1)/DD(i,1)))/(DD(i,1)-((DF(i,1)-1)/DD(i,1)))));

		pbcerr67(i,1) = abs(100*(1-((stdfcsw67(i,1)*((DD(i,1)-(DF(i,1)))/((DD(i,1)/(BLS_67_sort_mean(i,1))-DG(i,1)))))/(stdfcsw67(i,1)*(((DD(i,1)) ... 
			- (DF(i,1)-1))/(((DD(i,1))/(BLS_67_sort_mean(i,1))-(DG(i,1)-0.3))))))));

		err6764(i,1) = abs(100*(1-((stdfcsw67(i,1)*((BLS_64_sort_mean(i,1)*factor64-DF(i,1))/((BLS_64_sort_mean(i,1)*factor64/(BLS_67_sort_mean(i,1)) ...
			-DG(i,1)))))/(stdfcsw67(i,1)*(((BLS_64_sort_mean(i,1)*factor64+BLS_64_sort_mean(i,1)*factor64*BLS_64_sort_err(i,1)/100)-(DF(i,1))) ...
			/(((BLS_64_sort_mean(i,1)*factor64+BLS_64_sort_mean(i,1)*factor64*BLS_64_sort_err(i,1)/100)/(BLS_67_sort_mean(i,1))-DG(i,1)))))))); %Column CS
		err8284(i,1) = abs(100*(1-(((BLS_84_sort_mean(i,1)-DH(i,1)))/BLS_84_sort_mean(i,1))/((((BLS_84_sort_mean(i,1)+BLS_84_sort_mean(i,1) ...
			*BLS_84_sort_err(i,1)/100)-DH(i,1)))/(BLS_84_sort_mean(i,1)+BLS_84_sort_mean(i,1)*BLS_84_sort_err(i,1)/100)))); %Column DB
	end
	
else
	
	for i = 1:data_count
		err6864(i,1) = abs(100*(1-((DD(i,1)-(18.761))/DD(i,1))/(((DD(i,1)+DD(i,1)*BLS_64_sort_err(i,1)/100)-...
			(18.761))/(DD(i,1)+DD(i,1)*BLS_64_sort_err(i,1)/100)))); %Column CJ
		pbcerr68(i,1) = 0;

		pbcerr67(i,1) = 0;

		err6764(i,1) = abs(100*(1-((stdfcsw67(i,1)*((BLS_64_sort_mean(i,1)*factor64)/((BLS_64_sort_mean(i,1)*factor64/(BLS_67_sort_mean(i,1)) ...
			))))/(stdfcsw67(i,1)*(((BLS_64_sort_mean(i,1)*factor64+BLS_64_sort_mean(i,1)*factor64*BLS_64_sort_err(i,1)/100)) ...
			/(((BLS_64_sort_mean(i,1)*factor64+BLS_64_sort_mean(i,1)*factor64*BLS_64_sort_err(i,1)/100)/(BLS_67_sort_mean(i,1))))))))); %Column CS
		err8284(i,1) = abs(100*(1-(((BLS_84_sort_mean(i,1)))/BLS_84_sort_mean(i,1))/((((BLS_84_sort_mean(i,1)+BLS_84_sort_mean(i,1) ...
			*BLS_84_sort_err(i,1)/100)))/(BLS_84_sort_mean(i,1)+BLS_84_sort_mean(i,1)*BLS_84_sort_err(i,1)/100)))); %Column DB
	end

end

for i = 1:data_count
re67(i,1) = sqrt(BLS_67_sort_err(i,1)*BLS_67_sort_err(i,1)+err6764(i,1)*err6764(i,1)); %Column CR
re82(i,1) = sqrt(BLS_82_err(i,1)*BLS_82_err(i,1)+err8284(i,1)*err8284(i,1)); %Column DA
err68m(i,1) = sqrt(BLS_68_err(i,1)*BLS_68_err(i,1) + err6864(i,1)*err6864(i,1)); %Column CI and BK
end

for i = 1:data_count
ratio75_err(i,1) = sqrt(err68m(i,1)*err68m(i,1)+re67(i,1)*re67(i,1)); %Column BI
end

for i = 1:data_count
if (ratio68(i,1) + ratio68(i,1).*(err68m(i,1)/100))+1 < 0
Age68_err{i,1} = 'NA';
elseif (ratio68(i,1) - ratio68(i,1).*err68m(i,1)/100)+1 < 0
Age68_err{i,1} = 'NA';
else
Age68_err{i,1} = (log((ratio68(i,1) + ratio68(i,1).*(err68m(i,1)/100))+1)/0.000155125 - log((ratio68(i,1) - ratio68(i,1).*err68m(i,1)/100)+1)/0.000155125)/2;
end
end

for i = 1:data_count
if (ratio75(i,1)+ratio75(i,1)*(ratio75_err(i,1)/100))+1 < 0
Age75_err{i,1} = 'NA';
elseif (ratio75(i,1)-ratio75(i,1)*ratio75_err(i,1)/100)+1 < 0
Age75_err{i,1} = 'NA';
else
Age75_err{i,1} = (log((ratio75(i,1)+ratio75(i,1)*(ratio75_err(i,1)/100))+1)/0.00098485-log((ratio75(i,1)-ratio75(i,1)*ratio75_err(i,1)/100)+1)/0.00098485)/2;
end
end

for i = 1:data_count
if (fcbc82(i,1)+fcbc82(i,1)*(re82(i,1)/100))+1 < 0
Age82_err{i,1} = 'NA';
elseif (fcbc82(i,1)-fcbc82(i,1)*re82(i,1)/100)+1 < 0
Age82_err{i,1} = 'NA';
else
Age82_err{i,1} = (log((fcbc82(i,1)+fcbc82(i,1)*(re82(i,1)/100))+1)/0.0000495 - log((fcbc82(i,1)-fcbc82(i,1)*re82(i,1)/100)+1)/0.0000495)/2;
end
end

for i = 1:data_count
if 1/(fcbc67(i,1)-fcbc67(i,1)*re67(i,1)/100) < .04604504 %zero age
Age67_err{i,1} = 'NA';
elseif 1/(fcbc67(i,1)-fcbc67(i,1)*re67(i,1)/100) > .55 %older than Earth
Age67_err{i,1} = 'NA';
elseif 1/(fcbc67(i,1)+fcbc67(i,1)*re67(i,1)/100) < .04604504 %zero age
Age67_err{i,1} = 'NA';
elseif 1/(fcbc67(i,1)+fcbc67(i,1)*re67(i,1)/100) > .55 %older than Earth
Age67_err{i,1} = 'NA';
else
Age67_err{i,1} = abs((MyAge76(1/(fcbc67(i,1)-fcbc67(i,1)*re67(i,1)/100)) - MyAge76(1/(fcbc67(i,1)+fcbc67(i,1)*re67(i,1)/100)))/2);
end
end

for i = 1:data_count
rho(i,1) = (err68m(i,1)*err68m(i,1)+ratio75_err(i,1)*ratio75_err(i,1)-re67(i,1)*re67(i,1))/(2*err68m(i,1)*ratio75_err(i,1));
end

for i = 1:data_count
if isnan(cell2num(Age67(i,1))) == 1
Best_Age{i,1} = Age68{i,1};
Best_Age_err{i,1} = Age68_err{i,1};
end
end

for i = 1:data_count
if cell2num(Age68(i,1)) > 400 && (cell2num(Age68(i,1)) + cell2num(Age67(i,1)))/2 > bestage_cutoff
Best_Age{i,1} = Age67{i,1};
Best_Age_err{i,1} = Age67_err{i,1};
else
Best_Age{i,1} = Age68{i,1};
Best_Age_err{i,1} = Age68_err{i,1};
end
end

%% FILTERS FOR DISCORDANCE, PRECISION, AND 204 COUNTS %%

comment1{data_count, 1} = [];
comment2{data_count, 1} = [];
comment3{data_count, 1} = [];
comment4{data_count, 1} = [];
comment5{data_count, 1} = [];
comment6{data_count, 1} = [];

for i = 1:data_count
if BLS_68_err(i,1) > filter_err68
comment1(i,1) = {'high 6/8 err  '};
end
if cell2num(Age68(i,1)) > filter_cutoff && BLS_67_sort_err(i,1) > filter_err67
comment2(i,1) = {'high 6/7 err  '};
end
if cell2num(Age68(i,1)) > filter_cutoff && cell2num(Age67(i,1)) ~= 0 && (cell2num(Age68(i,1))/cell2num(Age67(i,1))) < (1 - filter_disc*0.01) 
comment3(i,1) = {'discordant  '};
end
if cell2num(Age68(i,1)) > filter_cutoff && cell2num(Age67(i,1)) ~= 0 && (cell2num(Age68(i,1))/cell2num(Age67(i,1))) > (1 + filter_disc_rev*0.01) 
comment4(i,1) = {'rev discord  '};
end
if CPS_204(1,i) > filter_204
comment5(i,1) = {'high 204  '};
end
if BLS_64_sort_mean(i,1) < filter_204/10
comment6(i,1) = {'low 206/204  '};
end
end

comment = strcat(comment1, comment2, comment3, comment4, comment5, comment6);

%% CONCATENATE DATA FOR EXPORT AND PLOTTING %%

AGES_OUT{data_count+1, 6} = [];
AGES_OUT(1,:) = {'6/8 age', '± (Ma)', '6/7 age', '± (Ma)', '8/2 age', '± (Ma)'};
AGES_OUT(2:end,:) = [Age68, Age68_err, Age67, Age67_err, Age82, Age82_err];

SAMPLE_CONCORDIA{data_count+1, 13} = [];
SAMPLE_CONCORDIA(1,:) = {'7/5 ratio', '±(%)', '6/8 ratio', '±(%)', 'rho', '6/8 age', '±(Ma)', '6/7 age', '±(Ma)', 'BEST AGE', '±(Ma)', '8/2 age', '±(Ma)'};
for i = 1:data_count
if sample_idx(i,1) == 1 && isempty(comment{i,1}) == 1 
	SAMPLE_CONCORDIA(i+1,:) = [num2cell(ratio75(i,:)), num2cell(ratio75_err(i,:)), num2cell(ratio68(i,:)), num2cell(err68m(i,:)), num2cell(rho(i,:)), ...
		Age68(i,:), Age68_err(i,:), Age67(i,:), Age67_err(i,:), Best_Age(i,:), Best_Age_err(i,:), Age82(i,:), Age82_err(i,:)];
elseif STD2_idx(i,1) == 1 
	SAMPLE_CONCORDIA(i+1,:) = [num2cell(ratio75(i,:)), num2cell(ratio75_err(i,:)), num2cell(ratio68(i,:)), num2cell(err68m(i,:)), num2cell(rho(i,:)), ...
		Age68(i,:), Age68_err(i,:), Age67(i,:), Age67_err(i,:), Best_Age(i,:), Best_Age_err(i,:), Age82(i,:), Age82_err(i,:)];
end
end

STD_CONCORDIA{data_count+1, 9} = [];
STD_CONCORDIA(1,:) = {'7/5 ratio', '±(%)', '6/8 ratio', '±(%)', 'rho', '6/8 age', '±(Ma)', '6/7 age', '±(Ma)'};
for i = 1:data_count
if STD1_idx(i,1) == 1
STD_CONCORDIA(i+1,:) = [num2cell(ratio75(i,:)), num2cell(ratio75_err(i,:)), num2cell(ratio68(i,:)), num2cell(err68m(i,:)), num2cell(rho(i,:)), ...
	Age68(i,:), Age68_err(i,:), Age67(i,:), Age67_err(i,:)];
end
end

CORRECTED_CONC_RATIOS{data_count+1, 15} = [];
CORRECTED_CONC_RATIOS(1,:) = {'sample', 'U (ppm)', 'Th(ppm)', '6/4c', '8/4 ratio', 'U/Th', '6/7 ratio', '±(%)', '8/2 ratio', '±(%)', ...
	'7/5 ratio', '±(%)', '6/8 ratio', '±(%)', 'rho'};
CORRECTED_CONC_RATIOS(2:end,:) = [sample, num2cell(ppm238), num2cell(ppm232), num2cell(BLS_64_sort_mean.*factor64), num2cell(BLS_84_sort_mean), ...
	num2cell(UTh), num2cell(fcbc67), num2cell(re67), num2cell(fcbc82), num2cell(re82), num2cell(ratio75), num2cell(ratio75_err), num2cell(ratio68), ...
	num2cell(err68m), num2cell(rho)];

AGES_1SD_RANDOM_ERRORS{data_count+1, 10} = [];
AGES_1SD_RANDOM_ERRORS(1,:) = {'6/8 age', '±(Ma)', '7/5 age', '±(Ma)', '6/7 age', '±(Ma)', '8/2 age', '±(Ma)', 'BEST AGE', '±(Ma)'};
AGES_1SD_RANDOM_ERRORS(2:end,:) = [Age68, Age68_err, Age75, Age75_err, Age67, Age67_err, Age82, Age82_err, Best_Age, Best_Age_err];

Macro_1_2_Output = [Macro1_Output, AGES_OUT, [{'comment'};comment], SAMPLE_CONCORDIA, STD_CONCORDIA, CORRECTED_CONC_RATIOS, AGES_1SD_RANDOM_ERRORS];

%% POPULATE STDS LISTBOX %%
name_idx2 = sum(nonzeros(STD1_idx)); %automatically plot final sample run
%{
for i=1:length(sample)
	if STD1_idx(i,1) == 1
		name_char_std{i,1} = char(sample(i,1));
	else
		name_char_std{i,1} = [];
	end
end
%}
name_char_std = stds(~cellfun(@isempty, stds));
 
name_char_std = name_char_std(~cellfun('isempty',name_char_std));

%for i=1:length(stds)
%	if isempty(comment{i,1}) == 0
%		name_char_std(i,1) = strcat('<html><BODY bgcolor="red">',stds(i,1),'</span></html>');
%	end
%end

%set(H.listbox4, 'String', name_char_std);
%set(H.listbox4,'Value',name_idx2);


%scatter(STD1g_num(name_idx2,1), ff68_num(name_idx2,1), 100, 'o')






%% PLOT DEFAULT Pb206/U238 DRIFT CORRECTION %%%%%
cla(H.axes_distribution,'reset'); 
axes(H.axes_session_fractionation);
hold on
fill([(1:1:data_count)';flipud((1:1:data_count)')], [ffse68_hi; flipud(ffse68_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
plot([(1:1:data_count); (1:1:data_count)], [(ffsw68+ffsw68*0.02)'; (ffsw68-ffsw68*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',1) % Error bars
scatter(STD1_num, ff68_num, 75, 'b', 'filled','d')
%sc = scatter(STD1_num(name_idx2,1), ff68_num(name_idx2,1), 175, 'o', 'MarkerEdgeColor', 'b');
axis([0 data_count+1 min([(ffsw68-ffsw68*0.02);ff68_num])-0.02*min([(ffsw68-ffsw68*0.02);ff68_num]) max([(ffsw68+ffsw68*0.02);ff68_num])+0.02*max([(ffsw68+ffsw68*0.02);ff68_num])])
hold off
%title('Pb206/U238 Session drift')
xlabel('Analysis number','Color','k')
ylabel('Pb206/U238 fractionation factor','Color','k')

%% CALCULATE RHO AND REPLACE 'BAD' (<0 OR >1) CORRELATION COEFFICIENT (RHO) %%%%%

sigmarule=1.5;
numpoints=50;
errcorr = rho;
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

STD1_rho = nonzeros(STD1_idx.*errcorr_corr);
STD2_rho = nonzeros(STD2_idx.*errcorr_corr);
rho = errcorr_corr;

STD1_concordia_data = [nonzeros(STD1_idx.*ratio75),nonzeros(STD1_idx.*ratio75_err),nonzeros(STD1_idx.*ratio68),nonzeros(STD1_idx.*err68m)];
STD2_concordia_data = [nonzeros(STD2_idx.*ratio75),nonzeros(STD2_idx.*ratio75_err),nonzeros(STD2_idx.*ratio68),nonzeros(STD2_idx.*err68m)];
concordia_data = [ratio75,ratio75_err,ratio68,err68m];
All_concordia_data = [ratio75,ratio75_err,ratio68,err68m];

center_STD1 = [STD1_concordia_data(:,1),STD1_concordia_data(:,3)];
center_STD2 = [STD2_concordia_data(:,1),STD2_concordia_data(:,3)];
center = [concordia_data(:,1),concordia_data(:,3)];
center_All = [concordia_data(:,1),concordia_data(:,3)];

sigx_abs_STD1 = STD1_concordia_data(:,1).*STD1_concordia_data(:,2).*0.01;
sigy_abs_STD1 = STD1_concordia_data(:,3).*STD1_concordia_data(:,4).*0.01;

sigx_abs_STD2 = STD2_concordia_data(:,1).*STD2_concordia_data(:,2).*0.01;
sigy_abs_STD2 = STD2_concordia_data(:,3).*STD2_concordia_data(:,4).*0.01;

sigx_abs = concordia_data(:,1).*concordia_data(:,2).*0.01;
sigy_abs = concordia_data(:,3).*concordia_data(:,4).*0.01;

sigx_abs_All = concordia_data(:,1).*concordia_data(:,2).*0.01;
sigy_abs_All = concordia_data(:,3).*concordia_data(:,4).*0.01;

sigx_sq_STD1 = sigx_abs_STD1.*sigx_abs_STD1;
sigy_sq_STD1 = sigy_abs_STD1.*sigy_abs_STD1;

sigx_sq_STD2 = sigx_abs_STD2.*sigx_abs_STD2;
sigy_sq_STD2 = sigy_abs_STD2.*sigy_abs_STD2;

sigx_sq = sigx_abs.*sigx_abs;
sigy_sq = sigy_abs.*sigy_abs;

sigx_sq_All = sigx_abs.*sigx_abs;
sigy_sq_All = sigy_abs.*sigy_abs;

rho_sigx_sigy_STD1 = sigx_abs_STD1.*sigy_abs_STD1.*STD1_rho;
rho_sigx_sigy_STD2 = sigx_abs_STD2.*sigy_abs_STD2.*STD2_rho;
rho_sigx_sigy = sigx_abs.*sigy_abs.*rho;
rho_sigx_sigy_All = sigx_abs.*sigy_abs.*rho;














%% POPULATE LISTBOX, SAMPLE INTENSITIES, AND PLOT INDIVIDUAL SAMPLE RAW DATA %%
name_idx = length(sample); %automatically plot final sample run

for i=1:length(sample)
	name_char(i,1) = sample(i,1);
end

for i=1:length(sample)
	if isempty(comment{i,1}) == 0
		name_char(i,1) = strcat('<html><BODY bgcolor="red">',name_char(i,1),'</span></html>');
	end
end

set(H.listbox1, 'String', name_char);
set(H.listbox1,'Value',length(sample));

if FAR == 1
values = Data_Far_All(:,8:14,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);
end

if IC == 1
values = Data_IC_All(:,7:12,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(1:end, 7) = 0.1;
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);
end

for i = 1:INT
for j = 1:7
if values2(i,j) < 0 
values2(i,j) = 1;
end
end
end

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:8
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end

C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

hold on
if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness, 'color',C{7});
end

hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])

%% CURRENT STATUS %%

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



%% MULTI-PLOT %%

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;


	%ptype_Primary_STDs_Callback(hObject, eventdata, H)


if get(H.ptype_Primary_STDs, 'Value') == 1
%Primary standard
axes(H.axes_session);
set(H.axes_session,'FontSize',8);
%set(H.primary_reference,'String',STD1);

for i = 1:length(sigx_sq_STD1)
covmat_STD1=[sigx_sq_STD1(i,1),rho_sigx_sigy_STD1(i,1);rho_sigx_sigy_STD1(i,1),sigy_sq_STD1(i,1)];
[PD_STD1,PV_STD1]=eig(covmat_STD1);
PV_STD1 = diag(PV_STD1).^.5;
theta_STD1 = linspace(0,2.*pi,numpoints)';
elpt_STD1 = [cos(theta_STD1),sin(theta_STD1)]*diag(PV_STD1)*PD_STD1';
numsigma = length(sigmarule);
elpt_STD1 = repmat(elpt_STD1,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt_STD1_out(:,:,i) = elpt_STD1 + repmat(center_STD1(i,1:2),numpoints,numsigma);
p1 = plot(elpt_STD1_out(:,1:2:end,i),elpt_STD1_out(:,2:2:end,i),'b','LineWidth',1.2);
hold on
end

%age_label2_x = 0.742701185586296;
age_label2_x = STD1_68*(1/STD1_67)*137.88;
%age_label2_y = 0.0912660713153783;
age_label2_y = STD1_68;

if get(H.primary, 'Value') == 1
	age_label2 = {'564 Ma'};
end

if get(H.primary, 'Value') == 2
	age_label2 = {'1050 Ma'};
end

if get(H.primary, 'Value') == 3
	age_label2 = {'? Ma'};
end

plot(xc,yc,'k','LineWidth',1.4)
hold on
p1 = scatter(age_label2_x, age_label2_y,50,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
labelpoints (age_label2_x, age_label2_y, age_label2, 'SE', .002);
legend(p1,'Accepted Age','Location','northwest');
axis([min(min(elpt_STD1_out(:,1,:))) - min(min(elpt_STD1_out(:,1,:)))*.01 max(max(elpt_STD1_out(:,1,:))) + max(max(elpt_STD1_out(:,1,:)))*.01 ...
	min(min(elpt_STD1_out(:,2,:))) - min(min(elpt_STD1_out(:,2,:)))*.01 max(max(elpt_STD1_out(:,2,:))) + max(max(elpt_STD1_out(:,2,:)))*.01]);
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);
end

if get(H.ptype_Secondary_STDs, 'Value') == 1

if sum(STD2_idx) > 1
axes(H.axes_session);
set(H.axes_session,'FontSize',8);
%set(H.secondary_reference,'String',STD2);

for i = 1:length(sigx_sq_STD2)
covmat_STD2=[sigx_sq_STD2(i,1),rho_sigx_sigy_STD2(i,1);rho_sigx_sigy_STD2(i,1),sigy_sq_STD2(i,1)];
[PD_STD2,PV_STD2]=eig(covmat_STD2);
PV_STD2 = diag(PV_STD2).^.5;
theta_STD2 = linspace(0,2.*pi,numpoints)';
elpt_STD2 = [cos(theta_STD2),sin(theta_STD2)]*diag(PV_STD2)*PD_STD2';
numsigma = length(sigmarule);
elpt_STD2 = repmat(elpt_STD2,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt_STD2_out(:,:,i) = elpt_STD2 + repmat(center_STD2(i,1:2),numpoints,numsigma);
plot(elpt_STD2_out(:,1:2:end,i),elpt_STD2_out(:,2:2:end,i),'b','LineWidth',1.2);
hold on
end

age_label3_x = 0.511;
age_label3_y = 0.0671;
age_label3 = {'419 Ma'};

plot(xc,yc,'k','LineWidth',1.4)
hold on
p2 = scatter(age_label3_x, age_label3_y,40,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
labelpoints (age_label3_x, age_label3_y, age_label3, 'SE', .002);
legend([p2],'accepted age','Location','northwest');
axis([min(min(elpt_STD2_out(:,1,:))) - min(min(elpt_STD2_out(:,1,:)))*.01 max(max(elpt_STD2_out(:,1,:))) + max(max(elpt_STD2_out(:,1,:)))*.01 ...
	min(min(elpt_STD2_out(:,2,:))) - min(min(elpt_STD2_out(:,2,:)))*.01 max(max(elpt_STD2_out(:,2,:))) + max(max(elpt_STD2_out(:,2,:)))*.01]);
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

end
end

if get(H.ptype_Unknowns, 'Value') == 1

axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);
hold on

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = plot(elpt_out_acc(:,1:2:end,i),elpt_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = plot(elpt_out_rej(:,1:2:end,i),elpt_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
	end
end

plot(x,y,'k','LineWidth',1.4)

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

elpt_min1 = min([min(min(nonzeros(elpt_out_acc(:,1,:)))),min(min(nonzeros(elpt_out_rej(:,1,:))))]);
elpt_max1 = max([max(max(elpt_out_acc(:,1,:))),max(max(elpt_out_rej(:,1,:)))]);
elpt_min2 = min([min(min(nonzeros(elpt_out_acc(:,2,:)))),min(min(nonzeros(elpt_out_rej(:,2,:))))]);
elpt_max2 = max([max(max(elpt_out_acc(:,2,:))),max(max(elpt_out_rej(:,2,:)))]);

for i = 1:length(time4)
if x4(i,1) > elpt_min1 - elpt_min1*.01 && x4(i,1) < elpt_max1 +elpt_max1*.01 ...
	&& y4(i,1) > elpt_min2 - elpt_min2*.01 && y4(i,1) < elpt_max2 + elpt_max2*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

axis([elpt_min1 - elpt_min1*.01 elpt_max1 + elpt_max1*.01 ...
	elpt_min2 - elpt_min2*.01 elpt_max2 + elpt_max2*.01]);
xlabel('207Pb/235U', 'FontSize', 10);
ylabel('206Pb/238U', 'FontSize', 10);

p3 = scatter(ratio75(length(sample),1), ratio68(length(sample),1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

accan= {'Accepted Analyses'};
rejan = {'Rejected Analyses'};

%legend([p1 p2], [accan, rejan], 'Location','northwest');

if get(H.leg_on_session,'Value') == 1	
	legend([p1 p2 p3], [accan, rejan, sample(length(sample))], 'Location','northwest');
else
	legend('hide')
end
	
end


if get(H.ptype_Unknowns_acc, 'Value') == 1
	
axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);
hold on

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = plot(elpt_out_acc(:,1:2:end,i),elpt_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = [];
	end
end

plot(x,y,'k','LineWidth',1.4)

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

for i = 1:length(time4)
if x4(i,1) > min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 && x4(i,1) < max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	&& y4(i,1) > min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 && y4(i,1) < max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

axis([min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01]);
xlabel('207Pb/235U', 'FontSize', 10);
ylabel('206Pb/238U', 'FontSize', 10);

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

accan= {'Accepted Analyses'};

if get(H.leg_on_session,'Value') == 1	
	legend([p1 p3], [accan, sample(name_idx)], 'Location','northwest');
else
	legend('hide')
end

end

if get(H.ptype_Unknowns_rej, 'Value') == 1
	
axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);
hold on

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = [];
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = plot(elpt_out_rej(:,1:2:end,i),elpt_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
	end
end

plot(x,y,'k','LineWidth',1.4)

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

for i = 1:length(time4)
if x4(i,1) > min(min(nonzeros(elpt_out_rej(:,1,:)))) - min(min(nonzeros(elpt_out_rej(:,1,:))))*.01 && x4(i,1) < max(max(nonzeros(elpt_out_rej(:,1,:)))) + max(max(nonzeros(elpt_out_rej(:,1,:))))*.01 ...
	&& y4(i,1) > min(min(nonzeros(elpt_out_rej(:,2,:)))) - min(min(nonzeros(elpt_out_rej(:,2,:))))*.01 && y4(i,1) < max(max(nonzeros(elpt_out_rej(:,2,:)))) + max(max(nonzeros(elpt_out_rej(:,2,:))))*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

axis([min(min(nonzeros(elpt_out_rej(:,1,:)))) - min(min(nonzeros(elpt_out_rej(:,1,:))))*.01 max(max(nonzeros(elpt_out_rej(:,1,:)))) + max(max(nonzeros(elpt_out_rej(:,1,:))))*.01 ...
	min(min(nonzeros(elpt_out_rej(:,2,:)))) - min(min(nonzeros(elpt_out_rej(:,2,:))))*.01 max(max(nonzeros(elpt_out_rej(:,2,:)))) + max(max(nonzeros(elpt_out_rej(:,2,:))))*.01]);
xlabel('207Pb/235U', 'FontSize', 10);
ylabel('206Pb/238U', 'FontSize', 10);

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

accan= {'Accepted Analyses'};
rejan = {'Rejected Analyses'};

%legend([p1 p2], [accan, rejan], 'Location','northwest');

if get(H.leg_on_session,'Value') == 1	
	legend([p2 p3], [rejan, sample(name_idx)], 'Location','northwest');
else
	legend('hide')
end

end

if get(H.DHF_primary, 'Value') == 1

for i = 1:length(Data_All(1,1,:))
	values3(:,:,i) = Data_All(:,:,i).*80000000;
end
values3(:,8,:) = values3(:,5,:)./values3(:,1,:);
values3(:,9,:) = values3(:,5,:)./values3(:,4,:);
values3(:,10,:) = values3(:,3,:)./values3(:,2,:);

axes(H.axes_session);
cla(H.axes_session,'reset');
hold on

for i = 1:length(values3(1,1,:))
	if STD1_idx(i,1) == 1
		q3 = plot(Ablate,values3(:,8,i),'linewidth', 1,'color','k');
	end
end

hold off
xlim([1 max(Ablate)])

stdan= {'Primary Standard Analyses'};


if get(H.leg_on_session,'Value') == 1	
	legend([q3], [stdan], 'Location','northwest');
else
	legend('hide')
end

end

if get(H.DHF_unknown, 'Value') == 1

for i = 1:length(Data_All(1,1,:))
	values3(:,:,i) = Data_All(:,:,i).*80000000;
end
values3(:,8,:) = values3(:,5,:)./values3(:,1,:);
values3(:,9,:) = values3(:,5,:)./values3(:,4,:);
values3(:,10,:) = values3(:,3,:)./values3(:,2,:);

axes(H.axes_session);
cla(H.axes_session,'reset');
hold on

for i = 1:length(values3(1,1,:))
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		q1 = plot(Ablate,values3(:,8,i),'linewidth', 1,'color','b');
	end
end

for i = 1:length(values3(1,1,:))
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		q2 = plot(Ablate,values3(:,8,i),'linewidth', 1,'color','r');
	end
end

hold off
xlim([1 max(Ablate)])

accan= {'Accepted Analyses'};
rejan = {'Rejected Analyses'};

if get(H.leg_on_session,'Value') == 1	
	legend([q1 q2], [accan, rejan], 'Location','northwest');
else
	legend('hide')
end

end

if get(H.age_uconc, 'Value') == 1

for i = 1:length(Macro_1_2_Output(:,1))
	if sum(size(cell2mat(Macro_1_2_Output(i,37)))) > 0 
		uconc(i,1) = cell2num(Macro_1_2_Output(i,51));
		bestage(i,1) = cell2num(Macro_1_2_Output(i,37));
	end
end

uconc(~isfinite(uconc))=0;
bestage(~isfinite(bestage))=0;

uconc = nonzeros(uconc);
bestage = nonzeros(bestage);

axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);

s1 = scatter(uconc, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('U ppm')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','northeast');
else
	legend('hide')
end

end

if get(H.age_raddos, 'Value') == 1

for i = 1:length(Macro_1_2_Output(:,1))
	if sum(size(cell2mat(Macro_1_2_Output(i,37)))) > 0 
		u(i,1) = cell2num(Macro_1_2_Output(i,51));
		th(i,1) = cell2num(Macro_1_2_Output(i,51));
		bestage(i,1) = cell2num(Macro_1_2_Output(i,37));
	end
end

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

axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);

s1 = scatter(raddos, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('Radiation Dosage (alpha decays/µg)')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','southeast');
else
	legend('hide')
end

end


if get(H.age_uth, 'Value') == 1

for i = 1:length(Macro_1_2_Output(:,1))
	if sum(size(cell2mat(Macro_1_2_Output(i,37)))) > 0 
		uth(i,1) = cell2num(Macro_1_2_Output(i,55));
		bestage(i,1) = cell2num(Macro_1_2_Output(i,37));
	end
end

uth(~isfinite(uth))=0;
bestage(~isfinite(bestage))=0;

uth = nonzeros(uth);
bestage = nonzeros(bestage);

axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);

s1 = scatter(uth, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('U/Th')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','northeast');
else
	legend('hide')
end

end


if get(H.age_concodance, 'Value') == 1


for i = 1:length(Macro_1_2_Output(:,1))
	if sum(size(cell2mat(Macro_1_2_Output(i,37)))) > 0 
		age68(i,1) = cell2num(Macro_1_2_Output(i,33));
		age67(i,1) = cell2num(Macro_1_2_Output(i,35));
		bestage(i,1) = cell2num(Macro_1_2_Output(i,37));
	end
end

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



axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);

s1 = scatter(concordance, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('Concordance (%)')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','northwest');
else
	legend('hide')
end

end

%% PLOT INDIVIDUAL SAMPLE CONCORDIA OR ALL SAMPLE CONCORDIAS %%

axes(H.axes_current_concordia);
set(H.axes_current_concordia,'FontSize',8);
%set(H.axes_current_concordia,'String',sample{name_idx,1});

bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});

concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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
%set(H.age_int_05, 'Value', 1);
timeinterval = 500000;
elseif diff_avg > 2 && diff_avg < 5
%set(H.age_int_1, 'Value', 1);
timeinterval = 1000000;
elseif diff_avg > 5 && diff_avg < 10
%set(H.age_int_2, 'Value', 1);
timeinterval = 2000000;
elseif diff_avg > 10 && diff_avg < 20
%set(H.age_int_5, 'Value', 1);
timeinterval = 5000000;
elseif diff_avg > 20 && diff_avg < 50
%set(H.age_int_10, 'Value', 1);
timeinterval = 10000000;
elseif diff_avg > 50 && diff_avg < 100
%set(H.age_int_25, 'Value', 1);
timeinterval = 25000000;
elseif diff_avg > 100 && diff_avg < 200
%set(H.age_int_50, 'Value', 1);
timeinterval = 50000000;
elseif diff_avg > 200
%set(H.age_int_100, 'Value', 1);
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

legend([p3], bestage,  'Location', 'northwest');









if get(H.all_unk, 'Value') == 1
timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

cla(H.axes_current_concordia,'reset');
axes(H.axes_current_concordia);
for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = plot(elpt_out_acc(:,1:2:end,i),elpt_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
		hold on
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = plot(elpt_out_rej(:,1:2:end,i),elpt_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
	end
end

plot(x,y,'k','LineWidth',1.4)
hold on

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

for i = 1:length(time4)
if x4(i,1) > min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 && x4(i,1) < max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	&& y4(i,1) > min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 && y4(i,1) < max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

legend([p1 p2],'Accepted Analyses','Rejected Analyses','Location','northwest');

axis([min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01]);
xlabel('207Pb/235U', 'FontSize', 10);
ylabel('206Pb/238U', 'FontSize', 10);

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

accan= 'Accepted Analyses';
rejan = 'Rejected Analyses';
legend([p1 p2 p3], [accan, rejan, bestage], 'Location','northwest');

end







%% DISTRIBUTION PLOT %%
cla(H.axes_distribution, 'reset');
axes(H.axes_distribution);

for i = 1:data_count
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
		dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
	end
end

if sum(current_status_num) > 0

dist_data = dist_data(any(dist_data ~= 0,2),:);

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
hist_ymin = 0;
bins = str2num(get(H.bins,'String'));
[counts binCenters] = hist(dist_data(:,1), bins);
hist_ymax = max(counts) + 1;
bins = str2num(get(H.bins,'String'));
x=xmin:xint:xmax;

if get(H.radio_hist, 'Value') == 1
	[counts binCenters] = hist(dist_data(:,1), bins);
	bar(binCenters, counts);
	axis([xmin xmax hist_ymin hist_ymax])
	xlabel('Age (Ma)','Color','k', 'FontSize', 10)
	ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_pdp, 'Value') == 1
	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
	lgnd=legend(p, 'Probability Density Plot');
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	set(lgnd,'color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k')
	ylabel('Probability','Color','k')
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
		set(H.Myr_Kernel_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
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
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
	end
		set(lgnd,'Color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_pdp, 'Value') == 1
	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	[counts binCenters] = hist(dist_data(:,1), bins);
	bar(binCenters, counts);
	hold on;
	p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
	axis([xmin xmax hist_ymin hist_ymax])
	lgnd=legend(p, 'Probability Density Plot');
	set(lgnd,'color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k', 'FontSize', 10)
	ylabel('Probability','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		kdemax = max(kdeA);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.Myr_Kernel_text, 'String', bandwidth);
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
	end
	if get(H.Myr_kernel,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
	end
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_pdp_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		kdemax = max(kdeA);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1],'Probability Density Plot','Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.Myr_Kernel_text, 'String', bandwidth);
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
	end
	if get(H.Myr_kernel,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		hold on
		pdpmax = max(kde1);
		set(p1,'linewidth',2)
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1], 'Probability Density Plot','Kernel Density Estimate');
	end
		set(lgnd,'Color','w');
		legend boxoff
 		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_pdp_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		set(H.Myr_Kernel_text, 'String', bandwidth);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(pdp))),'Color',[1 0 0]);
		hold on
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
		hold on
		p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
		set(p1,'linewidth',2)
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
		set(p1,'linewidth',2)
	end
		set(lgnd,'Color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
end
hold off
nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);
end

% Calculate systematic Uncertainties
for i = 1:length(STD1_idx)
	if STD1_idx(i,1) ~= 1 && BLS_68_err(i,1) < 20 
		syst_err_68(i,1) = sqrt(100*ffse68(i,1)/ffsw68(i,1)*100*ffse68(i,1)/ffsw68(i,1)+pbcerr68(i,1)*pbcerr68(i,1)+0.053*0.053+0.35*0.35);
	else
		syst_err_68(i,1) = 0;
	end
end

if length(syst_err_68) >= 126
	systerr68 = 2*mean(nonzeros(syst_err_68(1:126,1)));
else
	systerr68 = 2*mean(nonzeros(syst_err_68));
end

for i = 1:length(STD1_idx)
	if STD1_idx(i,1) ~= 1 && BLS_67_sort_err(i,1) < 20 && cell2num(Age68(i,1)) > 400
		syst_err_67(i,1) = sqrt(100*stdswse67(i,1)/stdfcsw67(i,1)*100*stdswse67(i,1)/stdfcsw67(i,1)+(pbcerr67(i,1))*(pbcerr67(i,1))+0.053*0.053+0.069*0.069+0.35*0.35);
	end
end

if length(syst_err_67) >= 126
	systerr67 = 2*mean(nonzeros(syst_err_67(1:126,1)));
else
	systerr67 = 2*mean(nonzeros(syst_err_67));
end

set(H.SE68,'String',systerr68)
set(H.SE67,'String',systerr67)










reduced = 1;

%% UPDATE HANDLES %%
H.sample = sample;
H.Data_All = Data_All;
H.Ablate = Ablate;
H.ratio75 = ratio75;
H.ratio75_err = ratio75_err;
H.ratio68 = ratio68;
H.err68m = err68m;
H.Age82 = Age82;
H.Age82_err = Age82_err;
H.Best_Age = Best_Age;
H.Best_Age_err = Best_Age_err;
H.rho = rho;
H.numpoints = numpoints;
H.sigmarule = sigmarule;
H.xc = xc;
H.yc = yc;
H.current_status = current_status;
H.current_status_num = current_status_num;
H.current_status_num_orig = current_status_num_orig;
H.comment = comment;
H.SAMPLE_CONCORDIA = SAMPLE_CONCORDIA;
H.Macro_1_2_Output = Macro_1_2_Output;
H.data_count = data_count;
H.STD1_idx = STD1_idx;
H.Age68 = Age68;
H.Age68_err = Age68_err;
H.Age67 = Age67;
H.Age67_err = Age67_err;
H.Macro1_Output = Macro1_Output;
H.AGES_OUT = AGES_OUT;
H.STD_CONCORDIA = STD_CONCORDIA;
H.CORRECTED_CONC_RATIOS = CORRECTED_CONC_RATIOS;
H.AGES_1SD_RANDOM_ERRORS = AGES_1SD_RANDOM_ERRORS;
H.STD1_num = STD1_num;
H.ffse68_hi = ffse68_hi;
H.ffse68_lo = ffse68_lo;
H.ffsw68 = ffsw68;
H.ff68_num = ff68_num;
H.ffse67_hi = ffse67_hi;
H.ffse67_lo = ffse67_lo;
H.stdfcsw67 = stdfcsw67;
H.ff67_num = ff67_num;
H.ffse82_hi = ffse82_hi;
H.ffse82_lo = ffse82_lo;
H.stdfcsw82 = stdfcsw82;
H.ff82_num = ff82_num;
H.sample_idx = sample_idx;
H.INT = INT;
H.sigx_sq_All = sigx_sq_All;
H.rho_sigx_sigy_All = rho_sigx_sigy_All;
H.sigy_sq_All = sigy_sq_All;
H.center_All = center_All;
H.name_char = name_char;
H.ffsw68 = ffsw68;
H.ffse68 = ffse68;
H.stdfcsw67 = stdfcsw67;
H.stdswse67 = stdswse67;
H.pbcerr68 = pbcerr68;
H.pbcerr67 = pbcerr67;
H.BLS_68_err = BLS_68_err;
H.BLS_67_sort_err = BLS_67_sort_err;

H.sigx_sq_STD1 = sigx_sq_STD1;
H.rho_sigx_sigy_STD1 = rho_sigx_sigy_STD1;
H.sigy_sq_STD1 = sigy_sq_STD1;
H.center_STD1 = center_STD1;
H.STD1_68 = STD1_68;
H.STD1_67 = STD1_67;

H.sigx_sq_STD2 = sigx_sq_STD2;
H.rho_sigx_sigy_STD2 = rho_sigx_sigy_STD2;
H.rho_sigx_sigy_STD2 = rho_sigx_sigy_STD2;
H.sigy_sq_STD2 = sigy_sq_STD2;
H.center_STD2 = center_STD2;
H.STD2_68 = STD2_68;
H.STD2_67 = STD2_67;
H.STD2_idx = STD2_idx;
H.reduced = reduced;

H.name_char_std = name_char_std;
%H.sc = sc;

if get(H.auto_reduce,'Value') == 0
	guidata(hObject,H);
end


%% PUSHBUTTON PLOT SESSION DRIFT %%
function plot_fract_68_Callback(hObject, eventdata, H)
cla(H.axes_session_fractionation,'reset');
data_count = H.data_count;
ffse68_hi = H.ffse68_hi;
ffse68_lo = H.ffse68_lo;
ffsw68 = H.ffsw68;
STD1_num = H.STD1_num;
ff68_num = H.ff68_num;
axes(H.axes_session_fractionation);
hold on
fill([(1:1:data_count)';flipud((1:1:data_count)')], [ffse68_hi; flipud(ffse68_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
plot([(1:1:data_count); (1:1:data_count)], [(ffsw68+ffsw68*0.02)'; (ffsw68-ffsw68*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',1) % Error bars
scatter(STD1_num, ff68_num, 75, 'b', 'filled','d')
axis([0 data_count+1 min([(ffsw68-ffsw68*0.02);ff68_num])-0.02*min([(ffsw68-ffsw68*0.02);ff68_num]) max([(ffsw68+ffsw68*0.02);ff68_num])+0.02*max([(ffsw68+ffsw68*0.02);ff68_num])])
hold off
%title('Pb206/U238 Session drift')
xlabel('Analysis number')
ylabel('Pb206/U238 fractionation factor')

function plot_fract_76_Callback(hObject, eventdata, H)
cla(H.axes_session_fractionation,'reset');
data_count = H.data_count;
ffse67_hi = H.ffse67_hi;
ffse67_lo = H.ffse67_lo;
stdfcsw67 = H.stdfcsw67;
STD1_num = H.STD1_num;
ff67_num = H.ff67_num;
axes(H.axes_session_fractionation);
hold on
fill([(1:1:data_count)';flipud((1:1:data_count)')], [ffse67_hi; flipud(ffse67_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
plot([(1:1:data_count); (1:1:data_count)], [(stdfcsw67+stdfcsw67*0.02)'; (stdfcsw67-stdfcsw67*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',1) % Error bars
scatter(STD1_num, ff67_num, 75, 'b', 'filled','d')
axis([0 data_count+1 min([(stdfcsw67-stdfcsw67*0.02);ff67_num])-0.02*min([(stdfcsw67-stdfcsw67*0.02);ff67_num]) max([(stdfcsw67+stdfcsw67*0.02);ff67_num])+0.02*max([(stdfcsw67+stdfcsw67*0.02);ff67_num])])
hold off
%title('Pb206/Pb207 Session drift')
xlabel('Analysis number')
ylabel('Pb206/Pb207 fractionation factor')

function plot_fract_82_Callback(hObject, eventdata, H)
cla(H.axes_session_fractionation,'reset');
data_count = H.data_count;
ffse82_hi = H.ffse82_hi;
ffse82_lo = H.ffse82_lo;
stdfcsw82 = H.stdfcsw82;
STD1_num = H.STD1_num;
ff82_num = H.ff82_num;
axes(H.axes_session_fractionation);
hold on
fill([(1:1:data_count)';flipud((1:1:data_count)')], [ffse82_hi; flipud(ffse82_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
plot([(1:1:data_count); (1:1:data_count)], [(stdfcsw82+stdfcsw82*0.02)'; (stdfcsw82-stdfcsw82*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',1) % Error bars
scatter(STD1_num, ff82_num, 75, 'b', 'filled','d')
axis([0 data_count+1 min([(stdfcsw82-stdfcsw82*0.02);ff82_num])-0.02*min([(stdfcsw82-stdfcsw82*0.02);ff82_num]) max([(stdfcsw82+stdfcsw82*0.02);ff82_num])+0.02*max([(stdfcsw82+stdfcsw82*0.02);ff82_num])])
hold off
%title('Pb208/Th232 Session drift')
xlabel('Analysis number')
ylabel('Pb208/Th232 fractionation factor')

%% LISTBOX SELECT %%
function listbox1_Callback(hObject, eventdata, H)
sample = H.sample;
Data_All = H.Data_All;
Ablate = H.Ablate;
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
current_status = H.current_status;
current_status_num = H.current_status_num;
current_status_num_orig = H.current_status_num_orig;
comment = H.comment;
INT = H.INT;
axes(H.axes_session);



name_idx = get(H.listbox1,'Value');

%for i=1:length(sample)
%name_char(i,1)=(sample(i,1));
%end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:8
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end

C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

hold on

%if get(H.All_Standards,'Value')==1 

%plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
%end











if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness, 'color',C{7});
end
if get(H.chk_Pb206_U238,'Value')==1 
plot(Ablate,plot_vals(:,8),'linewidth', thickness, 'color', 'k');
end
if get(H.chk_Pb206_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,9),'linewidth', thickness, 'color', 'k');
end
if get(H.chk_Pb208_Th232,'Value')==1 
plot(Ablate,plot_vals(:,10),'linewidth', thickness, 'color', 'k');
end





hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])



if current_status_num(name_idx,1) == 1 && current_status_num_orig(name_idx,1) == 1 
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');

elseif current_status_num(name_idx,1) == 0 && current_status_num_orig(name_idx,1) == 0 
%current_status{name_idx, 1} = comment{name_idx,1};
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');

elseif current_status_num(name_idx,1) == 1 && current_status_num_orig(name_idx,1) == 0 
current_status{name_idx, 1} = strcat({'Accepted with '}, comment{name_idx,1});
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');

elseif current_status_num(name_idx,1) == 0 && current_status_num_orig(name_idx,1) == 1 
current_status{name_idx, 1} = {'Rejected, but originally was accepted'};
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');

end




axes(H.axes_current_concordia);
cla(H.axes_current_concordia,'reset');
set(H.axes_current_concordia,'FontSize',8);
%set(H.axes_current_concordia,'String',sample{name_idx,1});

bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});

if get(H.all_unk, 'Value') == 0

concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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


if current_status_num(name_idx,1) == 1
	plot(elpt_out(:,1:2:end),elpt_out(:,2:2:end),'b','LineWidth',1.2);
else
	plot(elpt_out(:,1:2:end),elpt_out(:,2:2:end),'r','LineWidth',1.2);
end

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

%set(H.age_int_05, 'Value', 0);
%set(H.age_int_1, 'Value', 0);
%set(H.age_int_2, 'Value', 0);
%set(H.age_int_5, 'Value', 0);
%set(H.age_int_10, 'Value', 0);
%set(H.age_int_25, 'Value', 0);
%set(H.age_int_50, 'Value', 0);
%set(H.age_int_100, 'Value', 0);

if diff_avg > 0.5 && diff_avg < 2
%set(H.age_int_05, 'Value', 1);
timeinterval = 500000;
elseif diff_avg > 2 && diff_avg < 5
%set(H.age_int_1, 'Value', 1);
timeinterval = 1000000;
elseif diff_avg > 5 && diff_avg < 10
%set(H.age_int_2, 'Value', 1);
timeinterval = 2000000;
elseif diff_avg > 10 && diff_avg < 20
%set(H.age_int_5, 'Value', 1);
timeinterval = 5000000;
elseif diff_avg > 20 && diff_avg < 50
%set(H.age_int_10, 'Value', 1);
timeinterval = 10000000;
elseif diff_avg > 50 && diff_avg < 100
%set(H.age_int_25, 'Value', 1);
timeinterval = 25000000;
elseif diff_avg > 100 && diff_avg < 200
%set(H.age_int_50, 'Value', 1);
timeinterval = 50000000;
elseif diff_avg > 200
%set(H.age_int_100, 'Value', 1);
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

if get(H.leg_on,'Value')==1
	legend(p3, bestage,  'Location', 'northwest');
end


end




if get(H.all_unk, 'Value') == 1

sigx_sq_All = H.sigx_sq_All;
rho_sigx_sigy_All = H.rho_sigx_sigy_All;
sigy_sq_All = H.sigy_sq_All;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
center_All = H.center_All;
sample_idx = H.sample_idx;
current_status_num = H.current_status_num;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

cla(H.axes_current_concordia,'reset');
axes(H.axes_current_concordia);
for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = plot(elpt_out_acc(:,1:2:end,i),elpt_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
		hold on
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = plot(elpt_out_rej(:,1:2:end,i),elpt_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
	end
end

plot(x,y,'k','LineWidth',1.4)
hold on

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

for i = 1:length(time4)
if x4(i,1) > min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 && x4(i,1) < max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	&& y4(i,1) > min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 && y4(i,1) < max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

axis([min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01]);
xlabel('207Pb/235U', 'FontSize', 10);
ylabel('206Pb/238U', 'FontSize', 10);

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

accan= 'Accepted Analyses';
rejan = 'Rejected Analyses';

if get(H.leg_on,'Value')==1
	legend([p1 p2 p3], [accan, rejan, bestage], 'Location','northwest');
end

end

axes(H.axes_session);

if get(H.ptype_Unknowns, 'Value') == 1 || get(H.ptype_Unknowns_acc, 'Value') == 1 || get(H.ptype_Unknowns_rej, 'Value') == 1 
	p1 = H.p1;
	p2 = H.p2;
	p3 = H.p3;
	set(p3,'Visible','off')
	clear p3
end

if get(H.ptype_Unknowns, 'Value') == 1 || get(H.ptype_Unknowns_acc, 'Value') == 1 || get(H.ptype_Unknowns_rej, 'Value') == 1 
	p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);


accan= {'Accepted Analyses'};
rejan = {'Rejected Analyses'};

if get(H.leg_on_session,'Value') == 1 && get(H.ptype_Unknowns,'Value') == 1
	legend([p1 p2 p3], [accan, rejan, sample(name_idx)], 'Location','northwest');
elseif get(H.leg_on_session,'Value') == 1 && get(H.ptype_Unknowns_acc,'Value') == 1
	legend([p1 p3], [accan, sample(name_idx)], 'Location','northwest');
elseif get(H.leg_on_session,'Value') == 1 && get(H.ptype_Unknowns_rej,'Value') == 1
	legend([p2 p3], [rejan, sample(name_idx)], 'Location','northwest');
else
	legend('hide')
end

H.p3 = p3;
end
guidata(hObject,H);







%% ACCEPT/REJECT INDIVIDUAL ANALYSES %%
function accept_reject_Callback(hObject, eventdata, H)
name_idx = get(H.listbox1,'Value');
current_status = H.current_status;
current_status_num = H.current_status_num;
current_status_num_orig = H.current_status_num_orig;
comment = H.comment;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
Macro_1_2_Output = H.Macro_1_2_Output;
data_count = H.data_count;
STD1_idx = H.STD1_idx;
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
Age82 = H.Age82;
Age82_err = H.Age82_err;
Age68 = H.Age68;
Age68_err = H.Age68_err;
Age67 = H.Age67;
Age67_err = H.Age67_err;
Macro1_Output = H.Macro1_Output;
AGES_OUT = H.AGES_OUT;
STD_CONCORDIA = H.STD_CONCORDIA;
CORRECTED_CONC_RATIOS = H.CORRECTED_CONC_RATIOS;
AGES_1SD_RANDOM_ERRORS = H.AGES_1SD_RANDOM_ERRORS;
sample_idx = H.sample_idx;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
sample = H.sample;
name_char = H.name_char;

current_status_num(name_idx,1) = abs(current_status_num(name_idx,1) - 1);

comment_new = comment;

if current_status_num(name_idx,1) == 1 && current_status_num_orig(name_idx,1) == 1 
current_status{name_idx, 1} = ['Accepted'];
comment_new{name_idx, 1} = [];
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');

elseif current_status_num(name_idx,1) == 0 && current_status_num_orig(name_idx,1) == 0 
current_status{name_idx, 1} = ['Rejected: ', comment{name_idx,1}];
comment_new{name_idx, 1} = ['Rejected: ', comment{name_idx,1}];
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');

elseif current_status_num(name_idx,1) == 1 && current_status_num_orig(name_idx,1) == 0 
current_status{name_idx, 1} = strcat({'Accepted with '}, comment{name_idx,1});
comment_new{name_idx, 1} = strcat({'Accepted with '}, comment{name_idx,1});
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');

elseif current_status_num(name_idx,1) == 0 && current_status_num_orig(name_idx,1) == 1 
current_status{name_idx, 1} = {'Rejected, but originally was accepted'};
comment_new{name_idx, 1} = {'Rejected, but originally was accepted'};
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');

end

if current_status_num(name_idx,1) == 1
	name_char(name_idx,1) = sample(name_idx,1);
elseif current_status_num(name_idx,1) == 0
	name_char(name_idx,1) = strcat('<html><BODY bgcolor="red">',name_char(name_idx,1),'</span></html>');
end

set(H.listbox1, 'String', name_char);

currView = get(H.listbox1,'ListBoxTop');
set(H.listbox1,'ListBoxTop',currView)

clear SAMPLE_CONCORDIA

SAMPLE_CONCORDIA{data_count+1, 13} = [];
SAMPLE_CONCORDIA(1,:) = {'7/5 ratio', '±(%)', '6/8 ratio', '±(%)', 'rho', '6/8 age', '±(Ma)', '6/7 age', '±(Ma)', 'BEST AGE', '±(Ma)', '8/2 age', '±(Ma)'};

for i = 1:data_count
if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
SAMPLE_CONCORDIA(i+1,:) = [num2cell(ratio75(i,:)), num2cell(ratio75_err(i,:)), num2cell(ratio68(i,:)), ...
	num2cell(err68m(i,:)), num2cell(rho(i,:)), Age68(i,:), Age68_err(i,:), Age67(i,:), Age67_err(i,:), ...
	Best_Age(i,:), Best_Age_err(i,:), Age82(i,:), Age82_err(i,:)];
end
end

bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});

%clear Best_Age
%clear Best_Age_err
%Best_Age{data_count+1, 1} = [];
%Best_Age_err{data_count+1, 1} = [];

%for i = 1:data_count
%if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
%Best_Age(i+1,1) = SAMPLE_CONCORDIA(i+1,10);
%Best_Age_err(i+1,1) = SAMPLE_CONCORDIA(i+1,11);
%end
%end

comment = comment_new;

Macro_1_2_Output = [Macro1_Output, AGES_OUT, [{'comment'};comment], SAMPLE_CONCORDIA, STD_CONCORDIA, CORRECTED_CONC_RATIOS, AGES_1SD_RANDOM_ERRORS];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





axes(H.axes_current_concordia);
cla(H.axes_current_concordia,'reset');
set(H.axes_current_concordia,'FontSize',8);
%set(H.axes_current_concordia,'String',sample{name_idx,1});

if get(H.all_unk, 'Value') == 0

concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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


if current_status_num(name_idx,1) == 1
	plot(elpt_out(:,1:2:end),elpt_out(:,2:2:end),'b','LineWidth',1.2);
else
	plot(elpt_out(:,1:2:end),elpt_out(:,2:2:end),'r','LineWidth',1.2);
end
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

%set(H.age_int_05, 'Value', 0);
%set(H.age_int_1, 'Value', 0);
%set(H.age_int_2, 'Value', 0);
%set(H.age_int_5, 'Value', 0);
%set(H.age_int_10, 'Value', 0);
%set(H.age_int_25, 'Value', 0);
%set(H.age_int_50, 'Value', 0);
%set(H.age_int_100, 'Value', 0);

if diff_avg > 0.5 && diff_avg < 2
%set(H.age_int_05, 'Value', 1);
timeinterval = 500000;
elseif diff_avg > 2 && diff_avg < 5
%set(H.age_int_1, 'Value', 1);
timeinterval = 1000000;
elseif diff_avg > 5 && diff_avg < 10
%set(H.age_int_2, 'Value', 1);
timeinterval = 2000000;
elseif diff_avg > 10 && diff_avg < 20
%set(H.age_int_5, 'Value', 1);
timeinterval = 5000000;
elseif diff_avg > 20 && diff_avg < 50
%set(H.age_int_10, 'Value', 1);
timeinterval = 10000000;
elseif diff_avg > 50 && diff_avg < 100
%set(H.age_int_25, 'Value', 1);
timeinterval = 25000000;
elseif diff_avg > 100 && diff_avg < 200
%set(H.age_int_50, 'Value', 1);
timeinterval = 50000000;
elseif diff_avg > 200
%set(H.age_int_100, 'Value', 1);
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});
legend(p3, bestage,  'Location', 'northwest');
guidata(hObject,H);

end




if get(H.all_unk, 'Value') == 1

sigx_sq_All = H.sigx_sq_All;
rho_sigx_sigy_All = H.rho_sigx_sigy_All;
sigy_sq_All = H.sigy_sq_All;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
center_All = H.center_All;
sample_idx = H.sample_idx;
current_status_num = H.current_status_num;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

cla(H.axes_current_concordia,'reset');
axes(H.axes_current_concordia);
for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = plot(elpt_out_acc(:,1:2:end,i),elpt_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
		hold on
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = plot(elpt_out_rej(:,1:2:end,i),elpt_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
	end
end

plot(x,y,'k','LineWidth',1.4)
hold on

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

for i = 1:length(time4)
if x4(i,1) > min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 && x4(i,1) < max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	&& y4(i,1) > min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 && y4(i,1) < max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

axis([min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01]);
xlabel('207Pb/235U', 'FontSize', 10);
ylabel('206Pb/238U', 'FontSize', 10);

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

accan= 'Accepted Analyses';
rejan = 'Rejected Analyses';

legend([p1 p2 p3], [accan, rejan, bestage], 'Location','northwest');

end








axes(H.axes_distribution);
cla(H.axes_distribution, 'reset');

for i = 1:data_count
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
		dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
	end
end

if sum(current_status_num) > 0

dist_data = dist_data(any(dist_data ~= 0,2),:);

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
hist_ymin = 0;
bins = str2num(get(H.bins,'String'));
[counts binCenters] = hist(dist_data(:,1), bins);
hist_ymax = max(counts) + 1;
bins = str2num(get(H.bins,'String'));
x=xmin:xint:xmax;

if get(H.radio_hist, 'Value') == 1
	[counts binCenters] = hist(dist_data(:,1), bins);
	bar(binCenters, counts);
	axis([xmin xmax hist_ymin hist_ymax])
	xlabel('Age (Ma)','Color','k', 'FontSize', 10)
	ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_pdp, 'Value') == 1
	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
	lgnd=legend(p, 'Probability Density Plot');
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	set(lgnd,'color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k')
	ylabel('Probability','Color','k')
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
		set(H.Myr_Kernel_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
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
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
	end
		set(lgnd,'Color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_pdp, 'Value') == 1
	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	[counts binCenters] = hist(dist_data(:,1), bins);
	bar(binCenters, counts);
	hold on;
	p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
	axis([xmin xmax hist_ymin hist_ymax])
	lgnd=legend(p, 'Probability Density Plot');
	set(lgnd,'color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k', 'FontSize', 10)
	ylabel('Probability','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		kdemax = max(kdeA);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.Myr_Kernel_text, 'String', bandwidth);
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
	end
	if get(H.Myr_kernel,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
	end
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_pdp_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		kdemax = max(kdeA);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1],'Probability Density Plot','Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.Myr_Kernel_text, 'String', bandwidth);
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
	end
	if get(H.Myr_kernel,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		hold on
		pdpmax = max(kde1);
		set(p1,'linewidth',2)
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1], 'Probability Density Plot','Kernel Density Estimate');
	end
		set(lgnd,'Color','w');
		legend boxoff
 		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_pdp_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		set(H.Myr_Kernel_text, 'String', bandwidth);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(pdp))),'Color',[1 0 0]);
		hold on
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
		hold on
		p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
		set(p1,'linewidth',2)
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
		set(p1,'linewidth',2)
	end
		set(lgnd,'Color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
end

nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);
end

H.SAMPLE_CONCORDIA = SAMPLE_CONCORDIA;
H.Macro_1_2_Output = Macro_1_2_Output;
H.current_status = current_status;
H.current_status_num = current_status_num;
H.STD1_idx = STD1_idx;
H.name_char = name_char;
guidata(hObject,H);

%% CHECKBOXES DISTRIBUTION PLOT %%
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
set(H.xint,'Enable','off')
set(H.xint_t,'Enable','off')
set(H.Myr_kernel,'Enable','off')
set(H.Myr_Kernel_text,'Enable','off')
set(H.optimize,'Enable','off')
reduced = H.reduced;
if reduced == 1
data_count = H.data_count;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
current_status_num = H.current_status_num;
sample_idx = H.sample_idx;
cla(H.axes_distribution, 'reset');
axes(H.axes_distribution);
for i = 1:data_count
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
		dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
	end
end
if sum(current_status_num) > 0
	dist_data = dist_data(any(dist_data ~= 0,2),:);
	xmin = str2num(get(H.xmin,'String'));
	xmax = str2num(get(H.xmax,'String'));
	hist_ymin = 0;
	bins = str2num(get(H.bins,'String'));
	[counts binCenters] = hist(dist_data(:,1), bins);
	hist_ymax = max(counts) + 1;
	bar(binCenters, counts);
	axis([xmin xmax hist_ymin hist_ymax])
	xlabel('Age (Ma)','Color','k', 'FontSize', 10)
	ylabel('Number','Color','k', 'FontSize', 10)
end
nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);
end

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
reduced = H.reduced;
if reduced == 1
data_count = H.data_count;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
current_status_num = H.current_status_num;
sample_idx = H.sample_idx;
cla(H.axes_distribution, 'reset');
axes(H.axes_distribution);
for i = 1:data_count
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
		dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
	end
end
if sum(current_status_num) > 0
	dist_data = dist_data(any(dist_data ~= 0,2),:);
	xmin = str2num(get(H.xmin,'String'));
	xmax = str2num(get(H.xmax,'String'));
	xint = str2num(get(H.xint,'String'));
	x=xmin:xint:xmax;
	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
	lgnd=legend(p, 'Probability Density Plot');
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	set(lgnd,'Color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k', 'FontSize', 10)
	ylabel('Probability','Color','k', 'FontSize', 10)
end
nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);
end

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
reduced = H.reduced;
if reduced == 1
data_count = H.data_count;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
current_status_num = H.current_status_num;
sample_idx = H.sample_idx;
cla(H.axes_distribution, 'reset');
axes(H.axes_distribution);
for i = 1:data_count
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
		dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
	end
end
if sum(current_status_num) > 0
	dist_data = dist_data(any(dist_data ~= 0,2),:);
	xmin = str2num(get(H.xmin,'String'));
	xmax = str2num(get(H.xmax,'String'));
	xint = str2num(get(H.xint,'String'));
	x=xmin:xint:xmax;
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
		set(H.Myr_Kernel_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
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
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
	end
		set(lgnd,'Color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
end
nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);
end

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
reduced = H.reduced;
if reduced == 1
data_count = H.data_count;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
current_status_num = H.current_status_num;
sample_idx = H.sample_idx;
cla(H.axes_distribution, 'reset');
axes(H.axes_distribution);
for i = 1:data_count
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
		dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
	end
end
if sum(current_status_num) > 0
	dist_data = dist_data(any(dist_data ~= 0,2),:);
	xmin = str2num(get(H.xmin,'String'));
	xmax = str2num(get(H.xmax,'String'));
	xint = str2num(get(H.xint,'String'));
	x=xmin:xint:xmax;
	if get(H.optimize,'Value') == 1
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		set(H.Myr_Kernel_text, 'String', bandwidth);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(pdp))),'Color',[1 0 0]);
		hold on
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
		hold on
		p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
		set(p1,'linewidth',2)
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
		set(p1,'linewidth',2)
	end
		set(lgnd,'Color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
end
nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);
end

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
reduced = H.reduced;
if reduced == 1
data_count = H.data_count;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
current_status_num = H.current_status_num;
sample_idx = H.sample_idx;
cla(H.axes_distribution, 'reset');
axes(H.axes_distribution);
for i = 1:data_count
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
		dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
	end
end
if sum(current_status_num) > 0
	dist_data = dist_data(any(dist_data ~= 0,2),:);
	xmin = str2num(get(H.xmin,'String'));
	xmax = str2num(get(H.xmax,'String'));
	xint = str2num(get(H.xint,'String'));
	bins = str2num(get(H.bins,'String'));
	x=xmin:xint:xmax;
	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	hist_ymin = 0;
	bins = str2num(get(H.bins,'String'));
	[counts binCenters] = hist(dist_data(:,1), bins);
	hist_ymax = max(counts) + 1;
	bar(binCenters, counts);
	hold on;
	p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
	axis([xmin xmax hist_ymin hist_ymax])
	lgnd=legend(p, 'Probability Density Plot');
	set(lgnd,'color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k', 'FontSize', 10)
	ylabel('Probability','Color','k', 'FontSize', 10)
end
nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);
end

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
reduced = H.reduced;
if reduced == 1
data_count = H.data_count;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
current_status_num = H.current_status_num;
sample_idx = H.sample_idx;
cla(H.axes_distribution, 'reset');
axes(H.axes_distribution);
for i = 1:data_count
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
		dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
	end
end
if sum(current_status_num) > 0
	dist_data = dist_data(any(dist_data ~= 0,2),:);
	xmin = str2num(get(H.xmin,'String'));
	xmax = str2num(get(H.xmax,'String'));
	xint = str2num(get(H.xint,'String'));
	x=xmin:xint:xmax;
	hist_ymin = 0;
	bins = str2num(get(H.bins,'String'));
	if get(H.optimize,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		kdemax = max(kdeA);
		hist_ymax = max(counts) + 1;
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.Myr_Kernel_text, 'String', bandwidth);
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
	end
	if get(H.Myr_kernel,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		hist_ymax = max(counts) + 1;
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
	end
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
end
nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);
end

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
reduced = H.reduced;
if reduced == 1
data_count = H.data_count;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
current_status_num = H.current_status_num;
sample_idx = H.sample_idx;
cla(H.axes_distribution, 'reset');
axes(H.axes_distribution);
for i = 1:data_count
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
		dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
	end
end
if sum(current_status_num) > 0
	dist_data = dist_data(any(dist_data ~= 0,2),:);
	xmin = str2num(get(H.xmin,'String'));
	xmax = str2num(get(H.xmax,'String'));
	xint = str2num(get(H.xint,'String'));
	x=xmin:xint:xmax;
	hist_ymin = 0;
	bins = str2num(get(H.bins,'String'));
	if get(H.optimize,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		kdemax = max(kdeA);
		hist_ymax = max(counts) + 1;
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1],'Probability Density Plot','Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.Myr_Kernel_text, 'String', bandwidth);
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
	end
	if get(H.Myr_kernel,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		hold on
		pdpmax = max(kde1);
		hist_ymax = max(counts) + 1;
		set(p1,'linewidth',2)
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1], 'Probability Density Plot','Kernel Density Estimate');
	end
		set(lgnd,'Color','w');
		legend boxoff
 		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
end
nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);
end

%% CHECKBOXES %%
function log_scale_Callback(hObject, eventdata, H)
listbox1_Callback(hObject, eventdata, H)
%{
reduced = H.reduced;
if reduced == 1

name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:8
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end
C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on
if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness, 'color',C{7});
end
if get(H.chk_Pb206_U238,'Value')==1 
plot(Ablate,plot_vals(:,8),'linewidth', thickness, 'color','k');
end
if get(H.chk_Pb206_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,9),'linewidth', thickness, 'color','k');
end
if get(H.chk_Pb208_Th232,'Value')==1 
plot(Ablate,plot_vals(:,10),'linewidth', thickness, 'color','k');
end


hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])	
	
end
%}
 
function thick_lines_Callback(hObject, eventdata, H)
listbox1_Callback(hObject, eventdata, H)
%{
reduced = H.reduced;
if reduced == 1

name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:8
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end
C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on
if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness, 'color',C{7});
end
if get(H.chk_Pb206_U238,'Value')==1 
plot(Ablate,plot_vals(:,8),'linewidth', thickness, 'color','k');
end
if get(H.chk_Pb206_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,9),'linewidth', thickness, 'color','k');
end
if get(H.chk_Pb208_Th232,'Value')==1 
plot(Ablate,plot_vals(:,10),'linewidth', thickness, 'color','k');
end


hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])	
	
end
%}


function chk_Hg202_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)
%{
reduced = H.reduced;
if reduced == 1
	
name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
STD1_idx = H.STD1_idx;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end



values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);
for i = 1:length(Data_All(1,1,:))
	values3(:,:,i) = Data_All(:,:,i).*80000000;
end
values3(:,8,:) = values3(:,5,:)./values3(:,1,:);
values3(:,9,:) = values3(:,5,:)./values3(:,4,:);
values3(:,10,:) = values3(:,3,:)./values3(:,2,:);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:10
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
	for i = 1:INT
		for j = 1:10
			for k = 1:length(values3(1,1,:))
				if values3(i,j,k) < 0 
					values3(i,j,k) = 1;
				end
			end
		end
	end
	values3 = log10(values3);
	values3(~isfinite(values3))=0;
end




if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end
C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on













if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness, 'color',C{7});
end
hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])
end 
%}




function chk_Pb204_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)

%{

reduced = H.reduced;
if reduced == 1
	
name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:8
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end
C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on
if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness, 'color',C{7});
end
hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])

end
%}

function chk_Pb206_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)
%{

reduced = H.reduced;
if reduced == 1
	
name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:8
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end
C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on
if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness, 'color',C{7});
end
hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])

end
%}

function chk_Pb207_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)

%{

reduced = H.reduced;
if reduced == 1
	
name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:8
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end
C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on
if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness, 'color',C{7});
end
hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])

end
%}


function chk_Pb208_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)

%{
reduced = H.reduced;
if reduced == 1
	
name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:8
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end
C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on
if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness, 'color',C{7});
end
hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])

end
%}

function chk_Th232_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)

%{
reduced = H.reduced;
if reduced == 1
	
name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:8
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end
C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on
if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness, 'color',C{7});
end
hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])

end
%}

function chk_U238_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)

%{
reduced = H.reduced;
if reduced == 1
	
name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
STD1_idx = H.STD1_idx;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);
for i = 1:length(Data_All(1,1,:))
	values3(:,:,i) = Data_All(:,:,i).*80000000;
end
values3(:,8,:) = values3(:,5,:)./values3(:,1,:);
values3(:,9,:) = values3(:,5,:)./values3(:,4,:);
values3(:,10,:) = values3(:,3,:)./values3(:,2,:);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:10
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
	for i = 1:INT
		for j = 1:10
			for k = 1:length(values3(1,1,:))
				if values3(i,j,k) < 0 
					values3(i,j,k) = 1;
				end
			end
		end
	end
	values3 = log10(values3);
	values3(~isfinite(values3))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end

C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on

%{
if get(H.All_Primary_STDs,'Value')==1 
	for i = 1:length(values3(1,1,:))
		if STD1_idx(i,1) == 1
			plot(Ablate,values3(:,1,i),'linewidth', 0.25, 'color',C{7});
		end
	end
end
%}


if get(H.chk_Hg202,'Value')==1 
plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Pb204,'Value')==1 
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb206,'Value')==1 
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb207,'Value')==1 
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb208,'Value')==1 
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Th232,'Value')==1 
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{6});
end
if get(H.chk_U238,'Value')==1 
plot(Ablate,plot_vals(:,1),'linewidth', thickness, 'color',C{7});
end
hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])

end

%}

function chk_Pb206_U238_Callback(hObject, eventdata, H)

if get(H.chk_Pb206_U238,'Value')==1 
	set(H.chk_Hg202,'Value', 0);
	set(H.chk_Pb204,'Value', 0);
	set(H.chk_Pb206,'Value', 0);
	set(H.chk_Pb207,'Value', 0);
	set(H.chk_Pb208,'Value', 0);
	set(H.chk_Th232,'Value', 0);
	set(H.chk_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)

%{
reduced = H.reduced;
if reduced == 1
	
name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
STD1_idx = H.STD1_idx;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);
for i = 1:length(Data_All(1,1,:))
	values3(:,:,i) = Data_All(:,:,i).*80000000;
end
values3(:,8,:) = values3(:,5,:)./values3(:,1,:);
values3(:,9,:) = values3(:,5,:)./values3(:,4,:);
values3(:,10,:) = values3(:,3,:)./values3(:,2,:);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:10
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
	for i = 1:INT
		for j = 1:10
			for k = 1:length(values3(1,1,:))
				if values3(i,j,k) < 0 
					values3(i,j,k) = 1;
				end
			end
		end
	end
	values3 = log10(values3);
	values3(~isfinite(values3))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end

axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on





plot(Ablate,plot_vals(:,8),'linewidth', thickness, 'color', 'k');


hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])	
	
end
%}

function chk_Pb206_Pb207_Callback(hObject, eventdata, H)

if get(H.chk_Pb206_Pb207,'Value')==1 
	set(H.chk_Hg202,'Value', 0);
	set(H.chk_Pb204,'Value', 0);
	set(H.chk_Pb206,'Value', 0);
	set(H.chk_Pb207,'Value', 0);
	set(H.chk_Pb208,'Value', 0);
	set(H.chk_Th232,'Value', 0);
	set(H.chk_U238,'Value', 0);
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)

%{
reduced = H.reduced;
if reduced == 1

name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:8
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end
C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on

plot(Ablate,plot_vals(:,9),'linewidth', thickness, 'color', 'k');

hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])	
	
end
%}

function chk_Pb208_Th232_Callback(hObject, eventdata, H)

if get(H.chk_Pb208_Th232,'Value')==1 
	set(H.chk_Hg202,'Value', 0);
	set(H.chk_Pb204,'Value', 0);
	set(H.chk_Pb206,'Value', 0);
	set(H.chk_Pb207,'Value', 0);
	set(H.chk_Pb208,'Value', 0);
	set(H.chk_Th232,'Value', 0);
	set(H.chk_U238,'Value', 0);
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)

%{
reduced = H.reduced;
if reduced == 1

name_idx = get(H.listbox1,'Value');
Data_All = H.Data_All;
sample = H.sample;
Ablate = H.Ablate;
INT = H.INT;
for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end

values = Data_All(:,:,name_idx).*80000000;
values2 = values(any(values,2),:);
values2(:,8) = values2(:,5)./values2(:,1);
values2(:,9) = values2(:,5)./values2(:,4);
values2(:,10) = values2(:,3)./values2(:,2);

if get(H.log_scale, 'Value') == 1
	for i = 1:INT
		for j = 1:8
			if values2(i,j) < 0 
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2);
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2;
end
C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end
hold on

plot(Ablate,plot_vals(:,10),'linewidth', thickness, 'color', 'k');

hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])	
	
end
%}










%% INDIVIDUAL SAMPLE CONCORDIA AGE INTERVAL %%
function age_int_100_Callback(hObject, eventdata, H)
cla(H.axes_current_concordia,'reset');
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
name_idx = get(H.listbox1,'Value');
set(H.age_int_05, 'Value', 0);
set(H.age_int_1, 'Value', 0);
set(H.age_int_2, 'Value', 0);
set(H.age_int_5, 'Value', 0);
set(H.age_int_10, 'Value', 0);
set(H.age_int_25, 'Value', 0);
set(H.age_int_50, 'Value', 0);
set(H.age_int_100, 'Value', 1);
timeinterval = 100000000;
axes(H.axes_current_concordia);
set(H.axes_current_concordia,'FontSize',8);
p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
hold on
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});
legend([p3], bestage,  'Location', 'northwest');
set(H.axes_current_concordia,'FontSize',8);
concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

function age_int_50_Callback(hObject, eventdata, H)
cla(H.axes_current_concordia,'reset');
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
name_idx = get(H.listbox1,'Value');
set(H.age_int_05, 'Value', 0);
set(H.age_int_1, 'Value', 0);
set(H.age_int_2, 'Value', 0);
set(H.age_int_5, 'Value', 0);
set(H.age_int_10, 'Value', 0);
set(H.age_int_25, 'Value', 0);
set(H.age_int_50, 'Value', 1);
set(H.age_int_100, 'Value', 0);
timeinterval = 50000000;
axes(H.axes_current_concordia);
set(H.axes_current_concordia,'FontSize',8);
p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
hold on
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});
legend([p3], bestage,  'Location', 'northwest');
set(H.axes_current_concordia,'FontSize',8);
concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);





function leg_on_Callback(hObject, eventdata, H)

listbox1_Callback(hObject, eventdata, H)






function age_int_25_Callback(hObject, eventdata, H)
cla(H.axes_current_concordia,'reset');
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
name_idx = get(H.listbox1,'Value');
set(H.age_int_05, 'Value', 0);
set(H.age_int_1, 'Value', 0);
set(H.age_int_2, 'Value', 0);
set(H.age_int_5, 'Value', 0);
set(H.age_int_10, 'Value', 0);
set(H.age_int_25, 'Value', 1);
set(H.age_int_50, 'Value', 0);
set(H.age_int_100, 'Value', 0);
timeinterval = 25000000;
axes(H.axes_current_concordia);
set(H.axes_current_concordia,'FontSize',8);
p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
hold on
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});
legend([p3], bestage,  'Location', 'northwest');
set(H.axes_current_concordia,'FontSize',8);
concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

function age_int_10_Callback(hObject, eventdata, H)
cla(H.axes_current_concordia,'reset');
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
name_idx = get(H.listbox1,'Value');
set(H.age_int_05, 'Value', 0);
set(H.age_int_1, 'Value', 0);
set(H.age_int_2, 'Value', 0);
set(H.age_int_5, 'Value', 0);
set(H.age_int_10, 'Value', 1);
set(H.age_int_25, 'Value', 0);
set(H.age_int_50, 'Value', 0);
set(H.age_int_100, 'Value', 0);
timeinterval = 10000000;
axes(H.axes_current_concordia);
set(H.axes_current_concordia,'FontSize',8);
p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
hold on
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});
legend([p3], bestage,  'Location', 'northwest');
set(H.axes_current_concordia,'FontSize',8);
concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

function age_int_5_Callback(hObject, eventdata, H)
cla(H.axes_current_concordia,'reset');
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
name_idx = get(H.listbox1,'Value');
set(H.age_int_05, 'Value', 0);
set(H.age_int_1, 'Value', 0);
set(H.age_int_2, 'Value', 0);
set(H.age_int_5, 'Value', 1);
set(H.age_int_10, 'Value', 0);
set(H.age_int_25, 'Value', 0);
set(H.age_int_50, 'Value', 0);
set(H.age_int_100, 'Value', 0);
timeinterval = 5000000;
axes(H.axes_current_concordia);
set(H.axes_current_concordia,'FontSize',8);
p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
hold on
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});
legend([p3], bestage,  'Location', 'northwest');
set(H.axes_current_concordia,'FontSize',8);
concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

function age_int_2_Callback(hObject, eventdata, H)
cla(H.axes_current_concordia,'reset');
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
name_idx = get(H.listbox1,'Value');
set(H.age_int_05, 'Value', 0);
set(H.age_int_1, 'Value', 0);
set(H.age_int_2, 'Value', 1);
set(H.age_int_5, 'Value', 0);
set(H.age_int_10, 'Value', 0);
set(H.age_int_25, 'Value', 0);
set(H.age_int_50, 'Value', 0);
set(H.age_int_100, 'Value', 0);
timeinterval = 2000000;
axes(H.axes_current_concordia);
set(H.axes_current_concordia,'FontSize',8);
p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
hold on
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});
legend([p3], bestage,  'Location', 'northwest');
set(H.axes_current_concordia,'FontSize',8);
concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

function age_int_1_Callback(hObject, eventdata, H)
cla(H.axes_current_concordia,'reset');
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
name_idx = get(H.listbox1,'Value');
set(H.age_int_05, 'Value', 0);
set(H.age_int_1, 'Value', 1);
set(H.age_int_2, 'Value', 0);
set(H.age_int_5, 'Value', 0);
set(H.age_int_10, 'Value', 0);
set(H.age_int_25, 'Value', 0);
set(H.age_int_50, 'Value', 0);
set(H.age_int_100, 'Value', 0);
timeinterval = 1000000;
axes(H.axes_current_concordia);
set(H.axes_current_concordia,'FontSize',8);
p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
hold on
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});
legend([p3], bestage,  'Location', 'northwest');
set(H.axes_current_concordia,'FontSize',8);
concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

function age_int_05_Callback(hObject, eventdata, H)
cla(H.axes_current_concordia,'reset');
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
name_idx = get(H.listbox1,'Value');
set(H.age_int_05, 'Value', 1);
set(H.age_int_1, 'Value', 0);
set(H.age_int_2, 'Value', 0);
set(H.age_int_5, 'Value', 0);
set(H.age_int_10, 'Value', 0);
set(H.age_int_25, 'Value', 0);
set(H.age_int_50, 'Value', 0);
set(H.age_int_100, 'Value', 0);
timeinterval = 500000;
axes(H.axes_current_concordia);
set(H.axes_current_concordia,'FontSize',8);
p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
hold on
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});
legend([p3], bestage,  'Location', 'northwest');
set(H.axes_current_concordia,'FontSize',8);
concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

%% REPLOT DISTRIBUTION %%
function replot_Callback(hObject, eventdata, H)
current_status_num = H.current_status_num;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
data_count = H.data_count;
sample_idx = H.sample_idx;

axes(H.axes_distribution);
cla(H.axes_distribution, 'reset');

for i = 1:data_count
if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
end
end

dist_data = dist_data(any(dist_data ~= 0,2),:);

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
hist_ymin = str2num(get(H.h_ymin,'String'));
hist_ymax = str2num(get(H.h_ymax,'String'));
bins = str2num(get(H.bins,'String'));
x=xmin:xint:xmax;

	rad_on_dist=get(H.uipanel_distribution,'selectedobject');
	switch rad_on_dist

    case H.radio_hist

	[counts binCenters] = hist(dist_data(:,1), bins);
	bar(binCenters, counts);
	axis([xmin xmax hist_ymin hist_ymax])

    case H.radio_pdp

	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
	lgnd=legend(p, 'Probability Density Plot');
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	set(lgnd,'color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k')
	ylabel('Number','Color','k')

    case H.radio_kde
		rad_on_kernel=get(H.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case H.optimize

		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl1 = plot(x,kdeA,'Color',[1 0 0]);
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(H.optimize_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff

		case H.Myr_kernel
		x=xmin:xint:xmax;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl1 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		end
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k')
		ylabel('Probability','Color','k')

    case H.radio_hist_pdp

	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	[counts binCenters] = hist(dist_data(:,1), bins);
	bar(binCenters, counts);
	hold on;
	p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
	axis([xmin xmax hist_ymin hist_ymax])
	lgnd=legend(p, 'Probability Density Plot');
	set(lgnd,'color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k')
	ylabel('Number','Color','k')

    case H.radio_hist_kde
		rad_on_kernel=get(H.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case H.optimize

		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		kdemax = max(kdeA);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.optimize_text, 'String', bandwidth);

		case H.Myr_kernel
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
		end
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k')
		ylabel('Number','Color','k')

    case H.radio_hist_pdp_kde
		rad_on_kernel=get(H.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case H.optimize
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		kdemax = max(kdeA);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1],'Probability Density Plot','Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.optimize_text, 'String', bandwidth);

		case H.Myr_kernel
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		hold on
		pdpmax = max(kde1);
		set(p1,'linewidth',2)
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1], 'Probability Density Plot','Kernel Density Estimate');
		end
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k')
		ylabel('Number','Color','k')
 
   case H.radio_pdp_kde
		rad_on_kernel=get(H.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case H.optimize
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		set(H.optimize_text, 'String', bandwidth);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(pdp))),'Color',[1 0 0]);
		hold on
		p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
		set(p1,'linewidth',2)
		lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])

		case H.Myr_kernel
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint); 
   		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p1 = plot(x,kde1*(1/(max(kde1)/max(pdp))),'Color',[1 0 0]);
		hold on
		p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
		set(p1,'linewidth',2)
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
		set(p1,'linewidth',2)
		end
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k')
		ylabel('Probability','Color','k')

	end

nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);

%% EXPORT PDP %%
function export_pdp_Callback(hObject, eventdata, H)
current_status_num = H.current_status_num;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
data_count = H.data_count;
sample_idx = H.sample_idx;

for i = 1:data_count
if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
end
end

dist_data = dist_data(any(dist_data ~= 0,2),:);

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
x=xmin:xint:xmax;
pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
dat = num2cell([x', pdp']);

[file,path] = uiputfile('*.xls','Save file');
writetable(table(dat),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);
%xlswrite([path file], dat);

%% EXPORT KDE %%
function export_kde_Callback(hObject, eventdata, H)
current_status_num = H.current_status_num;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
data_count = H.data_count;
sample_idx = H.sample_idx;

for i = 1:data_count
if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
end
end

dist_data = dist_data(any(dist_data ~= 0,2),:);

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
x=xmin:xint:xmax;

		rad_on_kernel=get(H.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case H.optimize
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
	
		case H.Myr_kernel
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kdeA=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		
		end

dat = num2cell([x', kdeA']);

[file,path] = uiputfile('*.xls','Save file');
writetable(table(dat),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);
%xlswrite([path file], dat);

%% CLEAR ALL %%
function clear_all_Callback(hObject, eventdata, H)
cla(H.axes_distribution,'reset'); 
set(H.Myr_Kernel_text,'String','');
set(H.status,'String','');
cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')
cla(H.axes_session_fractionation,'reset');
cla(H.axes_session,'reset');
%cla(H.axes_secondary,'reset');
cla(H.axes_current_intensities,'reset');
cla(H.axes_current_concordia,'reset');
cla(H.axes_distribution,'reset'); 
set(H.standards_rejected,'String','');
%set(H.primary_reference,'String','');
%set(H.secondary_reference,'String','');
set(H.listbox1,'String','');
set(H.listbox1,'String','');
%set(H.optimize_text,'String','');
set(H.n_plotted,'String','?');

cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')
%set(H.h_ymax,'String','?');

%set(H.age_int_05, 'Value', 0);
%set(H.age_int_1, 'Value', 0);
%set(H.age_int_2, 'Value', 0);
%set(H.age_int_5, 'Value', 0);
%set(H.age_int_10, 'Value', 0);
%set(H.age_int_25, 'Value', 0);
%set(H.age_int_50, 'Value', 0);
%set(H.age_int_100, 'Value', 0);

guidata(hObject,H);

%% EXPORT REDUCED DATA %%
function export_data_Callback(hObject, eventdata, H)
Macro_1_2_Output = H.Macro_1_2_Output;

[file,path] = uiputfile('*.xls','Save file');
writetable(table(Macro_1_2_Output),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);
%xlswrite([path file], Macro_1_2_Output);




%% AGECALC COMPARE %%
function AgeCalc_comp_Callback(hObject, eventdata, H)
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

numbers_ML(1,:) = [];
numbers_ML(:,1:2) = [];

[filename pathname] = uigetfile({'*'},'Select Original AgeCalc File');
fullpathname = strcat(pathname, filename);

%if ispc == 1
%	file_copy = strcat(fullpathname, '_copy.csv');
%end
%if ismac == 1
%	file_copy = strcat(fullpathname, '_copy');
%end

%copyfile(fullpathname, file_copy, 'f');

if ispc == 1
	%d1 = [file_copy];[numbers text, data] = csvread(d1);
	Data_tmp = importdata(char(fullpathname),',',500000);
	numbers = num2cell(Data_tmp.data);
	text = Data_tmp.textdata;
end
if ismac == 1
	%d1 = [file_copy];[numbers text, data] = xlsread(d1);
	Data_tmp = importdata(char(fullpathname),',',500000);
	numbers = num2cell(Data_tmp.data);
	text = Data_tmp.textdata;
end
%delete(d1);

numbers(1:2,:) = [];
numbers(:,73:end) = [];

for i = 1:length(numbers(:,1))
	for j = 1:length(numbers(1,:))
		if isnan(numbers(i,j)) == 0 && isnan(numbers_ML(i,j)) == 0
			Difference(i,j) = numbers(i,j) - numbers_ML(i,j);
		else
			Difference(i,j) = 0;
		end
	end
end

for i = 1:length(numbers(:,1))
	for j = 1:length(numbers(1,:))
		if Difference(i,j) < 0.0000000001
			Difference(i,j) = 0;
		end
	end
end

idx = ( Difference > 0 );

XX = reshape(strtrim(cellstr(num2str(Difference(:), '%.7f'))), size(Difference));

for i = 1:length(numbers(:,1))
	for j = 1:length(numbers(1,:))
		if idx(i,j) == 1
			%XX(i,j) = strcat('<html><span style="color: #FF0000; font-weight: bold;">',XX(i,j),'</span></html>');
			XX(i,j) = strcat('<html><BODY bgcolor="red">',XX(i,j),'</span></html>');
		end
	end
end

f = figure('Position', [100 100 1000 600], 'NumberTitle', 'off');
t = uitable('Parent', f, 'Position', [50 50 900 500], 'Data', Difference);

head{1,72} = [];
for i = 1:72
	head(1,i) = Macro_1_2_Output(1,i+2);
end
t.ColumnName = head;


rownames{length(numbers(:,1)),1} = [];
for i = 1:length(numbers(:,1))
	rownames(i,1) = Macro_1_2_Output(i+1,1);
end
t.RowName = rownames;

set(t, 'Data',XX)








%% EXPORT GEOCHRON.ORG FORMAT %%
function export_standards_Callback(hObject, eventdata, H)
Macro_1_2_Output = H.Macro_1_2_Output(2:end,:);
%Macro_1_2_Output222222 = H.Macro_1_2_Output;


current_status_num = H.current_status_num;
STD1_idx = H.STD1_idx;
sample_idx = H.sample_idx;
ffsw68 = H.ffsw68; 
ffse68 = H.ffse68;
stdfcsw67 = H.stdfcsw67;
stdswse67 = H.stdswse67;
BLS_68_err = H.BLS_68_err;
BLS_67_sort_err = H.BLS_67_sort_err;
pbcerr68 = H.pbcerr68;
pbcerr67 = H.pbcerr67;
Age68 = H.Age68;









prompt = {'Aliquot Name:', 'Stratigraphic Formation Name:', 'Stratigraphic Age:', 'Rock Type', 'Latitude (decimal degrees):',  'Longitude (decimal degrees):', 'Analysis Purpose:', ...
	'Analyst Name:', 'Aliquot Reference:'};
title = 'Input Metadata';
dims = [1 35];
definput = {'20','hsv'};
answer = inputdlg(prompt, title);

% Calculate systematic Uncertainties

for i = 1:length(STD1_idx)
	if STD1_idx(i,1) ~= 1 && BLS_68_err(i,1) < 20 
		syst_err_68(i,1) = sqrt(100*ffse68(i,1)/ffsw68(i,1)*100*ffse68(i,1)/ffsw68(i,1)+pbcerr68(i,1)*pbcerr68(i,1)+0.053*0.053+0.35*0.35);
	else
		syst_err_68(i,1) = 0;
	end
end

if length(syst_err_68) >= 126
	systerr68 = 2*mean(nonzeros(syst_err_68(1:126,1)));
else
	systerr68 = 2*mean(nonzeros(syst_err_68));
end

for i = 1:length(STD1_idx)
	if STD1_idx(i,1) ~= 1 && BLS_67_sort_err(i,1) < 20 && cell2num(Age68(i,1)) > 400
		syst_err_67(i,1) = sqrt(100*stdswse67(i,1)/stdfcsw67(i,1)*100*stdswse67(i,1)/stdfcsw67(i,1)+(pbcerr67(i,1))*(pbcerr67(i,1))+0.053*0.053+0.069*0.069+0.35*0.35);
	end
end

if length(syst_err_67) >= 126
	systerr67 = 2*mean(nonzeros(syst_err_67(1:126,1)));
else
	systerr67 = 2*mean(nonzeros(syst_err_67));
end

for i = 1:length(current_status_num)
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		export_num(i,1) = 1;
	end
end

geochron_out{sum(export_num)+26, 20} = [];
geochron_out(1:17,1) = [{'Aliquot Name'; 'Stratigraphic Formation Name';'Stratigraphic Age';'Rock Type';'Mineral';'Method';'Latitude';'Longitude';'Internal Uncertainty Level'; ...
	'External Uncertainty 206/238 (% two sigma)';'External Uncertainty 206/207 (% two sigma)';'Analysis Purpose';'Laboratory Name';'Analyst Name'; ...
	'Aliquot Reference';'Aliquot Instrumental Method';'Aliquot Instrumental Reference'}];
geochron_out(1:4,2) = answer(1:4,1);
geochron_out(5,2) = [{'Zircon'}];
geochron_out(6,2) = [{'U-Pb'}];
geochron_out(7:8,2) = answer(5:6,1);
geochron_out(12,2) = answer(7,1);
geochron_out(14:15,2) = answer(8:9,1);
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

geochron_out_temp{sum(current_status_num), 74} = [];
for i = 1:length(current_status_num)
if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
geochron_out_temp(i,:) = Macro_1_2_Output(i,:);
end
end

geochron_out_temp(all(cellfun('isempty',geochron_out_temp),2),:) = [];

geochron_out(27:end,1) = geochron_out_temp(:,1);
geochron_out(27:end,2) = geochron_out_temp(:,51);
geochron_out(27:end,3) = geochron_out_temp(:,53);
geochron_out(27:end,4) = geochron_out_temp(:,55);
geochron_out(27:end,5:6) = geochron_out_temp(:,13:14);
geochron_out(27:end,7:11) = geochron_out_temp(:,28:32);
geochron_out(27:end,12:17) = geochron_out_temp(:,65:70);
geochron_out(27:end,18:19) = geochron_out_temp(:,73:74);

for i = 1:length(geochron_out_temp(:,1))
geochron_out(26+i,20) = {(cell2num(geochron_out_temp(i,21))/cell2num(geochron_out_temp(i,23)))*100};
end

[file,path] = uiputfile('*.xls','Save file');
writetable(table(geochron_out),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);

%% EXPORT SAMPLE CONCORDIA %%
function export_sample_concordias_Callback(hObject, eventdata, H)
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
numpoints = H.numpoints;
sigmarule = H.sigmarule;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;

figure;

plot(xc,yc,'k','LineWidth',1.4)
hold on
concordia_data = SAMPLE_CONCORDIA(2:end,1:5);
concordia_data(all(cellfun('isempty',concordia_data),2),:) = [];
concordia_data = cell2num(concordia_data);
rho = concordia_data(:,5);
center = [concordia_data(:,1),concordia_data(:,3)];
sigx_abs = concordia_data(:,1).*concordia_data(:,2).*0.01;
sigy_abs = concordia_data(:,3).*concordia_data(:,4).*0.01;
sigx_sq = sigx_abs.*sigx_abs;
sigy_sq = sigy_abs.*sigy_abs;
rho_sigx_sigy = sigx_abs.*sigy_abs.*rho;

for i = 1:length(sigx_sq);
covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
[PD,PV]=eig(covmat);
PV = diag(PV).^.5;
theta = linspace(0,2.*pi,numpoints)';
elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
numsigma = length(sigmarule);
elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt_out(:,:,i) = elpt + repmat(center(i,1:2),numpoints,numsigma);
p1 = plot(elpt_out(:,1:2:end,i),elpt_out(:,2:2:end,i),'b','LineWidth',1.2);
hold on
end

xaxismin = min(concordia_data(:,1)) - 0.015.*min(concordia_data(:,1));
xaxismax = max(concordia_data(:,1)) + 0.015.*max(concordia_data(:,1));
yaxismin = min(concordia_data(:,3)) - 0.015.*min(concordia_data(:,3));
yaxismax = max(concordia_data(:,3)) + 0.015.*max(concordia_data(:,3));

xaxismin_Myr = log(xaxismin+1)/0.00000000098485/1000000;
xaxismax_Myr = log(xaxismax+1)/0.00000000098485/1000000;
yaxismin_Myr = log(yaxismin+1)/0.000000000155125/1000000;
yaxismax_Myr = log(yaxismax+1)/0.000000000155125/1000000;

diff_avg = ((xaxismax_Myr - xaxismin_Myr) + (yaxismax_Myr - yaxismin_Myr))/2;

if diff_avg < 0.5
timeinterval = 100000;
elseif diff_avg > 0.5 && diff_avg < 2
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

%% EXPORT STANDARD CONCORDIAS %%
function export_standard_concordias_Callback(hObject, eventdata, H)
f1 = figure;
copyobj(H.axes_session,f1);
%copyobj(H.axes_secondary,f1);

%% EXPORT DISTRIBUTION PLOT  %%
function export_plot_Callback(hObject, eventdata, H)
current_status_num = H.current_status_num;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;
data_count = H.data_count;
sample_idx = H.sample_idx;

figure;

for i = 1:data_count
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
		dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
	end
end

if sum(current_status_num) > 0

dist_data = dist_data(any(dist_data ~= 0,2),:);

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
hist_ymin = 0;
bins = str2num(get(H.bins,'String'));
[counts binCenters] = hist(dist_data(:,1), bins);
hist_ymax = max(counts) + 1;
bins = str2num(get(H.bins,'String'));
x=xmin:xint:xmax;

if get(H.radio_hist, 'Value') == 1
	[counts binCenters] = hist(dist_data(:,1), bins);
	bar(binCenters, counts);
	axis([xmin xmax hist_ymin hist_ymax])
	xlabel('Age (Ma)','Color','k', 'FontSize', 10)
	ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_pdp, 'Value') == 1
	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
	lgnd=legend(p, 'Probability Density Plot');
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	set(lgnd,'color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k')
	ylabel('Probability','Color','k')
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
		set(H.Myr_Kernel_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
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
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
	end
		set(lgnd,'Color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_pdp, 'Value') == 1
	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	[counts binCenters] = hist(dist_data(:,1), bins);
	bar(binCenters, counts);
	hold on;
	p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
	axis([xmin xmax hist_ymin hist_ymax])
	lgnd=legend(p, 'Probability Density Plot');
	set(lgnd,'color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k', 'FontSize', 10)
	ylabel('Probability','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		kdemax = max(kdeA);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.Myr_Kernel_text, 'String', bandwidth);
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
	end
	if get(H.Myr_kernel,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
	end
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_pdp_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		kdemax = max(kdeA);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1],'Probability Density Plot','Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.Myr_Kernel_text, 'String', bandwidth);
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
	end
	if get(H.Myr_kernel,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		hold on
		pdpmax = max(kde1);
		set(p1,'linewidth',2)
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1], 'Probability Density Plot','Kernel Density Estimate');
	end
		set(lgnd,'Color','w');
		legend boxoff
 		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_pdp_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		set(H.Myr_Kernel_text, 'String', bandwidth);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(pdp))),'Color',[1 0 0]);
		hold on
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
		hold on
		p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
		set(p1,'linewidth',2)
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
		set(p1,'linewidth',2)
	end
		set(lgnd,'Color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
end
hold off
nsamp = num2str(length(dist_data));
set(H.n_plotted,'String',nsamp);
end










%% EXPORT ALL PLOTS %%
function summary_Callback(hObject, eventdata, H)



%{
prompt = {'Aliquot Name:', 'Stratigraphic Formation Name:', 'Stratigrapic Age:', 'Latitude (decimal degrees):',  'Longitude (decimal degrees):', 'Analysis Purpose:', ...
	'Analyst Name:', 'Aliquot Reference:'};
title = 'Input Metadata';
dims = [1 35];
definput = {'20','hsv'};
answer = inputdlg(prompt, title);
%}

%{

h.f = figure('units','pixels','position',[200,100,250,130],...
             'toolbar','none','menu','none','Name','Plot Selection!');
% Create yes/no checkboxes
h.c(1) = uicontrol('style','checkbox','units','pixels',...
                'position',[10,110,200,20],'string','Primary Standard Concordias?', 'Value', 1);
h.c(2) = uicontrol('style','checkbox','units','pixels',...
                'position',[10,90,200,20],'string','Secondary Standard Concordias?', 'Value', 0);    
h.c(3) = uicontrol('style','checkbox','units','pixels',...
                'position',[10,70,200,20],'string','Unknown Concordias (Accepted Only)?', 'Value', 0);    
h.c(4) = uicontrol('style','checkbox','units','pixels',...
                'position',[10,50,200,20],'string','Unknown Concordias (Rejected Only)?', 'Value', 0);   
h.c(5) = uicontrol('style','checkbox','units','pixels',...
                'position',[10,30,200,20],'string','Weighted Mean??', 'Value', 0);   

% Create OK pushbutton   
%h.p = uicontrol('style','pushbutton','units','pixels',...
%                'position',[50,5,150,20],'string','<html><b>OK, Build my DR!',...
%                'callback',@p_call);

h.p = uicontrol('style','pushbutton','units','pixels',...
                'position',[50,5,150,20],'string','<html><b>OK, Build my DR!');			
    
% Pushbutton callback
    %function p_call(varargin)

%mydlg = warndlg('This is a warning.', 'A Warning Dialog');

%disp('This prints after you close the warning dialog.');	
	
%close(h)
	
	
	
        vals = get(h.c,'Value');
        checked = find([vals{:}]);
        if isempty(checked)
            checked = 'none';
        end
        disp(checked)
	%end

%uiwait(msgbox(h));


ax(5,1) = h.c.Value	

waitfor(h.p);
close(h)

x=0
x=0
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONCORDIA PRIMARY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sigx_sq_STD1 = H.sigx_sq_STD1;
rho_sigx_sigy_STD1 = H.rho_sigx_sigy_STD1;
sigy_sq_STD1 = H.sigy_sq_STD1;
sigmarule = H.sigmarule;
numpoints = H.numpoints;
center_STD1 = H.center_STD1;
STD1_68 = H.STD1_68;
STD1_67 = H.STD1_67;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;

fignew = figure('Visible','off'); % Invisible figure

for i = 1:length(sigx_sq_STD1)
covmat_STD1=[sigx_sq_STD1(i,1),rho_sigx_sigy_STD1(i,1);rho_sigx_sigy_STD1(i,1),sigy_sq_STD1(i,1)];
[PD_STD1,PV_STD1]=eig(covmat_STD1);
PV_STD1 = diag(PV_STD1).^.5;
theta_STD1 = linspace(0,2.*pi,numpoints)';
elpt_STD1 = [cos(theta_STD1),sin(theta_STD1)]*diag(PV_STD1)*PD_STD1';
numsigma = length(sigmarule);
elpt_STD1 = repmat(elpt_STD1,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt_STD1_out(:,:,i) = elpt_STD1 + repmat(center_STD1(i,1:2),numpoints,numsigma);
p1 = plot(elpt_STD1_out(:,1:2:end,i),elpt_STD1_out(:,2:2:end,i),'b','LineWidth',1.2);
hold on
end

%age_label2_x = 0.742701185586296;
age_label2_x = STD1_68*(1/STD1_67)*137.88;
%age_label2_y = 0.0912660713153783;
age_label2_y = STD1_68;

if get(H.primary, 'Value') == 1
	age_label2 = {'564 Ma'};
end

plot(xc,yc,'k','LineWidth',1.4)
hold on
p1 = scatter(age_label2_x, age_label2_y,50,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
labelpoints (age_label2_x, age_label2_y, age_label2, 'SE', .002);

axis([min(min(elpt_STD1_out(:,1,:))) - min(min(elpt_STD1_out(:,1,:)))*.01 max(max(elpt_STD1_out(:,1,:))) + max(max(elpt_STD1_out(:,1,:)))*.01 ...
	min(min(elpt_STD1_out(:,2,:))) - min(min(elpt_STD1_out(:,2,:)))*.01 max(max(elpt_STD1_out(:,2,:))) + max(max(elpt_STD1_out(:,2,:)))*.01]);

if get(H.leg_on_session,'Value') == 1
	legend(p1,'Accepted Age','Location','northwest');
else
	legend('hide')
end

xlabel('207Pb/235U');
ylabel('206Pb/238U');
title('Primary Standards')

[file,path] = uiputfile('*','Save file');

export_fig([path file], fignew, '-pdf');
delete(fignew);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONCORDIA SECONDARY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sigx_sq_STD2 = H.sigx_sq_STD2;
rho_sigx_sigy_STD2 = H.rho_sigx_sigy_STD2;
rho_sigx_sigy_STD2 = H.rho_sigx_sigy_STD2;
sigy_sq_STD2 = H.sigy_sq_STD2;
sigmarule = H.sigmarule;
numpoints = H.numpoints;
center_STD2 = H.center_STD2;
STD2_68 = H.STD2_68;
STD2_67 = H.STD2_67;
STD2_idx = H.STD2_idx;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;

if sum(STD2_idx) > 1
fignew = figure('Visible','off'); % Invisible figure
%set(H.secondary_reference,'String',STD2);

for i = 1:length(sigx_sq_STD2)
covmat_STD2=[sigx_sq_STD2(i,1),rho_sigx_sigy_STD2(i,1);rho_sigx_sigy_STD2(i,1),sigy_sq_STD2(i,1)];
[PD_STD2,PV_STD2]=eig(covmat_STD2);
PV_STD2 = diag(PV_STD2).^.5;
theta_STD2 = linspace(0,2.*pi,numpoints)';
elpt_STD2 = [cos(theta_STD2),sin(theta_STD2)]*diag(PV_STD2)*PD_STD2';
numsigma = length(sigmarule);
elpt_STD2 = repmat(elpt_STD2,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt_STD2_out(:,:,i) = elpt_STD2 + repmat(center_STD2(i,1:2),numpoints,numsigma);
plot(elpt_STD2_out(:,1:2:end,i),elpt_STD2_out(:,2:2:end,i),'b','LineWidth',1.2);
hold on
end

age_label3_x = 0.511;
age_label3_y = 0.0671;
age_label3 = {'419 Ma'};

plot(xc,yc,'k','LineWidth',1.4)
hold on
p2 = scatter(age_label3_x, age_label3_y,40,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
labelpoints (age_label3_x, age_label3_y, age_label3, 'SE', .002);

axis([min(min(elpt_STD2_out(:,1,:))) - min(min(elpt_STD2_out(:,1,:)))*.01 max(max(elpt_STD2_out(:,1,:))) + max(max(elpt_STD2_out(:,1,:)))*.01 ...
	min(min(elpt_STD2_out(:,2,:))) - min(min(elpt_STD2_out(:,2,:)))*.01 max(max(elpt_STD2_out(:,2,:))) + max(max(elpt_STD2_out(:,2,:)))*.01]);
end

if get(H.leg_on_session,'Value') == 1
	legend([p2],'Accepted age','Location','northwest');
else
	legend('hide')
end

xlabel('207Pb/235U');
ylabel('206Pb/238U');
title('Secondary Standards')

export_fig([path file], fignew, '-pdf', '-append');
delete(fignew);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONCORDIA UNKNOWN ACCEPTED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sample = H.sample;
Data_All = H.Data_All;
Ablate = H.Ablate;
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
current_status = H.current_status;
current_status_num = H.current_status_num;
current_status_num_orig = H.current_status_num_orig;
comment = H.comment;
INT = H.INT;

name_idx = get(H.listbox1, 'Value');

fignew = figure('Visible','off'); % Invisible figure
hold on

sigx_sq_All = H.sigx_sq_All;
rho_sigx_sigy_All = H.rho_sigx_sigy_All;
sigy_sq_All = H.sigy_sq_All;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
center_All = H.center_All;
sample_idx = H.sample_idx;
current_status_num = H.current_status_num;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = plot(elpt_out_acc(:,1:2:end,i),elpt_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = [];
	end
end

plot(x,y,'k','LineWidth',1.4)

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

for i = 1:length(time4)
if x4(i,1) > min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 && x4(i,1) < max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	&& y4(i,1) > min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 && y4(i,1) < max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

axis([min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01]);

%p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

accan= {'Accepted Analyses'};

if get(H.leg_on_session,'Value') == 1	
	legend(p1, accan, 'Location','northwest');
else
	legend('hide')
end

xlabel('207Pb/235U');
ylabel('206Pb/238U');
title('Accepted Analyses')

export_fig([path file], fignew, '-pdf', '-append');
delete(fignew);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONCORDIA UNKNOWN REJECTED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sample = H.sample;
Data_All = H.Data_All;
Ablate = H.Ablate;
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
current_status = H.current_status;
current_status_num = H.current_status_num;
current_status_num_orig = H.current_status_num_orig;
comment = H.comment;
INT = H.INT;

name_idx = get(H.listbox1, 'Value');

fignew = figure('Visible','off'); % Invisible figure
hold on

sigx_sq_All = H.sigx_sq_All;
rho_sigx_sigy_All = H.rho_sigx_sigy_All;
sigy_sq_All = H.sigy_sq_All;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
center_All = H.center_All;
sample_idx = H.sample_idx;
current_status_num = H.current_status_num;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = [];
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = plot(elpt_out_rej(:,1:2:end,i),elpt_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
	end
end

plot(x,y,'k','LineWidth',1.4)

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

for i = 1:length(time4)
if x4(i,1) > min(min(nonzeros(elpt_out_rej(:,1,:)))) - min(min(nonzeros(elpt_out_rej(:,1,:))))*.01 && x4(i,1) < max(max(nonzeros(elpt_out_rej(:,1,:)))) + max(max(nonzeros(elpt_out_rej(:,1,:))))*.01 ...
	&& y4(i,1) > min(min(nonzeros(elpt_out_rej(:,2,:)))) - min(min(nonzeros(elpt_out_rej(:,2,:))))*.01 && y4(i,1) < max(max(nonzeros(elpt_out_rej(:,2,:)))) + max(max(nonzeros(elpt_out_rej(:,2,:))))*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

axis([min(min(nonzeros(elpt_out_rej(:,1,:)))) - min(min(nonzeros(elpt_out_rej(:,1,:))))*.01 max(max(nonzeros(elpt_out_rej(:,1,:)))) + max(max(nonzeros(elpt_out_rej(:,1,:))))*.01 ...
	min(min(nonzeros(elpt_out_rej(:,2,:)))) - min(min(nonzeros(elpt_out_rej(:,2,:))))*.01 max(max(nonzeros(elpt_out_rej(:,2,:)))) + max(max(nonzeros(elpt_out_rej(:,2,:))))*.01]);

%p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

rejan = {'Rejected Analyses'};

%legend([p1 p2], [accan, rejan], 'Location','northwest');

if get(H.leg_on_session,'Value') == 1	
	legend(p2, rejan, 'Location','northwest');
else
	legend('hide')
end

xlabel('207Pb/235U');
ylabel('206Pb/238U');
title('Rejected Analyses')

export_fig([path file], fignew, '-pdf', '-append');
delete(fignew);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISTRIBUTION PLOT ACCEPTED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_count = H.data_count;
SAMPLE_CONCORDIA = H.SAMPLE_CONCORDIA;

for i = 1:data_count
	if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
		dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
		dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
	end
end

if sum(current_status_num) > 0

dist_data = dist_data(any(dist_data ~= 0,2),:);

fignew = figure('Visible','off'); % Invisible figure
hold on

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
hist_ymin = 0;
bins = str2num(get(H.bins,'String'));
[counts binCenters] = hist(dist_data(:,1), bins);
hist_ymax = max(counts) + 1;
bins = str2num(get(H.bins,'String'));
x=xmin:xint:xmax;

if get(H.radio_hist, 'Value') == 1
	[counts binCenters] = hist(dist_data(:,1), bins);
	bar(binCenters, counts);
	axis([xmin xmax hist_ymin hist_ymax])
	xlabel('Age (Ma)','Color','k', 'FontSize', 10)
	ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_pdp, 'Value') == 1
	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
	lgnd=legend(p, 'Probability Density Plot');
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	set(lgnd,'color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k')
	ylabel('Probability','Color','k')
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
		set(H.Myr_Kernel_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
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
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
	end
		set(lgnd,'Color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_pdp, 'Value') == 1
	pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
	[counts binCenters] = hist(dist_data(:,1), bins);
	bar(binCenters, counts);
	hold on;
	p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
	axis([xmin xmax hist_ymin hist_ymax])
	lgnd=legend(p, 'Probability Density Plot');
	set(lgnd,'color','w');
	legend boxoff
	xlabel('Age (Ma)','Color','k', 'FontSize', 10)
	ylabel('Probability','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		kdemax = max(kdeA);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.Myr_Kernel_text, 'String', bandwidth);
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
	end
	if get(H.Myr_kernel,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend(p1,'Kernel Density Estimate');
		set(p1,'linewidth',2)
	end
		set(lgnd,'color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_hist_pdp_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(counts-1))),'Color',[1 0 0]);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		kdemax = max(kdeA);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1],'Probability Density Plot','Kernel Density Estimate');
		set(p1,'linewidth',2)
		set(H.Myr_Kernel_text, 'String', bandwidth);
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
	end
	if get(H.Myr_kernel,'Value') == 1
		[counts binCenters] = hist(dist_data(:,1), bins);
		bar(binCenters, counts);
		hold on;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		p1 = plot(x,kde1*(1/(max(kde1)/max(counts-1))),'Color',[1 0 0]);
		hold on
		pdpmax = max(kde1);
		set(p1,'linewidth',2)
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		p = plot(x, pdp*(1/(max(pdp)/max(counts-1))), 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
		axis([xmin xmax hist_ymin hist_ymax])
		lgnd=legend([p,p1], 'Probability Density Plot','Kernel Density Estimate');
	end
		set(lgnd,'Color','w');
		legend boxoff
 		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Number','Color','k', 'FontSize', 10)
end

if get(H.radio_pdp_kde, 'Value') == 1
	if get(H.optimize,'Value') == 1
		xA = transpose(x);
		n = length(dist_data(:,1));
		[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		set(H.Myr_Kernel_text, 'String', bandwidth);
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		pdpmax = max(pdp);
		p1 = plot(x,kdeA*(1/(max(kdeA)/max(pdp))),'Color',[1 0 0]);
		hold on
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
		hold on
		p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
		set(p1,'linewidth',2)
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
		set(p1,'linewidth',2)
	end
		set(lgnd,'Color','w');
		legend boxoff
		xlabel('Age (Ma)','Color','k', 'FontSize', 10)
		ylabel('Probability','Color','k', 'FontSize', 10)
end

hold off

end

export_fig([path file], fignew, '-pdf', '-append');
delete(fignew);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%% EXPORT DISTRIBUTION PLOTS %%
function export_distribution_plot_Callback(hObject, eventdata, H)







data1 = H.data1;
data2 = H.data2;
data3 = vertcat(data1,data2);
numsamples1 = length(data1);
numsamples2 = length(data2);
numsamples3 = length(data3);

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
hist_ymin = str2num(get(H.ymin,'String'));
hist_ymax = str2num(get(H.ymax,'String'));
bins = str2num(get(H.bins,'String'));

	rad_on_dist=get(H.uipanel_distribution,'selectedobject');
	switch rad_on_dist
    case H.radio_hist

	f1 = figure;
	hist(data1(:,1), bins);
	set(gca,'box','off')
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 8)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8)
	title('Filtered data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples1};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

	f2 = figure;
	hist(data2(:,1), bins);
	set(gca,'box','off')
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 8)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8)
	title('Rejected data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples2};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

	f3 = figure;
	hist(data3(:,1), bins);
	set(gca,'box','off')
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 8)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8)
	title('All data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples3};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

    case H.radio_pdp

	f1 = figure;
    x=xmin:xint:xmax;
	pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);    
	hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	lgnd=legend('Probability Density Plot');
	set(hl1,'linewidth',2)
	set(gca,'box','off')
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 8)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8)
	set(lgnd,'color','w');
	legend boxoff
	title('Filtered data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples1};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

	f2 = figure;
    x=xmin:xint:xmax;
	pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);    
	hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	lgnd=legend('Probability Density Plot');
	set(hl1,'linewidth',2)
	set(gca,'box','off')
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 8)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8)
	set(lgnd,'color','w');
	legend boxoff
	title('Rejected data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples2};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

	f3 = figure;
    x=xmin:xint:xmax;
	pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);    
	hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	lgnd=legend('Probability Density Plot');
	set(hl1,'linewidth',2)
	set(gca,'box','off')
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 8)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8)
	set(lgnd,'color','w');
	legend boxoff
	title('All data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples3};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

    case H.radio_kde     
	
		f1 = figure; 
		rad_on_kernel=get(H.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case H.optimize
		x=xmin:xint:xmax;
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data1(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl1 = plot(tin,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 8)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8) 
		set(H.optimize_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff
		title('Filtered data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples1};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

		case H.Myr_kernel

		x=xmin:xint:xmax;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(data1(:,1)),1) = kernel;
		kde1=pdp5_2sig(data1(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl1 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 8)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8)		
		end
		set(lgnd,'color','w');
		legend boxoff
		title('Filtered data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples1};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

		f2 = figure; 
		rad_on_kernel=get(H.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case H.optimize
		x=xmin:xint:xmax;
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data2(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl1 = plot(tin,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 8)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8) 
		set(H.optimize_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff
		title('Rejected data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples2};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

		case H.Myr_kernel

		x=xmin:xint:xmax;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(data2(:,1)),1) = kernel;
		kde1=pdp5_2sig(data2(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl1 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 8)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8)		
		end
		set(lgnd,'color','w');
		legend boxoff
		title('Rejected data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples2};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

		f3 = figure; 
		rad_on_kernel=get(H.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case H.optimize
		x=xmin:xint:xmax;
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data3(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl1 = plot(tin,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 8)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8) 
		set(H.optimize_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff
		title('All data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples3};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

		case H.Myr_kernel

		x=xmin:xint:xmax;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(data3(:,1)),1) = kernel;
		kde1=pdp5_2sig(data3(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl1 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 8)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 8)		
		end
		set(lgnd,'color','w');
		legend boxoff
		title('All data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples3};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');	

    case H.radio_hist_pdp

f1 = figure;        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
hist(data1(:,1), bins);
xlabel('Age (Ma)')
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
ax2 = axes('Position',get(ax1,'Position'),...
'XAxisLocation','top',...
'YAxisLocation','right',...
'Color','none',...
'XColor','b','YColor','b');
hold on
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
set(hl1,'linewidth',2)
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
legend('Probability Density Plot');
title('Filtered data');
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples1};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

f2 = figure;        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
hist(data2(:,1), bins);
xlabel('Age (Ma)')
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
ax2 = axes('Position',get(ax1,'Position'),...
'XAxisLocation','top',...
'YAxisLocation','right',...
'Color','none',...
'XColor','b','YColor','b');
hold on
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data2(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
set(hl1,'linewidth',2)
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
legend('Probability Density Plot');
title('Rejected data');
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples2};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

f3 = figure;        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
hist(data3(:,1), bins);
xlabel('Age (Ma)')
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
ax2 = axes('Position',get(ax1,'Position'),...
'XAxisLocation','top',...
'YAxisLocation','right',...
'Color','none',...
'XColor','b','YColor','b');
hold on
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data3(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
set(hl1,'linewidth',2)
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
legend('Probability Density Plot');
title('All data');
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples3};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');	



    case H.radio_hist_kde

f1 = figure;
 
 		rad_on_kernel=get(H.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case H.optimize      

		hist(data1(:,1), bins);
		set(gca,'box','off')
		axis([xmin xmax hist_ymin hist_ymax])
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 8)
		xlabel('Age (Ma)', 'FontSize', 8)
		ax2 = axes('Units', 'character'); %create a new axis and set units to be character
		set(ax2, 'Position',get(ax1,'Position'),...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none',...
        'XColor','k','YColor','k');
		hold on
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data1(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl2 = plot(xA,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Kernel Density Estimate');
		set(hl2,'linewidth',2) 
		set(H.optimize_text, 'String', bandwidth); 
		set(lgnd,'color','w');
		legend boxoff

		case H.Myr_kernel

		hist(data1(:,1), bins);
		set(gca,'box','off')
		axis([xmin xmax hist_ymin hist_ymax])
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 8)
		xlabel('Age (Ma)', 'FontSize', 8)
		ax2 = axes('Units', 'character'); %create a new axis and set units to be character
		set(ax2, 'Position',get(ax1,'Position'),...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none',...
        'XColor','k','YColor','k');
		hold on
		x=xmin:xint:xmax;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_data1(1:length(data1(:,1)),1) = kernel;
		kde1=pdp5_2sig(data1(:,1),kernel_data1,xmin,xmax,xint);    
		hl2 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kde1);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Kernel Density Estimate');
		set(hl2,'linewidth',2) 
		set(lgnd,'color','w');
		legend boxoff
		end

    case H.radio_hist_pdp_kde
	axes(H.axes_distribution);        
	x=xmin:xint:xmax;
	pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
	hist(data1(:,1), bins);
	set(gca,'box','off')
	xlabel('Age (Ma)', 'FontSize', 8)
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency')
	ax2 = axes('Units', 'character'); %create a new axis and set units to be character
	set(ax2, 'Position',get(ax1,'Position'),...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none',...
    'XColor','k','YColor','k');
	hold on

 		rad_on_kernel=get(H.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case H.optimize

		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data1(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
		x=xmin:xint:xmax;
		hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
		hl2 = plot(xA,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(pdp);
		kdemax = max(kdeA);
		maxboth = [pdpmax,kdemax];
		maxboth = max(maxboth);
		axis([xmin xmax 0 maxboth+0.1*maxboth])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Probability Density Plot','Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(hl2,'linewidth',2)     
   		set(H.optimize_text, 'String', bandwidth); 
		set(lgnd,'color','w');
		legend boxoff
		
		case H.Myr_kernel

		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data1(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
		x=xmin:xint:xmax;
		hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
		x=xmin:xint:xmax;
		kernel = str2num(get(H.Myr_Kernel_text,'String'));
		kernel_data1(1:length(data1(:,1)),1) = kernel;
		kde1=pdp5_2sig(data1(:,1),kernel_data1,xmin,xmax,xint);    
		hl2 = plot(x,kde1,'Color',[1 0 0]);		
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(pdp);
		kdemax = max(kde1);
		maxboth = [pdpmax,kdemax];
		maxboth = max(maxboth);
		axis([xmin xmax 0 maxboth+0.1*maxboth])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Probability Density Plot','Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(hl2,'linewidth',2)  
		set(lgnd,'color','w');
		legend boxoff
		end
	end



%% CHECKBOX WINDOWS %%
function chk_windows_Callback(hObject, eventdata, H)
INT_xmax = H.INT_xmax;
INT_xmin = H.INT_xmin;
BL_xmin = str2num(get(H.BL_min,'String'));
BL_xmax = str2num(get(H.BL_max,'String'));
threshold_U238 = str2num(get(H.threshold,'String'));
add_sec = str2num(get(H.add_int,'String'));
int_time = str2num(get(H.int_duration,'String'));
name_idx = get(H.listbox1,'Value');
data_ind = H.data_ind;
name = H.name;
t_BL_trim_length = H.t_BL_trim_length;
t_INT_trim = H.t_INT_trim;
t_INT_trim_max_idx = H.t_INT_trim_max_idx;
t_INT_trim_min_idx = H.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
plot_vals = log10(values2);
plot_vals(~isfinite(plot_vals))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
hold on
if get(H.chk_Hg201,'Value')==1 
plot(t,plot_vals(:,1),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Hg202,'Value')==1 
plot(t,plot_vals(:,2),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb204,'Value')==1 
plot(t,plot_vals(:,3),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb206,'Value')==1 
plot(t,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb207,'Value')==1 
plot(t,plot_vals(:,5),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Pb208,'Value')==1 
plot(t,plot_vals(:,6),'linewidth', thickness,'color',C{6});
end
if get(H.chk_Th232,'Value')==1 
plot(t,plot_vals(:,7),'linewidth', thickness,'color',C{7});
end
if get(H.chk_U238,'Value')==1 
plot(t,plot_vals(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = plot_vals(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = plot_vals(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
axis([0 max(t) 2 max(max(plot_vals))+0.5])

if get(H.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(H.axes_current_intensities,'FontSize',7);

guidata(hObject,H);




%% CHECKBOX 201Hg %%
function chk_Hg201_Callback(hObject, eventdata, H)
INT_xmax = H.INT_xmax;
INT_xmin = H.INT_xmin;
BL_xmin = str2num(get(H.BL_min,'String'));
BL_xmax = str2num(get(H.BL_max,'String'));
threshold_U238 = str2num(get(H.threshold,'String'));
add_sec = str2num(get(H.add_int,'String'));
int_time = str2num(get(H.int_duration,'String'));
name_idx = get(H.listbox1,'Value');
data_ind = H.data_ind;
name = H.name;
t_BL_trim_length = H.t_BL_trim_length;
t_INT_trim = H.t_INT_trim;
t_INT_trim_max_idx = H.t_INT_trim_max_idx;
t_INT_trim_min_idx = H.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
plot_vals = log10(values2);
plot_vals(~isfinite(plot_vals))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(H.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
hold on
if get(H.chk_Hg201,'Value')==1 
plot(t,plot_vals(:,1),'linewidth', thickness,'color',C{1});
end
if get(H.chk_Hg202,'Value')==1 
plot(t,plot_vals(:,2),'linewidth', thickness,'color',C{2});
end
if get(H.chk_Pb204,'Value')==1 
plot(t,plot_vals(:,3),'linewidth', thickness,'color',C{3});
end
if get(H.chk_Pb206,'Value')==1 
plot(t,plot_vals(:,4),'linewidth', thickness,'color',C{4});
end
if get(H.chk_Pb207,'Value')==1 
plot(t,plot_vals(:,5),'linewidth', thickness,'color',C{5});
end
if get(H.chk_Pb208,'Value')==1 
plot(t,plot_vals(:,6),'linewidth', thickness,'color',C{6});
end
if get(H.chk_Th232,'Value')==1 
plot(t,plot_vals(:,7),'linewidth', thickness,'color',C{7});
end
if get(H.chk_U238,'Value')==1 
plot(t,plot_vals(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = plot_vals(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = plot_vals(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
axis([0 max(t) 2 max(max(plot_vals))+0.5])

if get(H.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(H.axes_current_intensities,'FontSize',7);

guidata(hObject,H);
































































function known_p68_Callback(hObject, eventdata, H)

function known_p68_CreateFcn(hObject, eventdata, H)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s68_Callback(hObject, eventdata, H)
% hObject    handle to known_s68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s68 as text
%        str2double(get(hObject,'String')) returns contents of known_s68 as a double


% --- Executes during object creation, after setting all properties.
function known_s68_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_s68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p68err_Callback(hObject, eventdata, H)
% hObject    handle to known_p68err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p68err as text
%        str2double(get(hObject,'String')) returns contents of known_p68err as a double


% --- Executes during object creation, after setting all properties.
function known_p68err_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_p68err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s68err_Callback(hObject, eventdata, H)
% hObject    handle to known_s68err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s68err as text
%        str2double(get(hObject,'String')) returns contents of known_s68err as a double


% --- Executes during object creation, after setting all properties.
function known_s68err_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_s68err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p76_Callback(hObject, eventdata, H)
% hObject    handle to known_p76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p76 as text
%        str2double(get(hObject,'String')) returns contents of known_p76 as a double


% --- Executes during object creation, after setting all properties.
function known_p76_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_p76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s76_Callback(hObject, eventdata, H)
% hObject    handle to known_s76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s76 as text
%        str2double(get(hObject,'String')) returns contents of known_s76 as a double


% --- Executes during object creation, after setting all properties.
function known_s76_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_s76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p76err_Callback(hObject, eventdata, H)
% hObject    handle to known_p76err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p76err as text
%        str2double(get(hObject,'String')) returns contents of known_p76err as a double


% --- Executes during object creation, after setting all properties.
function known_p76err_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_p76err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s76err_Callback(hObject, eventdata, H)
% hObject    handle to known_s76err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s76err as text
%        str2double(get(hObject,'String')) returns contents of known_s76err as a double


% --- Executes during object creation, after setting all properties.
function known_s76err_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_s76err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p75_Callback(hObject, eventdata, H)
% hObject    handle to known_p75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p75 as text
%        str2double(get(hObject,'String')) returns contents of known_p75 as a double


% --- Executes during object creation, after setting all properties.
function known_p75_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_p75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s75_Callback(hObject, eventdata, H)
% hObject    handle to known_s75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s75 as text
%        str2double(get(hObject,'String')) returns contents of known_s75 as a double


% --- Executes during object creation, after setting all properties.
function known_s75_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_s75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p75err_Callback(hObject, eventdata, H)
% hObject    handle to known_p75err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p75err as text
%        str2double(get(hObject,'String')) returns contents of known_p75err as a double


% --- Executes during object creation, after setting all properties.
function known_p75err_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_p75err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s75err_Callback(hObject, eventdata, H)
% hObject    handle to known_s75err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s75err as text
%        str2double(get(hObject,'String')) returns contents of known_s75err as a double


% --- Executes during object creation, after setting all properties.
function known_s75err_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_s75err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p82_Callback(hObject, eventdata, H)
% hObject    handle to known_p82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p82 as text
%        str2double(get(hObject,'String')) returns contents of known_p82 as a double


% --- Executes during object creation, after setting all properties.
function known_p82_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_p82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s82_Callback(hObject, eventdata, H)
% hObject    handle to known_s82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s82 as text
%        str2double(get(hObject,'String')) returns contents of known_s82 as a double


% --- Executes during object creation, after setting all properties.
function known_s82_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_s82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p82err_Callback(hObject, eventdata, H)
% hObject    handle to known_p82err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p82err as text
%        str2double(get(hObject,'String')) returns contents of known_p82err as a double


% --- Executes during object creation, after setting all properties.
function known_p82err_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_p82err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s82err_Callback(hObject, eventdata, H)
% hObject    handle to known_s82err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s82err as text
%        str2double(get(hObject,'String')) returns contents of known_s82err as a double


% --- Executes during object creation, after setting all properties.
function known_s82err_CreateFcn(hObject, eventdata, H)
% hObject    handle to known_s82err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, H)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, H)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, H)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, H)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spline_breaks_Callback(hObject, eventdata, H)
% hObject    handle to spline_breaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spline_breaks as text
%        str2double(get(hObject,'String')) returns contents of spline_breaks as a double


% --- Executes during object creation, after setting all properties.
function spline_breaks_CreateFcn(hObject, eventdata, H)
% hObject    handle to spline_breaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in example_prn.
function example_prn_Callback(hObject, eventdata, H)
% hObject    handle to example_prn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

LiveUPbDataReductionExample;



function edit25_Callback(hObject, eventdata, H)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, H)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, H)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, H)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)







% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

xmin = str2num(get(H.edit21,'String'));
xmax = str2num(get(H.edit20,'String'));
ymin = str2num(get(H.edit23,'String'));
ymax = str2num(get(H.edit22,'String'));
agelabelmin = str2num(get(H.edit63,'String'));
agelabelmax = str2num(get(H.edit62,'String'));
agelabelint = str2num(get(H.edit64,'String'));

concordant_samples_sort = H.concordant_samples_sort;
discordant_samples_sort = H.discordant_samples_sort;

concordant_data = [concordant_samples_sort(:,2),concordant_samples_sort(:,3), ...
	concordant_samples_sort(:,4),concordant_samples_sort(:,5),...
	concordant_samples_sort(:,6),concordant_samples_sort(:,7)];

concordant_data_rho = concordant_samples_sort(:,8);

concordant_data_center=[concordant_data(:,3),concordant_data(:,5)];

concordant_data_sigx_abs = concordant_data(:,3).*concordant_data(:,4).*0.01;
concordant_data_sigy_abs = concordant_data(:,5).*concordant_data(:,6).*0.01;

concordant_data_sigx_sq = concordant_data_sigx_abs.*concordant_data_sigx_abs;
concordant_data_sigy_sq = concordant_data_sigy_abs.*concordant_data_sigy_abs;
concordant_data_rho_sigx_sigy = concordant_data_sigx_abs.*concordant_data_sigy_abs.*concordant_data_rho;
sigmarule=1.5;
numpoints=50;





%replaced with 32 bit code
%replaced with 32 bit code
%replaced with 32 bit code
axes(H.axes_current_intensities);

for i = 1:length(concordant_data_rho);

concordant_data_covmat=[concordant_data_sigx_sq(i,1),concordant_data_rho_sigx_sigy(i,1);concordant_data_rho_sigx_sigy(i,1), ...
	concordant_data_sigy_sq(i,1)];
[concordant_data_PD,concordant_data_PV]=eig(concordant_data_covmat);
concordant_data_PV=diag(concordant_data_PV).^.5;
concordant_data_theta=linspace(0,2.*pi,numpoints)';
concordant_data_elpt=[cos(concordant_data_theta),sin(concordant_data_theta)]*diag(concordant_data_PV)*concordant_data_PD';
numsigma=length(sigmarule);
concordant_data_elpt=repmat(concordant_data_elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
concordant_data_elpt=concordant_data_elpt+repmat(concordant_data_center(i,1:2),numpoints,numsigma);
plot(concordant_data_elpt(:,1:2:end),concordant_data_elpt(:,2:2:end),'b','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
for i=1:length(age_label_num)
age_label(i,1) = {sprintf('%.1f',age_label_num(1,i))};
age_label2(i,1) = strcat(age_label(i,1),' Ga');
end
age_label_num = age_label_num.*1000000000;
age_label_x = exp(0.00000000098485.*age_label_num)-1;
age_label_y = exp(0.000000000155125.*age_label_num)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');

axis([xmin xmax ymin ymax]);
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

discordant_data = [discordant_samples_sort(:,2),discordant_samples_sort(:,3), ...
	discordant_samples_sort(:,4),discordant_samples_sort(:,5),...
	discordant_samples_sort(:,6),discordant_samples_sort(:,7)];

discordant_data_rho = discordant_samples_sort(:,8);

discordant_data_center=[discordant_data(:,3),discordant_data(:,5)];

discordant_data_sigx_abs = discordant_data(:,3).*discordant_data(:,4).*0.01;
discordant_data_sigy_abs = discordant_data(:,5).*discordant_data(:,6).*0.01;

discordant_data_sigx_sq = discordant_data_sigx_abs.*discordant_data_sigx_abs;
discordant_data_sigy_sq = discordant_data_sigy_abs.*discordant_data_sigy_abs;
discordant_data_rho_sigx_sigy = discordant_data_sigx_abs.*discordant_data_sigy_abs.*discordant_data_rho;
sigmarule=1.5;
numpoints=50;
set(gca,'fontsize',20)

axes(H.axes_current_concordia);

for i = 1:length(discordant_data_rho);

discordant_data_covmat=[discordant_data_sigx_sq(i,1),discordant_data_rho_sigx_sigy(i,1);discordant_data_rho_sigx_sigy(i,1), ...
	discordant_data_sigy_sq(i,1)];
[discordant_data_PD,discordant_data_PV]=eig(discordant_data_covmat);
discordant_data_PV=diag(discordant_data_PV).^.5;
discordant_data_theta=linspace(0,2.*pi,numpoints)';
discordant_data_elpt=[cos(discordant_data_theta),sin(discordant_data_theta)]*diag(discordant_data_PV)*discordant_data_PD';
numsigma=length(sigmarule);
discordant_data_elpt=repmat(discordant_data_elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
discordant_data_elpt=discordant_data_elpt+repmat(discordant_data_center(i,1:2),numpoints,numsigma);
plot(discordant_data_elpt(:,1:2:end),discordant_data_elpt(:,2:2:end),'r','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');

axis([xmin xmax ymin ymax]);
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

nsamp1 = num2str(length(concordant_samples_sort(:,1)));
nsamp2 = num2str(length(discordant_samples_sort(:,1)));

set(H.text56,'String',nsamp1);
set(H.text58,'String',nsamp2);



% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)




function edit29_Callback(hObject, eventdata, H)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit30_Callback(hObject, eventdata, H)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit31_Callback(hObject, eventdata, H)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit31 as text
%        str2double(get(hObject,'String')) returns contents of edit31 as a double


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit32_Callback(hObject, eventdata, H)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bestage_cutoff_Callback(hObject, eventdata, H)
% hObject    handle to bestage_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bestage_cutoff as text
%        str2double(get(hObject,'String')) returns contents of bestage_cutoff as a double


% --- Executes during object creation, after setting all properties.
function bestage_cutoff_CreateFcn(hObject, eventdata, H)
% hObject    handle to bestage_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_err68_Callback(hObject, eventdata, H)
% hObject    handle to filter_err68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_err68 as text
%        str2double(get(hObject,'String')) returns contents of filter_err68 as a double


% --- Executes during object creation, after setting all properties.
function filter_err68_CreateFcn(hObject, eventdata, H)
% hObject    handle to filter_err68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_cutoff_Callback(hObject, eventdata, H)
% hObject    handle to filter_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_cutoff as text
%        str2double(get(hObject,'String')) returns contents of filter_cutoff as a double


% --- Executes during object creation, after setting all properties.
function filter_cutoff_CreateFcn(hObject, eventdata, H)
% hObject    handle to filter_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_disc_rev_Callback(hObject, eventdata, H)
% hObject    handle to filter_disc_rev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_disc_rev as text
%        str2double(get(hObject,'String')) returns contents of filter_disc_rev as a double


% --- Executes during object creation, after setting all properties.
function filter_disc_rev_CreateFcn(hObject, eventdata, H)
% hObject    handle to filter_disc_rev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_err67_Callback(hObject, eventdata, H)
% hObject    handle to filter_err67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_err67 as text
%        str2double(get(hObject,'String')) returns contents of filter_err67 as a double


% --- Executes during object creation, after setting all properties.
function filter_err67_CreateFcn(hObject, eventdata, H)
% hObject    handle to filter_err67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_disc_Callback(hObject, eventdata, H)
% hObject    handle to filter_disc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_disc as text
%        str2double(get(hObject,'String')) returns contents of filter_disc as a double


% --- Executes during object creation, after setting all properties.
function filter_disc_CreateFcn(hObject, eventdata, H)
% hObject    handle to filter_disc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

%cla(H.axes9,'reset'); %clear PDP plot
%cla(H.axes17,'reset'); %clear CDF plot

% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

cla(H.axes_current_intensities,'reset'); %clear PDP plot
cla(H.axes_current_concordia,'reset'); %clear CDF plot
% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, H)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



function edit43_Callback(hObject, eventdata, H)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit43 as text
%        str2double(get(hObject,'String')) returns contents of edit43 as a double


% --- Executes during object creation, after setting all properties.
function edit43_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit44_Callback(hObject, eventdata, H)
% hObject    handle to edit44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit44 as text
%        str2double(get(hObject,'String')) returns contents of edit44 as a double


% --- Executes during object creation, after setting all properties.
function edit44_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



function edit45_Callback(hObject, eventdata, H)
% hObject    handle to edit45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit45 as text
%        str2double(get(hObject,'String')) returns contents of edit45 as a double


% --- Executes during object creation, after setting all properties.
function edit45_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit46_Callback(hObject, eventdata, H)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit46 as text
%        str2double(get(hObject,'String')) returns contents of edit46 as a double


% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit47_Callback(hObject, eventdata, H)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit47 as text
%        str2double(get(hObject,'String')) returns contents of edit47 as a double


% --- Executes during object creation, after setting all properties.
function edit47_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit48_Callback(hObject, eventdata, H)
% hObject    handle to edit48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit48 as text
%        str2double(get(hObject,'String')) returns contents of edit48 as a double


% --- Executes during object creation, after setting all properties.
function edit48_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



function edit49_Callback(hObject, eventdata, H)
% hObject    handle to edit49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit49 as text
%        str2double(get(hObject,'String')) returns contents of edit49 as a double


% --- Executes during object creation, after setting all properties.
function edit49_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit50_Callback(hObject, eventdata, H)
% hObject    handle to edit50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit50 as text
%        str2double(get(hObject,'String')) returns contents of edit50 as a double


% --- Executes during object creation, after setting all properties.
function edit50_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function edit51_Callback(hObject, eventdata, H)
% hObject    handle to edit51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit51 as text
%        str2double(get(hObject,'String')) returns contents of edit51 as a double


% --- Executes during object creation, after setting all properties.
function edit51_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit52_Callback(hObject, eventdata, H)
% hObject    handle to edit52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit52 as text
%        str2double(get(hObject,'String')) returns contents of edit52 as a double


% --- Executes during object creation, after setting all properties.
function edit52_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit53_Callback(hObject, eventdata, H)
% hObject    handle to edit53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit53 as text
%        str2double(get(hObject,'String')) returns contents of edit53 as a double


% --- Executes during object creation, after setting all properties.
function edit53_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit54_Callback(hObject, eventdata, H)
% hObject    handle to edit54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit54 as text
%        str2double(get(hObject,'String')) returns contents of edit54 as a double


% --- Executes during object creation, after setting all properties.
function edit54_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



function xmin_Callback(hObject, eventdata, H)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmin as text
%        str2double(get(hObject,'String')) returns contents of xmin as a double


% --- Executes during object creation, after setting all properties.
function xmin_CreateFcn(hObject, eventdata, H)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit56_Callback(hObject, eventdata, H)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit56 as text
%        str2double(get(hObject,'String')) returns contents of edit56 as a double


% --- Executes during object creation, after setting all properties.
function edit56_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xmax_Callback(hObject, eventdata, H)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmax as text
%        str2double(get(hObject,'String')) returns contents of xmax as a double


% --- Executes during object creation, after setting all properties.
function xmax_CreateFcn(hObject, eventdata, H)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xint_Callback(hObject, eventdata, H)
% hObject    handle to xint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xint as text
%        str2double(get(hObject,'String')) returns contents of xint as a double


% --- Executes during object creation, after setting all properties.
function xint_CreateFcn(hObject, eventdata, H)
% hObject    handle to xint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ymin_Callback(hObject, eventdata, H)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymin as text
%        str2double(get(hObject,'String')) returns contents of ymin as a double


% --- Executes during object creation, after setting all properties.
function ymin_CreateFcn(hObject, eventdata, H)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function h_ymax_Callback(hObject, eventdata, H)
% hObject    handle to h_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of h_ymax as text
%        str2double(get(hObject,'String')) returns contents of h_ymax as a double


% --- Executes during object creation, after setting all properties.
function h_ymax_CreateFcn(hObject, eventdata, H)
% hObject    handle to h_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bins_Callback(hObject, eventdata, H)
% hObject    handle to bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bins as text
%        str2double(get(hObject,'String')) returns contents of bins as a double


% --- Executes during object creation, after setting all properties.
function bins_CreateFcn(hObject, eventdata, H)
% hObject    handle to bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')

% --- Executes on button press in plot_rejected.
function plot_rejected_Callback(hObject, eventdata, H)
% hObject    handle to plot_rejected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

axes(H.axes_distribution); 
cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')

data2 = H.data2;

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
hist_ymin = str2num(get(H.ymin,'String'));
hist_ymax = str2num(get(H.ymax,'String'));
bins = str2num(get(H.bins,'String'));
 
rad_on=get(H.uipanel_distribution,'selectedobject');
switch rad_on
    case H.radio_hist
    
axes(H.axes_distribution);    
hist(data2(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')
 
    case H.radio_pdp
 
axes(H.axes_distribution);     
x=xmin:xint:xmax;
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);    
hl1 = plot(x,pdp,'Color','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')
 
    case H.radio_kde
 
axes(H.axes_distribution);     
x=xmin:xint:xmax;
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data2(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
hl1 = plot(tin,kdeA,'Color','b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
kdemax = max(kdeA);
axis([xmin xmax 0 kdemax+0.1*kdemax])
legend('Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')   
 
    case H.radio_hist_pdp
 
axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
 
hist(data2(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data2(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
%hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
%set(hl2,'linewidth',2) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)') 
 
    case H.radio_hist_kde
        
axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
 
hist(data2(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data2(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
%hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Probability Density Plot');
%set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)')         
 
    
    case H.radio_hist_pdp_kde
 
axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
 
hist(data2(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
 
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data2(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Probability Density Plot','Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5)        
        
        
         case H.radio_pdp
        Two_Sample_Compare_PDP;
    
    case H.radio_hist_pdp_kde
        Two_Sample_Compare_KDE;
        
        
        
    otherwise
        set(H.edit_radioselect,'string','');
end
 
 
nsamp = num2str(length(data2));
set(H.n_plotted,'String',nsamp);




% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



% --- Executes on button press in plot_filtered.
function plot_filtered_Callback(hObject, eventdata, H)
% hObject    handle to plot_filtered (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

axes(H.axes_distribution); 
cla reset

set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')

data1 = H.data1;

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
hist_ymin = str2num(get(H.ymin,'String'));
hist_ymax = str2num(get(H.ymax,'String'));
bins = str2num(get(H.bins,'String'));

rad_on=get(H.uipanel_distribution,'selectedobject');
switch rad_on
    case H.radio_hist
    
axes(H.axes_distribution);    
hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')

    case H.radio_pdp

axes(H.axes_distribution);     
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);    
hl1 = plot(x,pdp,'Color','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')

    case H.radio_kde

axes(H.axes_distribution);     
x=xmin:xint:xmax;
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

hl1 = plot(tin,kdeA,'Color','b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
kdemax = max(kdeA);
axis([xmin xmax 0 kdemax+0.1*kdemax])
legend('Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')   

    case H.radio_hist_pdp

axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')

ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
%hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
%set(hl2,'linewidth',2) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)') 

    case H.radio_hist_kde
        
axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')

ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
%hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Kernel Density Estimate');
%set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)')         
    
    case H.radio_hist_pdp_kde

axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
xlabel('Age (Ma)')
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')


ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Probability Density Plot','Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5)        
        
        
            
        
        
    otherwise
        set(H.edit_radioselect,'string','');

end


nsamp = num2str(length(data1));
set(H.n_plotted,'String',nsamp);

























% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

data1 = H.data1;
final_sample_num = H.final_sample_num;
samples = H.samples;
discordant_samples_sort = H.discordant_samples_sort;
analysis_num = H.analysis_num;

for i = 1:length(samples)
if samples(i,1) > 0
	samples_ascribe1(i,1) = analysis_num(i,1);
else 
	samples_ascribe1(i,1) = {''};
end
end

samples_ascribe = samples_ascribe1(~cellfun(@isempty, samples_ascribe1));
name_reduced_samples = samples_ascribe(discordant_samples_sort(:,1),1);

dat = {'Analysis_name', 'bias_corr_samples_Pb207_Pb206', 'bias_corr_samples_Pb207_Pb206_err', ...
    'bias_corr_samples_Pb207_U235', 'bias_corr_samples_Pb207_U235_err', 'bias_corr_samples_Pb206_U238', 'bias_corr_samples_Pb206_U238_err' ...
    'rho', 'bias_corr_samples_Pb208_Th232', 'bias_corr_samples_Pb208_Th232_err', 'samples_Pb206_U238_age,', 'samples_Pb206_U238_age_err' ...
    'samples_Pb207_U235_age', 'samples_Pb207_U235_age_err', 'samples_Pb207_Pb206_age', 'samples_Pb207_Pb206_age_err', 'samples_Pb208_Th232_age', ...
    'samples_Pb208_Th232_age_err', 'discordance_Pb206U238_Pb207Pb206', 'discordance_Pb206U238_Pb207U235', 'best_age', 'best_age_err'};

dat(2:length(discordant_samples_sort(:,1))+1,:) = num2cell(discordant_samples_sort);
dat(2:length(discordant_samples_sort(:,1))+1,1) = name_reduced_samples;

[file,path] = uiputfile('*.xls','Save file');
writetable(table(dat),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);
%xlswrite([path file], dat);









% --- Executes on button press in summary.
function pushbutton39_Callback(hObject, eventdata, H)
% hObject    handle to summary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

time2 = H.time2;
standard_1_time = H.standard_1_time;
frac_corr_standard_1_Pb206_U238 = H.frac_corr_standard_1_Pb206_U238;
spline_Pb206_U238 = H.spline_Pb206_U238;
frac_corr_standard_1_Pb207_Pb206 = H.frac_corr_standard_1_Pb207_Pb206;
spline_Pb207_Pb206 = H.spline_Pb207_Pb206;
frac_corr_standard_1_Pb207_U235 = H.frac_corr_standard_1_Pb207_U235;
spline_Pb207_U235 = H.spline_Pb207_U235;
frac_corr_standard_1_Pb208_Th232 = H.frac_corr_standard_1_Pb208_Th232;
spline_Pb208_Th232 = H.spline_Pb208_Th232;







f = figure; %create new figure
plot(standard_1_time,frac_corr_standard_1_Pb206_U238,'.', time2,[spline_Pb206_U238])
hold on 
scatter(time2,spline_Pb206_U238, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
axis([min(time2) max(time2) min(frac_corr_standard_1_Pb206_U238) max(frac_corr_standard_1_Pb206_U238)]);

f1 = figure; %create new figure
plot(standard_1_time,frac_corr_standard_1_Pb207_Pb206,'.', time2,[spline_Pb207_Pb206])
hold on 
scatter(time2,spline_Pb207_Pb206, '.', 'r');
xlabel('decimal time');
ylabel('Pb207/Pb206');
axis([min(time2) max(time2) min(frac_corr_standard_1_Pb207_Pb206) max(frac_corr_standard_1_Pb207_Pb206)]);

f2 = figure; %create new figure
plot(standard_1_time,frac_corr_standard_1_Pb207_U235,'.', time2,[spline_Pb207_U235])
hold on 
scatter(time2,spline_Pb207_U235, '.', 'r');
xlabel('decimal time');
ylabel('Pb207/U235');
axis([min(time2) max(time2) min(frac_corr_standard_1_Pb207_U235) max(frac_corr_standard_1_Pb207_U235)]);

f3 = figure; %create new figure
plot(standard_1_time,frac_corr_standard_1_Pb208_Th232,'.', time2,[spline_Pb208_Th232])
hold on 
scatter(time2,spline_Pb208_Th232, '.', 'r');
xlabel('decimal time');
ylabel('Pb208/Th232');
axis([min(time2) max(time2) min(frac_corr_standard_1_Pb208_Th232) max(frac_corr_standard_1_Pb208_Th232)]);










% --- Executes on button press in pushbutton43.
function pushbutton43_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

f = figure; %create new figure
axes(H.axes_distribution); 
cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')

data1 = H.data1;
data2 = H.data2;

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
hist_ymin = str2num(get(H.ymin,'String'));
hist_ymax = str2num(get(H.ymax,'String'));
bins = str2num(get(H.bins,'String'));

rad_on=get(H.uipanel_distribution,'selectedobject');
switch rad_on
    case H.radio_hist
    
axes(H.axes_distribution);    
hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')

    case H.radio_pdp

axes(H.axes_distribution);     
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);    
hl1 = plot(x,pdp,'Color','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')

    case H.radio_kde

axes(H.axes_distribution);     
x=xmin:xint:xmax;
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

hl1 = plot(tin,kdeA,'Color','b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
kdemax = max(kdeA);
axis([xmin xmax 0 kdemax+0.1*kdemax])
legend('Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')   

    case H.radio_hist_pdp

axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')

ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
%hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
%set(hl2,'linewidth',2) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)') 

    case H.radio_hist_kde
        
axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')

ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
%hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Probability Density Plot');
%set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)')         

    
    case H.radio_hist_pdp_kde

axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')


ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Probability Density Plot','Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5)        
        
        
         case H.radio_pdp
        Two_Sample_Compare_PDP;
    
    case H.radio_hist_pdp_kde
        Two_Sample_Compare_KDE;
        
        
        
    otherwise
        set(H.edit_radioselect,'string','');
end


nsamp = num2str(length(data1));
set(H.n_plotted,'String',nsamp);


% --- Executes on button press in pushbutton46.
function pushbutton46_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in plot_all.
function plot_all_Callback(hObject, eventdata, H)
% hObject    handle to plot_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


axes(H.axes_distribution); 
cla reset

set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')

data1 = H.data1;
data2 = H.data2;

data3 = vertcat(data1,data2);

xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
hist_ymin = str2num(get(H.ymin,'String'));
hist_ymax = str2num(get(H.ymax,'String'));
bins = str2num(get(H.bins,'String'));
 
rad_on=get(H.uipanel_distribution,'selectedobject');
switch rad_on
    case H.radio_hist
    
axes(H.axes_distribution);    
hist(data3(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')
 
    case H.radio_pdp
 
axes(H.axes_distribution);     
x=xmin:xint:xmax;
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);    
hl1 = plot(x,pdp,'Color','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')
 
    case H.radio_kde
 
axes(H.axes_distribution);     
x=xmin:xint:xmax;
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data3(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
hl1 = plot(tin,kdeA,'Color','b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
kdemax = max(kdeA);
axis([xmin xmax 0 kdemax+0.1*kdemax])
legend('Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')   
 
    case H.radio_hist_pdp
 
axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
 
hist(data3(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data3(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
%hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
%set(hl2,'linewidth',2) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)') 
 
    case H.radio_hist_kde
        
axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
 
hist(data3(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data3(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
%hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Kernel Density Estimate');
%set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)')         
    
    case H.radio_hist_pdp_kde
 
axes(H.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
 
hist(data3(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
 
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data3(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Probability Density Plot','Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5)        
        
        
            
        
        
    otherwise
        set(H.edit_radioselect,'string','');
 
end
 
 
nsamp = num2str(length(data3));
set(H.n_plotted,'String',nsamp);

























% --- Executes on button press in pushbutton44.
function pushbutton44_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

















function edit62_Callback(hObject, eventdata, H)
% hObject    handle to edit62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit62 as text
%        str2double(get(hObject,'String')) returns contents of edit62 as a double


% --- Executes during object creation, after setting all properties.
function edit62_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit63_Callback(hObject, eventdata, H)
% hObject    handle to edit63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit63 as text
%        str2double(get(hObject,'String')) returns contents of edit63 as a double


% --- Executes during object creation, after setting all properties.
function edit63_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit64_Callback(hObject, eventdata, H)
% hObject    handle to edit64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit64 as text
%        str2double(get(hObject,'String')) returns contents of edit64 as a double


% --- Executes during object creation, after setting all properties.
function edit64_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function edit65_Callback(hObject, eventdata, H)
% hObject    handle to edit65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit65 as text
%        str2double(get(hObject,'String')) returns contents of edit65 as a double


% --- Executes during object creation, after setting all properties.
function edit65_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton50.
function pushbutton50_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)
cla(H.axes_current_intensities,'reset');
cla(H.axes_current_concordia,'reset');





function edit66_Callback(hObject, eventdata, H)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit66 as text
%        str2double(get(hObject,'String')) returns contents of edit66 as a double


% --- Executes during object creation, after setting all properties.
function edit66_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit67_Callback(hObject, eventdata, H)
% hObject    handle to edit67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit67 as text
%        str2double(get(hObject,'String')) returns contents of edit67 as a double


% --- Executes during object creation, after setting all properties.
function edit67_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outlier_cutoff_68_Callback(hObject, eventdata, H)
% hObject    handle to outlier_cutoff_68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outlier_cutoff_68 as text
%        str2double(get(hObject,'String')) returns contents of outlier_cutoff_68 as a double


% --- Executes during object creation, after setting all properties.
function outlier_cutoff_68_CreateFcn(hObject, eventdata, H)
% hObject    handle to outlier_cutoff_68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function edit69_Callback(hObject, eventdata, H)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit69 as text
%        str2double(get(hObject,'String')) returns contents of edit69 as a double


% --- Executes during object creation, after setting all properties.
function edit69_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit70_Callback(hObject, eventdata, H)
% hObject    handle to edit70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit70 as text
%        str2double(get(hObject,'String')) returns contents of edit70 as a double


% --- Executes during object creation, after setting all properties.
function edit70_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit71_Callback(hObject, eventdata, H)
% hObject    handle to edit71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit71 as text
%        str2double(get(hObject,'String')) returns contents of edit71 as a double


% --- Executes during object creation, after setting all properties.
function edit71_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit72_Callback(hObject, eventdata, H)
% hObject    handle to edit72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit72 as text
%        str2double(get(hObject,'String')) returns contents of edit72 as a double


% --- Executes during object creation, after setting all properties.
function edit72_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit73_Callback(hObject, eventdata, H)
% hObject    handle to edit73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit73 as text
%        str2double(get(hObject,'String')) returns contents of edit73 as a double


% --- Executes during object creation, after setting all properties.
function edit73_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outlier_cutoff_76_Callback(hObject, eventdata, H)
% hObject    handle to outlier_cutoff_76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outlier_cutoff_76 as text
%        str2double(get(hObject,'String')) returns contents of outlier_cutoff_76 as a double


% --- Executes during object creation, after setting all properties.
function outlier_cutoff_76_CreateFcn(hObject, eventdata, H)
% hObject    handle to outlier_cutoff_76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit75_Callback(hObject, eventdata, H)
% hObject    handle to edit75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit75 as text
%        str2double(get(hObject,'String')) returns contents of edit75 as a double


% --- Executes during object creation, after setting all properties.
function edit75_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit76_Callback(hObject, eventdata, H)
% hObject    handle to edit76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit76 as text
%        str2double(get(hObject,'String')) returns contents of edit76 as a double


% --- Executes during object creation, after setting all properties.
function edit76_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function poly_order_Callback(hObject, eventdata, H)
% hObject    handle to poly_order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of poly_order as text
%        str2double(get(hObject,'String')) returns contents of poly_order as a double


% --- Executes during object creation, after setting all properties.
function poly_order_CreateFcn(hObject, eventdata, H)
% hObject    handle to poly_order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton56.
function pushbutton56_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

xmin = str2num(get(H.edit21,'String'));
xmax = str2num(get(H.edit20,'String'));
ymin = str2num(get(H.edit23,'String'));
ymax = str2num(get(H.edit22,'String'));
agelabelmin = str2num(get(H.edit63,'String'));
agelabelmax = str2num(get(H.edit62,'String'));
agelabelint = str2num(get(H.edit64,'String'));

concordant_samples_sort = H.concordant_samples_sort;
discordant_samples_sort = H.discordant_samples_sort;

concordant_data = [concordant_samples_sort(:,2),concordant_samples_sort(:,3), ...
	concordant_samples_sort(:,4),concordant_samples_sort(:,5),...
	concordant_samples_sort(:,6),concordant_samples_sort(:,7)];

concordant_data_rho = concordant_samples_sort(:,8);

concordant_data_center=[concordant_data(:,3),concordant_data(:,5)];

concordant_data_sigx_abs = concordant_data(:,3).*concordant_data(:,4).*0.01;
concordant_data_sigy_abs = concordant_data(:,5).*concordant_data(:,6).*0.01;

concordant_data_sigx_sq = concordant_data_sigx_abs.*concordant_data_sigx_abs;
concordant_data_sigy_sq = concordant_data_sigy_abs.*concordant_data_sigy_abs;
concordant_data_rho_sigx_sigy = concordant_data_sigx_abs.*concordant_data_sigy_abs.*concordant_data_rho;
sigmarule=1.5;
numpoints=50;

figure;

for i = 1:length(concordant_data_rho);

concordant_data_covmat=[concordant_data_sigx_sq(i,1),concordant_data_rho_sigx_sigy(i,1);concordant_data_rho_sigx_sigy(i,1), ...
	concordant_data_sigy_sq(i,1)];
[concordant_data_PD,concordant_data_PV]=eig(concordant_data_covmat);
concordant_data_PV=diag(concordant_data_PV).^.5;
concordant_data_theta=linspace(0,2.*pi,numpoints)';
concordant_data_elpt=[cos(concordant_data_theta),sin(concordant_data_theta)]*diag(concordant_data_PV)*concordant_data_PD';
numsigma=length(sigmarule);
concordant_data_elpt=repmat(concordant_data_elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
concordant_data_elpt=concordant_data_elpt+repmat(concordant_data_center(i,1:2),numpoints,numsigma);
plot(concordant_data_elpt(:,1:2:end),concordant_data_elpt(:,2:2:end),'b','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
for i=1:length(age_label_num)
age_label(i,1) = {sprintf('%.1f',age_label_num(1,i))};
age_label2(i,1) = strcat(age_label(i,1),' Ga');
end
age_label_num = age_label_num.*1000000000;
age_label_x = exp(0.00000000098485.*age_label_num)-1;
age_label_y = exp(0.000000000155125.*age_label_num)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');

axis([xmin xmax ymin ymax]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

discordant_data = [discordant_samples_sort(:,2),discordant_samples_sort(:,3), ...
	discordant_samples_sort(:,4),discordant_samples_sort(:,5),...
	discordant_samples_sort(:,6),discordant_samples_sort(:,7)];

discordant_data_rho = discordant_samples_sort(:,8);

discordant_data_center=[discordant_data(:,3),discordant_data(:,5)];

discordant_data_sigx_abs = discordant_data(:,3).*discordant_data(:,4).*0.01;
discordant_data_sigy_abs = discordant_data(:,5).*discordant_data(:,6).*0.01;

discordant_data_sigx_sq = discordant_data_sigx_abs.*discordant_data_sigx_abs;
discordant_data_sigy_sq = discordant_data_sigy_abs.*discordant_data_sigy_abs;
discordant_data_rho_sigx_sigy = discordant_data_sigx_abs.*discordant_data_sigy_abs.*discordant_data_rho;
sigmarule=1.5;
numpoints=50;

figure;

for i = 1:length(discordant_data_rho);

discordant_data_covmat=[discordant_data_sigx_sq(i,1),discordant_data_rho_sigx_sigy(i,1);discordant_data_rho_sigx_sigy(i,1), ...
	discordant_data_sigy_sq(i,1)];
[discordant_data_PD,discordant_data_PV]=eig(discordant_data_covmat);
discordant_data_PV=diag(discordant_data_PV).^.5;
discordant_data_theta=linspace(0,2.*pi,numpoints)';
discordant_data_elpt=[cos(discordant_data_theta),sin(discordant_data_theta)]*diag(discordant_data_PV)*discordant_data_PD';
numsigma=length(sigmarule);
discordant_data_elpt=repmat(discordant_data_elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
discordant_data_elpt=discordant_data_elpt+repmat(discordant_data_center(i,1:2),numpoints,numsigma);
plot(discordant_data_elpt(:,1:2:end),discordant_data_elpt(:,2:2:end),'r','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');

axis([xmin xmax ymin ymax]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');



function BL_min_Callback(hObject, eventdata, H)
% hObject    handle to BL_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BL_min as text
%        str2double(get(hObject,'String')) returns contents of BL_min as a double


% --- Executes during object creation, after setting all properties.
function BL_min_CreateFcn(hObject, eventdata, H)
% hObject    handle to BL_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BL_max_Callback(hObject, eventdata, H)
% hObject    handle to BL_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BL_max as text
%        str2double(get(hObject,'String')) returns contents of BL_max as a double


% --- Executes during object creation, after setting all properties.
function BL_max_CreateFcn(hObject, eventdata, H)
% hObject    handle to BL_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function threshold_Callback(hObject, eventdata, H)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, H)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function add_int_Callback(hObject, eventdata, H)
% hObject    handle to add_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of add_int as text
%        str2double(get(hObject,'String')) returns contents of add_int as a double


% --- Executes during object creation, after setting all properties.
function add_int_CreateFcn(hObject, eventdata, H)
% hObject    handle to add_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int_duration_Callback(hObject, eventdata, H)
% hObject    handle to int_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int_duration as text
%        str2double(get(hObject,'String')) returns contents of int_duration as a double


% --- Executes during object creation, after setting all properties.
function int_duration_CreateFcn(hObject, eventdata, H)
% hObject    handle to int_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, H)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_selected.
function plot_selected_Callback(hObject, eventdata, H)
% hObject    handle to plot_selected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

cla(H.axes_current_intensities,'reset');
cla(H.axes_current_concordia,'reset');

data_ind = H.data_ind;
name = H.name;
t_BL_trim_length = H.t_BL_trim_length;
t_INT_trim = H.t_INT_trim;
BL_xmin = H.BL_xmin;
BL_xmax = H.BL_xmax;
t_INT_trim_max_idx = H.t_INT_trim_max_idx;
t_INT_trim_min_idx = H.t_INT_trim_min_idx;
INT_xmax = H.INT_xmax;
INT_xmin = H.INT_xmin;

Pb206_U238_err = H.Pb206_U238_err;
Pb207_U235_err = H.Pb207_U235_err;
Pb207_Pb206_err = H.Pb207_Pb206_err;

Pb206_U238 = H.Pb206_U238;
Pb207_U235 = H.Pb207_U235;
Pb207_Pb206 = H.Pb207_Pb206;

All_Pb206_U238_age = H.All_Pb206_U238_age;
All_Pb206_U238_age_err = H.All_Pb206_U238_age_err;
All_Pb207_U235_age = H.All_Pb207_U235_age;
All_Pb207_U235_age_err = H.All_Pb207_U235_age_err;
All_Pb207_Pb206_age = H.All_Pb207_Pb206_age;
All_Pb207_Pb206_age_err = H.All_Pb207_Pb206_age_err;

name_idx = get(H.listbox1,'Value');

axes(H.axes_current_intensities);

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
t = data_ind(1:length(values2),2,name_idx);
Y1 = msnorm(t,values2);

Y1_BL_trim = Y1(1:t_BL_trim_length(1,length(name)),:);

Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = min(Y1_BL_trim_min);
Y1_BL_trim_max = max(Y1_BL_trim_max);

t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));

t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;

Y1_INT_trim = Y1(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);

Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold on

rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',3)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',3)

plot(t,Y1,'LineWidth',1)
xlabel('time (seconds)')
ylabel('Relative Intensities')
title('Normalized Spectra')
h = legend('Hg202','Hg201','Pb204','Pb206','Pb207','Pb208','Th232','U238','Hg204');
set(h,'FontSize',5);

hold off















%%%%%%%%%% only last sample from here down %%%%%%%%%%%%










%%%%%%%%%%%%%%%%%%%% concordia %%%%%%%%%%%%%%%%%%%%%%%%%



%{
final_samples = [final_sample_num, nonzeros(samples.*bias_corr_samples_Pb207_Pb206), nonzeros(samples.*bias_corr_samples_Pb207_Pb206_err), ...
	nonzeros(samples.*bias_corr_samples_Pb207_U235), nonzeros(samples.*bias_corr_samples_Pb207_U235_err), ...
	nonzeros(samples.*bias_corr_samples_Pb206_U238), nonzeros(samples.*bias_corr_samples_Pb206_U238_err), ...
	nonzeros(samples.*rho), nonzeros(samples.*bias_corr_samples_Pb208_Th232), nonzeros(samples.*bias_corr_samples_Pb208_Th232_err), ...
	samples_Pb206_U238_age, samples_Pb206_U238_age_err, samples_Pb207_U235_age, samples_Pb207_U235_age_err, ...
	samples_Pb207_Pb206_age, samples_Pb207_Pb206_age_err, samples_Pb208_Th232_age, samples_Pb208_Th232_age_err, ...
	discordance_Pb206U238_Pb207Pb206, discordance_Pb206U238_Pb207U235, best_age, best_age_err];
%}






rhoA =((Pb206_U238_err.*Pb206_U238_err) + ...
	(Pb207_U235_err.*Pb207_U235_err)) - ...
	(Pb207_Pb206_err.*Pb207_Pb206_err);
rhoB =2.*(Pb206_U238_err.*Pb207_U235_err);
rho = rhoA./rhoB;


if rho < 0
	rho_corr = 0.7;
elseif rho > 1
	rho_corr = 0.7;
else
	rho_corr = rho;
end


concordia_data = [Pb207_Pb206,Pb207_Pb206_err, ...
	Pb207_U235,Pb207_U235_err,...
	Pb206_U238,Pb206_U238_err];

center=[concordia_data(name_idx,3),concordia_data(name_idx,5)];

sigx_abs = concordia_data(:,3).*concordia_data(:,4).*0.01;
sigy_abs = concordia_data(:,5).*concordia_data(:,6).*0.01;

sigx_sq = sigx_abs(name_idx,1).*sigx_abs(name_idx,1);
sigy_sq = sigy_abs(name_idx,1).*sigy_abs(name_idx,1);
rho_sigx_sigy = sigx_abs(name_idx,1).*sigy_abs(name_idx,1).*rho(name_idx,1);
sigmarule=1.5;
numpoints=50;


axes(H.axes_current_concordia)

covmat=[sigx_sq,rho_sigx_sigy;rho_sigx_sigy,sigy_sq];
[PD,PV]=eig(covmat);
PV=diag(PV).^.5;
theta=linspace(0,2.*pi,numpoints)';
elpt=[cos(theta),sin(theta)]*diag(PV)*PD';
numsigma=length(sigmarule);
elpt=repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt=elpt+repmat(center,numpoints,numsigma);
plot(elpt(:,1:2:end),elpt(:,2:2:end),'b','LineWidth',2);
hold on

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

xaxismin = Pb207_U235(name_idx,1) - 0.15.*Pb207_U235(name_idx,1);
xaxismax = Pb207_U235(name_idx,1) + 0.15.*Pb207_U235(name_idx,1);
yaxismin = Pb206_U238(name_idx,1) - 0.15.*Pb206_U238(name_idx,1);
yaxismax = Pb206_U238(name_idx,1) + 0.15.*Pb206_U238(name_idx,1);

Pb206_U238_age = 1/0.000000000155125.*log(1+Pb206_U238)/1000000;
Pb206_U238_age_err =abs((1/0.000000000155125.*log(1+Pb206_U238 ...
	-(Pb206_U238_err/100.*Pb206_U238))/1000000) ...
	-(1/0.000000000155125.*log(1+Pb206_U238 ...
	+(Pb206_U238_err/100.*Pb206_U238))/1000000))/2;

Pb207_Pb206_age = All_Pb206_U238_age(name_idx,1);
Pb207_Pb206_age_err = All_Pb206_U238_age_err(name_idx,1);

%Pb207_Pb206_age = newton_method(Pb207_Pb206(name_idx,1), 2000, .0000001);
%Pb207_Pb206_age_err = AgePb76Er5(Pb207_Pb206_age, Pb207_Pb206_err);


age_label_num = [100:50:5000];
for i=1:length(age_label_num)
age_label(i,1) = {sprintf('%.1f',age_label_num(1,i))};
age_label2(i,1) = strcat(age_label(i,1),' Ma');
end
age_label_num = age_label_num.*1000000;
age_label_x = exp(0.00000000098485.*age_label_num)-1;
age_label_y = exp(0.000000000155125.*age_label_num)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');


cutoff_76_68 = str2num(get(H.filter_transition_68_76,'String'));

age_label3_x = Pb207_U235(name_idx,1);
age_label3_y = Pb206_U238(name_idx,1);

if Pb206_U238_age < cutoff_76_68
    age_label3 = {Pb206_U238_age};
else
    age_label3 = {Pb207_Pb206_age};
end

if Pb206_U238_age < cutoff_76_68
    age_label4 = {Pb206_U238_age_err};
else
    age_label4 = {Pb207_Pb206_age_err};
end

scatter(age_label3_x, age_label3_y, 200,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
%labelpoints (age_label3_x, age_label3_y, age_label3, 'NW', .005,'FontSize', 25);

%age_plot = strcat(age_label3, ' +/- ', age_label4)
set(H.text139, 'String', age_label3); 
set(H.text141, 'String', age_label4); 



axis([xaxismin xaxismax yaxismin yaxismax]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');


% --- Executes on button press in example_txt.
function example_txt_Callback(hObject, eventdata, H)
% hObject    handle to example_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



function replace_bad_rho_Callback(hObject, eventdata, H)
% hObject    handle to replace_bad_rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of replace_bad_rho as text
%        str2double(get(hObject,'String')) returns contents of replace_bad_rho as a double


% --- Executes during object creation, after setting all properties.
function replace_bad_rho_CreateFcn(hObject, eventdata, H)
% hObject    handle to replace_bad_rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radio_errorprop_sliding.
function radio_errorprop_sliding_Callback(hObject, eventdata, H)
% hObject    handle to radio_errorprop_sliding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_errorprop_sliding


% --- Executes on button press in radio_errorprop_envelope.
function radio_errorprop_envelope_Callback(hObject, eventdata, H)
% hObject    handle to radio_errorprop_envelope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_errorprop_envelope


function ref_mat_primary_Callback(hObject, eventdata, H)
% hObject    handle to ref_mat_primary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref_mat_primary as text
%        str2double(get(hObject,'String')) returns contents of ref_mat_primary as a double


% --- Executes during object creation, after setting all properties.
function ref_mat_primary_CreateFcn(hObject, eventdata, H)
% hObject    handle to ref_mat_primary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref_mat_secondary_Callback(hObject, eventdata, H)
% hObject    handle to ref_mat_secondary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref_mat_secondary as text
%        str2double(get(hObject,'String')) returns contents of ref_mat_secondary as a double


% --- Executes during object creation, after setting all properties.
function ref_mat_secondary_CreateFcn(hObject, eventdata, H)
% hObject    handle to ref_mat_secondary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radio_intensities_log.
function radio_intensities_log_Callback(hObject, eventdata, H)
% hObject    handle to radio_intensities_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_intensities_log


% --- Executes on button press in radio_intensities_norm.
function radio_intensities_norm_Callback(hObject, eventdata, H)
% hObject    handle to radio_intensities_norm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_intensities_norm


% --- Executes on button press in radio_plot_fractionation.
function radio_plot_fractionation_Callback(hObject, eventdata, H)
% hObject    handle to radio_plot_fractionation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_plot_fractionation


% --- Executes on button press in radio_plot_ratios.
function radio_plot_ratios_Callback(hObject, eventdata, H)
% hObject    handle to radio_plot_ratios (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_plot_ratios


% --- Executes on button press in pushbutton59.
function pushbutton59_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton60.
function pushbutton60_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton61.
function pushbutton61_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton62.
function pushbutton62_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton63.
function pushbutton63_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



function outlier_cutoff_75_Callback(hObject, eventdata, H)
% hObject    handle to outlier_cutoff_75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outlier_cutoff_75 as text
%        str2double(get(hObject,'String')) returns contents of outlier_cutoff_75 as a double


% --- Executes during object creation, after setting all properties.
function outlier_cutoff_75_CreateFcn(hObject, eventdata, H)
% hObject    handle to outlier_cutoff_75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outlier_cutoff_82_Callback(hObject, eventdata, H)
% hObject    handle to outlier_cutoff_82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outlier_cutoff_82 as text
%        str2double(get(hObject,'String')) returns contents of outlier_cutoff_82 as a double


% --- Executes during object creation, after setting all properties.
function outlier_cutoff_82_CreateFcn(hObject, eventdata, H)
% hObject    handle to outlier_cutoff_82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function sliding_window_Callback(hObject, eventdata, H)
% hObject    handle to sliding_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sliding_window as text
%        str2double(get(hObject,'String')) returns contents of sliding_window as a double


% --- Executes during object creation, after setting all properties.
function sliding_window_CreateFcn(hObject, eventdata, H)
% hObject    handle to sliding_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diff_cutoff_68_Callback(hObject, eventdata, H)
% hObject    handle to diff_cutoff_68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diff_cutoff_68 as text
%        str2double(get(hObject,'String')) returns contents of diff_cutoff_68 as a double


% --- Executes during object creation, after setting all properties.
function diff_cutoff_68_CreateFcn(hObject, eventdata, H)
% hObject    handle to diff_cutoff_68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diff_cutoff_76_Callback(hObject, eventdata, H)
% hObject    handle to diff_cutoff_76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diff_cutoff_76 as text
%        str2double(get(hObject,'String')) returns contents of diff_cutoff_76 as a double


% --- Executes during object creation, after setting all properties.
function diff_cutoff_76_CreateFcn(hObject, eventdata, H)
% hObject    handle to diff_cutoff_76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diff_cutoff_75_Callback(hObject, eventdata, H)
% hObject    handle to diff_cutoff_75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diff_cutoff_75 as text
%        str2double(get(hObject,'String')) returns contents of diff_cutoff_75 as a double


% --- Executes during object creation, after setting all properties.
function diff_cutoff_75_CreateFcn(hObject, eventdata, H)
% hObject    handle to diff_cutoff_75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diff_cutoff_82_Callback(hObject, eventdata, H)
% hObject    handle to diff_cutoff_82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diff_cutoff_82 as text
%        str2double(get(hObject,'String')) returns contents of diff_cutoff_82 as a double


% --- Executes during object creation, after setting all properties.
function diff_cutoff_82_CreateFcn(hObject, eventdata, H)
% hObject    handle to diff_cutoff_82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end









function reject_poly_order_Callback(hObject, eventdata, H)
% hObject    handle to reject_poly_order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reject_poly_order as text
%        str2double(get(hObject,'String')) returns contents of reject_poly_order as a double


% --- Executes during object creation, after setting all properties.
function reject_poly_order_CreateFcn(hObject, eventdata, H)
% hObject    handle to reject_poly_order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function reject_spline_breaks_Callback(hObject, eventdata, H)
% hObject    handle to reject_spline_breaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reject_spline_breaks as text
%        str2double(get(hObject,'String')) returns contents of reject_spline_breaks as a double


% --- Executes during object creation, after setting all properties.
function reject_spline_breaks_CreateFcn(hObject, eventdata, H)
% hObject    handle to reject_spline_breaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton69.
function pushbutton69_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



function edit110_Callback(hObject, eventdata, H)
% hObject    handle to edit110 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit110 as text
%        str2double(get(hObject,'String')) returns contents of edit110 as a double


% --- Executes during object creation, after setting all properties.
function edit110_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit110 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit111_Callback(hObject, eventdata, H)
% hObject    handle to edit111 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit111 as text
%        str2double(get(hObject,'String')) returns contents of edit111 as a double


% --- Executes during object creation, after setting all properties.
function edit111_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit111 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit112_Callback(hObject, eventdata, H)
% hObject    handle to edit112 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit112 as text
%        str2double(get(hObject,'String')) returns contents of edit112 as a double


% --- Executes during object creation, after setting all properties.
function edit112_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit112 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit113_Callback(hObject, eventdata, H)
% hObject    handle to edit113 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit113 as text
%        str2double(get(hObject,'String')) returns contents of edit113 as a double


% --- Executes during object creation, after setting all properties.
function edit113_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit113 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit114_Callback(hObject, eventdata, H)
% hObject    handle to edit114 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit114 as text
%        str2double(get(hObject,'String')) returns contents of edit114 as a double


% --- Executes during object creation, after setting all properties.
function edit114_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit114 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit115_Callback(hObject, eventdata, H)
% hObject    handle to edit115 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit115 as text
%        str2double(get(hObject,'String')) returns contents of edit115 as a double


% --- Executes during object creation, after setting all properties.
function edit115_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit115 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton70.
function pushbutton70_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton71.
function pushbutton71_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



function edit116_Callback(hObject, eventdata, H)
% hObject    handle to edit116 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit116 as text
%        str2double(get(hObject,'String')) returns contents of edit116 as a double


% --- Executes during object creation, after setting all properties.
function edit116_CreateFcn(hObject, eventdata, H)
% hObject    handle to edit116 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton72.
function pushbutton72_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



function edit55_Callback(hObject, eventdata, H)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmin as text
%        str2double(get(hObject,'String')) returns contents of xmin as a double


% --- Executes during object creation, after setting all properties.
function edit55_CreateFcn(hObject, eventdata, H)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit57_Callback(hObject, eventdata, H)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmax as text
%        str2double(get(hObject,'String')) returns contents of xmax as a double


% --- Executes during object creation, after setting all properties.
function edit57_CreateFcn(hObject, eventdata, H)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit58_Callback(hObject, eventdata, H)
% hObject    handle to xint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xint as text
%        str2double(get(hObject,'String')) returns contents of xint as a double


% --- Executes during object creation, after setting all properties.
function edit58_CreateFcn(hObject, eventdata, H)
% hObject    handle to xint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit59_Callback(hObject, eventdata, H)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymin as text
%        str2double(get(hObject,'String')) returns contents of ymin as a double


% --- Executes during object creation, after setting all properties.
function edit59_CreateFcn(hObject, eventdata, H)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit60_Callback(hObject, eventdata, H)
% hObject    handle to h_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of h_ymax as text
%        str2double(get(hObject,'String')) returns contents of h_ymax as a double


% --- Executes during object creation, after setting all properties.
function edit60_CreateFcn(hObject, eventdata, H)
% hObject    handle to h_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit61_Callback(hObject, eventdata, H)
% hObject    handle to bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bins as text
%        str2double(get(hObject,'String')) returns contents of bins as a double


% --- Executes during object creation, after setting all properties.
function edit61_CreateFcn(hObject, eventdata, H)
% hObject    handle to bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton73.
function pushbutton73_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)


% --- Executes on button press in pushbutton74.
function pushbutton74_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton74 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



function Myr_Kernel_text_Callback(hObject, eventdata, H)
% hObject    handle to Myr_Kernel_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Myr_Kernel_text as text
%        str2double(get(hObject,'String')) returns contents of Myr_Kernel_text as a double


% --- Executes during object creation, after setting all properties.
function Myr_Kernel_text_CreateFcn(hObject, eventdata, H)
% hObject    handle to Myr_Kernel_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton76.
function pushbutton76_Callback(hObject, eventdata, H)
% hObject    handle to pushbutton76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)



function pval_Callback(hObject, eventdata, H)
% hObject    handle to pval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pval as text
%        str2double(get(hObject,'String')) returns contents of pval as a double


% --- Executes during object creation, after setting all properties.
function pval_CreateFcn(hObject, eventdata, H)
% hObject    handle to pval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes_current_concordia_CreateFcn(hObject, eventdata, H)
% hObject    handle to axes_current_concordia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    empty - H not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_current_concordia


% --- Executes on button press in standard_2_R33.
function standard_2_R33_Callback(hObject, eventdata, H)
% hObject    handle to standard_2_R33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% H    structure with H and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of standard_2_R33


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18


% --- Executes on button press in checkbox19.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox19


% --- Executes on button press in checkbox20.
function checkbox20_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox20


% --- Executes on button press in checkbox21.
function checkbox21_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox21


% --- Executes on button press in checkbox22.
function checkbox22_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox22


% --- Executes on button press in checkbox23.
function checkbox23_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox23


% --- Executes on button press in checkbox24.
function checkbox24_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox24


% --- Executes on button press in checkbox25.
function checkbox25_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox25



function filter_204_Callback(hObject, eventdata, handles)
% hObject    handle to filter_204 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_204 as text
%        str2double(get(hObject,'String')) returns contents of filter_204 as a double


% --- Executes during object creation, after setting all properties.
function filter_204_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_204 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function factor64_Callback(hObject, eventdata, handles)
% hObject    handle to factor64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of factor64 as text
%        str2double(get(hObject,'String')) returns contents of factor64 as a double


% --- Executes during object creation, after setting all properties.
function factor64_CreateFcn(hObject, eventdata, handles)
% hObject    handle to factor64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function reject68_Callback(hObject, eventdata, handles)
% hObject    handle to reject68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reject68 as text
%        str2double(get(hObject,'String')) returns contents of reject68 as a double


% --- Executes during object creation, after setting all properties.
function reject68_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reject68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function reject67_Callback(hObject, eventdata, handles)
% hObject    handle to reject67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reject67 as text
%        str2double(get(hObject,'String')) returns contents of reject67 as a double


% --- Executes during object creation, after setting all properties.
function reject67_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reject67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function reject75_Callback(hObject, eventdata, handles)
% hObject    handle to reject75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reject75 as text
%        str2double(get(hObject,'String')) returns contents of reject75 as a double


% --- Executes during object creation, after setting all properties.
function reject75_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reject75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function reject82_Callback(hObject, eventdata, handles)
% hObject    handle to reject82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reject82 as text
%        str2double(get(hObject,'String')) returns contents of reject82 as a double


% --- Executes during object creation, after setting all properties.
function reject82_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reject82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function h_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to h_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of h_ymin as text
%        str2double(get(hObject,'String')) returns contents of h_ymin as a double


% --- Executes during object creation, after setting all properties.
function h_ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to h_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit150_Callback(hObject, eventdata, handles)
% hObject    handle to xint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xint as text
%        str2double(get(hObject,'String')) returns contents of xint as a double


% --- Executes during object creation, after setting all properties.
function edit150_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit151_Callback(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmin as text
%        str2double(get(hObject,'String')) returns contents of xmin as a double


% --- Executes during object creation, after setting all properties.
function edit151_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit152_Callback(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmax as text
%        str2double(get(hObject,'String')) returns contents of xmax as a double


% --- Executes during object creation, after setting all properties.
function edit152_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit153_Callback(hObject, eventdata, handles)
% hObject    handle to bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bins as text
%        str2double(get(hObject,'String')) returns contents of bins as a double


% --- Executes during object creation, after setting all properties.
function edit153_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function optimize_Callback(hObject, eventdata, H)

set(H.optimize, 'Value', 1);
set(H.Myr_kernel, 'Value', 0);

function Myr_kernel_Callback(hObject, eventdata, H)

set(H.Myr_kernel, 'Value', 1);
set(H.optimize, 'Value', 0);

function edit154_Callback(hObject, eventdata, handles)
% hObject    handle to Myr_Kernel_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Myr_Kernel_text as text
%        str2double(get(hObject,'String')) returns contents of Myr_Kernel_text as a double


% --- Executes during object creation, after setting all properties.
function edit154_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Myr_Kernel_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in export_plot.
function pushbutton81_Callback(hObject, eventdata, handles)
% hObject    handle to export_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radio_pdp.
function checkbox46_Callback(hObject, eventdata, handles)
% hObject    handle to radio_pdp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_pdp


function all_unk_Callback(hObject, eventdata, H)
sample = H.sample;
Data_All = H.Data_All;
Ablate = H.Ablate;
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
current_status = H.current_status;
current_status_num = H.current_status_num;
current_status_num_orig = H.current_status_num_orig;
comment = H.comment;
INT = H.INT;

name_idx = get(H.listbox1,'Value');

for i=1:length(sample)
name_char(i,1)=(sample(i,1));
end




if current_status_num(name_idx,1) == 1 && current_status_num_orig(name_idx,1) == 1 
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');

elseif current_status_num(name_idx,1) == 0 && current_status_num_orig(name_idx,1) == 0 
%current_status{name_idx, 1} = comment{name_idx,1};
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');

elseif current_status_num(name_idx,1) == 1 && current_status_num_orig(name_idx,1) == 0 
current_status{name_idx, 1} = strcat({'Accepted with '}, comment{name_idx,1});
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');

elseif current_status_num(name_idx,1) == 0 && current_status_num_orig(name_idx,1) == 1 
current_status{name_idx, 1} = {'Rejected, but originally was accepted'};
set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');

end





axes(H.axes_current_concordia);
cla(H.axes_current_concordia,'reset');
set(H.axes_current_concordia,'FontSize',8);
%set(H.axes_current_concordia,'String',sample{name_idx,1});
%p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
%hold on
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});

if get(H.all_unk, 'Value') == 0

concordia_data = [ratio75(name_idx,1), ratio75_err(name_idx,1), ratio68(name_idx,1), err68m(name_idx,1)];
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

%set(H.age_int_05, 'Value', 0);
%set(H.age_int_1, 'Value', 0);
%set(H.age_int_2, 'Value', 0);
%set(H.age_int_5, 'Value', 0);
%set(H.age_int_10, 'Value', 0);
%set(H.age_int_25, 'Value', 0);
%set(H.age_int_50, 'Value', 0);
%set(H.age_int_100, 'Value', 0);

if diff_avg > 0.5 && diff_avg < 2
%set(H.age_int_05, 'Value', 1);
timeinterval = 500000;
elseif diff_avg > 2 && diff_avg < 5
%set(H.age_int_1, 'Value', 1);
timeinterval = 1000000;
elseif diff_avg > 5 && diff_avg < 10
%set(H.age_int_2, 'Value', 1);
timeinterval = 2000000;
elseif diff_avg > 10 && diff_avg < 20
%set(H.age_int_5, 'Value', 1);
timeinterval = 5000000;
elseif diff_avg > 20 && diff_avg < 50
%set(H.age_int_10, 'Value', 1);
timeinterval = 10000000;
elseif diff_avg > 50 && diff_avg < 100
%set(H.age_int_25, 'Value', 1);
timeinterval = 25000000;
elseif diff_avg > 100 && diff_avg < 200
%set(H.age_int_50, 'Value', 1);
timeinterval = 50000000;
elseif diff_avg > 200
%set(H.age_int_100, 'Value', 1);
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
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);



p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
hold on

if get(H.leg_on,'Value')==1
	legend(p3, bestage,  'Location', 'northwest');
end

guidata(hObject,H);

end




if get(H.all_unk, 'Value') == 1
	
cla(H.axes_current_concordia,'reset');
axes(H.axes_current_concordia);

sigx_sq_All = H.sigx_sq_All;
rho_sigx_sigy_All = H.rho_sigx_sigy_All;
sigy_sq_All = H.sigy_sq_All;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
center_All = H.center_All;
sample_idx = H.sample_idx;
current_status_num = H.current_status_num;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;


for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = plot(elpt_out_acc(:,1:2:end,i),elpt_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
		hold on
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = plot(elpt_out_rej(:,1:2:end,i),elpt_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
	end
end

plot(x,y,'k','LineWidth',1.4)
hold on

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

for i = 1:length(time4)
if x4(i,1) > min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 && x4(i,1) < max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	&& y4(i,1) > min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 && y4(i,1) < max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

axis([min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01]);
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);


p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

%legend(p3, bestage,  'Location', 'northwest');
accan= 'Accepted Analyses';
rejan = 'Rejected Analyses';

if get(H.leg_on,'Value')==1
	legend([p1 p2 p3], [accan, rejan, bestage], 'Location','northwest');
end

end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in primary.
function primary_Callback(hObject, eventdata, handles)
% hObject    handle to primary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns primary contents as cell array
%        contents{get(hObject,'Value')} returns selected item from primary


% --- Executes during object creation, after setting all properties.
function primary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to primary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in secondary.
function secondary_Callback(hObject, eventdata, handles)
% hObject    handle to secondary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns secondary contents as cell array
%        contents{get(hObject,'Value')} returns selected item from secondary


% --- Executes during object creation, after setting all properties.
function secondary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to secondary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in All_Primary_STDs.
function All_Primary_STDs_Callback(hObject, eventdata, handles)
% hObject    handle to All_Primary_STDs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of All_Primary_STDs


% --- Executes on button press in All_Unknowns.
function All_Unknowns_Callback(hObject, eventdata, handles)
% hObject    handle to All_Unknowns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of All_Unknowns


% --- Executes on button press in All_Secondary_STDs.
function All_Secondary_STDs_Callback(hObject, eventdata, handles)
% hObject    handle to All_Secondary_STDs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of All_Secondary_STDs





% --- Executes on button press in pushbutton108.
function pushbutton108_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton108 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton109.
function pushbutton109_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton109 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton110.
function pushbutton110_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton110 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function leg_on_session_Callback(hObject, eventdata, H)
if get(H.ptype_Primary_STDs, 'Value') == 1
	ptype_Primary_STDs_Callback(hObject, eventdata, H);
end
if get(H.ptype_Secondary_STDs, 'Value') == 1
	ptype_Secondary_STDs_Callback(hObject, eventdata, H);
end
if get(H.ptype_Unknowns, 'Value') == 1
	ptype_Unknowns_Callback(hObject, eventdata, H);
end
if get(H.ptype_Unknowns_acc, 'Value') == 1
	ptype_Unknowns_acc_Callback(hObject, eventdata, H);
end
if get(H.ptype_Unknowns_rej, 'Value') == 1
	ptype_Unknowns_rej_Callback(hObject, eventdata, H);
end
if get(H.DHF_primary, 'Value') == 1
	DHF_primary_Callback(hObject, eventdata, H);
end
if get(H.DHF_unknown, 'Value') == 1
	DHF_unknown_Callback(hObject, eventdata, H);
end
if get(H.age_uconc, 'Value') == 1
	age_uconc_Callback(hObject, eventdata, H);
end
if get(H.age_raddos, 'Value') == 1
	age_raddos_Callback(hObject, eventdata, H);
end
if get(H.age_uth, 'Value') == 1
	age_uth_Callback(hObject, eventdata, H);
end
if get(H.age_concodance, 'Value') == 1
	age_concodance_Callback(hObject, eventdata, H);
end


function ptype_Primary_STDs_Callback(hObject, eventdata, H)
set(H.ptype_Primary_STDs, 'Value', 1)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
set(H.DHF_primary, 'Value', 0)
set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)

sigx_sq_STD1 = H.sigx_sq_STD1;
rho_sigx_sigy_STD1 = H.rho_sigx_sigy_STD1;
sigy_sq_STD1 = H.sigy_sq_STD1;
sigmarule = H.sigmarule;
numpoints = H.numpoints;
center_STD1 = H.center_STD1;
STD1_68 = H.STD1_68;
STD1_67 = H.STD1_67;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;

%Primary standard
cla(H.axes_session,'reset');
axes(H.axes_session);
set(H.axes_session,'FontSize',8);
%set(H.primary_reference,'String',STD1);

for i = 1:length(sigx_sq_STD1)
covmat_STD1=[sigx_sq_STD1(i,1),rho_sigx_sigy_STD1(i,1);rho_sigx_sigy_STD1(i,1),sigy_sq_STD1(i,1)];
[PD_STD1,PV_STD1]=eig(covmat_STD1);
PV_STD1 = diag(PV_STD1).^.5;
theta_STD1 = linspace(0,2.*pi,numpoints)';
elpt_STD1 = [cos(theta_STD1),sin(theta_STD1)]*diag(PV_STD1)*PD_STD1';
numsigma = length(sigmarule);
elpt_STD1 = repmat(elpt_STD1,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt_STD1_out(:,:,i) = elpt_STD1 + repmat(center_STD1(i,1:2),numpoints,numsigma);
p1 = plot(elpt_STD1_out(:,1:2:end,i),elpt_STD1_out(:,2:2:end,i),'b','LineWidth',1.2);
hold on
end

%age_label2_x = 0.742701185586296;
age_label2_x = STD1_68*(1/STD1_67)*137.88;
%age_label2_y = 0.0912660713153783;
age_label2_y = STD1_68;

if get(H.primary, 'Value') == 1
	age_label2 = {'564 Ma'};
end

plot(xc,yc,'k','LineWidth',1.4)
hold on
p1 = scatter(age_label2_x, age_label2_y,50,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
labelpoints (age_label2_x, age_label2_y, age_label2, 'SE', .002);

axis([min(min(elpt_STD1_out(:,1,:))) - min(min(elpt_STD1_out(:,1,:)))*.01 max(max(elpt_STD1_out(:,1,:))) + max(max(elpt_STD1_out(:,1,:)))*.01 ...
	min(min(elpt_STD1_out(:,2,:))) - min(min(elpt_STD1_out(:,2,:)))*.01 max(max(elpt_STD1_out(:,2,:))) + max(max(elpt_STD1_out(:,2,:)))*.01]);
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);

if get(H.leg_on_session,'Value') == 1
	legend(p1,'Accepted Age','Location','northwest');
else
	legend('hide')
end





function ptype_Secondary_STDs_Callback(hObject, eventdata, H)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 1)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
set(H.DHF_primary, 'Value', 0)
set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)

sigx_sq_STD2 = H.sigx_sq_STD2;
rho_sigx_sigy_STD2 = H.rho_sigx_sigy_STD2;
rho_sigx_sigy_STD2 = H.rho_sigx_sigy_STD2;
sigy_sq_STD2 = H.sigy_sq_STD2;
sigmarule = H.sigmarule;
numpoints = H.numpoints;
center_STD2 = H.center_STD2;
STD2_68 = H.STD2_68;
STD2_67 = H.STD2_67;
STD2_idx = H.STD2_idx;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;

if sum(STD2_idx) > 1
cla(H.axes_session,'reset');
axes(H.axes_session);
set(H.axes_session,'FontSize',8);
%set(H.secondary_reference,'String',STD2);

for i = 1:length(sigx_sq_STD2)
covmat_STD2=[sigx_sq_STD2(i,1),rho_sigx_sigy_STD2(i,1);rho_sigx_sigy_STD2(i,1),sigy_sq_STD2(i,1)];
[PD_STD2,PV_STD2]=eig(covmat_STD2);
PV_STD2 = diag(PV_STD2).^.5;
theta_STD2 = linspace(0,2.*pi,numpoints)';
elpt_STD2 = [cos(theta_STD2),sin(theta_STD2)]*diag(PV_STD2)*PD_STD2';
numsigma = length(sigmarule);
elpt_STD2 = repmat(elpt_STD2,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt_STD2_out(:,:,i) = elpt_STD2 + repmat(center_STD2(i,1:2),numpoints,numsigma);
plot(elpt_STD2_out(:,1:2:end,i),elpt_STD2_out(:,2:2:end,i),'b','LineWidth',1.2);
hold on
end

age_label3_x = 0.511;
age_label3_y = 0.0671;
age_label3 = {'419 Ma'};

plot(xc,yc,'k','LineWidth',1.4)
hold on
p2 = scatter(age_label3_x, age_label3_y,40,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
labelpoints (age_label3_x, age_label3_y, age_label3, 'SE', .002);

axis([min(min(elpt_STD2_out(:,1,:))) - min(min(elpt_STD2_out(:,1,:)))*.01 max(max(elpt_STD2_out(:,1,:))) + max(max(elpt_STD2_out(:,1,:)))*.01 ...
	min(min(elpt_STD2_out(:,2,:))) - min(min(elpt_STD2_out(:,2,:)))*.01 max(max(elpt_STD2_out(:,2,:))) + max(max(elpt_STD2_out(:,2,:)))*.01]);
xlabel('207Pb/235U', 'FontSize', 8);
ylabel('206Pb/238U', 'FontSize', 8);
end

if get(H.leg_on_session,'Value') == 1
	legend([p2],'Accepted age','Location','northwest');
else
	legend('hide')
end

function ptype_Unknowns_acc_Callback(hObject, eventdata, H)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 1)
set(H.ptype_Unknowns_rej, 'Value', 0)
set(H.DHF_primary, 'Value', 0)
set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)

sample = H.sample;
Data_All = H.Data_All;
Ablate = H.Ablate;
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
current_status = H.current_status;
current_status_num = H.current_status_num;
current_status_num_orig = H.current_status_num_orig;
comment = H.comment;
INT = H.INT;

name_idx = get(H.listbox1, 'Value');

axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);
hold on

sigx_sq_All = H.sigx_sq_All;
rho_sigx_sigy_All = H.rho_sigx_sigy_All;
sigy_sq_All = H.sigy_sq_All;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
center_All = H.center_All;
sample_idx = H.sample_idx;
current_status_num = H.current_status_num;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = plot(elpt_out_acc(:,1:2:end,i),elpt_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = [];
	end
end

plot(x,y,'k','LineWidth',1.4)

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

for i = 1:length(time4)
if x4(i,1) > min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 && x4(i,1) < max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	&& y4(i,1) > min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 && y4(i,1) < max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

axis([min(min(nonzeros(elpt_out_acc(:,1,:)))) - min(min(nonzeros(elpt_out_acc(:,1,:))))*.01 max(max(nonzeros(elpt_out_acc(:,1,:)))) + max(max(nonzeros(elpt_out_acc(:,1,:))))*.01 ...
	min(min(nonzeros(elpt_out_acc(:,2,:)))) - min(min(nonzeros(elpt_out_acc(:,2,:))))*.01 max(max(nonzeros(elpt_out_acc(:,2,:)))) + max(max(nonzeros(elpt_out_acc(:,2,:))))*.01]);
xlabel('207Pb/235U', 'FontSize', 10);
ylabel('206Pb/238U', 'FontSize', 10);

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

accan= {'Accepted Analyses'};

if get(H.leg_on_session,'Value') == 1	
	legend([p1 p3], [accan, sample(name_idx)], 'Location','northwest');
else
	legend('hide')
end

H.p1 = p1;
H.p2 = p2;
H.p3 = p3;
guidata(hObject,H);


function age_uconc_Callback(hObject, eventdata, H)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
set(H.DHF_primary, 'Value', 0)
set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 1)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)

Macro_1_2_Output = H.Macro_1_2_Output;

for i = 1:length(Macro_1_2_Output(:,1))
	if sum(size(cell2mat(Macro_1_2_Output(i,37)))) > 0 
		uconc(i,1) = cell2num(Macro_1_2_Output(i,51));
		bestage(i,1) = cell2num(Macro_1_2_Output(i,37));
	end
end

uconc(~isfinite(uconc))=0;
bestage(~isfinite(bestage))=0;

uconc = nonzeros(uconc);
bestage = nonzeros(bestage);

axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);

s1 = scatter(uconc, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('U ppm')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','northeast');
else
	legend('hide')
end


function age_raddos_Callback(hObject, eventdata, H)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
set(H.DHF_primary, 'Value', 0)
set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 1)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)

Macro_1_2_Output = H.Macro_1_2_Output;

for i = 1:length(Macro_1_2_Output(:,1))
	if sum(size(cell2mat(Macro_1_2_Output(i,37)))) > 0 
		u(i,1) = cell2num(Macro_1_2_Output(i,51));
		th(i,1) = cell2num(Macro_1_2_Output(i,52));
		bestage(i,1) = cell2num(Macro_1_2_Output(i,37));
	end
end

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

axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);

s1 = scatter(raddos, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('Radiation Dosage (alpha decays/µg)')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','southeast');
else
	legend('hide')
end












function age_uth_Callback(hObject, eventdata, H)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
set(H.DHF_primary, 'Value', 0)
set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 1)
set(H.age_concodance, 'Value', 0)

Macro_1_2_Output = H.Macro_1_2_Output;

for i = 1:length(Macro_1_2_Output(:,1))
	if sum(size(cell2mat(Macro_1_2_Output(i,37)))) > 0 
		uth(i,1) = cell2num(Macro_1_2_Output(i,55));
		bestage(i,1) = cell2num(Macro_1_2_Output(i,37));
	end
end

uth(~isfinite(uth))=0;
bestage(~isfinite(bestage))=0;

uth = nonzeros(uth);
bestage = nonzeros(bestage);

axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);

s1 = scatter(uth, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('U/Th')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','northeast');
else
	legend('hide')
end



function age_concodance_Callback(hObject, eventdata, H)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
set(H.DHF_primary, 'Value', 0)
set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 1)

Macro_1_2_Output = H.Macro_1_2_Output;

for i = 1:length(Macro_1_2_Output(:,1))
	if sum(size(cell2mat(Macro_1_2_Output(i,37)))) > 0 
		age68(i,1) = cell2num(Macro_1_2_Output(i,33));
		age67(i,1) = cell2num(Macro_1_2_Output(i,35));
		bestage(i,1) = cell2num(Macro_1_2_Output(i,37));
	end
end

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



axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);

s1 = scatter(concordance, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('Concordance (%)')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','northwest');
else
	legend('hide')
end




function Export_Plot_Callback(hObject, eventdata, handles)










% --- Executes on button press in DHF_primary.
function DHF_primary_Callback(hObject, eventdata, H)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
set(H.DHF_primary, 'Value', 1)
set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)

Data_All = H.Data_All;
STD1_idx = H.STD1_idx;
Ablate = H.Ablate;

for i = 1:length(Data_All(1,1,:))
	values3(:,:,i) = Data_All(:,:,i).*80000000;
end
values3(:,8,:) = values3(:,5,:)./values3(:,1,:);
values3(:,9,:) = values3(:,5,:)./values3(:,4,:);
values3(:,10,:) = values3(:,3,:)./values3(:,2,:);

axes(H.axes_session);
cla(H.axes_session,'reset');
hold on

for i = 1:length(values3(1,1,:))
	if STD1_idx(i,1) == 1
		q3 = plot(Ablate,values3(:,8,i),'linewidth', 1,'color','k');
	end
end

hold off
xlim([1 max(Ablate)])

stdan= {'Primary Standard Analyses'};


if get(H.leg_on_session,'Value') == 1	
	legend([q3], [stdan], 'Location','northwest');
else
	legend('hide')
end



% --- Executes during object creation, after setting all properties.
function reject_no_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reject_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in reject_no.
function reject_no_Callback(hObject, eventdata, handles)
% hObject    handle to reject_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of reject_no


% --- Executes on button press in DHF_unknown.
function DHF_unknown_Callback(hObject, eventdata, H)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
set(H.DHF_primary, 'Value', 0)
set(H.DHF_unknown, 'Value', 1)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)

Data_All = H.Data_All;
sample_idx = H.sample_idx;
Ablate = H.Ablate;
current_status_num = H.current_status_num;

for i = 1:length(Data_All(1,1,:))
	values3(:,:,i) = Data_All(:,:,i).*80000000;
end
values3(:,8,:) = values3(:,5,:)./values3(:,1,:);
values3(:,9,:) = values3(:,5,:)./values3(:,4,:);
values3(:,10,:) = values3(:,3,:)./values3(:,2,:);

axes(H.axes_session);
cla(H.axes_session,'reset');
hold on

for i = 1:length(values3(1,1,:))
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		q1 = plot(Ablate,values3(:,8,i),'linewidth', 1,'color','b');
	end
end

for i = 1:length(values3(1,1,:))
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		q2 = plot(Ablate,values3(:,8,i),'linewidth', 1,'color','r');
	end
end

hold off
xlim([1 max(Ablate)])

accan= {'Accepted Analyses'};
rejan = {'Rejected Analyses'};

if get(H.leg_on_session,'Value') == 1	
	legend([q1 q2], [accan, rejan], 'Location','northwest');
else
	legend('hide')
end


function ptype_Unknowns_rej_Callback(hObject, eventdata, H)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 1)
set(H.DHF_primary, 'Value', 0)
set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)

sample = H.sample;
Data_All = H.Data_All;
Ablate = H.Ablate;
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
current_status = H.current_status;
current_status_num = H.current_status_num;
current_status_num_orig = H.current_status_num_orig;
comment = H.comment;
INT = H.INT;

name_idx = get(H.listbox1, 'Value');

axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);
hold on

sigx_sq_All = H.sigx_sq_All;
rho_sigx_sigy_All = H.rho_sigx_sigy_All;
sigy_sq_All = H.sigy_sq_All;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
center_All = H.center_All;
sample_idx = H.sample_idx;
current_status_num = H.current_status_num;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = [];
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = plot(elpt_out_rej(:,1:2:end,i),elpt_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
	end
end

plot(x,y,'k','LineWidth',1.4)

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

for i = 1:length(time4)
if x4(i,1) > min(min(nonzeros(elpt_out_rej(:,1,:)))) - min(min(nonzeros(elpt_out_rej(:,1,:))))*.01 && x4(i,1) < max(max(nonzeros(elpt_out_rej(:,1,:)))) + max(max(nonzeros(elpt_out_rej(:,1,:))))*.01 ...
	&& y4(i,1) > min(min(nonzeros(elpt_out_rej(:,2,:)))) - min(min(nonzeros(elpt_out_rej(:,2,:))))*.01 && y4(i,1) < max(max(nonzeros(elpt_out_rej(:,2,:)))) + max(max(nonzeros(elpt_out_rej(:,2,:))))*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

axis([min(min(nonzeros(elpt_out_rej(:,1,:)))) - min(min(nonzeros(elpt_out_rej(:,1,:))))*.01 max(max(nonzeros(elpt_out_rej(:,1,:)))) + max(max(nonzeros(elpt_out_rej(:,1,:))))*.01 ...
	min(min(nonzeros(elpt_out_rej(:,2,:)))) - min(min(nonzeros(elpt_out_rej(:,2,:))))*.01 max(max(nonzeros(elpt_out_rej(:,2,:)))) + max(max(nonzeros(elpt_out_rej(:,2,:))))*.01]);
xlabel('207Pb/235U', 'FontSize', 10);
ylabel('206Pb/238U', 'FontSize', 10);

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

accan= {'Accepted Analyses'};
rejan = {'Rejected Analyses'};

%legend([p1 p2], [accan, rejan], 'Location','northwest');

if get(H.leg_on_session,'Value') == 1	
	legend([p2 p3], [rejan, sample(name_idx)], 'Location','northwest');
else
	legend('hide')
end

H.p1 = p1;
H.p2 = p2;
H.p3 = p3;
guidata(hObject,H);





function ptype_Unknowns_Callback(hObject, eventdata, H)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 1)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
set(H.DHF_primary, 'Value', 0)
set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)

sample = H.sample;
Data_All = H.Data_All;
Ablate = H.Ablate;
ratio75 = H.ratio75;
ratio75_err = H.ratio75_err;
ratio68 = H.ratio68;
err68m = H.err68m;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho = H.rho;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
xc = H.xc;
yc = H.yc;
current_status = H.current_status;
current_status_num = H.current_status_num;
current_status_num_orig = H.current_status_num_orig;
comment = H.comment;
INT = H.INT;

name_idx = get(H.listbox1, 'Value');

axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'FontSize',8);
hold on

sigx_sq_All = H.sigx_sq_All;
rho_sigx_sigy_All = H.rho_sigx_sigy_All;
sigy_sq_All = H.sigy_sq_All;
numpoints = H.numpoints;
sigmarule = H.sigmarule;
center_All = H.center_All;
sample_idx = H.sample_idx;
current_status_num = H.current_status_num;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

for i = 1:length(sigx_sq_All)
		covmat=[sigx_sq_All(i,1),rho_sigx_sigy_All(i,1);rho_sigx_sigy_All(i,1),sigy_sq_All(i,1)];
		[PD,PV]=eig(covmat);
		PV = diag(PV).^.5;
		theta = linspace(0,2.*pi,numpoints)';
		elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma = length(sigmarule);
		elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
	if sample_idx(i,1) == 1 && current_status_num(i,1) == 1
		elpt_out_acc(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p1 = plot(elpt_out_acc(:,1:2:end,i),elpt_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
	elseif sample_idx(i,1) == 1 && current_status_num(i,1) == 0
		elpt_out_rej(:,:,i) = elpt + repmat(center_All(i,1:2),numpoints,numsigma);
		p2 = plot(elpt_out_rej(:,1:2:end,i),elpt_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
	end
end

plot(x,y,'k','LineWidth',1.4)

time4 = [500000000, 1000000000, 1500000000, 2000000000, 2500000000, 3000000000, 3500000000, 4000000000];
x4 = (exp(0.00000000098485.*time4)-1)';
y4 = (exp(0.000000000155125.*time4)-1)';

for i=1:length(x4)
age_label4(i,1) = {sprintf('%.0f',time4(1,i)/1000000)};
end

elpt_min1 = min([min(min(nonzeros(elpt_out_acc(:,1,:)))),min(min(nonzeros(elpt_out_rej(:,1,:))))]);
elpt_max1 = max([max(max(elpt_out_acc(:,1,:))),max(max(elpt_out_rej(:,1,:)))]);
elpt_min2 = min([min(min(nonzeros(elpt_out_acc(:,2,:)))),min(min(nonzeros(elpt_out_rej(:,2,:))))]);
elpt_max2 = max([max(max(elpt_out_acc(:,2,:))),max(max(elpt_out_rej(:,2,:)))]);

for i = 1:length(time4)
if x4(i,1) > elpt_min1 - elpt_min1*.01 && x4(i,1) < elpt_max1 +elpt_max1*.01 ...
	&& y4(i,1) > elpt_min2 - elpt_min2*.01 && y4(i,1) < elpt_max2 + elpt_max2*.01
scatter(x4(i,1), y4(i,1),20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(x4(i,1), y4(i,1), age_label4(i,1), 'SE', .0002);
end
end

axis([elpt_min1 - elpt_min1*.01 elpt_max1 + elpt_max1*.01 ...
	elpt_min2 - elpt_min2*.01 elpt_max2 + elpt_max2*.01]);
xlabel('207Pb/235U', 'FontSize', 10);
ylabel('206Pb/238U', 'FontSize', 10);

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

accan= {'Accepted Analyses'};
rejan = {'Rejected Analyses'};

%legend([p1 p2], [accan, rejan], 'Location','northwest');

if get(H.leg_on_session,'Value') == 1	
	legend([p1 p2 p3], [accan, rejan, sample(name_idx)], 'Location','northwest');
else
	legend('hide')
end

H.p1 = p1;
H.p2 = p2;
H.p3 = p3;
guidata(hObject,H);








function listbox4_Callback(hObject, eventdata, H)

name_char_std = H.name_char_std;
sc = H.sc;
STD1_num = H.STD1_num;
ff68_num = H.ff68_num;

value = get(H.listbox4, 'Value');

axes(H.axes_session_fractionation);

set(sc,'Visible','off')
clear sc



hold on

sc = scatter(STD1_num(value,1), ff68_num(value,1), 175, 'o', 'MarkerEdgeColor', 'b');

hold off

H.sc = sc;
guidata(hObject,H);


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton128.
function pushbutton128_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton128 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function SSB_SelectionChangedFcn(hObject, eventdata, H)

rad_on=get(H.uipanel_reject,'selectedobject');
switch rad_on
    case H.reject_yes
		set(H.pc_1, 'Enable', 'on'); set(H.pc_2, 'Enable', 'on'); set(H.pc_3, 'Enable', 'on'); set(H.pc_4, 'Enable', 'on'); set(H.pc_5, 'Enable', 'on');
		set(H.pc_6, 'Enable', 'on'); set(H.pc_7, 'Enable', 'on'); set(H.reject68, 'Enable', 'on'); set(H.reject67, 'Enable', 'on'); set(H.reject82, 'Enable', 'on'); 
		set(H.standards_rejected, 'Enable', 'on');
	case H.reject_no
		set(H.pc_1, 'Enable', 'off'); set(H.pc_2, 'Enable', 'off'); set(H.pc_3, 'Enable', 'off'); set(H.pc_4, 'Enable', 'off'); set(H.pc_5, 'Enable', 'off');
		set(H.pc_6, 'Enable', 'off'); set(H.pc_7, 'Enable', 'off'); set(H.reject68, 'Enable', 'off'); set(H.reject67, 'Enable', 'off'); set(H.reject82, 'Enable', 'off'); 
		set(H.standards_rejected, 'Enable', 'off');
end





% --- Executes on button press in pushbutton129.
function pushbutton129_Callback(hObject, eventdata, H)


figure(get(H.axes_session))


function savesession_Callback(hObject, eventdata, H)
H
save( 'someFile.mat', 'H' )


% --- Executes on button press in loadsession.
function loadsession_Callback(hObject, eventdata, handles)
% hObject    handle to loadsession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function savesesh_Callback(hObject, eventdata, H)
[file,path] = uiputfile('*.mat','Save file');
save([path file],'H')

function loadsesh_Callback(hObject, eventdata, H)
[filename pathname] = uigetfile({'*'},'File Selector','MultiSelect','on');
fullpathname = strcat(pathname, filename);
load(fullpathname,'H')
close(NuAgeCalcML_1_6)


% --- Executes during object creation, after setting all properties.
function SE67_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SE67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function SE68_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SE68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in commonpbcorr.
function commonpbcorr_Callback(hObject, eventdata, handles)
% hObject    handle to commonpbcorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of commonpbcorr
