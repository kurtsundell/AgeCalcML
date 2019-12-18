function varargout = AgeCalcML_1_4(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@AgeCalcML_1_4_OpeningFcn,'gui_OutputFcn',...
	@AgeCalcML_1_4_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function AgeCalcML_1_4_OpeningFcn(hObject, eventdata, H, varargin)
imshow('splashs_eQh_icon.ico', 'Parent', H.axes1);
H.output = hObject;
guidata(hObject, H);

function varargout = AgeCalcML_1_4_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;

function nu_upb_Callback(hObject, eventdata, H)
AgeCalcML_Nu_1_6

function nu_upb_tra_Callback(hObject, eventdata, H)
AgeCalcML_Nu_TRA_1_23

function nu_hf_Callback(hObject, eventdata, H)
AgeCalcML_Nu_Hf_1_5

function e2_upb_Callback(hObject, eventdata, H)
AgeCalcML_E2_1_15

function e2_tree_Callback(hObject, eventdata, H)
AgeCalcML_E2_TREE_1_2

function concordia_Callback(hObject, eventdata, H)
ConcordiaPlotter_1_0

function stackedconconcordias_Callback(hObject, eventdata, H)
StackedConcordiaPlotter_1_0

function agedistribution_Callback(hObject, eventdata, H)
DistributionPlotter_1_0

function stackedagedistributions_Callback(hObject, eventdata, H)
StackedDistributionPlotter_1_0

function weightedmean_Callback(hObject, eventdata, H)
WeightedMeanPlotter_1_0

function hafniumplotter_Callback(hObject, eventdata, H)
HafniumPlotter_1_7

function scanlistnu_Callback(hObject, eventdata, H)
Scanlist_Nu_1_1

function scanliste2_Callback(hObject, eventdata, H)
Scanlist_E2_1_0

function zirconspotfinder_Callback(hObject, eventdata, H)
ZirconSpotFinder_1_4

function geochron_Callback(hObject, eventdata, H)
folder_name = uigetdir; %prompt browser and select folder
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

[numbers text, metadata] = xlsread(char(fullpathname_metadata));

h = waitbar(0,'Appending metadata. Please wait...');

for j = 1:length(metadata(:,1))-1
	
	waitbar(j/length(metadata(:,1)), h, 'Appending metadata. Please wait...');
	
	name = char(metadata(j,1));
	tmp3 = strfind(filenames(:,1), name);

	for k = 1:length(filenames)
		if isempty(tmp3(~cellfun('isempty',tmp3(k,1)))) == 0
			sample_dir = filenames(k,1);
			tmp4 = strfind(metadata(:,1), sample_dir);
			
			for i = 1:length(metadata(:,1))
				if isempty(tmp4(~cellfun('isempty',tmp4(i,1)))) == 0
					answer{1,1} = char(sample_dir);
					answer{2,1} = char(metadata{i,2});
					answer{3,1} = char(metadata{i,3});
					answer{4,1} = char(metadata{i,7});
					answer{5,1} = metadata{i,5};
					answer{6,1} = metadata{i,6};
					answer{7,1} = char(metadata{i,9});
					answer{8,1} = char(metadata{i,10});
					answer{9,1} = char('N/A');
				end
			end
			
			if ispc == 1
				fullpathname_sample{i,1} = char(strcat(folder_name, '\', sample_dir));
			end
			if ismac == 1
				fullpathname_sample{i,1} = char(strcat(folder_name, '/', sample_dir));
			end
			fullpathname_sample = fullpathname_sample(~cellfun('isempty',fullpathname_sample));
			
			sample_files = dir([char(fullpathname_sample)]);
	
			for i = 1:size(sample_files,1)
				sample_filenames{i,1} = sample_files(i).name;
			end

			for i = 1:size(sample_filenames,1)
				if strcmp(sample_filenames(i,1),'.') == 1
					sample_filenames{i,1} = [];
				elseif strcmp(sample_filenames(i,1),'..') == 1
					sample_filenames{i,1} = [];
				end
			end
	
			sample_filenames = sample_filenames(~cellfun('isempty',sample_filenames));
	
			tmp5 = strfind(sample_filenames, char('datatable'));
	
			for i = 1:length(sample_filenames)
				if isempty(tmp5(~cellfun('isempty',tmp5(i,1)))) == 0
					if ispc == 1
						fullpathname_sampledata{i,1} = char(strcat(fullpathname_sample, '\', sample_filenames{i,1}));
					end
					if ismac == 1
						fullpathname_sampledata{i,1} = char(strcat(fullpathname_sample, '/', sample_filenames{i,1}));
					end
					fullpathname_sampledata = fullpathname_sampledata(~cellfun('isempty',fullpathname_sampledata));
				end
			end
	
			[numbers text, sampledata] = xlsread(char(fullpathname_sampledata));
			
			sampledata(1:4,2) = answer(1:4,1);
			sampledata(5,2) = [{'Zircon'}];
			sampledata(6,2) = [{'U-Pb'}];
			sampledata(7:8,2) = answer(5:6,1);
			sampledata(12,2) = answer(7,1);
			sampledata(14:15,2) = answer(8:9,1);
			
			if ispc == 1
				writetable(table(sampledata),char(strcat(folder_name, '\', sample_dir, '_Geochron_Upload')), 'FileType', 'spreadsheet', 'WriteVariableNames', 0);
			end
			if ismac == 1
				writetable(table(sampledata),char(strcat(folder_name, '/', sample_dir, '_Geochron_Upload')), 'FileType', 'spreadsheet', 'WriteVariableNames', 0);
			end
			
		end
	end
			
	clear answer sampledata tmp2 tmp3 tmp4 tmp5 fullpathname_sample fullpathname_sampledata sample_files sample_filenames

end

close(h)

if ispc == 1
	winopen(folder_name)
end
if ismac == 1
	macopen(folder_name)
end
