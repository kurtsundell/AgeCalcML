function varargout = AgeCalcML_Nu_Hf(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@AgeCalcML_Nu_Hf_OpeningFcn,'gui_OutputFcn',@AgeCalcML_Nu_Hf_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function AgeCalcML_Nu_Hf_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
guidata(hObject, H);

function varargout = AgeCalcML_Nu_Hf_OutputFcn(hObject, eventdata, H) 
H.reduced = 0;
guidata(hObject,H);
varargout{1} = H.output;

function browser_Callback(hObject, eventdata, H)
cla(H.STDS_plot,'reset'); 
cla(H.SingleAnalysis_plot,'reset'); 
cla(H.Results_plot,'reset'); 

folder_name = uigetdir; %prompt browser and select folder

set(H.text1, 'String', folder_name); %show path name

H.folder_name = folder_name;
guidata(hObject,H);

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

Hf_cutoff = str2num(get(H.stdopt_Hfcutoff,'String'));
Yb_cutoff = str2num(get(H.stdopt_Ybcutoff,'String'));
Hf_bias = str2num(get(H.stdopt_Hfbias,'String'))*0.000028;
Yb_bias = str2num(get(H.stdopt_Ybbias,'String'));

INT_cutoff_stds = str2num(get(H.stdopt_intcutoff,'String'))/100;
INT_cutoff_unknowns = str2num(get(H.results_intcutoff,'String'))/100;
DM_Slider = get(H.results_dmt,'Value')*4500;

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

H.Ratio_STD_176_177_MT_mean = nonzeros(Ratio_STD_176_177_MT_mean);
Ratio_STD_176_177_MT_SE = nonzeros(Ratio_STD_176_177_MT_SE);
H.Yb_Lu_Hf_MT_mean = nonzeros(Yb_Lu_Hf_MT_mean);
v180_MT = nonzeros(v180_MT);

H.Ratio_STD_176_177_R33_mean = nonzeros(Ratio_STD_176_177_R33_mean);
Ratio_STD_176_177_R33_SE = nonzeros(Ratio_STD_176_177_R33_SE);
H.Yb_Lu_Hf_R33_mean = nonzeros(Yb_Lu_Hf_R33_mean);
v180_R33 = nonzeros(v180_R33);

H.Ratio_STD_176_177_PLES_mean = nonzeros(Ratio_STD_176_177_PLES_mean);
Ratio_STD_176_177_PLES_SE = nonzeros(Ratio_STD_176_177_PLES_SE);
H.Yb_Lu_Hf_PLES_mean = nonzeros(Yb_Lu_Hf_PLES_mean);
v180_PLES = nonzeros(v180_PLES);

H.Ratio_STD_176_177_FC_mean = nonzeros(Ratio_STD_176_177_FC_mean);
Ratio_STD_176_177_FC_SE = nonzeros(Ratio_STD_176_177_FC_SE);
H.Yb_Lu_Hf_FC_mean = nonzeros(Yb_Lu_Hf_FC_mean);
v180_FC = nonzeros(v180_FC);

H.Ratio_STD_176_177_TEM_mean = nonzeros(Ratio_STD_176_177_TEM_mean);
Ratio_STD_176_177_TEM_SE = nonzeros(Ratio_STD_176_177_TEM_SE);
H.Yb_Lu_Hf_TEM_mean = nonzeros(Yb_Lu_Hf_TEM_mean);
v180_TEM = nonzeros(v180_TEM);

H.Ratio_STD_176_177_91500_mean = nonzeros(Ratio_STD_176_177_91500_mean);
Ratio_STD_176_177_91500_SE = nonzeros(Ratio_STD_176_177_91500_SE);
H.Yb_Lu_Hf_91500_mean = nonzeros(Yb_Lu_Hf_91500_mean);
v180_91500 = nonzeros(v180_91500);

H.Ratio_STD_176_177_SL_mean = nonzeros(Ratio_STD_176_177_SL_mean);
Ratio_STD_176_177_SL_SE = nonzeros(Ratio_STD_176_177_SL_SE);
H.Yb_Lu_Hf_SL_mean = nonzeros(Yb_Lu_Hf_SL_mean);
v180_SL = nonzeros(v180_SL);

if sum(SAMPLES_idx) > 0
	H.Ratio_UNKNOWN_176_177_mean = nonzeros(Ratio_UNKNOWN_176_177_mean);
	Ratio_UNKNOWN_176_177_SE = nonzeros(Ratio_UNKNOWN_176_177_SE);
	H.Yb_Lu_Hf_UNKNOWN_mean = nonzeros(Yb_Lu_Hf_UNKNOWN_mean);
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
if get(H.stds_MT,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_MT_mean) - 0.282507;
end
if get(H.stds_91500,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_91500_mean) - 0.282313;
end
if get(H.stds_TEM,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_TEM_mean) - 0.282686;
end
if get(H.stds_PLES,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_PLES_mean) - 0.282484;
end
if get(H.stds_FC,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_FC_mean) - 0.282183;
end
if get(H.stds_SL,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_SL_mean) - 0.282163;
end
if get(H.stds_R33,'Value') == 1
	STD_offset(end+1,1) = mean(Ratio_STD_176_177_R33_mean) - 0.282764; % R33 STD should end in 1 to be consistent
end

STD_offset_avg = mean(STD_offset);
set(H.stdopt_STDoffset,'String',sprintf('%f',STD_offset_avg))

STD_SE_avg = mean([Ratio_STD_176_177_MT_SE; Ratio_STD_176_177_R33_SE; Ratio_STD_176_177_PLES_SE; Ratio_STD_176_177_FC_SE; Ratio_STD_176_177_TEM_SE; ...
	Ratio_STD_176_177_91500_SE; Ratio_STD_176_177_SL_SE]);
set(H.stdopt_STDSE,'String',sprintf('%f',STD_SE_avg));
if sum(SAMPLES_idx) > 0
	set(H.unks_munc,'String',sprintf('%f',mean(Ratio_UNKNOWN_176_177_SE)));
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

set(H.stdopt_percret,'String',round(retained_stds_p,1))
set(H.unks_percret,'String',round(retained_unknowns_p,1))

reduced = 1;

close(h)

for i=1:length(sample)
	name_char(i,1)=(sample(i,1));
end

set(H.ind_listbox1, 'String', name_char);
set(H.ind_listbox1,'Value',length(sample));

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











H.SAMPLES_idx = SAMPLES_idx;

guidata(hObject,H);





stds_PLOT_Callback(hObject, eventdata, H)



















%{

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
%}






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

function stds_PLOT_Callback(hObject, eventdata, H)
axes(H.STDS_plot);
hold on
plot([-10, 90], [0.282761, 0.282761],'--','LineWidth',3,'Color',[0.58 0.58 0.58]) %R33 Bahlburg et al. 2010
plot([-10, 60], [0.282686, 0.282686],'--','LineWidth',3,'Color',[.6 .2 .4]) %TEM Woodhead and Hergt 2005
plot([-10, 10], [0.282507, 0.282507],'--','LineWidth',3,'Color',[.12 .71 .07]) %MT Woodhead and Hergt 2005
plot([-10, 10], [0.282484, 0.282484],'--','LineWidth',3,'Color',[.8 .6 1]) %PLES Slama et al. (2008)
plot([-10, 10], [0.282313, 0.282313],'--','LineWidth',3,'Color',[.2 .4 .4]) %91500 Fisher et al. 2014
plot([-10, 90], [0.282183, 0.282183],'--','LineWidth',3,'Color',[.2 .4 1]) %FC Fisher et al. 2014
plot([-10, 10], [0.28163, 0.28163],'--','LineWidth',3,'Color',[0.56 0.44 0.23]) %SL Woodhead and Hergt 2005
plot([-10, 10], [0.281697, 0.281697],'--','LineWidth',3,'Color',[0.56 0.44 0.23]) %SL Ping et al. (2004)-laser
plot([-10, 10], [0.281703, 0.281703],'--','LineWidth',3,'Color',[0.56 0.44 0.23]) %SL Kemp et al. (2006)-laser
plot([-10, 10], [0.281729, 0.281729],'--','LineWidth',3,'Color',[0.56 0.44 0.23]) %SL Wu et al. (2006)-laser

if sum(H.SAMPLES_idx) > 0
	h0 = scatter(H.Yb_Lu_Hf_UNKNOWN_mean, H.Ratio_UNKNOWN_176_177_mean, 50, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','w');
end
h1 = scatter(H.Yb_Lu_Hf_R33_mean, H.Ratio_STD_176_177_R33_mean, 150, 'MarkerEdgeColor','k', 'MarkerFaceColor',[0.58 0.58 0.58]);
h2 = scatter(H.Yb_Lu_Hf_TEM_mean, H.Ratio_STD_176_177_TEM_mean, 150, 'MarkerEdgeColor','k', 'MarkerFaceColor',[.6 .2 .4]);
h3 = scatter(H.Yb_Lu_Hf_MT_mean, H.Ratio_STD_176_177_MT_mean, 150, 'MarkerEdgeColor','k', 'MarkerFaceColor',[.12 .71 .07]);
h4 = scatter(H.Yb_Lu_Hf_PLES_mean, H.Ratio_STD_176_177_PLES_mean, 150, 'MarkerEdgeColor','k', 'MarkerFaceColor',[.8 .6 1]);
h5 = scatter(H.Yb_Lu_Hf_91500_mean, H.Ratio_STD_176_177_91500_mean, 150, 'MarkerEdgeColor','k', 'MarkerFaceColor',[.2 .4 .4]);
h6 = scatter(H.Yb_Lu_Hf_FC_mean, H.Ratio_STD_176_177_FC_mean, 150, 'MarkerEdgeColor','k', 'MarkerFaceColor',[.2 .4 1]);
h7 = scatter(H.Yb_Lu_Hf_SL_mean, H.Ratio_STD_176_177_SL_mean, 150, 'MarkerEdgeColor','k', 'MarkerFaceColor',[0.56 0.44 0.23]);
if sum(H.SAMPLES_idx) > 0
	legend([h0,h1,h2,h3,h4,h5,h6,h7],{'Unknowns','R33','Temora','Mud Tank','Plesovice','91500','FC','Sri Lanka'}, 'Location', 'southeast')
else
legend([h1,h2,h3,h4,h5,h6,h7],{'R33','Temora','Mud Tank','Plesovice','91500','FC','Sri Lanka'}, 'Location', 'southeast')
end
xlabel('176(Yb+Lu) / 176Hf (%)')
ylabel('176Hf/177Hf')
axis([-10 80 0.2813 0.2831])
hold off








function stds_MT_Callback(hObject, eventdata, H)
stds_PLOT_Callback(hObject, eventdata, H)
function stds_91500_Callback(hObject, eventdata, H)
stds_PLOT_Callback(hObject, eventdata, H)
function stds_TEM_Callback(hObject, eventdata, H)
stds_PLOT_Callback(hObject, eventdata, H)
function stds_PLES_Callback(hObject, eventdata, H)
stds_PLOT_Callback(hObject, eventdata, H)
function stds_FC_Callback(hObject, eventdata, H)
stds_PLOT_Callback(hObject, eventdata, H)
function stds_SL_Callback(hObject, eventdata, H)
stds_PLOT_Callback(hObject, eventdata, H)
function stds_R33_Callback(hObject, eventdata, H)
stds_PLOT_Callback(hObject, eventdata, H)



function stds_setscale_Callback(hObject, eventdata, H)
function stds_xmin_Callback(hObject, eventdata, H)
function stds_xmax_Callback(hObject, eventdata, H)
function stds_ymin_Callback(hObject, eventdata, H)
function stds_ymax_Callback(hObject, eventdata, H)
function stds_autoscale_Callback(hObject, eventdata, H)
function stds_accepted_Callback(hObject, eventdata, H)
function stds_unknowns_Callback(hObject, eventdata, H)
function stds_legend_Callback(hObject, eventdata, H)

function stdopt_AVG_Callback(hObject, eventdata, H)
function stdopt_LBL_Callback(hObject, eventdata, H)
function stdopt_SW_Callback(hObject, eventdata, H)
function stdopt_Hfbias_Callback(hObject, eventdata, H)
function stdopt_Ybbias_Callback(hObject, eventdata, H)
function stdopt_Hfcutoff_Callback(hObject, eventdata, H)
function stdopt_Ybcutoff_Callback(hObject, eventdata, H)
function stdopt_percrej_Callback(hObject, eventdata, H)
function stdopt_intcutoff_Callback(hObject, eventdata, H)

function ind_listbox1_Callback(hObject, eventdata, H)
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
function ind_180_Callback(hObject, eventdata, H)
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
function ind_176_177_Callback(hObject, eventdata, H)
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
function ind_SE_Callback(hObject, eventdata, H)
function AccRej_Callback(hObject, eventdata, H)
function EditSampleName_Callback(hObject, eventdata, H)

function results_data_Callback(hObject, eventdata, H)
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
function results_evolution_Callback(hObject, eventdata, H)
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
function results_epsilon_Callback(hObject, eventdata, H)
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
function results_dmt_Callback(hObject, eventdata, H)
str2num(get(H.DMtext,'String'));
set(H.DM_Slider, 'Value', str2num(get(H.DMtext,'String'))/4500);
function results_dms_Callback(hObject, eventdata, H)

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
function results_setscale_Callback(hObject, eventdata, H)
function results_xmin_Callback(hObject, eventdata, H)
function results_xmax_Callback(hObject, eventdata, H)
function results_ymin_Callback(hObject, eventdata, H)
function results_ymax_Callback(hObject, eventdata, H)
function results_autorejn_Callback(hObject, eventdata, H)
function results_legend_Callback(hObject, eventdata, H)
function results_rej_Callback(hObject, eventdata, H)
function results_autoscale_Callback(hObject, eventdata, H)
function results_intcutoff_Callback(hObject, eventdata, H)

function Export_Reduced_Callback(hObject, eventdata, H)
function Export_Plots_Callback(hObject, eventdata, H)
function Save_Session_Callback(hObject, eventdata, H)
function Upload_Session_Callback(hObject, eventdata, H)
