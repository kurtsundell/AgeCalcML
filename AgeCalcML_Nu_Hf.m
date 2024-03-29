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
H.reduced = 0;
H.folder_name = folder_name;
guidata(hObject,H);

function reduce_data_Callback(hObject, eventdata, H)



cla(H.STDS_plot,'reset');
cla(H.SingleAnalysis_plot,'reset');
cla(H.Results_plot,'reset');
set(H.ind_listbox1,'String','');

Hf_LBL = 0;
Hf_AVG = 1;
Hf_SW = 0;
Yb_LBL = 0;
Yb_AVG = 1;
Yb_SW = 0;

STD_MT = 'MT';
STD_R33 = 'R33';
STD_PLES = 'PLES';
STD_FC = 'FC';
STD_TEM = 'TEM';
STD_91500 = '91500';
STD_SL = 'SL';

Age_MT = 731;
Age_R33 = 419.3;
Age_PLES = 337.1;
Age_FC = 1099.5;
Age_TEM = 416.78;
Age_91500 = 1062.4;
Age_SL = 563.2;

%all 2s
Age_MTs = 0.2;
Age_R33s = 0.4;
Age_PLESs = 0.2;
Age_FCs = 0.5;
Age_TEMs = 0.33;
Age_91500s = 1.9;
Age_SLs = 4.8;

%if H.reduced == 0

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
filenames_sorted = natsortfiles(filenames);

TRA = 0;
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
	elseif isempty(findstr(char(filenames_sorted(i,1)), '.run')) == 0
		filename_data{i,1} = filenames_sorted(i,1);
	elseif isempty(findstr(char(filenames_sorted(i,1)), '.scancsv')) == 0
		filename_scancsv{i,1} = filenames_sorted(i,1);
		filename_scancsv(all(cellfun('isempty',filename_scancsv),2),:) = [];
		TRA = 1;
	end
end

filename_data(all(cellfun('isempty',filename_data),2),:) = [];

h = waitbar(0,'Reducing data. Please wait...');





if TRA == 0
	
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
	samp_length = length(BLS_180(:,1));
	data_count = length(sample);
end














