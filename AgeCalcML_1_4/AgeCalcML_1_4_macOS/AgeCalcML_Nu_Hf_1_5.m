function varargout = AgeCalcML_Nu_Hf_1_5(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AgeCalcML_Nu_Hf_1_5_OpeningFcn, ...
                   'gui_OutputFcn',  @AgeCalcML_Nu_Hf_1_5_OutputFcn, ...
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

function AgeCalcML_Nu_Hf_1_5_OpeningFcn(hObject, eventdata, H, varargin)
%imshow('splash.png', 'Parent', H.axes7);
H.output = hObject;
guidata(hObject, H);

function varargout = AgeCalcML_Nu_Hf_1_5_OutputFcn(hObject, eventdata, H) 
H.reduced = 0;
guidata(hObject,H);
varargout{1} = H.output;

%% Set Directory Button %%
function browser_Callback(hObject, eventdata, H)
cla(H.STDS_plot,'reset'); 
cla(H.SingleAnalysis_plot,'reset'); 
cla(H.Results_plot,'reset'); 

folder_name = uigetdir; %prompt browser and select folder

set(H.text1, 'String', folder_name); %show path name

H.folder_name = folder_name;
guidata(hObject,H);

%% CHECKBOX Auto Reduce %%
function auto_reduce_Callback(hObject, eventdata, H)
	
if get(H.auto_reduce,'Value') == 1
	set(H.reduce_data,'Enable','off')
	t = timer;
	set(t, 'ExecutionMode', 'fixedrate');
	set(t, 'Period', str2num(get(H.seconds,'String')));
	t.TimerFcn = @(~,~) reduce_data_Callback(hObject, eventdata, H);
	start(t)
end

if get(H.auto_reduce,'Value') == 0
	set(H.reduce_data,'Enable','on');
	t = H.t;
	delete(t)
end

H.t = t;
guidata(hObject,H);

%% Reduce Data %%
function reduce_data_Callback(hObject, eventdata, H)
folder_name = H.folder_name;

files=dir([folder_name]); %this maps out the directory to that folder

for i = 1:size(files,1)
	filenames{i,1} = files(i).name;
	filedates{i,1} = files(i).date;
end

for i = 1:size(filenames,1)
	if strcmp(filenames(i,1),'.') == 1
		filenames{i,1} = [];
		filedates{i,1} = [];
	elseif strcmp(filenames(i,1),'..') == 1
		filenames{i,1} = [];
		filedates{i,1} = [];
	end
end

filenames(all(cellfun('isempty',filenames),2),:) = [];
%filedates(all(cellfun('isempty',filedates),2),:) = [];

%DateNumber = datenum(filedates);

%[DateNumber_sorted, DateNumber_order] = sort(DateNumber);
%filenames_sorted = filenames(DateNumber_order,:);
filenames_sorted = filenames;

Agefile = 0;
for i = 1:size(filenames_sorted,1)
	if isempty(findstr(char(filenames_sorted(i,1)), '.txt')) == 0
		filename_data{i,1} = filenames_sorted(i,1);
	elseif isempty(findstr(char(filenames_sorted(i,1)), '.xls')) == 0
		filename_ages{i,1} = filenames_sorted(i,1);
		Agefile = 1;
	elseif isempty(findstr(char(filenames_sorted(i,1)), '.xlsx')) == 0
		filename_ages{i,1} = filenames_sorted(i,1);
		Agefile = 1;
	elseif isempty(findstr(char(filenames_sorted(i,1)), '.csv')) == 0
		filename_ages{i,1} = filenames_sorted(i,1);
		Agefile = 1;
	end
end

filename_data(all(cellfun('isempty',filename_data),2),:) = [];

h = waitbar(0,'Reducing data. Please wait...');

for i = 1:length(filename_data)

	fullpathname = char(strcat(folder_name, '/', filename_data{i,1}));

	Data = importdata(fullpathname,',',500000);

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

	for j = 1:length(data_parse(:,1))
		if data_parse(j,1) == 1 && data_parse(j+60+1,1) == 2
			sample_start_idx(j,1) = j;
			sample_end_idx(j,1) = j+60+1;
		end
	end

	sample_start_idx = nonzeros(sample_start_idx);
	sample_end_idx = nonzeros(sample_end_idx);

	data_count = length(sample_start_idx(:,1));

	for j = 1:data_count
		values_all_cell = regexp(Data(sample_start_idx(j,1)+1:sample_end_idx(j,1)-1), ',', 'split');
		for k = 1:60
			values_all(k,1:10,j+data_length) = str2num(cell2mat(values_all_cell{k,1}(1,3:12)));
			values_all(k,11:20,j+data_length) = str2num(cell2mat(values_all_cell{k,1}(1,19:28)));
		end
	end

	for j = 1:data_count
		name_tmp(j,1) = Data(sample_start_idx(j,1), 1);
	end

	name_tmp2 = char(name_tmp);
	for j = 1:data_count
		sample{j+data_length,:} = name_tmp2(j, 17:cell2mat(strfind(name_tmp(j,:), '<>'))-2);
	end

	data_length = length(values_all(1,1,:));

	clear sample_start_idx
	clear sample_end_idx
	clear data_parse
	clear data_count
	clear name_tmp
	clear name_tmp2

	waitbar(i*.5/length(filename_data))

end

%cla(H.STDS_plot,'reset'); 
cla(H.SingleAnalysis_plot,'reset'); 
cla(H.Results_plot,'reset'); 

Hf_cutoff = str2num(get(H.Hfcutoff,'String'));
Yb_cutoff = str2num(get(H.Ybcutoff,'String'));
Hf_bias = str2num(get(H.Hfbias,'String'))*0.000028;
Yb_bias = str2num(get(H.Ybbias,'String'));

INT_cutoff_stds = str2num(get(H.intensity_cutoff_stds,'String'))/100;
INT_cutoff_unknowns = str2num(get(H.intensity_cutoff_unknowns,'String'))/100;
DM_Slider = get(H.DMslider,'Value')*4500;

Hf_LBL = 0;
Hf_AVG = 1;
Hf_SW = 0;
Yb_LBL = 0;
Yb_AVG = 1;
Yb_SW = 0;

Analysis_num = (1:1:length(sample))';
waitbar(.6)
for i = 1:length(sample)
	for j = 1:60
		BLS_180(j,i) = values_all(j,11,i) - values_all(j,1,i);
		BLS_179(j,i) = values_all(j,12,i) - values_all(j,2,i);
		BLS_178(j,i) = values_all(j,13,i) - values_all(j,3,i);
		BLS_177(j,i) = values_all(j,14,i) - values_all(j,4,i);
		BLS_176(j,i) = values_all(j,15,i) - values_all(j,5,i);
		BLS_175(j,i) = values_all(j,16,i) - values_all(j,6,i);
		BLS_174(j,i) = values_all(j,17,i) - values_all(j,7,i);
		BLS_173(j,i) = values_all(j,18,i) - values_all(j,8,i);
		BLS_172(j,i) = values_all(j,19,i) - values_all(j,9,i);
		BLS_171(j,i) = values_all(j,20,i) - values_all(j,10,i);
	end
end

STD_MT = 'MT';
STD_R33 = 'R33';
STD_PLES = 'PLES';
STD_FC = 'FC';
STD_TEM = 'TEM';
STD_91500 = '91500';
STD_SL = 'SL';

STD_MT_idx = strfind(sample, STD_MT);
STD_R33_idx = strfind(sample, STD_R33);
STD_PLES_idx = strfind(sample, STD_PLES);
STD_FC_idx = strfind(sample, STD_FC);
STD_TEM_idx = strfind(sample, STD_TEM);
STD_91500_idx = strfind(sample, STD_91500);
STD_SL_idx = strfind(sample, STD_SL);

STD_MT_idx = abs(cellfun(@isempty,STD_MT_idx)-1);
STD_R33_idx = abs(cellfun(@isempty,STD_R33_idx)-1);
STD_PLES_idx = abs(cellfun(@isempty,STD_PLES_idx)-1);
STD_FC_idx = abs(cellfun(@isempty,STD_FC_idx)-1);
STD_TEM_idx = abs(cellfun(@isempty,STD_TEM_idx)-1);
STD_91500_idx = abs(cellfun(@isempty,STD_91500_idx)-1);
STD_SL_idx = abs(cellfun(@isempty,STD_SL_idx)-1);

STD_idx = STD_MT_idx + STD_R33_idx + STD_PLES_idx + STD_FC_idx + STD_TEM_idx + STD_91500_idx + STD_SL_idx;
SAMPLES_idx = abs((STD_MT_idx + STD_R33_idx + STD_PLES_idx + STD_FC_idx + STD_TEM_idx + STD_91500_idx + STD_SL_idx) - 1);

waitbar(.7)

for i = 1:length(sample)
	BetaHf(:,i) = (log(0.73250./(abs(BLS_179(:,i)./BLS_177(:,i)))))/(log(178.94583/176.94323)); %0.73250 from Patchett & Tatsumoto (1980)
end

for i = 1:60
	for j = 1:length(sample)
		if BLS_180(i,j) > Hf_cutoff
			BHf_gt_int(i,j) = BetaHf(i,j);
		else 
			BHf_gt_int(i,j) = 0;
		end
	end
end

%BHf_SW Need to code this. Col AI in HfCalc 70.

for i = 1:length(sample)
	BetaYb(:,i) = (log(1.132338*(1+Yb_bias/40000)./(abs(BLS_173(:,i)./BLS_171(:,i)))))/(log(172.93822/170.93634)); %173/171 1.132338 from Vervoort et al. (2004)
end

for i = 1:60
	for j = 1:length(sample)
		if BLS_171(i,j) > Yb_cutoff
			BYb_gt_int(i,j) = BetaYb(i,j);
		else 
			BYb_gt_int(i,j) = 0;
		end
	end
end

%BYb_SW Need to code this. Col AL in HfCalc 70.

for i = 1:60
	for j = 1:length(sample)
		if Yb_LBL == 1
			Lu176V(i,j) = (BLS_175(i,j)*0.02653)/((175.94269/174.94079)^(BetaYb(i,j))); %0.02653 from Patchett (1983) -- update to 0.02669 (Debrieve & Taylor)?
		elseif Yb_AVG == 1
			Lu176V(i,j) = (BLS_175(i,j)*0.02653)/((175.94269/174.94079)^(mean(BetaYb(:,j)))); %0.02653 from Patchett (1983) -- update to 0.02669 (Debrieve & Taylor)?
		%elseif Yb_SW == 1
			%Lu176V(i,j) = (BLS_175(i,j)*0.02653)/((175.94269/174.94079)^(mean(BYb_SW(i,j))); %0.02653 from Patchett (1983) -- update to 0.02669 (Debrieve & Taylor)?
		else
			Lu176V(i,j) = 0;
		end
	end
end
%=IF(K!$R$9=TRUE,(AA11*K!$D$17)/((175.94269/174.94079)^(AJ11))
%%% should these reference Hf LBL , Hf AVG and Hf SW?
for i = 1:60
	for j = 1:length(sample)
		if Yb_LBL == 1
			Yb176V(i,j) = (BLS_171(i,j)*0.901691)/((175.94258/170.93634)^(BetaYb(i,j))); %0.901691 from Vervoort et al. (2004)
		elseif Yb_AVG == 1
			Yb176V(i,j) = (BLS_171(i,j)*0.901691)/((175.94258/170.93634)^(mean(BetaYb(:,j)))); %0.901691 from Vervoort et al. (2004)
		%elseif Yb_SW == 1
			%Yb176V(i,j) = (BLS_171(i,j)*0.901691)/((175.94258/170.93634)^(mean(BYb_SW(i,j))); %0.901691 from Vervoort et al. (2004)
		else
			Yb176V(i,j) = 0;
		end
	end
end

for i = 1:60
	for j = 1:length(sample)
		if Hf_LBL == 1
			All(i,j) = ((BLS_176(i,j)-Lu176V(i,j)-Yb176V(i,j))/(BLS_177(i,j)))*((175.94142/176.94323)^(BetaHf(i,j)));
		elseif Hf_AVG == 1
			All(i,j) = ((BLS_176(i,j)-Lu176V(i,j)-Yb176V(i,j))/(BLS_177(i,j)))*((175.94142/176.94323)^(mean(BetaHf(:,j))));
		%elseif Hf_SW == 1
			%All(i,j) = ((BLS_176(i,j)-Lu176V(i,j)-Yb176V(i,j))/(BLS_177(i,j)))*((175.94142/176.94323)^(mean(BHf_SW(:,j))));
		else
			All(i,j) = 0;
		end
	end
end

waitbar(.8)

for i = 1:60
	for j = 1:length(sample)
		if values_all(i,11,j) > 0.7*max(values_all(i,11,j))
			Yb_Lu_Hf(i,j) = 100*(Lu176V(i,j)+Yb176V(i,j))/(BLS_177(i,j)*All(i,j));
		else
			Yb_Lu_Hf(i,j) = 0;
		end
	end
end

for i = 1:60
	for j = 1:length(sample)
		if values_all(i,11,j) > INT_cutoff_stds*max(values_all(:,11,j)) && SAMPLES_idx(j,1) == 0
			Filter_INT(i,j) = All(i,j);
		elseif values_all(i,11,j) > INT_cutoff_unknowns*max(values_all(:,11,j)) && SAMPLES_idx(j,1) == 1
			Filter_INT(i,j) = All(i,j);
		else
			Filter_INT(i,j) = 0;
		end
	end
end

for i = 1:60
	for j = 1:length(sample)
		if Filter_INT(i,j) == max(Filter_INT(:,j))
			Filter_MAXMIN(i,j) = 0;
		elseif Filter_INT(i,j) == min(nonzeros(Filter_INT(:,j)))
			Filter_MAXMIN(i,j) = 0;
		else
			Filter_MAXMIN(i,j) = Filter_INT(i,j);
		end
	end
end

for i = 1:60
	for j = 1:length(sample)
		if Filter_MAXMIN(i,j) > mean(nonzeros(Filter_MAXMIN(:,j))) + 2*std(nonzeros(Filter_MAXMIN(:,j))) || ...
				Filter_MAXMIN(i,j) < mean(nonzeros(Filter_MAXMIN(:,j))) - 2*std(nonzeros(Filter_MAXMIN(:,j)))
			Filter_95(i,j) = 0;
		else 
			Filter_95(i,j) = Filter_MAXMIN(i,j);
		end
	end
end

waitbar(.9)

for j = 1:length(sample)
	if STD_MT_idx(j,1) == 1
		Ratio_STD_176_177_MT_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_MT_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_MT_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_MT(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	elseif STD_R33_idx(j,1) == 1
		Ratio_STD_176_177_R33_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_R33_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_R33_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_R33(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	elseif STD_PLES_idx(j,1) == 1
		Ratio_STD_176_177_PLES_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_PLES_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_PLES_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_PLES(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	elseif STD_FC_idx(j,1) == 1
		Ratio_STD_176_177_FC_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_FC_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_FC_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_FC(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	elseif STD_TEM_idx(j,1) == 1
		Ratio_STD_176_177_TEM_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_TEM_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_TEM_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_TEM(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	elseif STD_91500_idx(j,1) == 1
		Ratio_STD_176_177_91500_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_91500_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_91500_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_91500(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	elseif STD_SL_idx(j,1) == 1
		Ratio_STD_176_177_SL_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_SL_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_SL_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_SL(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	else 
		Ratio_UNKNOWN_176_177_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_UNKNOWN_176_177_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_UNKNOWN_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_UNKNOWN(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
		sample_UNKNOWN_idx(j,1) = 1;
		sample_UNKNOWN_name(j,1) = sort(strtrim(sample(j,1)));
	end
end










Ratio_STD_176_177_MT_mean = nonzeros(Ratio_STD_176_177_MT_mean);
Ratio_STD_176_177_MT_SE = nonzeros(Ratio_STD_176_177_MT_SE);
Yb_Lu_Hf_MT_mean = nonzeros(Yb_Lu_Hf_MT_mean);
v180_MT = nonzeros(v180_MT);

Ratio_STD_176_177_R33_mean = nonzeros(Ratio_STD_176_177_R33_mean);
Ratio_STD_176_177_R33_SE = nonzeros(Ratio_STD_176_177_R33_SE);
Yb_Lu_Hf_R33_mean = nonzeros(Yb_Lu_Hf_R33_mean);
v180_R33 = nonzeros(v180_R33);

Ratio_STD_176_177_PLES_mean = nonzeros(Ratio_STD_176_177_PLES_mean);
Ratio_STD_176_177_PLES_SE = nonzeros(Ratio_STD_176_177_PLES_SE);
Yb_Lu_Hf_PLES_mean = nonzeros(Yb_Lu_Hf_PLES_mean);
v180_PLES = nonzeros(v180_PLES);

Ratio_STD_176_177_FC_mean = nonzeros(Ratio_STD_176_177_FC_mean);
Ratio_STD_176_177_FC_SE = nonzeros(Ratio_STD_176_177_FC_SE);
Yb_Lu_Hf_FC_mean = nonzeros(Yb_Lu_Hf_FC_mean);
v180_FC = nonzeros(v180_FC);

Ratio_STD_176_177_TEM_mean = nonzeros(Ratio_STD_176_177_TEM_mean);
Ratio_STD_176_177_TEM_SE = nonzeros(Ratio_STD_176_177_TEM_SE);
Yb_Lu_Hf_TEM_mean = nonzeros(Yb_Lu_Hf_TEM_mean);
v180_TEM = nonzeros(v180_TEM);

Ratio_STD_176_177_91500_mean = nonzeros(Ratio_STD_176_177_91500_mean);
Ratio_STD_176_177_91500_SE = nonzeros(Ratio_STD_176_177_91500_SE);
Yb_Lu_Hf_91500_mean = nonzeros(Yb_Lu_Hf_91500_mean);
v180_91500 = nonzeros(v180_91500);

Ratio_STD_176_177_SL_mean = nonzeros(Ratio_STD_176_177_SL_mean);
Ratio_STD_176_177_SL_SE = nonzeros(Ratio_STD_176_177_SL_SE);
Yb_Lu_Hf_SL_mean = nonzeros(Yb_Lu_Hf_SL_mean);
v180_SL = nonzeros(v180_SL);

if sum(SAMPLES_idx) > 0
	Ratio_UNKNOWN_176_177_mean = nonzeros(Ratio_UNKNOWN_176_177_mean);
	Ratio_UNKNOWN_176_177_SE = nonzeros(Ratio_UNKNOWN_176_177_SE);
	Yb_Lu_Hf_UNKNOWN_mean = nonzeros(Yb_Lu_Hf_UNKNOWN_mean);
	v180_UNKNOWN = nonzeros(v180_UNKNOWN);
	sample_UNKNOWN_name = sample_UNKNOWN_name(~cellfun('isempty', sample_UNKNOWN_name'));
end

if sum(SAMPLES_idx) > 0
	if Agefile == 1
		filename_ages(all(cellfun('isempty',filename_ages),2),:) = [];
		fullpathname = char(strcat(folder_name, '/', filename_ages{1,1}));
		Data = importdata(fullpathname,',',500000);
		Ages = regexp(Data, ',', 'split');
		clear Data
		for i = 1:length(Ages(:,1))
			Ages_names(i,1) = strtrim(Ages{i,1}(1,1));
			Ages_mean(i,1) = str2num(cell2mat(Ages{i,1}(1,2)));
			Ages_uncert(i,1) = str2num(cell2mat(Ages{i,1}(1,3)));
		end
	else
		Ages_names = sample_UNKNOWN_name;
		%Ages_mean(1:length(sample_UNKNOWN_name),1) = str2double(get(H.age_set,'Value'));
        Ages_mean(1:length(sample_UNKNOWN_name),1) = 23;
		Ages_uncert(1:length(sample_UNKNOWN_name),1) = 1;
	end
end

% Match sample names to optional uploaded age file
if sum(SAMPLES_idx) > 0
	for j = 1:length(Ages_names)
		for i = 1:length(sample)
			s(i,j) = strcmp(strtrim(sample(i,1)),strtrim(Ages_names(j,1)));
		end
	end
		
	for i = 1:length(s(:,1))
		[~,I(i,1)] = max(s(i,:));
	end

	for i = 1:data_length
		if SAMPLES_idx(i,1) == 1
			Ages_ascribed(i,1:2) = [Ages_mean(I(i,1),1),Ages_uncert(I(i,1),1)];
		else
			Ages_ascribed(i,1:2) = 0;
		end
	end

	Ages_ascribed( all(~Ages_ascribed,2), : ) = [];

end

waitbar(1)

if sum(SAMPLES_idx) > 0
	for i = 1:length(v180_UNKNOWN)
		if v180_UNKNOWN ~= 0
			eHf_UNKNOWNS(i,1) = 10000*((Ratio_UNKNOWN_176_177_mean(i,1)/(0.282785-(0.0336*(exp((1000000*Ages_ascribed(i,1))*1.867*10^-11)-1))))-1);
		end
	end
end

Epsilon_plot = [16.5,14.6,0,15.6,0;15.0,13.0,500,14.0,0;13.4,11.5,1000,12.5,0;11.9,9.9,1500,10.9,0;10.3,8.3,2000,9.3,0; ...
	8.7,6.7,2500,7.7,0;5.4,3.4,3500,4.4,0;3.7,1.7,4000,2.7,0;2.0,0.0,4500,1.0,0];

Evolution_plot = [0.283253,0.283197,0,0.283225,0.282785;0.282894,0.282838,500,0.282865796,0.282470;0.282531,0.282475,1000,0.282503222,0.282152; ...
	0.282165,0.282109,1500,0.282137248,0.281831;0.281796,0.281740,2000,0.281767842,0.281507;0.281423,0.281367,2500,0.281394971,0.281180; ...
	0.280667,0.280611,3500,0.280638706,0.280516;0.280283,0.280227,4000,0.280255245,0.280180;0.279896,0.279840,4500,0.279868189,0.279840];

Decay_const_176Lu = 0.01867; %176Lu decay constant (Scherer et al., 2001) 1.867*10^-11 (same as Soderland et al., 2004)
DM_176Hf_177Hf = 0.283225; %Vervoort and Blichert-Toft, 1999
DM_176Lu_177Hf = 0.0383; %Vervoort and Blichert-Toft, 1999
BSE_176Hf_177Hf = 0.282785; %Bouvier et al. 2008
BSE_176Lu_177Hf = 0.0336; %Bouvier et al. 2008

t_176Hf_177Hf = DM_176Hf_177Hf - (DM_176Lu_177Hf*(exp(Decay_const_176Lu*DM_Slider/1000)-1));

CHURt = BSE_176Hf_177Hf - (BSE_176Lu_177Hf*(exp(Decay_const_176Lu*DM_Slider/1000)-1));

DMpoint_Evol_x = DM_Slider;
DMpoint_Evol_y = t_176Hf_177Hf;

DMpoint_Epsi_x = DM_Slider;
DMpoint_Epsi_y = 10000*((t_176Hf_177Hf/CHURt)-1);

Y0_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0115*(exp(Decay_const_176Lu*DM_Slider/1000)-1));
Y0_u_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0193*(exp(Decay_const_176Lu*DM_Slider/1000)-1));
Y0_l_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0036*(exp(Decay_const_176Lu*DM_Slider/1000)-1));
Ys_Evol_DM_176Lu_177Hf = t_176Hf_177Hf;

Y0_Epsi_DM_176Lu_177Hf = 10000*((Y0_Evol_DM_176Lu_177Hf/BSE_176Hf_177Hf)-1);
Y0_u_Epsi_DM_176Lu_177Hf = 10000*((Y0_u_Evol_DM_176Lu_177Hf/BSE_176Hf_177Hf)-1);
Y0_l_Epsi_DM_176Lu_177Hf = 10000*((Y0_l_Evol_DM_176Lu_177Hf/BSE_176Hf_177Hf)-1);
Ys_Epsi_DM_176Lu_177Hf = DMpoint_Epsi_y;

STD_offset = [];
if get(H.check_MT,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_MT_mean) - 0.282507;
end
if get(H.check_R33,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_R33_mean) - 0.282764; % R33 STD should end in 1 to be consistent
end
if get(H.check_PLES,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_PLES_mean) - 0.282484;
end
if get(H.check_FC,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_FC_mean) - 0.282183;
end
if get(H.check_TEM,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_TEM_mean) - 0.282686;
end
if get(H.check_91500,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_91500_mean) - 0.282313;
end
if get(H.check_SL,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_SL_mean) - 0.282163;
end
STD_offset_avg = mean(STD_offset);
set(H.STDoffset,'String',sprintf('%f',STD_offset_avg))

STD_SE_avg = mean([Ratio_STD_176_177_MT_SE; Ratio_STD_176_177_R33_SE; Ratio_STD_176_177_PLES_SE; Ratio_STD_176_177_FC_SE; Ratio_STD_176_177_TEM_SE; ...
	Ratio_STD_176_177_91500_SE; Ratio_STD_176_177_SL_SE]);
set(H.STDSE,'String',sprintf('%f',STD_SE_avg));
if sum(SAMPLES_idx) > 0
	set(H.mean_uncertainty,'String',sprintf('%f',mean(Ratio_UNKNOWN_176_177_SE)));
end

% Calculate % data retained
for j = 1:length(sample)
	if SAMPLES_idx(j,1) == 0
		retained_stds(j,1) = length(nonzeros(Filter_INT(:,j)))/60;
	else
		retained_stds(j,1) = 0;
	end
end

for j = 1:length(sample)
	if SAMPLES_idx(j,1) == 1
		retained_unknowns(j,1) = length(nonzeros(Filter_INT(:,j)))/60;
	else
	retained_unknowns(j,1) = 0;
	end
end

retained_stds_p = sum(retained_stds)/sum(STD_idx)*100;
retained_unknowns_p = sum(retained_unknowns)/sum(SAMPLES_idx)*100;

set(H.ret_std,'String',round(retained_stds_p,1))
set(H.ret_unk,'String',round(retained_unknowns_p,1))


reduced = 1;

close(h)

for i=1:length(sample)
	name_char(i,1)=(sample(i,1));
end

set(H.listbox1, 'String', name_char);
set(H.listbox1,'Value',length(sample));

t = 1;
match = [1:1:length(sample)]';
for i=1:length(sample)
    if SAMPLES_idx(i,1) == 1
        match2(i,1) = t;
        t = t+1;
    else
        match2(i,1) = 0;
    end
end
%match2(match2==0) = [];


axes(H.STDS_plot);
hold on
plot([-10, 90], [0.282761, 0.282761],'--','LineWidth',2,'Color',[0.58 0.58 0.58]) %R33 Bahlburg et al. 2010
plot([-10, 60], [0.282686, 0.282686],'--','LineWidth',2,'Color',[.6 .2 .4]) %TEM Woodhead and Hergt 2005
plot([-10, 10], [0.282507, 0.282507],'--','LineWidth',2,'Color',[.12 .71 .07]) %MT Woodhead and Hergt 2005
plot([-10, 10], [0.282484, 0.282484],'--','LineWidth',2,'Color',[.8 .6 1]) %PLES Slama et al. (2008)
plot([-10, 10], [0.282313, 0.282313],'--','LineWidth',2,'Color',[.2 .4 .4]) %91500 Fisher et al. 2014
plot([-10, 90], [0.282183, 0.282183],'--','LineWidth',2,'Color',[.2 .4 1]) %FC Fisher et al. 2014
plot([-10, 10], [0.28163, 0.28163],'--','LineWidth',2,'Color',[0.56 0.44 0.23]) %SL Woodhead and Hergt 2005
plot([-10, 10], [0.281697, 0.281697],'--','LineWidth',2,'Color',[0.56 0.44 0.23]) %SL Ping et al. (2004)-laser
plot([-10, 10], [0.281703, 0.281703],'--','LineWidth',2,'Color',[0.56 0.44 0.23]) %SL Kemp et al. (2006)-laser
plot([-10, 10], [0.281729, 0.281729],'--','LineWidth',2,'Color',[0.56 0.44 0.23]) %SL Wu et al. (2006)-laser

if sum(SAMPLES_idx) > 0
	h0 = scatter(Yb_Lu_Hf_UNKNOWN_mean, Ratio_UNKNOWN_176_177_mean, 20, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','w');
end
h1 = scatter(Yb_Lu_Hf_R33_mean, Ratio_STD_176_177_R33_mean, 40, 'MarkerEdgeColor','k', 'MarkerFaceColor',[0.58 0.58 0.58]);
h2 = scatter(Yb_Lu_Hf_TEM_mean, Ratio_STD_176_177_TEM_mean, 40, 'MarkerEdgeColor','k', 'MarkerFaceColor',[.6 .2 .4]);
h3 = scatter(Yb_Lu_Hf_MT_mean, Ratio_STD_176_177_MT_mean, 40, 'MarkerEdgeColor','k', 'MarkerFaceColor',[.12 .71 .07]);
h4 = scatter(Yb_Lu_Hf_PLES_mean, Ratio_STD_176_177_PLES_mean, 40, 'MarkerEdgeColor','k', 'MarkerFaceColor',[.8 .6 1]);
h5 = scatter(Yb_Lu_Hf_91500_mean, Ratio_STD_176_177_91500_mean, 40, 'MarkerEdgeColor','k', 'MarkerFaceColor',[.2 .4 .4]);
h6 = scatter(Yb_Lu_Hf_FC_mean, Ratio_STD_176_177_FC_mean, 40, 'MarkerEdgeColor','k', 'MarkerFaceColor',[.2 .4 1]);
h7 = scatter(Yb_Lu_Hf_SL_mean, Ratio_STD_176_177_SL_mean, 40, 'MarkerEdgeColor','k', 'MarkerFaceColor',[0.56 0.44 0.23]);
if sum(SAMPLES_idx) > 0
	legend([h0,h1,h2,h3,h4,h5,h6,h7],{'Unknowns','R33','Temora','Mud Tank','Plesovice','91500','FC','Sri Lanka'}, 'Location', 'southeast')
else
legend([h1,h2,h3,h4,h5,h6,h7],{'R33','Temora','Mud Tank','Plesovice','91500','FC','Sri Lanka'}, 'Location', 'southeast')
end
xlabel('176(Yb+Lu) / 176Hf (%)')
ylabel('176Hf/177Hf')
axis([-10 80 0.2813 0.2831])
hold off

if sum(SAMPLES_idx) > 0
	if get(H.DataPlot, 'Value') == 1
		cla(H.Results_plot,'reset');
		axes(H.Results_plot);
		scatter(Yb_Lu_Hf_UNKNOWN_mean, Ratio_UNKNOWN_176_177_mean, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
		legend('Unknowns')
		xlabel('176(Yb+Lu) / 176Hf (%)')
		ylabel('176Hf/177Hf')
		hold off
	end
end

if get(H.EvolutionPlot, 'Value') == 1
	cla(H.Results_plot,'reset');
	axes(H.Results_plot);
	hold on
	if sum(SAMPLES_idx) > 0
		scatter(Ages_ascribed, Ratio_UNKNOWN_176_177_mean, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	end
	plot(Evolution_plot(:,3),Evolution_plot(:,5),'k','LineWidth',2)
	plot(Evolution_plot(:,3),Evolution_plot(:,4),'r','LineWidth',2)
	plot(Evolution_plot(:,3),Evolution_plot(:,1),'r','LineWidth',1)
	plot(Evolution_plot(:,3),Evolution_plot(:,2),'r','LineWidth',1)
	plot([0 DM_Slider],[Y0_u_Evol_DM_176Lu_177Hf, Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	plot([0 DM_Slider],[Y0_Evol_DM_176Lu_177Hf, Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 2)
	plot([0 DM_Slider],[Y0_l_Evol_DM_176Lu_177Hf, Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	legend({'Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193'}, 'Location', 'southeast')
	xlabel('Age (Ma)')
	ylabel('176Hf/177Hf(T)')
	hold off
end

if get(H.EpsilonPlot, 'Value') == 1
	cla(H.Results_plot,'reset');
	axes(H.Results_plot);
	
	hold on
	if sum(SAMPLES_idx) > 0
		scatter(Ages_ascribed(:,1), eHf_UNKNOWNS, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	end
	plot(Epsilon_plot(:,3),Epsilon_plot(:,5),'k','LineWidth',2)
	plot(Epsilon_plot(:,3),Epsilon_plot(:,4),'r','LineWidth',2)
	plot(Epsilon_plot(:,3),Epsilon_plot(:,1),'--r','LineWidth',1)
	plot(Epsilon_plot(:,3),Epsilon_plot(:,2),'--r','LineWidth',1)
	plot([0 DM_Slider],[Y0_u_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	plot([0 DM_Slider],[Y0_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 2)
	plot([0 DM_Slider],[Y0_l_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
    
    idx = match2(get(H.listbox1,'Value'),1);
    if idx ~= 0
        s1 = scatter(Ages_ascribed(idx,1), eHf_UNKNOWNS(idx,1), 150, 'o', 'MarkerEdgeColor', 'b');
        %legend({'Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193'}, 'Location', 'southeast')
    else    
        s1 = scatter(Ages_ascribed(1,1), eHf_UNKNOWNS(1,1), 150, 'o', 'MarkerEdgeColor', 'b');
        set(s1,'Visible','off')
    end

	legend({'Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193'}, 'Location', 'southeast')
	xlabel('Age (Ma)')
	ylabel('Epsilon Hf')
	hold on
end
%axis([0 27 -50 20])

BLS_176_177_corr = Filter_95;

name_idx = length(sample); %automatically plot final sample run

axes(H.SingleAnalysis_plot);
hold on
x = 1:1:60;
if get(H.checkbox_176_177,'Value') == 1
	for i = 1:60
		if BLS_176_177_corr(i,length(sample)) ~= 0
			scatter(x(1,i), BLS_176_177_corr(i,length(sample)), 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
		end
	end
	rectangle('Position',[0 min(nonzeros(BLS_176_177_corr(:,name_idx))) 60 max(BLS_176_177_corr(:,length(sample))) - min(nonzeros(BLS_176_177_corr(:,name_idx)))], 'LineWidth', 1)
	hold off
	legend(sample(length(sample),1))
	xlabel('Time (s)')
	ylabel('176/177 Corrected')
end
if get(H.checkbox_180,'Value') == 1
	hold on
	scatter(x, BLS_180(:,length(sample)), 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	legend(sample(length(sample),1))
	xlabel('Time (s)')
	ylabel('Baseline subtracted 177/176')
	hold off
end
axis([0, 60, min(nonzeros(BLS_176_177_corr(:,name_idx))), max(BLS_176_177_corr(:,length(sample)))])



set(H.intw_xmin,'String',{'0'})
set(H.intw_xmax,'String',{'60'})
set(H.intw_ymin,'String',round(min(nonzeros(BLS_176_177_corr(:,name_idx))),6))
set(H.intw_ymax,'String',round(max(BLS_176_177_corr(:,length(sample))),6))


set(H.status,'String',{'Accepted'},'ForegroundColor','blue');






H.sample = sample;
H.BLS_176 = BLS_176;
H.BLS_177 = BLS_177;
H.BLS_180 = BLS_180;
H.BLS_176_177_corr = BLS_176_177_corr;
H.DM_Slider = DM_Slider;
H.Y0_u_Evol_DM_176Lu_177Hf = Y0_u_Evol_DM_176Lu_177Hf;
H.Ys_Evol_DM_176Lu_177Hf = Ys_Evol_DM_176Lu_177Hf;
H.Y0_Evol_DM_176Lu_177Hf = Y0_Evol_DM_176Lu_177Hf;
H.Y0_l_Evol_DM_176Lu_177Hf = Y0_l_Evol_DM_176Lu_177Hf;
H.Y0_u_Epsi_DM_176Lu_177Hf = Y0_u_Epsi_DM_176Lu_177Hf;
H.Ys_Epsi_DM_176Lu_177Hf = Ys_Epsi_DM_176Lu_177Hf;
H.Y0_Epsi_DM_176Lu_177Hf = Y0_Epsi_DM_176Lu_177Hf;
H.Y0_l_Epsi_DM_176Lu_177Hf = Y0_l_Epsi_DM_176Lu_177Hf;
H.Epsilon_plot = Epsilon_plot;
H.Evolution_plot = Evolution_plot;
H.Decay_const_176Lu = Decay_const_176Lu;
H.DM_176Lu_177Hf = DM_176Lu_177Hf;
H.DM_176Hf_177Hf = DM_176Hf_177Hf;
H.BSE_176Lu_177Hf = BSE_176Lu_177Hf;
H.BSE_176Hf_177Hf = BSE_176Hf_177Hf;
H.reduced = reduced;
H.match = match;
H.match2 = match2;
H.Ages_ascribed = Ages_ascribed;
H.eHf_UNKNOWNS = eHf_UNKNOWNS;
H.s1 = s1;

if sum(SAMPLES_idx) > 0
	H.eHf_UNKNOWNS = eHf_UNKNOWNS;
	H.Ages_ascribed = Ages_ascribed;
	H.Yb_Lu_Hf_UNKNOWN_mean = Yb_Lu_Hf_UNKNOWN_mean;
	H.Ratio_UNKNOWN_176_177_mean = Ratio_UNKNOWN_176_177_mean;
	H.Ratio_UNKNOWN_176_177_mean = Ratio_UNKNOWN_176_177_mean;
end

if get(H.auto_reduce,'Value') == 0
	guidata(hObject,H);
end














%% Update Reductio button %%
function reduce_Callback(hObject, eventdata, H)





function listbox1_Callback(hObject, eventdata, H)
cla(H.SingleAnalysis_plot,'reset');

sample = H.sample;
BLS_176 = H.BLS_176;
BLS_177 = H.BLS_177;
match = H.match;
match2 = H.match2;
Ages_ascribed = H.Ages_ascribed;
eHf_UNKNOWNS = H.eHf_UNKNOWNS;
s1 = H.s1;

name_idx = get(H.listbox1,'Value');

axes(H.SingleAnalysis_plot);
x = 1:1:60;

if get(H.checkbox_176_177,'Value') == 1
	for i = 1:60
	hold on
		if H.BLS_176_177_corr(i,name_idx) ~= 0
			scatter(x(1,i), H.BLS_176_177_corr(i,name_idx), 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
		end
	hold off
	end

	legend(sample(name_idx,1))
	xlabel('Time (s)')
	ylabel('Baseline subtracted 177/176')
end


if get(H.checkbox_180,'Value') == 1

	scatter(x, H.BLS_180(:,name_idx), 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	legend(sample(name_idx,1))
	xlabel('Time (s)')
	ylabel('Baseline subtracted 177/176')
	axis([0 60 0 4])
end


axes(H.Results_plot);
idx = match2(get(H.listbox1,'Value'),1);
if idx ~= 0
    set(s1,'Visible','off')
	clear s1
    s1 = scatter(Ages_ascribed(idx,1), eHf_UNKNOWNS(idx,1), 150, 'o', 'MarkerEdgeColor', 'b');
    %legend({'Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193'}, 'Location', 'southeast')
else
    set(s1,'Visible','off')
end

H.s1 = s1;
guidata(hObject,H);


%% Results Plot Checkboxes %%
function DataPlot_Callback(hObject, eventdata, H)
set(H.EvolutionPlot, 'Value', 0);
set(H.EpsilonPlot, 'Value', 0);
set(H.DataPlot, 'Value', 1);

if H.reduced == 1
	cla(H.Results_plot,'reset'); 
	axes(H.Results_plot);
	Ratio_UNKNOWN_176_177_mean = H.Ratio_UNKNOWN_176_177_mean;
	scatter(H.Yb_Lu_Hf_UNKNOWN_mean, H.Ratio_UNKNOWN_176_177_mean, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	legend('Unknowns')
	xlabel('176(Yb+Lu) / 176Hf (%)')
	ylabel('176Hf/177Hf')
	title('Unknowns')
end

function EvolutionPlot_Callback(hObject, eventdata, H)
set(H.DataPlot, 'Value', 0);
set(H.EpsilonPlot, 'Value', 0);
set(H.EvolutionPlot, 'Value', 1);

DM_Slider = get(H.DMslider,'Value')*4500;
set(H.DMtext,'String',DM_Slider);

t_176Hf_177Hf = H.DM_176Hf_177Hf - (H.DM_176Lu_177Hf*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));

Y0_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0115*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Y0_u_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0193*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Y0_l_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0036*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Ys_Evol_DM_176Lu_177Hf = t_176Hf_177Hf;

if H.reduced == 1
	cla(H.Results_plot,'reset');
	axes(H.Results_plot);
	hold on
	scatter(H.Ages_ascribed(:,1), H.Ratio_UNKNOWN_176_177_mean, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	plot(H.Evolution_plot(:,3),H.Evolution_plot(:,5),'k','LineWidth',2)
	plot(H.Evolution_plot(:,3),H.Evolution_plot(:,4),'r','LineWidth',2)
	plot(H.Evolution_plot(:,3),H.Evolution_plot(:,1),'r','LineWidth',1)
	plot(H.Evolution_plot(:,3),H.Evolution_plot(:,2),'r','LineWidth',1)
	plot([0 DM_Slider],[Y0_u_Evol_DM_176Lu_177Hf, Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	plot([0 DM_Slider],[Y0_Evol_DM_176Lu_177Hf, Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 2)
	plot([0 DM_Slider],[Y0_l_Evol_DM_176Lu_177Hf, Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	legend('Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193')
	xlabel('Age (Ma)')
	ylabel('176Hf/177Hf(T)')
	%title('Evolution Plot')
end

function EpsilonPlot_Callback(hObject, eventdata, H)
set(H.DataPlot, 'Value', 0);
set(H.EvolutionPlot, 'Value', 0);
set(H.EpsilonPlot, 'Value', 1);

DM_Slider = get(H.DMslider,'Value')*4500;
set(H.DMtext,'String',DM_Slider);


t_176Hf_177Hf = H.DM_176Hf_177Hf - (H.DM_176Lu_177Hf*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));

CHURt = H.BSE_176Hf_177Hf - (H.BSE_176Lu_177Hf*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));

DMpoint_Evol_x = DM_Slider;
DMpoint_Evol_y = t_176Hf_177Hf;
 
DMpoint_Epsi_x = DM_Slider;
DMpoint_Epsi_y = 10000*((t_176Hf_177Hf/CHURt)-1);

Y0_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0115*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Y0_u_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0193*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Y0_l_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0036*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Ys_Evol_DM_176Lu_177Hf = t_176Hf_177Hf;

Y0_Epsi_DM_176Lu_177Hf = 10000*((Y0_Evol_DM_176Lu_177Hf/H.BSE_176Hf_177Hf)-1);
Y0_u_Epsi_DM_176Lu_177Hf = 10000*((Y0_u_Evol_DM_176Lu_177Hf/H.BSE_176Hf_177Hf)-1);
Y0_l_Epsi_DM_176Lu_177Hf = 10000*((Y0_l_Evol_DM_176Lu_177Hf/H.BSE_176Hf_177Hf)-1);
Ys_Epsi_DM_176Lu_177Hf = DMpoint_Epsi_y;

if H.reduced == 1
	cla(H.Results_plot,'reset'); 
	axes(H.Results_plot);
	hold on
	scatter(H.Ages_ascribed(:,1), H.eHf_UNKNOWNS, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	plot(H.Epsilon_plot(:,3),H.Epsilon_plot(:,5),'k','LineWidth',2)
	plot(H.Epsilon_plot(:,3),H.Epsilon_plot(:,4),'r','LineWidth',2)
	plot(H.Epsilon_plot(:,3),H.Epsilon_plot(:,1),'--r','LineWidth',1)
	plot(H.Epsilon_plot(:,3),H.Epsilon_plot(:,2),'--r','LineWidth',1)
	plot([0 DM_Slider],[Y0_u_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	plot([0 DM_Slider],[Y0_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 2)
	plot([0 DM_Slider],[Y0_l_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	legend('Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193')
	xlabel('Age (Ma)')
	ylabel('Epsilon Hf')
end



function DMslider_Callback(hObject, eventdata, H)

DM_Slider = get(H.DMslider,'Value')*4500;
set(H.DMtext,'String',DM_Slider);

if get(H.EvolutionPlot, 'Value') == 1
	cla(H.Results_plot,'reset');




t_176Hf_177Hf = H.DM_176Hf_177Hf - (H.DM_176Lu_177Hf*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));

Y0_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0115*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Y0_u_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0193*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Y0_l_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0036*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Ys_Evol_DM_176Lu_177Hf = t_176Hf_177Hf;








	axes(H.Results_plot);
	hold on
	scatter(H.Ages_ascribed(:,1), H.Ratio_UNKNOWN_176_177_mean, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	plot(H.Evolution_plot(:,3),H.Evolution_plot(:,5),'k','LineWidth',2)
	plot(H.Evolution_plot(:,3),H.Evolution_plot(:,4),'r','LineWidth',2)
	plot(H.Evolution_plot(:,3),H.Evolution_plot(:,1),'r','LineWidth',1)
	plot(H.Evolution_plot(:,3),H.Evolution_plot(:,2),'r','LineWidth',1)
	plot([0 DM_Slider],[Y0_u_Evol_DM_176Lu_177Hf, Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	plot([0 DM_Slider],[Y0_Evol_DM_176Lu_177Hf, Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 2)
	plot([0 DM_Slider],[Y0_l_Evol_DM_176Lu_177Hf, Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	legend('Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193')
	xlabel('Age (Ma)')
	ylabel('176Hf/177Hf(T)')
	%title('Evolution Plot')
end

if get(H.EpsilonPlot, 'Value') == 1
	cla(H.Results_plot,'reset');


t_176Hf_177Hf = H.DM_176Hf_177Hf - (H.DM_176Lu_177Hf*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));

CHURt = H.BSE_176Hf_177Hf - (H.BSE_176Lu_177Hf*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));

DMpoint_Evol_x = DM_Slider;
DMpoint_Evol_y = t_176Hf_177Hf;
 
DMpoint_Epsi_x = DM_Slider;
DMpoint_Epsi_y = 10000*((t_176Hf_177Hf/CHURt)-1);

Y0_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0115*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Y0_u_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0193*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Y0_l_Evol_DM_176Lu_177Hf = t_176Hf_177Hf + (0.0036*(exp(H.Decay_const_176Lu*DM_Slider/1000)-1));
Ys_Evol_DM_176Lu_177Hf = t_176Hf_177Hf;

Y0_Epsi_DM_176Lu_177Hf = 10000*((Y0_Evol_DM_176Lu_177Hf/H.BSE_176Hf_177Hf)-1);
Y0_u_Epsi_DM_176Lu_177Hf = 10000*((Y0_u_Evol_DM_176Lu_177Hf/H.BSE_176Hf_177Hf)-1);
Y0_l_Epsi_DM_176Lu_177Hf = 10000*((Y0_l_Evol_DM_176Lu_177Hf/H.BSE_176Hf_177Hf)-1);
Ys_Epsi_DM_176Lu_177Hf = DMpoint_Epsi_y;

	axes(H.Results_plot);
	hold on
	scatter(H.Ages_ascribed(:,1), H.eHf_UNKNOWNS, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	plot(H.Epsilon_plot(:,3),H.Epsilon_plot(:,5),'k','LineWidth',2)
	plot(H.Epsilon_plot(:,3),H.Epsilon_plot(:,4),'r','LineWidth',2)
	plot(H.Epsilon_plot(:,3),H.Epsilon_plot(:,1),'--r','LineWidth',1)
	plot(H.Epsilon_plot(:,3),H.Epsilon_plot(:,2),'--r','LineWidth',1)
	plot([0 DM_Slider],[Y0_u_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	plot([0 DM_Slider],[Y0_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 2)
	plot([0 DM_Slider],[Y0_l_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	legend('Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193')
	xlabel('Age (Ma)')
	ylabel('Epsilon Hf')
	%title('Epsilon Plot')
end


















function DMtext_Callback(hObject, eventdata, H)

str2num(get(H.DMtext,'String'));
set(H.DM_Slider, 'Value', str2num(get(H.DMtext,'String'))/4500);






function checkbox_180_Callback(hObject, eventdata, H)
set(H.checkbox_180,'Value', 1)
set(H.checkbox_176_177,'Value', 0) 
cla(H.SingleAnalysis_plot,'reset');
sample = H.sample;
BLS_180 = H.BLS_180;
x = 1:1:60;
if get(H.checkbox_180,'Value') == 1
	hold on
	scatter(x, BLS_180(:,length(sample)), 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	legend(sample(length(sample),1))
	xlabel('Time (s)')
	ylabel('Baseline subtracted 177/176')
	hold off
end


function checkbox_176_177_Callback(hObject, eventdata, H)
set(H.checkbox_180,'Value', 0)
set(H.checkbox_176_177,'Value', 1) 
cla(H.SingleAnalysis_plot,'reset');
sample = H.sample;
BLS_176 = H.BLS_176;
BLS_177 = H.BLS_177;

name_idx = get(H.listbox1,'Value');

axes(H.SingleAnalysis_plot);
x = 1:1:60;

if get(H.checkbox_176_177,'Value') == 1
	for i = 1:60
	hold on
		if H.BLS_176_177_corr(i,name_idx) ~= 0
			scatter(x(1,i), H.BLS_176_177_corr(i,name_idx), 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
		end
	hold off
	end

	legend(sample(name_idx,1))
	xlabel('Time (s)')
	ylabel('Baseline subtracted 177/176')
end







function check_MT_Callback(hObject, eventdata, H)

function check_91500_Callback(hObject, eventdata, H)

function check_TEM_Callback(hObject, eventdata, H)

function check_PLES_Callback(hObject, eventdata, H)

function check_SL_Callback(hObject, eventdata, H)

function check_R33_Callback(hObject, eventdata, H)

function checkbox7_Callback(hObject, eventdata, H)

function slider1_Callback(hObject, eventdata, H)

test = get(H.DM_Slider,'Value')




function slider1_CreateFcn(hObject, eventdata, H)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function slider3_Callback(hObject, eventdata, H)

function slider3_CreateFcn(hObject, eventdata, H)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function slider4_Callback(hObject, eventdata, H)

function slider4_CreateFcn(hObject, eventdata, H)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function listbox2_Callback(hObject, eventdata, H)

function listbox2_CreateFcn(hObject, eventdata, H)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slider5_Callback(hObject, eventdata, H)

function slider5_CreateFcn(hObject, eventdata, H)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


















function listbox1_CreateFcn(hObject, eventdata, H)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





function DM_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DM_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end







% --- Executes on button press in checkbox_179.
function checkbox_179_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_179 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_179


% --- Executes on button press in checkbox_178.
function checkbox_178_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_178 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_178


% --- Executes on button press in checkbox_177.
function checkbox_177_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_177 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_177


% --- Executes on button press in checkbox_176.
function checkbox_176_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_176 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_176


% --- Executes on button press in checkbox_175.
function checkbox_175_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_175 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_175


% --- Executes on button press in checkbox_174.
function checkbox_174_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_174 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_174


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17


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





function DMtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DMtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_173.
function checkbox_173_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_173 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_173


% --- Executes on button press in checkbox_172.
function checkbox_172_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_172 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_172


% --- Executes on button press in checkbox_171.
function checkbox_171_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_171 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_171







% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider10_Callback(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider11_Callback(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider12_Callback(hObject, eventdata, handles)
% hObject    handle to slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox28.
function checkbox28_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox28


% --- Executes on button press in checkbox29.
function checkbox29_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox29


% --- Executes on button press in checkbox30.
function checkbox30_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox30


% --- Executes on slider movement.
function INTslider_Callback(hObject, eventdata, handles)
% hObject    handle to INTslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function INTslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to INTslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function intensity_cutoff_stds_Callback(hObject, eventdata, handles)
% hObject    handle to intensity_cutoff_stds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intensity_cutoff_stds as text
%        str2double(get(hObject,'String')) returns contents of intensity_cutoff_stds as a double


% --- Executes during object creation, after setting all properties.
function intensity_cutoff_stds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intensity_cutoff_stds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox31.
function checkbox31_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox31


% --- Executes on button press in checkbox32.
function checkbox32_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox32


% --- Executes on button press in checkbox33.
function checkbox33_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox33



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to ret_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ret_std as text
%        str2double(get(hObject,'String')) returns contents of ret_std as a double


% --- Executes during object creation, after setting all properties.
function ret_std_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ret_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function pushbutton13_Callback(hObject, eventdata, handles)









function DMslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DMslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function seconds_Callback(hObject, eventdata, handles)
% hObject    handle to seconds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of seconds as text
%        str2double(get(hObject,'String')) returns contents of seconds as a double


% --- Executes during object creation, after setting all properties.
function seconds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seconds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox37.
function checkbox37_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox37



function minx_Callback(hObject, eventdata, handles)
% hObject    handle to minx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minx as text
%        str2double(get(hObject,'String')) returns contents of minx as a double


% --- Executes during object creation, after setting all properties.
function minx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxx_Callback(hObject, eventdata, handles)
% hObject    handle to maxx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxx as text
%        str2double(get(hObject,'String')) returns contents of maxx as a double


% --- Executes during object creation, after setting all properties.
function maxx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function miny_Callback(hObject, eventdata, handles)
% hObject    handle to miny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of miny as text
%        str2double(get(hObject,'String')) returns contents of miny as a double


% --- Executes during object creation, after setting all properties.
function miny_CreateFcn(hObject, eventdata, handles)
% hObject    handle to miny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxy_Callback(hObject, eventdata, handles)
% hObject    handle to maxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxy as text
%        str2double(get(hObject,'String')) returns contents of maxy as a double


% --- Executes during object creation, after setting all properties.
function maxy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setscale.
function setscale_Callback(hObject, eventdata, handles)
% hObject    handle to setscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of setscale


% --- Executes on button press in autoscale.
function autoscale_Callback(hObject, eventdata, handles)
% hObject    handle to autoscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoscale


% --- Executes on button press in autorej.
function autorej_Callback(hObject, eventdata, handles)
% hObject    handle to autorej (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autorej



function autorej_num_Callback(hObject, eventdata, handles)
% hObject    handle to autorej_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of autorej_num as text
%        str2double(get(hObject,'String')) returns contents of autorej_num as a double


% --- Executes during object creation, after setting all properties.
function autorej_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autorej_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in legend_results.
function legend_results_Callback(hObject, eventdata, handles)
% hObject    handle to legend_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of legend_results



function intw_xmax_Callback(hObject, eventdata, handles)
% hObject    handle to intw_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intw_xmax as text
%        str2double(get(hObject,'String')) returns contents of intw_xmax as a double


% --- Executes during object creation, after setting all properties.
function intw_xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intw_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intw_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to intw_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intw_ymin as text
%        str2double(get(hObject,'String')) returns contents of intw_ymin as a double


% --- Executes during object creation, after setting all properties.
function intw_ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intw_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intw_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to intw_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intw_ymax as text
%        str2double(get(hObject,'String')) returns contents of intw_ymax as a double


% --- Executes during object creation, after setting all properties.
function intw_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intw_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intw_xmin_Callback(hObject, eventdata, handles)
% hObject    handle to intw_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intw_xmin as text
%        str2double(get(hObject,'String')) returns contents of intw_xmin as a double


% --- Executes during object creation, after setting all properties.
function intw_xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intw_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox42.
function checkbox42_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox42


% --- Executes on button press in checkbox43.
function checkbox43_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox43


% --- Executes on button press in checkbox44.
function checkbox44_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox44



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox45.
function checkbox45_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox45


% --- Executes on button press in checkbox46.
function checkbox46_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox46



function intensity_cutoff_unknowns_Callback(hObject, eventdata, handles)
% hObject    handle to mean_uncertainty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mean_uncertainty as text
%        str2double(get(hObject,'String')) returns contents of mean_uncertainty as a double


% --- Executes during object creation, after setting all properties.
function mean_uncertainty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mean_uncertainty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Hfcutoff_Callback(hObject, eventdata, handles)
% hObject    handle to Hfcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Hfcutoff as text
%        str2double(get(hObject,'String')) returns contents of Hfcutoff as a double


% --- Executes during object creation, after setting all properties.
function Hfcutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Hfcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Hfbias_Callback(hObject, eventdata, handles)
% hObject    handle to Hfbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Hfbias as text
%        str2double(get(hObject,'String')) returns contents of Hfbias as a double


% --- Executes during object creation, after setting all properties.
function Hfbias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Hfbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ybbias_Callback(hObject, eventdata, handles)
% hObject    handle to Ybbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ybbias as text
%        str2double(get(hObject,'String')) returns contents of Ybbias as a double


% --- Executes during object creation, after setting all properties.
function Ybbias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ybbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ybcutoff_Callback(hObject, eventdata, handles)
% hObject    handle to Ybcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ybcutoff as text
%        str2double(get(hObject,'String')) returns contents of Ybcutoff as a double


% --- Executes during object creation, after setting all properties.
function Ybcutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ybcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox47.
function checkbox47_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox47



function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function intensity_cutoff_unknowns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intensity_cutoff_unknowns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_FC.
function check_FC_Callback(hObject, eventdata, handles)
% hObject    handle to check_FC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_FC


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function age_set_Callback(hObject, eventdata, handles)
% hObject    handle to age_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of age_set as text
%        str2double(get(hObject,'String')) returns contents of age_set as a double


% --- Executes during object creation, after setting all properties.
function age_set_CreateFcn(hObject, eventdata, handles)
% hObject    handle to age_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
