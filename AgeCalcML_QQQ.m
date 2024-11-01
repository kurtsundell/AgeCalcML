%% AGECALCML_QQQ MATLAB code for AgeCalcML_QQQ.fig %%
function varargout = AgeCalcML_QQQ(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn', @AgeCalcML_QQQ_OpeningFcn,'gui_OutputFcn',@AgeCalcML_QQQ_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
	gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
	[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
	gui_mainfcn(gui_State, varargin{:});
end
function AgeCalcML_QQQ_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
%set(H.WM_STD2,'Visible','off')
guidata(hObject, H);
function varargout = AgeCalcML_QQQ_OutputFcn(hObject, eventdata, H)
%imshow('splashs_eQh_icon.ico', 'Parent', H.axes50);
reduced = 0;
set(H.reject_no,'Value',1)
H.reduced = reduced;
guidata(hObject,H);
varargout{1} = H.output;

function browser_Callback(hObject, eventdata, H)

cla(H.axes_distribution,'reset');
set(H.status,'String','');
cla reset
cla(H.axes_session_fractionation,'reset');
cla(H.axes_session,'reset');
cla(H.axes_current_intensities,'reset');
cla(H.axes_current_concordia,'reset');
cla(H.axes_distribution,'reset');
set(H.standards_rejected,'String','0');
set(H.listbox1,'String','');
set(H.SE6867,'String','');

cla reset

set(H.wmSecondary, 'Value', 0)

set(H.ptype_Primary_STDs, 'Value', 1)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)


set(H.chk_Hg202,'Value', 1)
set(H.chk_Pb204,'Value', 1)
set(H.chk_Pb206,'Value', 1)
set(H.chk_Pb207,'Value', 1)
set(H.chk_Pb208,'Value', 1)
set(H.chk_Th232,'Value', 1)
set(H.chk_U238,'Value', 1)
set(H.chk_Pb206_U238,'Value', 0);
set(H.chk_Pb206_Pb207,'Value', 0);
set(H.chk_Pb208_Th232,'Value', 0);


folder_name = uigetdir; %prompt browser and select folder
set(H.filepath, 'String', folder_name); %show path name
H.folder_name = folder_name;
guidata(hObject,H);
function method_Callback(hObject, eventdata, H)
function downhole_Callback(hObject, eventdata, H)
function reduce_data_Callback(hObject, eventdata, H)
cla(H.axes_distribution,'reset');
set(H.status,'String','');
cla reset
cla(H.axes_session_fractionation,'reset');
cla(H.axes_session,'reset');
cla(H.axes_current_intensities,'reset');
cla(H.axes_current_concordia,'reset');
cla(H.axes_distribution,'reset');
set(H.standards_rejected,'String','0');
set(H.listbox1,'String','');
set(H.SE6867,'String','');
cla reset

% set(H.wmSecondary, 'Value', 0)
% set(H.ptype_Primary_STDs, 'Value', 1)
% set(H.ptype_Secondary_STDs, 'Value', 0)
% set(H.ptype_Unknowns, 'Value', 0)
% set(H.ptype_Unknowns_acc, 'Value', 0)
% set(H.ptype_Unknowns_rej, 'Value', 0)
% set(H.age_uconc, 'Value', 0)
% set(H.age_raddos, 'Value', 0)
% set(H.age_uth, 'Value', 0)
% set(H.age_concodance, 'Value', 0)

set(H.chk_Hg202,'Value', 1)
set(H.chk_Pb204,'Value', 1)
set(H.chk_Pb206,'Value', 1)
set(H.chk_Pb207,'Value', 1)
set(H.chk_Pb208,'Value', 1)
set(H.chk_Th232,'Value', 1)
set(H.chk_U238,'Value', 1)
set(H.chk_Pb206_U238,'Value', 0);
set(H.chk_Pb206_Pb207,'Value', 0);
set(H.chk_Pb208_Th232,'Value', 0);

waitnum = 10;
h = waitbar(1/waitnum,'Calculating. Please wait...');

folder_name = H.folder_name;
folders=dir([folder_name]); %map out the directory to that folder

for i = 1:size(folders,1)
	foldernames{i,1} = folders(i).name;
end

for i = 1:length(folders(:,1))
	if contains(foldernames(i,1),'SMPL.d') == 0
		foldernames{i,1} = [];
	end
end

foldernames(all(cellfun('isempty',foldernames),2),:) = [];

for i = 1:length(foldernames)
	fullpathname_data = char(strcat(folder_name, '/', foldernames{i,1}, '/', foldernames{i,1}(1:7), '.csv'));
	values_all(:,:,i) = readmatrix(fullpathname_data);
end

fullpathname_samples = char(strcat(folder_name, '/', 'BatchLog.csv'));
warning('off')
T = readtable(fullpathname_samples);
for i = 1:length(T.SampleName)
	Names{i,1} = T.SampleName{i,1};
end

data_count = length(Names);
N = data_count;



%Integration windows

ints = str2num(get(H.intstart,'String'));
inte = str2num(get(H.intend,'String'));

base1s = str2num(get(H.base1start,'String'));
base1e = str2num(get(H.base1end,'String'));

base2s = str2num(get(H.base2start,'String'));
base2e = str2num(get(H.base2end,'String'));


for i = 1:data_count
	baseline(1:(base1e-base1s+1),1:8,i) = values_all(base1s:base1e,2:9,i);
	baseline((base1e-base1s+2):(base1e-base1s+2)+(base2e-base2s),1:8,i) = values_all(base2s:base2e,2:9,i);
	%baseline(3:7,1:8,i) = values_all(24:28,2:9,i);
	integration(1:(inte-ints+1),1:8,i) = values_all(ints:inte,2:9,i);
end

%original
% for i = 1:data_count
% 	baseline(1:2,1:8,i) = values_all(1:2,2:9,i);
% 	baseline(3:7,1:8,i) = values_all(24:28,2:9,i);
% 	integration(1:16,1:8,i) = values_all(5:20,2:9,i);
% end





%Bulk BL subtract
BL202 = reshape(baseline(:,1,:),numel(baseline(:,1,:)),1);
BL204 = reshape(baseline(:,2,:),numel(baseline(:,2,:)),1);
BL206 = reshape(baseline(:,3,:),numel(baseline(:,3,:)),1);
BL207 = reshape(baseline(:,4,:),numel(baseline(:,4,:)),1);
BL208 = reshape(baseline(:,5,:),numel(baseline(:,5,:)),1);
BL232 = reshape(baseline(:,6,:),numel(baseline(:,6,:)),1);
BL235 = reshape(baseline(:,7,:),numel(baseline(:,7,:)),1);
BL238 = reshape(baseline(:,8,:),numel(baseline(:,8,:)),1);

mean202BL = mean(BL202);
mean204BL = mean(BL204);
mean206BL = mean(BL206);
mean207BL = mean(BL207);
mean208BL = mean(BL208);
mean232BL = mean(BL232);
mean235BL = mean(BL235);
mean238BL = mean(BL238);

BL202(BL202 > mean202BL + 2*std(BL202) | BL202 < mean202BL - 2*std(BL202) ) = [];
BL204(BL204 > mean204BL + 2*std(BL204) | BL204 < mean204BL - 2*std(BL204) ) = [];
BL206(BL206 > mean206BL + 2*std(BL206) | BL206 < mean206BL - 2*std(BL206) ) = [];
BL207(BL207 > mean207BL + 2*std(BL207) | BL207 < mean207BL - 2*std(BL207) ) = [];
BL208(BL208 > mean208BL + 2*std(BL208) | BL208 < mean208BL - 2*std(BL208) ) = [];
BL232(BL232 > mean232BL + 2*std(BL232) | BL232 < mean232BL - 2*std(BL232) ) = [];
BL235(BL235 > mean235BL + 2*std(BL235) | BL235 < mean235BL - 2*std(BL235) ) = [];
BL238(BL238 > mean238BL + 2*std(BL238) | BL238 < mean238BL - 2*std(BL238) ) = [];

std202BL = std(BL202);
std204BL = std(BL204);
std206BL = std(BL206);
std207BL = std(BL207);
std208BL = std(BL208);
std232BL = std(BL232);
std235BL = std(BL235);
std238BL = std(BL238);

mean202BL = mean(BL202);
mean204BL = mean(BL204);
mean206BL = mean(BL206);
mean207BL = mean(BL207);
mean208BL = mean(BL208);
mean232BL = mean(BL232);
mean235BL = mean(BL235);
mean238BL = mean(BL238);

SE202BL = std(BL202)./sqrt(length(BL202))./abs(mean202BL).*100;
SE204BL = std(BL204)./sqrt(length(BL204))./abs(mean204BL).*100;
SE206BL = std(BL206)./sqrt(length(BL206))./abs(mean206BL).*100;
SE207BL = std(BL207)./sqrt(length(BL207))./abs(mean207BL).*100;
SE208BL = std(BL208)./sqrt(length(BL208))./abs(mean208BL).*100;
SE232BL = std(BL232)./sqrt(length(BL232))./abs(mean232BL).*100;
SE235BL = std(BL235)./sqrt(length(BL235))./abs(mean235BL).*100;
SE238BL = std(BL238)./sqrt(length(BL238))./abs(mean238BL).*100;

for i = 1:data_count
	BLS_202(:,i) = integration(:,1,i) - mean202BL;
	BLS_204(:,i) = integration(:,2,i) - mean204BL - (BLS_202(:,i)./4.34);
	BLS_206(:,i) = integration(:,3,i) - mean206BL;
	BLS_207(:,i) = integration(:,4,i) - mean207BL;
	BLS_208(:,i) = integration(:,5,i) - mean208BL;
	BLS_232(:,i) = integration(:,6,i) - mean232BL;
	BLS_235(:,i) = integration(:,7,i) - mean235BL;
	if get(H.use235,'Value') == 0
		BLS_238(:,i) = integration(:,8,i) - mean238BL;
	end
	if get(H.use235,'Value') == 1
		BLS_238(:,i) = (integration(:,7,i) - mean235BL).*137.818;
	end
end


%{

waitbar(4/waitnum,h,'Calculating. Please wait...');

for i = 1:data_count
	mean238BL(i,1) = mean(baseline(:,8,i));
	mean232BL(i,1) = mean(baseline(:,6,i));
	mean208BL(i,1) = mean(baseline(:,5,i));
	mean207BL(i,1) = mean(baseline(:,4,i));
	mean206BL(i,1) = mean(baseline(:,3,i));
	mean204BL(i,1) = mean(baseline(:,2,i));
	mean202BL(i,1) = mean(baseline(:,1,i));
end

for i = 1:data_count
	SE238BL(i,1) = std(baseline(:,8,i))./sqrt(length(baseline(:,8,i)))./abs(mean238BL(i,1)).*100;
	SE232BL(i,1) = std(baseline(:,6,i))./sqrt(length(baseline(:,6,i)))./abs(mean232BL(i,1)).*100;
	SE208BL(i,1) = std(baseline(:,5,i))./sqrt(length(baseline(:,5,i)))./abs(mean208BL(i,1)).*100;
	SE207BL(i,1) = std(baseline(:,4,i))./sqrt(length(baseline(:,4,i)))./abs(mean207BL(i,1)).*100;
	SE206BL(i,1) = std(baseline(:,3,i))./sqrt(length(baseline(:,3,i)))./abs(mean206BL(i,1)).*100;
	SE204BL(i,1) = std(baseline(:,2,i))./sqrt(length(baseline(:,2,i)))./abs(mean204BL(i,1)).*100;
	SE202BL(i,1) = std(baseline(:,1,i))./sqrt(length(baseline(:,1,i)))./abs(mean202BL(i,1)).*100;
end

for i = 1:data_count
	BLS_238(:,i) = integration(:,8,i) - mean238BL(i,1);
	BLS_232(:,i) = integration(:,6,i) - mean232BL(i,1);
	BLS_208(:,i) = integration(:,5,i) - mean208BL(i,1);
	BLS_207(:,i) = integration(:,4,i) - mean207BL(i,1);
	BLS_206(:,i) = integration(:,3,i) - mean206BL(i,1);
	BLS_202(:,i) = integration(:,1,i) - mean202BL(i,1);
	BLS_204(:,i) = integration(:,2,i) - mean204BL(i,1) - (BLS_202(:,i)./4.34);
end

%}

sample = Names;

















	





waitbar(5/waitnum, h, 'Parsing the data. Please wait...');

n = length(integration(:,1,1));

if get(H.primary, 'Value') == 1
	STD1 = 'FC';
	STD1age = 1099;
	STD1_68 = 0.18588;
	STD1_67  = 13.132;
	STD1_75 = 1.9508
	STD1_82  = 0.05588;
	STD1_64c = 16.882;
	STD1_67c = 15.463;
	STD1_68c = 36.533;
	STD1_Uppm = 457;
	STD1_Thppm = 271;
end

if get(H.primary, 'Value') == 2
	STD1 = 'SL';
	STD1age = 564;
	STD1_68 = 0.09145;
	STD1_67 = 16.973;
	STD1_75 = 0.7426;
	STD1_82 = 0.0283;
	STD1_64c = 17.827;
	STD1_67c = 15.549;
	STD1_68c = 37.576;
	STD1_Uppm = 518;
	STD1_Thppm = 118;
end

if get(H.primary, 'Value') == 3
	STD1 = 'R33';
	STD1age = 419;
	STD1_68 = 0.0671;
	STD1_67 = 0.05522;
	STD1_75 = 0.511;
	STD1_82 = 0.0557219220349821; % NOT CORRECT! THIS IS THE RATIO FOR PLESOVICE
	STD1_Pb206_U238_known_err = 1;
	STD1_Pb207_Pb206_known_err = 1;
	STD1_Pb207_U235_known_err = 1;
	STD1_Pb208_Th232_known_err = 1; % NOT CORRECT! THIS IS THE UNC FOR PLESOVICE
	STD1_Uppm = 518; % NOT CORRECT, THIS IS FC
	STD1_Thppm = 118; % NOT CORRECT, THIS IS FC
end





if get(H.secondary, 'Value') == 1
	STD2 = 'R33';
	STD2age = 419;
	STD2_68 = 0.0671;
	STD2_67 = 0.05522;
	STD2_75 = 0.511;
	STD2_82 = 0.0557219220349821; % NOT CORRECT! THIS IS THE RATIO FOR PLESOVICE
	STD2_Pb206_U238_known_err = 1;
	STD2_Pb207_Pb206_known_err = 1;
	STD2_Pb207_U235_known_err = 1;
	STD2_Pb208_Th232_known_err = 1; % NOT CORRECT! THIS IS THE UNC FOR PLESOVICE
end

if get(H.secondary, 'Value') == 2
	STD2 = 'SL';
	STD2age = 564;
	STD2_68 = 0.09145;
	STD2_67  = 16.973;
	STD2_75 = 0.7426;
	STD2_82  = 0.0283;
	STD2_64c = 17.827;
	STD2_67c = 15.549;
	STD2_68c = 37.576;
	STD2_Uppm = 518;
	STD2_Thppm = 118;
end

if get(H.secondary, 'Value') == 3
	STD2 = 'FC';
	STD2age = 1099;
	STD2_68 = 0.18588;
	STD2_67  = 13.132;
	STD2_75 = 1.9508;
	STD2_82  = 0.05588;
	STD2_64c = 16.882;
	STD2_67c = 15.463;
	STD2_68c = 36.533;
	STD2_Uppm = 457;
	STD2_Thppm = 271;
end






if get(H.tertiary, 'Value') == 1
	STD3 = 'SL';
	STD3age = 564;
	STD3_68 = 0.09145;
	STD3_67  = 16.973;
	STD3_75 = 0.7426;
	STD3_82  = 0.0283;
	STD3_64c = 17.827;
	STD3_67c = 15.549;
	STD3_68c = 37.576;
	STD3_Uppm = 518;
	STD3_Thppm = 118;
end

if get(H.tertiary, 'Value') == 2
	STD3 = 'FC';
	STD3age = 1099;
	STD3_68 = 0.18588;
	STD3_67  = 13.132;
	STD3_75 = 1.9508;
	STD3_82  = 0.05588;
	STD3_64c = 16.882;
	STD3_67c = 15.463;
	STD3_68c = 36.533;
	STD3_Uppm = 457;
	STD3_Thppm = 271;
end

if get(H.tertiary, 'Value') == 3
	STD3 = 'R33';
	STD3age = 419;
	STD3_68 = 0.0671;
	STD3_67 = 0.05522;
	STD3_75 = 0.511;
	STD3_82 = 0.0557219220349821; % NOT CORRECT! THIS IS THE RATIO FOR PLESOVICE
	STD3_Pb206_U238_known_err = 1;
	STD3_Pb207_Pb206_known_err = 1;
	STD3_Pb207_U235_known_err = 1;
	STD3_Pb208_Th232_known_err = 1; % NOT CORRECT! THIS IS THE UNC FOR PLESOVICE
end








STD1_idx = strfind(sample, STD1);
STD2_idx = strfind(sample, STD2);
STD3_idx = strfind(sample, STD3);

STD1_idx = abs(cellfun(@isempty,STD1_idx)-1);
STD2_idx = abs(cellfun(@isempty,STD2_idx)-1);
STD3_idx = abs(cellfun(@isempty,STD3_idx)-1);

sample_idx = abs((STD1_idx + STD2_idx + STD3_idx) - 1);

waitbar(6/waitnum,h,'Calculating. Please wait...');

STD1_rename = {'std'};
bestage_cutoff = str2num(get(H.bestage_cutoff,'String'));
filter_cutoff = str2num(get(H.filter_cutoff,'String'));
filter_err68 = str2num(get(H.filter_err68,'String'));
filter_err67 = str2num(get(H.filter_err67,'String'));
filter_disc = str2num(get(H.filter_disc,'String'));
filter_disc_rev = str2num(get(H.filter_disc_rev,'String'));
filter_204 = str2num(get(H.filter_204,'String'));
factor64 = str2num(get(H.factor64,'String'));

for i = 1:data_count
	if STD1_idx(i,1) == 1
		stds(i,1) = sample(i,1);
		sample(i,1) = STD1_rename;
	end
end

serial = sample;

for i = 1:data_count
	CPS_202(1,i) = abs(mean(nonzeros(BLS_202(:,i))));
	CPS_204(1,i) = abs(mean(nonzeros(BLS_204(:,i))));
	CPS_206(1,i) = mean(nonzeros(BLS_206(:,i)));
	CPS_207(1,i) = mean(nonzeros(BLS_207(:,i)));
	CPS_208(1,i) = mean(nonzeros(BLS_208(:,i)));
	CPS_232(1,i) = mean(nonzeros(BLS_232(:,i)));
	CPS_238(1,i) = mean(nonzeros(BLS_238(:,i)));
end


for i = 1:data_count
	for j = 1:length(integration(:,1))
		BLS_68_tmp(j,1:2,i) = [BLS_206(j,i),BLS_238(j,i)];
		if BLS_206(j,i) > 0 && BLS_207(j,i) > 0

			BLS_67_tmp(j,1:2,i) = [BLS_206(j,i),BLS_207(j,i)];
		else
			BLS_67_tmp(j,1:2,i) = [0,0];
		end
		if 1./(BLS_206(j,i)./BLS_207(j,i)) > 0.55 || 1./(BLS_206(j,i)./BLS_207(j,i)) < 0.04604504
			BLS_67_tmp(j,1:2,i) = [0,0];
		end
		BLS_64_tmp(j,1:2,i) = [abs(BLS_206(j,i)),abs(BLS_204(j,i))];
		BLS_82_tmp(j,1:2,i) = [abs(BLS_208(j,i)),abs(BLS_232(j,i))];
		BLS_84_tmp(j,1:2,i) = [abs(BLS_208(j,i)),abs(BLS_204(j,i))];
	end
end







%238U downhole corr
if get(H.downhole,'Value') == 1 % --> Downhole Corr.
	for i = 1:data_count
		tmp68 = BLS_68_tmp(:,1,i)./BLS_68_tmp(:,2,i);
		tbl = table((1:1:length(BLS_68_tmp(:,1,1)))',tmp68);
		mdl = fitlm(tbl);
		BLS_68_corr(i,1) = mdl.Coefficients.Estimate(1,1);
		BLS_68_err_tmp1(i,1) = mdl.Coefficients.SE(1,1);
		BLS_68_err(i,1) = (BLS_68_err_tmp1(i,1)/sqrt(length(tmp68))) / BLS_68_corr(i,1) .* 100; % 1 sigma SE in %
		BLS_68_slope(i,1) = mdl.Coefficients.Estimate(2,1);
		clear tmp68
	end
end








%Total Counts
if get(H.totalcounts, 'Value') == 1
	if get(H.downhole,'Value') == 0
		for i = 1:data_count
			BLS_68_corr(i,1) = sum(BLS_68_tmp(1:end,1,i))/sum(BLS_68_tmp(1:end,2,i));
			for j = 1:length(BLS_68_tmp(:,1,i))
				BLS_68_err_tmp(j,1) = BLS_68_tmp(j,1,i)./BLS_68_tmp(j,2,i);
			end
			BLS_68_err_tmp = BLS_68_err_tmp(~isnan(BLS_68_err_tmp));
			BLS_68_err(i,1) = (std(BLS_68_err_tmp)/sqrt(length(BLS_68_err_tmp))) / BLS_68_corr(i,1) .* 100; % 1 sigma SE in %
			clear BLS_68_err_tmp
		end
		for i = 1:data_count
			BLS_68_slope(i,1) = 0;
		end
	end
	
	for i = 1:data_count
		if sum(BLS_67_tmp(:,2,i)) > 0
			BLS_67_corr(i,1) = sum(BLS_67_tmp(:,1,i))/sum(BLS_67_tmp(:,2,i));
		else
			BLS_67_corr(i,1) = 1000;
		end
		for j = 1:length(BLS_67_tmp(:,1,i))
			BLS_67_err_tmp(j,1) = BLS_67_tmp(j,1,i)./BLS_67_tmp(j,2,i);
		end
		BLS_67_err_tmp = BLS_67_err_tmp(~isnan(BLS_67_err_tmp));
		if sum(BLS_67_tmp(:,2,i)) > 0
			BLS_67_err(i,1) = std(BLS_67_err_tmp)/sqrt(length(BLS_67_err_tmp)) / BLS_67_corr(i,1) .* 100; % 1 sigma SE in %
		else
			BLS_67_err(i,1) = 1000;
		end
		clear BLS_67_err_tmp
	end
	
	for i = 1:data_count
		BLS_64_corr(i,1) = abs(0.85.*(sum(BLS_64_tmp(:,1,i))/sum(BLS_64_tmp(:,2,i))));
		for j = 1:length(BLS_64_tmp(:,1,i))
			BLS_64_err_tmp(j,1) = BLS_64_tmp(j,1,i)./BLS_64_tmp(j,2,i);
		end
		BLS_64_err_tmp = BLS_64_err_tmp(~isnan(BLS_64_err_tmp));
		BLS_64_err(i,1)  = std(BLS_64_err_tmp)/sqrt(length(BLS_64_err_tmp)) / BLS_64_corr(i,1) .* 100; % 1 sigma SE in %
		clear BLS_64_err_tmp
	end
	
	for i = 1:data_count
		BLS_82_corr(i,1) = sum(BLS_82_tmp(:,1,i))/sum(BLS_82_tmp(:,2,i));
		for j = 1:length(BLS_67_tmp(:,1,i))
			BLS_82_err_tmp(j,1) = BLS_82_tmp(j,1,i)./BLS_82_tmp(j,2,i);
		end
		BLS_82_err_tmp = BLS_82_err_tmp(~isnan(BLS_82_err_tmp));
		BLS_82_err(i,1)  = std(BLS_82_err_tmp)/sqrt(length(BLS_82_err_tmp)) / BLS_82_corr(i,1) .* 100; % 1 sigma SE in %
		clear BLS_82_err_tmp
	end
	
	for i = 1:data_count
		BLS_84_corr(i,1) = sum(BLS_84_tmp(:,1,i))/sum(BLS_84_tmp(:,2,i));
		for j = 1:length(BLS_84_tmp(:,1,i))
			BLS_84_err_tmp(j,1) = BLS_84_tmp(j,1,i)./BLS_84_tmp(j,2,i);
		end
		BLS_84_err_tmp = BLS_84_err_tmp(~isnan(BLS_84_err_tmp));
		BLS_84_err(i,1)  = std(BLS_84_err_tmp)/sqrt(length(BLS_84_err_tmp)) / BLS_84_corr(i,1) .* 100; % 1 sigma SE in %
		clear BLS_84_err_tmp
	end
	
end


%Mean ratios
if get(H.meanratios, 'Value') == 1
	if get(H.downhole,'Value') == 0
		for i = 1:data_count
			BLS_68_ratios(:,i) = BLS_68_tmp(:,1,i)./BLS_68_tmp(:,2,i);
		end	
		for i = 1:length(BLS_68_ratios(1,:))
			BLS_Ratios_tmp = BLS_68_ratios(:,i);
			for j = 1:length(BLS_Ratios_tmp)
				if BLS_Ratios_tmp(j,1) > mean(BLS_Ratios_tmp) + 2*std(BLS_Ratios_tmp) || ...
						BLS_Ratios_tmp(j,1) < mean(BLS_Ratios_tmp) - 2*std(BLS_Ratios_tmp)
					BLS_Ratios_tmp(j,1) = 0;
				end
			end
			BLS_Ratios_tmp(BLS_Ratios_tmp == 0) = [];
			BLS_68_corr(i,1) = mean(BLS_Ratios_tmp);
			BLS_68_err(i,1) = (std(BLS_Ratios_tmp)/sqrt(length(BLS_Ratios_tmp))) / BLS_68_corr(i,1) .* 100; % 1 sigma SE in %
			%n = length(BLS_Ratios_tmp)
			clear BLS_Ratios_tmp
		end
		for i = 1:data_count
			BLS_68_slope(i,1) = 0;
		end
	end
	
	for i = 1:data_count
		BLS_67_ratios(:,i) = BLS_67_tmp(:,1,i)./BLS_67_tmp(:,2,i);
		BLS_Ratios_tmp = nonzeros(BLS_67_ratios(:,i));
		BLS_Ratios_tmp(isnan(BLS_Ratios_tmp(:,1)),:) = [];
			for j = 1:length(BLS_Ratios_tmp)
				if BLS_Ratios_tmp(j,1) > mean(BLS_Ratios_tmp) + 2*std(BLS_Ratios_tmp) || ...
						BLS_Ratios_tmp(j,1) < mean(BLS_Ratios_tmp) - 2*std(BLS_Ratios_tmp)
					BLS_Ratios_tmp(j,1) = 0;
				end
			end
		BLS_Ratios_tmp(BLS_Ratios_tmp == 0) = [];
		BLS_67_corr(i,1) = mean(BLS_Ratios_tmp);
		BLS_67_err(i,1) = (std(BLS_Ratios_tmp)/sqrt(length(BLS_Ratios_tmp))) / BLS_67_corr(i,1) .* 100; % 1 sigma SE in %
		n = length(BLS_Ratios_tmp)
		clear BLS_Ratios_tmp
	end
	
	for i = 1:data_count
		BLS_64_corr(i,1) = abs(0.85.*(sum(BLS_64_tmp(:,1,i))/sum(BLS_64_tmp(:,2,i))));
		for j = 1:length(BLS_64_tmp(:,1,i))
			BLS_64_err_tmp(j,1) = BLS_64_tmp(j,1,i)./BLS_64_tmp(j,2,i);
		end
		BLS_64_err_tmp = BLS_64_err_tmp(~isnan(BLS_64_err_tmp));
		BLS_64_err(i,1)  = std(BLS_64_err_tmp)/sqrt(length(BLS_64_err_tmp)) / BLS_64_corr(i,1) .* 100; % 1 sigma SE in %
		clear BLS_64_err_tmp
	end
	
	for i = 1:data_count
		BLS_82_corr(i,1) = sum(BLS_82_tmp(:,1,i))/sum(BLS_82_tmp(:,2,i));
		for j = 1:length(BLS_67_tmp(:,1,i))
			BLS_82_err_tmp(j,1) = BLS_82_tmp(j,1,i)./BLS_82_tmp(j,2,i);
		end
		BLS_82_err_tmp = BLS_82_err_tmp(~isnan(BLS_82_err_tmp));
		BLS_82_err(i,1)  = std(BLS_82_err_tmp)/sqrt(length(BLS_82_err_tmp)) / BLS_82_corr(i,1) .* 100; % 1 sigma SE in %
		clear BLS_82_err_tmp
	end
	
	for i = 1:data_count
		BLS_84_corr(i,1) = sum(BLS_84_tmp(:,1,i))/sum(BLS_84_tmp(:,2,i));
		for j = 1:length(BLS_84_tmp(:,1,i))
			BLS_84_err_tmp(j,1) = BLS_84_tmp(j,1,i)./BLS_84_tmp(j,2,i);
		end
		BLS_84_err_tmp = BLS_84_err_tmp(~isnan(BLS_84_err_tmp));
		BLS_84_err(i,1)  = std(BLS_84_err_tmp)/sqrt(length(BLS_84_err_tmp)) / BLS_84_corr(i,1) .* 100; % 1 sigma SE in %
		clear BLS_84_err_tmp
	end
end


%Log ratios
%Mean ratios
if get(H.logratios, 'Value') == 1
	if get(H.downhole,'Value') == 0
		for i = 1:data_count
			BLS_68_ratios(:,i) = log( BLS_68_tmp(:,1,i)./BLS_68_tmp(:,2,i) );
		end	
		for i = 1:length(BLS_68_ratios(1,:))
			BLS_Ratios_tmp = BLS_68_ratios(:,i);
			for j = 1:length(BLS_Ratios_tmp)
				if BLS_Ratios_tmp(j,1) > mean(BLS_Ratios_tmp) + 2*std(BLS_Ratios_tmp) || ...
						BLS_Ratios_tmp(j,1) < mean(BLS_Ratios_tmp) - 2*std(BLS_Ratios_tmp)
					BLS_Ratios_tmp(j,1) = 0;
				end
			end
			BLS_Ratios_tmp(BLS_Ratios_tmp == 0) = [];
			BLS_68_corr_tmp = mean(BLS_Ratios_tmp);
			BLS_68_corr(i,1) = exp(BLS_68_corr_tmp);
			BLS_Ratios_tmp_exp = exp(BLS_Ratios_tmp);
			BLS_68_err(i,1) = (std(BLS_Ratios_tmp_exp)/sqrt(length(BLS_Ratios_tmp_exp))) / BLS_68_corr(i,1) .* 100; % 1 sigma SE in %
			n = length(BLS_Ratios_tmp)
			clear BLS_Ratios_tmp BLS_68_corr_tmp BLS_Ratios_tmp_exp
		end
		for i = 1:data_count
			BLS_68_slope(i,1) = 0;
		end
	end

	
	for i = 1:data_count
		BLS_67_ratios(:,i) = BLS_67_tmp(:,1,i)./BLS_67_tmp(:,2,i);
		BLS_Ratios_tmp = nonzeros(BLS_67_ratios(:,i));
		BLS_Ratios_tmp(isnan(BLS_Ratios_tmp(:,1)),:) = [];
			for j = 1:length(BLS_Ratios_tmp)
				if BLS_Ratios_tmp(j,1) > mean(BLS_Ratios_tmp) + 2*std(BLS_Ratios_tmp) || ...
						BLS_Ratios_tmp(j,1) < mean(BLS_Ratios_tmp) - 2*std(BLS_Ratios_tmp)
					BLS_Ratios_tmp(j,1) = 0;
				end
			end
		BLS_Ratios_tmp(BLS_Ratios_tmp == 0) = [];
		BLS_67_corr(i,1) = mean(BLS_Ratios_tmp);
		BLS_67_err(i,1) = (std(BLS_Ratios_tmp)/sqrt(length(BLS_Ratios_tmp))) / BLS_67_corr(i,1) .* 100; % 1 sigma SE in %
		n = length(BLS_Ratios_tmp)
		clear BLS_Ratios_tmp
	end
	
	for i = 1:data_count
		BLS_64_corr(i,1) = abs(0.85.*(sum(BLS_64_tmp(:,1,i))/sum(BLS_64_tmp(:,2,i))));
		for j = 1:length(BLS_64_tmp(:,1,i))
			BLS_64_err_tmp(j,1) = BLS_64_tmp(j,1,i)./BLS_64_tmp(j,2,i);
		end
		BLS_64_err_tmp = BLS_64_err_tmp(~isnan(BLS_64_err_tmp));
		BLS_64_err(i,1)  = std(BLS_64_err_tmp)/sqrt(length(BLS_64_err_tmp)) / BLS_64_corr(i,1) .* 100; % 1 sigma SE in %
		clear BLS_64_err_tmp
	end
	
	for i = 1:data_count
		BLS_82_corr(i,1) = sum(BLS_82_tmp(:,1,i))/sum(BLS_82_tmp(:,2,i));
		for j = 1:length(BLS_67_tmp(:,1,i))
			BLS_82_err_tmp(j,1) = BLS_82_tmp(j,1,i)./BLS_82_tmp(j,2,i);
		end
		BLS_82_err_tmp = BLS_82_err_tmp(~isnan(BLS_82_err_tmp));
		BLS_82_err(i,1)  = std(BLS_82_err_tmp)/sqrt(length(BLS_82_err_tmp)) / BLS_82_corr(i,1) .* 100; % 1 sigma SE in %
		clear BLS_82_err_tmp
	end
	
	for i = 1:data_count
		BLS_84_corr(i,1) = sum(BLS_84_tmp(:,1,i))/sum(BLS_84_tmp(:,2,i));
		for j = 1:length(BLS_84_tmp(:,1,i))
			BLS_84_err_tmp(j,1) = BLS_84_tmp(j,1,i)./BLS_84_tmp(j,2,i);
		end
		BLS_84_err_tmp = BLS_84_err_tmp(~isnan(BLS_84_err_tmp));
		BLS_84_err(i,1)  = std(BLS_84_err_tmp)/sqrt(length(BLS_84_err_tmp)) / BLS_84_corr(i,1) .* 100; % 1 sigma SE in %
		clear BLS_84_err_tmp
	end	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
end



















% unc propagated from bulk BLS rmv
for i = 1:data_count
	BLS_68_err(i,1) = sqrt( BLS_68_err(i,1)*BLS_68_err(i,1) );
	BLS_67_err(i,1) = sqrt( BLS_67_err(i,1)*BLS_67_err(i,1) );
	BLS_64_err(i,1) = sqrt( BLS_64_err(i,1)*BLS_64_err(i,1) );
	BLS_82_err(i,1) = sqrt( BLS_82_err(i,1)*BLS_82_err(i,1) );
	BLS_84_err(i,1) = sqrt( BLS_84_err(i,1)*BLS_84_err(i,1) );
end

% unc propagated from bulk BLS
%{
for i = 1:data_count
	BLS_68_err(i,1) = sqrt( BLS_68_err(i,1)*BLS_68_err(i,1) + SE206BL(i,1)*SE206BL(i,1) + SE238BL(i,1)*SE238BL(i,1) );
	BLS_67_err(i,1) = sqrt( BLS_67_err(i,1)*BLS_67_err(i,1) + SE206BL(i,1)*SE206BL(i,1) + SE207BL(i,1)*SE207BL(i,1) );
	BLS_64_err(i,1) = sqrt( BLS_64_err(i,1)*BLS_64_err(i,1) + SE206BL(i,1)*SE206BL(i,1) + SE204BL(i,1)*SE204BL(i,1) );
	BLS_82_err(i,1) = sqrt( BLS_82_err(i,1)*BLS_82_err(i,1) + SE208BL(i,1)*SE208BL(i,1) + SE232BL(i,1)*SE232BL(i,1) );
	BLS_84_err(i,1) = sqrt( BLS_84_err(i,1)*BLS_84_err(i,1) + SE208BL(i,1)*SE208BL(i,1) + SE204BL(i,1)*SE204BL(i,1) );
end
%}

waitbar(7/waitnum,h,'Calculating. Please wait...');

Macro1_Output(1:data_count+1,1:20) = {0}; % Preallocate
Macro1_Output(1,1:end) = {'sample', 'serial', '202 (cps)', '204 (cps)', '206 (cps)', '207 (cps)', '208 (cps)', '232 (cps)', '238 (cps)', '206238', '68 ± %', 'm68', ...
	'206207', '67 ± %', '206204', '64 ± %', '208232', '82 ± %', '208204', '84 ± %'};
Macro1_Output(2:end,1) = sample;
Macro1_Output(2:end,2) = serial;
Macro1_Output(2:end,3) = num2cell(CPS_202);
Macro1_Output(2:end,4) = num2cell(CPS_204);
Macro1_Output(2:end,5) = num2cell(CPS_206);
Macro1_Output(2:end,6) = num2cell(CPS_207);
Macro1_Output(2:end,7) = num2cell(CPS_208);
Macro1_Output(2:end,8) = num2cell(CPS_232);
Macro1_Output(2:end,9) = num2cell(CPS_238);
Macro1_Output(2:end,10) = num2cell(BLS_68_corr);
Macro1_Output(2:end,11) = num2cell(BLS_68_err);
Macro1_Output(2:end,12) = num2cell(BLS_68_slope);
Macro1_Output(2:end,13) = num2cell(BLS_67_corr);
Macro1_Output(2:end,14) = num2cell(BLS_67_err);
Macro1_Output(2:end,15) = num2cell(BLS_64_corr);
Macro1_Output(2:end,16) = num2cell(BLS_64_err);
Macro1_Output(2:end,17) = num2cell(BLS_82_corr);
Macro1_Output(2:end,18) = num2cell(BLS_82_err);
Macro1_Output(2:end,19) = num2cell(BLS_84_corr);
Macro1_Output(2:end,20) = num2cell(BLS_84_err);









% START MACRO 2 %%
for i = 1:data_count
	% 	if FC1_idx(i,1) == 1
	% 		STD1_238(i,1) = CPS_238(1,i);
	% 		STD1_232(i,1) = CPS_232(1,i);
	% 		ff68FC1(i,1) = FC1_68/BLS_68_corr(i,1); %Column CC;
	% 		stdfc67FC1(i,1) = FC1_67/BLS_67_corr(i,1); %Column CL;
	% 	end
	


	
	
	
	
	if STD1_idx(i,1) == 1
		STD1_238(i,1) = CPS_238(1,i);
		STD1_232(i,1) = CPS_232(1,i);
		ff68(i,1) = STD1_68/BLS_68_corr(i,1); %Column CC;
		stdfc67(i,1) = STD1_67/BLS_67_corr(i,1); %Column CL;
	else
		STD1_238(i,1) = 0;
		STD1_232(i,1) = 0;
		ff68(i,1) = 0;
		stdfc67(i,1) = 0;
	end
end










STD1_238_mean = mean(nonzeros(STD1_238));
STD1_232_mean = mean(nonzeros(STD1_232));

ff68n = ff68;
ff68n(ff68n == 0) = NaN;
ffsw68 = movmean(ff68n,str2num(get(H.igrun,'String')),'omitnan');
ffse68 = movstd(ff68n,str2num(get(H.igrun,'String')),'omitnan')./sqrt(str2num(get(H.igrun,'String')));

ff67n = stdfc67;
ff67n(ff67n == 0) = NaN;
stdfcsw67 = movmean(ff67n,str2num(get(H.igrun,'String')),'omitnan');
stdswse67 = movstd(ff67n,str2num(get(H.igrun,'String')),'omitnan')./sqrt(str2num(get(H.igrun,'String')));

%ff82n = stdfc82;
%ff82n(ff82n == 0) = NaN;
%stdfcsw82 = movmean(ff82n,str2num(get(H.igrun,'String')),'omitnan');
%stdswse82 = movstd(ff82n,str2num(get(H.igrun,'String')),'omitnan')./sqrt(str2num(get(H.igrun,'String')));

% Sliding window uncertainties %%
ffse68_hi = ffsw68 + ffse68;
ffse68_lo = ffsw68 - ffse68;

ffse67_hi = stdfcsw67 + stdswse67;
ffse67_lo = stdfcsw67 - stdswse67;

%ffse82_hi = stdfcsw82 + stdswse82;
%ffse82_lo = stdfcsw82 - stdswse82;

analysis_num = (1:1:data_count)'; % Set analysis numbers

for i = 1:data_count
	if STD1_idx(i,1) == 1
		STD1_num(i,1) = analysis_num(i,1);
		ff68_num(i,1) = ff68(i,1);
		ff67_num(i,1) = stdfc67(i,1);
		%ff82_num(i,1) = stdfc82(i,1);
	end
end

STD1_num = nonzeros(STD1_num);
ff68_num = nonzeros(ff68_num);
ff67_num = nonzeros(ff67_num);
%ff82_num = nonzeros(ff82_num);


if get(H.corr208, 'Value') == 0
	for i = 1:data_count
		fcbc68(i,1) = BLS_68_corr(i,1).*ffsw68(i,1);
		fcbc67(i,1) = BLS_67_corr(i,1).*stdfcsw67(i,1);
		fcbc82(i,1) = 0;
	end
end

if get(H.corr208, 'Value') == 1
	for i = 1:data_count
		if ffsw68(i,1) < 0 || BLS_68_corr(i,1) < 0
			Age_Est(i,1) = nan;
		else
			Age_Est(i,1) = log(ffsw68(i,1).*BLS_68_corr(i,1)+1)/0.000155125; %Age estimate based on fract factor and measured 6/8
		end
		SK_64(i,1) = (18.761-0.0000001.*Age_Est(i,1).*Age_Est(i,1)-0.0016.*Age_Est(i,1)); %6/4 from Stacey and Kramers (1975)
		SK_74(i,1) = 15.671-0.00000000009*Age_Est(i,1)*Age_Est(i,1)*Age_Est(i,1)+0.0000002*Age_Est(i,1)*Age_Est(i,1)-0.0003*Age_Est(i,1); %7/4 from Stacey and Kramers (1975)
		SK_84(i,1) = 38.657-0.00000003*Age_Est(i,1)*Age_Est(i,1)-0.0019*Age_Est(i,1); %8/4 from Stacey and Kramers (1975)
	end
	
	SK_206_208 = SK_64./SK_84;
	SK_207_208 = SK_74./SK_84;
	
	for i = 1:data_count
		for j = 1:length(integration(:,1))
			if BLS_208(j,i) > 0
				BLS_206c(j,i) = BLS_206(j,i) - BLS_208(j,i)*SK_206_208(i,1);
			else
				BLS_206c(j,i) = BLS_206(j,i);
			end
			if BLS_208(j,i) > 0
				BLS_207c(j,i) = BLS_207(j,i) - BLS_208(j,i)*SK_207_208(i,1);
			else
				BLS_207c(j,i) = BLS_207(j,i);
			end	
		end
	end
		
	for i = 1:data_count
		for j = 1:length(integration(:,1))
			BLS_68c_tmp(j,1:2,i) = [BLS_206c(j,i),BLS_238(j,i)];
			if BLS_206c(j,i) > 0 && BLS_207c(j,i) > 0
				
				BLS_67c_tmp(j,1:2,i) = [BLS_206c(j,i),BLS_207c(j,i)];
			else
				BLS_67c_tmp(j,1:2,i) = [0,0];
			end
			if 1./(BLS_206c(j,i)./BLS_207c(j,i)) > 0.55 || 1./(BLS_206c(j,i)./BLS_207c(j,i)) < 0.04604504
				BLS_67c_tmp(j,1:2,i) = [0,0];
			end
			%BLS_64_tmp(j,1:2,i) = [abs(BLS_206(j,i)),abs(BLS_204(j,i))];
			%BLS_82_tmp(j,1:2,i) = [abs(BLS_208(j,i)),abs(BLS_232(j,i))];
			%BLS_84_tmp(j,1:2,i) = [abs(BLS_208(j,i)),abs(BLS_204(j,i))];
		end
	end
	
	for i = 1:data_count
		BLS_68c_corr(i,1) = sum(BLS_68c_tmp(1:end,1,i))/sum(BLS_68c_tmp(1:end,2,i));
		if sum(BLS_67c_tmp(:,2,i)) > 0
			BLS_67c_corr(i,1) = sum(BLS_67c_tmp(:,1,i))/sum(BLS_67c_tmp(:,2,i));
		else
			BLS_67c_corr(i,1) = 1000;
		end
	end
	
	for i = 1:data_count
		if STD1_idx(i,1) == 1
			%STD1_238(i,1) = CPS_238(1,i);
			%STD1_232(i,1) = CPS_232(1,i);
			ff68(i,1) = STD1_68/BLS_68c_corr(i,1); %Column CC;
			stdfc67(i,1) = STD1_67/BLS_67c_corr(i,1); %Column CL;
		else
			%STD1_238(i,1) = 0;
			%STD1_232(i,1) = 0;
			ff68(i,1) = 0;
			stdfc67(i,1) = 0;
		end
	end

	ff68n = ff68;
	ff68n(ff68n == 0) = NaN;
	ffsw68 = movmean(ff68n,str2num(get(H.igrun,'String')),'omitnan');
	ffse68 = movstd(ff68n,str2num(get(H.igrun,'String')),'omitnan')./sqrt(str2num(get(H.igrun,'String')));

	ff67n = stdfc67;
	ff67n(ff67n == 0) = NaN;
	stdfcsw67 = movmean(ff67n,str2num(get(H.igrun,'String')),'omitnan');
	stdswse67 = movstd(ff67n,str2num(get(H.igrun,'String')),'omitnan')./sqrt(str2num(get(H.igrun,'String')));

	%ff82n = stdfc82;
	%ff82n(ff82n == 0) = NaN;
	%stdfcsw82 = movmean(ff82n,str2num(get(H.igrun,'String')),'omitnan');
	%stdswse82 = movstd(ff82n,str2num(get(H.igrun,'String')),'omitnan')./sqrt(str2num(get(H.igrun,'String')));

	% Sliding window uncertainties %%
	ffse68_hi = ffsw68 + ffse68;
	ffse68_lo = ffsw68 - ffse68;

	ffse67_hi = stdfcsw67 + stdswse67;
	ffse67_lo = stdfcsw67 - stdswse67;	

	
	for i = 1:data_count
		if STD1_idx(i,1) == 1
			STD1_num(i,1) = analysis_num(i,1);
			ff68_num(i,1) = ff68(i,1);
			ff67_num(i,1) = stdfc67(i,1);
			%ff82_num(i,1) = stdfc82(i,1);
		end
	end
	
	STD1_num = nonzeros(STD1_num);
	ff68_num = nonzeros(ff68_num);
	ff67_num = nonzeros(ff67_num);


	for i = 1:data_count
		fcbc68(i,1) = BLS_68c_corr(i,1).*ffsw68(i,1);
		fcbc67(i,1) = BLS_67c_corr(i,1).*stdfcsw67(i,1);
		fcbc82(i,1) = 0;
	end
end
























% Calculate final ratios and ages and uncertainties %%
for i = 1:data_count
	ppm238(i,1) = CPS_238(1,i).*STD1_Uppm/STD1_238_mean; %Column AY
	ppm232(i,1) = CPS_232(1,i).*(STD1_Thppm/STD1_232_mean); %Column AZ
end

UTh = ppm238./ppm232; %Column BC

for i = 1:data_count
	ratio68(i,1) = fcbc68(i,1)-((0.000000000155/0.0000092)*(((1/UTh(i,1))/2.3)-1)); %Column BJ
	ratio75(i,1) = (ratio68(i,1)/fcbc67(i,1))*137.82; %Column BH
end

for i = 1:data_count
	if ratio68(i,1) < 0
		Age68{i,1} = 'NA';
	else
		Age68{i,1} = log(ratio68(i,1)+1)/0.000155125;
	end
end

for i = 1:data_count
	if isnan(fcbc67(i,1)) == 1
		Age67{i,1} = .04604504;
	end
	if isnan(fcbc67(i,1)) == 0
		if 1/fcbc67(i,1) < .04604504 %zero age
			Age67{i,1} = 'NA';
		elseif 1/fcbc67(i,1) > .55 %older than Earth
			Age67{i,1} = 'NA';
		else
			Age67{i,1} = MyAge76(1/fcbc67(i,1));
		end
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
%	if fcbc82(i,1) < 0
%		Age82{i,1} = 'NA';
%	else
		Age82{i,1} = 'NA';
%	end
end

waitbar(9/waitnum,h,'Calculating. Please wait...');

%{
DD = BLS_64_corr*factor64;

for i = 1:data_count
	err6864(i,1) = abs(100*(1-((DD(i,1)-(18.761-DF(i,1)))/DD(i,1))/(((DD(i,1)+DD(i,1)*BLS_64_err(i,1)/100)-...
		(18.761-DF(i,1)))/(DD(i,1)+DD(i,1)*BLS_64_err(i,1)/100)))); %Column CJ
	pbcerr68(i,1) = abs(100*(1-(DD(i,1)-(DF(i,1)/DD(i,1)))/(DD(i,1)-((DF(i,1)-1)/DD(i,1)))));
	
	
	pbcerr67(i,1) = abs(100*(1-((stdfcsw67(i,1)*((DD(i,1)-(DF(i,1)))/((DD(i,1)/(BLS_67_corr(i,1))-DG(i,1)))))/(stdfcsw67(i,1)*(((DD(i,1)) ...
		- (DF(i,1)-1))/(((DD(i,1))/(BLS_67_corr(i,1))-(DG(i,1)-0.3))))))));
	
	
	err6764(i,1) = abs(100*(1-((stdfcsw67(i,1)*((BLS_64_corr(i,1)*factor64-DF(i,1))/((BLS_64_corr(i,1)*factor64/(BLS_67_corr(i,1)) ...
		-DG(i,1)))))/(stdfcsw67(i,1)*(((BLS_64_corr(i,1)*factor64+BLS_64_corr(i,1)*factor64*BLS_64_err(i,1)/100)-(DF(i,1))) ...
		/(((BLS_64_corr(i,1)*factor64+BLS_64_corr(i,1)*factor64*BLS_64_err(i,1)/100)/(BLS_67_corr(i,1))-DG(i,1)))))))); %Column CS
	err8284(i,1) = abs(100*(1-(((BLS_84_corr(i,1)-DH(i,1)))/BLS_84_corr(i,1))/((((BLS_84_corr(i,1)+BLS_84_corr(i,1) ...
		*BLS_84_err(i,1)/100)-DH(i,1)))/(BLS_84_corr(i,1)+BLS_84_corr(i,1)*BLS_84_err(i,1)/100)))); %Column DB
end
%}

for i = 1:data_count
	re67(i,1) = BLS_67_err(i,1);
	re82(i,1) = 0; %Column DA
	err68m(i,1) = BLS_68_err(i,1); 
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
%	if (fcbc82(i,1)+fcbc82(i,1)*(re82(i,1)/100))+1 < 0
%		Age82_err{i,1} = 'NA';
%	elseif (fcbc82(i,1)-fcbc82(i,1)*re82(i,1)/100)+1 < 0
		Age82_err{i,1} = 'NA';
%	else
%		Age82_err{i,1} = (log((fcbc82(i,1)+fcbc82(i,1)*(re82(i,1)/100))+1)/0.0000495 - log((fcbc82(i,1)-fcbc82(i,1)*re82(i,1)/100)+1)/0.0000495)/2;
%	end
end

for i = 1:data_count
	if isnan(fcbc67(i,1)) == 1
		Age67_err{i,1} = 'NA';
	end
	if isnan(fcbc67(i,1)) == 0
		if 1/(fcbc67(i,1)-fcbc67(i,1)*re67(i,1)/100) < .04604504
			Age67_err{i,1} = 'NA';
		elseif 1/(fcbc67(i,1)-fcbc67(i,1)*re67(i,1)/100) > .55
			Age67_err{i,1} = 'NA';
		elseif 1/(fcbc67(i,1)+fcbc67(i,1)*re67(i,1)/100) < .04604504
			Age67_err{i,1} = 'NA';
		elseif 1/(fcbc67(i,1)+fcbc67(i,1)*re67(i,1)/100) > .55
			Age67_err{i,1} = 'NA';
		else
			Age67_err{i,1} = abs((MyAge76(1/(fcbc67(i,1)-fcbc67(i,1)*re67(i,1)/100)) - MyAge76(1/(fcbc67(i,1)+fcbc67(i,1)*re67(i,1)/100)))/2);
		end
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

% FILTERS FOR DISCORDANCE, PRECISION, AND 204 COUNTS %%

comment1{data_count, 1} = [];
comment2{data_count, 1} = [];
comment3{data_count, 1} = [];
comment4{data_count, 1} = [];
comment5{data_count, 1} = [];
comment6{data_count, 1} = [];
comment7{data_count, 1} = [];

for i = 1:data_count
	if BLS_68_err(i,1) > filter_err68
		comment1(i,1) = {'high 6/8 err  '};
		%elseif mean(BLS_238(:,i)) < 0.0001
		%comment1(i,1) = {'Not zircon...  '};
	end
	if cell2num(Age68(i,1)) > filter_cutoff && BLS_67_err(i,1) > filter_err67
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
	%if BLS_64_corr(i,1) < filter_204/10
	%    comment6(i,1) = {'low 206/204  '};
	%end
	if ppm238(i,1) > str2num(get(H.Ufilt,'String'))
		comment7(i,1) = {'high U!!!  '};
	end
	
end

waitbar(10/waitnum,h,'Calculating. Please wait...');

comment = strcat(comment1, comment2, comment3, comment4, comment5, comment6, comment7);

% CONCATENATE DATA FOR EXPORT AND PLOTTING %%

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
%{
CORRECTED_CONC_RATIOS(2:end,:) = [sample, num2cell(ppm238), num2cell(ppm232), num2cell(BLS_64_corr.*factor64), num2cell(BLS_84_corr), ...
	num2cell(UTh), num2cell(fcbc67), num2cell(re67), num2cell(fcbc82), num2cell(re82), num2cell(ratio75), num2cell(ratio75_err), num2cell(ratio68), ...
	num2cell(err68m), num2cell(rho)];
%}
	
CORRECTED_CONC_RATIOS(2:end,:) = [sample, num2cell(ppm238), num2cell(ppm232), repmat({'N/A'},length(sample),1), num2cell(BLS_84_corr), ...
	num2cell(UTh), num2cell(fcbc67), num2cell(re67), num2cell(fcbc82), num2cell(re82), num2cell(ratio75), num2cell(ratio75_err), num2cell(ratio68), ...
	num2cell(err68m), num2cell(rho)];


AGES_1SD_RANDOM_ERRORS{data_count+1, 10} = [];
AGES_1SD_RANDOM_ERRORS(1,:) = {'6/8 age', '±(Ma)', '7/5 age', '±(Ma)', '6/7 age', '±(Ma)', '8/2 age', '±(Ma)', 'BEST AGE', '±(Ma)'};
AGES_1SD_RANDOM_ERRORS(2:end,:) = [Age68, Age68_err, Age75, Age75_err, Age67, Age67_err, Age82, Age82_err, Best_Age, Best_Age_err];

Macro_1_2_Output = [Macro1_Output, AGES_OUT, [{'comment'};comment], SAMPLE_CONCORDIA, STD_CONCORDIA, CORRECTED_CONC_RATIOS, AGES_1SD_RANDOM_ERRORS];
%assignin('base','Macro_1_2_Output',Macro_1_2_Output);
% POPULATE STDS LISTBOX %%
name_idx2 = sum(nonzeros(STD1_idx)); %automatically plot final sample run

name_char_std = stds(~cellfun(@isempty, stds));

name_char_std = name_char_std(~cellfun('isempty',name_char_std));



close(h)



% PLOT DEFAULT Pb206/U238 DRIFT CORRECTION %%%%%
cla(H.axes_distribution,'reset');
axes(H.axes_session_fractionation);
%figure
hold on
fill([(1:1:data_count)';flipud((1:1:data_count)')], [ffse68_hi; flipud(ffse68_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
plot([(1:1:data_count); (1:1:data_count)], [(ffsw68+ffsw68*0.02)'; (ffsw68-ffsw68*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',1) % Error bars
ss = scatter(STD1_num, ff68_num, 75, 'b', 'filled','d');
%sc = scatter(STD1_num(name_idx2,1), ff68_num(name_idx2,1), 175, 'o', 'MarkerEdgeColor', 'b');
axis([0 data_count+1 min([(ffsw68-ffsw68*0.02);ff68_num])-0.02*min([(ffsw68-ffsw68*0.02);ff68_num]) max([(ffsw68+ffsw68*0.02);ff68_num])+0.02*max([(ffsw68+ffsw68*0.02);ff68_num])])
hold off
%title('Pb206/U238 Session drift')
legend(ss, 'Primary Standards', 'Location','northeast');
xlabel('Analysis number','Color','k')
ylabel('Pb206/U238 fractionation factor','Color','k')

% CALCULATE RHO AND REPLACE 'BAD' (<0 OR >1) CORRELATION COEFFICIENT (RHO) %%%%%

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



for i = 1:length(ratio75)
	if isnan(ratio75(i,1)) || isnan(ratio75_err(i,1)) || isnan(ratio68(i,1)) || isnan(err68m(i,1)) == 1
		ratio75(i,1) = 0;
		ratio75_err(i,1) = 0;
		ratio68(i,1) = 0;
		err68m(i,1) = 0;
		errcorr_corr(i,1) = 0;
	end
end

STD1_rho = nonzeros(STD1_idx.*errcorr_corr);
STD2_rho = nonzeros(STD2_idx.*errcorr_corr);
STD3_rho = nonzeros(STD3_idx.*errcorr_corr);
rho = errcorr_corr;

STD1_concordia_data = [nonzeros(STD1_idx.*ratio75),nonzeros(STD1_idx.*ratio75_err),nonzeros(STD1_idx.*ratio68),nonzeros(STD1_idx.*err68m)];
STD2_concordia_data = [nonzeros(STD2_idx.*ratio75),nonzeros(STD2_idx.*ratio75_err),nonzeros(STD2_idx.*ratio68),nonzeros(STD2_idx.*err68m)];
STD3_concordia_data = [nonzeros(STD3_idx.*ratio75),nonzeros(STD3_idx.*ratio75_err),nonzeros(STD3_idx.*ratio68),nonzeros(STD3_idx.*err68m)];
concordia_data = [ratio75,ratio75_err,ratio68,err68m];
All_concordia_data = [ratio75,ratio75_err,ratio68,err68m];

center_STD1 = [STD1_concordia_data(:,1),STD1_concordia_data(:,3)];
center_STD2 = [STD2_concordia_data(:,1),STD2_concordia_data(:,3)];
center_STD3 = [STD3_concordia_data(:,1),STD3_concordia_data(:,3)];
center = [concordia_data(:,1),concordia_data(:,3)];
center_All = [concordia_data(:,1),concordia_data(:,3)];

sigx_abs_STD1 = STD1_concordia_data(:,1).*STD1_concordia_data(:,2).*0.01;
sigy_abs_STD1 = STD1_concordia_data(:,3).*STD1_concordia_data(:,4).*0.01;

sigx_abs_STD2 = STD2_concordia_data(:,1).*STD2_concordia_data(:,2).*0.01;
sigy_abs_STD2 = STD2_concordia_data(:,3).*STD2_concordia_data(:,4).*0.01;

sigx_abs_STD3 = STD3_concordia_data(:,1).*STD3_concordia_data(:,2).*0.01;
sigy_abs_STD3 = STD3_concordia_data(:,3).*STD3_concordia_data(:,4).*0.01;

sigx_abs = concordia_data(:,1).*concordia_data(:,2).*0.01;
sigy_abs = concordia_data(:,3).*concordia_data(:,4).*0.01;

sigx_abs_All = concordia_data(:,1).*concordia_data(:,2).*0.01;
sigy_abs_All = concordia_data(:,3).*concordia_data(:,4).*0.01;

sigx_sq_STD1 = sigx_abs_STD1.*sigx_abs_STD1;
sigy_sq_STD1 = sigy_abs_STD1.*sigy_abs_STD1;

sigx_sq_STD2 = sigx_abs_STD2.*sigx_abs_STD2;
sigy_sq_STD2 = sigy_abs_STD2.*sigy_abs_STD2;

sigx_sq_STD3 = sigx_abs_STD3.*sigx_abs_STD3;
sigy_sq_STD3 = sigy_abs_STD3.*sigy_abs_STD3;

sigx_sq = sigx_abs.*sigx_abs;
sigy_sq = sigy_abs.*sigy_abs;

sigx_sq_All = sigx_abs.*sigx_abs;
sigy_sq_All = sigy_abs.*sigy_abs;

rho_sigx_sigy_STD1 = sigx_abs_STD1.*sigy_abs_STD1.*STD1_rho;
rho_sigx_sigy_STD2 = sigx_abs_STD2.*sigy_abs_STD2.*STD2_rho;
rho_sigx_sigy_STD3 = sigx_abs_STD3.*sigy_abs_STD3.*STD3_rho;
rho_sigx_sigy = sigx_abs.*sigy_abs.*rho;
rho_sigx_sigy_All = sigx_abs.*sigy_abs.*rho;





% POPULATE LISTBOX, SAMPLE INTENSITIES, AND PLOT INDIVIDUAL SAMPLE RAW DATA %%
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


values = values_all(1:end,1:9,name_idx);
values2 = values(any(values,2),:);

values2(:,10) = values2(:,4)./values2(:,9);
values2(:,11) = values2(:,4)./values2(:,5);
values2(:,12) = values2(:,6)./values2(:,7);


Ablate = values2(:,1);

samp_length = length(Ablate);


values2(isinf(values2)|isnan(values2)) = 1;

if get(H.log_scale, 'Value') == 1
	for i = 1:samp_length
		for j = 2:12
			if values2(i,j) <= 0
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2(:,2:12));
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2(:,2:12);
end

C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
set(H.axes_current_intensities,'box','on')
if get(H.thick_lines,'Value')==1
	thickness = 2;
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
if get(H.chk_U238,'Value')==1
	plot(Ablate,plot_vals(:,8),'linewidth', thickness, 'color',C{7});
end






if get(H.showint,'Value') == 1
	
	Uvals = plot_vals(str2num(get(H.intstart,'String')):str2num(get(H.intend,'String')),8);
	Pbvals = [plot_vals(str2num(get(H.intstart,'String')):str2num(get(H.intend,'String')),4) ; plot_vals(str2num(get(H.intstart,'String')):str2num(get(H.intend,'String')),5)];
	
	startidx = str2num(get(H.intstart,'String'));
	endidx = str2num(get(H.intend,'String'));
	
	base1s = str2num(get(H.base1start,'String'));
	base1e = str2num(get(H.base1end,'String'));

	base1vals = plot_vals(base1s:base1e,:);
	
	base2s = str2num(get(H.base2start,'String'));
	base2e = str2num(get(H.base2end,'String'));

	base2vals = plot_vals(base2s:base2e,:);	
	
	
	rectangle('Position',[Ablate(startidx) min(Pbvals) Ablate(endidx)-Ablate(startidx)  max(Uvals)-min(Pbvals)],'linewidth', 2)
	rectangle('Position',[Ablate(base1s) min(min(base1vals)) Ablate(base1e)-Ablate(base1s)  max(max(base1vals))-min(min(base1vals))],'linewidth', 2)
	rectangle('Position',[Ablate(base2s) min(min(base2vals)) Ablate(base2e)-Ablate(base2s)  max(max(base2vals))-min(min(base2vals))],'linewidth', 2)

end








hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([0.2 max(Ablate)])

% CURRENT STATUS %%

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





timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;


































axes(H.axes_current_concordia);

if get(H.corr207,'Value') == 0
	
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
	
	if sum(sum(elpt_out)) > 0
		axis([min(min(elpt_out(:,1,:))) - min(min(elpt_out(:,1,:)))*.01 max(max(elpt_out(:,1,:))) + max(max(elpt_out(:,1,:)))*.01 ...
			min(min(elpt_out(:,2,:))) - min(min(elpt_out(:,2,:)))*.01 max(max(elpt_out(:,2,:))) + max(max(elpt_out(:,2,:)))*.01]);
		xlabel('207Pb/235U');
		ylabel('206Pb/238U');
		
		p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
		
		legend([p3], bestage,  'Location', 'northwest');
	end
end











if get(H.corr207,'Value') == 1

	concordia_data = cell2num(Macro_1_2_Output(2:end,60:64));
	center = [concordia_data(:,1),concordia_data(:,3)];
	sigx_abs = concordia_data(:,1).*concordia_data(:,2).*0.01;
	sigy_abs = concordia_data(:,3).*concordia_data(:,4).*0.01;
	sigx_sq = sigx_abs.*sigx_abs;
	sigy_sq = sigy_abs.*sigy_abs;
	rho_sigx_sigy = sigx_abs.*sigy_abs.*rho(name_idx,1);
	
	data1 = concordia_data;
	
	timemin = 0;
	timemax = 4000000000;
	timeinterval = 50000;
	time = timemin:timeinterval:timemax;
	xC1 = exp(0.00000000098485.*time)-1;
	yC1 = exp(0.000000000155125.*time)-1;
	
	concint = 500; % in Myr
	
	agelabelmin = 0;
	agelabelint = concint*1000000;
	agelabelmax = 4000000000;
	age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
	age_label_x = exp(0.00000000098485.*age_label_num)-1;
	age_label_y = exp(0.000000000155125.*age_label_num)-1;
	
	for i=1:length(age_label_num)
		age_label(i,1) = {sprintf('%.0f',age_label_num(1,i)/1000000)};
		age_label2(i,1) = strcat(age_label(i,1),' Ma');
	end
	
	xCTW = 1./yC1;
	yCTW = xC1 .* 1./yC1 ./ 137.82;
	
	age_label_xTW = 1./age_label_y;
	age_label_yTW = age_label_x .* 1./age_label_y./ 137.82;
	
	for i = 1:length(data1(:,1))
		
		data2(i,1) = 1/data1(i,3);
		data2(i,2) = data1(i,4);
		data2(i,3) = data1(i,1)*data2(i,1)/137.82;
		data2(i,4) = data1(i,2);
		data2(i,5) = data1(i,5);
		
		m = (0.836 - data2(i,3))/data2(i,1);
		x = 0.836/m;
		anchors = [0, 0.836; x, 0];
		[pY, S1] = polyfit(anchors(:,1),anchors(:,2),1);
		Yf = polyval(pY,xCTW');
		ydiff = abs(Yf - yCTW');
		[ymin1 yidx1] = min(ydiff);
		interc1 = [xCTW(yidx1),yCTW(yidx1)];
		
		Age68c(i,1) = log(1/interc1(:,1)+1)./0.000155125;
		%Age67(i,1) = MyAge76(interc1(:,2));
		
		
		H.Age68c = Age68c;
	end
	

	
	
	
	
	
	
	
	
	hold on
	
	center=[data2(:,1),data2(:,3)];
	rho = data2(:,5);
	sigx_abs = data2(:,1).*data2(:,2).*0.01;
	sigy_abs = data2(:,3).*data2(:,4).*0.01;
	sigx_sq = sigx_abs.*sigx_abs;
	sigy_sq = sigy_abs.*sigy_abs;
	rho_sigx_sigy = sigx_abs.*sigy_abs.*rho;
	numpoints=50;
	sigmarule1s=1.5;
	
	covmat=[sigx_sq(name_idx,1),rho_sigx_sigy(name_idx,1);rho_sigx_sigy(name_idx,1),sigy_sq(name_idx,1)];
	if sum(sum(isnan(covmat))) < 1
		[PD,PV]=eig(covmat);
		PV=diag(PV).^.5;
		theta=linspace(0,2.*pi,numpoints)';
		elpt1s=[cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma1s=length(sigmarule1s);
		elpt1s=repmat(elpt1s,1,numsigma1s).*repmat(sigmarule1s(floor(1:.5:numsigma1s+.5)),numpoints,1);
		elpt1s=elpt1s+repmat(center(name_idx,1:2),numpoints,numsigma1s);
		elpt1s_out(:,:,name_idx)=elpt1s+repmat(center(name_idx,1:2),numpoints,numsigma1s);
		plot(elpt1s(:,1:2:end),elpt1s(:,2:2:end),'b','LineWidth', 1);

	
	
	
		
		
		
		
		
		
		
		
		plot(xCTW,yCTW)
		scatter(data2(name_idx,1),data2(name_idx,3),'filled')
		text(age_label_xTW+0.1, age_label_yTW,age_label2, 'FontWeight', 'bold')
		
		
		p3 = scatter(interc1(:,1),interc1(:,2), 75, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
		plot(anchors(:,1), anchors(:,2))
		axis([0 data2(name_idx,1)+10 0.05 .2])
		
		for i = 1:length(age_label_num)
			scatter(age_label_xTW(1,i), age_label_yTW(1,i), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
		end
		
		
		%p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
		
		
		
		bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Age68c(name_idx,1))}, {' ± '},  {sprintf('%.1f',Age68_err{name_idx,1})}, {' Ma'});
		
		legend([p3], bestage,  'Location', 'northeast');
	end
end

% DISTRIBUTION PLOT %%

cla(H.axes_distribution, 'reset');
axes(H.axes_distribution);


%{

if get(H.plotSTDs,'Value') == 0
	
	for i = 1:data_count
		if current_status_num(i,1) == 1 && sample_idx(i,1) == 1
			dist_data(i+1,1) = cell2num(SAMPLE_CONCORDIA(i+1,10));
			dist_data(i+1,2) = cell2num(SAMPLE_CONCORDIA(i+1,11));
		end
	end
	
	for i = 1:length(dist_data(:,1))
		if isnan(dist_data(i,1)) == 1 || isnan(dist_data(i,2)) == 1
			dist_data(i,1:2) = [0,0];
		end
	end
	
end


if get(H.plotSTDs,'Value') == 1
	
	for i = 1:data_count
		if current_status_num(i,1) == 1 && sample_idx(i,1) == 0
			dist_data(i+1,1) = cell2num(Best_Age(i,:));
			dist_data(i+1,2) = cell2num(Best_Age_err(i,:));
		end
	end
	
	for i = 1:length(dist_data(:,1))
		if isnan(dist_data(i,1)) == 1 || isnan(dist_data(i,2)) == 1
			dist_data(i,1:2) = [0,0];
		end
	end
	
end


%}





reduced = 1;

% UPDATE HANDLES %%
H.sample = sample;
%H.Data_All = Data_All;
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
%H.ffse82_hi = ffse82_hi;
%H.ffse82_lo = ffse82_lo;
%H.stdfcsw82 = stdfcsw82;
%H.ff82_num = ff82_num;
H.sample_idx = sample_idx;
%H.INT = INT;
H.sigx_sq_All = sigx_sq_All;
H.rho_sigx_sigy_All = rho_sigx_sigy_All;
H.sigy_sq_All = sigy_sq_All;
H.center_All = center_All;
H.name_char = name_char;
H.ffsw68 = ffsw68;
H.ffse68 = ffse68;
H.stdfcsw67 = stdfcsw67;
H.stdswse67 = stdswse67;
%H.pbcerr68 = pbcerr68;
%H.pbcerr67 = pbcerr67;
H.BLS_68_err = BLS_68_err;
H.BLS_67_err = BLS_67_err;

H.sigx_sq_STD1 = sigx_sq_STD1;
H.rho_sigx_sigy_STD1 = rho_sigx_sigy_STD1;
H.sigy_sq_STD1 = sigy_sq_STD1;
H.center_STD1 = center_STD1;
H.STD1_68 = STD1_68;
H.STD1_67 = STD1_67;
H.STD1_75 = STD1_75;
H.STD1age = STD1age;

H.sigx_sq_STD2 = sigx_sq_STD2;
H.rho_sigx_sigy_STD2 = rho_sigx_sigy_STD2;
H.rho_sigx_sigy_STD2 = rho_sigx_sigy_STD2;
H.sigy_sq_STD2 = sigy_sq_STD2;
H.center_STD2 = center_STD2;
H.STD2_68 = STD2_68;
H.STD2_67 = STD2_67;
H.STD2_idx = STD2_idx;
H.STD2_75 = STD2_75;
H.STD2age = STD2age;

H.sigx_sq_STD3 = sigx_sq_STD3;
H.rho_sigx_sigy_STD3 = rho_sigx_sigy_STD3;
H.rho_sigx_sigy_STD3 = rho_sigx_sigy_STD3;
H.sigy_sq_STD3 = sigy_sq_STD3;
H.center_STD3 = center_STD3;
H.STD3_68 = STD3_68;
H.STD3_67 = STD3_67;
H.STD3_idx = STD3_idx;
H.STD3_75 = STD3_75;
H.STD3age = STD3age;

H.reduced = reduced;

%H.values_tmp = values_tmp;
%H.IC = IC;

H.values_all = values_all;

H.name_char_std = name_char_std;
%H.sc = sc;

H.samp_length = samp_length;

% Calculate systematic Uncertainties
% Original


%{
for i = 1:length(STD1_idx)
	if STD1_idx(i,1) ~= 1 && BLS_68_err(i,1) < 20 && isnan(ffse68(i,1)) == 0 && isnan(ffsw68(i,1)) == 0 && isnan(pbcerr68(i,1)) == 0
		syst_err_68(i,1) = sqrt(100*ffse68(i,1)/ffsw68(i,1)*100*ffse68(i,1)/ffsw68(i,1)+pbcerr68(i,1)*pbcerr68(i,1)+0.053*0.053+0.033*0.033); %.35 SL(?) --> .33 FC Mattinson (2010)
	else
		syst_err_68(i,1) = 0;
	end
end

%if length(syst_err_68) >= 126
%	systerr68 = 2*mean(nonzeros(syst_err_68(1:126,1)));
%else
systerr68 = 2*median(nonzeros(syst_err_68));
%end

for i = 1:length(STD1_idx)
	if STD1_idx(i,1) ~= 1 && BLS_67_err(i,1) < 20 && cell2num(Age68(i,1)) > 400 && isnan(stdswse67(i,1)) == 0 && isnan(stdfcsw67(i,1)) == 0 && isnan(pbcerr67(i,1)) == 0
		syst_err_67(i,1) = sqrt(100*stdswse67(i,1)/stdfcsw67(i,1)*100*stdswse67(i,1)/stdfcsw67(i,1)+(pbcerr67(i,1))*(pbcerr67(i,1))+0.053*0.053+0.069*0.069+0.035*0.035);
	end
end

%if length(syst_err_67) >= 126
%	systerr67 = 2*mean(nonzeros(syst_err_67(1:126,1)));
%else
systerr67 = 2*median(nonzeros(syst_err_67));
%end

set(H.SE6867,'String',strcat(sprintf('%.2f ', systerr68), {'%, '}, sprintf('%.2f ', systerr67), {'%'}))


H.systerr68 = systerr68;
H.systerr67 = systerr67;
%}


%New

%{
	for i = 1:length(STD1_idx)
		if STD1_idx(i,1) == 1
			STD1_data68(i,1) = BLS_68_corr(i,1);
			STD1_data68(i,2) = BLS_68_err(i,1)*STD1_data68(i,1)/100; %convert to abs unc;
			STD1_data67(i,1) = BLS_67_corr(i,1);
			STD1_data67(i,2) = BLS_67_err(i,1);
			STD1_pbcerr68(i,1) = pbcerr68(i,1);
			STD1_pbcerr67(i,1) = pbcerr67(i,1);
			
			
			%STD1_data68sw(i,1) = ffsw68(i,1);
			%STD1_data68sw(i,2) = 100*ffse68(i,1)/ffsw68(i,1);

		end
		
		if STD2_idx(i,1) == 1
			STD2_data68(i,1) = BLS_68_corr(i,1);
			STD2_data68(i,2) = BLS_68_err(i,1)*STD2_data68(i,1)/100; %convert to abs unc;
		end
	end
	STD1_data68( ~any(STD1_data68,2), : ) = [];  %rows
	STD1_data67( ~any(STD1_data67,2), : ) = [];  %rows
	STD1_pbcerr68( ~any(STD1_pbcerr68,2), : ) = [];  %rows
	STD1_pbcerr67( ~any(STD1_pbcerr67,2), : ) = [];  %rows
	%STD1_data68sw( ~any(STD1_data68sw,2), : ) = [];  %rows
	
	STD2_data68( ~any(STD2_data68,2), : ) = [];  %rows


	tt = sum(STD1_data68(:,1)./(STD1_data68(:,2).*STD1_data68(:,2))) / sum(1./(STD1_data68(:,2).*STD1_data68(:,2))); % Weighted Mean
	data2 = STD1_data68;
	data2(:,2) = data2(:,2).*2; % double the uncertainty to get the MSWD at 1 sigma....
	s = 1/sqrt(sum(1./(data2(:,2).*data2(:,2)))); % SE
	s_perc68 = s/tt*100;
	STD1_data68_MSWD = 1/(length(data2(:,1))-1).*sum(((data2(:,1)- (sum(data2(:,1)./(data2(:,2).^2))/sum(1./(data2(:,2).^2))) ).^2)./((data2(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot

	syst_err_68 = 2*sqrt(s_perc68^2 + 0.053^2 + 0.33^2);

%}












if get(H.ptype_Primary_STDs,'Value') == 1
	ptype_Primary_STDs_Callback(hObject, eventdata, H)
end

if get(H.ptype_Secondary_STDs,'Value') == 1
	ptype_Secondary_STDs_Callback(hObject, eventdata, H)
end

if get(H.ptype_Tertiary_STDs,'Value') == 1
	ptype_Tertiary_STDs_Callback(hObject, eventdata, H)
end

if get(H.wmPrimary,'Value') == 1
	wmPrimary_Callback(hObject, eventdata, H)
end

if get(H.wmSecondary,'Value') == 1
	wmSecondary_Callback(hObject, eventdata, H)
end

if get(H.wmTertiary,'Value') == 1
	wmTertiary_Callback(hObject, eventdata, H)
end

if get(H.ptype_Unknowns,'Value') == 1
	ptype_Unknowns_Callback(hObject, eventdata, H)
end

if get(H.ptype_Unknowns_acc,'Value') == 1
	ptype_Unknowns_acc_Callback(hObject, eventdata, H)
end

if get(H.ptype_Unknowns_rej,'Value') == 1
	ptype_Unknowns_rej_Callback(hObject, eventdata, H)
end

if get(H.age_uconc,'Value') == 1
	age_uconc_Callback(hObject, eventdata, H)
end

if get(H.age_raddos,'Value') == 1
	age_raddos_Callback(hObject, eventdata, H)
end

if get(H.age_uth,'Value') == 1
	age_uth_Callback(hObject, eventdata, H)
end

if get(H.age_concodance,'Value') == 1
	age_concodance_Callback(hObject, eventdata, H)
end





plot_distribution(hObject, eventdata, H)







guidata(hObject,H);


function primary_Callback(hObject, eventdata, H)
function secondary_Callback(hObject, eventdata, H)
function tertiary_Callback(hObject, eventdata, H)
function reject_no_CreateFcn(hObject, eventdata, H)
function reject68_Callback(hObject, eventdata, H)
function reject67_Callback(hObject, eventdata, H)
function sigmafilt_Callback(hObject, eventdata, H)
function t0ext_Callback(hObject, eventdata, H)
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

tmp = strfind(filenames(:,1), 'run');
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

Data = importdata(char(fullpathname_data),',',500000);
Names = importdata(fullpathname_names);
Names = Names(2:end,1);
data_count = length(Names);
N = data_count;

for i = 1:data_count
	name_tmp = char(Names(i,1));
	name_tmp_idx = strfind(name_tmp, '"');
	sample{i,:} = name_tmp(1,(name_tmp_idx(1,1)+1):(name_tmp_idx(1,2)-1));
	clear name_tmp name_tmp_idx
end



s = strfind(Data(69,1), 'FAR');
if isempty(s(cellfun('isempty',s(1,1)))) == 1
	FAR = 1;
	firstline = 73;
	IC = 0;
	cols = 12;
	%	set(H.mode, 'String', 'Faraday Acquisition')
end
if isempty(s(cellfun('isempty',s(1,1)))) == 0
	FAR = 0;
	IC = 1;
	cols = 10;
	firstline = 71;
	%	set(H.mode, 'String', 'Ion Counter Acquisition')
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

values_tmp = zeros(length(Data(firstline:end,1)),cols);
for j = 1:length(Data(firstline:end,1))
	values_all_cell = regexp(Data(j+firstline-1), ',', 'split');
	% patch for MATLAB versions earlier than 2018b, cell #11 has weirdness
	% with the 2021a update
	if verLessThan('matlab', '9.6') == 1 
		for k = 1:cols
			values_tmp(j,k) = str2num(cell2mat(values_all_cell{1,1}(1,k)));
		end
	else
		for k = 1:cols
			if k ~= 11
				values_tmp(j,k) = str2num(cell2mat(values_all_cell{1,1}(1,k)));
			end
		end
		values_tmp(j,11) = str2num(strrep(cell2mat(values_all_cell{1,1}(1,11)),'"',''));
	end
end

s = strfind(Data(69,1), 'FAR');
if isempty(s(cellfun('isempty',s(1,1)))) == 1
	FAR = 1;
	IC = 0;
	%	set(H.mode, 'String', 'Faraday Acquisition')
end
if isempty(s(cellfun('isempty',s(1,1)))) == 0
	FAR = 0;
	IC = 1;
	%	set(H.mode, 'String', 'Ion Counter Acquisition')
end

% Threshold 238
for i = 1:length(Data(firstline:end,1))
	if values_tmp(i,1) > -.004
		thresh238(i,1) = 1;
	else
		thresh238(i,1) = 0;
	end
end

for i = 2:length(Data(firstline:end,1))-2
	if thresh238(i,1) == 1 && thresh238(i-1) == 0 && values_tmp(i+1,1) > -.004 && values_tmp(i+2,1) > -.004 && values_tmp(i+3,1) > -.004 && values_tmp(i+4,1) > -.004 && ...
			values_tmp(i-1,1) < -.004 && values_tmp(i-2,1) < -.004 && values_tmp(i-3,1) < -.004 && values_tmp(i-4,1) < -.004
		
		t0_238(i,1) = values_tmp(i,cols-1);
		t0_idx(i,1) = values_tmp(i,cols-2);
	else
		t0_238(i,1) = 0;
	end
end

t0_238 = nonzeros(t0_238);
t0_idx = nonzeros(t0_idx);
diff_idx = diff(t0_idx);
diff_ch =  median(diff_idx) < diff_idx - 5;

%{
figure
hold on
plot(1:1:length(values_tmp(:,1)),values_tmp(:,1))
scatter(t0_idx,zeros(length(t0_idx),1),'filled')
hold off
%}




if length(t0_238) > data_count
	clear t0_238 t0_idx diff_idx diff_ch
	for i = 2:length(Data(73:end,1))-2
		if thresh238(i,1) == 1 && thresh238(i-1) == 0 && values_tmp(i+1,1) > -.004 && values_tmp(i+2,1) > -.004 && values_tmp(i+3,1) > -.004 && values_tmp(i+4,1) > -.004 && ...
				values_tmp(i-1,1) < -.004 && values_tmp(i-2,1) < -.004 && values_tmp(i-3,1) < -.004 && values_tmp(i-4,1) < -.004  && ...
				values_tmp(i-5,1) < -.004 && values_tmp(i-6,1) < -.004 && values_tmp(i-7,1) < -.004 && values_tmp(i-8,1) < -.004
			t0_238(i,1) = values_tmp(i,11);
			t0_idx(i,1) = values_tmp(i,10);
		else
			t0_238(i,1) = 0;
		end
	end
	t0_238 = nonzeros(t0_238);
	t0_idx = nonzeros(t0_idx);
	diff_idx = diff(t0_idx);
	diff_ch =  median(diff_idx) < diff_idx - 5;
end



if mean(diff(t0_idx)) > 140 && mean(diff(t0_idx)) < 160
	set(H.method,'Value',1)
	%	set(H.intg,'String','15 s')
elseif mean(diff(t0_idx)) > 50 && mean(diff(t0_idx)) < 70
	set(H.method,'Value',2)
	%	set(H.intg,'String','12 s')
	set(H.downhole,'Value',0)
elseif mean(diff(t0_idx)) > 25 && mean(diff(t0_idx)) < 40
	set(H.method,'Value',3)
	%	set(H.intg,'String','6 s')
	set(H.downhole,'Value',0)
elseif mean(diff(t0_idx)) > 5 && mean(diff(t0_idx)) < 25
	set(H.method,'Value',4)
	%	set(H.intg,'String','3 s')
	set(H.downhole,'Value',0)
end



















%T Zero Find by Medians
% Missing t0s (singles)
if get(H.tzero_method,'Value') == 1
	if data_count > length(t0_idx) && sum(diff_ch) > 0
		for i = 1:length(diff_ch)
			if mean(diff(t0_idx)) > 5 && mean(diff(t0_idx)) < 25
				adjstr = 1.5;
			else
				adjstr = 1.3;
			end
			if diff_ch(i,1) == 1 && diff_idx(i,1) > adjstr*median(diff_idx)
				t0_adj = t0_idx(1:i,1);
				t0_adj(i+1,1) = 0;
				t0_adj(i+2:i+2+length(t0_idx(i+2:end,1)),1) = t0_idx(i+1:end,1);
				t0_idx_bf = t0_adj(i,1);
				t0_idx_af = t0_adj(i+2,1);
				t0_adj(i+1,1) = round(t0_idx_bf + (t0_idx_af - t0_idx_bf)/2);
				t0_idx = t0_adj;
				diff_idx = diff(nonzeros(t0_adj));
				diff_ch =  median(diff_idx) < diff_idx - 5;
				clear t0_adj
			end
		end
		for i = 1:length(t0_idx)
			t0(i,1) = values_tmp(t0_idx(i,1),cols-1);
			t0_238(i,1) = values_tmp(t0_idx(i,1),cols-1);
		end
	else
		t0 = t0_238;
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
				diff_ch =  median(diff_idx) < diff_idx - 5;
				clear t0_adj
			end
		end
		for i = 1:length(t0_idx)
			t0(i,1) = values_tmp(t0_idx(i,1),cols-1);
			t0_238(i,1) = values_tmp(t0_idx(i,1),cols-1);
		end
	else
		t0 = t0_238;
	end
end

% T Zero Find by fractions
if get(H.tzero_method,'Value') == 2
	if data_count > length(t0_idx)
		if get(H.method,'Value') == 1 % 120/hour
			diff_idx_r = round(diff_idx/150)-1;
		elseif get(H.method,'Value') == 2 % 300/hour
			diff_idx_r = round(diff_idx/60)-1;
		elseif get(H.method,'Value') == 3 % 600/hour
			diff_idx_r = round(diff_idx/30)-1;
		elseif get(H.method,'Value') == 4 % 1200/hour
			diff_idx_r = round(diff_idx/15)-1;
		end
		for i = 1:data_count-1
			if diff_idx_r(i,1) > 0
				t0_adj = t0_idx(1:i,1);
				t0_adj(i+(diff_idx_r(i,1)+1):i+diff_idx_r(i,1)+length(t0_idx(i+1:end,1)),1) = t0_idx(i+1:end,1);
				t0_idx_bf = t0_adj(i,1);
				t0_idx_af = t0_adj(i+(diff_idx_r(i,1)+1),1);
				t0_idx_rnd = round((t0_idx_af - t0_idx_bf)/(diff_idx_r(i,1)+1));
				for j = 1:diff_idx_r(i,1)
					t0_adj(i+j,1) = t0_adj(i,1) + t0_idx_rnd*j;
				end
				t0_idx = t0_adj;
				clear t0_adj diff_idx_r diff_idx
				diff_idx = diff(t0_idx);
				if get(H.method,'Value') == 1 % 120/hour
					diff_idx_r = round(diff_idx/150)-1;
				elseif get(H.method,'Value') == 2 % 300/hour
					diff_idx_r = round(diff_idx/60)-1;
				elseif get(H.method,'Value') == 3 % 600/hour
					diff_idx_r = round(diff_idx/30)-1;
				elseif get(H.method,'Value') == 4 % 1200/hour
					diff_idx_r = round(diff_idx/15)-1;
				end
			end
		end
		for i = 1:length(t0_idx)
			t0(i,1) = values_tmp(t0_idx(i,1),cols-1);
			t0_238(i,1) = values_tmp(t0_idx(i,1),cols-1);
		end
	else
		t0 = t0_238;
	end
end




figure
hold on
plot(values_tmp(:,11),values_tmp(:,1),'b','Linewidth',1)
scatter(values_tmp(:,11),values_tmp(:,1),10,'filled','MarkerFaceColor','k')
scatter(t0_238,zeros(length(t0_238),1),'filled','MarkerFaceColor','r')
xlabel('Time (seconds)')
ylabel('238U Counts per Second (CPS)')
dim = [.2 .5 .3 .3];
str = strcat('sample n = ', {' '}, mat2str(data_count), {'   '}, 't zeros = ',{' '}, mat2str(length(t0_idx)))
annotation('textbox',dim,'String',str,'FitBoxToText','on');

if data_count == length(t0_idx)
	labelpoints (t0_238,zeros(length(t0_238),1), sample);
else
	labelpoints (t0_238,zeros(length(t0_238),1), [1:1:length(t0_238)]);
end






%{
figure
hold on
plot(1:1:length(values_tmp(:,1)),values_tmp(:,2))
scatter(t0_idx,zeros(length(t0_idx),1),'filled')
figure
hold on
plot(1:1:length(values_tmp(:,1)),values_tmp(:,4))
scatter(t0_idx,zeros(length(t0_idx),1),'filled')
figure
hold on
plot(1:1:length(values_tmp(:,1)),values_tmp(:,5))
scatter(t0_idx,zeros(length(t0_idx),1),'filled')
figure
hold on
plot(1:1:length(values_tmp(:,1)),values_tmp(:,6))
scatter(t0_idx,zeros(length(t0_idx),1),'filled')
figure
hold on
plot(1:1:length(values_tmp(:,1)),values_tmp(:,7))
scatter(t0_idx,zeros(length(t0_idx),1),'filled')
figure
hold on
scatter(t0_idx,zeros(length(t0_idx),1),'filled')
%}

to_idx_length = length(t0_idx)
data_count

function bestage_cutoff_Callback(hObject, eventdata, H)
function filter_err68_Callback(hObject, eventdata, H)
function filter_err67_Callback(hObject, eventdata, H)
function filter_cutoff_Callback(hObject, eventdata, H)
function filter_disc_rev_Callback(hObject, eventdata, H)
function filter_disc_Callback(hObject, eventdata, H)
function filter_204_Callback(hObject, eventdata, H)
function factor64_Callback(hObject, eventdata, H)

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
set(H.axes_session_fractionation,'box','on')
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
set(H.axes_session_fractionation,'box','on')
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
set(H.axes_session_fractionation,'box','on')
fill([(1:1:data_count)';flipud((1:1:data_count)')], [ffse82_hi; flipud(ffse82_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
plot([(1:1:data_count); (1:1:data_count)], [(stdfcsw82+stdfcsw82*0.02)'; (stdfcsw82-stdfcsw82*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',1) % Error bars
scatter(STD1_num, ff82_num, 75, 'b', 'filled','d')
axis([0 data_count+1 min([(stdfcsw82-stdfcsw82*0.02);ff82_num])-0.02*min([(stdfcsw82-stdfcsw82*0.02);ff82_num]) max([(stdfcsw82+stdfcsw82*0.02);ff82_num])+0.02*max([(stdfcsw82+stdfcsw82*0.02);ff82_num])])
hold off
%title('Pb208/Th232 Session drift')
xlabel('Analysis number')
ylabel('Pb208/Th232 fractionation factor')

function ptype_Primary_STDs_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 1)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Tertiary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)
%set(H.WM_STD2,'Visible','off')

sigx_sq_STD1 = H.sigx_sq_STD1;
rho_sigx_sigy_STD1 = H.rho_sigx_sigy_STD1;
sigy_sq_STD1 = H.sigy_sq_STD1;
sigmarule = H.sigmarule;
numpoints = H.numpoints;
center_STD1 = H.center_STD1;
STD1_68 = H.STD1_68;
STD1_67 = H.STD1_67;
STD1_idx = H.STD1_idx;
STD1_75 = H.STD1_75;
STD1age = H.STD1age;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;

%Primary standard
cla(H.axes_session,'reset');
axes(H.axes_session);
set(H.axes_session,'box','on')
%set(H.axes_session,'FontSize',8);
%set(H.primary_reference,'String',STD1);

for i = 1:length(sigx_sq_STD1)
	%if STD1_idx(i,1) == 1
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
	%end
end




age_label2_x = STD1_75;
age_label2_y = STD1_68;
age_label2 = {STD1age};




%{
%age_label2_x = 0.742701185586296;
age_label2_x = STD1_68*(1/STD1_67)*137.82;
%age_label2_y = 0.0912660713153783;
age_label2_y = STD1_68;

%if get(H.primary, 'Value') == 1
age_label2 = {'1087 Ma'};
%end
%}




plot(xc,yc,'k','LineWidth',1.4)
hold on
p1 = scatter(age_label2_x, age_label2_y,50,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
labelpoints (age_label2_x, age_label2_y, age_label2, 'SE', .002);

axis([min(min(nonzeros(elpt_STD1_out(:,1,:)))) - min(min(nonzeros(elpt_STD1_out(:,1,:))))*.01 max(max(elpt_STD1_out(:,1,:))) + max(max(elpt_STD1_out(:,1,:)))*.01 ...
	min(min(nonzeros(elpt_STD1_out(:,2,:)))) - min(min(nonzeros(elpt_STD1_out(:,2,:))))*.01 max(max(elpt_STD1_out(:,2,:))) + max(max(elpt_STD1_out(:,2,:)))*.01]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');

if get(H.leg_on_session,'Value') == 1
	legend(p1,'Accepted Age','Location','northwest');
else
	legend('hide')
end
function ptype_Secondary_STDs_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 1)
set(H.ptype_Tertiary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)
%set(H.WM_STD2,'Visible','on')

sigx_sq_STD2 = H.sigx_sq_STD2;
rho_sigx_sigy_STD2 = H.rho_sigx_sigy_STD2;
rho_sigx_sigy_STD2 = H.rho_sigx_sigy_STD2;
sigy_sq_STD2 = H.sigy_sq_STD2;
sigmarule = H.sigmarule;
numpoints = H.numpoints;
center_STD2 = H.center_STD2;
STD2_68 = H.STD2_68;
STD2_67 = H.STD2_67;
STD2_75 = H.STD2_75;
STD2age = H.STD2age;
STD2_idx = H.STD2_idx;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;


for i = 1:length(STD2_idx)
	if STD2_idx(i,1) == 1
		WM_Data(i,1:2) = cell2num([Best_Age(i,1),Best_Age_err(i,1)]);
	end
end
WM_Data = WM_Data(any(WM_Data ~= 0,2),:);

% if get(H.secondary,'Value') == 1
% 	WM_Data_hi = 419 + 419*str2num(get(H.percdev,'String'))*.01;
% 	WM_Data_lo = 419 - 419*str2num(get(H.percdev,'String'))*.01;
% end






if sum(STD2_idx) > 1
	cla(H.axes_session,'reset');
	axes(H.axes_session);
	set(H.axes_session,'box','on')
	%set(H.axes_session,'FontSize',8);
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
		%if WM_Data(i,1) < WM_Data_hi && WM_Data(i,1) > WM_Data_lo
			plot(elpt_STD2_out(:,1:2:end,i),elpt_STD2_out(:,2:2:end,i),'b','LineWidth',1.2);
		%else
		%	plot(elpt_STD2_out(:,1:2:end,i),elpt_STD2_out(:,2:2:end,i),'r','LineWidth',1.2);
		%	WM_Data(i,:) = [0,0];
		%end
		hold on
	end
	
	%WM_Data( ~any(WM_Data,2), : ) = [];  %rows
	
	
	
	
	
	age_label3_x = STD2_75;;
	age_label3_y = STD2_68;
	age_label3 = {STD2age};


	
	
	
	
	plot(xc,yc,'k','LineWidth',1.4)
	hold on
	p2 = scatter(age_label3_x, age_label3_y,40,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
	labelpoints (age_label3_x, age_label3_y, age_label3, 'SE', .002);
	
	axis([min(min(elpt_STD2_out(:,1,:))) - min(min(elpt_STD2_out(:,1,:)))*.01 max(max(elpt_STD2_out(:,1,:))) + max(max(elpt_STD2_out(:,1,:)))*.01 ...
		min(min(elpt_STD2_out(:,2,:))) - min(min(elpt_STD2_out(:,2,:)))*.01 max(max(elpt_STD2_out(:,2,:))) + max(max(elpt_STD2_out(:,2,:)))*.01]);
	xlabel('207Pb/235U');
	ylabel('206Pb/238U');
end

if get(H.leg_on_session,'Value') == 1
	legend([p2],'Accepted age','Location','northwest');
else
	legend('hide')
end
function ptype_Tertiary_STDs_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Tertiary_STDs, 'Value', 1)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)
%set(H.WM_STD2,'Visible','on')

sigx_sq_STD3 = H.sigx_sq_STD3;
rho_sigx_sigy_STD3 = H.rho_sigx_sigy_STD3;
rho_sigx_sigy_STD3 = H.rho_sigx_sigy_STD3;
sigy_sq_STD3 = H.sigy_sq_STD3;
sigmarule = H.sigmarule;
numpoints = H.numpoints;
center_STD3 = H.center_STD3;
STD3_68 = H.STD3_68;
STD3_67 = H.STD3_67;
STD3_75 = H.STD3_75;
STD3age = H.STD3age;
STD3_idx = H.STD3_idx;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;


for i = 1:length(STD3_idx)
	if STD3_idx(i,1) == 1
		WM_Data(i,1:2) = cell2num([Best_Age(i,1),Best_Age_err(i,1)]);
	end
end
WM_Data = WM_Data(any(WM_Data ~= 0,2),:);

% if get(H.secondary,'Value') == 1
% 	WM_Data_hi = 419 + 419*str2num(get(H.percdev,'String'))*.01;
% 	WM_Data_lo = 419 - 419*str2num(get(H.percdev,'String'))*.01;
% end






if sum(STD3_idx) > 1
	cla(H.axes_session,'reset');
	axes(H.axes_session);
	set(H.axes_session,'box','on')
	%set(H.axes_session,'FontSize',8);
	%set(H.secondary_reference,'String',STD3);
	
	for i = 1:length(sigx_sq_STD3)
		covmat_STD3=[sigx_sq_STD3(i,1),rho_sigx_sigy_STD3(i,1);rho_sigx_sigy_STD3(i,1),sigy_sq_STD3(i,1)];
		[PD_STD3,PV_STD3]=eig(covmat_STD3);
		PV_STD3 = diag(PV_STD3).^.5;
		theta_STD3 = linspace(0,2.*pi,numpoints)';
		elpt_STD3 = [cos(theta_STD3),sin(theta_STD3)]*diag(PV_STD3)*PD_STD3';
		numsigma = length(sigmarule);
		elpt_STD3 = repmat(elpt_STD3,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
		elpt_STD3_out(:,:,i) = elpt_STD3 + repmat(center_STD3(i,1:2),numpoints,numsigma);
		%if WM_Data(i,1) < WM_Data_hi && WM_Data(i,1) > WM_Data_lo
			plot(elpt_STD3_out(:,1:2:end,i),elpt_STD3_out(:,2:2:end,i),'b','LineWidth',1.2);
		%else
		%	plot(elpt_STD3_out(:,1:2:end,i),elpt_STD3_out(:,2:2:end,i),'r','LineWidth',1.2);
		%	WM_Data(i,:) = [0,0];
		%end
		hold on
	end
	
	%WM_Data( ~any(WM_Data,2), : ) = [];  %rows
	
	
	
	
	
	
	
	age_label3_x = STD3_75;
	age_label3_y = STD3_68;
	age_label3 = {STD3age};
	
	
	
	
	
	
	
	
	plot(xc,yc,'k','LineWidth',1.4)
	hold on
	p2 = scatter(age_label3_x, age_label3_y,40,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
	labelpoints (age_label3_x, age_label3_y, age_label3, 'SE', .002);
	
	axis([min(min(elpt_STD3_out(:,1,:))) - min(min(elpt_STD3_out(:,1,:)))*.01 max(max(elpt_STD3_out(:,1,:))) + max(max(elpt_STD3_out(:,1,:)))*.01 ...
		min(min(elpt_STD3_out(:,2,:))) - min(min(elpt_STD3_out(:,2,:)))*.01 max(max(elpt_STD3_out(:,2,:))) + max(max(elpt_STD3_out(:,2,:)))*.01]);
	xlabel('207Pb/235U');
	ylabel('206Pb/238U');
end

function wmPrimary_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 1)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)
%set(H.WM_STD2,'Visible','off')

Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
STD1_idx = H.STD1_idx;
current_status_num = H.current_status_num;

%Secondary standard
cla(H.axes_session,'reset');
axes(H.axes_session);
set(H.axes_session,'box','on')
hold on

for i = 1:H.data_count
	if STD1_idx(i,1) == 1 && current_status_num(i,1) == 1
		dataW(i,1) = cell2num(Best_Age(i,1));
		dataW(i,2) = cell2num(Best_Age_err(i,1));
	else
		dataW(i,1) = 0;
		dataW(i,2) = 0;
	end
end


dataW = dataW(any(dataW ~= 0,2),:);

len = length(dataW(:,1));
x = 1:1:len;
xmin = 0; % make nice plots
xmax = len+1; % make nice plots

%if get(H.sety,'Value') == 0
ymin = min(dataW(:,1)-dataW(:,2)) - min(dataW(:,1)-dataW(:,2))*.05; % make nice plots
ymax = max(dataW(:,1)+dataW(:,2)) +  max(dataW(:,1)+dataW(:,2)).*.05; % make nice plots


t = sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))); % Weighted Mean

dataW2 = dataW;
dataW2(:,2) = dataW2(:,2).*2; % double the uncertainty to get the MSWD at 1 sigma.... THIS DOESN'T MAKE SENSE TO ME. SEEMS BACKWARDS!
s = 1/sqrt(sum(1./(dataW2(:,2).*dataW2(:,2)))); % SE
MSWD = 1/(length(dataW2(:,1))-1).*sum(((dataW2(:,1)- (sum(dataW2(:,1)./(dataW2(:,2).^2))/sum(1./(dataW2(:,2).^2))) ).^2)./((dataW2(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot

students_t = [12.71	4.303	3.182	2.776	2.571	2.447	2.365	2.306	2.262	2.228	2.201	2.179	2.16	2.145	2.131	2.12	2.11	2.101	2.093	2.086	2.08 ...
	2.074	2.069	2.064	2.06	2.056	2.052	2.048	2.045];

% 95% confidence interval using 2-sided Student's t
if length(dataW(:,1))-1 < 30
	conf95 = students_t(1,(length(dataW(:,1))-1)) * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 30 && length(dataW(:,1))-1 < 40
	conf95 = 2.042 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 40 && length(dataW(:,1))-1 < 50
	conf95 = 2.021 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 50 && length(dataW(:,1))-1 < 60
	conf95 = 2.009 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 60 && length(dataW(:,1))-1 < 80
	conf95 = 2.000 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 80 && length(dataW(:,1))-1 < 100
	conf95 = 1.99 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 100 && length(dataW(:,1))-1 < 120
	conf95 = 1.984 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 120
	conf95 = 1.96 * s/2 *  sqrt(MSWD);
end

y = conf95/sqrt(MSWD); %y at 2 sigma

z = y*sqrt(MSWD);

dispersion_1sig= std(dataW(:,1))*1.96/2;
dispersion_2sig= std(dataW(:,1))*1.96;

dispersion_perc_1sig = dispersion_1sig/mean(dataW(:,1))*100;
dispersion_perc_2sig = dispersion_2sig/mean(dataW(:,1))*100;

%if get(H.input1s, 'Value') == 1 && get(H.plot1s, 'Value') == 1
plot([x; x], [(dataW(:,1)+dataW(:,2))'; (dataW(:,1)-dataW(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5) % Error bars, much nicer than the errorbar function
plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
scatter(x, dataW(:,1), 75, 'b', 'filled','d')

plot([xmin; xmax], [t+s; t+s], '-r', 'Color', 'k', 'LineWidth',1)
plot([xmin; xmax], [t-s; t-s], '-r', 'Color', 'k', 'LineWidth',1)
hold off
%set(H.wm,'String',round(t,3))
%set(H.unc,'String',round(s,3))
%set(H.mswd,'String',round(MSWD,3))
axis([xmin xmax ymin ymax])



bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',t)}, {' ± '},  {sprintf('%.1f',s)}, {' Ma'}, {'   MSWD = '}, {sprintf('%.1f',MSWD)});

legend(bestage,  'Location', 'northwest');
function wmSecondary_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 1)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)
%set(H.WM_STD2,'Visible','off')

Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
STD2_idx = H.STD2_idx;
current_status_num = H.current_status_num;

%Secondary standard
cla(H.axes_session,'reset');
axes(H.axes_session);
set(H.axes_session,'box','on')
hold on

for i = 1:H.data_count
	if STD2_idx(i,1) == 1 && current_status_num(i,1) == 1
		dataW(i,1) = cell2num(Best_Age(i,1));
		dataW(i,2) = cell2num(Best_Age_err(i,1));
	else
		dataW(i,1) = 0;
		dataW(i,2) = 0;
	end
end


dataW = dataW(any(dataW ~= 0,2),:);

len = length(dataW(:,1));
x = 1:1:len;
xmin = 0; % make nice plots
xmax = len+1; % make nice plots

%if get(H.sety,'Value') == 0
ymin = min(dataW(:,1)-dataW(:,2)) - min(dataW(:,1)-dataW(:,2))*.05; % make nice plots
ymax = max(dataW(:,1)+dataW(:,2)) +  max(dataW(:,1)+dataW(:,2)).*.05; % make nice plots


t = sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))); % Weighted Mean

dataW2 = dataW;
dataW2(:,2) = dataW2(:,2).*2; % double the uncertainty to get the MSWD at 1 sigma.... THIS DOESN'T MAKE SENSE TO ME. SEEMS BACKWARDS!
s = 1/sqrt(sum(1./(dataW2(:,2).*dataW2(:,2)))); % SE
MSWD = 1/(length(dataW2(:,1))-1).*sum(((dataW2(:,1)- (sum(dataW2(:,1)./(dataW2(:,2).^2))/sum(1./(dataW2(:,2).^2))) ).^2)./((dataW2(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot

students_t = [12.71	4.303	3.182	2.776	2.571	2.447	2.365	2.306	2.262	2.228	2.201	2.179	2.16	2.145	2.131	2.12	2.11	2.101	2.093	2.086	2.08 ...
	2.074	2.069	2.064	2.06	2.056	2.052	2.048	2.045];

% % 95% confidence interval using 2-sided Student's t
% if length(dataW(:,1))-1 < 30
% 	conf95 = students_t(1,(length(dataW(:,1))-1)) * s/2 *  sqrt(MSWD);
% elseif length(dataW(:,1))-1 >= 30 && length(dataW(:,1))-1 < 40
% 	conf95 = 2.042 * s/2 *  sqrt(MSWD);
% elseif length(dataW(:,1))-1 >= 40 && length(dataW(:,1))-1 < 50
% 	conf95 = 2.021 * s/2 *  sqrt(MSWD);
% elseif length(dataW(:,1))-1 >= 50 && length(dataW(:,1))-1 < 60
% 	conf95 = 2.009 * s/2 *  sqrt(MSWD);
% elseif length(dataW(:,1))-1 >= 60 && length(dataW(:,1))-1 < 80
% 	conf95 = 2.000 * s/2 *  sqrt(MSWD);
% elseif length(dataW(:,1))-1 >= 80 && length(dataW(:,1))-1 < 100
% 	conf95 = 1.99 * s/2 *  sqrt(MSWD);
% elseif length(dataW(:,1))-1 >= 100 && length(dataW(:,1))-1 < 120
% 	conf95 = 1.984 * s/2 *  sqrt(MSWD);
% elseif length(dataW(:,1))-1 >= 120
% 	conf95 = 1.96 * s/2 *  sqrt(MSWD);
% end
% 
% y = conf95/sqrt(MSWD); %y at 2 sigma
% 
% z = y*sqrt(MSWD);

dispersion_1sig= std(dataW(:,1))*1.96/2;
dispersion_2sig= std(dataW(:,1))*1.96;

dispersion_perc_1sig = dispersion_1sig/mean(dataW(:,1))*100;
dispersion_perc_2sig = dispersion_2sig/mean(dataW(:,1))*100;

%if get(H.input1s, 'Value') == 1 && get(H.plot1s, 'Value') == 1
plot([x; x], [(dataW(:,1)+dataW(:,2))'; (dataW(:,1)-dataW(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5) % Error bars, much nicer than the errorbar function
plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
scatter(x, dataW(:,1), 75, 'b', 'filled','d')

plot([xmin; xmax], [t+s; t+s], '-r', 'Color', 'k', 'LineWidth',1)
plot([xmin; xmax], [t-s; t-s], '-r', 'Color', 'k', 'LineWidth',1)
hold off
%set(H.wm,'String',round(t,3))
%set(H.unc,'String',round(s,3))
%set(H.mswd,'String',round(MSWD,3))
axis([xmin xmax ymin ymax])



bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',t)}, {' ± '},  {sprintf('%.1f',s)}, {' Ma'}, {'   MSWD = '}, {sprintf('%.1f',MSWD)});

legend(bestage,  'Location', 'northwest');
function wmTertiary_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 1)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)


Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
STD3_idx = H.STD3_idx;
current_status_num = H.current_status_num;

%Secondary standard
cla(H.axes_session,'reset');
axes(H.axes_session);
set(H.axes_session,'box','on')
hold on

for i = 1:H.data_count
	if STD3_idx(i,1) == 1 && current_status_num(i,1) == 1
		dataW(i,1) = cell2num(Best_Age(i,1));
		dataW(i,2) = cell2num(Best_Age_err(i,1));
	else
		dataW(i,1) = 0;
		dataW(i,2) = 0;
	end
end


dataW = dataW(any(dataW ~= 0,2),:);

len = length(dataW(:,1));
x = 1:1:len;
xmin = 0; % make nice plots
xmax = len+1; % make nice plots

%if get(H.sety,'Value') == 0
ymin = min(dataW(:,1)-dataW(:,2)) - min(dataW(:,1)-dataW(:,2))*.05; % make nice plots
ymax = max(dataW(:,1)+dataW(:,2)) +  max(dataW(:,1)+dataW(:,2)).*.05; % make nice plots


t = sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))); % Weighted Mean

dataW2 = dataW;
dataW2(:,2) = dataW2(:,2).*2; % double the uncertainty to get the MSWD at 1 sigma.... THIS DOESN'T MAKE SENSE TO ME. SEEMS BACKWARDS!
s = 1/sqrt(sum(1./(dataW2(:,2).*dataW2(:,2)))); % SE
MSWD = 1/(length(dataW2(:,1))-1).*sum(((dataW2(:,1)- (sum(dataW2(:,1)./(dataW2(:,2).^2))/sum(1./(dataW2(:,2).^2))) ).^2)./((dataW2(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot

students_t = [12.71	4.303	3.182	2.776	2.571	2.447	2.365	2.306	2.262	2.228	2.201	2.179	2.16	2.145	2.131	2.12	2.11	2.101	2.093	2.086	2.08 ...
	2.074	2.069	2.064	2.06	2.056	2.052	2.048	2.045];

% 95% confidence interval using 2-sided Student's t
if length(dataW(:,1))-1 < 30
	conf95 = students_t(1,(length(dataW(:,1))-1)) * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 30 && length(dataW(:,1))-1 < 40
	conf95 = 2.042 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 40 && length(dataW(:,1))-1 < 50
	conf95 = 2.021 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 50 && length(dataW(:,1))-1 < 60
	conf95 = 2.009 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 60 && length(dataW(:,1))-1 < 80
	conf95 = 2.000 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 80 && length(dataW(:,1))-1 < 100
	conf95 = 1.99 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 100 && length(dataW(:,1))-1 < 120
	conf95 = 1.984 * s/2 *  sqrt(MSWD);
elseif length(dataW(:,1))-1 >= 120
	conf95 = 1.96 * s/2 *  sqrt(MSWD);
end

y = conf95/sqrt(MSWD); %y at 2 sigma

z = y*sqrt(MSWD);

dispersion_1sig= std(dataW(:,1))*1.96/2;
dispersion_2sig= std(dataW(:,1))*1.96;

dispersion_perc_1sig = dispersion_1sig/mean(dataW(:,1))*100;
dispersion_perc_2sig = dispersion_2sig/mean(dataW(:,1))*100;

%if get(H.input1s, 'Value') == 1 && get(H.plot1s, 'Value') == 1
plot([x; x], [(dataW(:,1)+dataW(:,2))'; (dataW(:,1)-dataW(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5) % Error bars, much nicer than the errorbar function
plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
scatter(x, dataW(:,1), 75, 'b', 'filled','d')

plot([xmin; xmax], [t+s; t+s], '-r', 'Color', 'k', 'LineWidth',1)
plot([xmin; xmax], [t-s; t-s], '-r', 'Color', 'k', 'LineWidth',1)
hold off
%set(H.wm,'String',round(t,3))
%set(H.unc,'String',round(s,3))
%set(H.mswd,'String',round(MSWD,3))
axis([xmin xmax ymin ymax])



bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',t)}, {' ± '},  {sprintf('%.1f',s)}, {' Ma'}, {'   MSWD = '}, {sprintf('%.1f',MSWD)});

legend(bestage,  'Location', 'northwest');

function ptype_Unknowns_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Tertiary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 1)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)
%set(H.WM_STD2,'Visible','off')

sample = H.sample;
%Data_All = H.Data_All;
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
%INT = H.INT;

name_idx = get(H.listbox1, 'Value');

axes(H.axes_session);
cla(H.axes_session,'reset');
%set(H.axes_session,'FontSize',8);
hold on
set(H.axes_session,'box','on')
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
xlabel('207Pb/235U');
ylabel('206Pb/238U');

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
function ptype_Unknowns_acc_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Tertiary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 1)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)
%set(H.WM_STD2,'Visible','off')

sample = H.sample;
%Data_All = H.Data_All;
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
%INT = H.INT;

name_idx = get(H.listbox1, 'Value');

axes(H.axes_session);
cla(H.axes_session,'reset');
set(H.axes_session,'box','on')
%set(H.axes_session,'FontSize',8);
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
xlabel('207Pb/235U');
ylabel('206Pb/238U');

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
function ptype_Unknowns_rej_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Tertiary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 1)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)
%set(H.WM_STD2,'Visible','off')

sample = H.sample;
%Data_All = H.Data_All;
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
%INT = H.INT;

name_idx = get(H.listbox1, 'Value');

axes(H.axes_session);
cla(H.axes_session,'reset');
%set(H.axes_session,'FontSize',8);
hold on
set(H.axes_session,'box','on')
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
xlabel('207Pb/235U');
ylabel('206Pb/238U');

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
function age_uconc_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Tertiary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 1)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)
%set(H.WM_STD2,'Visible','off')

Macro_1_2_Output = H.Macro_1_2_Output;

for i = 1:length(H.sample_idx)
	if sum(size(cell2mat(Macro_1_2_Output(i+1,37)))) > 0 && sum(size(cell2mat(Macro_1_2_Output(i+1,51)))) > 0 && H.sample_idx(i,1) == 1
		uconc(i,1) = cell2num(Macro_1_2_Output(i+1,51));
		bestage(i,1) = cell2num(Macro_1_2_Output(i+1,37));
	end
end

uconc(~isfinite(uconc))=0;
bestage(~isfinite(bestage))=0;

uconc = nonzeros(uconc);
bestage = nonzeros(bestage);
cla(H.axes_session,'reset');
axes(H.axes_session);

%set(H.axes_session,'FontSize',8);
set(H.axes_session,'box','on')
s1 = scatter(uconc, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('U ppm')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','northeast');
else
	legend('hide')
end
function age_raddos_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Tertiary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 1)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 0)
%set(H.WM_STD2,'Visible','off')

Macro_1_2_Output = H.Macro_1_2_Output;

for i = 1:length(H.sample_idx)
	if sum(size(cell2mat(Macro_1_2_Output(i+1,37)))) > 0 && sum(size(cell2mat(Macro_1_2_Output(i+1,51)))) > 0 && sum(size(cell2mat(Macro_1_2_Output(i+1,52)))) > 0 && H.sample_idx(i,1) == 1
		u(i,1) = cell2num(Macro_1_2_Output(i+1,51));
		th(i,1) = cell2num(Macro_1_2_Output(i+1,52));
		bestage(i,1) = cell2num(Macro_1_2_Output(i+1,37));
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
%set(H.axes_session,'FontSize',8);
set(H.axes_session,'box','on')
s1 = scatter(raddos, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('Radiation Dosage (alpha decays/µg)')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','southeast');
else
	legend('hide')
end
function age_uth_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Tertiary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 1)
set(H.age_concodance, 'Value', 0)

Macro_1_2_Output = H.Macro_1_2_Output;

for i = 1:length(H.sample_idx)
	if sum(size(cell2mat(Macro_1_2_Output(i+1,37)))) > 0 && sum(size(cell2mat(Macro_1_2_Output(i+1,55)))) > 0 && H.sample_idx(i,1) == 1
		uth(i,1) = cell2num(Macro_1_2_Output(i+1,55));
		bestage(i,1) = cell2num(Macro_1_2_Output(i+1,37));
	end
end

uth(~isfinite(uth))=0;
bestage(~isfinite(bestage))=0;

uth = nonzeros(uth);
bestage = nonzeros(bestage);

axes(H.axes_session);
cla(H.axes_session,'reset');
%set(H.axes_session,'FontSize',8);
set(H.axes_session,'box','on')
s1 = scatter(uth, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('U/Th')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','northeast');
else
	legend('hide')
end
function age_concodance_Callback(hObject, eventdata, H)
set(H.wmPrimary, 'Value', 0)
set(H.wmTertiary, 'Value', 0)
set(H.wmSecondary, 'Value', 0)
set(H.ptype_Primary_STDs, 'Value', 0)
set(H.ptype_Secondary_STDs, 'Value', 0)
set(H.ptype_Tertiary_STDs, 'Value', 0)
set(H.ptype_Unknowns, 'Value', 0)
set(H.ptype_Unknowns_acc, 'Value', 0)
set(H.ptype_Unknowns_rej, 'Value', 0)
%set(H.DHF_primary, 'Value', 0)
%set(H.DHF_unknown, 'Value', 0)
set(H.age_uconc, 'Value', 0)
set(H.age_raddos, 'Value', 0)
set(H.age_uth, 'Value', 0)
set(H.age_concodance, 'Value', 1)
%set(H.WM_STD2,'Visible','off')

Macro_1_2_Output = H.Macro_1_2_Output;

for i = 1:length(H.sample_idx)
	if sum(size(cell2mat(Macro_1_2_Output(i+1,33)))) > 0 && sum(size(cell2mat(Macro_1_2_Output(i+1,35)))) > 0 && sum(size(cell2mat(Macro_1_2_Output(i+1,37)))) > 0 && H.sample_idx(i,1) == 1
		age68(i,1) = cell2num(Macro_1_2_Output(i+1,33));
		age67(i,1) = cell2num(Macro_1_2_Output(i+1,35));
		bestage(i,1) = cell2num(Macro_1_2_Output(i+1,37));
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
%set(H.axes_session,'FontSize',8);
set(H.axes_session,'box','on')
s1 = scatter(concordance, bestage, 50, 'b', 'filled', 'd', 'LineWidth', 1.25);
xlabel('Concordance (%)')
ylabel('Best Age (Ma)')

if get(H.leg_on_session,'Value') == 1
	legend(s1,'Accepted Unknowns','Location','northwest');
else
	legend('hide')
end
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
%if get(H.DHF_primary, 'Value') == 1
%	DHF_primary_Callback(hObject, eventdata, H);
%end
%if get(H.DHF_unknown, 'Value') == 1
%	DHF_unknown_Callback(hObject, eventdata, H);
%end
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

%set(H.axes_current_concordia,'String',sample{name_idx,1});



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
xlabel('207Pb/235U');
ylabel('206Pb/238U');

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Best_Age{name_idx,1})}, {' ± '},  {sprintf('%.1f',Best_Age_err{name_idx,1})}, {' Ma'});
legend(p3, bestage,  'Location', 'northwest');
guidata(hObject,H);





%{
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
xlabel('207Pb/235U');
ylabel('206Pb/238U');

p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);

accan= 'Accepted Analyses';
rejan = 'Rejected Analyses';

legend([p1 p2 p3], [accan, rejan, bestage], 'Location','northwest');

end
%}







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
		xlabel('Age (Ma)')
		ylabel('Number')
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
			xlabel('Age (Ma)')
			ylabel('Probability')
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
		xlabel('Age (Ma)')
		ylabel('Probability')
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
		xlabel('Age (Ma)')
		ylabel('Probability')
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
			xlabel('Age (Ma)')
			ylabel('Number')
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
		xlabel('Age (Ma)')
		ylabel('Number')
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
			xlabel('Age (Ma)')
			ylabel('Number')
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
		xlabel('Age (Ma)')
		ylabel('Number')
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
		xlabel('Age (Ma)')
		ylabel('Probability')
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

function listbox1_Callback(hObject, eventdata, H)
sample = H.sample;
%Data_All = H.Data_All;
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
%IC = H.IC;

%values_tmp = H.values_tmp;

samp_length = H.samp_length;


%INT = H.INT;
axes(H.axes_session);


values_all = H.values_all;


name_idx = get(H.listbox1,'Value');

%for i=1:length(sample)
%name_char(i,1)=(sample(i,1));
%end

%values = Data_All(:,:,name_idx).*80000000;



values = values_all(:,1:9,name_idx);


%values = values_tmp(120:277,1:9).*80000000; % 1200
%values = values_tmp(123:276,1:9).*80000000; % 600
%values = values_tmp(251:400,1:9).*80000000; % 300
%values = values_tmp(53:202,1:9).*80000000; % 120

% Twice as long
%values = values_tmp(120:719+37,1:9).*80000000; % 1200
%values = values_tmp(123:722+19,1:9).*80000000; % 600
%values = values_tmp(251:850+9,1:9).*80000000; % 300
%values = values_tmp(53:652+3,1:9).*80000000; % 120 --> 600 idxs








values = values_all(1:end,1:9,name_idx);
values2 = values(any(values,2),:);

values2(:,10) = values2(:,4)./values2(:,9);
values2(:,11) = values2(:,4)./values2(:,5);
values2(:,12) = values2(:,6)./values2(:,7);


Ablate = values2(:,1);

samp_length = length(Ablate);


values2(isinf(values2)|isnan(values2)) = 1;

if get(H.log_scale, 'Value') == 1
	for i = 1:samp_length
		for j = 2:12
			if values2(i,j) <= 0
				values2(i,j) = 1;
			end
		end
	end
	plot_vals = log10(values2(:,2:12));
	plot_vals(~isfinite(plot_vals))=0;
end

if get(H.log_scale, 'Value') == 0
	plot_vals = values2(:,2:12);
end
















C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');
set(H.axes_current_intensities,'box','on')
%figure
%hold on
if get(H.thick_lines,'Value')==1
	thickness = 2;
else
	thickness = 0.5;
end

hold on

%if get(H.All_Standards,'Value')==1

%plot(Ablate,plot_vals(:,7),'linewidth', thickness,'color',C{1});
%end



%if IC == 1
%	set(H.chk_Hg202,'Value',0)
%end







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
if get(H.chk_U238,'Value')==1
	plot(Ablate,plot_vals(:,8),'linewidth', thickness, 'color',C{7});
end
if get(H.chk_Pb206_U238,'Value')==1
	hold on
	
	tbl68 = table(Ablate(5:20),plot_vals(5:20,9));
	mdl = fitlm(tbl68);
	plot(mdl);
	
	%plot(Ablate(5:20),plot_vals(5:20,9),'linewidth', thickness, 'color', 'k');
end
if get(H.chk_Pb206_Pb207,'Value')==1
	plot(Ablate,plot_vals(:,10),'linewidth', thickness, 'color', 'k');
end
if get(H.chk_Pb208_Th232,'Value')==1
	plot(Ablate,plot_vals(:,11),'linewidth', thickness, 'color', 'k');
end



if get(H.showint,'Value') == 1
	
	Uvals = plot_vals(str2num(get(H.intstart,'String')):str2num(get(H.intend,'String')),8);
	Pbvals = [plot_vals(str2num(get(H.intstart,'String')):str2num(get(H.intend,'String')),4) ; plot_vals(str2num(get(H.intstart,'String')):str2num(get(H.intend,'String')),5)];
	
	startidx = str2num(get(H.intstart,'String'));
	endidx = str2num(get(H.intend,'String'));
	
	base1s = str2num(get(H.base1start,'String'));
	base1e = str2num(get(H.base1end,'String'));

	base1vals = plot_vals(base1s:base1e,:);
	
	base2s = str2num(get(H.base2start,'String'));
	base2e = str2num(get(H.base2end,'String'));

	base2vals = plot_vals(base2s:base2e,:);	
	
	
	rectangle('Position',[Ablate(startidx) min(Pbvals) Ablate(endidx)-Ablate(startidx)  max(Uvals)-min(Pbvals)],'linewidth', 2)
	rectangle('Position',[Ablate(base1s) min(min(base1vals)) Ablate(base1e)-Ablate(base1s)  max(max(base1vals))-min(min(base1vals))],'linewidth', 2)
	rectangle('Position',[Ablate(base2s) min(min(base2vals)) Ablate(base2e)-Ablate(base2s)  max(max(base2vals))-min(min(base2vals))],'linewidth', 2)

end









%ylim([5 8])


hold off
%title('Sample intensity')
xlabel('Time (seconds)')
if get(H.log_scale, 'Value') == 1
	ylabel('Intensity (log10 cps)')
else
	ylabel('Intensity (cps)')
end
xlim([0.2 max(Ablate)])
%ylim([1 8])


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


if get(H.corr207,'Value') == 0
	
	cla(H.axes_current_concordia,'reset');
	%set(H.axes_current_concordia,'FontSize',8);
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
	xlabel('207Pb/235U');
	ylabel('206Pb/238U');
	
	p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
	
	if get(H.leg_on,'Value')==1
		legend(p3, bestage,  'Location', 'northwest');
	end
	
end




if get(H.corr207,'Value') == 1
	
	cla(H.axes_current_concordia,'reset');
	
	concordia_data = cell2num(H.Macro_1_2_Output(2:end,60:64));
	center = [concordia_data(:,1),concordia_data(:,3)];
	sigx_abs = concordia_data(:,1).*concordia_data(:,2).*0.01;
	sigy_abs = concordia_data(:,3).*concordia_data(:,4).*0.01;
	sigx_sq = sigx_abs.*sigx_abs;
	sigy_sq = sigy_abs.*sigy_abs;
	rho_sigx_sigy = sigx_abs.*sigy_abs.*rho(name_idx,1);
	
	data1 = concordia_data;
	
	timemin = 0;
	timemax = 4000000000;
	timeinterval = 50000;
	time = timemin:timeinterval:timemax;
	xC1 = exp(0.00000000098485.*time)-1;
	yC1 = exp(0.000000000155125.*time)-1;
	
	concint = 500; % in Myr
	
	agelabelmin = 0;
	agelabelint = concint*1000000;
	agelabelmax = 4000000000;
	age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
	age_label_x = exp(0.00000000098485.*age_label_num)-1;
	age_label_y = exp(0.000000000155125.*age_label_num)-1;
	
	for i=1:length(age_label_num)
		age_label(i,1) = {sprintf('%.0f',age_label_num(1,i)/1000000)};
		age_label2(i,1) = strcat(age_label(i,1),' Ma');
	end
	
	xCTW = 1./yC1;
	yCTW = xC1 .* 1./yC1 ./ 137.82;
	
	age_label_xTW = 1./age_label_y;
	age_label_yTW = age_label_x .* 1./age_label_y./ 137.82;
	
	for i = 1:length(data1(:,1))
		
		data2(i,1) = 1/data1(i,3);
		data2(i,2) = data1(i,4);
		data2(i,3) = data1(i,1)*data2(i,1)/137.82;
		data2(i,4) = data1(i,2);
		data2(i,5) = data1(i,5);
		
		m(i,1) = (0.836 - data2(i,3))/data2(i,1);
		x(i,1) = 0.836/m(i,1);
		anchors(:,:,i) = [0, 0.836; x(i,1), 0];
		[pY(i,:), S1(i,:)] = polyfit(anchors(:,1,i),anchors(:,2,i),1);
		Yf(:,i) = polyval(pY(i,:),xCTW');
		ydiff(:,i) = abs(Yf(:,i) - yCTW');
		[ymin1 yidx1(i,:)] = min(ydiff(:,i));
		interc1(i,:) = [xCTW(yidx1(i,:)),yCTW(yidx1(i,:))];
		
		Age68c(i,1) = log(1/interc1(i,1)+1)./0.000155125;
		%Age67(i,1) = MyAge76(interc1(:,2));
	end
	

	
	
	
	hold on
	
	
	center=[data2(:,1),data2(:,3)];
	rho = data2(:,5);
	sigx_abs = data2(:,1).*data2(:,2).*0.01;
	sigy_abs = data2(:,3).*data2(:,4).*0.01;
	sigx_sq = sigx_abs.*sigx_abs;
	sigy_sq = sigy_abs.*sigy_abs;
	rho_sigx_sigy = sigx_abs.*sigy_abs.*rho;
	numpoints=50;
	sigmarule1s=1.5;
	
	covmat=[sigx_sq(name_idx,1),rho_sigx_sigy(name_idx,1);rho_sigx_sigy(name_idx,1),sigy_sq(name_idx,1)];
	[PD,PV]=eig(covmat);
	PV=diag(PV).^.5;
	theta=linspace(0,2.*pi,numpoints)';
	elpt1s=[cos(theta),sin(theta)]*diag(PV)*PD';
	numsigma1s=length(sigmarule1s);
	elpt1s=repmat(elpt1s,1,numsigma1s).*repmat(sigmarule1s(floor(1:.5:numsigma1s+.5)),numpoints,1);
	elpt1s=elpt1s+repmat(center(name_idx,1:2),numpoints,numsigma1s);
	elpt1s_out(:,:,name_idx)=elpt1s+repmat(center(name_idx,1:2),numpoints,numsigma1s);
	plot(elpt1s(:,1:2:end),elpt1s(:,2:2:end),'b','LineWidth', 1);
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	plot(xCTW,yCTW)
	
	text(age_label_xTW+0.1, age_label_yTW,age_label2, 'FontWeight', 'bold')
	
	
	p3 = scatter(interc1(name_idx,1),interc1(name_idx,2), 75, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
	plot(anchors(:,1,name_idx), anchors(:,2,name_idx))
	if data2(name_idx,3) > 0.05
		axis([0 data2(name_idx,1)+10 0.05 data2(name_idx,3)+.1])
	else
		axis([0 data2(name_idx,1)+10 0 data2(name_idx,3)+.1])
	end
	
	for i = 1:length(age_label_num)
		scatter(age_label_xTW(1,i), age_label_yTW(1,i), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
	end

	
	%p3 = scatter(ratio75(name_idx,1), ratio68(name_idx,1), 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
	
	scatter(data2(name_idx,1),data2(name_idx,3),'filled')
	
	bestage = strcat('Best Age', {' = '}, {sprintf('%.1f',Age68c(name_idx,1))}, {' ± '},  {sprintf('%.1f',H.Age68_err{name_idx,1})}, {' Ma'});
	
	legend([p3], bestage,  'Location', 'northeast');

end























axes(H.axes_session);
set(H.axes_session,'box','on')
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
function log_scale_Callback(hObject, eventdata, H)
listbox1_Callback(hObject, eventdata, H)
function thick_lines_Callback(hObject, eventdata, H)
listbox1_Callback(hObject, eventdata, H)
function chk_Hg202_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)
function chk_Pb204_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)
function chk_Pb206_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)
function chk_Pb207_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)
function chk_Pb208_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)
function chk_Th232_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
	set(H.chk_Pb208_Th232,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)
function chk_U238_Callback(hObject, eventdata, H)
if get(H.chk_Hg202,'Value')==1 || get(H.chk_Pb204,'Value')==1 || get(H.chk_Pb206,'Value')==1 || get(H.chk_Pb207,'Value')==1 || get(H.chk_Pb208,'Value')==1 ...
		|| get(H.chk_Th232,'Value')==1 || get(H.chk_U238,'Value')==1
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
	set(H.chk_U238,'Value', 0);
	set(H.chk_Pb206_U238,'Value', 0);
	set(H.chk_Pb206_Pb207,'Value', 0);
end

listbox1_Callback(hObject, eventdata, H)
function leg_on_Callback(hObject, eventdata, H)

listbox1_Callback(hObject, eventdata, H)

function plot_distribution(hObject, eventdata, H)
%if H.reduced == 1
%	if H.export_dist == 1
%		figure;
%	end
%	if H.export_dist == 0
cla(H.axes_distribution, 'reset');
axes(H.axes_distribution);
%	end
%	H.export_dist = 0;
guidata(hObject,H);
hold on

% for i = 1:H.data_count
% 	if H.current_status_num(i,1) == 1 && H.sample_idx(i,1) == 1
% 		dist_data(i+1,1) = cell2num(H.SAMPLE_CONCORDIA(i+1,10));
% 		dist_data(i+1,2) = cell2num(H.SAMPLE_CONCORDIA(i+1,11));
% 		dist_data = dist_data(any(dist_data ~= 0,2),:);
% 	end
% end
% 
% for i = 1:length(dist_data(:,1))
% 	if dist_data(i,1) > str2double(get(H.xmin,'String')) && dist_data(i,1) < str2double(get(H.xmax,'String'))
% 		dist_data(i,:) = dist_data(i,:);
% 	else
% 		dist_data(i,1:2) = 0;
% 	end
% end






if get(H.plotSTDs,'Value') == 0
	
	for i = 1:H.data_count
		if H.current_status_num(i,1) == 1 && H.sample_idx(i,1) == 1
			dist_data(i+1,1) = cell2num(H.SAMPLE_CONCORDIA(i+1,10));
			dist_data(i+1,2) = cell2num(H.SAMPLE_CONCORDIA(i+1,11));
		end
	end
	
	for i = 1:length(dist_data(:,1))
		if isnan(dist_data(i,1)) == 1 || isnan(dist_data(i,2)) == 1
			dist_data(i,1:2) = [0,0];
		end
	end
	
end


if get(H.plotSTDs,'Value') == 1
	
	for i = 1:H.data_count
		if H.current_status_num(i,1) == 1 && H.sample_idx(i,1) == 0
			dist_data(i+1,1) = cell2num(H.Best_Age(i,:));
			dist_data(i+1,2) = cell2num(H.Best_Age_err(i,:));
		end
	end
	
	for i = 1:length(dist_data(:,1))
		if isnan(dist_data(i,1)) == 1 || isnan(dist_data(i,2)) == 1
			dist_data(i,1:2) = [0,0];
		end
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

function savesesh_Callback(hObject, eventdata, H)
[file,path] = uiputfile('*.mat','Save file');
save([path file],'H')
function loadsesh_Callback(hObject, eventdata, H)
[filename pathname] = uigetfile({'*'},'File Selector','MultiSelect','on');
fullpathname = strcat(pathname, filename);
load(fullpathname,'H')
close(AgeCalcML_Nu_TRA)

function export_detailed_Callback(hObject, eventdata, H)
Macro_1_2_Output = H.Macro_1_2_Output;

if get(H.corr207,'Value') == 1
	Age68c = num2cell(H.Age68c);
	Macro_1_2_Output(1,75) = {'207 corr'};
	Macro_1_2_Output(:,76) = Macro_1_2_Output(:,74);
	Macro_1_2_Output(2:length(Age68c)+1,75) = Age68c;
end

[file,path] = uiputfile('*.xls','Save file');
writetable(table(Macro_1_2_Output),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);
function export_summary_Callback(hObject, eventdata, H)
Macro_1_2_Output = H.Macro_1_2_Output(2:end,:);

current_status_num = H.current_status_num;
STD1_idx = H.STD1_idx;
sample_idx = H.sample_idx;
ffsw68 = H.ffsw68;
ffse68 = H.ffse68;
stdfcsw67 = H.stdfcsw67;
stdswse67 = H.stdswse67;
BLS_68_err = H.BLS_68_err;
BLS_67_err = H.BLS_67_err;
%pbcerr68 = H.pbcerr68;
%pbcerr67 = H.pbcerr67;
Age68 = H.Age68;
%systerr68 = H.systerr68;
%systerr67 = H.systerr67;



%{
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
	if STD1_idx(i,1) ~= 1 && BLS_67_err(i,1) < 20 && cell2num(Age68(i,1)) > 400
		syst_err_67(i,1) = sqrt(100*stdswse67(i,1)/stdfcsw67(i,1)*100*stdswse67(i,1)/stdfcsw67(i,1)+(pbcerr67(i,1))*(pbcerr67(i,1))+0.053*0.053+0.069*0.069+0.35*0.35);
	end
end

if length(syst_err_67) >= 126
	systerr67 = 2*mean(nonzeros(syst_err_67(1:126,1)));
else
	systerr67 = 2*mean(nonzeros(syst_err_67));
end

%}

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
%geochron_out(10,2) = num2cell(systerr68);
%geochron_out(11,2) = num2cell(systerr67);
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
function analysis_tools_Callback(hObject, eventdata, H)





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
	
	age_label3_x = 28.983;
	age_label3_y = 0.703433333;
	age_label3 = {'3465.4 Ma'};
	
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
		xlabel('Age (Ma)')
		ylabel('Number')
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
			xlabel('Age (Ma)')
			ylabel('Probability')
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
		xlabel('Age (Ma)')
		ylabel('Probability')
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
		xlabel('Age (Ma)')
		ylabel('Probability')
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
			xlabel('Age (Ma)')
			ylabel('Number')
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
		xlabel('Age (Ma)')
		ylabel('Number')
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
			xlabel('Age (Ma)')
			ylabel('Number')
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
		xlabel('Age (Ma)')
		ylabel('Number')
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
		xlabel('Age (Ma)')
		ylabel('Probability')
	end
	
	hold off
	
end

export_fig([path file], fignew, '-pdf', '-append');
delete(fignew);

function export_plot_fractionation_Callback(hObject, eventdata, H)
f = figure;
copyobj(H.axes_session_fractionation,f);
function export_plot_session_Callback(hObject, eventdata, H)
f1 = figure;
copyobj(H.axes_session,f1);
function export_plot_intensities_Callback(hObject, eventdata, H)
f2 = figure;
copyobj(H.axes_current_intensities,f2);
function export_plot_conc_Callback(hObject, eventdata, H)
f3 = figure;
copyobj(H.axes_current_concordia,f3);
function export_plot_distribution_Callback(hObject, eventdata, H)
f4 = figure;
copyobj(H.axes_distribution,f4);

function batches_Callback(hObject, eventdata, H)

function batch_num_Callback(hObject, eventdata, H)

function tzero_method_Callback(hObject, eventdata, H)

function Ufilt_Callback(hObject, eventdata, H)

function largenigneous_Callback(hObject, eventdata, H)

function igrun_Callback(hObject, eventdata, H)

function corr208_Callback(hObject, eventdata, H)

function corr207_Callback(hObject, eventdata, H)

function STD_R_Callback(hObject, eventdata, H)

function totalcounts_Callback(hObject, eventdata, H)
set(H.totalcounts,'Value',1)
set(H.meanratios,'Value',0)
set(H.logratios,'Value',0)

function meanratios_Callback(hObject, eventdata, H)
set(H.totalcounts,'Value',0)
set(H.meanratios,'Value',1)
set(H.logratios,'Value',0)

function logratios_Callback(hObject, eventdata, H)
set(H.totalcounts,'Value',0)
set(H.meanratios,'Value',0)
set(H.logratios,'Value',1)

function use235_Callback(hObject, eventdata, H)






function plotSTDs_Callback(hObject, eventdata, H)


function showint_Callback(hObject, eventdata, H)
if get(H.showint,'Value') == 0
	set(H.intstart,'Visible','Off')
	set(H.intstartt,'Visible','Off')
	set(H.intend,'Visible','Off')
	set(H.intendt,'Visible','Off')	
	set(H.base1start,'Visible','Off')
	set(H.base1startt,'Visible','Off')
	set(H.base1end,'Visible','Off')
	set(H.base1endt,'Visible','Off')	
	set(H.base2start,'Visible','Off')
	set(H.base2startt,'Visible','Off')
	set(H.base2end,'Visible','Off')
	set(H.base2endt,'Visible','Off')
end
if get(H.showint,'Value') == 1
	set(H.intend,'Visible','On')
	set(H.intendt,'Visible','On')
	set(H.intstart,'Visible','On')
	set(H.intstartt,'Visible','On')
	set(H.base1start,'Visible','On')
	set(H.base1startt,'Visible','On')
	set(H.base1end,'Visible','On')
	set(H.base1endt,'Visible','On')	
	set(H.base2start,'Visible','On')
	set(H.base2startt,'Visible','On')
	set(H.base2end,'Visible','On')
	set(H.base2endt,'Visible','On')
end
listbox1_Callback(hObject, eventdata, H)

function intend_Callback(hObject, eventdata, H)


function intstart_Callback(hObject, eventdata, H)




function base1end_Callback(hObject, eventdata, H)




function base1start_Callback(hObject, eventdata, H)



function base2end_Callback(hObject, eventdata, H)



function base2start_Callback(hObject, eventdata, H)