if TRA == 1
	firstline = 74;
	cols = 13;
	
	
	if length(filename_scancsv) == 1
		if ispc == 1
			fullpathname_data = char(strcat(folder_name, '\', filename_data{1,1}));
		end
		if ismac == 1
			fullpathname_data = char(strcat(folder_name, '/', filename_data{1,1}));
		end
		
		if ispc == 1
			fullpathname_names = char(strcat(folder_name, '\', filename_scancsv{1,1}));
		end
		if ismac == 1
			fullpathname_names = char(strcat(folder_name, '/', filename_scancsv{1,1}));
		end
		
		
		
		
		
		Data = importdata(char(fullpathname_data),',',500000);
		
		if H.reduced == 0
			Names = importdata(fullpathname_names);
			Names = Names(2:end,1);
		end
		
		
		if H.reduced == 1
			Names = H.sample;
		end
		
		
		data_count = length(Names);
		
		
		
		
		
		if H.reduced == 0
			for i = 1:data_count
				name_tmp = char(Names(i,1));
				name_tmp_idx = strfind(name_tmp, '"');
				sample{i,:} = name_tmp(1,(name_tmp_idx(1,1)+1):(name_tmp_idx(1,2)-1));
				clear name_tmp name_tmp_idx
			end
		end
		
		if H.reduced == 1
			sample = H.sample;
		end
		
		
		
		
		
		
		
		%{
		if 50*length(sample)+firstline < length(Data(firstline:end,1))
			rws = 50*length(sample)+firstline;
		else
			rws = length(Data(firstline:end,1));
		end
		%}
		rws = length(Data(firstline:end,1));
		
		%rws = 50*length(sample)+firstline;
		values_tmp1{rws,cols} = [];
		for j = 1:rws
			values_all_cell(j,:) = regexp(Data(j+firstline-1), ',', 'split');
			values_tmp1(j,1:13) = values_all_cell{j,1}(1,1:13);
		end
		% patch for MATLAB versions earlier than 2018b, cell #11 has weirdness
		% with the 2021a update
		if verLessThan('matlab', '9.6') == 1
			for k = 1:cols
				values_tmp(:,k) = str2num(str2mat(values_tmp1(:,k)));
			end
		else
			for k = 1:cols
				if k ~= 12
					values_tmp(:,k) = str2num(str2mat(values_tmp1(:,k)));
				end
			end
			for j = 1:rws
				values_tmp(j,12) = str2num(strrep(cell2mat(values_all_cell{j,1}(1,12)),'"',''));
			end
		end
		
		%{
			values_tmp = zeros(length(Data(firstline:end,1)),cols);
			for j = 1:length(Data(firstline:end,1))
				values_all_cell = regexp(Data(j+firstline-1), ',', 'split');
				for k = 1:cols
					values_tmp(j,k) = str2num(cell2mat(values_all_cell{1,1}(1,k)));
				end
			end
		%}
		
		
		thresh = 0;
		
		for i = 1:rws
			if values_tmp(i,1) > thresh
				thresh180(i,1) = 1;
			else
				thresh180(i,1) = 0;
			end
		end
		
		for i = 2:rws-2
			if thresh180(i,1) == 1 && thresh180(i-1) == 0 && values_tmp(i+1,1) > thresh && values_tmp(i+2,1) > thresh && values_tmp(i+3,1) > thresh && values_tmp(i+4,1) > thresh && ...
					values_tmp(i-1,1) < thresh && values_tmp(i-2,1) < thresh && values_tmp(i-3,1) < thresh && values_tmp(i-4,1) < thresh
				t0_180(i,1) = values_tmp(i,cols-1);
				t0_idx(i,1) = values_tmp(i,cols-2);
			else
				t0_180(i,1) = 0;
			end
		end
		
		t0_180 = nonzeros(t0_180);
		t0_idx = nonzeros(t0_idx);
		diff_idx = diff(t0_idx);
		diff_ch =  median(diff_idx) < diff_idx - 10;
		%{
		figure
		hold on
		plot(1:1:length(values_tmp(:,1)),values_tmp(:,1))
		scatter(t0_idx,zeros(length(t0_idx),1),'filled')
		hold off
		%}
		
		
		
		
		%T Zero Find by Medians
		% Missing t0s (singles)
		if data_count > length(t0_idx) && sum(diff_ch) > 0
			for i = 1:length(diff_ch)
				if diff_ch(i,1) == 1
					t0_adj = t0_idx(1:i,1);
					t0_adj(i+1,1) = 0;
					t0_adj(i+2:i+2+length(t0_idx(i+2:end,1)),1) = t0_idx(i+1:end,1);
					t0_idx_bf = t0_adj(i,1);
					t0_idx_af = t0_adj(i+2,1);
					t0_adj(i+1,1) = round(t0_idx_bf + (t0_idx_af - t0_idx_bf)/2);
					t0_idx = t0_adj;
					diff_idx = diff(nonzeros(t0_adj));
					diff_ch =  median(diff_idx) < diff_idx - 10;
					clear t0_adj
				end
			end
			for i = 1:length(t0_idx)
				t0(i,1) = values_tmp(t0_idx(i,1),cols-1);
				t0_180(i,1) = values_tmp(t0_idx(i,1),cols-1);
			end
		else
			t0 = t0_180;
		end
		
		% Missing t0s (multiples)
		if data_count > length(t0_idx) && sum(diff_ch) > 0
			for i = 1:length(diff_ch)
				if diff_ch(i,1) == 1 && diff_idx(i,1) > 2*median(diff_idx)
					t0_adj = t0_idx(1:i,1);
					t0_div = round(diff_idx(i,1)/median(diff_idx),0);
					t0_adj(i+1:i+t0_div-1,1) = 0;
					t0_adj(i+t0_div:i+t0_div+length(t0_idx(i+2:end,1)),1) = t0_idx(i+1:end,1);
					t0_idx_bf = t0_adj(i,1);
					t0_idx_af = t0_adj(i+t0_div,1);
					t0_add = round((t0_idx_af - t0_idx_bf)/t0_div);
					for j = 1:t0_div - 1
						t0_adj(i+j,1) = t0_adj(i,1) + t0_add*j;
					end
					t0_idx = t0_adj;
					diff_idx = diff(nonzeros(t0_adj));
					diff_ch =  median(diff_idx) < diff_idx - 50;
					clear t0_adj
				end
			end
			for i = 1:length(t0_idx)
				t0(i,1) = values_tmp(t0_idx(i,1),cols-1);
				t0_180(i,1) = values_tmp(t0_idx(i,1),cols-1);
			end
		else
			t0 = t0_180;
		end
		
		start_idx = t0_idx - 7;
		end_idx = t0_idx + 38;
		sampl_length = end_idx(1,1)-start_idx(1,1)+1;
		
		%%% Indexes
		for i = 1:data_count
			values_all(1:sampl_length,1:cols,i) = values_tmp(start_idx(i,1):end_idx(i,1),1:cols);
			baseline(1:6,1:cols,i) = values_all(1:6,1:cols,i);
			integration(1:30,1:cols,i) = values_all(10:39,1:cols,i);
		end
		
		for j = 1:data_count
			for i = 1:length(baseline(:,j))
				if baseline(i,j) > median(baseline(:,j)) + 2*std(baseline(:,j)) || baseline(i,j) < median(baseline(:,j)) - 2*std(baseline(:,j))
					baseline(i,j) = 0;
				else
					baseline(i,j) = baseline(i,j);
				end
			end
		end
		
		samp_length = length(integration(:,1,1));
		
	end

	
	
	if length(filename_scancsv) > 1
		for p = 1:length(filename_data)
			if ispc == 1
				tmp1 = char(strcat(folder_name, '\', filename_data{p,1}));
				tmp2 = char(strcat(folder_name, '\', filename_scancsv{p,1}));
			end
			if ismac == 1
				tmp1 = char(strcat(folder_name, '/', filename_data{p,1}));
				tmp2 = char(strcat(folder_name, '/', filename_scancsv{p,1}));
			end
			fullpathname_data(p,1) = {tmp1};
			fullpathname_names(p,1) = {tmp2};
		end
		
		for p = 1:length(fullpathname_data)
			
			if p == 1
				data_length = 0;
			end
			
			Data = importdata(char(fullpathname_data(p,1)),',',500000);
			Names = importdata(fullpathname_names{p,1});
			Names = Names(2:end,1);
			data_count_tmp = length(Names);
			
			
			
			if H.reduced == 0
				
				for i = 1:data_count_tmp
					name_tmp = char(Names(i,1));
					name_tmp_idx = strfind(name_tmp, '"');
					sample{data_length+i,:} = name_tmp(1,(name_tmp_idx(1,1)+1):(name_tmp_idx(1,2)-1));
					clear name_tmp name_tmp_idx
				end
		
			end
			
			
			
			if H.reduced == 1
				sample = H.sample;
			end
			
			
			if 50*length(sample)+firstline < length(Data(firstline:end,1))
				rws = 50*length(sample)+firstline;
			else
				rws = length(Data(firstline:end,1));
			end
			
			
			

			if H.reduced == 0
			
			
			values_tmp1{rws,cols} = [];
			for j = 1:rws
				values_all_cell(j,:) = regexp(Data(j+firstline-1), ',', 'split');
				values_tmp1(j,1:13) = values_all_cell{j,1}(1,1:13);
			end
			% patch for MATLAB versions earlier than 2018b, cell #11 has weirdness
			% with the 2021a update
			if verLessThan('matlab', '9.6') == 1
				for k = 1:cols
					values_tmp(:,k) = str2num(str2mat(values_tmp1(:,k)));
				end
			else
				for k = 1:cols
					if k ~= 12
						values_tmp(:,k) = str2num(str2mat(values_tmp1(:,k)));
					end
				end
				for j = 1:rws
					values_tmp(j,12) = str2num(strrep(cell2mat(values_all_cell{j,1}(1,12)),'"',''));
				end
			end
			
			%{
				values_tmp = zeros(length(Data(firstline:end,1)),cols);
				for j = 1:length(Data(firstline:end,1))
					values_all_cell = regexp(Data(j+firstline-1), ',', 'split');
					for k = 1:cols
						values_tmp(j,k) = str2num(cell2mat(values_all_cell{1,1}(1,k)));
					end
				end
			%}
			
			thresh = 0;
			
			for i = 1:rws
				if values_tmp(i,1) > thresh
					thresh180(i,1) = 1;
				else
					thresh180(i,1) = 0;
				end
			end
			
			for i = 2:rws-2
				if thresh180(i,1) == 1 && thresh180(i-1) == 0 && values_tmp(i+1,1) > thresh && values_tmp(i+2,1) > thresh && values_tmp(i+3,1) > thresh && values_tmp(i+4,1) > thresh && ...
						values_tmp(i-1,1) < thresh && values_tmp(i-2,1) < thresh && values_tmp(i-3,1) < thresh && values_tmp(i-4,1) < thresh
					t0_180(i,1) = values_tmp(i,cols-1);
					t0_idx(i,1) = values_tmp(i,cols-2);
				else
					t0_180(i,1) = 0;
				end
			end
			
			t0_180 = nonzeros(t0_180);
			t0_idx = nonzeros(t0_idx);
			diff_idx = diff(t0_idx);
			diff_ch =  median(diff_idx) < diff_idx - 10;
			
			%{
			figure
			hold on
			plot(1:1:length(values_tmp(:,1)),values_tmp(:,1))
			scatter(t0_idx,zeros(length(t0_idx),1),'filled')
			hold off
			%}
			
			%T Zero Find by Medians
			% Missing t0s (singles)
			if data_count_tmp > length(t0_idx) && sum(diff_ch) > 0
				for i = 1:length(diff_ch)
					if diff_ch(i,1) == 1
						t0_adj = t0_idx(1:i,1);
						t0_adj(i+1,1) = 0;
						t0_adj(i+2:i+2+length(t0_idx(i+2:end,1)),1) = t0_idx(i+1:end,1);
						t0_idx_bf = t0_adj(i,1);
						t0_idx_af = t0_adj(i+2,1);
						t0_adj(i+1,1) = round(t0_idx_bf + (t0_idx_af - t0_idx_bf)/2);
						t0_idx = t0_adj;
						diff_idx = diff(nonzeros(t0_adj));
						diff_ch =  median(diff_idx) < diff_idx - 10;
						clear t0_adj
					end
				end
				for i = 1:length(t0_idx)
					t0(i,1) = values_tmp(t0_idx(i,1),cols-1);
					t0_180(i,1) = values_tmp(t0_idx(i,1),cols-1);
				end
			else
				t0 = t0_180;
			end
			
			% Missing t0s (multiples)
			if data_count_tmp > length(t0_idx) && sum(diff_ch) > 0
				for i = 1:length(diff_ch)
					if diff_ch(i,1) == 1 && diff_idx(i,1) > 2*median(diff_idx)
						t0_adj = t0_idx(1:i,1);
						t0_div = round(diff_idx(i,1)/median(diff_idx),0);
						t0_adj(i+1:i+t0_div-1,1) = 0;
						t0_adj(i+t0_div:i+t0_div+length(t0_idx(i+2:end,1)),1) = t0_idx(i+1:end,1);
						t0_idx_bf = t0_adj(i,1);
						t0_idx_af = t0_adj(i+t0_div,1);
						t0_add = round((t0_idx_af - t0_idx_bf)/t0_div);
						for j = 1:t0_div - 1
							t0_adj(i+j,1) = t0_adj(i,1) + t0_add*j;
						end
						t0_idx = t0_adj;
						diff_idx = diff(nonzeros(t0_adj));
						diff_ch =  median(diff_idx) < diff_idx - 50;
						clear t0_adj
					end
				end
				for i = 1:length(t0_idx)
					t0(i,1) = values_tmp(t0_idx(i,1),cols-1);
					t0_180(i,1) = values_tmp(t0_idx(i,1),cols-1);
				end
			else
				t0 = t0_180;
			end
			
			
			%%% Indexes
			
			start_idx = t0_idx - 7;
			end_idx = t0_idx + 38;
			sampl_length = end_idx(1,1)-start_idx(1,1)+1;
			
			%%% Indexes
			
			for i = 1:data_count_tmp
				values_all_tmp(1:sampl_length,1:cols,i) = values_tmp(start_idx(i,1):end_idx(i,1),1:cols);
				values_all(:,:,data_length+i) = values_all_tmp(:,:,i);
				baseline(1:6,1:cols,data_length+i) = values_all_tmp(1:6,1:cols,i);
				integration(1:30,1:cols,data_length+i) = values_all_tmp(10:39,1:cols,i);
			end
			
			
			end
			
			
			if H.reduced == 1
				values_all = H.values_all;
				baseline = H.baseline;
				integration = H.integration;
			end
			
			
			
			
			
			samp_length = length(integration(:,1,1));
			data_length = length(sample);
			
			clear Data Names data_count_tmp	values_tmp values_tmp1 values_all_cell thresh180 t0_180 t0_idx diff_idx start_idx end_idx
			
		end
		data_count = length(sample);
	end
	
	
	for i = 1:data_count
		mean180BL(i,1) = mean(nonzeros(baseline(:,1,i)));
		mean179BL(i,1) = mean(nonzeros(baseline(:,2,i)));
		mean178BL(i,1) = mean(nonzeros(baseline(:,3,i)));
		mean177BL(i,1) = mean(nonzeros(baseline(:,4,i)));
		mean176BL(i,1) = mean(nonzeros(baseline(:,5,i)));
		mean175BL(i,1) = mean(nonzeros(baseline(:,6,i)));
		mean174BL(i,1) = mean(nonzeros(baseline(:,7,i)));
		mean173BL(i,1) = mean(nonzeros(baseline(:,8,i)));
		mean172BL(i,1) = mean(nonzeros(baseline(:,9,i)));
		mean171BL(i,1) = mean(nonzeros(baseline(:,10,i)));
	end
	
	%{
		for i = 1:data_count
			SE180BL(i,1) = std(baseline(:,1,i))./sqrt(length(baseline(:,1,i)))./abs(mean180BL(i,1)).*100;
			SE179BL(i,1) = std(baseline(:,2,i))./sqrt(length(baseline(:,2,i)))./abs(mean179BL(i,1)).*100;
			SE178BL(i,1) = std(baseline(:,3,i))./sqrt(length(baseline(:,3,i)))./abs(mean178BL(i,1)).*100;
			SE177BL(i,1) = std(baseline(:,4,i))./sqrt(length(baseline(:,4,i)))./abs(mean177BL(i,1)).*100;
			SE176BL(i,1) = std(baseline(:,5,i))./sqrt(length(baseline(:,5,i)))./abs(mean176BL(i,1)).*100;
			SE175BL(i,1) = std(baseline(:,6,i))./sqrt(length(baseline(:,6,i)))./abs(mean175BL(i,1)).*100;
			SE174BL(i,1) = std(baseline(:,7,i))./sqrt(length(baseline(:,7,i)))./abs(mean174BL(i,1)).*100;
			SE173BL(i,1) = std(baseline(:,8,i))./sqrt(length(baseline(:,8,i)))./abs(mean173BL(i,1)).*100;
			SE172BL(i,1) = std(baseline(:,9,i))./sqrt(length(baseline(:,9,i)))./abs(mean172BL(i,1)).*100;
			SE171BL(i,1) = std(baseline(:,10,i))./sqrt(length(baseline(:,10,i)))./abs(mean171BL(i,1)).*100;
		end
	%}
	
	for i = 1:data_count
		BLS_180(:,i) = integration(:,1,i) - mean180BL(i,1);
		BLS_179(:,i) = integration(:,2,i) - mean179BL(i,1);
		BLS_178(:,i) = integration(:,3,i) - mean178BL(i,1);
		BLS_177(:,i) = integration(:,4,i) - mean177BL(i,1);
		BLS_176(:,i) = integration(:,5,i) - mean176BL(i,1);
		BLS_175(:,i) = integration(:,6,i) - mean175BL(i,1);
		BLS_174(:,i) = integration(:,7,i) - mean174BL(i,1);
		BLS_173(:,i) = integration(:,8,i) - mean173BL(i,1);
		BLS_172(:,i) = integration(:,9,i) - mean172BL(i,1);
		BLS_171(:,i) = integration(:,10,i) - mean171BL(i,1);
	end
	
end

























%end


%{
for j = 1:data_count
	for i = 1:samp_length
		if BLS_173(i,j)/BLS_171(i,j) > median(BLS_173(:,j)./BLS_171(:,j)) + 2*std(BLS_173(:,j)./BLS_171(:,j)) ||...
				BLS_173(i,j)/BLS_171(i,j) < median(BLS_173(:,j)./BLS_171(:,j)) - 2*std(BLS_173(:,j)./BLS_171(:,j))
			BLS_173(i,j) = 0;
			BLS_171(i,j) = 0;
		end
	end
end
%}


for j = 1:data_count
	for i = 1:samp_length
		if BLS_176(i,j)/BLS_177(i,j) > median(BLS_176(:,j)./BLS_177(:,j)) + 2*std(BLS_176(:,j)./BLS_177(:,j)) ||...
				BLS_176(i,j)/BLS_177(i,j) < median(BLS_176(:,j)./BLS_177(:,j)) - 2*std(BLS_176(:,j)./BLS_177(:,j))
			BLS_176(i,j) = 0;
			BLS_177(i,j) = 0;
			BLS_178(i,j) = 0;
		end
	end
end


%{
for j = 1:data_count
	for i = 1:samp_length
		if BLS_175(i,j)/BLS_171(i,j) > median(BLS_175(:,j)./BLS_171(:,j)) + 2*std(BLS_175(:,j)./BLS_171(:,j)) ||...
				BLS_175(i,j)/BLS_171(i,j) < median(BLS_175(:,j)./BLS_171(:,j)) - 2*std(BLS_175(:,j)./BLS_171(:,j))
			BLS_175(i,j) = 0;
			BLS_171(i,j) = 0;
		end
	end
end
%}


%cla(H.STDS_plot,'reset');
cla(H.SingleAnalysis_plot,'reset');
cla(H.Results_plot,'reset');

Hf_cutoff = str2num(get(H.stdopt_Hfcutoff,'String'));
Yb_cutoff = str2num(get(H.stdopt_Ybcutoff,'String'));
Hf_bias = str2num(get(H.stdopt_Hfbias,'String'))*0.000028;
Yb_bias = str2num(get(H.stdopt_Ybbias,'String'));

INT_cutoff_stds = str2num(get(H.stdopt_intcutoff,'String'))/100;
INT_cutoff_unknowns = str2num(get(H.results_intcutoff,'String'))/100;








if length(filename_scancsv) == 1
	
	
	if data_count ~= length(t0_idx)
		close(h)
		f = errordlg('T zero identification failed! Have a quick look at the Hf180 time series....','File Error');
		
		
		figure
		hold on
		plot(values_tmp(:,12),values_tmp(:,1))
		scatter(t0_180,0.1*ones(length(t0_180)),'filled')
		xlabel('Time (s)')
		ylabel('180Hf')
		dim = [.2 .5 .3 .3];
		str = strcat('sample n = ', {' '}, mat2str(data_count), {'   '}, 't zeros = ',{' '}, mat2str(length(t0_180)));
		annotation('textbox',dim,'String',str,'FitBoxToText','on');
		if data_count == length(t0_180)
			labelpoints (t0_180,zeros(length(t0_180),1), sample);
		else
			labelpoints (t0_180,zeros(length(t0_180),1), [1:1:length(t0_180)]);
		end
		
		figure
		hold on
		plot(values_tmp(:,11),values_tmp(:,1))
		scatter(t0_idx,0.1*ones(length(t0_idx)),'filled')
		xlabel('Index')
		ylabel('180Hf')
		dim = [.2 .5 .3 .3];
		str = strcat('sample n = ', {' '}, mat2str(data_count), {'   '}, 't zeros = ',{' '}, mat2str(length(t0_idx)));
		annotation('textbox',dim,'String',str,'FitBoxToText','on');
		if data_count == length(t0_idx)
			labelpoints (t0_180,zeros(length(t0_idx),1), sample);
		else
			labelpoints (t0_idx,zeros(length(t0_idx),1), [1:1:length(t0_idx)]);
		end
		
		
		return
		
		
		
		
	end
	
	
	
end






Analysis_num = (1:1:length(sample))';





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












for i = 1:samp_length
	for j = 1:length(sample)
		if BLS_176(i,j) == 0 || BLS_177(i,j) == 0
			BetaHf(i,j) = 0;
		else
			BetaHf(i,j) = (log(0.73250./(abs(BLS_179(i,j)./BLS_177(i,j)))))/(log(178.94583/176.94323)); %0.73250 from Patchett & Tatsumoto (1980)
		end
	end
end
%{
for i = 1:samp_length
	for j = 1:length(sample)
		if BLS_180(i,j) > Hf_cutoff
			BHf_gt_int(i,j) = BetaHf(i,j);
		else
			BHf_gt_int(i,j) = 0;
		end
	end
end
%}

%BHf_SW Need to code this. Col AI in HfCalc 70.

for i = 1:length(sample)
	BetaYb(:,i) = (log(1.132338*(1+Yb_bias/40000)./(abs(BLS_173(:,i)./BLS_171(:,i)))))/(log(172.93822/170.93634)); %173/171 1.132338 from Vervoort et al. (2004)
end

for i = 1:samp_length
	for j = 1:length(sample)
		if BLS_176(i,j) == 0 || BLS_177(i,j) == 0
			Lu176V(i,j) = 0;
		else
			Lu176V(i,j) = (BLS_175(i,j)*0.02653)/((175.94269/174.94079)^(mean(BetaYb(:,j)))); %0.02653 from Patchett (1983) -- update to 0.02669 (Debrieve & Taylor)?
		end
	end
end

for i = 1:samp_length
	for j = 1:length(sample)
		if BLS_176(i,j) == 0 || BLS_177(i,j) == 0
			Yb176V(i,j) = 0;
		else
			Yb176V(i,j) = (BLS_171(i,j)*0.901691)/((175.94258/170.93634)^(mean(BetaYb(:,j)))); %0.901691 from Vervoort et al. (2004)
		end
	end
end

for i = 1:samp_length
	for j = 1:length(sample)
		if BLS_176(i,j) == 0 || BLS_177(i,j) == 0
			All(i,j) = 0;
		else
			All(i,j) = ((BLS_176(i,j)-Lu176V(i,j)-Yb176V(i,j))/(BLS_177(i,j)))*((175.94142/176.94323)^(mean(nonzeros(BetaHf(:,j)))));
		end
	end
end

waitbar(.8)

%{
for j = 1:data_count
	for i = 1:samp_length
		if All(i,j) > median(nonzeros(All(:,j))) + 2*std(nonzeros(All(:,j))) || All(i,j) < median(nonzeros(All(:,j))) - 2*std(nonzeros(All(:,j)))
			All(i,j) = 0;
		end
	end
end
%}






if TRA == 0
	for j = 1:length(sample)
		for i = 1:samp_length
			if All(i,j) ~= 0
				if values_all(i,11,j) > 0.7*max(values_all(:,11,j))
					Yb_Lu_Hf(i,j) = 100*(Lu176V(i,j)+Yb176V(i,j))/(BLS_177(i,j)*All(i,j));
				else
					Yb_Lu_Hf(i,j) = 0;
				end
			end
		end
	end
	for i = 1:samp_length
		for j = 1:length(sample)
			if All(i,j) ~= 0
				if values_all(i,11,j) > INT_cutoff_stds*max(values_all(:,11,j)) && SAMPLES_idx(j,1) == 0
					Filter_INT(i,j) = All(i,j);
				elseif values_all(i,11,j) > INT_cutoff_unknowns*max(values_all(:,11,j)) && SAMPLES_idx(j,1) == 1
					Filter_INT(i,j) = All(i,j);
				else
					Filter_INT(i,j) = 0;
				end
			end
		end
	end
end


if TRA == 1
	for j = 1:length(sample)
		for i = 1:samp_length
			if All(i,j) ~= 0
				if integration(i,1,j) > 0.7*max(integration(:,1,j))
					Yb_Lu_Hf(i,j) = 100*(Lu176V(i,j)+Yb176V(i,j))/(BLS_177(i,j)*All(i,j));
				else
					Yb_Lu_Hf(i,j) = 0;
				end
			end
		end
	end
	for i = 1:samp_length
		for j = 1:length(sample)
			if All(i,j) ~= 0
				if integration(i,1,j) > INT_cutoff_stds*max(integration(:,1,j)) && SAMPLES_idx(j,1) == 0
					Filter_INT(i,j) = All(i,j);
				elseif integration(i,1,j) > INT_cutoff_unknowns*max(integration(:,1,j)) && SAMPLES_idx(j,1) == 1
					Filter_INT(i,j) = All(i,j);
				else
					Filter_INT(i,j) = 0;
				end
			end
		end
	end
end







for i = 1:samp_length
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

for i = 1:samp_length
	for j = 1:length(sample)
		if Filter_MAXMIN(i,j) > mean(nonzeros(Filter_MAXMIN(:,j))) + 2*std(nonzeros(Filter_MAXMIN(:,j))) || ...
				Filter_MAXMIN(i,j) < mean(nonzeros(Filter_MAXMIN(:,j))) - 2*std(nonzeros(Filter_MAXMIN(:,j)))
			Filter_95(i,j) = 0;
		else
			Filter_95(i,j) = Filter_MAXMIN(i,j);
		end
	end
end

%{
%if TRA == 0
	for i = 1:length(sample)
		if BLS_180(30,i) < 0.1
			BLS_180(:,i) = 0;
			BLS_179(:,i) = 0;
			BLS_178(:,i) = 0;
			BLS_177(:,i) = 0;
			BLS_176(:,i) = 0;
			BLS_175(:,i) = 0;
			BLS_174(:,i) = 0;
			BLS_173(:,i) = 0;
			BLS_172(:,i) = 0;
			BLS_171(:,i) = 0;
		end
	end
%end
%}



%if get(H.flagunknowns,'Value') == 1
	EL = Filter_95;
	for j = 1:length(sample)
		if STD_idx(j,1) == 1
			for i = 1:10
				STDSE_EL = std(nonzeros(EL(:,j)))/sqrt(length(nonzeros(EL(:,j))));
				testsamp = EL(:,j);
				testsamp(i,1) = 0;
				STDSE_testsamp = std(nonzeros(testsamp))/sqrt(length(nonzeros(testsamp)));
				if STDSE_testsamp < STDSE_EL
					EL(i,j) = 0;
				end
			end
		end
	end
	
	for j = 1:length(sample)
		if STD_idx(j,1) == 1
			for i = 21:30
				STDSE_EL = std(nonzeros(EL(:,j)))/sqrt(length(nonzeros(EL(:,j))));
				testsamp = EL(:,j);
				testsamp(i,1) = 0;
				STDSE_testsamp = std(nonzeros(testsamp))/sqrt(length(nonzeros(testsamp)));
				if STDSE_testsamp < STDSE_EL
					EL(i,j) = 0;
				end
			end
		end
	end
	Filter_95 = EL;
%end


%if get(H.filterstandards,'Value') == 1
	EL = Filter_95;
	for j = 1:length(sample)
		if SAMPLES_idx(j,1) == 1
			for i = 51:60
				STDSE_EL = std(nonzeros(EL(:,j)))/sqrt(length(nonzeros(EL(:,j))));
				testsamp = EL(:,j);
				testsamp(i,1) = 0;
				STDSE_testsamp = std(nonzeros(testsamp))/sqrt(length(nonzeros(testsamp)));
				if STDSE_testsamp < STDSE_EL
					EL(i,j) = 0;
				end
			end
		end
	end
	for j = 1:length(sample)
		if SAMPLES_idx(j,1) == 1
			for i = 1:10
				STDSE_EL = std(nonzeros(EL(:,j)))/sqrt(length(nonzeros(EL(:,j))));
				testsamp = EL(:,j);
				testsamp(i,1) = 0;
				STDSE_testsamp = std(nonzeros(testsamp))/sqrt(length(nonzeros(testsamp)));
				if STDSE_testsamp < STDSE_EL
					EL(i,j) = 0;
				end
			end
		end
	end
	for j = 1:length(sample)
		if SAMPLES_idx(j,1) == 1
			for i = 21:30
				STDSE_EL = std(nonzeros(EL(:,j)))/sqrt(length(nonzeros(EL(:,j))));
				testsamp = EL(:,j);
				testsamp(i,1) = 0;
				STDSE_testsamp = std(nonzeros(testsamp))/sqrt(length(nonzeros(testsamp)));
				if STDSE_testsamp < STDSE_EL
					EL(i,j) = 0;
				end
			end
		end
	end
	Filter_95 = EL;
%end






%{
%if TRA == 0
	for i = 1:length(sample)
		if BLS_180(30,i) < 0.1
			Filter_95(:,i) = 0;
		end
	end

	count = 1;
	for i = 1:length(sample)
		if SAMPLES_idx(i,1) == 1
			Filter_95_unks(:,count) = Filter_95(:,i);
			count = count + 1;
		end
	end
%end
%}




waitbar(.9)

for j = 1:length(sample)
	ALL_176_177_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
	ALL_176_177_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
	ALL_Yb_Lu_Hf_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
	ALL_v180(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
%{	
	if STD_MT_idx(j,1) == 1
		Ratio_STD_176_177_MT_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_MT_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_MT_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_MT(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	end
	if STD_MT_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282507) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_MT_idx(j,1) = 0;
		Ratio_STD_176_177_MT_mean(j,1) = 0;
		Ratio_STD_176_177_MT_SE(j,1) = 0;
		Yb_Lu_Hf_MT_mean(j,1) = 0;
		v180_MT(j,1) = 0;
	end
	
	if STD_R33_idx(j,1) == 1
		Ratio_STD_176_177_R33_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_R33_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_R33_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_R33(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	end
	if STD_R33_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282739) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_R33_idx(j,1) = 0;
		Ratio_STD_176_177_R33_mean(j,1) = 0;
		Ratio_STD_176_177_R33_SE(j,1) = 0;
		Yb_Lu_Hf_R33_mean(j,1) = 0;
		v180_R33(j,1) = 0;
	end
	
	if STD_PLES_idx(j,1) == 1
		Ratio_STD_176_177_PLES_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_PLES_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_PLES_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_PLES(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	end
	if STD_PLES_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282484) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_PLES_idx(j,1) = 0;
		Ratio_STD_176_177_PLES_mean(j,1) = 0;
		Ratio_STD_176_177_PLES_SE(j,1) = 0;
		Yb_Lu_Hf_PLES_mean(j,1) = 0;
		v180_PLES(j,1) = 0;
	end
	
	if STD_FC_idx(j,1) == 1
		Ratio_STD_176_177_FC_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_FC_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_FC_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_FC(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	end 
	if STD_FC_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282157) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_FC_idx(j,1) = 0;
		Ratio_STD_176_177_FC_mean(j,1) = 0;
		Ratio_STD_176_177_FC_SE(j,1) = 0;
		Yb_Lu_Hf_FC_mean(j,1) = 0;
		v180_FC(j,1) = 0;
	end
	
	if STD_TEM_idx(j,1) == 1
		Ratio_STD_176_177_TEM_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_TEM_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_TEM_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_TEM(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	end
	if STD_TEM_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282686) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_TEM_idx(j,1) = 0;
		Ratio_STD_176_177_TEM_mean(j,1) =0;
		Ratio_STD_176_177_TEM_SE(j,1) = 0;
		Yb_Lu_Hf_TEM_mean(j,1) = 0;
		v180_TEM(j,1) = 0;
	end
	
	if STD_91500_idx(j,1) == 1
		Ratio_STD_176_177_91500_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_91500_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		Yb_Lu_Hf_91500_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_91500(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));
	end
	if STD_91500_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282298) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_91500_idx(j,1) = 0;
		Ratio_STD_176_177_91500_mean(j,1) = 0;
		Ratio_STD_176_177_91500_SE(j,1) = 0;
		Yb_Lu_Hf_91500_mean(j,1) = 0;
		v180_91500(j,1) = 0;
	end
%}	
	
	
	if STD_R33_idx(j,1) == 1
		Ratio_STD_176_177_R33_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_R33_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		LuHf_R33(j,1) = mean(nonzeros(Lu176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		LuHf_R33s(j,1) = (std(nonzeros(Lu176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		YbHf_R33(j,1) = mean(nonzeros(Yb176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		YbHf_R33s(j,1) = (std(nonzeros(Yb176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_R33(j,1) = mean(nonzeros(BLS_178(:,j)))/mean(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_R33s(j,1) = (std(nonzeros(BLS_178(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		Yb_Lu_Hf_R33_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_R33(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));	
	end
	if STD_R33_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282739) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_R33_idx(j,1) = 0;
		Ratio_STD_176_177_R33_mean(j,1) = 0;
		Ratio_STD_176_177_R33_SE(j,1) = 0;
		LuHf_R33(j,1) = 0;
		LuHf_R33s(j,1) = 0;		
		YbHf_R33(j,1) = 0;
		YbHf_R33s(j,1) = 0;		
		Hf178_Hf177_R33(j,1) = 0;
		Hf178_Hf177_R33s(j,1) = 0;		
		Yb_Lu_Hf_R33_mean(j,1) = 0;
		v180_R33(j,1) = 0;
	end	
	
	if STD_TEM_idx(j,1) == 1
		Ratio_STD_176_177_TEM_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_TEM_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		LuHf_TEM(j,1) = mean(nonzeros(Lu176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		LuHf_TEMs(j,1) = (std(nonzeros(Lu176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		YbHf_TEM(j,1) = mean(nonzeros(Yb176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		YbHf_TEMs(j,1) = (std(nonzeros(Yb176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_TEM(j,1) = mean(nonzeros(BLS_178(:,j)))/mean(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_TEMs(j,1) = (std(nonzeros(BLS_178(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		Yb_Lu_Hf_TEM_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_TEM(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));	
	end
	if STD_TEM_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282686) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_TEM_idx(j,1) = 0;
		Ratio_STD_176_177_TEM_mean(j,1) = 0;
		Ratio_STD_176_177_TEM_SE(j,1) = 0;
		LuHf_TEM(j,1) = 0;
		LuHf_TEMs(j,1) = 0;		
		YbHf_TEM(j,1) = 0;
		YbHf_TEMs(j,1) = 0;		
		Hf178_Hf177_TEM(j,1) = 0;
		Hf178_Hf177_TEMs(j,1) = 0;		
		Yb_Lu_Hf_TEM_mean(j,1) = 0;
		v180_TEM(j,1) = 0;
	end	
	
	if STD_MT_idx(j,1) == 1
		Ratio_STD_176_177_MT_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		if length(nonzeros(Filter_95(:,j))) > 1
			Ratio_STD_176_177_MT_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		elseif length(nonzeros(Filter_95(:,j))) == 1
			Ratio_STD_176_177_MT_SE(j,1) = 0.0000000001;
		end
		LuHf_MT(j,1) = mean(nonzeros(Lu176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		LuHf_MTs(j,1) = (std(nonzeros(Lu176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		YbHf_MT(j,1) = mean(nonzeros(Yb176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		YbHf_MTs(j,1) = (std(nonzeros(Yb176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_MT(j,1) = mean(nonzeros(BLS_178(:,j)))/mean(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_MTs(j,1) = (std(nonzeros(BLS_178(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		Yb_Lu_Hf_MT_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_MT(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));	
	end
	if STD_MT_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282507) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_MT_idx(j,1) = 0;
		Ratio_STD_176_177_MT_mean(j,1) = 0;
		Ratio_STD_176_177_MT_SE(j,1) = 0;
		LuHf_MT(j,1) = 0;
		LuHf_MTs(j,1) = 0;		
		YbHf_MT(j,1) = 0;
		YbHf_MTs(j,1) = 0;		
		Hf178_Hf177_MT(j,1) = 0;
		Hf178_Hf177_MTs(j,1) = 0;		
		Yb_Lu_Hf_MT_mean(j,1) = 0;
		v180_MT(j,1) = 0;
	end	
	
	if STD_PLES_idx(j,1) == 1
		Ratio_STD_176_177_PLES_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_PLES_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		LuHf_PLES(j,1) = mean(nonzeros(Lu176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		LuHf_PLESs(j,1) = (std(nonzeros(Lu176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		YbHf_PLES(j,1) = mean(nonzeros(Yb176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		YbHf_PLESs(j,1) = (std(nonzeros(Yb176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_PLES(j,1) = mean(nonzeros(BLS_178(:,j)))/mean(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_PLESs(j,1) = (std(nonzeros(BLS_178(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		Yb_Lu_Hf_PLES_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_PLES(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));	
	end
	if STD_PLES_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282484) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_PLES_idx(j,1) = 0;
		Ratio_STD_176_177_PLES_mean(j,1) = 0;
		Ratio_STD_176_177_PLES_SE(j,1) = 0;
		LuHf_PLES(j,1) = 0;
		LuHf_PLESs(j,1) = 0;		
		YbHf_PLES(j,1) = 0;
		YbHf_PLESs(j,1) = 0;		
		Hf178_Hf177_PLES(j,1) = 0;
		Hf178_Hf177_PLESs(j,1) = 0;		
		Yb_Lu_Hf_PLES_mean(j,1) = 0;
		v180_PLES(j,1) = 0;
	end	
	
	if STD_91500_idx(j,1) == 1
		Ratio_STD_176_177_91500_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_91500_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		LuHf_91500(j,1) = mean(nonzeros(Lu176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		LuHf_91500s(j,1) = (std(nonzeros(Lu176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		YbHf_91500(j,1) = mean(nonzeros(Yb176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		YbHf_91500s(j,1) = (std(nonzeros(Yb176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_91500(j,1) = mean(nonzeros(BLS_178(:,j)))/mean(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_91500s(j,1) = (std(nonzeros(BLS_178(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		Yb_Lu_Hf_91500_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_91500(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));	
	end
	if STD_91500_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282298) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_91500_idx(j,1) = 0;
		Ratio_STD_176_177_91500_mean(j,1) = 0;
		Ratio_STD_176_177_91500_SE(j,1) = 0;
		LuHf_91500(j,1) = 0;
		LuHf_91500s(j,1) = 0;		
		YbHf_91500(j,1) = 0;
		YbHf_91500s(j,1) = 0;		
		Hf178_Hf177_91500(j,1) = 0;
		Hf178_Hf177_91500s(j,1) = 0;		
		Yb_Lu_Hf_91500_mean(j,1) = 0;
		v180_91500(j,1) = 0;
	end	
	
	if STD_FC_idx(j,1) == 1
		Ratio_STD_176_177_FC_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_FC_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		LuHf_FC(j,1) = mean(nonzeros(Lu176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		LuHf_FCs(j,1) = (std(nonzeros(Lu176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		YbHf_FC(j,1) = mean(nonzeros(Yb176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		YbHf_FCs(j,1) = (std(nonzeros(Yb176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_FC(j,1) = mean(nonzeros(BLS_178(:,j)))/mean(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_FCs(j,1) = (std(nonzeros(BLS_178(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		Yb_Lu_Hf_FC_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_FC(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));	
	end
	if STD_FC_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.282157) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1
		sample(j,1) = {'xx'};
		STD_FC_idx(j,1) = 0;
		Ratio_STD_176_177_FC_mean(j,1) = 0;
		Ratio_STD_176_177_FC_SE(j,1) = 0;
		LuHf_FC(j,1) = 0;
		LuHf_FCs(j,1) = 0;		
		YbHf_FC(j,1) = 0;
		YbHf_FCs(j,1) = 0;		
		Hf178_Hf177_FC(j,1) = 0;
		Hf178_Hf177_FCs(j,1) = 0;		
		Yb_Lu_Hf_FC_mean(j,1) = 0;
		v180_FC(j,1) = 0;
	end	
	
	if STD_SL_idx(j,1) == 1 && length(nonzeros(Filter_95(:,j))) > 1
		Ratio_STD_176_177_SL_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		Ratio_STD_176_177_SL_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		LuHf_SL(j,1) = mean(nonzeros(Lu176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		LuHf_SLs(j,1) = (std(nonzeros(Lu176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		YbHf_SL(j,1) = mean(nonzeros(Yb176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		YbHf_SLs(j,1) = (std(nonzeros(Yb176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_SL(j,1) = mean(nonzeros(BLS_178(:,j)))/mean(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_SLs(j,1) = (std(nonzeros(BLS_178(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		Yb_Lu_Hf_SL_mean(j,1) = mean(nonzeros(Yb_Lu_Hf(:,j)));
		v180_SL(j,1) = mean(nonzeros(BLS_177(:,j)./0.186));	
	end
	if STD_SL_idx(j,1) == 1 && abs(mean(nonzeros(Filter_95(:,j))) + Hf_bias - 0.28170) > str2num(get(H.flag,'String')) && get(H.filterstandards,'Value') == 1 || ...
			length(nonzeros(Filter_95(:,j))) <= 1
		sample(j,1) = {'xx'};
		STD_SL_idx(j,1) = 0;
		Ratio_STD_176_177_SL_mean(j,1) = 0;
		Ratio_STD_176_177_SL_SE(j,1) = 0;
		LuHf_SL(j,1) = 0;
		LuHf_SLs(j,1) = 0;		
		YbHf_SL(j,1) = 0;
		YbHf_SLs(j,1) = 0;		
		Hf178_Hf177_SL(j,1) = 0;
		Hf178_Hf177_SLs(j,1) = 0;		
		Yb_Lu_Hf_SL_mean(j,1) = 0;
		v180_SL(j,1) = 0;
	end
	
	if SAMPLES_idx(j,1) == 1
		Ratio_UNKNOWN_176_177_mean(j,1) = mean(nonzeros(Filter_95(:,j))) + Hf_bias;
		if std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j)))) == 0
			Ratio_UNKNOWN_176_177_SE(j,1) = 0.0000000001;
		else
			Ratio_UNKNOWN_176_177_SE(j,1) = std(nonzeros(Filter_95(:,j)))/sqrt(length(nonzeros(Filter_95(:,j))));
		end
		LuHf_UNKNOWN(j,1) = mean(nonzeros(Lu176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		LuHf_UNKNOWNs(j,1) = (std(nonzeros(Lu176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		YbHf_UNKNOWN(j,1) = mean(nonzeros(Yb176V(:,j)))/mean(nonzeros(BLS_177(:,j)));
		YbHf_UNKNOWNs(j,1) = (std(nonzeros(Yb176V(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
		Hf178_Hf177_UNKNOWN(j,1) = mean(nonzeros(BLS_178(:,j)))/mean(nonzeros(BLS_177(:,j)));
		Hf178_Hf177_UNKNOWNs(j,1) = (std(nonzeros(BLS_178(:,j))./nonzeros(BLS_177(:,j))))/length(nonzeros(BLS_177(:,j)));		
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
LuHf_MT = nonzeros(LuHf_MT);
LuHf_MTs = nonzeros(LuHf_MTs);
YbHf_MT = nonzeros(YbHf_MT);
YbHf_MTs = nonzeros(YbHf_MTs);
Hf178_Hf177_MT = nonzeros(Hf178_Hf177_MT);
Hf178_Hf177_MTs = nonzeros(Hf178_Hf177_MTs);

H.Ratio_STD_176_177_R33_mean = nonzeros(Ratio_STD_176_177_R33_mean);
Ratio_STD_176_177_R33_SE = nonzeros(Ratio_STD_176_177_R33_SE);
H.Yb_Lu_Hf_R33_mean = nonzeros(Yb_Lu_Hf_R33_mean);
v180_R33 = nonzeros(v180_R33);
LuHf_R33 = nonzeros(LuHf_R33);
LuHf_R33s = nonzeros(LuHf_R33s);
YbHf_R33 = nonzeros(YbHf_R33);
YbHf_R33s = nonzeros(YbHf_R33s);
Hf178_Hf177_R33 = nonzeros(Hf178_Hf177_R33);
Hf178_Hf177_R33s = nonzeros(Hf178_Hf177_R33s);

H.Ratio_STD_176_177_PLES_mean = nonzeros(Ratio_STD_176_177_PLES_mean);
Ratio_STD_176_177_PLES_SE = nonzeros(Ratio_STD_176_177_PLES_SE);
H.Yb_Lu_Hf_PLES_mean = nonzeros(Yb_Lu_Hf_PLES_mean);
v180_PLES = nonzeros(v180_PLES);
LuHf_PLES = nonzeros(LuHf_PLES);
LuHf_PLESs = nonzeros(LuHf_PLESs);
YbHf_PLES = nonzeros(YbHf_PLES);
YbHf_PLESs = nonzeros(YbHf_PLESs);
Hf178_Hf177_PLES = nonzeros(Hf178_Hf177_PLES);
Hf178_Hf177_PLESs = nonzeros(Hf178_Hf177_PLESs);

H.Ratio_STD_176_177_FC_mean = nonzeros(Ratio_STD_176_177_FC_mean);
Ratio_STD_176_177_FC_SE = nonzeros(Ratio_STD_176_177_FC_SE);
H.Yb_Lu_Hf_FC_mean = nonzeros(Yb_Lu_Hf_FC_mean);
v180_FC = nonzeros(v180_FC);
LuHf_FC = nonzeros(LuHf_FC);
LuHf_FCs = nonzeros(LuHf_FCs);
YbHf_FC = nonzeros(YbHf_FC);
YbHf_FCs = nonzeros(YbHf_FCs);
Hf178_Hf177_FC = nonzeros(Hf178_Hf177_FC);
Hf178_Hf177_FCs = nonzeros(Hf178_Hf177_FCs);

H.Ratio_STD_176_177_TEM_mean = nonzeros(Ratio_STD_176_177_TEM_mean);
Ratio_STD_176_177_TEM_SE = nonzeros(Ratio_STD_176_177_TEM_SE);
H.Yb_Lu_Hf_TEM_mean = nonzeros(Yb_Lu_Hf_TEM_mean);
v180_TEM = nonzeros(v180_TEM);
LuHf_TEM = nonzeros(LuHf_TEM);
LuHf_TEMs = nonzeros(LuHf_TEMs);
YbHf_TEM = nonzeros(YbHf_TEM);
YbHf_TEMs = nonzeros(YbHf_TEMs);
Hf178_Hf177_TEM = nonzeros(Hf178_Hf177_TEM);
Hf178_Hf177_TEMs = nonzeros(Hf178_Hf177_TEMs);

H.Ratio_STD_176_177_91500_mean = nonzeros(Ratio_STD_176_177_91500_mean);
Ratio_STD_176_177_91500_SE = nonzeros(Ratio_STD_176_177_91500_SE);
H.Yb_Lu_Hf_91500_mean = nonzeros(Yb_Lu_Hf_91500_mean);
v180_91500 = nonzeros(v180_91500);
LuHf_91500 = nonzeros(LuHf_91500);
LuHf_91500s = nonzeros(LuHf_91500s);
YbHf_91500 = nonzeros(YbHf_91500);
YbHf_91500s = nonzeros(YbHf_91500s);
Hf178_Hf177_91500 = nonzeros(Hf178_Hf177_91500);
Hf178_Hf177_91500s = nonzeros(Hf178_Hf177_91500s);

H.Ratio_STD_176_177_SL_mean = nonzeros(Ratio_STD_176_177_SL_mean);
Ratio_STD_176_177_SL_SE = nonzeros(Ratio_STD_176_177_SL_SE);
H.Yb_Lu_Hf_SL_mean = nonzeros(Yb_Lu_Hf_SL_mean);
v180_SL = nonzeros(v180_SL);
LuHf_SL = nonzeros(LuHf_SL);
LuHf_SLs = nonzeros(LuHf_SLs);
YbHf_SL = nonzeros(YbHf_SL);
YbHf_SLs = nonzeros(YbHf_SLs);
Hf178_Hf177_SL = nonzeros(Hf178_Hf177_SL);
Hf178_Hf177_SLs = nonzeros(Hf178_Hf177_SLs);

















if sum(SAMPLES_idx) > 0
	Ratio_UNKNOWN_176_177_mean = nonzeros(Ratio_UNKNOWN_176_177_mean);
	H.Ratio_UNKNOWN_176_177_mean = Ratio_UNKNOWN_176_177_mean;
	Ratio_UNKNOWN_176_177_SE = nonzeros(Ratio_UNKNOWN_176_177_SE);
	Yb_Lu_Hf_UNKNOWN_mean = nonzeros(Yb_Lu_Hf_UNKNOWN_mean);
	H.Yb_Lu_Hf_UNKNOWN_mean = Yb_Lu_Hf_UNKNOWN_mean;
	v180_UNKNOWN = nonzeros(v180_UNKNOWN);
	sample_UNKNOWN_name = sample_UNKNOWN_name(~cellfun('isempty', sample_UNKNOWN_name'));
	LuHf_UNKNOWN = nonzeros(LuHf_UNKNOWN);
	LuHf_UNKNOWNs = nonzeros(LuHf_UNKNOWNs);
	YbHf_UNKNOWN = nonzeros(YbHf_UNKNOWN);
	YbHf_UNKNOWNs = nonzeros(YbHf_UNKNOWNs);
	Hf178_Hf177_UNKNOWN = nonzeros(Hf178_Hf177_UNKNOWN);
	Hf178_Hf177_UNKNOWNs = nonzeros(Hf178_Hf177_UNKNOWNs);
end

if sum(SAMPLES_idx) > 0
	if Agefile == 1
		filename_ages(all(cellfun('isempty',filename_ages),2),:) = [];
		
		if ispc == 1
			fullpathname = char(strcat(folder_name, '\', filename_ages{1,1}));
		end
		if ismac == 1
			fullpathname = char(strcat(folder_name, '/', filename_ages{1,1}));
		end
		
		
		Data = importdata(fullpathname,',',500000);
		Ages = regexp(Data, ',', 'split');
		%clear Data
		for i = 1:length(Ages(:,1))
			Ages_names(i,1) = strtrim(Ages{i,1}(1,1));
			Ages_mean(i,1) = str2num(cell2mat(Ages{i,1}(1,2)));
			Ages_uncert(i,1) = str2num(cell2mat(Ages{i,1}(1,3)));
		end
	else
		Ages_names = sample_UNKNOWN_name;
		%Ages_mean(1:length(sample_UNKNOWN_name),1) = str2double(get(H.age_set,'Value'));
		Ages_mean(1:length(sample_UNKNOWN_name),1) = str2num(get(H.defaultage,'String'));
		Ages_uncert(1:length(sample_UNKNOWN_name),1) = 1;
	end
end




%E4- ( G4 * ( EXP((1000000*L4) * 1.867 * 10^-11 ) -1 ) )



% Match sample names to optional uploaded age file
%s = zeros(length(sample),length(Ages_names));
if sum(SAMPLES_idx) > 0
	if Agefile == 1
		for j = 1:length(Ages_names)
			for i = 1:length(sample)
				s(i,j) = strcmp(strtrim(sample(i,1)),strtrim(Ages_names(j,1)));
			end
		end
		
		for i = 1:length(s(:,1))
			if sum(s(i,:)) == 0
				I(i,1) = 0;
			else
				[~,I(i,1)] = max(s(i,:));
			end
		end
		
		for i = 1:data_count
			if SAMPLES_idx(i,1) == 1 && I(i,1) ~= 0
				Ages_ascribed(i,1) = [Ages_mean(I(i,1),1)];
				Ages_uncert_ascribed(i,1) = [Ages_uncert(I(i,1),1)];
			end
			if SAMPLES_idx(i,1) == 1 && I(i,1) == 0
				Ages_ascribed(i,1) = str2num(get(H.defaultage,'String'));
				Ages_uncert_ascribed(i,1) = 1;
			end
		end
		
		
	end
	if Agefile == 0
		for i = 1:length(sample)
			if SAMPLES_idx(i,1) == 1
				Ages_ascribed(i,1) = str2num(get(H.defaultage,'String'));
				Ages_uncert_ascribed(i,1) = 1;
			end
		end
	end
	
	Ages_ascribed( all(~Ages_ascribed,2), : ) = [];
	Ages_uncert_ascribed( all(~Ages_uncert_ascribed,2), : ) = [];

	
end



















waitbar(1)

for i = 1:length(v180_UNKNOWN)
	if v180_UNKNOWN(i,1) ~= 0
		HfHfT_UNKNOWN(i,1) = Ratio_UNKNOWN_176_177_mean(i,1) - ( LuHf_UNKNOWN(i,1) * ( exp((1000000*Ages_ascribed(i,1)) * 1.87 * (10^-11) ) - 1 ) );
		HfHfT_UNKNOWNs(i,1) = Ratio_UNKNOWN_176_177_mean(i,1) - ( LuHf_UNKNOWN(i,1) * ( exp((1000000*Ages_ascribed(i,1)) * 1.87 * (10^-11) ) - 1 ) ) - ...
			(  (Ratio_UNKNOWN_176_177_mean(i,1) - Ratio_UNKNOWN_176_177_SE(i,1)) - ( (LuHf_UNKNOWN(i,1) - LuHf_UNKNOWNs(i,1)) * ...
			( exp((1000000*Ages_ascribed(i,1)) * 1.87 * (10^-11) ) - 1 ) )  );
	end
end

for i = 1:sum(STD_R33_idx)
	if v180_R33(i,1) ~= 0
		HfHfT_R33(i,1) = H.Ratio_STD_176_177_R33_mean(i,1) - ( LuHf_R33(i,1) * ( exp((1000000*Age_R33) * 1.87 * (10^-11) ) - 1 ) );
		HfHfT_R33s(i,1) = H.Ratio_STD_176_177_R33_mean(i,1) - ( LuHf_R33(i,1) * ( exp((1000000*Age_R33) * 1.87 * (10^-11) ) - 1 ) ) - ...
			(  (H.Ratio_STD_176_177_R33_mean(i,1) - Ratio_STD_176_177_R33_SE(i,1)) - ( (LuHf_R33(i,1) - LuHf_R33s(i,1)) * ...
			( exp((1000000*Age_R33) * 1.87 * (10^-11) ) - 1 ) )  );
	end
end

for i = 1:sum(STD_TEM_idx)
	if v180_TEM(i,1) ~= 0
		HfHfT_TEM(i,1) = H.Ratio_STD_176_177_TEM_mean(i,1) - ( LuHf_TEM(i,1) * ( exp((1000000*Age_TEM) * 1.87 * (10^-11) ) - 1 ) );
		HfHfT_TEMs(i,1) = H.Ratio_STD_176_177_TEM_mean(i,1) - ( LuHf_TEM(i,1) * ( exp((1000000*Age_TEM) * 1.87 * (10^-11) ) - 1 ) ) - ...
			(  (H.Ratio_STD_176_177_TEM_mean(i,1) - Ratio_STD_176_177_TEM_SE(i,1)) - ( (LuHf_TEM(i,1) - LuHf_TEMs(i,1)) * ...
			( exp((1000000*Age_TEM) * 1.87 * (10^-11) ) - 1 ) )  );
	end
end

for i = 1:sum(STD_MT_idx)
	if v180_MT(i,1) ~= 0
		HfHfT_MT(i,1) = H.Ratio_STD_176_177_MT_mean(i,1) - ( LuHf_MT(i,1) * ( exp((1000000*Age_MT) * 1.87 * (10^-11) ) - 1 ) );
		HfHfT_MTs(i,1) = H.Ratio_STD_176_177_MT_mean(i,1) - ( LuHf_MT(i,1) * ( exp((1000000*Age_MT) * 1.87 * (10^-11) ) - 1 ) ) - ...
			(  (H.Ratio_STD_176_177_MT_mean(i,1) - Ratio_STD_176_177_MT_SE(i,1)) - ( (LuHf_MT(i,1) - LuHf_MTs(i,1)) * ...
			( exp((1000000*Age_MT) * 1.87 * (10^-11) ) - 1 ) )  );
	end
end

for i = 1:sum(STD_PLES_idx)
	if v180_PLES(i,1) ~= 0
		HfHfT_PLES(i,1) = H.Ratio_STD_176_177_PLES_mean(i,1) - ( LuHf_PLES(i,1) * ( exp((1000000*Age_PLES) * 1.87 * (10^-11) ) - 1 ) );
		HfHfT_PLESs(i,1) = H.Ratio_STD_176_177_PLES_mean(i,1) - ( LuHf_PLES(i,1) * ( exp((1000000*Age_PLES) * 1.87 * (10^-11) ) - 1 ) ) - ...
			(  (H.Ratio_STD_176_177_PLES_mean(i,1) - Ratio_STD_176_177_PLES_SE(i,1)) - ( (LuHf_PLES(i,1) - LuHf_PLESs(i,1)) * ...
			( exp((1000000*Age_PLES) * 1.87 * (10^-11) ) - 1 ) )  );
	end
end

for i = 1:sum(STD_91500_idx)
	if v180_91500(i,1) ~= 0
		HfHfT_91500(i,1) = H.Ratio_STD_176_177_91500_mean(i,1) - ( LuHf_91500(i,1) * ( exp((1000000*Age_91500) * 1.87 * (10^-11) ) - 1 ) );
		HfHfT_91500s(i,1) = H.Ratio_STD_176_177_91500_mean(i,1) - ( LuHf_91500(i,1) * ( exp((1000000*Age_91500) * 1.87 * (10^-11) ) - 1 ) ) - ...
			(  (H.Ratio_STD_176_177_91500_mean(i,1) - Ratio_STD_176_177_91500_SE(i,1)) - ( (LuHf_91500(i,1) - LuHf_91500s(i,1)) * ...
			( exp((1000000*Age_91500) * 1.87 * (10^-11) ) - 1 ) )  );
	end
end

for i = 1:sum(STD_FC_idx)
	if v180_FC(i,1) ~= 0
		HfHfT_FC(i,1) = H.Ratio_STD_176_177_FC_mean(i,1) - ( LuHf_FC(i,1) * ( exp((1000000*Age_FC) * 1.87 * (10^-11) ) - 1 ) );
		HfHfT_FCs(i,1) = H.Ratio_STD_176_177_FC_mean(i,1) - ( LuHf_FC(i,1) * ( exp((1000000*Age_FC) * 1.87 * (10^-11) ) - 1 ) ) - ...
			(  (H.Ratio_STD_176_177_FC_mean(i,1) - Ratio_STD_176_177_FC_SE(i,1)) - ( (LuHf_FC(i,1) - LuHf_FCs(i,1)) * ...
			( exp((1000000*Age_FC) * 1.87 * (10^-11) ) - 1 ) )  );
	end
end

for i = 1:sum(STD_SL_idx)
	if v180_SL(i,1) ~= 0
		HfHfT_SL(i,1) = H.Ratio_STD_176_177_SL_mean(i,1) - ( LuHf_SL(i,1) * ( exp((1000000*Age_SL) * 1.87 * (10^-11) ) - 1 ) );
		HfHfT_SLs(i,1) = H.Ratio_STD_176_177_SL_mean(i,1) - ( LuHf_SL(i,1) * ( exp((1000000*Age_SL) * 1.87 * (10^-11) ) - 1 ) ) - ...
			(  (H.Ratio_STD_176_177_SL_mean(i,1) - Ratio_STD_176_177_SL_SE(i,1)) - ( (LuHf_SL(i,1) - LuHf_SLs(i,1)) * ...
			( exp((1000000*Age_SL) * 1.87 * (10^-11) ) - 1 ) )  );
	end
end


%{
count = 1;
if sum(SAMPLES_idx) > 0
	for i = 1:length(SAMPLES_idx)
		if SAMPLES_idx(i,1) == 1
			if v180_UNKNOWN(count,1) ~= 0
				%eHf_UNKNOWNS(count,1) = 10000*((Ratio_UNKNOWN_176_177_mean(i,1)/(0.282785-(0.0336*(exp((1000000*Ages_ascribed(count,1))*1.867*10^-11)-1))))-1);
				eHf_UNKNOWNSf(i,1) = 10000*((HfHfT_UNKNOWN(i,1)/(0.282785-(0.0336*(exp((1000000*Ages_ascribed(count,1))*1.867*10^-11)-1))))-1);
				eHf_UNKNOWNS(count,1) = 10000*((HfHfT_UNKNOWN(i,1)/(0.282785-(0.0336*(exp((1000000*Ages_ascribed(count,1))*1.867*10^-11)-1))))-1);
			end
			count = count + 1;
		else
			eHf_UNKNOWNSf(i,1) = 0;
		end
	end
end
%}

count = 1;
if sum(SAMPLES_idx) > 0
	for i = 1:length(SAMPLES_idx)
		if SAMPLES_idx(i,1) == 1
			if v180_UNKNOWN(count,1) ~= 0
				eHf_UNKNOWNS(count,1) = 10000*((HfHfT_UNKNOWN(count,1)/(0.282785-(0.0336*(exp((1000000*Ages_ascribed(count,1))*1.867*10^-11)-1))))-1);
				eHf_UNKNOWNSs(count,1) = (10000*((HfHfT_UNKNOWN(count,1)/(0.282785-(0.0336*(exp((1000000*Ages_ascribed(count,1))*1.867*10^-11)-1))))-1)) - ...
					10000*(((HfHfT_UNKNOWN(count,1) - HfHfT_UNKNOWNs(count,1))/(0.282785-(0.0336*(exp((1000000*Ages_ascribed(count,1))*1.867*10^-11)-1))))-1);
			end
			count = count + 1;
		end
	end
end

for i = 1:sum(STD_R33_idx)
	if v180_R33(i,1) ~= 0
		eHf_R33(i,1) = 10000*((HfHfT_R33(i,1)/(0.282785-(0.0336*(exp((1000000*Age_R33)*1.867*10^-11)-1))))-1);
		eHf_R33s(i,1) = (10000*((HfHfT_R33(i,1)/(0.282785-(0.0336*(exp((1000000*Age_R33)*1.867*10^-11)-1))))-1)) - ...
			10000*(((HfHfT_R33(i,1) - HfHfT_R33s(i,1))/(0.282785-(0.0336*(exp((1000000*Age_R33)*1.867*10^-11)-1))))-1);
	end
end

for i = 1:sum(STD_TEM_idx)
	if v180_TEM(i,1) ~= 0
		eHf_TEM(i,1) = 10000*((HfHfT_TEM(i,1)/(0.282785-(0.0336*(exp((1000000*Age_TEM)*1.867*10^-11)-1))))-1);
		eHf_TEMs(i,1) = (10000*((HfHfT_TEM(i,1)/(0.282785-(0.0336*(exp((1000000*Age_TEM)*1.867*10^-11)-1))))-1)) - ...
			10000*(((HfHfT_TEM(i,1) - HfHfT_TEMs(i,1))/(0.282785-(0.0336*(exp((1000000*Age_TEM)*1.867*10^-11)-1))))-1);
	end
end

for i = 1:sum(STD_MT_idx)
	if v180_MT(i,1) ~= 0
		eHf_MT(i,1) = 10000*((HfHfT_MT(i,1)/(0.282785-(0.0336*(exp((1000000*Age_MT)*1.867*10^-11)-1))))-1);
		eHf_MTs(i,1) = (10000*((HfHfT_MT(i,1)/(0.282785-(0.0336*(exp((1000000*Age_MT)*1.867*10^-11)-1))))-1)) - ...
			10000*(((HfHfT_MT(i,1) - HfHfT_MTs(i,1))/(0.282785-(0.0336*(exp((1000000*Age_MT)*1.867*10^-11)-1))))-1);
	end
end

for i = 1:sum(STD_PLES_idx)
	if v180_PLES(i,1) ~= 0
		eHf_PLES(i,1) = 10000*((HfHfT_PLES(i,1)/(0.282785-(0.0336*(exp((1000000*Age_PLES)*1.867*10^-11)-1))))-1);
		eHf_PLESs(i,1) = (10000*((HfHfT_PLES(i,1)/(0.282785-(0.0336*(exp((1000000*Age_PLES)*1.867*10^-11)-1))))-1)) - ...
			10000*(((HfHfT_PLES(i,1) - HfHfT_PLESs(i,1))/(0.282785-(0.0336*(exp((1000000*Age_PLES)*1.867*10^-11)-1))))-1);
	end
end

for i = 1:sum(STD_91500_idx)
	if v180_91500(i,1) ~= 0
		eHf_91500(i,1) = 10000*((HfHfT_91500(i,1)/(0.282785-(0.0336*(exp((1000000*Age_91500)*1.867*10^-11)-1))))-1);
		eHf_91500s(i,1) = (10000*((HfHfT_91500(i,1)/(0.282785-(0.0336*(exp((1000000*Age_91500)*1.867*10^-11)-1))))-1)) - ...
			10000*(((HfHfT_91500(i,1) - HfHfT_91500s(i,1))/(0.282785-(0.0336*(exp((1000000*Age_91500)*1.867*10^-11)-1))))-1);
	end
end

for i = 1:sum(STD_FC_idx)
	if v180_FC(i,1) ~= 0
		eHf_FC(i,1) = 10000*((HfHfT_FC(i,1)/(0.282785-(0.0336*(exp((1000000*Age_FC)*1.867*10^-11)-1))))-1);
		eHf_FCs(i,1) = (10000*((HfHfT_FC(i,1)/(0.282785-(0.0336*(exp((1000000*Age_FC)*1.867*10^-11)-1))))-1)) - ...
			10000*(((HfHfT_FC(i,1) - HfHfT_FCs(i,1))/(0.282785-(0.0336*(exp((1000000*Age_FC)*1.867*10^-11)-1))))-1);
	end
end

for i = 1:sum(STD_SL_idx)
	if v180_SL(i,1) ~= 0
		eHf_SL(i,1) = 10000*((HfHfT_SL(i,1)/(0.282785-(0.0336*(exp((1000000*Age_SL)*1.867*10^-11)-1))))-1);
		eHf_SLs(i,1) = (10000*((HfHfT_SL(i,1)/(0.282785-(0.0336*(exp((1000000*Age_SL)*1.867*10^-11)-1))))-1)) - ...
			10000*(((HfHfT_SL(i,1) - HfHfT_SLs(i,1))/(0.282785-(0.0336*(exp((1000000*Age_SL)*1.867*10^-11)-1))))-1);
	end
end


















count = 1;
if sum(SAMPLES_idx) > 0
	for i = 1:length(SAMPLES_idx)
		if SAMPLES_idx(i,1) == 1
			if v180_UNKNOWN(count,1) ~= 0
				eHf_UNKNOWNSf(i,1) = 10000*((HfHfT_UNKNOWN(count,1)/(0.282785-(0.0336*(exp((1000000*Ages_ascribed(count,1))*1.867*10^-11)-1))))-1);
				count = count + 1;
			else
				eHf_UNKNOWNSf(i,1) = 0;
			end
		end
	end
end

%for i = 1:length(v180_UNKNOWN)
%	if v180_UNKNOWN(i,1) ~= 0
%		eHf_UNKNOWNS3(i,1) = 10000 * (( HfHfT_UNKNOWN(i,1) / (0.282785 - ( 0.0336 * ( exp((1000000*Ages_ascribed(i,1))*1.867*10^-11)-1))))-1);
%	end
%end







%for i = 1:length(v180_UNKNOWN)
%	if v180_UNKNOWN(i,1) ~= 0
%		eHf_UNKNOWNS2(i,1) = 10000 * (( Ratio_UNKNOWN_176_177_mean(i,1) / (0.282785 - (0.0336 * (exp ((1000000*Ages_ascribed(i,1) ) * 1.867*(10^-11) ) -1 ) ))) -1 );
%	end
%end

%eHf_UNKNOWNSf(i,1) = 10000*((Ratio_UNKNOWN_176_177_mean(i,1)/(0.282785-(0.0336*(exp((1000000*Ages_ascribed(count,1))*1.867*10^-11)-1))))-1);


%10000*(( H8 / (K!$F$37-(K!$E$37 * ( EXP ((1000000 * L8 ) * 1.867*10^-11 ) -1 ) )))-1)

if sum(SAMPLES_idx) > 0
	for i = 1:length(v180_UNKNOWN)
		if v180_UNKNOWN(i,1) ~= 0
			eHf0_UNKNOWN(i,1) = 10000 * ((Ratio_UNKNOWN_176_177_mean(i,1)/0.282785)-1); %BSE Bouvier et al. 2008
			eHf0_UNKNOWNs(i,1) = 10000 * ((Ratio_UNKNOWN_176_177_mean(i,1)/0.282785)-1) - 10000 * ((( Ratio_UNKNOWN_176_177_mean(i,1) - Ratio_UNKNOWN_176_177_SE(i,1) ) /0.282785)-1);
		end
	end
end

if sum(STD_R33_idx) > 0
	for i = 1:length(v180_R33)
		if v180_R33(i,1) ~= 0
			eHf0_R33(i,1) = 10000 * ((H.Ratio_STD_176_177_R33_mean(i,1)/0.282785)-1); %BSE Bouvier et al. 2008
			eHf0_R33s(i,1) = 10000 * ((H.Ratio_STD_176_177_R33_mean(i,1)/0.282785)-1) - 10000 * ((( H.Ratio_STD_176_177_R33_mean(i,1) - Ratio_STD_176_177_R33_SE(i,1) ) /0.282785)-1);
		end
	end
end

if sum(STD_TEM_idx) > 0
	for i = 1:length(v180_TEM)
		if v180_TEM(i,1) ~= 0
			eHf0_TEM(i,1) = 10000 * ((H.Ratio_STD_176_177_TEM_mean(i,1)/0.282785)-1); %BSE Bouvier et al. 2008
			eHf0_TEMs(i,1) = 10000 * ((H.Ratio_STD_176_177_TEM_mean(i,1)/0.282785)-1) - 10000 * ((( H.Ratio_STD_176_177_TEM_mean(i,1) - Ratio_STD_176_177_TEM_SE(i,1) ) /0.282785)-1);
		end
	end
end

if sum(STD_MT_idx) > 0
	for i = 1:length(v180_MT)
		if v180_MT(i,1) ~= 0
			eHf0_MT(i,1) = 10000 * ((H.Ratio_STD_176_177_MT_mean(i,1)/0.282785)-1); %BSE Bouvier et al. 2008
			eHf0_MTs(i,1) = 10000 * ((H.Ratio_STD_176_177_MT_mean(i,1)/0.282785)-1) - 10000 * ((( H.Ratio_STD_176_177_MT_mean(i,1) - Ratio_STD_176_177_MT_SE(i,1) ) /0.282785)-1);
		end
	end
end

if sum(STD_PLES_idx) > 0
	for i = 1:length(v180_PLES)
		if v180_PLES(i,1) ~= 0
			eHf0_PLES(i,1) = 10000 * ((H.Ratio_STD_176_177_PLES_mean(i,1)/0.282785)-1); %BSE Bouvier et al. 2008
			eHf0_PLESs(i,1) = 10000 * ((H.Ratio_STD_176_177_PLES_mean(i,1)/0.282785)-1) - 10000 * ((( H.Ratio_STD_176_177_PLES_mean(i,1) - Ratio_STD_176_177_PLES_SE(i,1) ) /0.282785)-1);
		end
	end
end

if sum(STD_91500_idx) > 0
	for i = 1:length(v180_91500)
		if v180_91500(i,1) ~= 0
			eHf0_91500(i,1) = 10000 * ((H.Ratio_STD_176_177_91500_mean(i,1)/0.282785)-1); %BSE Bouvier et al. 2008
			eHf0_91500s(i,1) = 10000 * ((H.Ratio_STD_176_177_91500_mean(i,1)/0.282785)-1) - 10000 * ((( H.Ratio_STD_176_177_91500_mean(i,1) - Ratio_STD_176_177_91500_SE(i,1) ) /0.282785)-1);
		end
	end
end

if sum(STD_FC_idx) > 0
	for i = 1:length(v180_FC)
		if v180_FC(i,1) ~= 0
			eHf0_FC(i,1) = 10000 * ((H.Ratio_STD_176_177_FC_mean(i,1)/0.282785)-1); %BSE Bouvier et al. 2008
			eHf0_FCs(i,1) = 10000 * ((H.Ratio_STD_176_177_FC_mean(i,1)/0.282785)-1) - 10000 * ((( H.Ratio_STD_176_177_FC_mean(i,1) - Ratio_STD_176_177_FC_SE(i,1) ) /0.282785)-1);
		end
	end
end

if sum(STD_SL_idx) > 0
	for i = 1:length(v180_SL)
		if v180_SL(i,1) ~= 0
			eHf0_SL(i,1) = 10000 * ((H.Ratio_STD_176_177_SL_mean(i,1)/0.282785)-1); %BSE Bouvier et al. 2008
			eHf0_SLs(i,1) = 10000 * ((H.Ratio_STD_176_177_SL_mean(i,1)/0.282785)-1) - 10000 * ((( H.Ratio_STD_176_177_SL_mean(i,1) - Ratio_STD_176_177_SL_SE(i,1) ) /0.282785)-1);
		end
	end
end

%10000*( ( E4/K!$F$37)-1),"")
%-10000*(((E4-F4)/K!$F$37)-1),"")




































STD_offset = [];
if get(H.stds_MT,'Value') == 1
	STD_offset(end+1,1) = mean(nonzeros(Ratio_STD_176_177_MT_mean)) - 0.282507;
end
if get(H.stds_91500,'Value') == 1
	STD_offset(end+1,1) = mean(nonzeros(Ratio_STD_176_177_91500_mean)) - 0.282298;
end
if get(H.stds_TEM,'Value') == 1
	STD_offset(end+1,1) = mean(nonzeros(Ratio_STD_176_177_TEM_mean)) - 0.282686;
end
if get(H.stds_PLES,'Value') == 1
	STD_offset(end+1,1) = mean(nonzeros(Ratio_STD_176_177_PLES_mean)) - 0.282484;
end
if get(H.stds_FC,'Value') == 1
	STD_offset(end+1,1) = mean(nonzeros(Ratio_STD_176_177_FC_mean)) - 0.282157;
end
if get(H.stds_SL,'Value') == 1
	STD_offset(end+1,1) = mean(nonzeros(Ratio_STD_176_177_SL_mean)) - 0.28170;
end
if get(H.stds_R33,'Value') == 1
	STD_offset(end+1,1) = mean(nonzeros(Ratio_STD_176_177_R33_mean)) - 0.282739; % R33 STD should end in 1 to be consistent
end

for i = 1:data_count
	if STD_MT_idx(i,1) == 1
		offset_MT(i,1) = abs(Ratio_STD_176_177_MT_mean(i,1) - 0.282507);
	else
		offset_MT(i,1) = 0;
	end
	if STD_SL_idx(i,1) == 1
		offset_SL(i,1) = abs(Ratio_STD_176_177_SL_mean(i,1) - 0.28170);
	else
		offset_SL(i,1) = 0;
	end
	if STD_R33_idx(i,1) == 1
		offset_R33(i,1) = abs(Ratio_STD_176_177_R33_mean(i,1) - 0.282739);
	else
		offset_R33(i,1) = 0;
	end
	if STD_TEM_idx(i,1) == 1
		offset_TEM(i,1) = abs(Ratio_STD_176_177_TEM_mean(i,1) - 0.282686);
	else
		offset_TEM(i,1) = 0;
	end
	if STD_91500_idx(i,1) == 1
		offset_91500(i,1) = abs(Ratio_STD_176_177_91500_mean(i,1) - 0.282298);
	else
		offset_91500(i,1) = 0;
	end
	if STD_PLES_idx(i,1) == 1
		offset_PLES(i,1) = abs(Ratio_STD_176_177_PLES_mean(i,1) - 0.282484);
	else
		offset_PLES(i,1) = 0;
	end
	if STD_FC_idx(i,1) == 1
		offset_FC(i,1) = abs(Ratio_STD_176_177_FC_mean(i,1) - 0.282157);
	else
		offset_FC(i,1) = 0;
	end
end













STD_offset_avg = median(STD_offset);
set(H.stdopt_STDoffset,'String',sprintf('%f',STD_offset_avg))

STD_SE_avg = median([Ratio_STD_176_177_MT_SE; Ratio_STD_176_177_R33_SE; Ratio_STD_176_177_PLES_SE; Ratio_STD_176_177_FC_SE; Ratio_STD_176_177_TEM_SE; ...
	Ratio_STD_176_177_91500_SE; Ratio_STD_176_177_SL_SE]);
set(H.stdopt_STDSE,'String',sprintf('%f',STD_SE_avg));
if sum(SAMPLES_idx) > 0
	set(H.unks_munc,'String',sprintf('%f',mean(Ratio_UNKNOWN_176_177_SE(~isnan(Ratio_UNKNOWN_176_177_SE)))));
end

% Calculate % data retained
for j = 1:length(sample)
	if SAMPLES_idx(j,1) == 0
		if sum(BLS_180(:,j)) > 0 
			%&& isempty(strmatch(sample(1,1),'xx')) == 1
			retained_stds(j,1) = length(nonzeros(Filter_INT(:,j)))/samp_length;
			retained_stds_idx(j,1) = 1;
		else
			retained_stds(j,1) = 0;
			retained_stds_idx(j,1) = 0;
		end
	end
end

for j = 1:length(sample)
	if SAMPLES_idx(j,1) == 1
		if sum(BLS_180(:,j)) > 0
			retained_unknowns(j,1) = length(nonzeros(Filter_INT(:,j)))/samp_length;
			retained_unknowns_idx(j,1) = 1;
		else
			retained_unknowns(j,1) = 0;
			retained_unknowns_idx(j,1) = 0;
		end
	end
end

retained_stds_p = sum(retained_stds)/sum(retained_stds_idx)*100;

retained_unknowns_p = sum(retained_unknowns)/sum(retained_unknowns_idx)*100;

set(H.stdopt_percret,'String',round(retained_stds_p,1))
set(H.unks_percret,'String',round(retained_unknowns_p,1))

BLS_176_177_corr = Filter_95;

reduced = 1;

close(h)

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




comment1{length(sample), 1} = [];
comment2{length(sample), 1} = [];
comment3{length(sample), 1} = [];

for i = 1:length(sample)
	if ALL_176_177_SE(i,1) > str2num(get(H.unc_cutoff,'String'))
		comment1(i,1) = {'high uncertainty  '};
	end
	if SAMPLES_idx(i,1) == 1 && eHf_UNKNOWNSf(i,1) > str2num(get(H.epsiloncutoffhi,'String'))
		comment2(i,1) = {'high epsilon  '};
	end
	if SAMPLES_idx(i,1) == 1 && eHf_UNKNOWNSf(i,1) < str2num(get(H.epsiloncutofflo,'String'))
		comment3(i,1) = {'low epsilon  '};
	end
end

comment = strcat(comment1, comment2, comment3);

for i = 1:length(sample)
	if isempty(comment{i,1}) == 1
		current_status{i,1} = ['Accepted'];
		current_status_num(i,1) = 1;
	else
		current_status{i,1} = ['Rejected: ', comment{i,1}];
		current_status_num(i,1) = 0;
	end
end

current_status_num_orig = current_status_num;

for i = 1:length(sample)
	if contains(sample(i,1),'xx') == 1
		name_char(i,1) = strcat('<html><BODY bgcolor="red">',sample(i,1),'</span></html>');
	else
		name_char(i,1)=(sample(i,1));
	end
end

name_idx = length(sample); %automatically plot final sample run

for i=1:length(sample)
	if isempty(comment{i,1}) == 0 && get(H.flagunknowns,'Value') == 1 && STD_idx(i,1) == 0
		name_char(i,1) = strcat('<html><BODY bgcolor="orange">',name_char(i,1),'</span></html>');
	end
end

for i=1:length(sample)
	if contains(sample(i,1),'Burn through') == 1
		name_char(i,1) = strcat('<html><BODY bgcolor="lime">',name_char(i,1),'</span></html>');
	end
end

for i=1:length(sample)
	if get(H.filterstandards,'Value') == 1
		if offset_MT(i,1) > str2num(get(H.flag,'String')) || offset_SL(i,1) > str2num(get(H.flag,'String')) || offset_R33(i,1) > str2num(get(H.flag,'String')) ||...
				offset_TEM(i,1) > str2num(get(H.flag,'String')) || offset_91500(i,1) > str2num(get(H.flag,'String')) || offset_PLES(i,1) > str2num(get(H.flag,'String')) ||...
				offset_FC(i,1) > str2num(get(H.flag,'String'))
			%name_char(i,1) = strcat('<html><BODY bgcolor="green">',name_char(i,1),'</span></html>');
		end
	end
end

set(H.ind_listbox1, 'String', name_char);
set(H.ind_listbox1,'Value',length(sample));


% if current_status_num(name_idx,1) == 1
% 	set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');
% elseif current_status_num(name_idx,1) == 0
% 	set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');
% end



offset_MT = nonzeros(offset_MT);
offset_SL = nonzeros(offset_SL);
offset_R33 = nonzeros(offset_R33);
offset_TEM = nonzeros(offset_TEM);
offset_91500 = nonzeros(offset_91500);
offset_PLES = nonzeros(offset_PLES);
offset_FC = nonzeros(offset_FC);




%tab = {'Table-__ . Hf isotopic data.'};
%heads = {'Order'	'Sample'	'(176Yb + 176Lu) / 176Hf (%)'	'Volts Hf'	'176Hf/177Hf'	'± (1s)'	'176Lu/177Hf'	'176Hf/177Hf (T)'	'E-Hf (0)'...
%	'E-Hf (0) ± (1s)'	'E-Hf (T)'	'Age (Ma)'};




heads1 = {'Table'};

heads2 = {'LA-MC-ICPMS Lu-Hf isotopic analyses of zircon.'};

heads3 = {'1)'	'2)'	'3)'	'4)'	'5)'	'6)'	'7)'	'8)'	'9)'	'10)'	'11)'	'12)'	'13)'	'14)'	'15)'	'16)'	'17)'	'18)'	'19)'	'20)'};

heads4 = {'Sample' '176Hf/177Hf'	'2 SE'	'176Lu/177Hf'	'2 SE'	'176Yb/177Hf'	'2 SE'	'178Hf/177Hf'	'2 SE'	'EHf (0)'	'2 SE' ...
	'176Hf/177Hf (i)'	'EHf (i)'	'2 SE'	'Age (Ma)'	'2 SE'	'(176Yb+176Lu)/176Hf (%)'	'Volts Hf'	'Correction (EHf)'	'Age (Ma)'	'EHf (i)'};

EXPORT{sum(SAMPLES_idx)+sum(STD_idx)+30,21} = [];

EXPORT(1,1) = heads1;
EXPORT(2,1) = heads2;
EXPORT(4,2:end) = heads3;
EXPORT(5,:) = heads4;

%for i = 1:sum(SAMPLES_idx)
%	EXPORT(i+2,1) = {i};
%end

count = 1;
for i = 1:length(SAMPLES_idx)
	if SAMPLES_idx(i,1) == 1
		EXPORT(count+6,1) = sample(i,1);
		EXPORT{count+6,2} = Ratio_UNKNOWN_176_177_mean(count,1); %176Hf/177Hf
		EXPORT{count+6,3} = 2*Ratio_UNKNOWN_176_177_SE(count,1); %2 SE
		EXPORT{count+6,4} = LuHf_UNKNOWN(count,1);
		EXPORT{count+6,5} = 2*LuHf_UNKNOWNs(count,1); %2 SE
		EXPORT{count+6,6} = YbHf_UNKNOWN(count,1);
		EXPORT{count+6,7} = 2*YbHf_UNKNOWNs(count,1); %2 SE
		EXPORT{count+6,8} = Hf178_Hf177_UNKNOWN(count,1);
		EXPORT{count+6,9} = 2*Hf178_Hf177_UNKNOWNs(count,1); %2 SE
		EXPORT{count+6,10} = eHf0_UNKNOWN(count,1);
		EXPORT{count+6,11} = 2*eHf0_UNKNOWNs(count,1);%2 SE
		EXPORT{count+6,12} = HfHfT_UNKNOWN(count,1);
		EXPORT{count+6,13} = eHf_UNKNOWNS(count,1);
		EXPORT{count+6,14} = eHf_UNKNOWNSs(count,1);
		EXPORT{count+6,15} = Ages_ascribed(count,1);
		EXPORT{count+6,16} = Ages_uncert_ascribed(count,1);
		EXPORT{count+6,17} = Yb_Lu_Hf_UNKNOWN_mean(count,1); %(176Lu+176Yb)/176Hf %)
		EXPORT{count+6,18} = v180_UNKNOWN(count,1);
		EXPORT{count+6,19} = (YbHf_UNKNOWN(count,1) + HfHfT_UNKNOWN(count,1)) / 0.000028;
		EXPORT{count+6,20} = Ages_ascribed(count,1);
		EXPORT{count+6,21} = eHf_UNKNOWNS(count,1);
		count = count + 1;
	end
end







%{

		
		
		
		
		
		
		
		
%}





%Append STDs with mean and 2 SD

count = 1;
loc_R33 = 7+length(nonzeros(SAMPLES_idx));
for i = 1:length(STD_R33_idx)
	if STD_R33_idx(i,1) == 1
		EXPORT(count+loc_R33,1) = {STD_R33};
		EXPORT{count+loc_R33,2} = H.Ratio_STD_176_177_R33_mean(count,1); %176Hf/177Hf
 		EXPORT{count+loc_R33,3} = 2*Ratio_STD_176_177_R33_SE(count,1); %2 SE
 		EXPORT{count+loc_R33,4} = LuHf_R33(count,1);
 		EXPORT{count+loc_R33,5} = 2*LuHf_R33s(count,1); %2 SE
		EXPORT{count+loc_R33,6} = YbHf_R33(count,1);
 		EXPORT{count+loc_R33,7} = 2*YbHf_R33s(count,1); %2 SE
 		EXPORT{count+loc_R33,8} = Hf178_Hf177_R33(count,1);
 		EXPORT{count+loc_R33,9} = 2*Hf178_Hf177_R33s(count,1); %2 SE
 		EXPORT{count+loc_R33,10} = eHf0_R33(count,1);
 		EXPORT{count+loc_R33,11} = 2*eHf0_R33s(count,1);%2 SE
 		EXPORT{count+loc_R33,12} = HfHfT_R33(count,1);
 		EXPORT{count+loc_R33,13} = eHf_R33(count,1);
		EXPORT{count+loc_R33,14} = 2*eHf_R33s(count,1);%2 SE
 		EXPORT{count+loc_R33,15} = Age_R33;
 		EXPORT{count+loc_R33,16} = Age_R33s;
 		EXPORT{count+loc_R33,17} = H.Yb_Lu_Hf_R33_mean(count,1); %(176Lu+176Yb)/176Hf %)
 		EXPORT{count+loc_R33,18} = v180_R33(count,1);
 		EXPORT{count+loc_R33,19} = (YbHf_R33(count,1) + HfHfT_R33(count,1)) / 0.000028;
 		EXPORT{count+loc_R33,20} = Age_R33;
 		EXPORT{count+loc_R33,21} = eHf_R33(count,1);
		count = count + 1;
	end
end

EXPORT(8+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx),1) = {'R33 Mean'};
EXPORT(9+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx),1) = {'R33 2 SD'};
EXPORT{loc_R33+sum(STD_R33_idx)+1,2} = mean(cell2num(EXPORT(loc_R33+1:loc_R33+sum(STD_R33_idx),2)));
EXPORT{loc_R33+sum(STD_R33_idx)+2,2} = 2*std(cell2num(EXPORT(loc_R33+1:loc_R33+sum(STD_R33_idx),2)));
EXPORT{loc_R33+sum(STD_R33_idx)+1,8} = mean(cell2num(EXPORT(loc_R33+1:loc_R33+sum(STD_R33_idx),8)));
EXPORT{loc_R33+sum(STD_R33_idx)+2,8} = 2*std(cell2num(EXPORT(loc_R33+1:loc_R33+sum(STD_R33_idx),8)));
EXPORT{loc_R33+sum(STD_R33_idx)+1,10} = mean(cell2num(EXPORT(loc_R33+1:loc_R33+sum(STD_R33_idx),10)));
EXPORT{loc_R33+sum(STD_R33_idx)+2,10} = 2*std(cell2num(EXPORT(loc_R33+1:loc_R33+sum(STD_R33_idx),10)));
EXPORT{loc_R33+sum(STD_R33_idx)+1,13} = mean(cell2num(EXPORT(loc_R33+1:loc_R33+sum(STD_R33_idx),13)));
EXPORT{loc_R33+sum(STD_R33_idx)+2,13} = 2*std(cell2num(EXPORT(loc_R33+1:loc_R33+sum(STD_R33_idx),13)));

count = 1;
loc_TEM = 10+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx);
for i = 1:length(STD_TEM_idx)
	if STD_TEM_idx(i,1) == 1
		EXPORT(count+loc_TEM,1) = {STD_TEM};
		EXPORT{count+loc_TEM,2} = H.Ratio_STD_176_177_TEM_mean(count,1); %176Hf/177Hf
 		EXPORT{count+loc_TEM,3} = 2*Ratio_STD_176_177_TEM_SE(count,1); %2 SE
 		EXPORT{count+loc_TEM,4} = LuHf_TEM(count,1);
 		EXPORT{count+loc_TEM,5} = 2*LuHf_TEMs(count,1); %2 SE
		EXPORT{count+loc_TEM,6} = YbHf_TEM(count,1);
 		EXPORT{count+loc_TEM,7} = 2*YbHf_TEMs(count,1); %2 SE
 		EXPORT{count+loc_TEM,8} = Hf178_Hf177_TEM(count,1);
 		EXPORT{count+loc_TEM,9} = 2*Hf178_Hf177_TEMs(count,1); %2 SE
 		EXPORT{count+loc_TEM,10} = eHf0_TEM(count,1);
 		EXPORT{count+loc_TEM,11} = 2*eHf0_TEMs(count,1);%2 SE
 		EXPORT{count+loc_TEM,12} = HfHfT_TEM(count,1);
 		EXPORT{count+loc_TEM,13} = eHf_TEM(count,1);
		EXPORT{count+loc_TEM,14} = 2*eHf_TEMs(count,1);%2 SE
 		EXPORT{count+loc_TEM,15} = Age_TEM;
 		EXPORT{count+loc_TEM,16} = Age_TEMs;
 		EXPORT{count+loc_TEM,17} = H.Yb_Lu_Hf_TEM_mean(count,1); %(176Lu+176Yb)/176Hf %)
 		EXPORT{count+loc_TEM,18} = v180_TEM(count,1);
 		EXPORT{count+loc_TEM,19} = (YbHf_TEM(count,1) + HfHfT_TEM(count,1)) / 0.000028;
 		EXPORT{count+loc_TEM,20} = Age_TEM;
 		EXPORT{count+loc_TEM,21} = eHf_TEM(count,1);
		count = count + 1;
	end
end

EXPORT(11+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx),1) = {'TEM Mean'};
EXPORT(12+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx),1) = {'TEM 2 SD'};
EXPORT{loc_TEM+sum(STD_TEM_idx)+1,2} = mean(cell2num(EXPORT(loc_TEM+1:loc_TEM+sum(STD_TEM_idx),2)));
EXPORT{loc_TEM+sum(STD_TEM_idx)+2,2} = 2*std(cell2num(EXPORT(loc_TEM+1:loc_TEM+sum(STD_TEM_idx),2)));
EXPORT{loc_TEM+sum(STD_TEM_idx)+1,8} = mean(cell2num(EXPORT(loc_TEM+1:loc_TEM+sum(STD_TEM_idx),8)));
EXPORT{loc_TEM+sum(STD_TEM_idx)+2,8} = 2*std(cell2num(EXPORT(loc_TEM+1:loc_TEM+sum(STD_TEM_idx),8)));
EXPORT{loc_TEM+sum(STD_TEM_idx)+1,10} = mean(cell2num(EXPORT(loc_TEM+1:loc_TEM+sum(STD_TEM_idx),10)));
EXPORT{loc_TEM+sum(STD_TEM_idx)+2,10} = 2*std(cell2num(EXPORT(loc_TEM+1:loc_TEM+sum(STD_TEM_idx),10)));
EXPORT{loc_TEM+sum(STD_TEM_idx)+1,13} = mean(cell2num(EXPORT(loc_TEM+1:loc_TEM+sum(STD_TEM_idx),13)));
EXPORT{loc_TEM+sum(STD_TEM_idx)+2,13} = 2*std(cell2num(EXPORT(loc_TEM+1:loc_TEM+sum(STD_TEM_idx),13)));

count = 1;
loc_MT = 13+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx);
for i = 1:length(STD_MT_idx)
	if STD_MT_idx(i,1) == 1
		EXPORT(count+loc_MT,1) = {STD_MT};
		EXPORT{count+loc_MT,2} = H.Ratio_STD_176_177_MT_mean(count,1); %176Hf/177Hf
 		EXPORT{count+loc_MT,3} = 2*Ratio_STD_176_177_MT_SE(count,1); %2 SE
 		EXPORT{count+loc_MT,4} = LuHf_MT(count,1);
 		EXPORT{count+loc_MT,5} = 2*LuHf_MTs(count,1); %2 SE
		EXPORT{count+loc_MT,6} = YbHf_MT(count,1);
 		EXPORT{count+loc_MT,7} = 2*YbHf_MTs(count,1); %2 SE
 		EXPORT{count+loc_MT,8} = Hf178_Hf177_MT(count,1);
 		EXPORT{count+loc_MT,9} = 2*Hf178_Hf177_MTs(count,1); %2 SE
 		EXPORT{count+loc_MT,10} = eHf0_MT(count,1);
 		EXPORT{count+loc_MT,11} = 2*eHf0_MTs(count,1);%2 SE
 		EXPORT{count+loc_MT,12} = HfHfT_MT(count,1);
 		EXPORT{count+loc_MT,13} = eHf_MT(count,1);
		EXPORT{count+loc_MT,14} = 2*eHf_MTs(count,1);%2 SE
 		EXPORT{count+loc_MT,15} = Age_MT;
 		EXPORT{count+loc_MT,16} = Age_MTs;
 		EXPORT{count+loc_MT,17} = H.Yb_Lu_Hf_MT_mean(count,1); %(176Lu+176Yb)/176Hf %)
 		EXPORT{count+loc_MT,18} = v180_MT(count,1);
 		EXPORT{count+loc_MT,19} = (YbHf_MT(count,1) + HfHfT_MT(count,1)) / 0.000028;
 		EXPORT{count+loc_MT,20} = Age_MT;
 		EXPORT{count+loc_MT,21} = eHf_MT(count,1);
		count = count + 1;
	end
end

EXPORT(14+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx),1) = {'MT Mean'};
EXPORT(15+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx),1) = {'MT 2 SD'};
EXPORT{loc_MT+sum(STD_MT_idx)+1,2} = mean(cell2num(EXPORT(loc_MT+1:loc_MT+sum(STD_MT_idx),2)));
EXPORT{loc_MT+sum(STD_MT_idx)+2,2} = 2*std(cell2num(EXPORT(loc_MT+1:loc_MT+sum(STD_MT_idx),2)));
EXPORT{loc_MT+sum(STD_MT_idx)+1,8} = mean(cell2num(EXPORT(loc_MT+1:loc_MT+sum(STD_MT_idx),8)));
EXPORT{loc_MT+sum(STD_MT_idx)+2,8} = 2*std(cell2num(EXPORT(loc_MT+1:loc_MT+sum(STD_MT_idx),8)));
EXPORT{loc_MT+sum(STD_MT_idx)+1,10} = mean(cell2num(EXPORT(loc_MT+1:loc_MT+sum(STD_MT_idx),10)));
EXPORT{loc_MT+sum(STD_MT_idx)+2,10} = 2*std(cell2num(EXPORT(loc_MT+1:loc_MT+sum(STD_MT_idx),10)));
EXPORT{loc_MT+sum(STD_MT_idx)+1,13} = mean(cell2num(EXPORT(loc_MT+1:loc_MT+sum(STD_MT_idx),13)));
EXPORT{loc_MT+sum(STD_MT_idx)+2,13} = 2*std(cell2num(EXPORT(loc_MT+1:loc_MT+sum(STD_MT_idx),13)));

count = 1;
loc_PLES = 16+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx);
for i = 1:length(STD_PLES_idx)
	if STD_PLES_idx(i,1) == 1
		EXPORT(count+loc_PLES,1) = {STD_PLES};
		EXPORT{count+loc_PLES,2} = H.Ratio_STD_176_177_PLES_mean(count,1); %176Hf/177Hf
 		EXPORT{count+loc_PLES,3} = 2*Ratio_STD_176_177_PLES_SE(count,1); %2 SE
 		EXPORT{count+loc_PLES,4} = LuHf_PLES(count,1);
 		EXPORT{count+loc_PLES,5} = 2*LuHf_PLESs(count,1); %2 SE
		EXPORT{count+loc_PLES,6} = YbHf_PLES(count,1);
 		EXPORT{count+loc_PLES,7} = 2*YbHf_PLESs(count,1); %2 SE
 		EXPORT{count+loc_PLES,8} = Hf178_Hf177_PLES(count,1);
 		EXPORT{count+loc_PLES,9} = 2*Hf178_Hf177_PLESs(count,1); %2 SE
 		EXPORT{count+loc_PLES,10} = eHf0_PLES(count,1);
 		EXPORT{count+loc_PLES,11} = 2*eHf0_PLESs(count,1);%2 SE
 		EXPORT{count+loc_PLES,12} = HfHfT_PLES(count,1);
 		EXPORT{count+loc_PLES,13} = eHf_PLES(count,1);
		EXPORT{count+loc_PLES,14} = 2*eHf_PLESs(count,1);%2 SE
 		EXPORT{count+loc_PLES,15} = Age_PLES;
 		EXPORT{count+loc_PLES,16} = Age_PLESs;
 		EXPORT{count+loc_PLES,17} = H.Yb_Lu_Hf_PLES_mean(count,1); %(176Lu+176Yb)/176Hf %)
 		EXPORT{count+loc_PLES,18} = v180_PLES(count,1);
 		EXPORT{count+loc_PLES,19} = (YbHf_PLES(count,1) + HfHfT_PLES(count,1)) / 0.000028;
 		EXPORT{count+loc_PLES,20} = Age_PLES;
 		EXPORT{count+loc_PLES,21} = eHf_PLES(count,1);
		count = count + 1;
	end
end

EXPORT(17+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx),1) = {'PLES Mean'};
EXPORT(18+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx),1) = {'PLES 2 SD'};
EXPORT{loc_PLES+sum(STD_PLES_idx)+1,2} = mean(cell2num(EXPORT(loc_PLES+1:loc_PLES+sum(STD_PLES_idx),2)));
EXPORT{loc_PLES+sum(STD_PLES_idx)+2,2} = 2*std(cell2num(EXPORT(loc_PLES+1:loc_PLES+sum(STD_PLES_idx),2)));
EXPORT{loc_PLES+sum(STD_PLES_idx)+1,8} = mean(cell2num(EXPORT(loc_PLES+1:loc_PLES+sum(STD_PLES_idx),8)));
EXPORT{loc_PLES+sum(STD_PLES_idx)+2,8} = 2*std(cell2num(EXPORT(loc_PLES+1:loc_PLES+sum(STD_PLES_idx),8)));
EXPORT{loc_PLES+sum(STD_PLES_idx)+1,10} = mean(cell2num(EXPORT(loc_PLES+1:loc_PLES+sum(STD_PLES_idx),10)));
EXPORT{loc_PLES+sum(STD_PLES_idx)+2,10} = 2*std(cell2num(EXPORT(loc_PLES+1:loc_PLES+sum(STD_PLES_idx),10)));
EXPORT{loc_PLES+sum(STD_PLES_idx)+1,13} = mean(cell2num(EXPORT(loc_PLES+1:loc_PLES+sum(STD_PLES_idx),13)));
EXPORT{loc_PLES+sum(STD_PLES_idx)+2,13} = 2*std(cell2num(EXPORT(loc_PLES+1:loc_PLES+sum(STD_PLES_idx),13)));

count = 1;
loc_91500 = 19+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx);
for i = 1:length(STD_91500_idx)
	if STD_91500_idx(i,1) == 1
		EXPORT(count+loc_91500,1) = {STD_91500};
		EXPORT{count+loc_91500,2} = H.Ratio_STD_176_177_91500_mean(count,1); %176Hf/177Hf
 		EXPORT{count+loc_91500,3} = 2*Ratio_STD_176_177_91500_SE(count,1); %2 SE
 		EXPORT{count+loc_91500,4} = LuHf_91500(count,1);
 		EXPORT{count+loc_91500,5} = 2*LuHf_91500s(count,1); %2 SE
		EXPORT{count+loc_91500,6} = YbHf_91500(count,1);
 		EXPORT{count+loc_91500,7} = 2*YbHf_91500s(count,1); %2 SE
 		EXPORT{count+loc_91500,8} = Hf178_Hf177_91500(count,1);
 		EXPORT{count+loc_91500,9} = 2*Hf178_Hf177_91500s(count,1); %2 SE
 		EXPORT{count+loc_91500,10} = eHf0_91500(count,1);
 		EXPORT{count+loc_91500,11} = 2*eHf0_91500s(count,1);%2 SE
 		EXPORT{count+loc_91500,12} = HfHfT_91500(count,1);
 		EXPORT{count+loc_91500,13} = eHf_91500(count,1);
		EXPORT{count+loc_91500,14} = 2*eHf_91500s(count,1);%2 SE
 		EXPORT{count+loc_91500,15} = Age_91500;
 		EXPORT{count+loc_91500,16} = Age_91500s;
 		EXPORT{count+loc_91500,17} = H.Yb_Lu_Hf_91500_mean(count,1); %(176Lu+176Yb)/176Hf %)
 		EXPORT{count+loc_91500,18} = v180_91500(count,1);
 		EXPORT{count+loc_91500,19} = (YbHf_91500(count,1) + HfHfT_91500(count,1)) / 0.000028;
 		EXPORT{count+loc_91500,20} = Age_91500;
 		EXPORT{count+loc_91500,21} = eHf_91500(count,1);
		count = count + 1;
	end
end

EXPORT(20+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx)+sum(STD_91500_idx),1) = {'91500 Mean'};
EXPORT(21+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx)+sum(STD_91500_idx),1) = {'91500 2 SD'};
EXPORT{loc_91500+sum(STD_91500_idx)+1,2} = mean(cell2num(EXPORT(loc_91500+1:loc_91500+sum(STD_91500_idx),2)));
EXPORT{loc_91500+sum(STD_91500_idx)+2,2} = 2*std(cell2num(EXPORT(loc_91500+1:loc_91500+sum(STD_91500_idx),2)));
EXPORT{loc_91500+sum(STD_91500_idx)+1,8} = mean(cell2num(EXPORT(loc_91500+1:loc_91500+sum(STD_91500_idx),8)));
EXPORT{loc_91500+sum(STD_91500_idx)+2,8} = 2*std(cell2num(EXPORT(loc_91500+1:loc_91500+sum(STD_91500_idx),8)));
EXPORT{loc_91500+sum(STD_91500_idx)+1,10} = mean(cell2num(EXPORT(loc_91500+1:loc_91500+sum(STD_91500_idx),10)));
EXPORT{loc_91500+sum(STD_91500_idx)+2,10} = 2*std(cell2num(EXPORT(loc_91500+1:loc_91500+sum(STD_91500_idx),10)));
EXPORT{loc_91500+sum(STD_91500_idx)+1,13} = mean(cell2num(EXPORT(loc_91500+1:loc_91500+sum(STD_91500_idx),13)));
EXPORT{loc_91500+sum(STD_91500_idx)+2,13} = 2*std(cell2num(EXPORT(loc_91500+1:loc_91500+sum(STD_91500_idx),13)));

count = 1;
loc_FC = 22+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx)+sum(STD_91500_idx);
for i = 1:length(STD_FC_idx)
	if STD_FC_idx(i,1) == 1
		EXPORT(count+loc_FC,1) = {STD_FC};
		EXPORT{count+loc_FC,2} = H.Ratio_STD_176_177_FC_mean(count,1); %176Hf/177Hf
 		EXPORT{count+loc_FC,3} = 2*Ratio_STD_176_177_FC_SE(count,1); %2 SE
 		EXPORT{count+loc_FC,4} = LuHf_FC(count,1);
 		EXPORT{count+loc_FC,5} = 2*LuHf_FCs(count,1); %2 SE
		EXPORT{count+loc_FC,6} = YbHf_FC(count,1);
 		EXPORT{count+loc_FC,7} = 2*YbHf_FCs(count,1); %2 SE
 		EXPORT{count+loc_FC,8} = Hf178_Hf177_FC(count,1);
 		EXPORT{count+loc_FC,9} = 2*Hf178_Hf177_FCs(count,1); %2 SE
 		EXPORT{count+loc_FC,10} = eHf0_FC(count,1);
 		EXPORT{count+loc_FC,11} = 2*eHf0_FCs(count,1);%2 SE
 		EXPORT{count+loc_FC,12} = HfHfT_FC(count,1);
 		EXPORT{count+loc_FC,13} = eHf_FC(count,1);
		EXPORT{count+loc_FC,14} = 2*eHf_FCs(count,1);%2 SE
 		EXPORT{count+loc_FC,15} = Age_FC;
 		EXPORT{count+loc_FC,16} = Age_FCs;
 		EXPORT{count+loc_FC,17} = H.Yb_Lu_Hf_FC_mean(count,1); %(176Lu+176Yb)/176Hf %)
 		EXPORT{count+loc_FC,18} = v180_FC(count,1);
 		EXPORT{count+loc_FC,19} = (YbHf_FC(count,1) + HfHfT_FC(count,1)) / 0.000028;
 		EXPORT{count+loc_FC,20} = Age_FC;
 		EXPORT{count+loc_FC,21} = eHf_FC(count,1);
		count = count + 1;
	end
end

EXPORT(23+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx)+sum(STD_91500_idx)+sum(STD_FC_idx),1) = {'FC Mean'};
EXPORT(24+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx)+sum(STD_91500_idx)+sum(STD_FC_idx),1) = {'FC 2 SD'};
EXPORT{loc_FC+sum(STD_FC_idx)+1,2} = mean(cell2num(EXPORT(loc_FC+1:loc_FC+sum(STD_FC_idx),2)));
EXPORT{loc_FC+sum(STD_FC_idx)+2,2} = 2*std(cell2num(EXPORT(loc_FC+1:loc_FC+sum(STD_FC_idx),2)));
EXPORT{loc_FC+sum(STD_FC_idx)+1,8} = mean(cell2num(EXPORT(loc_FC+1:loc_FC+sum(STD_FC_idx),8)));
EXPORT{loc_FC+sum(STD_FC_idx)+2,8} = 2*std(cell2num(EXPORT(loc_FC+1:loc_FC+sum(STD_FC_idx),8)));
EXPORT{loc_FC+sum(STD_FC_idx)+1,10} = mean(cell2num(EXPORT(loc_FC+1:loc_FC+sum(STD_FC_idx),10)));
EXPORT{loc_FC+sum(STD_FC_idx)+2,10} = 2*std(cell2num(EXPORT(loc_FC+1:loc_FC+sum(STD_FC_idx),10)));
EXPORT{loc_FC+sum(STD_FC_idx)+1,13} = mean(cell2num(EXPORT(loc_FC+1:loc_FC+sum(STD_FC_idx),13)));
EXPORT{loc_FC+sum(STD_FC_idx)+2,13} = 2*std(cell2num(EXPORT(loc_FC+1:loc_FC+sum(STD_FC_idx),13)));

count = 1;
loc_SL = 25+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx)+sum(STD_91500_idx)+sum(STD_FC_idx);
for i = 1:length(STD_SL_idx)
	if STD_SL_idx(i,1) == 1
		EXPORT(count+loc_SL,1) = {STD_SL};
		EXPORT{count+loc_SL,2} = H.Ratio_STD_176_177_SL_mean(count,1); %176Hf/177Hf
 		EXPORT{count+loc_SL,3} = 2*Ratio_STD_176_177_SL_SE(count,1); %2 SE
 		EXPORT{count+loc_SL,4} = LuHf_SL(count,1);
 		EXPORT{count+loc_SL,5} = 2*LuHf_SLs(count,1); %2 SE
		EXPORT{count+loc_SL,6} = YbHf_SL(count,1);
 		EXPORT{count+loc_SL,7} = 2*YbHf_SLs(count,1); %2 SE
 		EXPORT{count+loc_SL,8} = Hf178_Hf177_SL(count,1);
 		EXPORT{count+loc_SL,9} = 2*Hf178_Hf177_SLs(count,1); %2 SE
 		EXPORT{count+loc_SL,10} = eHf0_SL(count,1);
 		EXPORT{count+loc_SL,11} = 2*eHf0_SLs(count,1);%2 SE
 		EXPORT{count+loc_SL,12} = HfHfT_SL(count,1);
 		EXPORT{count+loc_SL,13} = eHf_SL(count,1);
		EXPORT{count+loc_SL,14} = 2*eHf_SLs(count,1);%2 SE
 		EXPORT{count+loc_SL,15} = Age_SL;
 		EXPORT{count+loc_SL,16} = Age_SLs;
 		EXPORT{count+loc_SL,17} = H.Yb_Lu_Hf_SL_mean(count,1); %(176Lu+176Yb)/176Hf %)
 		EXPORT{count+loc_SL,18} = v180_SL(count,1);
 		EXPORT{count+loc_SL,19} = (YbHf_SL(count,1) + HfHfT_SL(count,1)) / 0.000028;
 		EXPORT{count+loc_SL,20} = Age_SL;
 		EXPORT{count+loc_SL,21} = eHf_SL(count,1);
		count = count + 1;
	end
end

EXPORT(26+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx)+sum(STD_91500_idx)+sum(STD_FC_idx)+sum(STD_SL_idx),1) = {'SL Mean'};
EXPORT(27+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx)+sum(STD_91500_idx)+sum(STD_FC_idx)+sum(STD_SL_idx),1) = {'SL 2 SD'};
EXPORT{loc_SL+sum(STD_SL_idx)+1,2} = mean(cell2num(EXPORT(loc_SL+1:loc_SL+sum(STD_SL_idx),2)));
EXPORT{loc_SL+sum(STD_SL_idx)+2,2} = 2*std(cell2num(EXPORT(loc_SL+1:loc_SL+sum(STD_SL_idx),2)));
EXPORT{loc_SL+sum(STD_SL_idx)+1,8} = mean(cell2num(EXPORT(loc_SL+1:loc_SL+sum(STD_SL_idx),8)));
EXPORT{loc_SL+sum(STD_SL_idx)+2,8} = 2*std(cell2num(EXPORT(loc_SL+1:loc_SL+sum(STD_SL_idx),8)));
EXPORT{loc_SL+sum(STD_SL_idx)+1,10} = mean(cell2num(EXPORT(loc_SL+1:loc_SL+sum(STD_SL_idx),10)));
EXPORT{loc_SL+sum(STD_SL_idx)+2,10} = 2*std(cell2num(EXPORT(loc_SL+1:loc_SL+sum(STD_SL_idx),10)));
EXPORT{loc_SL+sum(STD_SL_idx)+1,13} = mean(cell2num(EXPORT(loc_SL+1:loc_SL+sum(STD_SL_idx),13)));
EXPORT{loc_SL+sum(STD_SL_idx)+2,13} = 2*std(cell2num(EXPORT(loc_SL+1:loc_SL+sum(STD_SL_idx),13)));

EXPORT(29+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx)+sum(STD_91500_idx)+sum(STD_FC_idx)+sum(STD_SL_idx):...
	52+length(nonzeros(SAMPLES_idx))+sum(STD_R33_idx)+sum(STD_TEM_idx)+sum(STD_MT_idx)+sum(STD_PLES_idx)+sum(STD_91500_idx)+sum(STD_FC_idx)+sum(STD_SL_idx),1) = ...
{'1) Corrected 176Hf/177Hf ratio.';
'2) Uncertainty in corrected 176Hf/177Hf ratio (expressed at the 95% confidence interval)';...
'3) Corrected 176Lu/177Hf ratio.';...
'4) Uncertainty in corrected 176Lu//177Hf ratio (expressed at the 95% confidence interval).';...
'5) Corrected 176Yb/177Hf ratio.';...
'6) Uncertainty in corrected 176Yb/177Hf ratio (expressed at the 95% confidence interval.';...
'7) Corrected 178Hf/177Hf ratio.';...
'8) Uncertainty in corrected 178Hf/177Hf ratio (expressed at the 95% confidence interval.';...
'9) Present day EHf value (EHf(0))';...
'10) Uncertainty in present day EHf value (expressed at the 95% confidence interval) expressed in epsilon notation.';...
'11) Initial 176Hf/177Hf ratio (i).';...
'12) The calculated initial EHf (EHf(i)) or calculated EHf value at some time, t.';...
'decay constant of Soderlund et al. (2004) was used (1.867*10-11 year-1).';...
'13) Uncertainty in initial EHf value (expressed at the 95% confidence interval) expressed in epsilon notation.';...
'14) Crystallization age used for determining initial 176Hf/177Hf and initial EHf.';...
'15) Uncertainty in age used for determining initial 176Hf/177Hf and initial EHf (expressed at the 95% confidence interval).';...
'16) Mass bias (in %) calculated as (176Yb + 176Lu)/176Hf.';...
'17) The total Hf voltage of the analysis.';...
'18) Interference correction expressed in EHf units, estimated as ((176Yb/177Hf + 176Lu/177Hf)/(0.000028)).';...
'19) Age (Ma).';...
'20) Initial EHf, EHf(i).';...
'Reference for Lu-Hf Methods: Ibanez-Mejia, M., Gehrels, G.E., Ruiz, J., Vervoort, J.D., Eddy, M.P. and Li, C., 2014. Small-volume baddeleyite (ZrO2) U-Pb geochronology and Lu-Hf isotope geochemistry by LA-ICP-MS. Techniques and applications. Chemical Geology, 384, pp.149-167.';...
'Reference for Arizona LaserChron Center: Gehrels, G.E., Valencia, V.A. and Ruiz, J., 2008. Enhanced precision, accuracy, efficiency, and spatial resolution of U-Pb ages by laser ablation-multicollector-inductively coupled plasma-mass spectrometry. Geochemistry, Geophysics, Geosystems, 9(3), pp. 1-13.';...
'Reference for data reduction software (AgeCalcML): Sundell, K.E., Gehrels, G.E. and Pecha, M.E., 2021. Rapid U-Pb Geochronology by Laser Ablation Multi-collector ICP-MS. Geostandards and Geoanalytical Research, 45(1), pp.37-57.'};

















H.EXPORT = EXPORT;

%sample	Yb_Lu_Hf_UNKNOWN_mean	v180_UNKNOWN	Ratio_UNKNOWN_176_177_mean	Ratio_UNKNOWN_176_177_SE	LuHf_UNKNOWN	HfHfT_UNKNOWN	eHf0_UNKNOWN	eHf0_UNKNOWNs	eHf_UNKNOWNS	Ages_mean


H.samp_length = samp_length;
H.TRA = TRA;

H.current_status = current_status;
H.current_status_num = current_status_num;


H.sample = sample;
H.BLS_176 = BLS_176;
H.BLS_177 = BLS_177;
H.BLS_180 = BLS_180;
H.BLS_176_177_corr = BLS_176_177_corr;
H.reduced = reduced;
H.match = match;
H.match2 = match2;

H.SAMPLES_idx = SAMPLES_idx;

%H.Data = Data;
%H.Names = Names;
%H.values_tmp = values_tmp;
%H.t0_180 = t0_180;
%H.t0_idx = t0_idx;

H.values_all = values_all;
H.baseline = baseline;
H.integration = integration;

H.data_count = data_count;

H.STD_MT_idx = STD_MT_idx;
H.STD_SL_idx = STD_SL_idx;
H.STD_R33_idx = STD_R33_idx;
H.STD_TEM_idx = STD_TEM_idx;
H.STD_91500_idx = STD_91500_idx;
H.STD_PLES_idx = STD_PLES_idx;
H.STD_FC_idx = STD_FC_idx;
H.SAMPLES_idx = SAMPLES_idx;
H.STD_idx = STD_idx;

H.offset_MT = offset_MT;
H.offset_SL = offset_SL;
H.offset_R33 = offset_R33;
H.offset_TEM = offset_TEM;
H.offset_91500 = offset_91500;
H.offset_PLES = offset_PLES;
H.offset_FC = offset_FC;



if sum(SAMPLES_idx) > 0
	H.eHf_UNKNOWNS = eHf_UNKNOWNS;
	H.Ages_ascribed = Ages_ascribed;
	H.Yb_Lu_Hf_UNKNOWN_mean = Yb_Lu_Hf_UNKNOWN_mean;
	H.Ratio_UNKNOWN_176_177_mean = Ratio_UNKNOWN_176_177_mean;
	H.Ratio_UNKNOWN_176_177_mean = Ratio_UNKNOWN_176_177_mean;
end

stds_PLOT_Callback(hObject, eventdata, H)

ind_PLOT_Callback(hObject, eventdata, H)

results_PLOT_Callback(hObject, eventdata, H)

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
cla(H.STDS_plot,'reset');
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
if get(H.stds_setscale,'Value') == 1
	axis([-10 80 0.2813 0.2831])
end

name_tmp = (get(H.ind_listbox1,'String'));
if H.STD_idx(get(H.ind_listbox1,'Value'),1) == 1
	if H.STD_MT_idx(get(H.ind_listbox1,'Value'),1) == 1
		if contains(name_tmp(get(H.ind_listbox1,'Value')),'xx') == 0
			idxs = sum(H.STD_MT_idx(1:get(H.ind_listbox1,'Value')));
			scatter(H.Yb_Lu_Hf_MT_mean(idxs,1), H.Ratio_STD_176_177_MT_mean(idxs,1), 500, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
		end
	end
	if H.STD_SL_idx(get(H.ind_listbox1,'Value'),1) == 1
		if contains(name_tmp(get(H.ind_listbox1,'Value')),'xx') == 0
			idxs = sum(H.STD_SL_idx(1:get(H.ind_listbox1,'Value')));
			scatter(H.Yb_Lu_Hf_SL_mean(idxs,1), H.Ratio_STD_176_177_SL_mean(idxs,1), 500, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
		end
	end
	if H.STD_R33_idx(get(H.ind_listbox1,'Value'),1) == 1
		if contains(name_tmp(get(H.ind_listbox1,'Value')),'xx') == 0
			idxs = sum(H.STD_R33_idx(1:get(H.ind_listbox1,'Value')));
			scatter(H.Yb_Lu_Hf_R33_mean(idxs,1), H.Ratio_STD_176_177_R33_mean(idxs,1), 500, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
		end
	end
	if H.STD_TEM_idx(get(H.ind_listbox1,'Value'),1) == 1
		if contains(name_tmp(get(H.ind_listbox1,'Value')),'xx') == 0
			idxs = sum(H.STD_TEM_idx(1:get(H.ind_listbox1,'Value')));
			scatter(H.Yb_Lu_Hf_TEM_mean(idxs,1), H.Ratio_STD_176_177_TEM_mean(idxs,1), 500, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
		end
	end
	if H.STD_91500_idx(get(H.ind_listbox1,'Value'),1) == 1
		if contains(name_tmp(get(H.ind_listbox1,'Value')),'xx') == 0
			idxs = sum(H.STD_91500_idx(1:get(H.ind_listbox1,'Value')));
			scatter(H.Yb_Lu_Hf_91500_mean(idxs,1), H.Ratio_STD_176_177_91500_mean(idxs,1), 500, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
		end
	end
	if H.STD_PLES_idx(get(H.ind_listbox1,'Value'),1) == 1
		if contains(name_tmp(get(H.ind_listbox1,'Value')),'xx') == 0
			idxs = sum(H.STD_PLES_idx(1:get(H.ind_listbox1,'Value')));
			scatter(H.Yb_Lu_Hf_PLES_mean(idxs,1), H.Ratio_STD_176_177_PLES_mean(idxs,1), 500, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
		end
	end
	if H.STD_FC_idx(get(H.ind_listbox1,'Value'),1) == 1
		if contains(name_tmp(get(H.ind_listbox1,'Value')),'xx') == 0
			idxs = sum(H.STD_FC_idx(1:get(H.ind_listbox1,'Value')));
			scatter(H.Yb_Lu_Hf_FC_mean(idxs,1), H.Ratio_STD_176_177_FC_mean(idxs,1), 500, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
		end
	end
end

hold off

function ind_PLOT_Callback(hObject, eventdata, H)

cla(H.SingleAnalysis_plot,'reset')

BLS_176_177_corr = H.BLS_176_177_corr;
sample = H.sample;
name_idx = get(H.ind_listbox1,'Value');

axes(H.SingleAnalysis_plot);
hold on


x = 1:1:H.samp_length;

if get(H.ind_176_177,'Value') == 1
	for i = 1:H.samp_length
		if BLS_176_177_corr(i,name_idx) ~= 0
			scatter(x(1,i), BLS_176_177_corr(i,name_idx), 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
		end
	end
	hold off
	legend(sample(name_idx,1))
	xlabel('Integration Number')
	ylabel('176/177 Corrected')
	xlim([0 H.samp_length])
end
if get(H.ind_180,'Value') == 1
	scatter(x, H.BLS_180(:,name_idx), 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	legend(sample(name_idx,1))
	xlabel('Time (s)')
	ylabel('Baseline subtracted 180')
	hold off
end

function results_PLOT_Callback(hObject, eventdata, H)

DM_Slider = str2num(get(H.results_dmt,'String'));

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





















cla(H.Results_plot,'reset');
axes(H.Results_plot);
hold on

if sum(H.SAMPLES_idx) > 0
	if get(H.results_data, 'Value') == 1
		scatter(H.Yb_Lu_Hf_UNKNOWN_mean, H.Ratio_UNKNOWN_176_177_mean, 100, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
		
		
		
		idx = H.match2(get(H.ind_listbox1,'Value'),1);
		if idx ~= 0
			s1 = scatter(H.Yb_Lu_Hf_UNKNOWN_mean(idx,1), H.Ratio_UNKNOWN_176_177_mean(idx,1), 200, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
			%legend({'Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193'}, 'Location', 'southeast')
		else
			%s1 = scatter(H.Yb_Lu_Hf_UNKNOWN_mean(1,1), H.Ratio_UNKNOWN_176_177_mean(1,1), 200, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
			%set(s1,'Visible','off')
		end
		
		
		
		
		legend('Unknowns')
		xlabel('176(Yb+Lu) / 176Hf (%)')
		ylabel('176Hf/177Hf')
	end
end

if get(H.results_evolution, 'Value') == 1
	if sum(H.SAMPLES_idx) > 0
		scatter(H.Ages_ascribed(:,1), H.Ratio_UNKNOWN_176_177_mean, 100, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	end
	plot(Evolution_plot(:,3),Evolution_plot(:,5),'k','LineWidth',2)
	plot(Evolution_plot(:,3),Evolution_plot(:,4),'r','LineWidth',2)
	plot(Evolution_plot(:,3),Evolution_plot(:,1),'r','LineWidth',1)
	plot(Evolution_plot(:,3),Evolution_plot(:,2),'r','LineWidth',1)
	plot([0 DM_Slider],[Y0_u_Evol_DM_176Lu_177Hf,Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	plot([0 DM_Slider],[Y0_Evol_DM_176Lu_177Hf, Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 2)
	plot([0 DM_Slider],[Y0_l_Evol_DM_176Lu_177Hf, Ys_Evol_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	
	
	if sum(H.SAMPLES_idx) > 0
		idx = H.match2(get(H.ind_listbox1,'Value'),1);
		if idx ~= 0
			s1 = scatter(H.Ages_ascribed(idx,1), H.Ratio_UNKNOWN_176_177_mean(idx,1), 200, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
			%legend({'Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193'}, 'Location', 'southeast')
		else
			%s1 = scatter(H.Ages_ascribed(1,1), H.Ratio_UNKNOWN_176_177_mean(1,1), 200, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
			%set(s1,'Visible','off')
		end
		
		legend({'Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193'}, 'Location', 'southeast')
	end
	
	
	
	
	
	
	
	
	
	
	
	%if sum(H.SAMPLES_idx) > 0
	%	legend({'Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193'}, 'Location', 'southeast')
	%end
	xlabel('Age (Ma)')
	ylabel('176Hf/177Hf(T)')
end

if get(H.results_epsilon, 'Value') == 1
	if sum(H.SAMPLES_idx) > 0
		scatter(H.Ages_ascribed(:,1), H.eHf_UNKNOWNS, 100, 'd', 'MarkerEdgeColor','k', 'MarkerFaceColor','b')
	end
	plot(Epsilon_plot(:,3),Epsilon_plot(:,5),'k','LineWidth',2)
	plot(Epsilon_plot(:,3),Epsilon_plot(:,4),'r','LineWidth',2)
	plot(Epsilon_plot(:,3),Epsilon_plot(:,1),'--r','LineWidth',1)
	plot(Epsilon_plot(:,3),Epsilon_plot(:,2),'--r','LineWidth',1)
	plot([0 DM_Slider],[Y0_u_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	plot([0 DM_Slider],[Y0_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 2)
	plot([0 DM_Slider],[Y0_l_Epsi_DM_176Lu_177Hf, Ys_Epsi_DM_176Lu_177Hf], 'Color', [0.4,0.4,0.4], 'LineWidth', 1)
	
	if sum(H.SAMPLES_idx) > 0
		idx = H.match2(get(H.ind_listbox1,'Value'),1);
		if idx ~= 0
			s1 = scatter(H.Ages_ascribed(idx,1), H.eHf_UNKNOWNS(idx,1), 200, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
			%legend({'Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193'}, 'Location', 'southeast')
		else
			%s1 = scatter(H.Ages_ascribed(1,1), H.eHf_UNKNOWNS(1,1), 200, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 2);
			%set(s1,'Visible','off')
		end
		legend({'Unknowns', 'CHUR', 'Depleted Mantle (DM)', 'DM+', 'DM-', '176Lu/177Hf = 0.0036', '176Lu/177Hf = 0.0115', '176Lu/177Hf = 0.0193'}, 'Location', 'southeast')
	end
	xlabel('Age (Ma)')
	ylabel('Epsilon Hf')
end
if get(H.results_autoscale,'Value') == 0
	axis([str2num(get(H.results_xmin,'String')) str2num(get(H.results_xmax,'String')) str2num(get(H.results_ymin,'String')) str2num(get(H.results_ymax,'String'))])
end








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

function stdopt_intcutoff_Callback(hObject, eventdata, H)



function ind_listbox1_Callback(hObject, eventdata, H)
ind_PLOT_Callback(hObject, eventdata, H)


%if H.STD_idx(get(H.ind_listbox1,'Value'),1) == 1
stds_PLOT_Callback(hObject, eventdata, H)
%end


results_PLOT_Callback(hObject, eventdata, H)

function ind_180_Callback(hObject, eventdata, H)
set(H.ind_180,'Value', 1)
set(H.ind_176_177,'Value', 0)
ind_PLOT_Callback(hObject, eventdata, H)

function ind_176_177_Callback(hObject, eventdata, H)
set(H.ind_180,'Value', 0)
set(H.ind_176_177,'Value', 1)
ind_PLOT_Callback(hObject, eventdata, H)



function AccRej_Callback(hObject, eventdata, H)

H.currView = get(H.ind_listbox1,'ListBoxTop');
analysis_num = get(H.ind_listbox1,'Value');
names_tmp = get(H.ind_listbox1,'String');
names_tmp(analysis_num,1) = strcat('<html><BODY bgcolor="red">',{'xx'},'</span></html>');
H.sample = names_tmp;
set(H.ind_listbox1,'String',H.sample)
set(H.ind_listbox1,'ListBoxTop',H.currView)
%H.sample = get(H.ind_listbox1,'String');
guidata(hObject,H);


function EditSampleName_Callback(hObject, eventdata, H)
H.currView = get(H.ind_listbox1,'ListBoxTop');
analysis_num = get(H.ind_listbox1,'Value');
names_tmp = get(H.ind_listbox1,'String');
names_tmp(analysis_num,1) = strcat('<html><BODY bgcolor="lime">',{'Burn through'},'</span></html>');
H.sample = names_tmp;
set(H.ind_listbox1,'String',H.sample)
set(H.ind_listbox1,'ListBoxTop',H.currView)
%H.sample = get(H.ind_listbox1,'String');
guidata(hObject,H);


function results_data_Callback(hObject, eventdata, H)
set(H.results_autoscale, 'Value', 1);
set(H.results_data, 'Value', 1);
set(H.results_evolution, 'Value', 0);
set(H.results_epsilon, 'Value', 0);
results_PLOT_Callback(hObject, eventdata, H)

function results_evolution_Callback(hObject, eventdata, H)
set(H.results_autoscale, 'Value', 1);
set(H.results_data, 'Value', 0);
set(H.results_evolution, 'Value', 1);
set(H.results_epsilon, 'Value', 0);
results_PLOT_Callback(hObject, eventdata, H)

function results_epsilon_Callback(hObject, eventdata, H)
set(H.results_autoscale, 'Value', 1);
set(H.results_data, 'Value', 0);
set(H.results_evolution, 'Value', 0);
set(H.results_epsilon, 'Value', 1);
results_PLOT_Callback(hObject, eventdata, H)

function results_dmt_Callback(hObject, eventdata, H)
H.DM_Slider = str2num(get(H.results_dmt,'String'))/4500;
set(H.results_dms, 'Value', H.DM_Slider);
guidata(hObject,H);
results_PLOT_Callback(hObject, eventdata, H)

function results_dms_Callback(hObject, eventdata, H)
H.DM_Slider = get(H.results_dms,'Value')*4500;
set(H.results_dmt,'String',H.DM_Slider);
guidata(hObject,H);
results_PLOT_Callback(hObject, eventdata, H)

function results_xmin_Callback(hObject, eventdata, H)
results_PLOT_Callback(hObject, eventdata, H)
set(H.results_autoscale,'Value',0)

function results_xmax_Callback(hObject, eventdata, H)
results_PLOT_Callback(hObject, eventdata, H)
set(H.results_autoscale,'Value',0)

function results_ymin_Callback(hObject, eventdata, H)
results_PLOT_Callback(hObject, eventdata, H)
set(H.results_autoscale,'Value',0)

function results_ymax_Callback(hObject, eventdata, H)
results_PLOT_Callback(hObject, eventdata, H)
set(H.results_autoscale,'Value',0)

function results_legend_Callback(hObject, eventdata, H)

function results_autoscale_Callback(hObject, eventdata, H)
results_PLOT_Callback(hObject, eventdata, H)

function results_intcutoff_Callback(hObject, eventdata, H)



function Export_Reduced_Callback(hObject, eventdata, H)

EXPORT = H.EXPORT;
[file,path] = uiputfile('*.xls','Save file');
writetable(table(EXPORT),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);


function Export_Plots_Callback(hObject, eventdata, H)

function Save_Session_Callback(hObject, eventdata, H)

function Upload_Session_Callback(hObject, eventdata, H)



function defaultage_Callback(hObject, eventdata, H)



function unc_cutoff_Callback(hObject, eventdata, H)



function epsiloncutoffhi_Callback(hObject, eventdata, H)



function epsiloncutofflo_Callback(hObject, eventdata, H)








function flag_Callback(hObject, eventdata, H)


function filterstandards_Callback(hObject, eventdata, H)



function flagunknowns_Callback(hObject, eventdata, H)


function tzero_Callback(hObject, eventdata, H)

%data_count = H.data_count;




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
filenames_sorted = natsortfiles(filenames);

TRA = 0;
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
	elseif isempty(findstr(char(filenames_sorted(i,1)), '.run')) == 0
		filename_data{i,1} = filenames_sorted(i,1);
	elseif isempty(findstr(char(filenames_sorted(i,1)), '.scancsv')) == 0
		filename_scancsv{i,1} = filenames_sorted(i,1);
		filename_scancsv(all(cellfun('isempty',filename_scancsv),2),:) = [];
		TRA = 1;
	end
end

filename_data(all(cellfun('isempty',filename_data),2),:) = [];









if TRA == 1
	firstline = 74;
	cols = 13;
	
	
	
	if length(filename_scancsv) > 1
		
		
		
		f = errordlg('You can only test one run at a time for t zero.... :(','Sorry!');
		
		return
		
	end
	
	
	if length(filename_scancsv) == 1
		if ispc == 1
			fullpathname_data = char(strcat(folder_name, '\', filename_data{1,1}));
		end
		if ismac == 1
			fullpathname_data = char(strcat(folder_name, '/', filename_data{1,1}));
		end
		
		if ispc == 1
			fullpathname_names = char(strcat(folder_name, '\', filename_scancsv{1,1}));
		end
		if ismac == 1
			fullpathname_names = char(strcat(folder_name, '/', filename_scancsv{1,1}));
		end
		
		
		
		
		
		Data = importdata(char(fullpathname_data),',',500000);
		
		if H.reduced == 0
			Names = importdata(fullpathname_names);
			Names = Names(2:end,1);
		end

		
		if H.reduced == 1
			Names = H.Names;
		end
		
		
		data_count = length(Names);
		
		
		
		
		
		if H.reduced == 0
			for i = 1:data_count
				name_tmp = char(Names(i,1));
				name_tmp_idx = strfind(name_tmp, '"');
				sample{i,:} = name_tmp(1,(name_tmp_idx(1,1)+1):(name_tmp_idx(1,2)-1));
				clear name_tmp name_tmp_idx
			end
		end
		
		if H.reduced == 1
			sample = H.sample;
		end		
		
		
		
	end
	
	
	
	%{
		if 50*length(sample)+firstline < length(Data(firstline:end,1))
			rws = 50*length(sample)+firstline;
		else
			rws = length(Data(firstline:end,1));
		end
	%}
	rws = length(Data(firstline:end,1));
	
	%rws = 50*length(sample)+firstline;
	values_tmp1{rws,cols} = [];
	for j = 1:rws
		values_all_cell(j,:) = regexp(Data(j+firstline-1), ',', 'split');
		values_tmp1(j,1:13) = values_all_cell{j,1}(1,1:13);
	end
	% patch for MATLAB versions earlier than 2018b, cell #11 has weirdness
	% with the 2021a update
	if verLessThan('matlab', '9.6') == 1
		for k = 1:cols
			values_tmp(:,k) = str2num(str2mat(values_tmp1(:,k)));
		end
	else
		for k = 1:cols
			if k ~= 12
				values_tmp(:,k) = str2num(str2mat(values_tmp1(:,k)));
			end
		end
		for j = 1:rws
			values_tmp(j,12) = str2num(strrep(cell2mat(values_all_cell{j,1}(1,12)),'"',''));
		end
	end
	
	%{
			values_tmp = zeros(length(Data(firstline:end,1)),cols);
			for j = 1:length(Data(firstline:end,1))
				values_all_cell = regexp(Data(j+firstline-1), ',', 'split');
				for k = 1:cols
					values_tmp(j,k) = str2num(cell2mat(values_all_cell{1,1}(1,k)));
				end
			end
	%}
	
	
	thresh = 0;
	
	for i = 1:rws
		if values_tmp(i,1) > thresh
			thresh180(i,1) = 1;
		else
			thresh180(i,1) = 0;
		end
	end
	
	for i = 2:rws-2
		if thresh180(i,1) == 1 && thresh180(i-1) == 0 && values_tmp(i+1,1) > thresh && values_tmp(i+2,1) > thresh && values_tmp(i+3,1) > thresh && values_tmp(i+4,1) > thresh && ...
				values_tmp(i-1,1) < thresh && values_tmp(i-2,1) < thresh && values_tmp(i-3,1) < thresh && values_tmp(i-4,1) < thresh
			t0_180(i,1) = values_tmp(i,cols-1);
			t0_idx(i,1) = values_tmp(i,cols-2);
		else
			t0_180(i,1) = 0;
		end
	end
	
	t0_180 = nonzeros(t0_180);
	t0_idx = nonzeros(t0_idx);
	diff_idx = diff(t0_idx);
	diff_ch =  median(diff_idx) < diff_idx - 10;
	%{
		figure
		hold on
		plot(1:1:length(values_tmp(:,1)),values_tmp(:,1))
		scatter(t0_idx,zeros(length(t0_idx),1),'filled')
		hold off
	%}
	
	
	
	
	%T Zero Find by Medians
	% Missing t0s (singles)
	if data_count > length(t0_idx) && sum(diff_ch) > 0
		for i = 1:length(diff_ch)
			if diff_ch(i,1) == 1
				t0_adj = t0_idx(1:i,1);
				t0_adj(i+1,1) = 0;
				t0_adj(i+2:i+2+length(t0_idx(i+2:end,1)),1) = t0_idx(i+1:end,1);
				t0_idx_bf = t0_adj(i,1);
				t0_idx_af = t0_adj(i+2,1);
				t0_adj(i+1,1) = round(t0_idx_bf + (t0_idx_af - t0_idx_bf)/2);
				t0_idx = t0_adj;
				diff_idx = diff(nonzeros(t0_adj));
				diff_ch =  median(diff_idx) < diff_idx - 10;
				clear t0_adj
			end
		end
		for i = 1:length(t0_idx)
			t0(i,1) = values_tmp(t0_idx(i,1),cols-1);
			t0_180(i,1) = values_tmp(t0_idx(i,1),cols-1);
		end
	else
		t0 = t0_180;
	end
	
	% Missing t0s (multiples)
	if data_count > length(t0_idx) && sum(diff_ch) > 0
		for i = 1:length(diff_ch)
			if diff_ch(i,1) == 1 && diff_idx(i,1) > 2*median(diff_idx)
				t0_adj = t0_idx(1:i,1);
				t0_div = round(diff_idx(i,1)/median(diff_idx),0);
				t0_adj(i+1:i+t0_div-1,1) = 0;
				t0_adj(i+t0_div:i+t0_div+length(t0_idx(i+2:end,1)),1) = t0_idx(i+1:end,1);
				t0_idx_bf = t0_adj(i,1);
				t0_idx_af = t0_adj(i+t0_div,1);
				t0_add = round((t0_idx_af - t0_idx_bf)/t0_div);
				for j = 1:t0_div - 1
					t0_adj(i+j,1) = t0_adj(i,1) + t0_add*j;
				end
				t0_idx = t0_adj;
				diff_idx = diff(nonzeros(t0_adj));
				diff_ch =  median(diff_idx) < diff_idx - 50;
				clear t0_adj
			end
		end
		for i = 1:length(t0_idx)
			t0(i,1) = values_tmp(t0_idx(i,1),cols-1);
			t0_180(i,1) = values_tmp(t0_idx(i,1),cols-1);
		end
	else
		t0 = t0_180;
	end
	
	start_idx = t0_idx - 7;
	end_idx = t0_idx + 38;
	sampl_length = end_idx(1,1)-start_idx(1,1)+1;
	
	%%% Indexes
	for i = 1:data_count
		values_all(1:sampl_length,1:cols,i) = values_tmp(start_idx(i,1):end_idx(i,1),1:cols);
		baseline(1:6,1:cols,i) = values_all(1:6,1:cols,i);
		integration(1:30,1:cols,i) = values_all(10:39,1:cols,i);
	end
	
	for j = 1:data_count
		for i = 1:length(baseline(:,j))
			if baseline(i,j) > median(baseline(:,j)) + 2*std(baseline(:,j)) || baseline(i,j) < median(baseline(:,j)) - 2*std(baseline(:,j))
				baseline(i,j) = 0;
			else
				baseline(i,j) = baseline(i,j);
			end
		end
	end
	
	samp_length = length(integration(:,1,1));
	
	
	
% 	
% 	
% 
% 	
% 	
% 	for i = 1:data_count
% 		mean180BL(i,1) = mean(nonzeros(baseline(:,1,i)));
% 		mean179BL(i,1) = mean(nonzeros(baseline(:,2,i)));
% 		mean178BL(i,1) = mean(nonzeros(baseline(:,3,i)));
% 		mean177BL(i,1) = mean(nonzeros(baseline(:,4,i)));
% 		mean176BL(i,1) = mean(nonzeros(baseline(:,5,i)));
% 		mean175BL(i,1) = mean(nonzeros(baseline(:,6,i)));
% 		mean174BL(i,1) = mean(nonzeros(baseline(:,7,i)));
% 		mean173BL(i,1) = mean(nonzeros(baseline(:,8,i)));
% 		mean172BL(i,1) = mean(nonzeros(baseline(:,9,i)));
% 		mean171BL(i,1) = mean(nonzeros(baseline(:,10,i)));
% 	end
% 	
% 	%{
% 		for i = 1:data_count
% 			SE180BL(i,1) = std(baseline(:,1,i))./sqrt(length(baseline(:,1,i)))./abs(mean180BL(i,1)).*100;
% 			SE179BL(i,1) = std(baseline(:,2,i))./sqrt(length(baseline(:,2,i)))./abs(mean179BL(i,1)).*100;
% 			SE178BL(i,1) = std(baseline(:,3,i))./sqrt(length(baseline(:,3,i)))./abs(mean178BL(i,1)).*100;
% 			SE177BL(i,1) = std(baseline(:,4,i))./sqrt(length(baseline(:,4,i)))./abs(mean177BL(i,1)).*100;
% 			SE176BL(i,1) = std(baseline(:,5,i))./sqrt(length(baseline(:,5,i)))./abs(mean176BL(i,1)).*100;
% 			SE175BL(i,1) = std(baseline(:,6,i))./sqrt(length(baseline(:,6,i)))./abs(mean175BL(i,1)).*100;
% 			SE174BL(i,1) = std(baseline(:,7,i))./sqrt(length(baseline(:,7,i)))./abs(mean174BL(i,1)).*100;
% 			SE173BL(i,1) = std(baseline(:,8,i))./sqrt(length(baseline(:,8,i)))./abs(mean173BL(i,1)).*100;
% 			SE172BL(i,1) = std(baseline(:,9,i))./sqrt(length(baseline(:,9,i)))./abs(mean172BL(i,1)).*100;
% 			SE171BL(i,1) = std(baseline(:,10,i))./sqrt(length(baseline(:,10,i)))./abs(mean171BL(i,1)).*100;
% 		end
% 	%}
% 	
% 	for i = 1:data_count
% 		BLS_180(:,i) = integration(:,1,i) - mean180BL(i,1);
% 		BLS_179(:,i) = integration(:,2,i) - mean179BL(i,1);
% 		BLS_178(:,i) = integration(:,3,i) - mean178BL(i,1);
% 		BLS_177(:,i) = integration(:,4,i) - mean177BL(i,1);
% 		BLS_176(:,i) = integration(:,5,i) - mean176BL(i,1);
% 		BLS_175(:,i) = integration(:,6,i) - mean175BL(i,1);
% 		BLS_174(:,i) = integration(:,7,i) - mean174BL(i,1);
% 		BLS_173(:,i) = integration(:,8,i) - mean173BL(i,1);
% 		BLS_172(:,i) = integration(:,9,i) - mean172BL(i,1);
% 		BLS_171(:,i) = integration(:,10,i) - mean171BL(i,1);
% 	end
% 	
end


















figure
hold on
plot(values_tmp(:,12),values_tmp(:,1))
scatter(t0_180,0.1*ones(length(t0_180)),'filled')
xlabel('Time (s)')
ylabel('180Hf')
dim = [.2 .5 .3 .3];
str = strcat('sample n = ', {' '}, mat2str(data_count), {'   '}, 't zeros = ',{' '}, mat2str(length(t0_180)));
annotation('textbox',dim,'String',str,'FitBoxToText','on');
if data_count == length(t0_180)
	labelpoints (t0_180,zeros(length(t0_180),1), sample);
else
	labelpoints (t0_180,zeros(length(t0_180),1), [1:1:length(t0_180)]);
end

figure
hold on
plot(values_tmp(:,11),values_tmp(:,1))
scatter(t0_idx,0.1*ones(length(t0_idx)),'filled')
xlabel('Index')
ylabel('180Hf')
dim = [.2 .5 .3 .3];
str = strcat('sample n = ', {' '}, mat2str(data_count), {'   '}, 't zeros = ',{' '}, mat2str(length(t0_idx)));
annotation('textbox',dim,'String',str,'FitBoxToText','on');
if data_count == length(t0_idx)
	labelpoints (t0_idx,zeros(length(t0_idx),1), sample);
else
	labelpoints (t0_idx,zeros(length(t0_idx),1), [1:1:length(t0_idx)]);
end







