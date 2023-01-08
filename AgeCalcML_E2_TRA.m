%% AGECALCML_E2_TRA MATLAB code

% GG Mods:
% revised loop to find Tzero. Sets Tzero at 56 rows from previous if no signal. Adds default values for missing analyses.
% added variable to set intensity needed to identify Tzero
% added variable to set max 204 intensity for rejected analysis
% added variable to set max signal instability for rejected analysis
% uses 235 rather than 238 (modified lowint and lin factors to 235)
% uses 56 rows rather then 73 rows
% uses 1 integrations rather than 4 integrations
% removed all deadtime corrections
% values for each analysis are in AnalysisValues Array
% values used for total counts are in PeakValues array (values are background, common-Pb, and fractionation corrected)
% revised lowint and lin corrections to correct values
% removed duplicate overdispersion factors from 206/238 and 206/207
% added fifth term for long-term variance for 68, 67, and 82 systematic uncertainties
% lab-specific variables now all set in first two modules
% revised Detailed and Geochron output tables so all at 2-sigma
% revised Geochron Output Table so that it has all variables
% added AnalysisValues and PeakValues output tables to visualize backgrounds, Tzero, and Peak Values
% removed all TREE calc and plots
% removed calcs to optimize offsets of 68, 67, and 82
% removed 3D Concordia plots
% removed code for AutoReduce and Re-Reduce. Now only one set of calculations
% revised info and accept/reject capabilities in listbox
% revised comments to reflect Operator accept/reject
% added output boxes on interface with info about # rejected for each criteria
% added FC-SL-R33 to a single Concordia plot
% added young/log concordia plot to help set 64factor
% all concordia plots are at 1-sigma
% added WM ages of 68, 67, and 82 for FC, SL, and R33 to help set 64 factor and offset plots
% added FFsw68init to Fract plot for 206/238. Helps evaluate impact of changes
% added info to accept/reject status in Listbox (yellow = rejected standards, black = bad analyses)
% changed all 137.8x to 137.818, and uses MyAge76 (not MyAge&6_E2)
% added capabilites for 208/232 (e.g., fract plot, offset plot, systematic uncertainty, weighted mean ages)
% added 206/238 vs 208/232 plot. Uses 206/207 for correlation coefficient calc (should use 206/208 and 232/235?)
% added button to export all plots. Saved in pdf format back in data folder. Also shows plots to save in other formats
% removed buttons and calculations for Save Session, Save All, Import Session. Need to re-reduce each time.
% replaced fitlm with polyfit and polyval (for 68 and 82 uncertainty). Runs faster, no need for stats add-on


%% SET DEFAULT COMMAND LINE AND HANDLE STRUCTURE %%
function varargout = AgeCalcML_E2_TRA(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@AgeCalcML_E2_TRA_OpeningFcn,'gui_OutputFcn',@AgeCalcML_E2_TRA_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:}); % This creates the GUI from AgeCalcML_E2_TRA.fig (created in GUIDE)
end

function AgeCalcML_E2_TRA_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
guidata(hObject, H);

function varargout = AgeCalcML_E2_TRA_OutputFcn(hObject, eventdata, H) % this creates the gui from AgeCalcML_E2_TRA.fig
varargout{1} = H.output;

set(H.plot_fract_68,'Value',1);
H.reduced = 0;
plottype_Callback(hObject, eventdata, H)
H.export_fract = 0;
H.export_comp = 0;
H.export_dist = 0;
H.point = 0;
%H.locate_STD = 1;

use_avg_ACF = 1;
use_FC_68 = 1;
use_FC_67 = 1;
Use_SL_68 = 1;
Use_SL_67 = 1;
Use_R33_68 = 1;
TzeroPrev = 0;
TzeroEmptyScan = 0;
lowint_238 = 0.5*100-50; %slider val
lin_238 = 0.5*100-50; %slider val
lowint_206 = 0.5*100-50; %slider val
lin_206 = 0.5*100-50; %slider val
lowint_232 = 0.5*100-50; %slider val
lin_232 = 0.5*100-50; %slider val

set(H.slider_lowint_238,'Value',((lowint_238+50)/100)); %slider val
set(H.slider_lin_238,'Value',((lin_238+50)/100)); %slider val
set(H.slider_lowint_206,'Value',((lowint_206+50)/100)); %slider val
set(H.slider_lin_206,'Value',((lin_206+50)/100)); %slider val
set(H.slider_lowint_232,'Value',((lowint_232+50)/100)); %slider val
set(H.slider_lin_232,'Value',((lin_232+50)/100)); %slider val

set(H.lowint_val_238,'String',lowint_238);
set(H.lin_val_238,'String',lin_238);
set(H.lowint_val_206,'String',lowint_206);
set(H.lin_val_206,'String',lin_206);
set(H.lowint_val_232,'String',lowint_232);
set(H.lin_val_232,'String',lin_232);

set(H.Use_SL_68, 'Value',Use_SL_68); % checkbox
set(H.Use_SL_67, 'Value',Use_SL_67); % checkbox
set(H.Use_R33_68, 'Value',Use_R33_68); % checkbox

cla(H.axes_session_fractionation,'reset');
cla(H.axes_comp,'reset');
cla(H.axes_current_intensities,'reset');
cla(H.axes_current_concordia,'reset');
cla(H.axes_distribution,'reset');
set(H.listbox1,'String','');
set(H.status,'String','');

set(H.plot_fract_68,'Value',1);

set(H.comment1_sum_unk, 'Value',0);
set(H.comment1_sum_std, 'Value',0);
set(H.comment2_sum_unk, 'Value',0);
set(H.comment2_sum_std, 'Value',0);
set(H.comment3_sum_unk, 'Value',0);
set(H.comment3_sum_std, 'Value',0);
set(H.comment4_sum_unk, 'Value',0);
set(H.comment4_sum_std, 'Value',0);
set(H.comment5_sum_unk, 'Value',0);
set(H.comment5_sum_std, 'Value',0);
set(H.comment6_sum_unk, 'Value',0);
set(H.comment6_sum_std, 'Value',0);
set(H.comment7_sum_unk, 'Value',0);
set(H.comment7_sum_std, 'Value',0);
set(H.comment8_sum_unk, 'Value',0);
set(H.comment8_sum_std, 'Value',0);
set(H.comment9_sum_unk, 'Value',0);
set(H.comment9_sum_std, 'Value',0);
set(H.comment10_sum_std, 'Value',0);
set(H.comment11_sum_std, 'Value',0);

set(H.all_standards,'String','0'); % was 0
set(H.all_unknowns,'String','0'); % was 0
set(H.rejected_unk_sum,'String','0'); % was 0
set(H.rejected_std_sum,'String','0'); % was 0
set(H.StdErr68,'String','0'); % was 0 - syst err
set(H.StdErr67,'String','0'); % was 0 - syst err
set(H.StdErr82,'String','0'); % was 0 - syst err

guidata(hObject,H);

function browser_Callback(hObject, eventdata, H) %This is the callback for Select Input
folder_name = uigetdir; %prompt browser and select folder
set(H.filepath, 'String', folder_name); %show path name
H.folder_name = folder_name;
guidata(hObject,H);

set(H.browser,'Enable','on');
set(H.reduce_data,'Enable','on');
timerout = timerfindall;
delete(timerout);

import_data_Callback(hObject, eventdata, H)


%% BUTTON TO IMPORT DATA %%

function import_data_Callback(hObject, eventdata, H)
H.reduced = 0;
guidata(hObject,H);
folder_name = H.folder_name;
files=dir([folder_name]); %map out the directory to the folder specified in the GUI window

waitnum = 3;
h = waitbar(0,'Import U-Th-Pb data');

% specifies files and filenames (from GUI input)

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
H.fullpathname_names = fullpathname_names;

clear tmp tmp1

[numbers text, data] = xlsread(fullpathname_data); % numbers is array with all values from xls file.

set(H.plot_fract_68,'Value',1)
set(H.plot_fract_76,'Value',0)
set(H.plot_fract_82,'Value',0)
%set(H.export_fractionation,'Visible','on')

waitbar(1/waitnum, h, 'Import U-Th-Pb data'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

FCstd = 'FC';
SLstd = 'SL';
R33std = 'R33';

%% Import U-Th-Pb data

waitbar(2/waitnum, h, 'Import U-Th-Pb data'); %%%%%%%%%%%%%%%%%%

Names = importdata(fullpathname_names);     % Names = list of analysis names from scanlist
Names = Names(2:end,1);
NumAnalyses = length(Names);     % datacount = number of analyses
NumScans = length(numbers(:,1));  % NumScans set from # rows in xls file NumAnalyses*57;

for i = 1:NumAnalyses     % sample = array with analysis names
    name_tmp = char(Names(i,1));
    name_tmp_idx = strfind(name_tmp, '"');
    sample{i,:} = name_tmp(1,(name_tmp_idx(1,1)+1):(name_tmp_idx(1,2)-1));
    clear name_tmp name_tmp_idx
end

sample2 = sample;

H.current_status_num_operator_reject = zeros(NumScans,1);
H.current_status_num_operator_accept = zeros(NumScans,1);
FCstd_idx = strfind(sample, FCstd);
SLstd_idx = strfind(sample, SLstd);
R33std_idx = strfind(sample, R33std);
FCstd_idx = abs(cellfun(@isempty,FCstd_idx)-1);
SLstd_idx = abs(cellfun(@isempty,SLstd_idx)-1);
R33std_idx = abs(cellfun(@isempty,R33std_idx)-1);

sample_idx = abs((FCstd_idx + SLstd_idx + R33std_idx) - 1);

Scan = numbers(:,1);     % Scan = array with row number in csv file **********
Time = numbers(:,2) - numbers(1,2);     % Time = array with time stamp from column 2 in csv file **********
ACF = numbers(:,3)./64;     % ACF = array with ACF values from column 3 in csv file **********

M202ap = zeros(NumScans,1);     % M202ap = array with 202 values from column 4 of csv file **********
for i = 1:NumScans    % uses pulse mode unless * present **********
    if isnan(numbers(i,5)) == 1
        M202ap(i,1) = 10000000000;
    elseif isnan(numbers(i,4)) == 1
        M202ap(i,1) = numbers(i,5)*ACF(i,1);
    elseif numbers(i,4) == 0 && numbers(i,4) > 2000
        M202ap(i,1) = numbers(i,5)*ACF(i,1);
    elseif isnan(numbers(i,4)) == 1
        tmp = regexp(data(i+1,4),'\d*','Match');
        M202ap(i,1) = str2double(cell2mat(tmp{1,1}));
        clear tmp
    else
        M202ap(i,1) = numbers(i,4);
    end
end

M204ap = zeros(NumScans,1);  % M204ap = array with 204 values from column 7 of csv file **********
for i = 1:NumScans
    if isnan(numbers(i,8)) == 1
        M204ap(i,1) = 10000000000;
    elseif isnan(numbers(i,7)) == 1
        M204ap(i,1) = numbers(i,8)*ACF(i,1);
    elseif numbers(i,7) == 0 && numbers(i,7) > 2000
        M204ap(i,1) = numbers(i,8)*ACF(i,1);
    elseif isnan(numbers(i,7)) == 1
        tmp = regexp(data(i+1,7),'\d*','Match');
        M204ap(i,1) = str2double(cell2mat(tmp{1,1}));
        clear tmp
    else
        M204ap(i,1) = numbers(i,7);
    end
end

M206ap = zeros(NumScans,1);  % M206ap = array with 206 values from column 10 of csv file **********
for i = 1:NumScans
    if isnan(numbers(i,10)) == 1
        M206ap(i,1) = numbers(i,11).*ACF(i,1);
    elseif numbers(i,10) == 0 && numbers(i,11) > 2000
        M206ap(i,1) = numbers(i,11).*ACF(i,1);
    else
        M206ap(i,1) = numbers(i,10);
    end
end

M207ap = zeros(NumScans,1);  % M207ap = array with 207 values from column 13 of csv file **********
for i = 1:NumScans
    if isnan(numbers(i,13)) == 1
        M207ap(i,1) = numbers(i,14).*ACF(i,1);
    elseif numbers(i,13) == 0 && numbers(i,14) > 2000
        M207ap(i,1) = numbers(i,14).*ACF(i,1);
    else
        M207ap(i,1) = numbers(i,13);
    end
end

M208ap = zeros(NumScans,1);  % M208ap = array with 208 values from column 16 of csv file **********
for i = 1:NumScans
    if isnan(numbers(i,16)) == 1
        M208ap(i,1) = numbers(i,17).*ACF(i,1);
    elseif numbers(i,16) == 0 && numbers(i,17) > 2000
        M208ap(i,1) = numbers(i,17).*ACF(i,1);
    else
        M208ap(i,1) = numbers(i,16);
    end
end

M232ap = zeros(NumScans,1);  % M232ap = array with 232 values from column 19 of csv file **********
for i = 1:NumScans
    if isnan(numbers(i,19)) == 1
        M232ap(i,1) = numbers(i,20).*ACF(i,1);
    elseif numbers(i,19) == 0 && numbers(i,20) > 2000
        M232ap(i,1) = numbers(i,20).*ACF(i,1);
    else
        M232ap(i,1) = numbers(i,19);
    end
end

M235ap = zeros(NumScans,1);  % M235ap = array with 235 values from column 22 of csv file **********
for i = 1:NumScans
    if isnan(numbers(i,22)) == 1
        M235ap(i,1) = numbers(i,23).*ACF(i,1);
    elseif numbers(i,22) == 0 && numbers(i,23) > 2000
        M235ap(i,1) = numbers(i,23).*ACF(i,1);
    else
        M235ap(i,1) = numbers(i,22);
    end
end

M238ap = M235ap.*137.818;     % creates array for 238 values from 235 * 137.818 **********

H.NumAnalyses=NumAnalyses;
H.NumScans=NumScans;
H.sample=sample;
H.sample2=sample2;
H.sample_idx = sample_idx;
H.FCstd_idx = FCstd_idx;
H.SLstd_idx = SLstd_idx;
H.R33std_idx = R33std_idx;
H.M202ap=M202ap; H.M204ap=M204ap; H.M206ap=M206ap; H.M207ap=M207ap; H.M208ap=M208ap; H.M232ap=M232ap; H.M235ap=M235ap; H.M238ap=M238ap;

close(h)

reduce_data_Callback(hObject, eventdata, H)

%% Calculate U-Th-Pb intensities

function reduce_data_Callback(hObject, eventdata, H) %runs to line 1800

waitnum = 5;
h = waitbar(0,'Calculate Intensities'); %%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

bestage_cutoff = str2num(get(H.bestage_cutoff,'String')); % populates settings from GUI input values
filter_err68 = str2num(get(H.filter_err68,'String'));
filter_err67 = str2num(get(H.filter_err67,'String'));
filter_cutoff = str2num(get(H.filter_cutoff,'String')); %min age for discordance filter
filter_204 = str2num(get(H.filter_204,'String'));
factor64 = str2num(get(H.factor64,'String'));
filter_235 = str2num(get(H.filter_235,'String'));
filter_disc = str2num(get(H.filter_disc,'String'));
filter_disc_rev = str2num(get(H.filter_disc_rev,'String'));
peakoffsetcutoff = str2num(get(H.peakoffsetcutoff,'String'));

lowint_238 = get(H.slider_lowint_238,'Value')*100-50; %slider val
lin_238 = get(H.slider_lin_238,'Value')*100-50; %slider val
lowint_206 = get(H.slider_lowint_206,'Value')*100-50; %slider val
lin_206 = get(H.slider_lin_206,'Value')*100-50; %slider val
lowint_232 = get(H.slider_lowint_232,'Value')*100-50; %slider val
lin_232 = get(H.slider_lin_232,'Value')*100-50; %slider val
lowint68 = (lowint_238 + 50)*0.1-5;
lin68 = (lin_238 + 50)*0.1-5;
lowint67 = -(lowint_206+50)*0.005+0.25;
lin67 = -(lin_206 + 50)*0.0005+0.025;
lowint82 = (lowint_232 + 50)*0.1-5;
lin82 = (lin_232 + 50)*0.1-5;

H.STD_FC_68 = 0.18588;
H.STD_FC_67  = 13.132;
H.STD_FC_82  = 0.05588;
H.STD_FC_64c = 16.882;
H.STD_FC_67c = 15.463;
H.STD_FC_68c = 36.533;
H.STD_FC_Uppm = 457;
H.STD_FC_Thppm = 271;
H.STD_FC_68age = 1099.017663;
H.STD_FC_67age = 1098.138545;
H.STD_FC_82age = 1099;
H.STD_FC_82age = 1099;

% SL
H.STD_SL_68 = 0.09042;
H.STD_SL_67  = 17.02;
H.STD_SL_82  = 0.0283;
H.STD_SL_64c = 17.827;
H.STD_SL_67c = 15.549;
H.STD_SL_68c = 37.576;
H.STD_SL_Uppm = 518;
H.STD_SL_Thppm = 118;
H.STD_SL_68age = 558.0205842;
H.STD_SL_67age = 557.0746252;
H.STD_SL_82age = 558;
H.STD_SL_82age = 558;

% R33
H.STD_R33_68 = 0.06721;
H.STD_R33_67  = 18.124;
H.STD_R33_82  = 0.02096;
H.STD_R33_64c = 18.073;
H.STD_R33_67c = 15.574;
H.STD_R33_68c = 37.856;
H.STD_R33_Uppm = 175;
H.STD_R33_Thppm = 125;
H.STD_R33_68age = 419.3248442;
H.STD_R33_67age = 418.3465252;
H.STD_R33_82age = 419;
H.STD_R33_82age = 419;

rejectFC68 = str2num(get(H.reject_std_level_68,'String'));
rejectSL68 = str2num(get(H.reject_std_level_68,'String'));
rejectR3368 = str2num(get(H.reject_std_level_68,'String'));
rejectFC67 = str2num(get(H.reject_std_level_67,'String'));
rejectSL67 = str2num(get(H.reject_std_level_67,'String'));
rejectR3367 = str2num(get(H.reject_std_level_67,'String'));
reject82 = str2num(get(H.reject_std_level_68,'String'));

odf68 = 0.6; %overdispersion factor 6/8
odf67 = 0.8; %overdispersion factor 6/7
odf82 = 0.6; % overdispersion factor 8/2
DC238err = 0.053; % 1-sigma uncertainty of decay constant
FC68err = 0.20; % 1-sigma uncertainty in FC 206/238 age
LT68err = 0.20; % 1-sigma uncertainty of Long Term Variance in 206/238 (from Wang et al. 2022)
DC235err = 0.069; % 1-sigma uncertainty of decay constant
FC67err = 0.20; % 1-sigma uncertainty in FC 206/207 age
LT67err = 0.20; % 1-sigma uncertainty of Long Term Variance in 207/207 (from Wang et al. 2022)
DC232err = 0.5; % 1-sigma uncertainty of decay constant
FC82err = 0.50; % 1-sigma uncertainty in FC 206/238 age
LT82err = 0.50; % 1-sigma uncertainty of Long Term Variance in 206/238 (from Wang et al. 2022)

TzeroPrev = 1;

for i = 5:H.NumScans-1 % loop to find Tzero for each analysis
    if H.M235ap(i,1) < filter_235 && H.M235ap(i+1,1) > filter_235 && H.M235ap(i-1,1) < filter_235 && H.M235ap(i+2,1) > filter_235 && H.M235ap(i-2,1) < filter_235 && H.M235ap(i+3,1) > filter_235
        %if M238ap(i,1) < 100000 && M238ap(i+1,1) > 100000 && M238ap(i-1,1) < 100000 && M238ap(i+2,1) > 100000 && M238ap(i-2,1) < 100000 && M238ap(i+3,1) > 100000
        TzeroRow(i,1) = i;  % sets TzeroRow(i) value to rownumber if 3 rows of low-int followed by 3 rows of hi-int **********
        TzeroPrev = i;     % sets counter to i value
        i = i + 10;
    elseif i > TzeroPrev + 57     % sets Tzero if 56 rows past previous set (for empty analyses)
        TzeroRow(i,1) = i;
        TzeroPrev = i;
        H.M202ap(i-9:i,1) = 100; %these are values insterted for "bad" analyses
        H.M204ap(i-9:i,1) = 100;
        H.M206ap(i-9:i,1) = 100;
        H.M207ap(i-9:i,1) = 100;
        H.M208ap(i-9:i,1) = 100;
        H.M232ap(i-9:i,1) = 100;
        H.M235ap(i-9:i,1) = 100;
        H.M238ap(i-9:i,1) = 100;
        H.M202ap(i+1:i+32,1) = 200;
        H.M204ap(i+1:i+32,1) = 200;
        H.M206ap(i+1:i+32,1) = 100100;
        H.M207ap(i+1:i+32,1) = 100100;
        H.M208ap(i+1:i+32,1) = 100100;
        H.M232ap(i+1:i+32,1) = 100100;
        H.M235ap(i+1:i+32,1) = 100100;
        H.M238ap(i+1:i+32,1) = 100100;
        i = i + 10;
    else
        TzeroRow(i,1) = 0;
    end
end

TstartAnVal = TzeroRow(TzeroRow>0,1) - 10; % Row number for start of AnalysisValue Value array (10 before Tzero row number)
TendAnVal = TzeroRow(TzeroRow>0,1) + 45 + 4; % Row number for end of AnalysisValue array (45 + 8 rows after Tzero)

for i = 1:H.NumAnalyses
    AnalysisValues(1:60,1:8,i) = [H.M202ap(TstartAnVal(i,1):TendAnVal(i,1)), H.M204ap(TstartAnVal(i,1):TendAnVal(i,1)), H.M206ap(TstartAnVal(i,1):TendAnVal(i,1)), H.M207ap(TstartAnVal(i,1):TendAnVal(i,1)), ...
        H.M208ap(TstartAnVal(i,1):TendAnVal(i,1)), H.M232ap(TstartAnVal(i,1):TendAnVal(i,1)), H.M235ap(TstartAnVal(i,1):TendAnVal(i,1)), H.M238ap(TstartAnVal(i,1):TendAnVal(i,1))];
end
H.AnalysisValues=AnalysisValues;

PeakValues = zeros(46,15,H.NumAnalyses); %intensity of 46 rows on peaks (background subtracted)

BkgdValues = zeros(H.NumAnalyses,8); % average intensity of backgrounds (six values from #3-#8, minus max and min)

for i = 1:H.NumAnalyses % BkgdValues contains average background values for each analysis.
    for j = 1:8
        BkgdValues(i,j) = (sum(H.AnalysisValues(2:8,j,i))-max(H.AnalysisValues(2:8,j,i))-min(H.AnalysisValues(2:8,j,i)))/5; %uses five (seven-max-min)
    end
end

for i = 1:H.NumAnalyses % 202 intensity of 43 rows starting three before Tzero (background subtracted; uses mean of closest four values)
    for j = 1:43
        if mean(H.AnalysisValues(j+8:j+11,1,i))-BkgdValues(i,1) < 1 
            PeakValues(j,1,i) = 1;
        else
            PeakValues(j,1,i) = mean(H.AnalysisValues(j+8:j+11,1,i))-BkgdValues(i,1); % 202 from mean of 43 rows on peaks (minus mean of backgrounds)
        end
    end
end

for i = 1:H.NumAnalyses % 204 intensity of 43 rows starting three beforer Tzero (background and 204Hg corrected; uses mean of closest four values)
    for j = 1:43
        if mean(H.AnalysisValues(j+8:j+11,2,i)) - BkgdValues(i,2) - (PeakValues(j,1,i)/4.3) < 1 %was J10 and J13
            PeakValues(j,2,i) = 1;
        else
            PeakValues(j,2,i) = mean(H.AnalysisValues(j+8:j+11,2,i)) - BkgdValues(i,2) - (PeakValues(j,1,i)/4.3); %204
        end
    end
end

for i = 1:H.NumAnalyses % 206 intensity of 46 rows starting three before Tzero (background subtracted)
    for j = 1:46
        if H.AnalysisValues(j+8,3,i) - BkgdValues(i,3) < 1
            PeakValues(j,3,i) = 1;
        else
            PeakValues(j,3,i) = (H.AnalysisValues(j+8,3,i) - BkgdValues(i,3));
        end
    end
end

for i = 1:H.NumAnalyses % 207 intensity of 46 rows starting three before Tzero (background subtracted; corrected for lin and lowint factors) *****
    for j = 1:46
        if H.AnalysisValues(j+8,4,i) - BkgdValues(i,4) < 1 % was j+10
            PeakValues(j,4,i) = 1;
        else
            PeakValues(j,4,i) = (H.AnalysisValues(j+8,4,i)-BkgdValues(i,4))*(1 - lowint67*exp(-1*(H.AnalysisValues(j+8,4,i)-BkgdValues(i,4))/10000) - lin67*(H.AnalysisValues(j+8,4,i)-BkgdValues(i,4))/10000); % 207

        end
    end
end

for i = 1:H.NumAnalyses % 208 intensity of 46 rows starting three before Tzero (background subtracted)
    for j = 1:46
        if H.AnalysisValues(j+8,5,i) - BkgdValues(i,5) < 1 % was j+10
            PeakValues(j,5,i) = 1;
        else
            PeakValues(j,5,i) = (H.AnalysisValues(j+8,5,i)-BkgdValues(i,5));
        end
    end
end

for i = 1:H.NumAnalyses % 232 intensity of 46 rows starting three before Tzero (background subtracted)
    for j = 1:46
        if H.AnalysisValues(j+8,6,i) - BkgdValues(i,6) < 1
            PeakValues(j,6,i) = 1;
        else
            PeakValues(j,6,i) = (H.AnalysisValues(j+8,6,i)-BkgdValues(i,6));
        end
    end
end
for i = 1:H.NumAnalyses % 232* intensity of 46 rows starting three before Tzero (background subtracted)
    for j = 1:46
        PeakValues(j,6,i) = (PeakValues(j,6,i))*(1 - 0.3*lin82*((PeakValues(j,6,i))^1.5)/100000000000 - 0.2*lowint82*exp(-0.000001*(PeakValues(j,6,i))));
    end
end

for i = 1:H.NumAnalyses % 235 intensity of 46 rows starting three before Tzero (background subtracted)
    for j = 1:46
        if H.AnalysisValues(j+8,7,i) - BkgdValues(i,7) < 1
            PeakValues(j,7,i) = 1;
        else
            PeakValues(j,7,i) = (H.AnalysisValues(j+8,7,i)-BkgdValues(i,7));
        end
    end
end

for i = 1:H.NumAnalyses % 235* intensity corrected for lin and lowint factors
    for j = 1:46
        PeakValues(j,8,i) = PeakValues(j,7,i)*(1 - (0.3*lin68*((138*PeakValues(j,7,i))^1.5)/100000000000) - (0.2*lowint68*exp(-0.000001*(138*PeakValues(j,7,i)))));
    end
end

for i = 1:H.NumAnalyses % 238 intensity of 46 rows after Tzero (background subtracted)
    for j = 1:46
        if H.AnalysisValues(j+8,8,i) - BkgdValues(i,8) < 1
            PeakValues(j,9,i) = 1;
        else
            PeakValues(j,9,i) = PeakValues(j,7,i)*137.818;
        end
    end
end

for i = 1:H.NumAnalyses % 238* corrected for lin and lowint factors 
    for j = 1:46
        PeakValues(j,10,i) = PeakValues(j,8,i)*137.818;
    end
end

for i = 1:H.NumAnalyses 
    for j = 1:46
        PeakCPS(1,i) = mean(PeakValues(6,10,i)+PeakValues(7,10,i)+PeakValues(8,10,i));
        PeakCPS(2,i) = mean(PeakValues(9,10,i)+PeakValues(10,10,i)+PeakValues(11,10,i));
        PeakCPS(3,i) = mean(PeakValues(12,10,i)+PeakValues(13,10,i)+PeakValues(14,10,i));
        PeakCPS(4,i) = mean(PeakValues(15,10,i)+PeakValues(16,10,i)+PeakValues(17,10,i));
        PeakCPS(5,i) = mean(PeakValues(18,10,i)+PeakValues(19,10,i)+PeakValues(20,10,i));
        PeakCPS(6,i) = mean(PeakValues(21,10,i)+PeakValues(22,10,i)+PeakValues(23,10,i));
        PeakCPS(7,i) = mean(PeakValues(24,10,i)+PeakValues(25,10,i)+PeakValues(26,10,i));
        PeakCPS(8,i) = mean(PeakValues(27,10,i)+PeakValues(28,10,i)+PeakValues(29,10,i));
        PeakAvgCPS(1,i) = mean(PeakValues(6:29,10,i)); 
        PeakOffset(1,i) = PeakCPS(1,i)/PeakAvgCPS(1,i);
        PeakOffset(2,i) = PeakCPS(2,i)/PeakAvgCPS(1,i);
        PeakOffset(3,i) = PeakCPS(3,i)/PeakAvgCPS(1,i);
        PeakOffset(4,i) = PeakCPS(4,i)/PeakAvgCPS(1,i);
        PeakOffset(5,i) = PeakCPS(5,i)/PeakAvgCPS(1,i);
        PeakOffset(6,i) = PeakCPS(6,i)/PeakAvgCPS(1,i);
        PeakOffset(7,i) = PeakCPS(7,i)/PeakAvgCPS(1,i);
        PeakOffset(8,i) = PeakCPS(8,i)/PeakAvgCPS(1,i);
    end
end

%% CALCULATE U-Th-Pb RATIOS

waitbar(1/waitnum, h, 'Calculate Ratios 1'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

for i = 1:H.NumAnalyses % 206/238 -- calculates ratio of corrected intensities for each row *****
    for j = 1:46
        if PeakValues(j,3,i) == 1 || PeakValues(j,10,i) == 1
            PeakValues(j,11,i) = 1;
        else
            PeakValues(j,11,i) = PeakValues(j,3,i)/PeakValues(j,10,i);
        end
    end
end

for i = 1:H.NumAnalyses % 206/207 -- calculates ratio of corrected intensities for each row (1.5 and 30 are set as min & max values) *****
    for j = 1:46
        if PeakValues(j,3,i) == 1 || PeakValues(j,4,i) == 1
            PeakValues(j,12,i) = 1;
        elseif PeakValues(j,3,i)/PeakValues(j,4,i) > 30
            PeakValues(j,12,i) = 30;
        elseif PeakValues(j,3,i)/PeakValues(j,4,i) < 1.5
            PeakValues(j,12,i) = 1.5;
        else
            PeakValues(j,12,i) = PeakValues(j,3,i)/PeakValues(j,4,i);
        end
    end
end

for i = 1:H.NumAnalyses % 206/204 -- calculates ratio of corrected intensities for each row (100 and 200,000 are set as min & max values) *****
    for j = 1:46
        if abs(PeakValues(j,3,i)/PeakValues(j,2,i)) > 200000
            PeakValues(j,13,i) = 200000;
        elseif abs(PeakValues(j,3,i)/PeakValues(j,2,i)) < 100
            PeakValues(j,13,i) = 100;
        else
            PeakValues(j,13,i) = abs(PeakValues(j,3,i)/PeakValues(j,2,i));
        end
    end
end

for i = 1:H.NumAnalyses % 208/232 -- calculates ratio of corrected intensities for each row *****
    for j = 1:46
        if PeakValues(j,5,i) == 1 || PeakValues(j,6,i) == 1
            PeakValues(j,14,i) = 1;
        else
            PeakValues(j,14,i) = PeakValues(j,5,i)/PeakValues(j,6,i);
        end
    end
end

for i = 1:H.NumAnalyses % 208/204 -- calculates ratio of corrected intensities for each row (10 and 10,000 are set as min & max values) *****
    for j = 1:46
        if PeakValues(j,5,i) == 1
            PeakValues(j,15,i) = 1;
        elseif abs(PeakValues(j,5,i)/PeakValues(j,2,i)) > 10000
            PeakValues(j,15,i) = 10000;
        elseif abs(PeakValues(j,5,i)/PeakValues(j,2,i)) < 10
            PeakValues(j,15,i) = 10;
        else
            PeakValues(j,15,i) = abs(PeakValues(j,5,i)/PeakValues(j,2,i));
        end
    end
end

for i = 1:H.NumAnalyses %counts values of 235 that are >5M cps (was 238)
    for j = 11:56
        if H.AnalysisValues(j,7,i) > 5000000 %was col 8 for 238
            countif(j,i) = 1;
        else
            countif(j,i) = 0;
        end
    end
end
countsum = sum(countif);

for i = 1:H.NumAnalyses
    if mean(PeakValues(4:20,8,i)) < filter_235 || H.AnalysisValues(20,3,i) == 100100 % bad if 235<filter_235 values
        mode(i,1) = {'bad'};
        modenum(i,1) = 1;
    elseif countsum(1,i) < 3 % IC if no peaks have less than three readings have > 5M cps
        mode(i,1) = {'IC'};
        modenum(i,1) = 2;
    elseif mean(PeakValues(2:33,8,i)) > 5000000 % AN if mean 235* > 5Mcps (was column 10 for 238)
        mode(i,1) = {'AN'};
        modenum(i,1) = 3;
    else
        mode(i,1) = {'MI'}; % MI if none of the above
        modenum(i,1) = 4;
    end
end

waitbar(2/waitnum, h, 'Calculate Ratios 2'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

%Tzero = 1;

%% Creating CalcValues Array

CalcValues = zeros(H.NumAnalyses,18); % array with reduced UPBdata; intensities from 26 peak rows; ratios from all 46 rows

for i = 1:H.NumAnalyses
    CalcValues(i,1) = abs(mean(PeakValues(7:32,2,i))); % col 1 = avg 204 intensity
    CalcValues(i,2) = abs(mean(PeakValues(7:32,3,i))); % col 2 = avg 206 intensity
    CalcValues(i,3) = abs(mean(PeakValues(7:32,4,i))); % col 3 = avg 207 intensity
    CalcValues(i,4) = abs(mean(PeakValues(7:32,5,i))); % col 4 = avg 208 intensity

    if mean(PeakValues(7:32,6,i)) < 1000 % col 5 = 232 intensity
        CalcValues(i,5) = 1;
    else
        CalcValues(i,5) = abs(mean(PeakValues(7:32,6,i))); % col 5 = avg 232 intensity
    end

    if mean(PeakValues(7:32,8,i)) < 1000 % col 6 = avg 235* intensity
        CalcValues(i,6) = 1;
    else
        CalcValues(i,6) = abs(mean(PeakValues(7:32,8,i))); % col 6 = avg 235* intensity
    end

    if mean(PeakValues(7:32,10,i)) < 1000 % col 7 = avg 238* intensity
        CalcValues(i,7) = 1;
    else
        CalcValues(i,7) = abs(mean(PeakValues(7:32,10,i))); % col 7 = avg 238* intensity
    end
end

waitbar(3/waitnum, h, 'Calculate Ratios 3'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

for i = 1:H.NumAnalyses % col 8 = 206/238 from total counts of 46 rows (starting three before Tzero)
    if modenum(i,1) == 1 %
        CalcValues(i,8) = 1.3;
    else
        CalcValues(i,8) = (sum(PeakValues(:,3,i))/sum(PeakValues(:,10,i))); 
    end
end

for i=1:H.NumAnalyses
    x=1:26;
    y=PeakValues(7:32,11,i);
    [p,S]=polyfit(x,y,1);
    [y_fit,delta]=polyval(p,1,S);
    err_68_reg(i,1) = delta/2; %uncertainty of regression at 95% (/2 for 1-sigma) 
end

for i = 1:H.NumAnalyses % col 9 = uncertainty of 206/238 from least squares regression of 26 rows
    if modenum(i,1) == 1
        CalcValues(i,9) = 1;
    elseif 100*err_68_reg(i,1)/CalcValues(i,8) > 50
        CalcValues(i,9) = 50;
    else
        CalcValues(i,9) = 100*(err_68_reg(i,1)/CalcValues(i,8)); 
    end
end

for i = 1:H.NumAnalyses % col 11 = 206/207 from total counts of 46 rows (starting three before Tzero)
    if modenum(i,1) == 1
        CalcValues(i,11) = 5;
    elseif sum(PeakValues(:,3,i))/sum(PeakValues(:,4,i)) < 1.5
        CalcValues(i,11) = 1.5;
    elseif sum(PeakValues(:,3,i))/sum(PeakValues(:,4,i)) > 30
        CalcValues(i,11) = 30;
    else
        CalcValues(i,11) = (sum(PeakValues(:,3,i))/sum(PeakValues(:,4,i)));
    end
end

for i = 1:H.NumAnalyses % col 12 = 206/207 uncertainty from std error of mean of 26 scans on peaks (starting two after Tzero) *****
    if modenum(i,1) == 1
        CalcValues(i,12) = 1;
    elseif 100*std(PeakValues(7:32,12,i))/CalcValues(i,11)/sqrt(26) > 50
        CalcValues(i,12) = 50;
    else
        CalcValues(i,12) = (100*std(PeakValues(7:32,12,i))/CalcValues(i,11))/sqrt(26); % removed underdispersion factor applied of 0.6 ***** (was 5:33)
    end
end

for i = 1:H.NumAnalyses % col 13 = 206/204 from peak intensities (times 4 for most analyses to reduce common Pb correction) *****
    if modenum(i,1) == 1
        CalcValues(i,13) = 1000;
    elseif CalcValues(i,2)/CalcValues(i,1) < 20
        CalcValues(i,13) = 20;
    elseif CalcValues(i,2)/CalcValues(i,1) < 1000
        CalcValues(i,13) = 4*CalcValues(i,2)/CalcValues(i,1);
    elseif CalcValues(i,2)/CalcValues(i,1) > 10000
        CalcValues(i,13) = 3*CalcValues(i,2)/CalcValues(i,1);
    else
        CalcValues(i,13) = (4*CalcValues(i,2)/CalcValues(i,1));
    end
end

for i = 1:H.NumAnalyses % col 14 = 206/204 uncertainty from std error of mean of 26 scans on peaks (starting two after Tzero) *****
    if modenum(i,1) == 1
        CalcValues(i,14) = 1;
    elseif (100*std(PeakValues(7:32,13,i))/CalcValues(i,13))/sqrt(26) > 100
        CalcValues(i,14) = 100;
    else
        CalcValues(i,14) = (100*std(PeakValues(7:32,13,i))/CalcValues(i,13))/sqrt(26);
    end
end

for i = 1:H.NumAnalyses % col 15 = 208/232 from peak intensities of 26 rows (starting two after Tzero) *****
    if modenum(i,1) == 1
        CalcValues(i,15) = 1;
    elseif CalcValues(i,4)/CalcValues(i,5) > 0.5
        CalcValues(i,15) = 0.5;
    else
        CalcValues(i,15) = (CalcValues(i,4)/CalcValues(i,5));
    end
end
%err_82_sem(:,1) = std(PeakValues(7:32,14,:))/4;

for i=1:H.NumAnalyses
    x=1:26;
    y=PeakValues(7:32,14,i);
    [p,S]=polyfit(x,y,1);
    [y_fit,delta]=polyval(p,1,S);
    err_82_reg(i,1) = delta/2; %uncertainty of regression at 95% (/2 for 1-sigma) 
end

for i = 1:H.NumAnalyses % col 16 = uncertainty of 208/232 from least squares regression of 26 rows *****
    if modenum(i,1) == 1
        CalcValues(i,16) = 1;
    elseif abs(100*err_82_reg(i,1)/CalcValues(i,15)) > 20
        CalcValues(i,16) = 20;
    else
        CalcValues(i,16) = abs(100*(err_82_reg(i,1)/CalcValues(i,15)));
    end
end

for i = 1:H.NumAnalyses % col 17 = 208/204 from peak intensities (times 4 for most analyses to reduce common Pb correction) *****
    if modenum(i,1) == 1
        CalcValues(i,17) = 100;
    elseif CalcValues(i,4)/CalcValues(i,1) < 100
        CalcValues(i,17) = 100;
    else
        CalcValues(i,17) = 4*CalcValues(i,4)/CalcValues(i,1);
    end
end

for i = 1:H.NumAnalyses % col 18 = 208/204 uncertainty from std error of mean of 26 scans on peaks (starting two after Tzero) *****
    if modenum(i,1) == 1
        CalcValues(i,18) = 1;
    elseif 100*std(PeakValues(7:32,15,i))/CalcValues(i,17)/sqrt(26) > 50
        CalcValues(i,18) = 50;
    else
        CalcValues(i,18) = (100*std(PeakValues(7:32,15,i))/CalcValues(i,17)/sqrt(26));
    end
end

for i = 1:H.NumAnalyses
    serial{i,1} = i;
end

%% Calculating Initial Fractionation Factors

waitbar(4/waitnum, h, 'Calculate Fractionation Factors'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

for i = 1:H.NumAnalyses %206204 
    if CalcValues(i,13)*factor64 > 20
        corrected64(i,1) = (CalcValues(i,13)*factor64); % applies 206/204 factor if 206/204 > 20
    else
        corrected64(i,1) = 20;
    end
end

for i = 1:H.NumAnalyses % initial 68 ff (E2AgeCalc 192 Sheet1 Excel col HK) -- This is to determine fraction-corrected age for Pbc
    if contains(H.sample{i,1}, 'FC') == 1 && modenum(i,1) ~= 1
        ff68init(i,1) = H.STD_FC_68/CalcValues(i,8)*(corrected64(i,1)-H.STD_FC_64c)/corrected64(i,1);
    elseif contains(H.sample{i,1}, 'SL') == 1 && modenum(i,1) ~= 1
        ff68init(i,1) = H.STD_SL_68/CalcValues(i,8)*(corrected64(i,1)-H.STD_SL_64c)/corrected64(i,1);
    elseif contains(H.sample{i,1}, 'R33') == 1 && modenum(i,1) ~= 1
        ff68init(i,1) = H.STD_R33_68/CalcValues(i,8)*(corrected64(i,1)-H.STD_R33_64c)/corrected64(i,1);
    else
        ff68init(i,1) = 0;
    end
end
ff68init(H.NumAnalyses+1:H.NumAnalyses+46,1) = 0;

if length(nonzeros(ff68init(:,1))) > 10 && H.NumAnalyses > 30 %sets ff for 206/238
    for i = 1:13 %initial 68 ff sw (first 13 rows)
        if length(nonzeros(ff68init(1:i+26))) < 4
            ffsw68init(i,1) = mean(nonzeros(ff68init(1:i+26,1)));
        else
            ffsw68init(i,1) = (sum(nonzeros(ff68init(1:i+26,1)))-max(nonzeros(ff68init(1:i+26,1)))-min(nonzeros(ff68init(1:i+26,1))))/(length(nonzeros(ff68init(1:i+26,1)))-2);
        end
    end
    for i = 14:40 %initial 68 ff sw (row 14 to row 40)
        if length(nonzeros(ff68init(6:i+39))) < 4
            ffsw68init(i,1) = mean(nonzeros(ff68init(6:i+39,1)));
        else
            ffsw68init(i,1) = (sum(nonzeros(ff68init(6:i+39,1)))-max(nonzeros(ff68init(6:i+39,1)))-min(nonzeros(ff68init(6:i+39,1))))/(length(nonzeros(ff68init(6:i+39,1)))-2);
        end
    end
    for i = 41:H.NumAnalyses %initial 68 ff sw (row 41 to end)
        if length(nonzeros(ff68init(i-34:i+39))) < 4
            ffsw68init(i,1) = mean(nonzeros(ff68init(i-34:i+39,1)));
        else
            ffsw68init(i,1) = (sum(nonzeros(ff68init(i-34:i+39,1)))-max(nonzeros(ff68init(i-34:i+39,1)))-min(nonzeros(ff68init(i-34:i+39,1))))/(length(nonzeros(ff68init(i-34:i+39,1)))-2);
        end
    end
else
    for i = 1:H.NumAnalyses
        ffsw68init(i,1) = mean(nonzeros(ff68init));
    end
end

for i = 1:H.NumAnalyses %initial 6/8 age
    Age68init(i,1) = abs(log(CalcValues(i,8)*ffsw68init(i,1)+1)/0.000155125);
end
%% Determine if STD ages are acceptable by comparison of initial ages with known ages

for i = 1:H.NumAnalyses %68 STDS -- Rejects 68 analyses if different from known age
    reject68std(i,1) = 0;
    if contains(H.sample{i,1}, 'FC') == 1 && Age68init(i,1) > (H.STD_FC_68age+0.01*rejectFC68*H.STD_FC_68age) || contains(H.sample{i,1}, 'FC') == 1 && Age68init(i,1) < (H.STD_FC_68age-0.01*rejectFC68*H.STD_FC_68age) || ...
            contains(H.sample{i,1}, 'SL') == 1 && Age68init(i,1) > (H.STD_SL_68age+0.01*rejectSL68*H.STD_SL_68age) || contains(H.sample{i,1}, 'SL') == 1 && Age68init(i,1) < (H.STD_SL_68age-0.01*rejectSL68*H.STD_SL_68age) || ...
            contains(H.sample{i,1}, 'R33') == 1 && Age68init(i,1) > (H.STD_R33_68age+0.01*rejectR3368*H.STD_R33_68age) || contains(H.sample{i,1}, 'R33') == 1 && Age68init(i,1) < (H.STD_R33_68age-0.01*rejectR3368*H.STD_R33_68age)
        reject68std(i,1) = 1;
        if modenum(i,1) ~= 1
        end
    end
end

for i = 1:H.NumAnalyses %67 STDS -- Rejects 67 analyses if different from known age
    reject67std(i,1) = 0;
    if contains(H.sample{i,1}, 'FC') == 1 && CalcValues(i,11) > (H.STD_FC_67+0.01*rejectFC67*H.STD_FC_67) || contains(H.sample{i,1}, 'FC') == 1 && CalcValues(i,11) < (H.STD_FC_67-0.01*rejectFC67*H.STD_FC_67) || ...
            contains(H.sample{i,1}, 'SL') == 1 && CalcValues(i,11) > (H.STD_SL_67+0.01*rejectSL67*H.STD_SL_67) || contains(H.sample{i,1}, 'SL') == 1 && CalcValues(i,11) < (H.STD_SL_67-0.01*rejectSL67*H.STD_SL_67) || ...
            contains(H.sample{i,1}, 'R33') == 1 && CalcValues(i,11) > (H.STD_R33_67+0.02*rejectR3367*H.STD_R33_67) || contains(H.sample{i,1}, 'R33') == 1 && CalcValues(i,11) < (H.STD_R33_67-0.02*rejectR3367*H.STD_R33_67)
        reject67std(i,1) = 1;
    end
end

for i = 1:H.NumAnalyses %82 ff (E2AgeCalc 192 Sheet1 Excel col CP)
    if contains(H.sample{i,1}, 'FC') == 1
        ff82init(i,1) = H.STD_FC_82/(CalcValues(i,15)*(((CalcValues(i,17)*factor64)-H.STD_FC_68c)/(CalcValues(i,17)*factor64))); %uses te wrong STD 68c, should be FC not SL
    elseif contains(H.sample{i,1}, 'SL') == 1
        ff82init(i,1) = H.STD_SL_82/(CalcValues(i,15)*(((CalcValues(i,17)*factor64)-H.STD_SL_68c)/(CalcValues(i,17)*factor64)));
    elseif contains(H.sample{i,1}, 'R33') == 1
        ff82init(i,1) = H.STD_R33_82/(CalcValues(i,15)*(((CalcValues(i,17)*factor64)-H.STD_R33_68c)/(CalcValues(i,17)*factor64)));
    else
        ff82init(i,1) = 0;
    end
end

for i = 1:H.NumAnalyses %82 STDS -- Rejects 82 analyses if different from known age Uses rejection level of 206/238
    reject82std(i,1) = 0;
    if modenum(i,1) ~= 1
        if contains(H.sample{i,1}, 'FC') == 1 && ff82init(i,1)*CalcValues(i,15) > (H.STD_FC_82+0.01*reject82*H.STD_FC_82) || contains(H.sample{i,1}, 'FC') == 1 && ff82init(i,1)*CalcValues(i,15) < (H.STD_FC_82-0.01*reject82*H.STD_FC_82) || ...
    			contains(H.sample{i,1}, 'SL') == 1 && ff82init(i,1)*CalcValues(i,15) > (H.STD_SL_82+0.01*reject82*H.STD_SL_82) || contains(H.sample{i,1}, 'SL') == 1 && ff82init(i,1)*CalcValues(i,15) < (H.STD_SL_82-0.01*reject82*H.STD_SL_82) || ...
    			contains(H.sample{i,1}, 'R33') == 1 && ff82init(i,1)*CalcValues(i,15) > (H.STD_R33_82+0.01*reject82*H.STD_R33_82) || contains(H.sample{i,1}, 'R33') == 1 && ff82init(i,1)*CalcValues(i,15) < (H.STD_R33_82-0.01*reject82*H.STD_R33_82)
    		reject82std(i,1) = 1;
        end
    end
end

%% Calculating Final Fract Factors

Use_SL_68 = get(H.Use_SL_68, 'Value'); % checkbox
Use_SL_67 = get(H.Use_SL_67, 'Value'); % checkbox
Use_R33_68 = get(H.Use_R33_68, 'Value'); % checkbox

for i = 1:H.NumAnalyses %68 ff
    if contains(H.sample{i,1}, 'FC') == 1 && reject68std(i,1) == 0 % && use_FC_68 unless rejected
        ff68(i,1) = H.STD_FC_68/(CalcValues(i,8)*(corrected64(i,1)-H.STD_FC_64c)/corrected64(i,1));
    elseif contains(H.sample{i,1}, 'SL') == 1  && reject68std(i,1) == 0 && Use_SL_68 == 1
        ff68(i,1) = H.STD_SL_68/(CalcValues(i,8)*(corrected64(i,1)-H.STD_SL_64c)/corrected64(i,1));
    elseif contains(H.sample{i,1}, 'R33') == 1  && reject68std(i,1) == 0 && Use_R33_68 == 1
        ff68(i,1) = H.STD_R33_68/(CalcValues(i,8)*(corrected64(i,1)-H.STD_R33_64c)/corrected64(i,1));
    else
        ff68(i,1) = 0;
    end
end
for i = 1:H.NumAnalyses %68 ff rejected
    if contains(H.sample{i,1}, 'FC') == 1 && reject68std(i,1) == 1 % && use_FC_68 unless rejected
        ff68rej(i,1) = H.STD_FC_68/(CalcValues(i,8)*(corrected64(i,1)-H.STD_FC_64c)/corrected64(i,1));
    elseif contains(H.sample{i,1}, 'SL') == 1  && reject68std(i,1) == 1 && Use_SL_68 == 1
        ff68rej(i,1) = H.STD_SL_68/(CalcValues(i,8)*(corrected64(i,1)-H.STD_SL_64c)/corrected64(i,1));
    elseif contains(H.sample{i,1}, 'R33') == 1  && reject68std(i,1) == 1 && Use_R33_68 == 1
        ff68rej(i,1) = H.STD_R33_68/(CalcValues(i,8)*(corrected64(i,1)-H.STD_R33_64c)/corrected64(i,1));
    else
        ff68rej(i,1) = 0;
    end
end
ff68(H.NumAnalyses+1:H.NumAnalyses+46,1) = 0;

if length(nonzeros(ff68(:,1))) > 10 && H.NumAnalyses > 30 % revised FF68 calc
    for i = 1:13 %68 ff sw and se 
        ffsw68(i,1) = (sum(nonzeros(ff68(1:i+26,1)))-max(nonzeros(ff68(1:i+26,1)))-min(nonzeros(ff68(1:i+26,1))))/(length(nonzeros(ff68(1:i+26,1)))-2);
        ffswse68(i,1) = abs(std(nonzeros(ff68(1:i+26,1)))/(sqrt(length(nonzeros(ff68(1:i+26,1))))));
    end
    for i = 14:40 %68 ff sw and se 
        ffsw68(i,1) = (sum(nonzeros(ff68(6:i+39,1)))-max(nonzeros(ff68(6:i+39,1)))-min(nonzeros(ff68(6:i+39,1))))/(length(nonzeros(ff68(6:i+39,1)))-2);
        ffswse68(i,1) = abs(std(nonzeros(ff68(6:i+39,1)))/(sqrt(length(nonzeros(ff68(6:i+39,1))))));
    end
    for i = 41:H.NumAnalyses %68 ff sw and se 
        ffsw68(i,1) = (sum(nonzeros(ff68(i-34:i+39,1)))-max(nonzeros(ff68(i-34:i+39,1)))-min(nonzeros(ff68(i-34:i+39,1))))/(length(nonzeros(ff68(i-34:i+39,1)))-2);
        ffswse68(i,1) = abs(std(nonzeros(ff68(i-34:i+39,1)))/(sqrt(length(nonzeros(ff68(i-34:i+39,1))))));
    end
else
    for i = 1:H.NumAnalyses
        ffsw68(i,1) = mean(nonzeros([ff68]));
        ffswse68(i,1) = (std(nonzeros([ff68])))/sqrt(length(nonzeros([ff68])));
    end
end

ffse68_hi = ffsw68 + ffswse68; 
ffse68_lo = ffsw68 - ffswse68; 

for i = 1:H.NumAnalyses
    Age68init2(i,1) = log(ffsw68(i,1)*CalcValues(i,8)+1)/0.000155125; 
    DA(i,1) = 18.761 - 0.0000001*Age68init2(i,1)*Age68init2(i,1) - 0.0016*Age68init2(i,1); 
    DB(i,1) = 15.671 - 0.00000000009*Age68init2(i,1)*Age68init2(i,1)*Age68init2(i,1)+0.0000002*Age68init2(i,1)*Age68init2(i,1)-0.0003*Age68init2(i,1); 
    DC(i,1) = 38.657  -0.00000003*Age68init2(i,1)*Age68init2(i,1) - 0.0019*Age68init2(i,1); 
end

for i = 1:H.NumAnalyses
    fcbc68(i,1) = abs(CalcValues(i,8)*ffsw68(i,1)*(corrected64(i,1)-DA(i,1))/corrected64(i,1)); 
end

for i = 1:H.NumAnalyses
    err6864(i,1) = abs(100*(1-((corrected64(i,1)-(18.761-DA(i,1)))/corrected64(i,1))/(((corrected64(i,1)+corrected64(i,1)*CalcValues(i,14)/100)-(18.761-DA(i,1)))/(corrected64(i,1)+corrected64(i,1)*CalcValues(i,14)/100)))); 
    pbcerr68(i,1) = abs(100*(1-(corrected64(i,1)-(DA(i,1)/corrected64(i,1)))/(corrected64(i,1)-((DA(i,1)-1)/corrected64(i,1))))); 
    ratio68err(i,1) = odf68*(sqrt(CalcValues(i,9)*CalcValues(i,9)+err6864(i,1)*err6864(i,1))); 
end

for i = 1:H.NumAnalyses %67 ff uses FC and SL
    if contains(H.sample{i,1}, 'FC') == 1 && reject67std(i,1) == 0
        ff67(i,1) = H.STD_FC_67/((corrected64(i,1)-DA(i,1))/((corrected64(i,1)/CalcValues(i,11))-DB(i,1)));
    elseif contains(H.sample{i,1}, 'SL') == 1 && reject67std(i,1) == 0 && Use_SL_67 == 1
        ff67(i,1) = H.STD_SL_67/((corrected64(i,1)-DA(i,1))/((corrected64(i,1)/CalcValues(i,11))-DB(i,1)));
    else
        ff67(i,1) = 0;
    end
end
for i = 1:H.NumAnalyses %67 ff rejected uses FC and SL
    if contains(H.sample{i,1}, 'FC') == 1 && reject67std(i,1) == 1
        ff67rej(i,1) = H.STD_FC_67/((corrected64(i,1)-DA(i,1))/((corrected64(i,1)/CalcValues(i,11))-DB(i,1)));
    elseif contains(H.sample{i,1}, 'SL') == 1 && reject67std(i,1) == 1 && Use_SL_67 == 1
        ff67rej(i,1) = H.STD_SL_67/((corrected64(i,1)-DA(i,1))/((corrected64(i,1)/CalcValues(i,11))-DB(i,1)));
    else
        ff67rej(i,1) = 0;
    end
end
ff67(H.NumAnalyses+1:H.NumAnalyses+46,1) = 0;

if length(nonzeros(ff67(:,1))) > 10 && H.NumAnalyses > 30
    for i = 1:13 %67 ff sw and se 
        ffsw67(i,1) = (sum(nonzeros(ff67(1:i+26,1)))-max(nonzeros(ff67(1:i+26,1)))-min(nonzeros(ff67(1:i+26,1))))/(length(nonzeros(ff67(1:i+26,1)))-2);
        ffswse67(i,1) = abs(std(nonzeros(ff67(1:i+26,1)))/(sqrt(length(nonzeros(ff67(1:i+26,1))))));
    end
    for i = 14:40 %67 ff sw and se 
        ffsw67(i,1) = (sum(nonzeros(ff67(6:i+39,1)))-max(nonzeros(ff67(6:i+39,1)))-min(nonzeros(ff67(6:i+39,1))))/(length(nonzeros(ff67(6:i+39,1)))-2);
        ffswse67(i,1) = abs(std(nonzeros(ff67(6:i+39,1)))/(sqrt(length(nonzeros(ff67(6:i+39,1))))));
    end
    for i = 41:H.NumAnalyses %67 ff sw and se 
        ffsw67(i,1) = (sum(nonzeros(ff67(i-34:i+39,1)))-max(nonzeros(ff67(i-34:i+39,1)))-min(nonzeros(ff67(i-34:i+39,1))))/(length(nonzeros(ff67(i-34:i+39,1)))-2);
        ffswse67(i,1) = abs(std(nonzeros(ff67(i-34:i+39,1)))/(sqrt(length(nonzeros(ff67(i-34:i+39,1))))));
    end
else
    for i = 1:H.NumAnalyses
        ffsw67(i,1) = mean(nonzeros([ff67]));
        ffswse67(i,1) = (std(nonzeros([ff67])))/sqrt(length(nonzeros([ff67])));
    end
end

ffse67_hi = ffsw67 + ffswse67; 
ffse67_lo = ffsw67 - ffswse67; 

for i = 1:H.NumAnalyses
    fcbc67(i,1) = (abs(ffsw67(i,1)*((corrected64(i,1)-DA(i,1))/((corrected64(i,1)/(CalcValues(i,11))-DB(i,1)))))); %col CL
end

for i = 1:H.NumAnalyses % cols CN, CO, and CM
    err6764(i,1) = abs(100*(1-((ffsw67(i,1)*((corrected64(i,1)-DA(i,1))/((corrected64(i,1)/(CalcValues(i,11))-DB(i,1)))))/...
        (ffsw67(i,1)*(((corrected64(i,1)+corrected64(i,1)*CalcValues(i,14)/100)-(DA(i,1)))/(((corrected64(i,1)+corrected64(i,1)*CalcValues(i,14)/100)/(CalcValues(i,11))-DB(i,1)))))))); %col CN
    pbcerr67(i,1) = abs(100*(1-((ffsw67(i,1)*((corrected64(i,1)-(DA(i,1)))/((corrected64(i,1)/(CalcValues(i,11))-DB(i,1)))))/(ffsw67(i,1)*(((corrected64(i,1))-(DA(i,1)-1))/...
        (((corrected64(i,1))/(CalcValues(i,11))-(DB(i,1)-0.3)))))))); 
    ratio67err(i,1) = odf67*(sqrt(CalcValues(i,12)*CalcValues(i,12)+err6764(i,1)*err6764(i,1)));
end

for i = 1:H.NumAnalyses %67 ff  uses FC and SL
    if contains(H.sample{i,1}, 'FC') == 1 && reject67std(i,1) == 0
        ff67(i,1) = H.STD_FC_67/((corrected64(i,1)-DA(i,1))/((corrected64(i,1)/CalcValues(i,11))-DB(i,1)));
    elseif contains(H.sample{i,1}, 'SL') == 1 && reject67std(i,1) == 0 %&& Use_SL_67 == 1
        ff67(i,1) = H.STD_SL_67/((corrected64(i,1)-DA(i,1))/((corrected64(i,1)/CalcValues(i,11))-DB(i,1)));
    else
        ff67(i,1) = 0;
    end
end

for i = 1:H.NumAnalyses %82 ff 
    if contains(H.sample{i,1}, 'FC') == 1 && reject82std(i,1) == 0
        ff82(i,1) = H.STD_FC_82/(CalcValues(i,15)*(((CalcValues(i,17)*factor64)-H.STD_FC_68c)/(CalcValues(i,17)*factor64)));
    elseif contains(H.sample{i,1}, 'SL') == 1 && reject82std(i,1) == 0 
        ff82(i,1) = H.STD_SL_82/(CalcValues(i,15)*(((CalcValues(i,17)*factor64)-H.STD_SL_68c)/(CalcValues(i,17)*factor64)));
    elseif contains(H.sample{i,1}, 'R33') == 1 && reject82std(i,1) == 0 
        ff82(i,1) = H.STD_R33_82/(CalcValues(i,15)*(((CalcValues(i,17)*factor64)-H.STD_R33_68c)/(CalcValues(i,17)*factor64)));
    else
        ff82(i,1) = 0;
    end
end
for i = 1:H.NumAnalyses %82 ff rejected
    if contains(H.sample{i,1}, 'FC') == 1 && reject82std(i,1) == 1
        ff82rej(i,1) = H.STD_FC_82/(CalcValues(i,15)*(((CalcValues(i,17)*factor64)-H.STD_FC_68c)/(CalcValues(i,17)*factor64)));
    elseif contains(H.sample{i,1}, 'SL') == 1 && reject82std(i,1) == 1 
        ff82rej(i,1) = H.STD_SL_82/(CalcValues(i,15)*(((CalcValues(i,17)*factor64)-H.STD_SL_68c)/(CalcValues(i,17)*factor64)));
    elseif contains(H.sample{i,1}, 'R33') == 1 && reject82std(i,1) == 1 
        ff82rej(i,1) = H.STD_R33_82/(CalcValues(i,15)*(((CalcValues(i,17)*factor64)-H.STD_R33_68c)/(CalcValues(i,17)*factor64)));
    else
        ff82rej(i,1) = 0;
    end
end
ff82(H.NumAnalyses+1:H.NumAnalyses+46,1) = 0;

if length(nonzeros(ff82(:,1))) > 10 && H.NumAnalyses > 30
    for i = 1:13 %82 ff sw and se 
        ffsw82(i,1) = (sum(nonzeros(ff82(1:i+26,1)))-max(nonzeros(ff82(1:i+26,1)))-min(nonzeros(ff82(1:i+26,1))))/(length(nonzeros(ff82(1:i+26,1)))-2);
        ffswse82(i,1) = abs(std(nonzeros(ff82(1:i+26,1)))/(sqrt(length(nonzeros(ff82(1:i+26,1))))));
    end
    for i = 14:40 %82 ff sw and se 
        ffsw82(i,1) = (sum(nonzeros(ff82(6:i+39,1)))-max(nonzeros(ff82(6:i+39,1)))-min(nonzeros(ff82(6:i+39,1))))/(length(nonzeros(ff82(6:i+39,1)))-2);
        ffswse82(i,1) = abs(std(nonzeros(ff82(6:i+39,1)))/(sqrt(length(nonzeros(ff82(6:i+39,1))))));
    end
    for i = 41:H.NumAnalyses %82 ff sw and se 
        ffsw82(i,1) = (sum(nonzeros(ff82(i-34:i+39,1)))-max(nonzeros(ff82(i-34:i+39,1)))-min(nonzeros(ff82(i-34:i+39,1))))/(length(nonzeros(ff82(i-34:i+39,1)))-2);
        ffswse82(i,1) = abs(std(nonzeros(ff82(i-34:i+39,1)))/(sqrt(length(nonzeros(ff82(i-34:i+39,1))))));
    end
else
    for i = 1:H.NumAnalyses
        ffsw82(i,1) = mean(nonzeros([ff82]));
        ffswse82(i,1) = (std(nonzeros([ff82])))/sqrt(length(nonzeros([ff82])));
    end
end

ffse82_hi = ffsw82 + ffswse82; 
ffse82_lo = ffsw82 - ffswse82; 

for i = 1:H.NumAnalyses 
    fcbc82(i,1) = abs(CalcValues(i,15)*ffsw82(i,1)*(((CalcValues(i,17)*factor64)-DC(i,1))/(CalcValues(i,17)*factor64)));
end

for i = 1:H.NumAnalyses
    err8284(i,1) = abs(100*(1-(((CalcValues(i,17)-DC(i,1)))/CalcValues(i,17))/((((CalcValues(i,17)+CalcValues(i,17)*CalcValues(i,18)/100)-DC(i,1)))/...
        (CalcValues(i,17)+CalcValues(i,17)*CalcValues(i,18)/100)))); 
    pbcerr82(i,1) = abs(100*(1-(((CalcValues(i,17)-DC(i,1))/CalcValues(i,17))/((CalcValues(i,17)-(DC(i,1)-2))/CalcValues(i,17))))); 
    ratio82err(i,1) = odf82*(sqrt(CalcValues(i,16)*CalcValues(i,16)+err8284(i,1)*err8284(i,1))); 
end

%% Determine U, Th, and U/Th

for i = 1:H.NumAnalyses %U ppm and Th ppm calc measured STDs 
    if reject68std(i,1) == 0 && contains(H.sample{i,1}, 'FC') == 1
        DL(i,1) = CalcValues(i,7);
        DM(i,1) = CalcValues(i,5);
        DN(i,1) = H.STD_FC_Uppm;
        DO(i,1) = H.STD_FC_Thppm;
    elseif reject68std(i,1) == 0 && contains(H.sample{i,1}, 'R33') == 1
        DL(i,1) = CalcValues(i,7);
        DM(i,1) = CalcValues(i,5);
        DN(i,1) = H.STD_R33_Uppm;
        DO(i,1) = H.STD_R33_Thppm;
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

for i = 1:H.NumAnalyses %U ppm and Thppm (E2AgeCalc 192 Sheet1 Excel cols AT and AU)
    Uppm(i,1) = CalcValues(i,7)*DNmean/DLmean;
    Thppm(i,1) = CalcValues(i,5)*DOmean/DMmean;
end
UTh = Uppm./Thppm; %U/Th ratio (E2AgeCalc 192 Sheet1 Excel col AX)

%% Calculate ages to 1377

waitbar(5/waitnum, h, 'Calculate Ages'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

for i = 1:H.NumAnalyses
    ratio68(i,1) = (fcbc68(i,1) -((0.000000000155/0.0000092)*(((1/UTh(i,1))/2.3)-1))); % BE 6/8 ratio
    ratio75(i,1) = (ratio68(i,1)/fcbc67(i,1))*137.818; %col BC
    ratio75err(i,1) = sqrt(ratio68err(i,1)*ratio68err(i,1) + ratio67err(i,1)*ratio67err(i,1)); %col BD
    Age68(i,1) = (abs(log(ratio68(i,1)+1)/0.000155125)); %BH 6/8 age
    Age68err(i,1) = abs(log((ratio68(i,1)+ratio68(i,1)*(ratio68err(i,1)/100))+1)/0.000155125-log((ratio68(i,1)-ratio68(i,1)*ratio68err(i,1)/100)+1)/0.000155125)/2; %col BI
    ratio82(i,1) = (fcbc82(i,1)); %*(1+0.1*lin82*exp(-0.000002*CalcValues(i,6)))); % cols DU and BA
    errcorr_6875(i,1) = (ratio68err(i,1)*ratio68err(i,1)+ratio75err(i,1)*ratio75err(i,1)-ratio67err(i,1)*ratio67err(i,1))/(2*ratio68err(i,1)*ratio75err(i,1)); %col BG
    Age75(i,1) = (abs(log(ratio75(i,1)+1)/0.00098485)); %col BJ
    Age75err(i,1) = abs((log((ratio75(i,1)+ratio75(i,1)*(ratio75err(i,1)/100))+1)/0.00098485-log((ratio75(i,1)-ratio75(i,1)*ratio75err(i,1)/100)+1)/0.00098485)/2); %col BK
    Age82(i,1) = (abs(log(ratio82(i,1)+1)/0.0000495)); %round(abs(log(ratio82(i,1)+1)/0.0000495),2); %col BN
    Age82err(i,1) = abs((log((ratio82(i,1)+ratio82(i,1)*(ratio82err(i,1)/100))+1)/0.0000495-log((ratio82(i,1)-ratio82(i,1)*ratio82err(i,1)/100)+1)/0.0000495)/2); %col BO
    errcorr_6882(i,1) = (ratio68err(i,1)*ratio68err(i,1)+ratio82err(i,1)*ratio82err(i,1)-ratio67err(i,1)*ratio67err(i,1))/(2*ratio68err(i,1)*ratio82err(i,1)); %should be re68 rather than ratio67err??
end

for i = 1:H.NumAnalyses %col BM
    if 1/(fcbc67(i,1)-fcbc67(i,1)*ratio67err(i,1)/100) > .0461 && 1/(fcbc67(i,1)-fcbc67(i,1)*ratio67err(i,1)/100) < .590
        Age67{i,1} = (abs(MyAge76(1/fcbc67(i,1))));
        Age67err{i,1} = abs((MyAge76(1/(fcbc67(i,1)-fcbc67(i,1)*ratio67err(i,1)/100)) - MyAge76(1/(fcbc67(i,1)+fcbc67(i,1)*ratio67err(i,1)/100)))/2);
        Age67err_2s{i,1} = (abs(2*Age67err{i,1}));
    else
        Age67{i,1} = 0; %'NA';
        Age67err{i,1} = 0; %'NA';
        Age67err_2s{i,1} = 0; %'NA';
    end
end

Age67=cell2num(Age67);
Age67err=cell2num(Age67err);
Age67err_2s=cell2num(Age67err_2s);

for i = 1:H.NumAnalyses %col BP
    if strcmp(Age67err(i,1), 0) == 1
        Best_Age(i,1) = Age68(i,1);
        Best_Age_err(i,1) = Age68err(i,1);
    elseif Age68(i,1) > 400 && (Age68(i,1)+(Age67(i,1)))/2 > bestage_cutoff
        Best_Age(i,1) = (Age67(i,1));
        Best_Age_err(i,1) = (Age67err(i,1));
    else
        Best_Age(i,1) = Age68(i,1);
        Best_Age_err(i,1) = Age68err(i,1);
    end
end

for i = 1:H.NumAnalyses
    if modenum(i,1) == 1
    else
        Age68err_2s(i,1) = (2*abs((log((ratio68(i,1)+ratio68(i,1)*(ratio68err(i,1)/100))+1)/0.000155125-log((ratio68(i,1)-ratio68(i,1)*ratio68err(i,1)/100)+1)/0.000155125)/2));
        Age82err_2s(i,1) = (2*abs((log((ratio82(i,1)+ratio82(i,1)*(ratio82err(i,1)/100))+1)/0.0000495-log((ratio82(i,1)-ratio82(i,1)*ratio82err(i,1)/100)+1)/0.0000495)/2));
        Age75err_2s(i,1) = (2*abs((log((ratio75(i,1)+ratio75(i,1)*(ratio75err(i,1)/100))+1)/0.00098485-log((ratio75(i,1)-ratio75(i,1)*ratio75err(i,1)/100)+1)/0.00098485)/2));
        ratio75err_2s(i,1) = 2*sqrt(ratio68err(i,1)*ratio68err(i,1) + ratio67err(i,1)*ratio67err(i,1));
        ratio68err_2s(i,1) = (2*odf68*sqrt(CalcValues(i,9)*CalcValues(i,9)+err6864(i,1)*err6864(i,1)));
        Best_Age_err_2s(i,1) = (2*Best_Age_err(i,1)); 
        ratio67err_2s(i,1) = (2*odf67*sqrt(CalcValues(i,12)*CalcValues(i,12)+err6764(i,1)*err6764(i,1)));
        ratio82err_2s(i,1) = (2*odf82*sqrt(CalcValues(i,16)*CalcValues(i,16)+err8284(i,1)*err8284(i,1)));
    end
end

comment1{H.NumAnalyses, 1} = [];
comment2{H.NumAnalyses, 1} = [];
comment3{H.NumAnalyses, 1} = [];
comment4{H.NumAnalyses, 1} = [];
comment5{H.NumAnalyses, 1} = [];
comment6{H.NumAnalyses, 1} = [];
comment7{H.NumAnalyses, 1} = [];
comment8{H.NumAnalyses, 1} = [];
comment9{H.NumAnalyses, 1} = [];
comment10{H.NumAnalyses, 1} = [];
comment11{H.NumAnalyses, 1} = [];

%% comments and counts

all_standards = 0;
all_unknowns = 0;
rejected_unk_sum = 0;
rejected_std_sum = 0;
comment1_num_unk = zeros(H.NumAnalyses,1);
comment1_num_std = zeros(H.NumAnalyses,1);
comment2_num_unk = zeros(H.NumAnalyses,1);
comment2_num_std = zeros(H.NumAnalyses,1);
comment3_num_unk = zeros(H.NumAnalyses,1);
comment3_num_std = zeros(H.NumAnalyses,1);
comment4_num_unk = zeros(H.NumAnalyses,1);
comment4_num_std = zeros(H.NumAnalyses,1);
comment5_num_unk = zeros(H.NumAnalyses,1);
comment5_num_std = zeros(H.NumAnalyses,1);
comment6_num_unk = zeros(H.NumAnalyses,1);
comment6_num_std = zeros(H.NumAnalyses,1);
comment5_num_unk = zeros(H.NumAnalyses,1);
comment5_num_std = zeros(H.NumAnalyses,1);
comment6_num_unk = zeros(H.NumAnalyses,1);
comment6_num_std = zeros(H.NumAnalyses,1);
comment7_num_unk = zeros(H.NumAnalyses,1);
comment7_num_std = zeros(H.NumAnalyses,1);
comment8_num_unk = zeros(H.NumAnalyses,1);
comment8_num_std = zeros(H.NumAnalyses,1);
comment9_num_unk = zeros(H.NumAnalyses,1);
comment9_num_std = zeros(H.NumAnalyses,1);
comment10_num_std = zeros(H.NumAnalyses,1);
comment11_num_std = zeros(H.NumAnalyses,1);

for i = 1:H.NumAnalyses % count of all standards
    if contains(H.sample{i,1}, 'FC') == 1 || contains(H.sample{i,1}, 'SL') == 1 || contains(H.sample{i,1}, 'R33') == 1
        all_standards = all_standards + 1;
    end
end
all_unknowns = H.NumAnalyses - all_standards;
set(H.all_standards, 'String', all_standards); %STD1_idx_rej);
set(H.all_unknowns, 'String', all_unknowns); %STD1_idx_rej);

for i = 1:H.NumAnalyses-1
    if  H.AnalysisValues(20,3,i) == 100100
        if H.FCstd_idx(i,1) == 0 && H.SLstd_idx(i,1) == 0 && H.R33std_idx(i,1) == 0
            comment1(i,1) = {'Bad (Low 235) '};
            comment1_num_unk(i,1) = 1;
        end
        if H.FCstd_idx(i,1) == 1 || H.SLstd_idx(i,1) == 1 || H.R33std_idx(i,1) == 1
            comment1(i,1) = {'Bad (Low 235) '};
            comment1_num_std(i,1) = 1;
        end
    end
    if CalcValues(i,9) > filter_err68  %|| reject68std(i,1) == 1
        if H.FCstd_idx(i,1) == 0 && H.SLstd_idx(i,1) == 0 && H.R33std_idx(i,1) == 0
            comment2(i,1) = {'6/8err '};
            comment2_num_unk(i,1) = 1;
        end
        if H.FCstd_idx(i,1) == 1 || H.SLstd_idx(i,1) == 1 || H.R33std_idx(i,1) == 1
            comment2(i,1) = {'6/8err '};
            comment2_num_std(i,1) = 1;
        end
    end
    if Age68(i,1) > filter_cutoff && CalcValues(i,12) > filter_err67
        if H.FCstd_idx(i,1) == 0 && H.SLstd_idx(i,1) == 0 && H.R33std_idx(i,1) == 0
        	comment3(i,1) = {'6/7err '};
            comment3_num_unk(i,1) = 1;
        end
        if H.FCstd_idx(i,1) == 1 || H.SLstd_idx(i,1) == 1 || H.R33std_idx(i,1) == 1
        	comment3(i,1) = {'6/7err '};
            comment3_num_std(i,1) = 1;
        end
    end
    if Age68(i,1) < Age67(i,1)*(1-filter_disc*0.01) && Age68(i,1) > filter_cutoff
        if H.FCstd_idx(i,1) == 0 && H.SLstd_idx(i,1) == 0 && H.R33std_idx(i,1) == 0
    		comment4(i,1) = {'Discord '};
            comment4_num_unk(i,1) = 1;
        end
        if H.FCstd_idx(i,1) == 1 || H.SLstd_idx(i,1) == 1 || H.R33std_idx(i,1) == 1
    		comment4(i,1) = {'Discord '};
            comment4_num_std(i,1) = 1;
        end
    end
    if Age68(i,1) > Age67(i,1)*(1+filter_disc_rev*0.01) && Age68(i,1) > filter_cutoff
        if H.FCstd_idx(i,1) == 0 && H.SLstd_idx(i,1) == 0 && H.R33std_idx(i,1) == 0
    		comment5(i,1) = {'RevDiscord '};
            comment5_num_unk(i,1) = 1;
        end
        if H.FCstd_idx(i,1) == 1 || H.SLstd_idx(i,1) == 1 || H.R33std_idx(i,1) == 1
    		comment5(i,1) = {'RevDiscord '};
            comment5_num_std(i,1) = 1;
        end
    end
    if CalcValues(i,1) > filter_204
        if H.FCstd_idx(i,1) == 0 && H.SLstd_idx(i,1) == 0 && H.R33std_idx(i,1) == 0
    		comment6(i,1) = {'High 204 '};
            comment6_num_unk(i,1) = 1;
        end
        if H.FCstd_idx(i,1) == 1 || H.SLstd_idx(i,1) == 1 || H.R33std_idx(i,1) == 1
    		comment6(i,1) = {'High 204 '};
            comment6_num_std(i,1) = 1;
        end
    end
    if PeakOffset(1,i)>peakoffsetcutoff || PeakOffset(2,i)>peakoffsetcutoff || PeakOffset(3,i)>peakoffsetcutoff || PeakOffset(4,i)>peakoffsetcutoff || ...
            PeakOffset(5,i)>peakoffsetcutoff || PeakOffset(6,i)>peakoffsetcutoff || PeakOffset(7,i)>peakoffsetcutoff || PeakOffset(5,i)>peakoffsetcutoff
        if H.FCstd_idx(i,1) == 0 && H.SLstd_idx(i,1) == 0 && H.R33std_idx(i,1) == 0
            comment7(i,1) = {'Variable Intensity '};
            comment7_num_unk(i,1) = 1;
        end
        if H.FCstd_idx(i,1) == 1 || H.SLstd_idx(i,1) == 1 || H.R33std_idx(i,1) == 1
            comment7(i,1) = {'Variable Intensity '};
            comment7_num_std(i,1) = 1;
        end
    end
    if H.current_status_num_operator_reject(i,1) == 1
        if H.FCstd_idx(i,1) == 0 && H.SLstd_idx(i,1) == 0 && H.R33std_idx(i,1) == 0
    		comment8(i,1) = {'Operator Rejected '};
            comment8_num_unk(i,1) = 1;
        end
        if H.FCstd_idx(i,1) == 1 || H.SLstd_idx(i,1) == 1 || H.R33std_idx(i,1) == 1
    		comment8(i,1) = {'Operator Rejected '};
            comment8_num_std(i,1) = 1;
        end
    end
    if H.current_status_num_operator_accept(i,1) == 1
        if H.FCstd_idx(i,1) == 0 && H.SLstd_idx(i,1) == 0 && H.R33std_idx(i,1) == 0
    		comment9(i,1) = {'Operator Accepted '};
            comment9_num_unk(i,1) = 1;
        end
        if H.FCstd_idx(i,1) == 1 || H.SLstd_idx(i,1) == 1 || H.R33std_idx(i,1) == 1
    		comment9(i,1) = {'Operator Accepted '};
            comment9_num_std(i,1) = 1;
        end
    end
    if reject68std(i,1) == 1
        if H.FCstd_idx(i,1) == 1 || H.SLstd_idx(i,1) == 1 || H.R33std_idx(i,1) == 1
            comment10(i,1) = {'6/8offset '};
            comment10_num_std(i,1) = 1;
        end
    end
    if reject67std(i,1) == 1
        if H.FCstd_idx(i,1) == 1 || H.SLstd_idx(i,1) == 1 || H.R33std_idx(i,1) == 1
    		comment11(i,1) = {'6/7offset '};
            comment11_num_std(i,1) = 1;
        end
    end
end

comment = strcat(comment1, comment2, comment3, comment4, comment5, comment6, comment7, comment8, comment9, comment10, comment11);

comment1_sum_unk = sum(comment1_num_unk(:,1)); %bad
comment1_sum_std = sum(comment1_num_std(:,1)); %bad
comment2_sum_unk = sum(comment2_num_unk(:,1)); %68 err
comment2_sum_std = sum(comment2_num_std(:,1)); %68 err
comment3_sum_unk = sum(comment3_num_unk(:,1)); %67 err
comment3_sum_std = sum(comment3_num_std(:,1)); %67 err
comment4_sum_unk = sum(comment4_num_unk(:,1)); %Disc
comment4_sum_std = sum(comment4_num_std(:,1)); %Disc
comment5_sum_unk = sum(comment5_num_unk(:,1)); %RevDisc
comment5_sum_std = sum(comment5_num_std(:,1)); %RevDisc
comment6_sum_unk = sum(comment6_num_unk(:,1)); %204
comment6_sum_std = sum(comment6_num_std(:,1)); %204
comment7_sum_unk = sum(comment7_num_unk(:,1)); %VarIntensity
comment7_sum_std = sum(comment7_num_std(:,1)); %VarIntensity
comment8_sum_unk = sum(comment8_num_unk(:,1)); %Operator Reject
comment8_sum_std = sum(comment8_num_std(:,1)); %Operator Reject
comment9_sum_unk = sum(comment9_num_unk(:,1)); %Operator Accept
comment9_sum_std = sum(comment9_num_std(:,1)); %Operator Accept
comment10_sum_std = sum(comment10_num_std(:,1)); %68 offset
comment11_sum_std = sum(comment11_num_std(:,1)); %67 offset

for i=1:H.NumAnalyses
    if comment2_num_unk(i,1)+comment3_num_unk(i,1)+comment4_num_unk(i,1)+comment5_num_unk(i,1)+comment6_num_unk(i,1)+ ...
            comment7_num_unk(i,1)+comment8_num_unk(i,1) >= 1 
        rejected_unk_sum=rejected_unk_sum+1;
        if comment9_num_unk(i,1) == 1
            rejected_unk_sum=rejected_unk_sum-1;
        end
    end
end

for i=1:H.NumAnalyses
    if comment2_num_std(i,1)+comment3_num_std(i,1)+comment4_num_std(i,1)+comment5_num_std(i,1)+comment6_num_std(i,1)+comment7_num_std(i,1)+ ...
            comment8_num_std(i,1)+comment10_num_std(i,1)+comment11_num_std(i,1) >= 1
        rejected_std_sum=rejected_std_sum+1;
        if comment9_num_std(i,1) == 1
            rejected_std_sum=rejected_std_sum-1;
        end
    end
end

set(H.rejected_unk_sum, 'String', rejected_unk_sum);
set(H.rejected_std_sum, 'String', rejected_std_sum);

set(H.comment1_sum_unk, 'String', comment1_sum_unk);
set(H.comment1_sum_std, 'String', comment1_sum_std);
set(H.comment2_sum_unk, 'String', comment2_sum_unk);
set(H.comment2_sum_std, 'String', comment2_sum_std);
set(H.comment3_sum_unk, 'String', comment3_sum_unk);
set(H.comment3_sum_std, 'String', comment3_sum_std);
set(H.comment4_sum_unk, 'String', comment4_sum_unk);
set(H.comment4_sum_std, 'String', comment4_sum_std);
set(H.comment5_sum_unk, 'String', comment5_sum_unk);
set(H.comment5_sum_std, 'String', comment5_sum_std);
set(H.comment6_sum_unk, 'String', comment6_sum_unk);
set(H.comment6_sum_std, 'String', comment6_sum_std);
set(H.comment7_sum_unk, 'String', comment7_sum_unk);
set(H.comment7_sum_std, 'String', comment7_sum_std);
set(H.comment8_sum_unk, 'String', comment8_sum_unk);
set(H.comment8_sum_std, 'String', comment8_sum_std);
set(H.comment9_sum_unk, 'String', comment9_sum_unk);
set(H.comment9_sum_std, 'String', comment9_sum_std);
set(H.comment10_sum_std, 'String', comment10_sum_std);
set(H.comment11_sum_std, 'String', comment11_sum_std);

close(h)

analysis_num = cell2num(serial);

%% CALCULATE 68-75 CONCORDIA ELLIPSES

sigmarule=1.5;
numpoints=50;
errcorr_fix_6875 = 0.7;
errcorr_hi_6875 = errcorr_6875 > 1;
errcorr_lo_6875 = errcorr_6875 < 0;
errcorr_6875_bad = sum(errcorr_hi_6875) + sum(errcorr_lo_6875);
for i = 1:length(errcorr_6875)
    if errcorr_6875(i,:) < 0
        errcorr_corr_6875(i,:) = errcorr_fix_6875;
    elseif errcorr_6875(i,:) > 1
        errcorr_corr_6875(i,:) = errcorr_fix_6875;
    else
        errcorr_corr_6875(i,:) = errcorr_6875(i,:);
    end
end

FCstd_rho_6875 = nonzeros(H.FCstd_idx.*errcorr_corr_6875);
SLstd_rho_6875 = nonzeros(H.SLstd_idx.*errcorr_corr_6875);
R33std_rho_6875 = nonzeros(H.R33std_idx.*errcorr_corr_6875);
rho_6875 = errcorr_corr_6875;

FCstd_concordia_data_6875 = [nonzeros(H.FCstd_idx.*ratio75),nonzeros(H.FCstd_idx.*ratio75err),nonzeros(H.FCstd_idx.*ratio68),nonzeros(H.FCstd_idx.*ratio68err)];
SLstd_concordia_data_6875 = [nonzeros(H.SLstd_idx.*ratio75),nonzeros(H.SLstd_idx.*ratio75err),nonzeros(H.SLstd_idx.*ratio68),nonzeros(H.SLstd_idx.*ratio68err)];
R33std_concordia_data_6875 = [nonzeros(H.R33std_idx.*ratio75),nonzeros(H.R33std_idx.*ratio75err),nonzeros(H.R33std_idx.*ratio68),nonzeros(H.R33std_idx.*ratio68err)];
concordia_data_6875 = [ratio75,ratio75err,ratio68,ratio68err];
All_concordia_data_6875 = [ratio75,ratio75err,ratio68,ratio68err];

center_FCstd_6875 = [FCstd_concordia_data_6875(:,1),FCstd_concordia_data_6875(:,3)];
center_SLstd_6875 = [SLstd_concordia_data_6875(:,1),SLstd_concordia_data_6875(:,3)];
center_R33std_6875 = [R33std_concordia_data_6875(:,1),R33std_concordia_data_6875(:,3)];
center_6875 = [concordia_data_6875(:,1),concordia_data_6875(:,3)];
center_All_6875 = [concordia_data_6875(:,1),concordia_data_6875(:,3)];

sigx_abs_FCstd_6875 = FCstd_concordia_data_6875(:,1).*FCstd_concordia_data_6875(:,2).*0.01;
sigy_abs_FCstd_6875 = FCstd_concordia_data_6875(:,3).*FCstd_concordia_data_6875(:,4).*0.01;
sigx_abs_SLstd_6875 = SLstd_concordia_data_6875(:,1).*SLstd_concordia_data_6875(:,2).*0.01;
sigy_abs_SLstd_6875 = SLstd_concordia_data_6875(:,3).*SLstd_concordia_data_6875(:,4).*0.01;
sigx_abs_R33std_6875 = R33std_concordia_data_6875(:,1).*R33std_concordia_data_6875(:,2).*0.01;
sigy_abs_R33std_6875 = R33std_concordia_data_6875(:,3).*R33std_concordia_data_6875(:,4).*0.01;
sigx_abs_6875 = concordia_data_6875(:,1).*concordia_data_6875(:,2).*0.01;
sigy_abs_6875 = concordia_data_6875(:,3).*concordia_data_6875(:,4).*0.01;
sigx_abs_All_6875 = concordia_data_6875(:,1).*concordia_data_6875(:,2).*0.01;
sigy_abs_All_6875 = concordia_data_6875(:,3).*concordia_data_6875(:,4).*0.01;
sigx_sq_FCstd_6875 = sigx_abs_FCstd_6875.*sigx_abs_FCstd_6875;
sigy_sq_FCstd_6875 = sigy_abs_FCstd_6875.*sigy_abs_FCstd_6875;
sigx_sq_SLstd_6875 = sigx_abs_SLstd_6875.*sigx_abs_SLstd_6875;
sigy_sq_SLstd_6875 = sigy_abs_SLstd_6875.*sigy_abs_SLstd_6875;
sigx_sq_R33std_6875 = sigx_abs_R33std_6875.*sigx_abs_R33std_6875;
sigy_sq_R33std_6875 = sigy_abs_R33std_6875.*sigy_abs_R33std_6875;
sigx_sq_6875 = sigx_abs_6875.*sigx_abs_6875;
sigy_sq_6875 = sigy_abs_6875.*sigy_abs_6875;
sigx_sq_All_6875 = sigx_abs_6875.*sigx_abs_6875;
sigy_sq_All_6875 = sigy_abs_6875.*sigy_abs_6875;

rho_sigx_sigy_FCstd_6875 = sigx_abs_FCstd_6875.*sigy_abs_FCstd_6875.*FCstd_rho_6875;
rho_sigx_sigy_SLstd_6875 = sigx_abs_SLstd_6875.*sigy_abs_SLstd_6875.*SLstd_rho_6875;
rho_sigx_sigy_R33std_6875 = sigx_abs_R33std_6875.*sigy_abs_R33std_6875.*R33std_rho_6875;
rho_sigx_sigy_6875 = sigx_abs_6875.*sigy_abs_6875.*rho_6875;
rho_sigx_sigy_All_6875 = sigx_abs_6875.*sigy_abs_6875.*rho_6875;

%% CALCULATE 68-82 CONCORDIA ELLIPSES

sigmarule=1.5;
numpoints=50;
errcorr_fix_6882 = 0.7;
errcorr_hi_6882 = errcorr_6882 > 1;
errcorr_lo_6882 = errcorr_6882 < 0;
errcorr_6882_bad = sum(errcorr_hi_6882) + sum(errcorr_lo_6882);
for i = 1:length(errcorr_6882)
    if errcorr_6882(i,:) < 0
        errcorr_corr_6882(i,:) = errcorr_fix_6882;
    elseif errcorr_6882(i,:) > 1
        errcorr_corr_6882(i,:) = errcorr_fix_6882;
    else
        errcorr_corr_6882(i,:) = errcorr_6882(i,:);
    end
end

FCstd_rho_6882 = nonzeros(H.FCstd_idx.*errcorr_corr_6882);
SLstd_rho_6882 = nonzeros(H.SLstd_idx.*errcorr_corr_6882);
R33std_rho_6882 = nonzeros(H.R33std_idx.*errcorr_corr_6882);
rho_6882 = errcorr_corr_6882;

FCstd_concordia_data_6882 = [nonzeros(H.FCstd_idx.*ratio82),nonzeros(H.FCstd_idx.*ratio82err),nonzeros(H.FCstd_idx.*ratio68),nonzeros(H.FCstd_idx.*ratio68err)];
SLstd_concordia_data_6882 = [nonzeros(H.SLstd_idx.*ratio82),nonzeros(H.SLstd_idx.*ratio82err),nonzeros(H.SLstd_idx.*ratio68),nonzeros(H.SLstd_idx.*ratio68err)];
R33std_concordia_data_6882 = [nonzeros(H.R33std_idx.*ratio82),nonzeros(H.R33std_idx.*ratio82err),nonzeros(H.R33std_idx.*ratio68),nonzeros(H.R33std_idx.*ratio68err)];
concordia_data_6882 = [ratio82,ratio82err,ratio68,ratio68err];
All_concordia_data_6882 = [ratio82,ratio82err,ratio68,ratio68err];

center_FCstd_6882 = [FCstd_concordia_data_6882(:,1),FCstd_concordia_data_6882(:,3)];
center_SLstd_6882 = [SLstd_concordia_data_6882(:,1),SLstd_concordia_data_6882(:,3)];
center_R33std_6882 = [R33std_concordia_data_6882(:,1),R33std_concordia_data_6882(:,3)];
center_6882 = [concordia_data_6882(:,1),concordia_data_6882(:,3)];
center_All_6882 = [concordia_data_6882(:,1),concordia_data_6882(:,3)];

sigx_abs_FCstd_6882 = FCstd_concordia_data_6882(:,1).*FCstd_concordia_data_6882(:,2).*0.01;
sigy_abs_FCstd_6882 = FCstd_concordia_data_6882(:,3).*FCstd_concordia_data_6882(:,4).*0.01;
sigx_abs_SLstd_6882 = SLstd_concordia_data_6882(:,1).*SLstd_concordia_data_6882(:,2).*0.01;
sigy_abs_SLstd_6882 = SLstd_concordia_data_6882(:,3).*SLstd_concordia_data_6882(:,4).*0.01;
sigx_abs_R33std_6882 = R33std_concordia_data_6882(:,1).*R33std_concordia_data_6882(:,2).*0.01;
sigy_abs_R33std_6882 = R33std_concordia_data_6882(:,3).*R33std_concordia_data_6882(:,4).*0.01;
sigx_abs_6882 = concordia_data_6882(:,1).*concordia_data_6882(:,2).*0.01;
sigy_abs_6882 = concordia_data_6882(:,3).*concordia_data_6882(:,4).*0.01;
sigx_abs_All_6882 = concordia_data_6882(:,1).*concordia_data_6882(:,2).*0.01;
sigy_abs_All_6882 = concordia_data_6882(:,3).*concordia_data_6882(:,4).*0.01;
sigx_sq_FCstd_6882 = sigx_abs_FCstd_6882.*sigx_abs_FCstd_6882;
sigy_sq_FCstd_6882 = sigy_abs_FCstd_6882.*sigy_abs_FCstd_6882;
sigx_sq_SLstd_6882 = sigx_abs_SLstd_6882.*sigx_abs_SLstd_6882;
sigy_sq_SLstd_6882 = sigy_abs_SLstd_6882.*sigy_abs_SLstd_6882;
sigx_sq_R33std_6882 = sigx_abs_R33std_6882.*sigx_abs_R33std_6882;
sigy_sq_R33std_6882 = sigy_abs_R33std_6882.*sigy_abs_R33std_6882;
sigx_sq_6882 = sigx_abs_6882.*sigx_abs_6882;
sigy_sq_6882 = sigy_abs_6882.*sigy_abs_6882;
sigx_sq_All_6882 = sigx_abs_6882.*sigx_abs_6882;
sigy_sq_All_6882 = sigy_abs_6882.*sigy_abs_6882;

rho_sigx_sigy_FCstd_6882 = sigx_abs_FCstd_6882.*sigy_abs_FCstd_6882.*FCstd_rho_6882;
rho_sigx_sigy_SLstd_6882 = sigx_abs_SLstd_6882.*sigy_abs_SLstd_6882.*SLstd_rho_6882;
rho_sigx_sigy_R33std_6882 = sigx_abs_R33std_6882.*sigy_abs_R33std_6882.*R33std_rho_6882;
rho_sigx_sigy_6882 = sigx_abs_6882.*sigy_abs_6882.*rho_6882;
rho_sigx_sigy_All_6882 = sigx_abs_6882.*sigy_abs_6882.*rho_6882;

%% POPULATE LISTBOX, H.sample INTENSITIES, AND PLOT INDIVIDUAL H.sample RAW DATA %% to 1824

for i=1:length(H.sample)
    H.name_char(i,1)=(H.sample(i,1));
end
H.name_idx = length(H.sample);

for i=1:length(H.sample)
    if isempty(comment{i,1}) == 0 && modenum(i,1) ~= 1 && H.current_status_num_operator_reject(i,1) == 0
        H.name_char(i,1) = strcat('<html><BODY bgcolor="red">',H.name_char(i,1),'</span></html>');
    end
end
for i=1:length(H.sample)
    if isempty(comment{i,1}) == 0 && modenum(i,1) ~= 1 && H.current_status_num_operator_reject(i,1) == 1
        H.name_char(i,1) = strcat('<html><BODY bgcolor="blue">',H.name_char(i,1),'</span></html>');
    end
end
for i=1:length(H.sample)
    if isempty(comment{i,1}) == 0 && modenum(i,1) ~= 1 && H.current_status_num_operator_accept(i,1) == 1
        H.name_char(i,1) = strcat('<html><BODY bgcolor="green">',H.name_char(i,1),'</span></html>');
    end
end
for i=1:length(H.sample)
    if reject68std(i,1) == 1 && H.current_status_num_operator_accept(i,1) == 0
        H.name_char(i,1) = strcat('<html><BODY bgcolor="yellow">',H.name_char(i,1),'</span></html>');
    end
end
for i=1:length(H.sample)
    if reject67std(i,1) == 1 && H.current_status_num_operator_accept(i,1) == 0
        H.name_char(i,1) = strcat('<html><BODY bgcolor="yellow">',H.name_char(i,1),'</span></html>');
    end
end
for i=1:length(H.sample)
    if H.AnalysisValues(20,3,i) == 100100
        H.name_char(i,1) = strcat('<html><BODY bgcolor="black">',H.name_char(i,1),'</span></html>');
    end
end
set(H.listbox1, 'String', H.name_char);

Ablate = 30/60:30/60:30;

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
xc = exp(0.00000000098485.*time3)-1;
yc = exp(0.000000000155125.*time3)-1;

for i = 1:H.NumAnalyses
    if isempty(comment{i,1}) == 1
        current_status{i,1} = ['Accepted'];
        current_status_num(i,1) = 1;
    end
end

%% Calculating systematic uncertainties

for i = 1:H.NumAnalyses % FF systematic error for 206/238
    if Age68err_2s(i,1) < 10
        fferr68(i,1) = 100*(ffswse68(i,1)/ffsw68(i,1)); %(1sigma)
    else
        fferr68(i,1) = 0;
    end
end
FF68err = round(mean(nonzeros(fferr68)),2); %1 sigma
PBC68err = round(mean(nonzeros(pbcerr68)),3); % 1 sigma

for i = 1:H.NumAnalyses % Total systematic error for 206/238 (added fifth term for long-term reproducibility)
    if Age68err(i,1) < 10
        syst_err_68(i,1) = sqrt(FF68err*FF68err+PBC68err*PBC68err+DC238err*DC238err+FC68err*FC68err+LT68err*LT68err); %all at 1 sigma
    else
        syst_err_68(i,1) = 0;
    end
end

systerr68 = round(2*mean(nonzeros(syst_err_68)),2); %206/238 systematic error at 2-sigma

for i = 1:H.NumAnalyses % FF systematic error for 206/207
    if Age67(i,1) > str2num(get(H.filter_cutoff,'String')) 
        fferr67(i,1) = 100*(ffswse67(i,1)/ffsw67(i,1)); % at 1-sigma
    else
        fferr67(i,1) = 0;
    end
end
FF67err = round(mean(nonzeros(fferr67)),2); % at 1-sigma
PBC67err = round(mean(nonzeros(pbcerr67)),3); % at 1-sigma

for i = 1:H.NumAnalyses % Total systematic error for 206/207 (added fifth term for long-term reproducibility) at 1-sigma
    if  Age67(i,1) > str2num(get(H.filter_cutoff,'String')) 
        syst_err_67(i,1) = sqrt(FF67err*FF67err+PBC67err*PBC67err+DC238err*DC238err+DC235err*DC235err+FC67err*FC67err+LT67err*LT67err);
    end
end

systerr67 = round(2*mean(nonzeros(syst_err_67)),2); %206/207 systematic error at 2-sigma

for i = 1:H.NumAnalyses % FF systematic error for 208/232
    if Age82(i,1) > str2num(get(H.filter_cutoff,'String'))  %Age82err(i,1) < 10
        fferr82(i,1) = 100*(ffswse82(i,1)/ffsw82(i,1)); % at 1-sigma
    else
        fferr82(i,1) = 0;
    end
end
FF82err = round(mean(nonzeros(fferr82)),2); % at 1-sigma
PBC82err = round(mean(nonzeros(pbcerr82)),3); % at 1-sigma

for i = 1:H.NumAnalyses % Total systematic error for 208/232 (added fifth term for long-term reproducibility) at 1-sigma
    if  Age82(i,1) > str2num(get(H.filter_cutoff,'String')) 
        syst_err_82(i,1) = sqrt(FF82err*FF82err+PBC82err*PBC82err+DC238err*DC238err+DC235err*DC235err+FC82err*FC82err+LT82err*LT82err);
    end
end

systerr82 = round(2*mean(nonzeros(syst_err_82)),2); %208/232 systematic error at 2-sigma

H.LT68err=LT68err; H.DC238err=DC238err; H.PBC68err=PBC68err; H.FF68err=FF68err; H.FC68err=FC68err;
H.LT67err=LT67err; H.DC235err=DC235err; H.PBC67err=PBC67err; H.FF67err=FF67err; H.FC67err=FC67err;
H.LT82err=LT82err; H.DC232err=DC232err; H.PBC82err=PBC82err; H.FF82err=FF82err; H.FC82err=FC82err;

set(H.StdErr68, 'String', systerr68);
set(H.StdErr67, 'String', systerr67);
set(H.StdErr82, 'String', systerr82);

H.systerr68=systerr68; H.systerr67=systerr67; H.systerr82=systerr82;

guidata(hObject,H);

%% SET HANDLES

export_dist = 0;

H.current_status = current_status; H.current_status_num = current_status_num; H.analysis_num = analysis_num; H.comment = comment; H.serial=serial; H.mode=mode; H.modenum=modenum;
H.ff68=ff68;H.ff67=ff67; H.ff82=ff82; H.ff68rej=ff68rej;H.ff67rej=ff67rej; H.ff82rej=ff82rej;
H.ffse68_hi = ffse68_hi; H.ffse68_lo = ffse68_lo; H.ffsw68 = ffsw68; H.ffsw68init = ffsw68init;
H.ffse67_hi = ffse67_hi; H.ffse67_lo = ffse67_lo;
H.ffse82_hi = ffse82_hi; H.ffse82_lo = ffse82_lo; H.ffsw82 = ffsw82;
H.odf68=odf68; H.odf67=odf67; H.odf82=odf82; 

H.sigx_sq_FCstd_6875 = sigx_sq_FCstd_6875; H.rho_sigx_sigy_FCstd_6875 = rho_sigx_sigy_FCstd_6875; H.sigy_sq_FCstd_6875 = sigy_sq_FCstd_6875; H.numpoints = numpoints; H.sigmarule = sigmarule;
H.center_FCstd_6875 = center_FCstd_6875; H.sigx_sq_SLstd_6875 = sigx_sq_SLstd_6875; H.rho_sigx_sigy_SLstd_6875 = rho_sigx_sigy_SLstd_6875;
H.sigy_sq_SLstd_6875 = sigy_sq_SLstd_6875; H.center_SLstd_6875 = center_SLstd_6875; H.sigx_sq_R33std_6875 = sigx_sq_R33std_6875; H.rho_sigx_sigy_R33std_6875 = rho_sigx_sigy_R33std_6875;
H.sigy_sq_R33std_6875 = sigy_sq_R33std_6875; H.center_R33std_6875 = center_R33std_6875; H.sigx_sq_All_6875 = sigx_sq_All_6875; H.rho_sigx_sigy_All_6875 = rho_sigx_sigy_All_6875;
H.sigy_sq_All_6875 = sigy_sq_All_6875; H.center_All_6875 = center_All_6875; H.rho_6875 = rho_6875; H.errcorr_6875 = errcorr_6875;

H.sigx_sq_FCstd_6882 = sigx_sq_FCstd_6882; H.rho_sigx_sigy_FCstd_6882 = rho_sigx_sigy_FCstd_6882; H.sigy_sq_FCstd_6882 = sigy_sq_FCstd_6882; H.numpoints = numpoints; H.sigmarule = sigmarule;
H.center_FCstd_6882 = center_FCstd_6882; H.sigx_sq_SLstd_6882 = sigx_sq_SLstd_6882; H.rho_sigx_sigy_SLstd_6882 = rho_sigx_sigy_SLstd_6882;
H.sigy_sq_SLstd_6882 = sigy_sq_SLstd_6882; H.center_SLstd_6882 = center_SLstd_6882; H.sigx_sq_R33std_6882 = sigx_sq_R33std_6882; H.rho_sigx_sigy_R33std_6882 = rho_sigx_sigy_R33std_6882;
H.sigy_sq_R33std_6882 = sigy_sq_R33std_6882; H.center_R33std_6882 = center_R33std_6882; H.sigx_sq_All_6882 = sigx_sq_All_6882; H.rho_sigx_sigy_All_6882 = rho_sigx_sigy_All_6882;
H.sigy_sq_All_6882 = sigy_sq_All_6882; H.center_All_6882 = center_All_6882; H.rho_6882 = rho_6882; H.errcorr_6882 = errcorr_6882;

H.ratio75 = ratio75; H.ratio75err = ratio75err; H.ratio75err_2s=ratio75err_2s; H.Uppm=Uppm; H.Thppm=Thppm; H.UTh=UTh; 
H.ratio68 = ratio68; H.ratio68err = ratio68err; H.Best_Age = Best_Age; H.Best_Age_err = Best_Age_err;  H.Age82 = Age82; H.Age82err = Age82err;
H.Age68 = Age68; H.Age68err = Age68err; H.Age67 = Age67; H.Age67err = Age67err; H.Age67err_2s = Age67err_2s; H.Age68err = Age68err; H.Age68err_2s = Age68err_2s;
H.xc = xc; H.yc = yc;  H.pbcerr67 = pbcerr67; H.pbcerr68 = pbcerr68; H.ffswse68 = ffswse68; H.ffsw67 = ffsw67; H.ffswse67 = ffswse67; H.Age75 = Age75;
H.export_dist = export_dist; reduced = 1; H.reduced = reduced; H.Ablate = Ablate; H.CalcValues = CalcValues; H.PeakValues = PeakValues; H.BkgdValues = BkgdValues;
H.reject68std=reject68std; H.reject67std=reject67std; H.reject82std=reject82std; H.comment=comment; H.ratio68err_2s=ratio68err_2s; H.fcbc67=fcbc67; H.ratio67err_2s=ratio67err_2s;
H.corrected64=corrected64; H.Age75err_2s=Age75err_2s; H.Age82err_2s=Age82err_2s; H.Best_Age_err_2s=Best_Age_err_2s; H.ratio82=ratio82; H.ratio82err_2s=ratio82err_2s;

%end of reduce_data function

H.export_fract = 0;
H.export_comp = 0;
H.export_dist = 0;

plot_compare(hObject, eventdata, H)
listbox1_Callback(hObject, eventdata, H)
plot_session_fract(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)

%% Session Fractionation Plots to 1993

function plot_session_fract(hObject, eventdata, H)

FC_IC_x = zeros(H.NumAnalyses,1);
FC_IC_y = zeros(H.NumAnalyses,1);
FC_IC_x_rej = zeros(H.NumAnalyses,1);
FC_IC_y_rej = zeros(H.NumAnalyses,1);
FC_MI_x = zeros(H.NumAnalyses,1);
FC_MI_y = zeros(H.NumAnalyses,1);
FC_AN_x = zeros(H.NumAnalyses,1);
FC_AN_y = zeros(H.NumAnalyses,1);

SL_IC_x = zeros(H.NumAnalyses,1);
SL_IC_y = zeros(H.NumAnalyses,1);
SL_IC_x_rej = zeros(H.NumAnalyses,1);
SL_IC_y_rej = zeros(H.NumAnalyses,1);
SL_MI_x = zeros(H.NumAnalyses,1);
SL_MI_y = zeros(H.NumAnalyses,1);
SL_AN_x = zeros(H.NumAnalyses,1);
SL_AN_y = zeros(H.NumAnalyses,1);

R33_IC_x = zeros(H.NumAnalyses,1);
R33_IC_y = zeros(H.NumAnalyses,1);
R33_IC_x_rej = zeros(H.NumAnalyses,1);
R33_IC_y_rej = zeros(H.NumAnalyses,1);
R33_MI_x = zeros(H.NumAnalyses,1);
R33_MI_y = zeros(H.NumAnalyses,1);
R33_AN_x = zeros(H.NumAnalyses,1);
R33_AN_y = zeros(H.NumAnalyses,1);

FC_67_x = zeros(H.NumAnalyses,1);
FC_67_y = zeros(H.NumAnalyses,1);
FC_67_x_rej = zeros(H.NumAnalyses,1);
FC_67_y_rej = zeros(H.NumAnalyses,1);
SL_67_x = zeros(H.NumAnalyses,1);
SL_67_y = zeros(H.NumAnalyses,1);
SL_67_x_rej = zeros(H.NumAnalyses,1);
SL_67_y_rej = zeros(H.NumAnalyses,1);

FC_82_x = zeros(H.NumAnalyses,1);
FC_82_y = zeros(H.NumAnalyses,1);
SL_82_x = zeros(H.NumAnalyses,1);
SL_82_y = zeros(H.NumAnalyses,1);
R33_82_x = zeros(H.NumAnalyses,1);
R33_82_y = zeros(H.NumAnalyses,1);
FC_82_x_rej = zeros(H.NumAnalyses,1);
FC_82_y_rej = zeros(H.NumAnalyses,1);
SL_82_x_rej = zeros(H.NumAnalyses,1);
SL_82_y_rej = zeros(H.NumAnalyses,1);
R33_82_x_rej = zeros(H.NumAnalyses,1);
R33_82_y_rej = zeros(H.NumAnalyses,1);

Use_SL_68 = get(H.Use_SL_68, 'Value'); % checkbox
Use_SL_67 = get(H.Use_SL_67, 'Value'); % checkbox
Use_R33_68 = get(H.Use_R33_68, 'Value'); % checkbox

for i = 1:H.NumAnalyses % FF Plots for FC 206/238
    if H.FCstd_idx(i,1) == 1 && H.modenum(i,1) == 2 && H.reject68std(i,1) == 0 % FF Plot for FC-IC 206/238
        FC_IC_x(i,1) = H.analysis_num(i,1);
        FC_IC_y(i,1) = H.ff68(i,1); 
    end
    if H.FCstd_idx(i,1) == 1 && H.modenum(i,1) == 2 && H.reject68std(i,1) == 1 % FF Plot for FC-IC 206/238 rejected
        FC_IC_x_rej(i,1) = H.analysis_num(i,1);
        FC_IC_y_rej(i,1) = H.STD_FC_68/(H.CalcValues(i,8)*(H.corrected64(i,1)-H.STD_FC_64c)/H.corrected64(i,1)); 
    end
    if H.FCstd_idx(i,1) == 1 && H.modenum(i,1) == 3 && H.reject68std(i,1) == 0  %FF Plot for FC-MI 206/238
        FC_MI_x(i,1) = H.analysis_num(i,1);
        FC_MI_y(i,1) = H.ff68(i,1); 
    end
    if H.FCstd_idx(i,1) == 1 && H.modenum(i,1) == 4 && H.reject68std(i,1) == 0 %FF Plot for FC-AN 206/238
        FC_AN_x(i,1) = H.analysis_num(i,1);
        FC_AN_y(i,1) = H.ff68(i,1); 
    end
end

for i = 1:H.NumAnalyses  % FF Plots for SL 206/238
    if H.SLstd_idx(i,1) == 1 && H.modenum(i,1) == 2 && H.reject68std(i,1) == 0 % FF Plot for SL-IC 206/238
        SL_IC_x(i,1) = H.analysis_num(i,1);
        SL_IC_y(i,1) = H.ff68(i,1); 
    end
    if H.SLstd_idx(i,1) == 1 && H.modenum(i,1) == 2 && H.reject68std(i,1) == 1 && get(H.Use_SL_68,'Value') == 1 % FF Plot for SL-IC 206/238 rejected && H.modenum(i,1) == 2 
        SL_IC_x_rej(i,1) = H.analysis_num(i,1);
        SL_IC_y_rej(i,1) = H.STD_SL_68/(H.CalcValues(i,8)*(H.corrected64(i,1)-H.STD_SL_64c)/H.corrected64(i,1)); 
    end
    if H.SLstd_idx(i,1) == 1 && H.modenum(i,1) == 2 && get(H.Use_SL_68,'Value') == 0 % FF Plot for SL-IC 206/238 rejected 
        SL_IC_x_rej(i,1) = H.analysis_num(i,1);
        SL_IC_y_rej(i,1) = H.STD_SL_68/(H.CalcValues(i,8)*(H.corrected64(i,1)-H.STD_SL_64c)/H.corrected64(i,1)); 
    end
    if H.SLstd_idx(i,1) == 1 && H.modenum(i,1) == 3 && H.reject68std(i,1) == 0 % FF Plot for SL-MI 206/238
        SL_MI_x(i,1) = H.analysis_num(i,1);
        SL_MI_y(i,1) = H.ff68(i,1); 
    end
    if H.SLstd_idx(i,1) == 1 && H.modenum(i,1) == 4 && H.reject68std(i,1) == 0 % FF Plot for SL-AN 206/238
        SL_AN_x(i,1) = H.analysis_num(i,1);
        SL_AN_y(i,1) = H.ff68(i,1); 
    end
end

for i = 1:H.NumAnalyses % FF Plots for R33 206/238
    if H.R33std_idx(i,1) == 1 && H.modenum(i,1) == 2 && H.reject68std(i,1) == 0 % FF Plot for R33-IC 206/238
        R33_IC_x(i,1) = H.analysis_num(i,1);
        R33_IC_y(i,1) = H.ff68(i,1); 
    end
    if H.R33std_idx(i,1) == 1 && H.modenum(i,1) == 2 && H.reject68std(i,1) == 1 && get(H.Use_R33_68,'Value') == 1 % FF Plot for R33-IC 206/238 rejected 
        R33_IC_x_rej(i,1) = H.analysis_num(i,1);
        R33_IC_y_rej(i,1) = H.STD_R33_68/(H.CalcValues(i,8)*(H.corrected64(i,1)-H.STD_R33_64c)/H.corrected64(i,1)); 
    end
    if H.R33std_idx(i,1) == 1 && H.modenum(i,1) == 2 && get(H.Use_R33_68,'Value') == 0 % FF Plot for R33-IC 206/238 rejected 
        R33_IC_x_rej(i,1) = H.analysis_num(i,1);
        R33_IC_y_rej(i,1) = H.STD_R33_68/(H.CalcValues(i,8)*(H.corrected64(i,1)-H.STD_R33_64c)/H.corrected64(i,1)); 
    end
    if H.R33std_idx(i,1) == 1 && H.modenum(i,1) == 3 && H.reject68std(i,1) == 0 % FF Plot for R33-MI 206/238
        R33_MI_x(i,1) = H.analysis_num(i,1);
        R33_MI_y(i,1) = H.ff68(i,1); 
    end
    if H.R33std_idx(i,1) == 1 && H.modenum(i,1) == 4 && H.reject68std(i,1) == 0 % FF Plot for R33-AN 206/238
        R33_AN_x(i,1) = H.analysis_num(i,1);
        R33_AN_y(i,1) = H.ff68(i,1); 
    end
end

for i = 1:H.NumAnalyses % FF Plot values for 206/207
    if H.FCstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.reject67std(i,1) == 0 % FC for FF plot accepted
        FC_67_x(i,1) = H.analysis_num(i,1);
        FC_67_y(i,1) = H.ff67(i,1); 
    end
    if H.FCstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.reject67std(i,1) == 1  % FC for FF plot rejected
        FC_67_x_rej(i,1) = H.analysis_num(i,1);
        FC_67_y_rej(i,1) = H.ff67rej(i,1); 
    end

    if H.SLstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.reject67std(i,1) == 0  %for SL for FF plot accepted
        SL_67_x(i,1) = H.analysis_num(i,1);
        SL_67_y(i,1) = H.ff67(i,1); 
    end
    if H.SLstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.reject67std(i,1) == 1  %for SL for FF plot rejected
        SL_67_x_rej(i,1) = H.analysis_num(i,1);
        SL_67_y_rej(i,1) = H.ff67rej(i,1); 
    end
end

% Fract Plot values for 208/232
for i = 1:H.NumAnalyses
    if H.FCstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.reject82std(i,1) == 0 % FC for FF plot accepted
        FC_82_x(i,1) = H.analysis_num(i,1);
        FC_82_y(i,1) = H.ff82(i,1); 
    end
    if H.FCstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.reject82std(i,1) == 1  % FC for FF plot rejected
        FC_82_x_rej(i,1) = H.analysis_num(i,1);
        FC_82_y_rej(i,1) = H.ff82rej(i,1); 
    end
    if H.SLstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.reject82std(i,1) == 0 % SL for FF plot accepted
        SL_82_x(i,1) = H.analysis_num(i,1);
        SL_82_y(i,1) = H.ff82(i,1); 
    end
    if H.SLstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.reject82std(i,1) == 1  %for SL for FF plot rejected
        SL_82_x_rej(i,1) = H.analysis_num(i,1);
        SL_82_y_rej(i,1) = H.ff82rej(i,1); 
    end
    if H.R33std_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.reject82std(i,1) == 0 % R33 for FF plot accepted
        R33_82_x(i,1) = H.analysis_num(i,1);
        R33_82_y(i,1) = H.ff82(i,1);
    end
    if H.R33std_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.reject82std(i,1) == 1  %for R33 for FF plot rejected
        R33_82_x_rej(i,1) = H.analysis_num(i,1);
        R33_82_y_rej(i,1) = H.ff82rej(i,1); 
    end
end

H.fract68_x = FC_IC_x + FC_IC_x_rej + FC_MI_x+ FC_AN_x+ SL_IC_x + SL_IC_x_rej + SL_MI_x + SL_AN_x + R33_IC_x + R33_IC_x_rej + R33_MI_x + R33_AN_x;
H.fract68_y = FC_IC_y + FC_IC_y_rej + FC_MI_y+ FC_AN_y+ SL_IC_y + SL_IC_y_rej + SL_MI_y + SL_AN_y + R33_IC_y + R33_IC_y_rej + R33_MI_y + R33_AN_y;

FC_IC_x = nonzeros(FC_IC_x);
FC_IC_y = nonzeros(FC_IC_y);
FC_IC_x_rej = nonzeros(FC_IC_x_rej);
FC_IC_y_rej = nonzeros(FC_IC_y_rej);
FC_MI_x = nonzeros(FC_MI_x);
FC_MI_y = nonzeros(FC_MI_y);
FC_AN_x = nonzeros(FC_AN_x);
FC_AN_y = nonzeros(FC_AN_y);

SL_IC_x = nonzeros(SL_IC_x);
SL_IC_y = nonzeros(SL_IC_y);
SL_IC_x_rej = nonzeros(SL_IC_x_rej);
SL_IC_y_rej = nonzeros(SL_IC_y_rej);
SL_MI_x = nonzeros(SL_MI_x);
SL_MI_y = nonzeros(SL_MI_y);
SL_AN_x = nonzeros(SL_AN_x);
SL_AN_y = nonzeros(SL_AN_y);

R33_IC_x = nonzeros(R33_IC_x);
R33_IC_y = nonzeros(R33_IC_y);
R33_IC_x_rej = nonzeros(R33_IC_x_rej);
R33_IC_y_rej = nonzeros(R33_IC_y_rej);
R33_MI_x = nonzeros(R33_MI_x);
R33_MI_y = nonzeros(R33_MI_y);
R33_AN_x = nonzeros(R33_AN_x);
R33_AN_y = nonzeros(R33_AN_y);

FC_67_x = nonzeros(FC_67_x);
FC_67_y = nonzeros(FC_67_y);
FC_67_x_rej = nonzeros(FC_67_x_rej);
FC_67_y_rej = nonzeros(FC_67_y_rej);
SL_67_x = nonzeros(SL_67_x);
SL_67_y = nonzeros(SL_67_y);
SL_67_x_rej = nonzeros(SL_67_x_rej);
SL_67_y_rej = nonzeros(SL_67_y_rej);

FC_82_x = nonzeros(FC_82_x);
FC_82_y = nonzeros(FC_82_y);
SL_82_x = nonzeros(SL_82_x);
SL_82_y = nonzeros(SL_82_y);
R33_82_x = nonzeros(R33_82_x);
R33_82_y = nonzeros(R33_82_y);
FC_82_x_rej = nonzeros(FC_82_x_rej);
FC_82_y_rej = nonzeros(FC_82_y_rej);
SL_82_x_rej = nonzeros(SL_82_x_rej);
SL_82_y_rej = nonzeros(SL_82_y_rej);
R33_82_x_rej = nonzeros(R33_82_x_rej);
R33_82_y_rej = nonzeros(R33_82_y_rej);

Use_SL_68 = get(H.Use_SL_68, 'Value'); % checkbox
Use_SL_67 = get(H.Use_SL_67, 'Value'); % checkbox
Use_R33_68 = get(H.Use_R33_68, 'Value'); % checkbox

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
if get(H.plot_fract_68,'Value') == 1 && get(H.Use_SL_68,'Value') == 1 && get(H.Use_R33_68,'Value') == 1  % 206/238 fractionation plot with H.FC and SL and R33
    fill([(1:1:H.NumAnalyses)';flipud((1:1:H.NumAnalyses)')], [H.ffse68_hi; flipud(H.ffse68_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
    plot([(1:1:H.NumAnalyses); (1:1:H.NumAnalyses)], [(H.ffsw68+H.ffsw68*0.02)'; (H.ffsw68-H.ffsw68*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',.5) % Error bars
    plot(1:1:H.NumAnalyses,H.ffsw68init,'k','LineWidth',1,'LineStyle','--');
    plot(1:1:H.NumAnalyses,H.ffsw68,'k','LineWidth',1.5);
    h1 = scatter(FC_IC_x, FC_IC_y, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
    h2 = scatter(FC_MI_x, FC_MI_y, 75, 'r', 'd', 'LineWidth', 1.25);
    h3 = scatter(FC_AN_x, FC_AN_y, 75, 'r', 'x', 'LineWidth', 1.25);
    h4 = scatter(SL_IC_x, SL_IC_y, 75, 'b', 'filled', 'd', 'LineWidth', 1.25);
    h5 = scatter(SL_MI_x, SL_MI_y, 75, 'b', 'd', 'LineWidth', 1.25);
    h6 = scatter(SL_AN_x, SL_AN_y, 75, 'b', 'x', 'LineWidth', 1.25);
    h7 = scatter(R33_IC_x, R33_IC_y, 75, 'g', 'filled','d', 'LineWidth', 1.25);
    h8 = scatter(R33_MI_x, R33_MI_y, 75, 'g', 'd','LineWidth', 1.25);
    h9 = scatter(R33_AN_x, R33_AN_y, 75, 'g', 'x', 'LineWidth', 1.25);
    h10 = scatter(FC_IC_x_rej, FC_IC_y_rej, 50, 'r', 'd', 'LineWidth', 0.75);
    h11 = scatter(SL_IC_x_rej, SL_IC_y_rej, 50, 'b', 'd', 'LineWidth', 0.75);
    h12 = scatter(R33_IC_x_rej, R33_IC_y_rej, 50, 'g', 'd', 'LineWidth', 0.75);
    leg = legend([h1 h4 h7],{'FC','SL','R33'}); % was leg =
    leg.NumColumns = 5;
    H.loc_68_unk = scatter(H.analysis_num(get(H.listbox1,'Value')),H.ffsw68(get(H.listbox1,'Value')),30, 'c', 'LineWidth', 2, 'MarkerEdgeColor', 'y');
    H.loc_68_std = scatter(H.fract68_x(get(H.listbox1,'Value')),H.fract68_y(get(H.listbox1,'Value')),200, 's', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
    hold off
    ylabel('206/238 fractionation factor')
    axis([0 H.NumAnalyses+1 min([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y;R33_IC_y;R33_MI_y;R33_AN_y])-...
        0.04*min([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y;R33_IC_y;R33_MI_y;R33_AN_y])...
        max([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y;R33_IC_y;R33_MI_y;R33_AN_y])+...
        0.04*max([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y;R33_IC_y;R33_MI_y;R33_AN_y])])
    box on
end

if get(H.plot_fract_68,'Value') == 1 && get(H.Use_SL_68,'Value') == 0 && get(H.Use_R33_68,'Value') == 1 % 206/238 fractionation plot with FC and R33
    fill([(1:1:H.NumAnalyses)';flipud((1:1:H.NumAnalyses)')], [H.ffse68_hi; flipud(H.ffse68_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
    plot([(1:1:H.NumAnalyses); (1:1:H.NumAnalyses)], [(H.ffsw68+H.ffsw68*0.02)'; (H.ffsw68-H.ffsw68*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',.5) % Error bars
    plot(1:1:H.NumAnalyses,H.ffsw68init,'k','LineWidth',1,'LineStyle','--');
    plot(1:1:H.NumAnalyses,H.ffsw68,'k','LineWidth',1.5);
    h1 = scatter(FC_IC_x, FC_IC_y, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
    h2 = scatter(FC_MI_x, FC_MI_y, 75, 'r', 'd', 'LineWidth', 1.25);
    h3 = scatter(FC_AN_x, FC_AN_y, 75, 'r', 'x', 'LineWidth', 1.25);
    h7 = scatter(R33_IC_x, R33_IC_y, 75, 'g', 'filled','d', 'LineWidth', 1.25);
    h8 = scatter(R33_MI_x, R33_MI_y, 75, 'g', 'd','LineWidth', 1.25);
    h9 = scatter(R33_AN_x, R33_AN_y, 75, 'g', 'x', 'LineWidth', 1.25);
    h10 = scatter(FC_IC_x_rej, FC_IC_y_rej, 50, 'r', 'd', 'LineWidth', 0.75);
    h11 = scatter(SL_IC_x_rej, SL_IC_y_rej, 50, 'b', 'd', 'LineWidth', 0.75);
    h12 = scatter(R33_IC_x_rej, R33_IC_y_rej, 50, 'g', 'd', 'LineWidth', 0.75);
    leg = legend([h1 h7],{'FC', 'R33'}); % was leg =
    leg.NumColumns = 4;
    H.loc_68_unk = scatter(H.analysis_num(get(H.listbox1,'Value')),H.ffsw68(get(H.listbox1,'Value')),30, 'c', 'LineWidth', 2, 'MarkerEdgeColor', 'y');
    H.loc_68_std = scatter(H.fract68_x(get(H.listbox1,'Value')),H.fract68_y(get(H.listbox1,'Value')),200, 's', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
    hold off
    ylabel('206/238 fractionation factor')
    axis([0 H.NumAnalyses+1 min([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y])-...
        0.04*min([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y])...
        max([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y])+...
        0.04*max([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y])])
    box on
end

if get(H.plot_fract_68,'Value') == 1 && get(H.Use_SL_68,'Value') == 0 && get(H.Use_R33_68,'Value') == 0 % 206/238 fractionation plot with FC
    fill([(1:1:H.NumAnalyses)';flipud((1:1:H.NumAnalyses)')], [H.ffse68_hi; flipud(H.ffse68_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
    plot([(1:1:H.NumAnalyses); (1:1:H.NumAnalyses)], [(H.ffsw68+H.ffsw68*0.02)'; (H.ffsw68-H.ffsw68*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',.5) % Error bars
    plot(1:1:H.NumAnalyses,H.ffsw68init,'k','LineWidth',1,'LineStyle','--');
    plot(1:1:H.NumAnalyses,H.ffsw68,'k','LineWidth',1.5);
    h1 = scatter(FC_IC_x, FC_IC_y, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
    h2 = scatter(FC_MI_x, FC_MI_y, 75, 'r', 'd', 'LineWidth', 1.25);
    h3 = scatter(FC_AN_x, FC_AN_y, 75, 'r', 'x', 'LineWidth', 1.25);
    h4 = scatter(FC_IC_x_rej, FC_IC_y_rej, 50, 'r', 'd', 'LineWidth', 0.75);
    h5 = scatter(SL_IC_x_rej, SL_IC_y_rej, 50, 'b', 'd', 'LineWidth', 0.75);
    h6 = scatter(R33_IC_x_rej, R33_IC_y_rej, 50, 'g', 'd', 'LineWidth', 0.75);
    leg = legend([h1],{'FC'}); 
    leg.NumColumns = 3;
    H.loc_68_unk = scatter(H.analysis_num(get(H.listbox1,'Value')),H.ffsw68(get(H.listbox1,'Value')),30, 'c', 'LineWidth', 2, 'MarkerEdgeColor', 'y');
    H.loc_68_std = scatter(H.fract68_x(get(H.listbox1,'Value')),H.fract68_y(get(H.listbox1,'Value')),200, 's', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
    hold off
    ylabel('206/238 fractionation factor')
    axis([0 H.NumAnalyses+1 min([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y])-...
        0.04*min([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y])...
        max([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y])+...
        0.04*max([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y])])
    box on
end

if get(H.plot_fract_68,'Value') == 1 && get(H.Use_SL_68,'Value') == 1 && get(H.Use_R33_68,'Value') == 0  % 206/238 fractionation plot with FC and SL
    fill([(1:1:H.NumAnalyses)';flipud((1:1:H.NumAnalyses)')], [H.ffse68_hi; flipud(H.ffse68_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
    plot([(1:1:H.NumAnalyses); (1:1:H.NumAnalyses)], [(H.ffsw68+H.ffsw68*0.02)'; (H.ffsw68-H.ffsw68*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',.5) % Error bars
    plot(1:1:H.NumAnalyses,H.ffsw68init,'k','LineWidth',1,'LineStyle','--');
    plot(1:1:H.NumAnalyses,H.ffsw68,'k','LineWidth',1.5);
    h1 = scatter(FC_IC_x, FC_IC_y, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
    h2 = scatter(FC_MI_x, FC_MI_y, 75, 'r', 'd', 'LineWidth', 1.25);
    h3 = scatter(FC_AN_x, FC_AN_y, 75, 'r', 'x', 'LineWidth', 1.25);
    h4 = scatter(SL_IC_x, SL_IC_y, 75, 'b', 'filled', 'd', 'LineWidth', 1.25);
    h5 = scatter(SL_MI_x, SL_MI_y, 75, 'b', 'd', 'LineWidth', 1.25);
    h6 = scatter(SL_AN_x, SL_AN_y, 75, 'b', 'x', 'LineWidth', 1.25);
    h10 = scatter(FC_IC_x_rej, FC_IC_y_rej, 50, 'r', 'd', 'LineWidth', 0.75);
    h11 = scatter(SL_IC_x_rej, SL_IC_y_rej, 50, 'b', 'd', 'LineWidth', 0.75);
    h12 = scatter(R33_IC_x_rej, R33_IC_y_rej, 50, 'g', 'd', 'LineWidth', 0.75);
    leg = legend([h1 h4],{'FC', 'SL',}); % was leg =
    leg.NumColumns = 4;
    H.loc_68_unk = scatter(H.analysis_num(get(H.listbox1,'Value')),H.ffsw68(get(H.listbox1,'Value')),30, 'c', 'LineWidth', 2, 'MarkerEdgeColor', 'y');
    H.loc_68_std = scatter(H.fract68_x(get(H.listbox1,'Value')),H.fract68_y(get(H.listbox1,'Value')),200, 's', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
    hold off
    ylabel('206/238 fractionation factor')
    axis([0 H.NumAnalyses+1 min([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y;R33_IC_y;R33_MI_y;R33_AN_y])-...
        0.04*min([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y;R33_IC_y;R33_MI_y;R33_AN_y])...
        max([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y;R33_IC_y;R33_MI_y;R33_AN_y])+...
        0.04*max([(H.ffsw68-H.ffsw68*0.02);FC_IC_y;FC_MI_y;FC_AN_y;SL_IC_y;SL_MI_y;SL_AN_y;R33_IC_y;R33_MI_y;R33_AN_y])])
    box on
end

if get(H.plot_fract_76,'Value') == 1 && get(H.Use_SL_67,'Value') == 1 % 206/207 fractionation plot with FC and SL
    fill([(1:1:H.NumAnalyses)';flipud((1:1:H.NumAnalyses)')], [H.ffse67_hi; flipud(H.ffse67_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
    plot([(1:1:H.NumAnalyses); (1:1:H.NumAnalyses)], [(H.ffsw67+H.ffsw67*0.02)'; (H.ffsw67-H.ffsw67*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',.5) % Error bars
    plot(1:1:H.NumAnalyses,H.ffsw67,'k','LineWidth',1);
    h1 = scatter(FC_67_x, FC_67_y, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
    h2 = scatter(SL_67_x, SL_67_y, 75, 'b', 'filled', 'd', 'LineWidth', 1.25);
    h10 = scatter(FC_67_x_rej, FC_67_y_rej, 50, 'r', 'd', 'LineWidth', 0.75);
    h11 = scatter(SL_67_x_rej, SL_67_y_rej, 50, 'b', 'd', 'LineWidth', 0.75);
    leg = legend([h1 h2],{'FC', 'SL'});
    leg.NumColumns = 2;
    H.loc_67_unk = scatter(H.analysis_num(get(H.listbox1,'Value')),H.ffsw67(get(H.listbox1,'Value')),30, 'c', 'LineWidth', 2, 'MarkerEdgeColor', 'y');
    H.loc_67_std = scatter(H.analysis_num(get(H.listbox1,'Value')),H.ff67(get(H.listbox1,'Value')),200, 's', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
    hold off
    ylabel('206/207 fractionation factor')
    axis([0 H.NumAnalyses+1 min([(H.ffsw67-H.ffsw67*0.02);FC_67_y;SL_67_y])-0.06*min([(H.ffsw67-H.ffsw67*0.02);FC_67_y;SL_67_y]) max([(H.ffsw67-H.ffsw67*0.02);FC_67_y;SL_67_y])+...
        0.06*max([(H.ffsw67-H.ffsw67*0.02);FC_67_y;SL_67_y])])
    box on
end
if get(H.plot_fract_76,'Value') == 1 && get(H.Use_SL_67,'Value') == 0 % 206/207 fractionation plot with FC but no SL
    fill([(1:1:H.NumAnalyses)';flipud((1:1:H.NumAnalyses)')], [H.ffse67_hi; flipud(H.ffse67_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
    plot([(1:1:H.NumAnalyses); (1:1:H.NumAnalyses)], [(H.ffsw67+H.ffsw67*0.02)'; (H.ffsw67-H.ffsw67*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',.5) % Error bars
    plot(1:1:H.NumAnalyses,H.ffsw67,'k','LineWidth',1);
    h1 = scatter(FC_67_x, FC_67_y, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
    h2 = scatter(SL_67_x, SL_67_y, 50, 'b', 'd', 'LineWidth', 0.75);
    h2 = scatter(FC_67_x_rej, FC_67_y_rej, 50, 'r', 'd', 'LineWidth', 0.75);
    h3 = scatter(SL_67_x_rej, SL_67_y_rej, 50, 'b', 'd', 'LineWidth', 0.75);
    leg = legend([h1 h3],{'FC', 'SL'});
    leg.NumColumns = 2;
    H.loc_67_unk = scatter(H.analysis_num(get(H.listbox1,'Value')),H.ffsw67(get(H.listbox1,'Value')),30, 'c', 'LineWidth', 2, 'MarkerEdgeColor', 'y');
    H.loc_67_std = scatter(H.analysis_num(get(H.listbox1,'Value')),H.ff67(get(H.listbox1,'Value')),200, 's', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
    hold off
    ylabel('206/207 fractionation factor')
    axis([0 H.NumAnalyses+1 min([(H.ffsw67-H.ffsw67*0.02);FC_67_y;SL_67_y])-0.06*min([(H.ffsw67-H.ffsw67*0.02);FC_67_y;SL_67_y]) max([(H.ffsw67-H.ffsw67*0.02);FC_67_y;SL_67_y])+...
        0.06*max([(H.ffsw67-H.ffsw67*0.02);FC_67_y;SL_67_y])])
    box on
end

if get(H.plot_fract_82,'Value') == 1 % 208/232 fractionation plot with FC and SL
    fill([(1:1:H.NumAnalyses)';flipud((1:1:H.NumAnalyses)')], [H.ffse82_hi; flipud(H.ffse82_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);
    plot([(1:1:H.NumAnalyses); (1:1:H.NumAnalyses)], [(H.ffsw82+H.ffsw82*0.02)'; (H.ffsw82-H.ffsw82*0.02)'], '-r', 'Color', [.4 .6 1], 'LineWidth',.5) % Error bars
    plot(1:1:H.NumAnalyses,H.ffsw82,'k','LineWidth',1);
    h1 = scatter(FC_82_x, FC_82_y, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
    h2 = scatter(SL_82_x, SL_82_y, 75, 'b', 'filled', 'd', 'LineWidth', 1.25);
    h3 = scatter(R33_82_x, R33_82_y, 75, 'g', 'filled', 'd', 'LineWidth', 1.25);
    h4 = scatter(FC_82_x_rej, FC_82_y_rej, 50, 'r', 'd', 'LineWidth', 0.75);
    h5 = scatter(SL_82_x_rej, SL_82_y_rej, 50, 'b', 'd', 'LineWidth', 0.75);
    h6 = scatter(R33_82_x_rej, R33_82_y_rej, 50, 'g', 'd', 'LineWidth', 0.75);
    leg = legend([h1 h2 h3],{'FC', 'SL', 'R33'});
    leg.NumColumns = 3;
    %H.loc_82_unk = scatter(H.analysis_num(get(H.listbox1,'Value')),H.ffsw82(get(H.listbox1,'Value')),30, 'c', 'LineWidth', 2, 'MarkerEdgeColor', 'y');
    %H.loc_82_std = scatter(H.analysis_num(get(H.listbox1,'Value')),H.ff82(get(H.listbox1,'Value')),200, 's', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
    hold off
    ylabel('208/232 fractionation factor')
    axis([0 H.NumAnalyses+1 min([(H.ffsw82-H.ffsw82*0.02);FC_82_y;SL_82_y;R33_82_y])-0.06*min([(H.ffsw82-H.ffsw82*0.02);FC_82_y;SL_82_y;R33_82_y]) max([(H.ffsw82-H.ffsw82*0.02);FC_82_y;SL_82_y;R33_82_y])+...
        0.06*max([(H.ffsw82-H.ffsw82*0.02);FC_82_y;SL_82_y;R33_82_y])])
    box on
end
%end of plot_session function
H.export_fract = 0;

function plot_fract_68_Callback(hObject, eventdata, H) % 206/238 Fractionation Plot
set(H.plot_fract_68,'Value',1)
set(H.plot_fract_76,'Value',0)
set(H.plot_fract_82,'Value',0)
set(H.axes_session_fractionation,'Visible','on')
%set(H.export_fractionation,'Visible','on')
plot_session_fract(hObject, eventdata, H)

function plot_fract_76_Callback(hObject, eventdata, H) % 206/207 Fractionation Plot
set(H.plot_fract_68,'Value',0)
set(H.plot_fract_76,'Value',1)
set(H.plot_fract_82,'Value',0)
set(H.axes_session_fractionation,'Visible','on')
%set(H.export_fractionation,'Visible','on')
plot_session_fract(hObject, eventdata, H)

function plot_fract_82_Callback(hObject, eventdata, H) % 208/232 Fractionation Plot
set(H.plot_fract_68,'Value',0)
set(H.plot_fract_76,'Value',0)
set(H.plot_fract_82,'Value',1)
set(H.axes_session_fractionation,'Visible','on')
%set(H.export_fractionation,'Visible','on')
plot_session_fract(hObject, eventdata, H)

function export_fractionation_Callback(hObject, eventdata, H) %this can be removed?
H.export_fract = 1;
guidata(hObject,H);
plot_session_fract(hObject, eventdata, H)

%% Create plots in upper right box

function plot_compare(hObject, eventdata, H) % to row 2820 (plots in upper right)

if H.export_comp == 1 && get(H.plottype,'Value') ~= 9 && get(H.plottype,'Value') ~= 10 && get(H.plottype,'Value') ~= 11
    figure;
end
if H.export_comp == 0 && get(H.plottype,'Value') ~= 9 && get(H.plottype,'Value') ~= 10 && get(H.plottype,'Value') ~= 11
    cla(H.axes_comp,'reset');
    axes(H.axes_comp);
end
if get(H.plottype,'Value') ~= 9 && get(H.plottype,'Value') ~= 10 && get(H.plottype,'Value') ~= 11
    H.export_comp = 0;
    guidata(hObject,H);
    hold on
end

sigx_sq_FCstd_6875 = H.sigx_sq_FCstd_6875; rho_sigx_sigy_FCstd_6875 = H.rho_sigx_sigy_FCstd_6875; sigy_sq_FCstd_6875 = H.sigy_sq_FCstd_6875;
center_FCstd_6875 = H.center_FCstd_6875;sigx_sq_SLstd_6875 = H.sigx_sq_SLstd_6875; rho_sigx_sigy_SLstd_6875 = H.rho_sigx_sigy_SLstd_6875;
sigy_sq_SLstd_6875 = H.sigy_sq_SLstd_6875; center_SLstd_6875 = H.center_SLstd_6875; sigy_sq_All_6875 = H.sigy_sq_All_6875; center_All_6875 = H.center_All_6875; 
sigx_sq_R33std_6875 = H.sigx_sq_R33std_6875; rho_sigx_sigy_R33std_6875 = H.rho_sigx_sigy_R33std_6875; sigy_sq_R33std_6875 = H.sigy_sq_R33std_6875;
center_R33std_6875 = H.center_R33std_6875;sigx_sq_All_6875 = H.sigx_sq_All_6875; rho_sigx_sigy_All_6875 = H.rho_sigx_sigy_All_6875;

sigx_sq_FCstd_6882 = H.sigx_sq_FCstd_6882; rho_sigx_sigy_FCstd_6882 = H.rho_sigx_sigy_FCstd_6882; sigy_sq_FCstd_6882 = H.sigy_sq_FCstd_6882;
center_FCstd_6882 = H.center_FCstd_6882;sigx_sq_SLstd_6882 = H.sigx_sq_SLstd_6882; rho_sigx_sigy_SLstd_6882 = H.rho_sigx_sigy_SLstd_6882;
sigy_sq_SLstd_6882 = H.sigy_sq_SLstd_6882; center_SLstd_6882 = H.center_SLstd_6882; sigy_sq_All_6882 = H.sigy_sq_All_6882; center_All_6882 = H.center_All_6882; 
sigx_sq_R33std_6882 = H.sigx_sq_R33std_6882; rho_sigx_sigy_R33std_6882 = H.rho_sigx_sigy_R33std_6882; sigy_sq_R33std_6882 = H.sigy_sq_R33std_6882;
center_R33std_6882 = H.center_R33std_6882;sigx_sq_All_6882 = H.sigx_sq_All_6882; rho_sigx_sigy_All_6882 = H.rho_sigx_sigy_All_6882;

numpoints = H.numpoints; sigmarule = H.sigmarule; sample_idx = H.sample_idx;
current_status_num = H.current_status_num; FCstd_idx = H.FCstd_idx; SLstd_idx = H.SLstd_idx; R33std_idx = H.R33std_idx; sample = H.sample;

%Plot Types 1-3 Concordia Unknowns (1 sigma)
if get(H.plottype,'Value') == 1 || get(H.plottype,'Value') == 2 || get(H.plottype,'Value') == 3
    sigmarule1s=1.5;
    for i = 1:length(H.sample_idx)
        if H.sample_idx(i,1) == 1 && H.AnalysisValues(20,3,i) ~= 100100
            sigx_sq_6875(i,1) = sigx_sq_All_6875(i,1);
            rho_sigx_sigy_6875(i,1) = rho_sigx_sigy_All_6875(i,1);
            sigy_sq_6875(i,1) = sigy_sq_All_6875(i,1);
            center_6875(i,1:2) = center_All_6875(i,1:2);
        else
            sigx_sq_6875(i,1) = 0;
            rho_sigx_sigy_6875(i,1) = 0;
            sigy_sq_6875(i,1) = 0;
            center_6875(i,1:2) = [0,0];
        end
    end
    for i = 1:length(H.sample)
        covmat=[sigx_sq_6875(i,1),rho_sigx_sigy_6875(i,1);rho_sigx_sigy_6875(i,1),sigy_sq_6875(i,1)];
        [PD,PV]=eig(covmat);
        PV=diag(PV).^.5;
        theta=linspace(0,2.*pi,numpoints)';
        elpt1s=[cos(theta),sin(theta)]*diag(PV)*PD';
        numsigma1s=length(sigmarule1s);
        elpt1s=repmat(elpt1s,1,numsigma1s).*repmat(sigmarule1s(floor(1:.5:numsigma1s+.5)),numpoints,1);
        elpt1s=elpt1s+repmat(center_6875(i,1:2),numpoints,numsigma1s);
        elpt1s_out(:,:,i)=elpt1s;

        if get(H.plottype,'Value') == 1 || get(H.plottype,'Value') == 3 
            if H.sample_idx(i,1) == 1 && current_status_num(i,1) == 1
                elpt1s_out_acc(:,:,i) = elpt1s;
                p1 = plot(elpt1s_out_acc(:,1:2:end,i),elpt1s_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
            end
            if H.sample_idx(i,1) == 1 && current_status_num(i,1) == 0 && H.AnalysisValues(20,3,i) ~= 100100
                elpt1s_out_rej(:,:,i) = elpt1s;
                p2 = plot(elpt1s_out_rej(:,1:2:end,i),elpt1s_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
            end
        end
    end
    xscalar = .01;
    yscalar = .01;
    if min(min(nonzeros(elpt1s_out(:,1,:))))-min(min(nonzeros(elpt1s_out(:,1,:))))*xscalar <= 0
        xlo = 0;
    else
        xlo = min(min(nonzeros(elpt1s_out(:,1,:))))-min(min(nonzeros(elpt1s_out(:,1,:))))*xscalar;
    end
    if min(min(nonzeros(elpt1s_out(:,2,:))))-min(min(nonzeros(elpt1s_out(:,2,:))))*yscalar <= 0
        ylo = 0;
    else
        ylo = min(min(nonzeros(elpt1s_out(:,2,:))))-min(min(nonzeros(elpt1s_out(:,2,:))))*yscalar;
    end
    xhi = max(max(elpt1s_out(:,1,:)))+max(max(elpt1s_out(:,1,:)))*xscalar;
    yhi = max(max(elpt1s_out(:,2,:)))+max(max(elpt1s_out(:,2,:)))*yscalar;
    timeC = 0:1000000:4500000000;
    xC = exp(0.00000000098485.*timeC)-1;
    yC = exp(0.000000000155125.*timeC)-1;
    agelabelmin = 0;
    agelabelint = 500*1000000; 

    if get(H.plottype,'Value') == 3  
        agelabelint = 500*1000000/10; 
    end
    agelabelmax = 4000000000;
    age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
    age_label_x = exp(0.00000000098485.*age_label_num)-1;
    age_label_y = exp(0.000000000155125.*age_label_num)-1;
    for i=1:length(age_label_num)
        age_label(i,1) = {sprintf('%.0f',age_label_num(1,i)/1000000)};
        age_label2(i,1) = strcat(age_label(i,1),' Ma');
    end
    plot(xC,yC,'k','LineWidth',1.4)

    if get(H.plottype,'Value') == 1 ||  get(H.plottype,'Value') == 2
        for i = 1:length(age_label_num)
            if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
                scatter3(age_label_x(1,i), age_label_y(1,i), 1, 30, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
                text(age_label_x(1,i)+0.5, age_label_y(1,i),age_label2(i,1), 'FontWeight') % , 'bold')
            end
        end
    end

    if get(H.plottype,'Value') == 3	
        for i = 1:length(age_label_num)
            if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
                scatter3(age_label_x(1,i), age_label_y(1,i), 1, 30, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
                text(age_label_x(1,i)+0.02, age_label_y(1,i),age_label2(i,1), 'FontWeight') % , 'bold')
            end
        end
    end

    xlabel('207Pb/235U');
    ylabel('206Pb/238U');
    axis([xlo xhi ylo yhi])
    set(H.setxmin,'String',xlo)
    set(H.setxmax,'String',xhi)
    set(H.setymin,'String',ylo)
    set(H.setymax,'String',yhi)

    if get(H.plottype,'Value') == 2
        for i = 1:length(H.sample)
            if H.sample_idx(i,1) == 1 && current_status_num(i,1) == 0
                scatter3(H.ratio75(i,1), H.ratio68(i,1), 1, 50, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g', 'LineWidth', 1.5)
                text(H.ratio75(i,1)+0.008, H.ratio68(i,1),1,H.sample(i,1), 'FontWeight', 'bold')
            end
        end
    end
end

if get(H.plottype,'Value') == 3
    set(gca, 'XScale', 'log')
    set(gca, 'YScale', 'log')
    axis([xlo xhi ylo yhi])
    set(H.setxmax,'String',0.72)
    set(H.setymax,'String',0.09)
    axis([str2double(get(H.setxmin,'String')) str2double(get(H.setxmax,'String')) str2double(get(H.setymin,'String')) str2double(get(H.setymax,'String'))])
end
% end of Plot Types 1-3 = 68-75 concordia plots

% Plot Types 5-7 and 3 = 68-75 Concordia Plots
if get(H.plottype,'Value') == 5 || get(H.plottype,'Value') == 6 || get(H.plottype,'Value') == 7 || get(H.plottype,'Value') == 8 || get(H.plottype,'Value') == 3
    sigmarule1s=1.5;
    for i = 1:length(H.sample)
        sigx_sq_6875(i,1) = sigx_sq_All_6875(i,1);
        rho_sigx_sigy_6875(i,1) = rho_sigx_sigy_All_6875(i,1);
        sigy_sq_6875(i,1) = sigy_sq_All_6875(i,1);
        center_6875(i,1:2) = center_All_6875(i,1:2);
    end

    for i = 1:length(H.sample)
        covmat=[sigx_sq_6875(i,1),rho_sigx_sigy_6875(i,1);rho_sigx_sigy_6875(i,1),sigy_sq_6875(i,1)];
        [PD,PV]=eig(covmat);
        PV=diag(PV).^.5;
        theta=linspace(0,2.*pi,numpoints)';
        elpt1s=[cos(theta),sin(theta)]*diag(PV)*PD';
        numsigma1s=length(sigmarule1s);
        elpt1s=repmat(elpt1s,1,numsigma1s).*repmat(sigmarule1s(floor(1:.5:numsigma1s+.5)),numpoints,1);
        elpt1s=elpt1s+repmat(center_6875(i,1:2),numpoints,numsigma1s);
        elpt1s_out(:,:,i)=elpt1s;
        if get(H.plottype,'Value') == 5 || get(H.plottype,'Value') == 6 || get(H.plottype,'Value') == 7 || get(H.plottype,'Value') == 8
            if FCstd_idx(i,1) == 1 && current_status_num(i,1) == 1
                elpt1s_out_acc(:,:,i) = elpt1s;
                p1 = plot(elpt1s_out_acc(:,1:2:end,i),elpt1s_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
            end
            if FCstd_idx(i,1) == 1 && current_status_num(i,1) == 0
                elpt1s_out_rej(:,:,i) = elpt1s;
                p2 = plot(elpt1s_out_rej(:,1:2:end,i),elpt1s_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
            end
            if SLstd_idx(i,1) == 1 && current_status_num(i,1) == 1
                elpt1s_out_acc(:,:,i) = elpt1s;
                p1 = plot(elpt1s_out_acc(:,1:2:end,i),elpt1s_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
            end
            if SLstd_idx(i,1) == 1 && current_status_num(i,1) == 0
                elpt1s_out_rej(:,:,i) = elpt1s;
                p2 = plot(elpt1s_out_rej(:,1:2:end,i),elpt1s_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
            end
            if R33std_idx(i,1) == 1 && current_status_num(i,1) == 1
                elpt1s_out_acc(:,:,i) = elpt1s;
                p1 = plot(elpt1s_out_acc(:,1:2:end,i),elpt1s_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
            end
            if R33std_idx(i,1) == 1 && current_status_num(i,1) == 0
                elpt1s_out_rej(:,:,i) = elpt1s;
                p2 = plot(elpt1s_out_rej(:,1:2:end,i),elpt1s_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
            end
        end
        if get(H.plottype,'Value') == 3
            if H.sample_idx(i,1) == 1 && current_status_num(i,1) == 1
                elpt1s_out_acc(:,:,i) = elpt1s;
                p1 = plot(elpt1s_out_acc(:,1:2:end,i),elpt1s_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
            end
            if H.sample_idx(i,1) == 1 && current_status_num(i,1) == 0
                elpt1s_out_rej(:,:,i) = elpt1s;
                p2 = plot(elpt1s_out_rej(:,1:2:end,i),elpt1s_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
            end
            if R33std_idx(i,1) == 1 && current_status_num(i,1) == 0
                elpt1s_out_rej(:,:,i) = elpt1s;
                p3 = plot(elpt1s_out_rej(:,1:2:end,i),elpt1s_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
            end
            if R33std_idx(i,1) == 1 && current_status_num(i,1) == 1
                elpt1s_out_acc(:,:,i) = elpt1s;
                p4 = plot(elpt1s_out_acc(:,1:2:end,i),elpt1s_out_acc(:,2:2:end,i),'g','LineWidth',1.2);
            end

        end
    end
    xscalar = .01;
    yscalar = .01;
    if min(min(nonzeros(elpt1s_out(:,1,:))))-min(min(nonzeros(elpt1s_out(:,1,:))))*xscalar <= 0
        xlo = 0;
    else
        xlo = min(min(nonzeros(elpt1s_out(:,1,:))))-min(min(nonzeros(elpt1s_out(:,1,:))))*xscalar;
    end
    if min(min(nonzeros(elpt1s_out(:,2,:))))-min(min(nonzeros(elpt1s_out(:,2,:))))*yscalar <= 0
        ylo = 0;
    else
        ylo = min(min(nonzeros(elpt1s_out(:,2,:))))-min(min(nonzeros(elpt1s_out(:,2,:))))*yscalar;
    end
    xhi = max(max(elpt1s_out(:,1,:)))+max(max(elpt1s_out(:,1,:)))*xscalar;
    yhi = max(max(elpt1s_out(:,2,:)))+max(max(elpt1s_out(:,2,:)))*yscalar;
    timeC = 0:1000000:4500000000;
    xC = exp(0.00000000098485.*timeC)-1;
    yC = exp(0.000000000155125.*timeC)-1;
    agelabelmin = 0;

    if get(H.plottype,'Value') == 3
        agelabelint = 500*1000000/10; %          
    end
    if get(H.plottype,'Value') == 5
        agelabelint = 500*1000000/5; %            
    end
    if get(H.plottype,'Value') == 6 || get(H.plottype,'Value') == 7 || get(H.plottype,'Value') == 8
        agelabelint = 500*1000000/25; %            
    end

    agelabelmax = 4000000000;
    age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
    age_label_x = exp(0.00000000098485.*age_label_num)-1;
    age_label_y = exp(0.000000000155125.*age_label_num)-1;
    for i=1:length(age_label_num)
        age_label(i,1) = {sprintf('%.0f',age_label_num(1,i)/1000000)};
        age_label2(i,1) = strcat(age_label(i,1),' Ma');
    end
    plot(xC,yC,'k','LineWidth',1.4)
    if get(H.plottype,'Value') == 5
        for i = 1:length(age_label_num)
            if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
                scatter3(age_label_x(1,i), age_label_y(1,i), 1, 30, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
                text(age_label_x(1,i)+0.05, age_label_y(1,i),age_label2(i,1)) %, 'FontWeight', 'bold')
            end
        end
    end
    if get(H.plottype,'Value') == 6
        for i = 1:length(age_label_num)
            if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
                scatter3(age_label_x(1,i), age_label_y(1,i), 1, 30, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
                text(age_label_x(1,i)+0.01, age_label_y(1,i),age_label2(i,1)) %, 'FontWeight', 'bold')
            end
        end
    end
    if get(H.plottype,'Value') == 7
        for i = 1:length(age_label_num)
            if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
                scatter3(age_label_x(1,i), age_label_y(1,i), 1, 30, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
                text(age_label_x(1,i)+0.005, age_label_y(1,i),age_label2(i,1)) %, 'FontWeight', 'bold')
            end
        end
    end
    if get(H.plottype,'Value') == 8
        for i = 1:length(age_label_num)
            if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
                scatter3(age_label_x(1,i), age_label_y(1,i), 1, 30, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
                text(age_label_x(1,i)+0.005, age_label_y(1,i),age_label2(i,1)) %, 'FontWeight', 'bold')
            end
        end
    end
    if get(H.plottype,'Value') == 3
        for i = 1:length(age_label_num)
            if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
                scatter3(age_label_x(1,i), age_label_y(1,i), 1, 30, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
                text(age_label_x(1,i)+0.02, age_label_y(1,i),age_label2(i,1), 'FontWeight') % , 'bold')
            end
        end
    end
    xlabel('207Pb/235U');
    ylabel('206Pb/238U');
    axis([xlo xhi ylo yhi])
    set(H.setxmin,'String',xlo)
    set(H.setxmax,'String',xhi)
    set(H.setymin,'String',ylo)
    set(H.setymax,'String',yhi)
    if get(H.plottype,'Value') == 3
        set(gca, 'XScale', 'log')
        set(gca, 'YScale', 'log')
        axis([xlo xhi ylo yhi])
        set(H.setxmax,'String',0.72)
        set(H.setymax,'String',0.09)
        axis([str2double(get(H.setxmin,'String')) str2double(get(H.setxmax,'String')) str2double(get(H.setymin,'String')) str2double(get(H.setymax,'String'))])
    end
    if get(H.plottype,'Value') == 5
        axis([xlo xhi ylo yhi])
        set(H.setxmin,'String',0.4)
        set(H.setxmax,'String',2.3)
        set(H.setymin,'String',0.055)
        set(H.setymax,'String',0.2)
        axis([str2double(get(H.setxmin,'String')) str2double(get(H.setxmax,'String')) str2double(get(H.setymin,'String')) str2double(get(H.setymax,'String'))])
    end
    if get(H.plottype,'Value') == 6 %FC
        axis([xlo xhi ylo yhi])
        set(H.setxmin,'String',1.6)
        set(H.setxmax,'String',2.3)
        set(H.setymin,'String',0.16)
        set(H.setymax,'String',0.21)
        axis([str2double(get(H.setxmin,'String')) str2double(get(H.setxmax,'String')) str2double(get(H.setymin,'String')) str2double(get(H.setymax,'String'))])
    end
    if get(H.plottype,'Value') == 7 %SL
        axis([xlo xhi ylo yhi])
        set(H.setxmin,'String',0.62)
        set(H.setxmax,'String',0.82)
        set(H.setymin,'String',0.078)
        set(H.setymax,'String',0.098)
        axis([str2double(get(H.setxmin,'String')) str2double(get(H.setxmax,'String')) str2double(get(H.setymin,'String')) str2double(get(H.setymax,'String'))])
    end
    if get(H.plottype,'Value') == 8 %R33
        axis([xlo xhi ylo yhi])
        set(H.setxmin,'String',0.4)
        set(H.setxmax,'String',0.6)
        set(H.setymin,'String',0.055)
        set(H.setymax,'String',0.078)
        axis([str2double(get(H.setxmin,'String')) str2double(get(H.setxmax,'String')) str2double(get(H.setymin,'String')) str2double(get(H.setymax,'String'))])
    end

    if get(H.plottype,'Value') == 5 || get(H.plottype,'Value') == 6 || get(H.plottype,'Value') == 7 || get(H.plottype,'Value') == 8
        p1 = scatter(H.STD_FC_68*137.818*(1/H.STD_FC_67), H.STD_FC_68,30,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.0);
        p2 = scatter(H.STD_SL_68*137.818*(1/H.STD_SL_67), H.STD_SL_68,30,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.0);
        p3 = scatter(H.STD_R33_68*137.818*(1/H.STD_R33_67), H.STD_R33_68,30,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.0);
    end
end
% end of plottype 5-8 (and 3) = 68-82 concordia plots

% start of 68-82 concordia plot (plottype = 4)
if get(H.plottype,'Value') == 4
    sigmarule1s=1.5;
    for i = 1:length(H.sample_idx)
        if H.sample_idx(i,1) == 1 && H.AnalysisValues(20,3,i) ~= 100100
            sigx_sq_6882(i,1) = sigx_sq_All_6882(i,1);
            rho_sigx_sigy_6882(i,1) = rho_sigx_sigy_All_6882(i,1);
            sigy_sq_6882(i,1) = sigy_sq_All_6882(i,1);
            center_6882(i,1:2) = center_All_6882(i,1:2);
        else
            sigx_sq_6882(i,1) = 0;
            rho_sigx_sigy_6882(i,1) = 0;
            sigy_sq_6882(i,1) = 0;
            center_6882(i,1:2) = [0,0];
        end
    end
    for i = 1:length(H.sample)
        covmat=[sigx_sq_6882(i,1),rho_sigx_sigy_6882(i,1);rho_sigx_sigy_6882(i,1),sigy_sq_6882(i,1)];
        [PD,PV]=eig(covmat);
        PV=diag(PV).^.5;
        theta=linspace(0,2.*pi,numpoints)';
        elpt1s=[cos(theta),sin(theta)]*diag(PV)*PD';
        numsigma1s=length(sigmarule1s);
        elpt1s=repmat(elpt1s,1,numsigma1s).*repmat(sigmarule1s(floor(1:.5:numsigma1s+.5)),numpoints,1);
        elpt1s=elpt1s+repmat(center_6882(i,1:2),numpoints,numsigma1s);
        elpt1s_out(:,:,i)=elpt1s;
            if H.sample_idx(i,1) == 1 && current_status_num(i,1) == 1
                elpt1s_out_acc(:,:,i) = elpt1s;
                p1 = plot(elpt1s_out_acc(:,1:2:end,i),elpt1s_out_acc(:,2:2:end,i),'b','LineWidth',1.2);
            end
            if H.sample_idx(i,1) == 1 && current_status_num(i,1) == 0 && H.AnalysisValues(20,3,i) ~= 100100
                elpt1s_out_rej(:,:,i) = elpt1s;
                p2 = plot(elpt1s_out_rej(:,1:2:end,i),elpt1s_out_rej(:,2:2:end,i),'r','LineWidth',1.2);
            end
    end
    xscalar = .01;
    yscalar = .01;
    if min(min(nonzeros(elpt1s_out(:,1,:))))-min(min(nonzeros(elpt1s_out(:,1,:))))*xscalar <= 0
        xlo = 0;
    else
        xlo = 0.8*min(min(nonzeros(elpt1s_out(:,1,:))))-min(min(nonzeros(elpt1s_out(:,1,:))))*xscalar;
    end
    if min(min(nonzeros(elpt1s_out(:,2,:))))-min(min(nonzeros(elpt1s_out(:,2,:))))*yscalar <= 0
        ylo = 0;
    else
        ylo = 0.8*min(min(nonzeros(elpt1s_out(:,2,:))))-min(min(nonzeros(elpt1s_out(:,2,:))))*yscalar;
    end
    xhi = 1.1*max(max(elpt1s_out(:,1,:)))+max(max(elpt1s_out(:,1,:)))*xscalar;
    yhi = 1.1*max(max(elpt1s_out(:,2,:)))+max(max(elpt1s_out(:,2,:)))*yscalar;
    timeC = 0:1000000:4500000000;
    xC = exp(0.000000000049475.*timeC)-1;
    yC = exp(0.000000000155125.*timeC)-1;
    agelabelmin = 0;
    agelabelint = 500*1000000; %agelabelint = str2num(get(H.concint,'String'))*1000000;

    agelabelmax = 4000000000;
    age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
    age_label_x = exp(0.000000000049475.*age_label_num)-1;
    age_label_y = exp(0.000000000155125.*age_label_num)-1;
    for i=1:length(age_label_num)
        age_label(i,1) = {sprintf('%.0f',age_label_num(1,i)/1000000)};
        age_label2(i,1) = strcat(age_label(i,1),' Ma');
    end
    plot(xC,yC,'k','LineWidth',1.4)

         for i = 1:length(age_label_num)
            if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
                scatter3(age_label_x(1,i), age_label_y(1,i), 1, 30, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
                text(age_label_x(1,i)+0.02, age_label_y(1,i),age_label2(i,1), 'FontWeight') % , 'bold')
            end
        end
  
    xlabel('208Pb/232Th');
    ylabel('206Pb/238U');
    axis([xlo xhi ylo yhi])
    set(H.setxmin,'String',xlo)
    set(H.setxmax,'String',xhi)
    set(H.setymin,'String',ylo)
    set(H.setymax,'String',yhi)

end

% end of 68-82 plot


%% Weighted Mean calc for FC-SL-R33 for continuous display (no uncertainty or MSWD)

if get(H.plottype,'Value') <= 19
    dataW=zeros(H.NumAnalyses,1);
    for i = 1:H.NumAnalyses %FC 68
        if H.FCstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
            dataW(i,1) = H.Age68(i,1);
            dataW(i,2) = H.Age68err_2s(i,1);
        end
    end
    dataW = dataW(any(dataW ~= 0,2),:);
    wmFC_68 = round(sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))),1); % Weighted Mean
    dataW=zeros(H.NumAnalyses,1);
    for i = 1:H.NumAnalyses %SL 68
        if H.SLstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
            dataW(i,1) = H.Age68(i,1);
            dataW(i,2) = H.Age68err_2s(i,1);
        end
    end
    dataW = dataW(any(dataW ~= 0,2),:);
    wmSL_68 = round(sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))),1); % Weighted Mean
    dataW=zeros(H.NumAnalyses,1); %R33 68
    for i = 1:H.NumAnalyses
        if H.R33std_idx(i,1) == 1 && H.current_status_num(i,1) == 1
            dataW(i,1) = H.Age68(i,1);
            dataW(i,2) = H.Age68err_2s(i,1);
        end
    end
    dataW = dataW(any(dataW ~= 0,2),:);
    wmR33_68 = round(sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))),1); % Weighted Mean
    dataW=zeros(H.NumAnalyses,1);
    for i = 1:H.NumAnalyses %FC 67
        if H.FCstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
            dataW(i,1) = (H.Age67(i,1));
            dataW(i,2) = (H.Age67err_2s(i,1));
        end
    end
    dataW = dataW(any(dataW ~= 0,2),:);
    wmFC_67 = round(sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))),1); % Weighted Mean
    dataW=zeros(H.NumAnalyses,1);
    for i = 1:H.NumAnalyses %SL 67
        if H.SLstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
            dataW(i,1) = (H.Age67(i,1));
            dataW(i,2) = (H.Age67err_2s(i,1));
        end
    end
    dataW = dataW(any(dataW ~= 0,2),:);
    wmSL_67 = round(sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))),1); % Weighted Mean
    dataW=zeros(H.NumAnalyses,1);
    for i = 1:H.NumAnalyses %R33 67
        if H.R33std_idx(i,1) == 1 && H.current_status_num(i,1) == 1
            dataW(i,1) = (H.Age67(i,1));
            dataW(i,2) = (H.Age67err_2s(i,1));
        end
    end
    dataW = dataW(any(dataW ~= 0,2),:);
    wmR33_67 = round(sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))),1); % Weighted Mean
    dataW=zeros(H.NumAnalyses,1);
    for i = 1:H.NumAnalyses %FC 82
        if H.FCstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
            dataW(i,1) = (H.Age82(i,1));
            dataW(i,2) = (H.Age82err_2s(i,1));
        end
    end
    dataW = dataW(any(dataW ~= 0,2),:);
    wmFC_82 = round(sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))),1); % Weighted Mean
    dataW=zeros(H.NumAnalyses,1);
    for i = 1:H.NumAnalyses %SL 82
        if H.SLstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
            dataW(i,1) = (H.Age82(i,1));
            dataW(i,2) = (H.Age82err_2s(i,1));
        end
    end
    dataW = dataW(any(dataW ~= 0,2),:);
    wmSL_82 = round(sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))),1); % Weighted Mean
    dataW=zeros(H.NumAnalyses,1);
    for i = 1:H.NumAnalyses %R33 82
        if H.R33std_idx(i,1) == 1 && H.current_status_num(i,1) == 1
            dataW(i,1) = (H.Age82(i,1));
            dataW(i,2) = (H.Age82err_2s(i,1));
        end
    end
    dataW = dataW(any(dataW ~= 0,2),:);
    wmR33_82 = round(sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))),1); % Weighted Mean
    dataW=zeros(H.NumAnalyses,1);
end

set(H.wmFC_68,'String',wmFC_68);
set(H.wmSL_68,'String',wmSL_68);
set(H.wmR33_68,'String',wmR33_68);
set(H.wmFC_67,'String',wmFC_67);
set(H.wmSL_67,'String',wmSL_67);
set(H.wmR33_67,'String',wmR33_67);
set(H.wmFC_82,'String',wmFC_82);
set(H.wmSL_82,'String',wmSL_82);
set(H.wmR33_82,'String',wmR33_82);

if get(H.plottype,'Value') == 5
    agelabelint = 500*1000000/5; %           
end
if get(H.plottype,'Value') == 6	|| get(H.plottype,'Value') == 7 || get(H.plottype,'Value') == 8
    agelabelint = 500*1000000/25; %           
end

%% Young Concordance Calculation
for i = 1:length(H.Age68) %young concordance calc
    if 100*H.Age68(i,1)/(H.Age67(i,1)) < 200 && 100*H.Age68(i,1)/(H.Age67(i,1)) > 10 && H.Age68(i,1)<800
        conc_young(i,1) = 100*H.Age68(i,1)/(H.Age67(i,1));
    else
        conc_young(i,1) = 0;
    end
end

conc_young = nonzeros(conc_young);
conc_young_avg = median(conc_young); %was mean
set(H.conc_young_avg,'String',round(conc_young_avg,1))

%% Age vs Unonc, RadDos, U/Th, Concordance Plots to 2390

if get(H.plottype,'Value') == 16 || get(H.plottype,'Value') == 17 || get(H.plottype,'Value') == 18 || get(H.plottype,'Value') == 19
    for i = 1:H.NumAnalyses %length(H.sample_idx)
        if H.sample_idx(i,1) == 1 && H.current_status_num(i,1) == 1 && H.Age68(i,1)>1 && H.Age68(i,1)<4500000000 && ...
                (H.Age67(i,1))>1 && (H.Age67(i,1))<4500000000 && H.Uppm(i,1)>1 && H.Uppm(i,1)<1000000 && H.Thppm(i,1)>1 && H.Thppm(i,1)<1000000
            age68(i,1) = (H.Age68(i,1));
            age67(i,1) = (H.Age67(i,1));
            bestage(i,1) = (H.Best_Age(i,1));
            u(i,1) = (H.Uppm(i,1));
            th(i,1) = (H.Thppm(i,1));
            uth(i,1) = (H.UTh(i,1));
        end
    end
    if get(H.plottype,'Value') == 16
        s1 = scatter(u, bestage,  50, 'filled', 'b', 'd', 'LineWidth', 1, 'MarkerEdgeColor', 'k');
        xlabel('U ppm')
        ylabel('Best Age (Ma)')
    end
    if get(H.plottype,'Value') == 17
        for i = 1:length(u)
            raddos(i,1) = 8*u(i,1)*(exp(0.000000000155*bestage(i,1)*1000000)-1)+7*(u(i,1)/137.818)*(exp(0.000000000985*bestage(i,1)*1000000)-1)...
                +6*th(i,1)*(exp(0.0000000000495*bestage(i,1)*1000000)-1);
        end
        s1 = scatter(raddos, bestage, 50, 'filled', 'b', 'd', 'LineWidth', 1, 'MarkerEdgeColor', 'k');
        xlabel('Radiation Dosage (alpha decays/µg)')
        ylabel('Best Age (Ma)')
    end
    if get(H.plottype,'Value') == 18
        s1 = scatter(uth, bestage,  50, 'filled', 'b', 'd', 'LineWidth', 1, 'MarkerEdgeColor', 'k');
        xlabel('U/Th')
        ylabel('Best Age (Ma)')
    end
    if  get(H.plottype,'Value') == 19
        for i = 1:length(age68) %concordance calc
            concordance(i,1) = 100*age68(i,1)/age67(i,1);
            bestage(i,1) = bestage(i,1);
        end
        s1 = scatter(concordance, bestage,  50, 'filled', 'b', 'd', 'LineWidth', 1, 'MarkerEdgeColor', 'k');
        xlabel('Concordance (%)')
        ylabel('Best Age (Ma)')
    end
    legend(s1,'Accepted Unknowns','Location','northeast'); %label for concordance plot
    x1 = xlim;
    y1 = ylim;
    set(H.setxmin,'String',x1(1,1))
    set(H.setxmax,'String',x1(1,2))
    set(H.setymin,'String',y1(1,1))
    set(H.setymax,'String',y1(1,2))
end

%% Offset Plots

filter_cutoff = str2num(get(H.filter_cutoff,'String'));
filter_disc = str2num(get(H.filter_disc,'String'));
filter_disc_rev = str2num(get(H.filter_disc_rev,'String'));
dtcut = [5000000, 30; 5000000,-30];
z = [0, 0; 30000000, 0];

%start of offset plots for 206/238
if get(H.plottype,'Value') == 9
    for i = 1:H.NumAnalyses % FF and Offset Plots for FC 206/238
        if H.FCstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 % Offset Plot for FC 206/238
            FC_238(i,1) = H.CalcValues(i,6); %col GF = 235* intensity
            FC_OS_238(i,1) = 100*(H.Age68(i,1)-H.STD_FC_68age)/H.STD_FC_68age; %col GG
        else
            FC_238(i,1) = 0; %col GF
            FC_OS_238(i,1) = 0; %col GG
        end
    end

    for i = 1:H.NumAnalyses  % FF and Offset Plots for SL 206/238
        if H.SLstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 % Offset Plot for SL 206/238
            SL_238(i,1) = H.CalcValues(i,6); %col GP
            SL_OS_238(i,1) = 100*(H.Age68(i,1)-H.STD_SL_68age)/H.STD_SL_68age; %col GQ
        else
            SL_238(i,1) = 0; %col GP
            SL_OS_238(i,1) = 0; %col GQ
        end
    end

    for i = 1:H.NumAnalyses % FF and Offset Plots for R33 206/238
        if H.R33std_idx(i,1) == 1 && H.modenum(i,1) ~= 1 % Offset Plot for R33 206/238
            R33_238(i,1) = H.CalcValues(i,6); %col GZ
            R33_OS_238(i,1) = 100*(H.Age68(i,1)-H.STD_R33_68age)/H.STD_R33_68age; %col HA
        else
            R33_238(i,1) = 0; %col GZ
            R33_OS_238(i,1) = 0; %col HA
        end
    end

    for i = 1:H.NumAnalyses % should these have *0.01?
        if H.sample_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.Age68(i,1) > (1-filter_disc*0.01)*(H.Age67(i,1)) && ...
                H.Age68(i,1) < (1+filter_disc_rev*0.01)*(H.Age67(i,1)) % isempty(H.comment(i,1)) == 1
            Unk_238_x(i,1) = H.CalcValues(i,6);
            Unk_238_y(i,1) = ((100*H.Age68(i,1)/(H.Age67(i,1)))-100)/5;
        else
            Unk_238_x(i,1) = 0;
            Unk_238_y(i,1) = 0;
        end
    end

    for i = 1:H.NumAnalyses
        if H.sample_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.Age68(i,1) < (1-filter_disc*0.01)*(H.Age67(i,1)) % && H.Age68(i,1) > filter_cutoff
            Unk_D_238_x(i,1) = H.CalcValues(i,6);
            Unk_D_238_y(i,1) = ((100*H.Age68(i,1)/(H.Age67(i,1)))-100)/5;
        else
            Unk_D_238_x(i,1) = 0;
            Unk_D_238_y(i,1) = 0;
        end
    end

    for i = 1:H.NumAnalyses
        if H.sample_idx(i,1) == 1 && H.modenum(i,1) == 2  && H.Age68(i,1) > (1+filter_disc_rev*0.01)*(H.Age67(i,1)) % &&  H.Age68(i,1) > filter_cutoff
            Unk_RD_238_x(i,1) = H.CalcValues(i,6);
            Unk_RD_238_y(i,1) = ((100*H.Age68(i,1)/(H.Age67(i,1)))-100)/5;
        else
            Unk_RD_238_x(i,1) = 0;
            Unk_RD_238_y(i,1) = 0;
        end
    end

    FC_238 = nonzeros(FC_238);
    FC_OS_238 = nonzeros(FC_OS_238);
    SL_238 = nonzeros(SL_238);
    SL_OS_238 = nonzeros(SL_OS_238);
    R33_238 = nonzeros(R33_238);
    R33_OS_238 = nonzeros(R33_OS_238);
    Unk_238_x = nonzeros(Unk_238_x);
    Unk_238_y = nonzeros(Unk_238_y);
    Unk_D_238_x = nonzeros(Unk_D_238_x);
    Unk_D_238_y = nonzeros(Unk_D_238_y);
    Unk_RD_238_x = nonzeros(Unk_RD_238_x);
    Unk_RD_238_y = nonzeros(Unk_RD_238_y);

    hold on

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
    plot(dtcut(:,1),dtcut(:,2),'k','LineWidth', 1);
    plot(z(:,1),z(:,2),'k','LineWidth', 1);

    h3 = scatter(Unk_238_x, Unk_238_y, 50,  'o', 'LineWidth', 0.5, 'MarkerEdgeColor', [.5 .5 .5]);
    h2 = scatter(Unk_D_238_x, Unk_D_238_y, 30,  'x', 'LineWidth', 0.4, 'MarkerEdgeColor', [.5 .5 .5]);
    h1 = scatter(Unk_RD_238_x, Unk_RD_238_y, 20,  '+', 'LineWidth', 0.4, 'MarkerEdgeColor', [.5 .5 .5]);
    h4 = scatter(R33_238, R33_OS_238, 75,  'g', 'filled', 'd', 'LineWidth', 1.25);
    h5 = scatter(SL_238, SL_OS_238, 75, 'b', 'filled', 'd', 'LineWidth', 1.25);
    h6 = scatter(FC_238, FC_OS_238, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
    leg = legend([h6 h5 h4 h3 h2 h1],{'FC', 'SL', 'R33','Unk-Acc', 'Unk-Disc', 'Unk-RevDisc'});
    leg.NumColumns = 2;
    xlabel('U average intensity (cps)')
    ylabel('Age Offset and Discordance (%)')

    xhi238 = max([FC_238;SL_238;R33_238;Unk_238_x;]);
    set(H.setxmin,'String',0)
    set(H.setxmax,'String',xhi238)
    set(H.setymin,'String',-15)
    set(H.setymax,'String',15)
    axis([str2num(get(H.setxmin,'String')) str2num(get(H.setxmax,'String')) str2num(get(H.setymin,'String')) str2num(get(H.setymax,'String'))])
    ax = gca;
    ax.XRuler.Exponent = 0;
    box on
    %end

end
% end of Offset plots for 206/238

% start of Offset plots for 206/207
if get(H.plottype,'Value') == 10
    for i = 1:H.NumAnalyses
        if H.FCstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 % for FC for Offset Plot
            FC_206(i,1) = H.CalcValues(i,2); %col GL
            FC_67_OS(i,1) = 100*((H.Age67(i,1))-H.STD_FC_67age)/H.STD_FC_67age; %col GM
        else
            FC_206(i,1) = 0; %col GL
            FC_67_OS(i,1) = 0; %col GM
        end
        if H.SLstd_idx(i,1) == 1 && H.modenum(i,1) ~= 1 % for SL for Offset plot
            SL_206(i,1) = H.CalcValues(i,2); %col GV
            SL_67_OS(i,1) = 100*((H.Age67(i,1))-H.STD_SL_67age)/H.STD_SL_67age; %col GW
        else
            SL_206(i,1) = 0; %col GV
            SL_67_OS(i,1) = 0; %col GW
        end
        if H.R33std_idx(i,1) == 1 && H.modenum(i,1) ~= 1 % for R33 for Offset plot
            R33_206(i,1) = H.CalcValues(i,2); %col HF
            R33_67_OS(i,1) = 100*((H.Age67(i,1))-H.STD_R33_67age)/H.STD_R33_67age; %col HG
        else
            R33_206(i,1) = 0; %col HF
            R33_67_OS(i,1) = 0; %col HG
        end

        if H.sample_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.Age68(i,1) > (1-filter_disc*0.01)*(H.Age67(i,1)) && H.Age68(i,1) < (1+filter_disc_rev*0.01)*(H.Age67(i,1)) %&& H.Age68(i,1) > H.filter_cutoff
            Unk_206_x(i,1) = H.CalcValues(i,2); %col HY
            Unk_206_y(i,1) = ((100*H.Age68(i,1)/(H.Age67(i,1)))-100)/5;
        else
            Unk_206_x(i,1) = 0;
            Unk_206_y(i,1) = 0;
        end
        if H.sample_idx(i,1) == 1 && H.modenum(i,1) ~= 1  && H.Age68(i,1) < (1-filter_disc*0.01)*(H.Age67(i,1)) %&& H.Age68(i,1) > filter_cutoff
            Unk_206_D_x(i,1) = H.CalcValues(i,2); %col HW
            Unk_206_D_y(i,1) = ((100*H.Age68(i,1)/(H.Age67(i,1)))-100)/5;
        else
            Unk_206_D_x(i,1) = 0;
            Unk_206_D_y(i,1) = 0;
        end
        if H.sample_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.Age68(i,1) > (1+filter_disc_rev*0.01)*(H.Age67(i,1)) %&& H.Age68(i,1) > filter_cutoff
            Unk_206_RD_x(i,1) = H.CalcValues(i,2); %col HX
            Unk_206_RD_y(i,1) = ((100*H.Age68(i,1)/(H.Age67(i,1)))-100)/5;
        else
            Unk_206_RD_x(i,1) = 0;
            Unk_206_RD_y(i,1) = 0;
        end
    end

    FC_206 = nonzeros(FC_206);
    FC_67_OS = nonzeros(FC_67_OS);
    SL_206 = nonzeros(SL_206);
    SL_67_OS = nonzeros(SL_67_OS);
    R33_206 = nonzeros(R33_206);
    R33_67_OS = nonzeros(R33_67_OS);
    Unk_206_x = nonzeros(Unk_206_x);
    Unk_206_y = nonzeros(Unk_206_y);
    Unk_206_D_x = nonzeros(Unk_206_D_x);
    Unk_206_D_y = nonzeros(Unk_206_D_y);
    Unk_206_RD_x = nonzeros(Unk_206_RD_x);
    Unk_206_RD_y = nonzeros(Unk_206_RD_y);

    hold on

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
    plot(dtcut(:,1),dtcut(:,2),'k','LineWidth', 1);
    plot(z(:,1),z(:,2),'k','LineWidth', 1);
    h3 = scatter(Unk_206_x, Unk_206_y, 50,  'o', 'LineWidth', 0.5, 'MarkerEdgeColor', [.5 .5 .5]);
    h2 = scatter(Unk_206_D_x, Unk_206_D_y, 30, 'x', 'LineWidth', 0.4, 'MarkerEdgeColor', [.5 .5 .5]); %, 'MarkerFaceColor', [.5 .5 .5] %'b', 'filled',
    h1 = scatter(Unk_206_RD_x, Unk_206_RD_y, 20, '+', 'LineWidth', 0.4, 'MarkerEdgeColor', [.5 .5 .5]); % , 'MarkerFaceColor', [.5 .5 .5] % 'b', 'filled',
    h4 = scatter(R33_206, R33_67_OS, 75,  'g', 'filled', 'd', 'LineWidth', 1.25);
    h5 = scatter(SL_206, SL_67_OS, 75, 'b', 'filled', 'd', 'LineWidth', 1.25);
    h6 = scatter(FC_206, FC_67_OS, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
    leg = legend([h6 h5 h4 h3 h2 h1],{'FC', 'SL', 'R33', 'Unk-Acc', 'Unk-Disc', 'Unk-RD'});
    leg.NumColumns = 2;
    xlabel('206Pb average intensity (cps)')
    ylabel('Age Offset and Discordance (%)')
    xhi206 = max([FC_206;SL_206;R33_206;Unk_206_x;Unk_206_D_x;Unk_206_RD_x]);
    set(H.setxmin,'String',0)
    set(H.setxmax,'String',xhi206)
    set(H.setymin,'String',-25)
    set(H.setymax,'String',25)
    axis([str2num(get(H.setxmin,'String')) str2num(get(H.setxmax,'String')) str2num(get(H.setymin,'String')) str2num(get(H.setymax,'String'))])
    ax = gca;
    ax.XRuler.Exponent = 0;
    box on
end
%end of offset plots for 206/207

%start of offset plots for 208/232
if get(H.plottype,'Value') == 11
    for i = 1:H.NumAnalyses
        if H.FCstd_idx(i,1) == 1
            FC_232(i,1) = H.CalcValues(i,5); %col GN
            FC_OS_232(i,1) = 100*(H.Age82(i,1)-H.STD_FC_82age)/H.STD_FC_82age; %col GO
        else
            FC_232(i,1) = 0;
            FC_OS_232(i,1) = 0;
        end
        if H.SLstd_idx(i,1) == 1
            SL_232(i,1) = H.CalcValues(i,5); %col GX
            SL_OS_232(i,1) = 100*(H.Age82(i,1)-H.STD_SL_82age)/H.STD_SL_82age; %col GY
        else
            SL_232(i,1) = 0;
            SL_OS_232(i,1) = 0;
        end
        if H.R33std_idx(i,1) == 1
            R33_232(i,1) = H.CalcValues(i,5); %col HH
            R33_OS_232(i,1) = 100*(H.Age82(i,1)-H.STD_R33_82age)/H.STD_R33_82age; %col HI
        else
            R33_232(i,1) = 0;
            R33_OS_232(i,1) = 0;
        end
        if H.FCstd_idx(i,1) ~= 1 && H.SLstd_idx(i,1) ~= 1 && H.R33std_idx(i,1) ~= 1
            Unk_232(i,1) = H.CalcValues(i,5); %col HH
        else
            Unk_232(i,1) = 0;
        end

        if H.sample_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.Age82(i,1) > (1-filter_disc*0.01)*(H.Age68(i,1)) && H.Age82(i,1) < (1+filter_disc_rev*0.01)*(H.Age68(i,1)) %&& H.Age82(i,1) > filter_cutoff
            Unk_232_x(i,1) = H.CalcValues(i,5); %col HY
            Unk_232_y(i,1) = ((100*H.Age82(i,1)/(H.Age68(i,1)))-100)/5;
        else
            Unk_232_x(i,1) = 0;
            Unk_232_y(i,1) = 0;
        end
        if H.sample_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.Age82(i,1) < (1-filter_disc*0.01)*(H.Age68(i,1)) %&& H.Age82(i,1) > filter_cutoff
            Unk_232_D_x(i,1) = H.CalcValues(i,5); %col HW
            Unk_232_D_y(i,1) = ((100*H.Age82(i,1)/(H.Age68(i,1)))-100)/5;
        else
            Unk_232_D_x(i,1) = 0;
            Unk_232_D_y(i,1) = 0;
        end
        if H.sample_idx(i,1) == 1 && H.modenum(i,1) ~= 1 && H.Age82(i,1) > (1+filter_disc_rev*0.01)*(H.Age68(i,1)) %&& H.Age82(i,1) > H.filter_cutoff
            Unk_232_RD_x(i,1) = H.CalcValues(i,5); %col HX
            Unk_232_RD_y(i,1) = ((100*H.Age82(i,1)/(H.Age68(i,1)))-100)/5;
        else
            Unk_232_RD_x(i,1) = 0;
            Unk_232_RD_y(i,1) = 0;
        end
    end

    FC_232 = nonzeros(FC_232);
    FC_OS_232 = nonzeros(FC_OS_232);
    SL_232 = nonzeros(SL_232);
    SL_OS_232 = nonzeros(SL_OS_232);
    R33_232 = nonzeros(R33_232);
    R33_OS_232 = nonzeros(R33_OS_232);
    Unk_232_x = nonzeros(Unk_232_x);
    Unk_232_y = nonzeros(Unk_232_y);
    Unk_232_D_x = nonzeros(Unk_232_D_x);
    Unk_232_D_y = nonzeros(Unk_232_D_y);
    Unk_232_RD_x = nonzeros(Unk_232_RD_x);
    Unk_232_RD_y = nonzeros(Unk_232_RD_y);

    hold on

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
    plot(dtcut(:,1),dtcut(:,2),'k','LineWidth', 1);
    plot(z(:,1),z(:,2),'k','LineWidth', 1);

    h1 = scatter(Unk_232_x, Unk_232_y, 50,  'o', 'LineWidth', 0.5, 'MarkerEdgeColor', [.5 .5 .5]);
    h2 = scatter(Unk_232_D_x, Unk_232_D_y, 40,  'x', 'LineWidth', 0.3, 'MarkerEdgeColor', [.5 .5 .5]);
    h3 = scatter(Unk_232_RD_x, Unk_232_RD_y, 30,  '+', 'LineWidth', 0.3, 'MarkerEdgeColor', [.5 .5 .5]);
    h6 = scatter(R33_232, R33_OS_232, 75,  'g', 'filled', 'd', 'LineWidth', 1.25);
    h5 = scatter(SL_232, SL_OS_232, 75, 'b', 'filled', 'd', 'LineWidth', 1.25);
    h4 = scatter(FC_232, FC_OS_232, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
    leg = legend([h6 h5 h4 h3 h2 h1],{'FC', 'SL', 'R33','Unk-Acc','Unk-Disc','Unk-RevDisc'});
    leg.NumColumns = 2;
    xlabel('Th average intensity (cps)')
    ylabel('Age Offset and Discordance (%)')

    xhi232 = max([FC_232;SL_232;R33_232;Unk_232]);
    set(H.setxmin,'String',0)
    set(H.setxmax,'String',xhi232)
    set(H.setymin,'String',-15)
    set(H.setymax,'String',15)
    axis([str2num(get(H.setxmin,'String')) str2num(get(H.setxmax,'String')) str2num(get(H.setymin,'String')) str2num(get(H.setymax,'String'))])
    ax = gca;
    ax.XRuler.Exponent = 0;
    box on
end

%end of creating offset plots

%% Weighted Mean Plots (only 67 for FC1, 68 for SL and R33)

if get(H.plottype,'Value') >= 12 && get(H.plottype,'Value') <= 15
    if get(H.plottype,'Value') == 12 %wm plot for unknowns
        for i = 1:H.NumAnalyses
            if H.sample_idx(i,1) == 1 && H.current_status_num(i,1) == 1
                dataW(i,1) = (H.Best_Age(i,1)); 
                dataW(i,2) = (H.Best_Age_err_2s(i,1)); 
            else
                dataW(i,1) = 0;
                dataW(i,2) = 0;
            end
        end
    end
    if get(H.plottype,'Value') == 13 %wm plot for FC
        for i = 1:H.NumAnalyses
            if H.FCstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
                dataW(i,1) = (H.Age67(i,1)); dataW(i,1) = (H.Age67(i,1));
                dataW(i,2) = (H.Age67err_2s(i,1));
            else
                dataW(i,1) = 0;
                dataW(i,2) = 0;
            end
        end
    end
    if get(H.plottype,'Value') == 14 %wm plot for SL
        for i = 1:H.NumAnalyses
            if H.SLstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
                dataW(i,1) = (H.Age68(i,1));
                dataW(i,2) = (H.Age68err_2s(i,1));
            else
                dataW(i,1) = 0;
                dataW(i,2) = 0;
            end
        end
    end
    if get(H.plottype,'Value') == 15 %wm plot for R33
        for i = 1:H.NumAnalyses
            if H.R33std_idx(i,1) == 1 && H.current_status_num(i,1) == 1
                dataW(i,1) = (H.Age68(i,1));
                dataW(i,2) = (H.Age68err_2s(i,1));
            else
                dataW(i,1) = 0;
                dataW(i,2) = 0;
            end
        end
    end

    dataW = dataW(any(dataW ~= 0,2),:);

    len = length(dataW(:,1));
    x = 1:1:len;
    xmin = 0; % make nice plots
    xmax = len+1; % make nice plots

    ymin = min(dataW(:,1)-dataW(:,2)) - min(dataW(:,1)-dataW(:,2))*.05; % make nice plots
    ymax = max(dataW(:,1)+dataW(:,2)) +  max(dataW(:,1)+dataW(:,2)).*.05; % make nice plots

    t = sum(dataW(:,1)./(dataW(:,2).*dataW(:,2))) / sum(1./(dataW(:,2).*dataW(:,2))); % Weighted Mean

    dataW2 = dataW;
    s = 1/sqrt(sum(1./(dataW2(:,2).*dataW2(:,2)))); % SE
    MSWD = 1/(length(dataW2(:,1))-1).*sum(((dataW2(:,1)- (sum(dataW2(:,1)./(dataW2(:,2).^2))/sum(1./(dataW2(:,2).^2))) ).^2)./((dataW2(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
 %{
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
%}
    plot([x; x], [(dataW(:,1)+dataW(:,2))'; (dataW(:,1)-dataW(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
    plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
    scatter(x, dataW(:,1), 75, 'b', 'filled','d')

    plot([xmin; xmax], [t+s; t+s], '-r', 'Color', 'k', 'LineWidth',1)
    plot([xmin; xmax], [t-s; t-s], '-r', 'Color', 'k', 'LineWidth',1)
    hold off

    set(H.wm,'String',round(t,1))
    set(H.unc,'String',round(s,1))
    set(H.mswd,'String',round(MSWD,1))

    axis([xmin xmax ymin ymax])
end

H.export_comp = 0;
H.export_fract = 0;
H.export_dist = 0;

%end of plot-compare function
set(gca,'box','on')

%% Various Functions for Plots

function wmFC_68_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)
function wmSL_68_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)
function wmR33_68_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)
function wmFC_67_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)
function wmSL_67_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)
function wmR33_67_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)
function conc_young_avg_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)

function conc1s_Callback(hObject, eventdata, H)
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
set(H.conc1s,'Value', 1)
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
set(H.conc1s,'Value', 1)
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
set(H.conc1s,'Value', 1)
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
set(H.conc1s,'Value', 1)
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
set(H.conc1s,'Value', 1)
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
set(H.conc1s,'Value', 1)
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function ageuconc_Callback(hObject, eventdata, H)
set(H.conc1s,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.FC_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
set(H.ageuconc,'Value', 1)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function ageraddos_Callback(hObject, eventdata, H)
set(H.conc1s,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.FC_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 1)
set(H.ageuth,'Value', 0)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function ageuth_Callback(hObject, eventdata, H)
set(H.conc1s,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.FC_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
set(H.ageuconc,'Value', 0)
set(H.ageraddos,'Value', 0)
set(H.ageuth,'Value', 1)
set(H.ageconc,'Value', 0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function ageconc_Callback(hObject, eventdata, H)
set(H.conc1s,'Value', 0)
set(H.SL_conc,'Value', 0)
set(H.R33_conc,'Value', 0)
set(H.FC_conc,'Value', 0)
set(H.Unk_conc,'Value', 0)
set(H.Unk_conc_acc,'Value', 0)
set(H.Unk_conc_rej,'Value', 0)
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
plot_compare(hObject, eventdata, H)

%% INDIVIDUAL ANALYSIS CONCORDIA PLOTS %% to 3608

function listbox1_Callback(hObject, eventdata, H)
AnalysisValues = H.AnalysisValues;
Ablate = H.Ablate;
current_status = H.current_status;
current_status_num = H.current_status_num;
name_idx = get(H.listbox1,'Value');
values = H.AnalysisValues(:,:,name_idx);

for i = 1:60 % preparing beam trace
    for j = 1:8
        if values(i,j) < 0
            values2(i,j) = 1;
        elseif values(i,j) == 0
            values2(i,j) = 1;
        else
            values2(i,j) = values(i,j);
        end
    end
end

if get(H.log_scale, 'Value') == 1
    plot_vals = log10(values2);
end
if get(H.log_scale, 'Value') == 0
    plot_vals = values2;
end
C = {[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[0 1 0],[1 0 1]}; % Cell array of colors
axes(H.axes_current_intensities);
cla(H.axes_current_intensities,'reset');

thickness = 1;

hold on

plot(Ablate,plot_vals(:,1),'linewidth', thickness,'color',C{1});
plot(Ablate,plot_vals(:,2),'linewidth', thickness,'color',C{2});
plot(Ablate,plot_vals(:,3),'linewidth', thickness,'color',C{3});
plot(Ablate,plot_vals(:,4),'linewidth', thickness,'color',C{4});
plot(Ablate,plot_vals(:,5),'linewidth', thickness,'color',C{5});
plot(Ablate,plot_vals(:,6),'linewidth', thickness,'color',C{6});
plot(Ablate,plot_vals(:,7),'linewidth', thickness, 'color',C{7});
plot(Ablate,plot_vals(:,8),'linewidth', thickness, 'color',C{8});

hold off
xlabel('Time (seconds)')

if get(H.log_scale, 'Value') == 1
    ylabel('Intensity (log10 cps)')
end
if get(H.log_scale, 'Value') == 0
    ylabel('Intensity (cps)')
end
xlim([1 max(Ablate)])
box on
ratio75 = H.ratio75;
ratio75err = H.ratio75err;
ratio68 = H.ratio68;
ratio68err = H.ratio68err;
Best_Age = H.Best_Age;
Best_Age_err = H.Best_Age_err;
rho_6875 = H.rho_6875;
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
concordia_data_6875 = [ratio75(name_idx,1), ratio75err(name_idx,1), ratio68(name_idx,1), ratio68err(name_idx,1)];
center_6875 = [concordia_data_6875(:,1),concordia_data_6875(:,3)];
sigx_abs_6875 = concordia_data_6875(:,1).*concordia_data_6875(:,2).*0.01;
sigy_abs_6875 = concordia_data_6875(:,3).*concordia_data_6875(:,4).*0.01;
sigx_sq_6875 = sigx_abs_6875.*sigx_abs_6875;
sigy_sq_6875 = sigy_abs_6875.*sigy_abs_6875;
rho_sigx_sigy_6875 = sigx_abs_6875.*sigy_abs_6875.*rho_6875(name_idx,1);
covmat=[sigx_sq_6875,rho_sigx_sigy_6875;rho_sigx_sigy_6875,sigy_sq_6875];
[PD,PV]=eig(covmat);
PV = diag(PV).^.5;
theta = linspace(0,2.*pi,numpoints)';
elpt = [cos(theta),sin(theta)]*diag(PV)*PD';
numsigma = length(sigmarule);
elpt = repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt_out = elpt + repmat(center_6875,numpoints,numsigma);
plot(elpt_out(:,1:2:end),elpt_out(:,2:2:end),'b','LineWidth',1.2);
hold on
plot(xc,yc,'k','LineWidth',1.4)
xaxismin = ratio75(name_idx,1) - 0.025.*ratio75(name_idx,1);
xaxismax = ratio75(name_idx,1) + 0.025.*ratio75(name_idx,1);
yaxismin = ratio68(name_idx,1) - 0.025.*ratio68(name_idx,1);
yaxismax = ratio68(name_idx,1) + 0.025.*ratio68(name_idx,1);
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
axis([min(min(elpt_out(:,1,:))) - min(min(elpt_out(:,1,:)))*.03 max(max(elpt_out(:,1,:))) + max(max(elpt_out(:,1,:)))*.03 ...
    min(min(elpt_out(:,2,:))) - min(min(elpt_out(:,2,:)))*.03 max(max(elpt_out(:,2,:))) + max(max(elpt_out(:,2,:)))*.03]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');

if current_status_num(name_idx,1) == 1 % && current_status_num_orig(name_idx,1) == 1
    set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','blue');
elseif current_status_num(name_idx,1) == 0 % && current_status_num_orig(name_idx,1) == 0
    current_status{name_idx, 1} = ['Rejected:  ', comment{name_idx,1}];
    set(H.status, 'String', current_status{name_idx,1},'ForegroundColor','red');
end
legend(p3, bestage,  'Location', 'northwest');
box on

H.export_fract = 0;

plot_session_fract(hObject, eventdata, H)
guidata(hObject,H);

%% ListBox Operator Reject Action

function operator_reject_Callback(hObject, eventdata, H)
name_idx = get(H.listbox1,'Value');
H.current_status_num_operator_reject(name_idx,1) = 1;

if H.current_status_num(name_idx,1) == 1 && H.current_status_num_operator_reject(name_idx,1) == 0 % 1 & 1 = Accepted
    H.current_status{name_idx, 1} = ['Accepted'];
    set(H.status, 'String', H.current_status{name_idx,1},'ForegroundColor','blue');
elseif H.current_status_num(name_idx,1) == 0 && H.current_status_num_operator_reject(name_idx,1) == 0 % 0 & 0 = Analysis Rejected by default
    H.current_status{name_idx, 1} = ['Rejected:  ', H.comment{name_idx,1}];
    set(H.status, 'String', H.current_status{name_idx,1},'ForegroundColor','red');
    H.name_char(name_idx,1) = strcat('<html><BODY bgcolor="red">',H.name_char(name_idx,1),'</span></html>'); % remains rejected
elseif H.current_status_num_operator_reject(name_idx,1) == 1 %H.current_status_num(name_idx,1) == 1 &&
    H.current_status{name_idx, 1} = {'Rejected by Operator'};
    set(H.status, 'String', H.current_status{name_idx,1},'ForegroundColor','red');
    H.name_char(name_idx,1) = strcat('<html><BODY bgcolor="blue">',H.name_char(name_idx,1),'</span></html>'); % rejected by operator
end

for i=1:length(H.sample)
    if H.AnalysisValues(20,3,i) == 100100
        H.name_char(i,1) = strcat('<html><BODY bgcolor="black">',H.name_char(i,1),'</span></html>');   % H.current_status_num(name_idx,1) = 1;
    end
end

set(H.listbox1, 'String', H.name_char);
guidata(hObject,H);
reduce_data_Callback(hObject, eventdata, H)

%% ListBox Operator Accept Action

function operator_accept_Callback(hObject, eventdata, H)
name_idx = get(H.listbox1,'Value');
H.current_status_num_operator_accept(name_idx,1) = 1;

if H.current_status_num(name_idx,1) == 1 && H.current_status_num_operator_accept(name_idx,1) == 0 % 1 & 1 = Accepted
    H.current_status{name_idx, 1} = ['Accepted'];
    set(H.status, 'String', H.current_status{name_idx,1},'ForegroundColor','blue');
elseif H.current_status_num(name_idx,1) == 0 && H.current_status_num_operator_accept(name_idx,1) == 0 % 0 & 0 = Analysis Rejected by default
    H.current_status{name_idx, 1} = ['Rejected   ', H.comment{name_idx,1}];
    set(H.status, 'String', H.current_status{name_idx,1},'ForegroundColor','red');
    H.name_char(name_idx,1) = strcat('<html><BODY bgcolor="red">',H.name_char(name_idx,1),'</span></html>'); % remains rejected
elseif H.current_status_num_operator_accept(name_idx,1) == 1 %H.current_status_num(name_idx,1) == 0 &&
    H.current_status{name_idx, 1} = {'Accepted by Operator'};
    set(H.status, 'String', H.current_status{name_idx,1},'ForegroundColor','blue');
    H.name_char(name_idx,1) = strcat('<html><BODY bgcolor="green">',H.name_char(name_idx,1),'</span></html>'); % rejected by operator
end

for i=1:length(H.sample)
    if H.AnalysisValues(20,3,i) == 100100
        H.name_char(i,1) = strcat('<html><BODY bgcolor="black">',H.name_char(i,1),'</span></html>');   % H.current_status_num(name_idx,1) = 1;
    end
end

set(H.listbox1, 'String', H.name_char);
guidata(hObject,H);
reduce_data_Callback(hObject, eventdata, H)

function log_scale_Callback(hObject, eventdata, H)
listbox1_Callback(hObject, eventdata, H)

%% AGE DISTRIBUTION PLOTS %% to line 3720

function plot_distribution(hObject, eventdata, H)
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

for i = 1:H.NumAnalyses
    if H.current_status_num(i,1) == 1 && H.sample_idx(i,1) == 1
        dist_data(i+1,1) = (H.Best_Age(i+1,1));
        dist_data(i+1,2) = (H.Best_Age_err(i+1,1));
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
set(gca,'box','on')
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

% end of DZ distribution plot function

%% Export Tables

function export_results_Callback(hObject, eventdata, H)

%%calculating weighted means for Geochron output table
dataW=zeros(H.NumAnalyses,1);
for i = 1:H.NumAnalyses
    if H.FCstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
        dataW(i,1) = H.Age68(i,1);
        dataW(i,2) = H.Age68err_2s(i,1);
    end
end
dataW = dataW(any(dataW ~= 0,2),:);
wmFC_68_err = 1/sqrt(sum(1./(dataW(:,2).*dataW(:,2)))); % SE
wmFC_68_mswd = 1/(length(dataW(:,1))-1).*sum(((dataW(:,1)- (sum(dataW(:,1)./(dataW(:,2).^2))/sum(1./(dataW(:,2).^2))) ).^2)./((dataW(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
dataW=zeros(H.NumAnalyses,1);
for i = 1:H.NumAnalyses
    if H.SLstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
        dataW(i,1) = H.Age68(i,1);
        dataW(i,2) = H.Age68err_2s(i,1);
    end
end
dataW = dataW(any(dataW ~= 0,2),:);
wmSL_68_err = 1/sqrt(sum(1./(dataW(:,2).*dataW(:,2)))); % SE
wmSL_68_mswd = 1/(length(dataW(:,1))-1).*sum(((dataW(:,1)- (sum(dataW(:,1)./(dataW(:,2).^2))/sum(1./(dataW(:,2).^2))) ).^2)./((dataW(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
dataW=zeros(H.NumAnalyses,1);
for i = 1:H.NumAnalyses
    if H.R33std_idx(i,1) == 1 && H.current_status_num(i,1) == 1
        dataW(i,1) = H.Age68(i,1);
        dataW(i,2) = H.Age68err_2s(i,1);
    end
end
dataW = dataW(any(dataW ~= 0,2),:);
wmR33_68_err = 1/sqrt(sum(1./(dataW(:,2).*dataW(:,2)))); % SE
wmR33_68_mswd = 1/(length(dataW(:,1))-1).*sum(((dataW(:,1)- (sum(dataW(:,1)./(dataW(:,2).^2))/sum(1./(dataW(:,2).^2))) ).^2)./((dataW(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
dataW=zeros(H.NumAnalyses,1);
for i = 1:H.NumAnalyses % WM calc for 67 ages for FC-SL-R33
    if H.FCstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
        dataW(i,1) = (H.Age67(i,1));
        dataW(i,2) = (H.Age67err_2s(i,1));
    end
end
dataW = dataW(any(dataW ~= 0,2),:);
wmFC_67_err = 1/sqrt(sum(1./(dataW(:,2).*dataW(:,2)))); % SE
wmFC_67_mswd = 1/(length(dataW(:,1))-1).*sum(((dataW(:,1)- (sum(dataW(:,1)./(dataW(:,2).^2))/sum(1./(dataW(:,2).^2))) ).^2)./((dataW(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
dataW=zeros(H.NumAnalyses,1);
for i = 1:H.NumAnalyses
    if H.SLstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
        dataW(i,1) = (H.Age67(i,1));
        dataW(i,2) = (H.Age67err_2s(i,1));
    end
end
dataW = dataW(any(dataW ~= 0,2),:);
wmSL_67_err = 1/sqrt(sum(1./(dataW(:,2).*dataW(:,2)))); % SE
wmSL_67_mswd = 1/(length(dataW(:,1))-1).*sum(((dataW(:,1)- (sum(dataW(:,1)./(dataW(:,2).^2))/sum(1./(dataW(:,2).^2))) ).^2)./((dataW(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
dataW=zeros(H.NumAnalyses,1);
for i = 1:H.NumAnalyses
    if H.R33std_idx(i,1) == 1 && H.current_status_num(i,1) == 1
        dataW(i,1) = (H.Age67(i,1));
        dataW(i,2) = (H.Age67err_2s(i,1));
    end
end
dataW = dataW(any(dataW ~= 0,2),:);
wmR33_67_err = 1/sqrt(sum(1./(dataW(:,2).*dataW(:,2)))); % SE
wmR33_67_mswd = 1/(length(dataW(:,1))-1).*sum(((dataW(:,1)- (sum(dataW(:,1)./(dataW(:,2).^2))/sum(1./(dataW(:,2).^2))) ).^2)./((dataW(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
dataW=zeros(H.NumAnalyses,1);
for i = 1:H.NumAnalyses % WM calc for 82 ages for FC-SL-R33
    if H.FCstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1
        dataW(i,1) = (H.Age82(i,1));
        dataW(i,2) = (H.Age82err_2s(i,1));
    end
end
dataW = dataW(any(dataW ~= 0,2),:);
wmFC_82_err = 1/sqrt(sum(1./(dataW(:,2).*dataW(:,2)))); % SE
wmFC_82_mswd = 1/(length(dataW(:,1))-1).*sum(((dataW(:,1)- (sum(dataW(:,1)./(dataW(:,2).^2))/sum(1./(dataW(:,2).^2))) ).^2)./((dataW(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
dataW=zeros(H.NumAnalyses,1);
for i = 1:H.NumAnalyses
    if H.SLstd_idx(i,1) == 1 && H.current_status_num(i,1) == 1 %current_status_num is why bad 82 ages do not impact wm calc
        dataW(i,1) = (H.Age82(i,1));
        dataW(i,2) = (H.Age82err_2s(i,1));
    end
end
dataW = dataW(any(dataW ~= 0,2),:);
wmSL_82_err = 1/sqrt(sum(1./(dataW(:,2).*dataW(:,2)))); % SE
wmSL_82_mswd = 1/(length(dataW(:,1))-1).*sum(((dataW(:,1)- (sum(dataW(:,1)./(dataW(:,2).^2))/sum(1./(dataW(:,2).^2))) ).^2)./((dataW(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
dataW=zeros(H.NumAnalyses,1);
for i = 1:H.NumAnalyses
    if H.R33std_idx(i,1) == 1 && H.current_status_num(i,1) == 1
        dataW(i,1) = (H.Age82(i,1));
        dataW(i,2) = (H.Age82err_2s(i,1));
    end
end
dataW = dataW(any(dataW ~= 0,2),:);
wmR33_82_err = 1/sqrt(sum(1./(dataW(:,2).*dataW(:,2)))); % SE
wmR33_82_mswd = 1/(length(dataW(:,1))-1).*sum(((dataW(:,1)- (sum(dataW(:,1)./(dataW(:,2).^2))/sum(1./(dataW(:,2).^2))) ).^2)./((dataW(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
dataW=zeros(H.NumAnalyses,1);

H.wmFC_68_err = round(wmFC_68_err,1);
H.wmSL_68_err = round(wmSL_68_err,1);
H.wmR33_68_err = round(wmR33_68_err,1);
H.wmFC_67_err = round(wmFC_67_err,1);
H.wmSL_67_err = round(wmSL_67_err,1);
H.wmR33_67_err = round(wmR33_67_err,1);
H.wmFC_82_err = round(wmFC_82_err,1);
H.wmSL_82_err = round(wmSL_82_err,1);
H.wmR33_82_err = round(wmR33_82_err,1);
H.wmFC_68_mswd = round(wmFC_68_mswd,1);
H.wmSL_68_mswd = round(wmSL_68_mswd,1);
H.wmR33_68_mswd = round(wmR33_68_mswd,1);
H.wmFC_67_mswd = round(wmFC_67_mswd,1);
H.wmSL_67_mswd = round(wmSL_67_mswd,1);
H.wmR33_67_mswd = round(wmR33_67_mswd,1);
H.wmFC_82_mswd = round(wmFC_82_mswd,1);
H.wmSL_82_mswd = round(wmSL_82_mswd,1);
H.wmR33_82_mswd = round(wmR33_82_mswd,1);
% End of calculating weighted means

%Start of Detailed Data Table
Macro_1_2_Output(1:H.NumAnalyses+1,1:42) = {0};
Macro_1_2_Output(1,1:end) = {'spotname', 'serial', 'Mode', '68 STDS',	'67 STDS',	'Unknowns', '204 cps', '206 cps', '207 cps', '208 cps', '232 cps', '235 cps', '238 cps', 'Uppm', ...
    'Thppm', 'U/Th', '207/235', '75 ± 2s %', '206/238', '68 ± 2s %' ...
    'errcorr', 'slope', '206/207', '67 ± 2s %', '206/204', '64 ± 2s %', '208/232', '82 ± 2s %', '208/204', '84 ± 2s %', '6/8 age', '± 2s (Ma)', '7/5 age', '± 2s (Ma)', '6/7 age', ...
    '± 2s (Ma)', '8/2 age', '± 2s (Ma)','Best Age', '± 2s (Ma)', '68-67 Conc', '68-82 Conc'};
Macro_1_2_Output(2:end,1) = H.sample;
Macro_1_2_Output(2:end,2) = H.serial;
Macro_1_2_Output(2:end,3) = H.mode;

for i = 1:H.NumAnalyses
    if H.reject68std(i,1) == 1
        Macro_1_2_Output{i+1,4} = 'xx';
    elseif H.sample_idx(i,1) == 0 && H.current_status_num_operator_reject(i,1) == 1
        Macro_1_2_Output{i+1,4} = 'xx';
    else
        Macro_1_2_Output{i+1,4} = '';
    end

    if H.reject67std(i,1) == 1
        Macro_1_2_Output{i+1,5} = 'xx';
    elseif H.sample_idx(i,1) == 0 && H.current_status_num_operator_reject(i,1) == 1
        Macro_1_2_Output{i+1,5} = 'xx';
    else
        Macro_1_2_Output{i+1,5} = '';
    end

    if H.current_status_num_operator_reject(i,1) == 1
        Macro_1_2_Output{i+1,6} = 'Rejected by Operator';
    else
        Macro_1_2_Output{i+1,6} = '';
    end
    if H.current_status_num_operator_accept(i,1) == 1
        Macro_1_2_Output{i+1,6} = 'Accepted by Operator';
    else
        Macro_1_2_Output{i+1,6} = '';
    end
    Macro_1_2_Output(i+1,6) = H.comment(i,1);
end

for i = 1:length(H.CalcValues(:,1))
    CalcValues_2s(:,14) = round(2*(H.CalcValues(:,14)),0);
    CalcValues_2s(:,18) = round(2*(H.CalcValues(:,18)),0);
end

H.CalcValues(:,1) = round(H.CalcValues(:,1),0);
H.CalcValues(:,2) = round(H.CalcValues(:,2),0);
H.CalcValues(:,3) = round(H.CalcValues(:,3),0);
H.CalcValues(:,4) = round(H.CalcValues(:,4),0);
H.CalcValues(:,5) = round(H.CalcValues(:,5),0);
H.CalcValues(:,6) = round(H.CalcValues(:,6),0);
H.CalcValues(:,7) = round(H.CalcValues(:,7),0);
H.ratio75(:,1)=round(H.ratio75(:,1),4); %207/205
H.ratio75err_2s(:,1)=round(H.ratio75err_2s(:,1),1); %7/5 ± %
H.ratio68=round(H.ratio68,5); %206/238
H.ratio68err_2s=round(H.ratio68err_2s,1); %68 ± %
H.errcorr_6875=round(H.errcorr_6875,3); %errcorr_6875
H.CalcValues(:,10)=round(H.CalcValues(:,10),1); %68 slope
H.fcbc67=round(H.fcbc67,3); %206/207
H.ratio67err_2s=round(H.ratio67err_2s,1); %67 ± %
H.corrected64=round(H.corrected64,0); %206/204
H.ratio82=round(H.ratio82,5); %208/232
H.ratio82err_2s=round(H.ratio82err_2s,1); %82 ± %
H.CalcValues(:,17)=round(H.CalcValues(:,17),0); %84
H.Age68=round(H.Age68,1);
H.Age75=round(H.Age75,1);
H.Age67=round((H.Age67),1);
H.Age82=round(H.Age82,1);
H.Best_Age=round(H.Best_Age,1);
H.Age68err_2s=round(H.Age68err_2s,1);
H.Age75err_2s=round(H.Age75err_2s,1);
H.Age67err_2s=round((H.Age67err_2s),1);
H.Age82err_2s=round(H.Age82err_2s,1);
H.Best_Age_err_2s=round(H.Best_Age_err_2s,1);
Macro_1_2_Output(2:end,7) = num2cell(H.CalcValues(:,1)); %204 cps columns E to V of DTT
Macro_1_2_Output(2:end,8) = num2cell(H.CalcValues(:,2)); %206 cps
Macro_1_2_Output(2:end,9) = num2cell(H.CalcValues(:,3)); %207 cps
Macro_1_2_Output(2:end,10) = num2cell(H.CalcValues(:,4)); %208 cps
Macro_1_2_Output(2:end,11) = num2cell(H.CalcValues(:,5)); %232 cps
Macro_1_2_Output(2:end,12) = num2cell(H.CalcValues(:,6)); %235 cps
Macro_1_2_Output(2:end,13) = num2cell(H.CalcValues(:,7)); %238 cps
Macro_1_2_Output(2:end,14) = num2cell(round(H.Uppm(:,1),0)); %Uppm
Macro_1_2_Output(2:end,15) = num2cell(round(H.Thppm(:,1),0)); %Thppm
Macro_1_2_Output(2:end,16) = num2cell(round(H.UTh(:,1),2)); %U/Th
Macro_1_2_Output(2:end,17) = num2cell(H.ratio75(:,1)); %207/205
Macro_1_2_Output(2:end,18) = num2cell(H.ratio75err_2s(:,1)); %7/5 ± %
Macro_1_2_Output(2:end,19) = num2cell(H.ratio68); %206/238
Macro_1_2_Output(2:end,20) = num2cell(H.ratio68err_2s); %68 ± %
Macro_1_2_Output(2:end,21) = num2cell(H.errcorr_6875); %errcorr_6875
Macro_1_2_Output(2:end,22) = num2cell(H.CalcValues(:,10)); %68 slope
Macro_1_2_Output(2:end,23) = num2cell(H.fcbc67); %206/207
Macro_1_2_Output(2:end,24) = num2cell(H.ratio67err_2s); %67 ± %
Macro_1_2_Output(2:end,25) = num2cell(H.corrected64); %206/204
Macro_1_2_Output(2:end,26) = num2cell(CalcValues_2s(:,14)); %64 ± %
Macro_1_2_Output(2:end,27) = num2cell(H.ratio82); %208/232
Macro_1_2_Output(2:end,28) = num2cell(H.ratio82err_2s); %82 ± %
Macro_1_2_Output(2:end,29) = num2cell(H.CalcValues(:,17)); %208/204
Macro_1_2_Output(2:end,30) = num2cell(CalcValues_2s(:,18)); %84 ± %
Macro_1_2_Output(2:end,31) = num2cell(H.Age68);
Macro_1_2_Output(2:end,32) = num2cell(H.Age68err_2s);
Macro_1_2_Output(2:end,33) = num2cell(H.Age75);
Macro_1_2_Output(2:end,34) = num2cell(H.Age75err_2s);
Macro_1_2_Output(2:end,35) = num2cell(H.Age67);
Macro_1_2_Output(2:end,36) = num2cell(H.Age67err_2s);
Macro_1_2_Output(2:end,37) = num2cell(H.Age82);
Macro_1_2_Output(2:end,38) = num2cell(H.Age82err_2s);
Macro_1_2_Output(2:end,39) = num2cell(H.Best_Age);
Macro_1_2_Output(2:end,40) = num2cell(H.Best_Age_err_2s);
for i = 1:H.NumAnalyses
    concordance6867(i,1) = 100*H.Age68(i,1)/H.Age67(i,1); %Conc
end
for i = 1:H.NumAnalyses
    concordance6882(i,1) = 100*H.Age68(i,1)/H.Age82(i,1); %Conc
end
concordance6867=round(concordance6867,1);
concordance6882=round(concordance6882,1);
Macro_1_2_Output(2:end,41) = num2cell(concordance6867);
Macro_1_2_Output(2:end,42) = num2cell(concordance6882);
%End of Detailed Data Table

%Start of Geochron Data Table
for i = 1:length(H.current_status_num)
    if H.current_status_num(i,1) == 1 && H.sample_idx(i,1) == 1
        export_num(i,1) = 1; %finds only accepted unknown analyses
    end
end

Geochron_Output = Macro_1_2_Output(2:end,:);

geochron_out{sum(export_num)+26, 20} = []; %Geochron Data Table Columns A-V
geochron_out(1:17,1) = [{'Aliquot Name'; 'Stratigraphic Formation Name';'Stratigraphic Age';'Rock Type';'Mineral';'Method';'Latitude';'Longitude';'Internal Uncertainty Level'; ...
    'External Uncertainty 206/238 (% two sigma)';'External Uncertainty 206/207 (% two sigma)';'Analysis Purpose';'Laboratory Name';'Analyst Name'; ...
    'Aliquot Reference';'Aliquot Instrumental Method';'Aliquot Instrumental Reference'}];
geochron_out(5,2) = [{'Zircon'}];
geochron_out(6,2) = [{'U-Pb'}];
geochron_out(9,2) = [{'two sigma'}];
geochron_out(10,2) = num2cell(H.systerr68);
geochron_out(11,2) = num2cell(H.systerr67);
geochron_out(12,2) = num2cell(H.systerr82);
geochron_out(13,2) = [{'Arizona LaserChron Center'}];
geochron_out(16,2) = [{'LA-ICPMS'}];
geochron_out(17:18,2) = [{'doi:10.1029/2007GC001805'; ...
    'doi.org/10.1130/GES00889.1'}];
geochron_out(23,1:20) = [{'Analysis','U','206Pb','U/Th','206Pb*','± 2s','207Pb*','± 2s','206Pb*','± 2s','error','206Pb*','± 2s','207Pb*','± 2s','206Pb*','± 2s','Best age','± 2s','Conc'}]; %added 2s
geochron_out(24,2:20) = [{'(ppm)','204Pb',' ','207Pb*','(%)','235U','(%)','238U','(%)','corr.','238U','(Ma)','235U','(Ma)','207Pb*','(Ma)','(Ma)','(Ma)','(%)'}];
geochron_out(21,1) = [{'Accepted Unknown Analyses'}];
geochron_out(21,3) = [{'Ratios'}];
geochron_out(21,12) = [{'Ages (Ma)'}];

geochron_out_temp{sum(H.current_status_num), 42} = [];
for i = 1:length(H.current_status_num)
    if H.current_status_num(i,1) == 1 && H.sample_idx(i,1) == 1
        geochron_out_temp(i,:) = Geochron_Output(i,:); %geochron_out_temp has accepted unknown analyses
    end
end

geochron_out_temp(all(cellfun('isempty',geochron_out_temp),2),:) = [];
geochron_out(27:end,1) = geochron_out_temp(:,1); % Analysis
geochron_out(27:end,2) = geochron_out_temp(:,14); % Uppm
geochron_out(27:end,3) = geochron_out_temp(:,25); % 206/204
geochron_out(27:end,4) = geochron_out_temp(:,16); % U/Th
geochron_out(27:end,5) = geochron_out_temp(:,23); % 206/207
geochron_out(27:end,6) = geochron_out_temp(:,24); % 206/207 ±2s
geochron_out(27:end,7) = geochron_out_temp(:,17); % 207/235
geochron_out(27:end,8) = geochron_out_temp(:,18); % 207/235 ±2s
geochron_out(27:end,9) = geochron_out_temp(:,19); % 206/238
geochron_out(27:end,10) = geochron_out_temp(:,20); % 206/238 ±2s
geochron_out(27:end,11) = geochron_out_temp(:,21); % errcorr_6875
geochron_out(27:end,12) = geochron_out_temp(:,31); % 206/238 age
geochron_out(27:end,13) = geochron_out_temp(:,32); % 206/238 age ±2s
geochron_out(27:end,14) = geochron_out_temp(:,33); % 207/235 age
geochron_out(27:end,15) = geochron_out_temp(:,34); % 207/235 age ±2s
geochron_out(27:end,16) = geochron_out_temp(:,35); % 206/207 age
geochron_out(27:end,17) = geochron_out_temp(:,36); % 206/207 age±2s
geochron_out(27:end,18) = geochron_out_temp(:,39); % Best age
geochron_out(27:end,19) = geochron_out_temp(:,40); % Best age ±2s
geochron_out(27:end,20) = geochron_out_temp(:,41); % Concordance

geochron_out(21,23) = [{'Rejected Unknown Analyses'}]; %Geochron Data Table Columns W-AP (rejected analyses)
geochron_out(23,23:42) = [{'Analysis','U','206Pb','U/Th','206Pb*','± 2s','207Pb*','± 2s','206Pb*','± 2s','error','206Pb*','± 2s','207Pb*','± 2s','206Pb*','± 2s','Best age','± 2s','Conc'}];
geochron_out(24,24:42) = [{'(ppm)','204Pb',' ','207Pb*','(%)','235U','(%)','238U','(%)','corr.','238U','(Ma)','235U','(Ma)','207Pb*','(Ma)','(Ma)','(Ma)','(%)'}];
geochron_out(21,25) = [{'Ratios'}];
geochron_out(21,34) = [{'Ages (Ma)'}];

geochron_out_temp_rej{sum(H.current_status_num), 42} = []; %was 74
for i = 1:length(H.current_status_num)
    if H.current_status_num(i,1) == 0 && H.sample_idx(i,1) == 1
        geochron_out_temp_rej(i,:) = Geochron_Output(i,:);
    end
end

geochron_out_temp_rej(all(cellfun('isempty',geochron_out_temp_rej),2),:) = [];
rejl = 27+length(geochron_out_temp_rej(:,1))-1;

geochron_out(27:rejl,23) = geochron_out_temp_rej(:,1); % analysis
geochron_out(27:rejl,24) = geochron_out_temp_rej(:,14); % Uppm
geochron_out(27:rejl,25) = geochron_out_temp_rej(:,25); % 206/204
geochron_out(27:rejl,26) = geochron_out_temp_rej(:,16); % U/Th
geochron_out(27:rejl,27) = geochron_out_temp_rej(:,23); % 206/207
geochron_out(27:rejl,28) = geochron_out_temp_rej(:,24); % 206/207 2s
geochron_out(27:rejl,29) = geochron_out_temp_rej(:,17); % 207/235
geochron_out(27:rejl,30) = geochron_out_temp_rej(:,18); % 207/235 2s
geochron_out(27:rejl,31) = geochron_out_temp_rej(:,19); % 206/238
geochron_out(27:rejl,32) = geochron_out_temp_rej(:,20); % 206/238 2s
geochron_out(27:rejl,33) = geochron_out_temp_rej(:,21); % errcorr_6875
geochron_out(27:rejl,34) = geochron_out_temp_rej(:,31); % 206/238
geochron_out(27:rejl,35) = geochron_out_temp_rej(:,32); % 206/238 2s
geochron_out(27:rejl,36) = geochron_out_temp_rej(:,33); % 207/235
geochron_out(27:rejl,37) = geochron_out_temp_rej(:,34); % 207/235 2s
geochron_out(27:rejl,38) = geochron_out_temp_rej(:,35); % 206/207
geochron_out(27:rejl,39) = geochron_out_temp_rej(:,36); % 206/207 2s
geochron_out(27:rejl,40) = geochron_out_temp_rej(:,39); % Best Age
geochron_out(27:rejl,41) = geochron_out_temp_rej(:,40); % Best Age 2s
geochron_out(27:rejl,42) = geochron_out_temp_rej(:,41); % Concordance

geochron_out(21,45) = {'Accepted Standards'}; %Geochron Data Table Columns AS-BL (standard analyses)
geochron_out(23,45:64) = [{'Analysis','U','206Pb','U/Th','206Pb*','± 2s','207Pb*','± 2s','206Pb*','± 2s','error','206Pb*','± 2s','207Pb*','± 2s','206Pb*','± 2s','Best age','± 2s','Conc'}];
geochron_out(24,46:64) = [{'(ppm)','204Pb',' ','207Pb*','(%)','235U','(%)','238U','(%)','corr.','238U','(Ma)','235U','(Ma)','207Pb*','(Ma)','(Ma)','(Ma)','(%)'}];
geochron_out(21,47) = [{'Ratios'}];
geochron_out(21,56) = [{'Ages (Ma)'}];

geochron_out_temp_stds{sum(H.current_status_num), 42} = []; %was 74
for i = 1:length(H.current_status_num)
    if H.sample_idx(i,1) == 0 && H.current_status_num(i,1) == 1
        geochron_out_temp_stds(i,:) = Geochron_Output(i,:);
    end
end

geochron_out_temp_stds(all(cellfun('isempty',geochron_out_temp_stds),2),:) = [];
stdsl = 27+length(geochron_out_temp_stds(:,1))-1;

geochron_out(27:stdsl,45) = geochron_out_temp_stds(:,1); % analysis
geochron_out(27:stdsl,46) = geochron_out_temp_stds(:,14); % Uppm
geochron_out(27:stdsl,47) = geochron_out_temp_stds(:,25); % 206/204
geochron_out(27:stdsl,48) = geochron_out_temp_stds(:,16); % U/Th
geochron_out(27:stdsl,49) = geochron_out_temp_stds(:,23); % 206/207r
geochron_out(27:stdsl,50) = geochron_out_temp_stds(:,24); % 206/207 2s
geochron_out(27:stdsl,51) = geochron_out_temp_stds(:,17); % 207/235r
geochron_out(27:stdsl,52) = geochron_out_temp_stds(:,18); % 207/235r 2s
geochron_out(27:stdsl,53) = geochron_out_temp_stds(:,19); % 206/238 age
geochron_out(27:stdsl,54) = geochron_out_temp_stds(:,20); % 206/238 age 2s
geochron_out(27:stdsl,55) = geochron_out_temp_stds(:,21); % errcorr_6875
geochron_out(27:stdsl,56) = geochron_out_temp_stds(:,31); % 206/238 age
geochron_out(27:stdsl,57) = geochron_out_temp_stds(:,32); % 206/238 age 2s
geochron_out(27:stdsl,58) = geochron_out_temp_stds(:,33); % 207/235 age
geochron_out(27:stdsl,59) = geochron_out_temp_stds(:,34); % 207/235 age 2s
geochron_out(27:stdsl,60) = geochron_out_temp_stds(:,35); % 206/207 age
geochron_out(27:stdsl,61) = geochron_out_temp_stds(:,36); % 206/207 2s
geochron_out(27:stdsl,62) = geochron_out_temp_stds(:,39); % Best age
geochron_out(27:stdsl,63) = geochron_out_temp_stds(:,40); % Best age 2s
geochron_out(27:stdsl,64) = geochron_out_temp_stds(:,41); % Concordance

geochron_out(1,23) = [{'Data Reduction Parameters:'}]; %Geochron Data Table Columns W-AM Top Row (Acquisition Parameters)
geochron_out(2,23) = [{'Cutoff Values'}];
geochron_out(3,23) = [{'Unknowns'}];
geochron_out(4,23) = [{'Standards'}];
geochron_out(1,24) = [{'6/8-6/7 Best Age Cutoff (Ma)'}];
geochron_out(1,25) = [{'Discordance Cutoff (Ma)'}];
geochron_out(1,26) = [{'6/8 Unc Cutoff Unk (%)'}];
geochron_out(1,27) = [{'6/7 Unc Cutoff Unk'}];
geochron_out(1,28) = [{'6/8 Unc Cutoff Std(%)'}];
geochron_out(1,29) = [{'6/7 Unc Cutoff Std'}];
geochron_out(1,30) = [{'Disc Filter (%)'}];
geochron_out(1,31) = [{'Rev Disc Filter (%)'}];
geochron_out(1,32) = [{'6/8 Offset Cutoff Std (%)'}];
geochron_out(1,33) = [{'6/7 Offset Cutoff Std (%)'}];

geochron_out(1,34) = [{'Stability Cutoff (%)'}];
geochron_out(1,35) = [{'Max 204 (cps)'}];
geochron_out(1,36) = [{'Min 235 (cps)'}];
geochron_out(1,37) = [{'Operator Rejected'}];
geochron_out(1,38) = [{'Operator Accepted'}];
geochron_out(1,39) = [{'Rejected Analyses'}];
geochron_out(1,40) = [{'Total # Analyses'}];
geochron_out(1,41) = [{'Use SL 6/8?'}];
geochron_out(1,42) = [{'Use SL 6/7?'}];
geochron_out(1,43) = [{'Use R33 6/8?'}];
geochron_out(1,44) = [{'206/204 factor'}];
geochron_out(1,45) = [{'206 lin factor'}];
geochron_out(1,46) = [{'206 low int factor'}];
geochron_out(1,47) = [{'235 lin factor factor'}];
geochron_out(1,48) = [{'235 low int factor'}];
geochron_out(1,49) = [{'6/8-6/7 Concordance (%)'}];

geochron_out(2,24) = {get(H.bestage_cutoff,'String')};
geochron_out(2,25) = {get(H.filter_cutoff,'String')};
geochron_out(2,26) = {get(H.filter_err68,'String')};
geochron_out(3,26) = {get(H.comment2_sum_unk,'String')};
geochron_out(2,27) = {get(H.filter_err67,'String')};
geochron_out(3,27) = {get(H.comment3_sum_unk,'String')};
geochron_out(2,28) = {get(H.filter_err68,'String')};
geochron_out(4,28) = {get(H.comment2_sum_std,'String')};
geochron_out(2,29) = {get(H.filter_err67,'String')};
geochron_out(4,29) = {get(H.comment3_sum_std,'String')};
geochron_out(2,30) = {get(H.filter_disc,'String')};
geochron_out(3,30) = {get(H.comment4_sum_unk,'String')};
geochron_out(4,30) = {get(H.comment4_sum_std,'String')};
geochron_out(2,31) = {get(H.filter_disc_rev,'String')};
geochron_out(3,31) = {get(H.comment5_sum_unk,'String')};
geochron_out(4,31) = {get(H.comment5_sum_std,'String')};
geochron_out(2,32) = {get(H.reject_std_level_68,'String')};
geochron_out(4,32) = {get(H.comment10_sum_std,'String')};
geochron_out(2,33) = {get(H.reject_std_level_67,'String')};
geochron_out(4,33) = {get(H.comment11_sum_std,'String')};
geochron_out(2,34) = {get(H.peakoffsetcutoff,'String')};
geochron_out(3,34) = {get(H.comment7_sum_unk,'String')};
geochron_out(4,34) = {get(H.comment7_sum_std,'String')};
geochron_out(2,35) = {get(H.filter_204,'String')};
geochron_out(3,35) = {get(H.comment6_sum_unk,'String')};
geochron_out(4,35) = {get(H.comment6_sum_std,'String')};
geochron_out(2,36) = {get(H.filter_235,'String')};
geochron_out(3,36) = {get(H.comment1_sum_unk,'String')};
geochron_out(4,36) = {get(H.comment1_sum_std,'String')};
geochron_out(3,37) = {get(H.comment8_sum_unk,'String')};
geochron_out(4,37) = {get(H.comment8_sum_std,'String')};
geochron_out(3,38) = {get(H.comment9_sum_unk,'String')};
geochron_out(4,38) = {get(H.comment9_sum_std,'String')};
geochron_out(3,39) = {get(H.rejected_unk_sum,'String')};
geochron_out(4,39) = {get(H.rejected_std_sum,'String')};
geochron_out(3,40) = {get(H.all_unknowns,'String')};
geochron_out(4,40) = {get(H.all_standards,'String')};

if get(H.Use_SL_68,'Value') == 1
    geochron_out(2,41) = {'yes'};
else
    geochron_out(2,41) = {'no'};
end
if get(H.Use_SL_67,'Value') == 1
    geochron_out(2,42) = {'yes'};
else
    geochron_out(2,42) = {'no'};
end
if get(H.Use_R33_68,'Value') == 1
    geochron_out(2,43) = {'yes'};
else
    geochron_out(2,43) = {'no'};
end

geochron_out(2,44) = {get(H.factor64,'String')};
geochron_out(2,45) = {get(H.lin_val_206,'String')};
geochron_out(2,46) = {get(H.lowint_val_206,'String')};
geochron_out(2,47) = {get(H.lin_val_238,'String')};
geochron_out(2,48) = {get(H.lowint_val_238,'String')};
geochron_out(2,49) = {get(H.conc_young_avg,'String')};

geochron_out(7,24) = [{'Total (2s)'}]; %
geochron_out(7,25) = [{'Fract Corr (1s)'}]; %
geochron_out(7,26) = [{'Long-Term Variance (1s)'}]; %
geochron_out(7,27) = [{'Common Pb (1s)'}]; %
geochron_out(7,28) = [{'Standard Age (1s)'}]; %
geochron_out(7,29) = [{'Decay Constant (1s)'}]; %
geochron_out(8,23) = [{'Systematic Uncertainty 6/8 (%):'}];
geochron_out(9,23) = [{'Systematic Uncertainty 6/7 (%):'}];
geochron_out(10,23) = [{'Systematic Uncertainty 8/2 (%):'}];

DCerr = round(sqrt(H.DC238err*H.DC238err+H.DC235err*H.DC235err),2);

geochron_out(8,24) = num2cell(H.systerr68); %Total Systematic error
geochron_out(8,25) = num2cell(H.FF68err); %Fract Corr 68
geochron_out(8,26) = num2cell(H.LT68err); %long-term variance 68
geochron_out(8,27) = num2cell(H.PBC68err); %common Pb
geochron_out(8,28) = num2cell(H.FC68err); %std age
geochron_out(8,29) = num2cell(H.DC238err); %decay constant
geochron_out(9,24) = num2cell(H.systerr67); %total
geochron_out(9,25) = num2cell(H.FF67err); %Fract Corr 67
geochron_out(9,26) = num2cell(H.LT67err); %long-term variance 67
geochron_out(9,27) = num2cell(H.PBC67err); %common Pb
geochron_out(9,28) = num2cell(H.FC67err); %std age
geochron_out(9,29) = num2cell(DCerr); %decay constant
geochron_out(10,24) = num2cell(H.systerr82); %total
geochron_out(10,25) = num2cell(H.FF82err); %Fract Corr 82
geochron_out(10,26) = num2cell(H.LT82err); %long-term variance 82
geochron_out(10,27) = num2cell(H.PBC82err); %common Pb
geochron_out(10,28) = num2cell(H.FC82err); %std age
geochron_out(10,29) = num2cell(H.DC232err); %decay constant

geochron_out(7,35) = [{'6/8 Age (Ma)'}];
geochron_out(7,36) = [{'6/8 Age ± 2s (Ma)'}];
geochron_out(7,37) = [{'6/8 Age (MSWD)'}];
geochron_out(7,38) = [{'6/7 Age (Ma)'}];
geochron_out(7,39) = [{'6/7 Age ± 2s (Ma)'}];
geochron_out(7,40) = [{'6/7 Age (MSWD)'}];
geochron_out(7,41) = [{'8/2 Age (Ma)'}];
geochron_out(7,42) = [{'8/2 Age ± 2s (Ma)'}];
geochron_out(7,43) = [{'8/2 Age (MSWD)'}];

geochron_out(8,34) = [{'FC'}];
geochron_out(9,34) = [{'SL'}];
geochron_out(10,34) = [{'R33'}];

geochron_out(8,35) = {get(H.wmFC_68,'String')};
geochron_out(8,36) = num2cell(H.wmFC_68_err);
geochron_out(8,37) = num2cell(H.wmFC_68_mswd);
geochron_out(8,38) = {get(H.wmFC_67,'String')};
geochron_out(8,39) = num2cell(H.wmFC_67_err);
geochron_out(8,40) = num2cell(H.wmFC_67_mswd);
geochron_out(8,41) = {get(H.wmFC_82,'String')};
geochron_out(8,42) = num2cell(H.wmFC_82_err);
geochron_out(8,43) = num2cell(H.wmFC_82_mswd);
geochron_out(9,35) = {get(H.wmSL_68,'String')};
geochron_out(9,36) = num2cell(H.wmSL_68_err);
geochron_out(9,37) = num2cell(H.wmSL_68_mswd);
geochron_out(9,38) = {get(H.wmSL_67,'String')};
geochron_out(9,39) = num2cell(H.wmSL_67_err);
geochron_out(9,40) = num2cell(H.wmSL_67_mswd);
geochron_out(9,41) = {get(H.wmSL_82,'String')};
geochron_out(9,42) = num2cell(H.wmSL_82_err);
geochron_out(9,43) = num2cell(H.wmSL_82_mswd);
geochron_out(10,35) = {get(H.wmR33_68,'String')};
geochron_out(10,36) = num2cell(H.wmR33_68_err);
geochron_out(10,37) = num2cell(H.wmR33_68_mswd);
geochron_out(10,38) = {get(H.wmR33_67,'String')};
geochron_out(10,39) = num2cell(H.wmR33_67_err);
geochron_out(10,40) = num2cell(H.wmR33_67_mswd);
geochron_out(10,41) = {get(H.wmR33_82,'String')};
geochron_out(10,42) = num2cell(H.wmR33_82_err);
geochron_out(10,43) = num2cell(H.wmR33_82_mswd);

geochron_out(8,45) = [{'Overdispersion Factor:'}];
geochron_out(7,46) = [{'206/238'}];
geochron_out(7,47) = [{'206/207'}];
geochron_out(7,48) = [{'208/232'}];
geochron_out(8,46) = num2cell(H.odf68);
geochron_out(8,47) = num2cell(H.odf67);
geochron_out(8,48) = num2cell(H.odf82);

% End of Geochron Data Table Output

% Start of AnalysisValue Data Table Output
AnalysisValues_Output2(46,9,H.NumAnalyses) = {0}; % Sets up AnalysisValues Data Table Output
AnalysisValues_Output3(46,9,H.NumAnalyses) = {0};

for i = 1:H.NumAnalyses
    AnalysisValues_Output3(1,2:9,i)=[H.sample(i,1)];
end
for i = 1:H.NumAnalyses
    AnalysisValues_Output3(2,2:9,i)=[H.serial(i,1)];
end
for i = 1:H.NumAnalyses
    AnalysisValues_Output3(3,2:9,i)=[H.mode(i,1)];
end

AnalysisValues_Output3(4,2,:)=[{''}];
AnalysisValues_Output3(5,2,:)=[{'202'}];
AnalysisValues_Output3(5,3,:)=[{'204'}];
AnalysisValues_Output3(5,4,:)=[{'206'}];
AnalysisValues_Output3(5,5,:)=[{'207'}];
AnalysisValues_Output3(5,6,:)=[{'208'}];
AnalysisValues_Output3(5,7,:)=[{'232'}];
AnalysisValues_Output3(5,8,:)=[{'235'}];
AnalysisValues_Output3(5,9,:)=[{'238'}];

AnalysisValues_Output3(1,1,1)=[{'Name'}];
AnalysisValues_Output3(2,1,1)=[{'Serial'}];
AnalysisValues_Output3(3,1,1)=[{'Mode'}];
AnalysisValues_Output3(5,1,1)=[{'Isotope'}];
AnalysisValues_Output3(7,1,1)=[{'Unused'}];
AnalysisValues_Output3(9:15,1,1)=[{'Bkgd'}];
AnalysisValues_Output3(17,1,1)=[{'PeakValue start'}];
AnalysisValues_Output3(20,1,1)=[{'Tzero'}];
AnalysisValues_Output3(23,1,1)=[{'Peak #1'}];
AnalysisValues_Output3(26,1,1)=[{'Peak #2'}];
AnalysisValues_Output3(29,1,1)=[{'Peak #3'}];
AnalysisValues_Output3(32,1,1)=[{'Peak #4'}];
AnalysisValues_Output3(35,1,1)=[{'Peak #5'}];
AnalysisValues_Output3(38,1,1)=[{'Peak #6'}];
AnalysisValues_Output3(41,1,1)=[{'Peak #7'}];
AnalysisValues_Output3(44,1,1)=[{'Peak #8'}];
AnalysisValues_Output3(62,1,1)=[{'PeakValue end'}];
AnalysisValues_Output3(64:69,1,1)=[{'Unused'}];

AnalysisValues_Output2=round(H.AnalysisValues(:,:,:),0);

AnalysisValues_Output3(7,2:9,:) = num2cell(AnalysisValues_Output2(1,1:8,:));
AnalysisValues_Output3(8,1,:)=[{''}];
AnalysisValues_Output3(9:15,2:9,:) = num2cell(AnalysisValues_Output2(2:8,1:8,:));
AnalysisValues_Output3(16,1,:)=[{''}];
AnalysisValues_Output3(17:62,2:9,:) = num2cell(AnalysisValues_Output2(9:54,1:8,:));
AnalysisValues_Output3(63,1,:)=[{''}];
AnalysisValues_Output3(64:69,2:9,:) = num2cell(AnalysisValues_Output2(55:60,1:8,:));
% End of AnalysisValue Data Table Output

% Start of PeakValue Data Table Output
PeakValues_Output(46,10,H.NumAnalyses) = {0};  
PeakValues_Output2(46,10,H.NumAnalyses) = {0}; 

for i = 1:H.NumAnalyses
PeakValues_Output2(1,2:11,i)=[H.sample(i,1)];
end
for i = 1:H.NumAnalyses
PeakValues_Output2(2,2:11,i)=[H.serial(i,1)];
end
for i = 1:H.NumAnalyses
PeakValues_Output2(3,2:11,i)=[H.mode(i,1)];
end

PeakValues_Output2(4,2,:)=[{''}];
PeakValues_Output2(5,2,:)=[{'202'}];
PeakValues_Output2(5,3,:)=[{'204'}];
PeakValues_Output2(5,4,:)=[{'206'}];
PeakValues_Output2(5,5,:)=[{'207'}];
PeakValues_Output2(5,6,:)=[{'208'}];
PeakValues_Output2(5,7,:)=[{'232'}];
PeakValues_Output2(5,8,:)=[{'235'}];
PeakValues_Output2(5,9,:)=[{'235*'}];
PeakValues_Output2(5,10,:)=[{'238'}];
PeakValues_Output2(5,11,:)=[{'238*'}];
PeakValues_Output2(6,2:9,:)=[{''}];

PeakValues_Output2(1,1,1)=[{'Name'}];
PeakValues_Output2(2,1,1)=[{'Serial'}];
PeakValues_Output2(3,1,1)=[{'Mode'}];
PeakValues_Output2(5,1,1)=[{'Isotope'}];

PeakValues_Output2(13,1,1)=[{'Peak #1'}];
PeakValues_Output2(16,1,1)=[{'Peak #2'}];
PeakValues_Output2(19,1,1)=[{'Peak #3'}];
PeakValues_Output2(22,1,1)=[{'Peak #4'}];
PeakValues_Output2(25,1,1)=[{'Peak #5'}];
PeakValues_Output2(28,1,1)=[{'Peak #6'}];
PeakValues_Output2(31,1,1)=[{'Peak #7'}];
PeakValues_Output2(34,1,1)=[{'Peak #8'}];

PeakValues_Output=round(H.PeakValues(:,:,:),0); % Sets up PeakValues Data Table Output
PeakValues_Output2(7:52,2:11,:) = num2cell(PeakValues_Output(1:46,1:10,:)); 
% End of PeakValue Data Table Output

Macro_1_2_Output = [Macro_1_2_Output];

c = char(H.folder_name);
if ispc == 1
    s = strfind(c,'\');
end
if ismac == 1
    s = strfind(c,'/');
end
samplename = c(s(end)+1:end);

if ispc == 1
    path_geochron = char(strcat(H.folder_name, '\', samplename, ' Geochron Data Table.xlsx')); %was strcat
    path_detailed = char(strcat(H.folder_name, '\', samplename, ' Detailed Data Table.xlsx'));
    path_analysisvalue = char(strcat(H.folder_name, '\', samplename, ' Analysis Value Data Table.xlsx'));
    path_peakvalue = char(strcat(H.folder_name, '\', samplename, ' Peak Value Data Table.xlsx'));
end
if ismac == 1
    path_geochron = char(strcat(H.folder_name, '/', samplename, ' Geochron Data Table.xlsx'));
    path_detailed = char(strcat(H.folder_name, '/', samplename, ' Detailed Data Table.xlsx'));
    path_analysisvalue = char(strcat(H.folder_name, '/', samplename, ' Analysis Value Data Table.xlsx'));
    path_peakvalue = char(strcat(H.folder_name, '/', samplename, ' Peak Value Data Table.xlsx'));
end
waitnum = 4;
h = waitbar(0,'');
    waitbar(1/waitnum, h, 'Saving Geochron Data Table');
writetable(table(geochron_out), path_geochron, 'FileType', 'spreadsheet', 'WriteVariableNames', 0,'WriteMode','replacefile');
    waitbar(2/waitnum, h, 'Saving Detailed Data Table');
writetable(table(Macro_1_2_Output), path_detailed, 'FileType', 'spreadsheet', 'WriteVariableNames', 0,'WriteMode','replacefile');
    waitbar(3/waitnum, h, 'Saving Analysis Values Data Table');
writetable(table(AnalysisValues_Output3), path_analysisvalue, 'FileType', 'spreadsheet', 'WriteVariableNames', 0,'WriteMode','replacefile');
    waitbar(4/waitnum, h, 'Saving Peak Values Data Table');
writetable(table(PeakValues_Output2), path_peakvalue, 'FileType', 'spreadsheet', 'WriteVariableNames', 0,'WriteMode','replacefile');

close(h)

%% Export Figures

function export_figures_Callback(hObject, eventdata, H) %%function export_figures_Callback(hObject, eventdata, handles)

c = char(H.folder_name);
if ispc == 1
    s = strfind(c,'\');
end
if ismac == 1
    s = strfind(c,'/');
end
samplename = c(s(end)+1:end);

set(H.plot_fract_68,'Value',1) %FF PLot - 68
set(H.plot_fract_76,'Value',0)
set(H.plot_fract_82,'Value',0)
H.export_fract = 1;
plot_session_fract(hObject, eventdata, H);
saveas(gcf, fullfile(H.folder_name, '\','206-238 Fractionation Plot'),'pdf');

set(H.plot_fract_68,'Value',0) % FF Plot 67
set(H.plot_fract_76,'Value',1)
set(H.plot_fract_82,'Value',0)
H.export_fract = 1;
plot_session_fract(hObject, eventdata, H);
saveas(gcf, fullfile(H.folder_name, '\','206-207 Fractionation Plot'),'pdf');

set(H.plot_fract_68,'Value',0) %FF PLot 82
set(H.plot_fract_76,'Value',0)
set(H.plot_fract_82,'Value',1)
H.export_fract = 1;
plot_session_fract(hObject, eventdata, H);
saveas(gcf, fullfile(H.folder_name, '\','208-232 Fractionation Plot'),'pdf');
set(H.plot_fract_68,'Value',1)
set(H.plot_fract_76,'Value',0)
set(H.plot_fract_82,'Value',0)

H.export_dist = 1;
guidata(hObject,H);
plot_distribution(hObject, eventdata, H)

set(H.plottype,'Value',1) % Concordia All
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Concordia All'),'pdf');

set(H.plottype,'Value',2) %Concordia Rejected
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Concordia Rejected'),'pdf');

set(H.plottype,'Value',3) % Concordia Young-Log
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Concordia Young-Log'),'pdf');

set(H.plottype,'Value',4) %Concordia 68-82
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Concordia 68-82'),'pdf');

set(H.plottype,'Value',5) %Offset 206-238
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Concordia FC-SL-R33'),'pdf');

set(H.plottype,'Value',6) %Concordia FC
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Concordia FC'),'pdf');

set(H.plottype,'Value',7) %Concordia SL
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Concordia SL'),'pdf');

set(H.plottype,'Value',8) %Concordia R33
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Concordia R33'),'pdf');

set(H.plottype,'Value',9) %Offset 206-238
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Offset 206-238'),'pdf');

set(H.plottype,'Value',10) %Offset 206-207
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Offset 206-207'),'pdf');

set(H.plottype,'Value',11) %Offset 208-232
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Offset 208-232'),'pdf');

set(H.plottype,'Value',12) %Weighted Mean Unknowns
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Weighted Mean Unknowns'),'pdf');

set(H.plottype,'Value',13) %Weighted Mean FC
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Weighted Mean FC'),'pdf');

set(H.plottype,'Value',14) %Weighted Mean SL
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Weighted Mean SL'),'pdf');

set(H.plottype,'Value',15) %Weighted Mean R33
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Weighted Mean R33'),'pdf');

set(H.plottype,'Value',16) %Age vs Concentration
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Age vs Concentration'),'pdf');

set(H.plottype,'Value',17) %Age vs Radiation Dosage
H.export_comp = 1;
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Age vs Radiation Dosage'),'pdf');

set(H.plottype,'Value',18) %Age vs U/Th
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Age vs U-Th'),'pdf');

set(H.plottype,'Value',19) %Age vs Concordance
H.export_comp = 1;
H.point = 0;
plot_compare(hObject, eventdata, H)
saveas(gcf, fullfile(H.folder_name, '\','Age vs Concordance'),'pdf');
H.export_comp = 0;

function plottype_Callback(hObject, eventdata, H)
if get(H.plottype,'Value') == 9
    set(H.slider_lowint_238,'Visible','on');
    set(H.lowint_val_238t,'Visible','on');
    set(H.lowint_val_238,'Visible','on');
    set(H.slider_lin_238,'Visible','on');
    set(H.lin_val_238t,'Visible','on');
    set(H.lin_val_238,'Visible','on');
else
    set(H.slider_lowint_238,'Visible','off');
    set(H.lowint_val_238t,'Visible','off');
    set(H.lowint_val_238,'Visible','off');
    set(H.slider_lin_238,'Visible','off');
    set(H.lin_val_238t,'Visible','off');
    set(H.lin_val_238,'Visible','off');
end
if  get(H.plottype,'Value') == 10
    set(H.slider_lowint_206,'Visible','on');
    set(H.lowint_val_206t,'Visible','on');
    set(H.lowint_val_206,'Visible','on');
    set(H.slider_lin_206,'Visible','on');
    set(H.lin_val_206t,'Visible','on');
    set(H.lin_val_206,'Visible','on');
else
    set(H.slider_lowint_206,'Visible','off');
    set(H.lowint_val_206t,'Visible','off');
    set(H.lowint_val_206,'Visible','off');
    set(H.slider_lin_206,'Visible','off');
    set(H.lin_val_206t,'Visible','off');
    set(H.lin_val_206,'Visible','off');
end
if get(H.plottype,'Value') == 11
    set(H.slider_lowint_232,'Visible','on');
    set(H.lowint_val_232t,'Visible','on');
    set(H.lowint_val_232,'Visible','on');
    set(H.slider_lin_232,'Visible','on');
    set(H.lin_val_232t,'Visible','on');
    set(H.lin_val_232,'Visible','on');
else
    set(H.slider_lowint_232,'Visible','off');
    set(H.lowint_val_232t,'Visible','off');
    set(H.lowint_val_232,'Visible','off');
    set(H.slider_lin_232,'Visible','off');
    set(H.lin_val_232t,'Visible','off');
    set(H.lin_val_232,'Visible','off');
end
if get(H.plottype,'Value') <= 19
    set(H.wmFC_68,'Visible','on');
    set(H.wmSL_68,'Visible','on');
    set(H.wmR33_68,'Visible','on');
    set(H.wmFC_67,'Visible','on');
    set(H.wmSL_67,'Visible','on');
    set(H.wmR33_67,'Visible','on');
    set(H.conc_young_avg,'Visible','on');
else
    set(H.wmFC_68,'Visible','off');
    set(H.wmSL_68,'Visible','off');
    set(H.wmR33_68,'Visible','off');
    set(H.wmFC_67,'Visible','off');
    set(H.wmSL_67,'Visible','off');
    set(H.wmR33_67,'Visible','off');
    set(H.conc_young_avg,'Visible','off');
end
if get(H.plottype,'Value') <= 19
    set(H.Use_SL_68,'Visible','on');
    set(H.Use_SL_67,'Visible','on');
    set(H.Use_R33_68,'Visible','on');
end
if get(H.plottype,'Value') >= 12 && get(H.plottype,'Value') <= 15
    set(H.wmt,'Visible','on');
    set(H.wm,'Visible','on');
    set(H.unc,'Visible','on');
    set(H.unct,'Visible','on');
    set(H.mswd,'Visible','on');
    set(H.mswdt,'Visible','on');
else
    set(H.wmt,'Visible','off');
    set(H.wm,'Visible','off');
    set(H.unc,'Visible','off');
    set(H.unct,'Visible','off');
    set(H.mswd,'Visible','off');
    set(H.mswdt,'Visible','off');
end

if H.reduced == 1
    plot_compare(hObject, eventdata, H)
end

function Use_SL_68_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function Use_SL_67_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function Use_R33_68_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function bestage_cutoff_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function filter_err68_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function filter_err67_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function filter_cutoff_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function filter_disc_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function filter_disc_rev_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function peakoffsetcutoff_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function filter_204_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function filter_235_Callback(hObject, eventdata, H)
import_data_Callback(hObject, eventdata, H)
function factor64_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function reject_std_level_68_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)
function reject_std_level_67_Callback(hObject, eventdata, H)
reduce_data_Callback(hObject, eventdata, H)

function slider_lowint_238_Callback(hObject, eventdata, H)
lowint_238 = get(H.slider_lowint_238,'Value')*100-50; %slider val
set(H.lowint_val_238, 'String', lowint_238);
reduce_data_Callback(hObject, eventdata, H)

function slider_lin_238_Callback(hObject, eventdata, H)
lin_238 = get(H.slider_lin_238,'Value')*100-50; %slider val
set(H.lin_val_238, 'String', lin_238);
reduce_data_Callback(hObject, eventdata, H)

function lowint_val_238_Callback(hObject, eventdata, H)
lowint_238 = str2num(get(H.lowint_val_238,'String'));
lowint_val_dec_238 = str2num(get(H.lowint_val_238,'String'))/100+0.5; %slider val
set(H.slider_lowint_238, 'Value', lowint_val_dec_238);
reduce_data_Callback(hObject, eventdata, H)

function lin_val_238_Callback(hObject, eventdata, H)
lin_238 = str2num(get(H.lin_val_238,'String'));
lin_val_dec_238 = str2num(get(H.lin_val_238,'String'))/100+0.5; %slider val
set(H.slider_lin_238, 'Value', lin_val_dec_238);
reduce_data_Callback(hObject, eventdata, H)

function slider_lowint_206_Callback(hObject, eventdata, H)
lowint_206 = get(H.slider_lowint_206,'Value')*100-50; %slider val
set(H.lowint_val_206, 'String', lowint_206);
reduce_data_Callback(hObject, eventdata, H)

function slider_lin_206_Callback(hObject, eventdata, H)
lin_206 = get(H.slider_lin_206,'Value')*100-50; %slider val
set(H.lin_val_206, 'String', lin_206);
reduce_data_Callback(hObject, eventdata, H)

function lowint_val_206_Callback(hObject, eventdata, H)
lowint_206 = str2num(get(H.lowint_val_206,'String'));
lowint_val_dec_206 = str2num(get(H.lowint_val_206,'String'))/100+0.5; %slider val
set(H.slider_lowint_206, 'Value', lowint_val_dec_206);
reduce_data_Callback(hObject, eventdata, H)

function lin_val_206_Callback(hObject, eventdata, H)
lin_206 = str2num(get(H.lin_val_206,'String'));
lin_val_dec_206 = str2num(get(H.lin_val_206,'String'))/100+0.5; %slider val
set(H.slider_lin_206, 'Value', lin_val_dec_206);
reduce_data_Callback(hObject, eventdata, H)

function slider_lowint_232_Callback(hObject, eventdata, H)
lowint_232 = get(H.slider_lowint_232,'Value')*100-50; %slider val
set(H.lowint_val_232, 'String', lowint_232);
reduce_data_Callback(hObject, eventdata, H)

function slider_lin_232_Callback(hObject, eventdata, H)
lin_232 = get(H.slider_lin_232,'Value')*100-50; %slider val
set(H.lin_val_232, 'String', lin_232);
reduce_data_Callback(hObject, eventdata, H)

function lowint_val_232_Callback(hObject, eventdata, H)
lowint_232 = str2num(get(H.lowint_val_232,'String'));
lowint_val_dec_232 = str2num(get(H.lowint_val_232,'String'))/100+0.5; %slider val
set(H.slider_lowint_232, 'Value', lowint_val_dec_232);
reduce_data_Callback(hObject, eventdata, H)

function lin_val_232_Callback(hObject, eventdata, H)
lin_232 = str2num(get(H.lin_val_232,'String'));
lin_val_dec_232 = str2num(get(H.lin_val_232,'String'))/100+0.5; %slider val
set(H.slider_lin_232, 'Value', lin_val_dec_232);
reduce_data_Callback(hObject, eventdata, H)

Use_SL_68 = get(H.Use_SL_68, 'Value'); % checkbox
Use_SL_67 = get(H.Use_SL_67, 'Value'); % checkbox
Use_R33_68 = get(H.Use_R33_68, 'Value'); % checkbox
reduce_data_Callback(hObject, eventdata, H)

function reject_std_level_67_CreateFcn(hObject, eventdata, handles)
function slider_lin_232_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function all_standards_Callback(hObject, eventdata, handles)
function all_standards_CreateFcn(hObject, eventdata, handles)
function comment1_sum_std_Callback(hObject, eventdata, handles)
function comment1_sum_std_CreateFcn(hObject, eventdata, handles)
function comment1_sum_unk_Callback(hObject, eventdata, handles)
function comment1_sum_unk_CreateFcn(hObject, eventdata, handles)
function all_unknowns_Callback(hObject, eventdata, handles)
function all_unknowns_CreateFcn(hObject, eventdata, handles)
function filter_235_CreateFcn(hObject, eventdata, handles)
function StdErr68_Callback(hObject, eventdata, handles)
function StdErr68_CreateFcn(hObject, eventdata, handles)
function StdErr67_Callback(hObject, eventdata, handles)
function StdErr67_CreateFcn(hObject, eventdata, handles)
function comment3_sum_std_Callback(hObject, eventdata, handles)
function comment3_sum_std_CreateFcn(hObject, eventdata, handles)
function comment2_sum_std_Callback(hObject, eventdata, handles)
function comment2_sum_std_CreateFcn(hObject, eventdata, handles)
function peakoffsetcutoff_CreateFcn(hObject, eventdata, handles)
function slider_lowint_232_CreateFcn(hObject, eventdata, handles)
function lin_val_232_CreateFcn(hObject, eventdata, handles)
function lowint_val_232_CreateFcn(hObject, eventdata, handles)
function bestage_cutoff_CreateFcn(hObject, eventdata, handles)
function filter_err68_CreateFcn(hObject, eventdata, handles)
function filter_cutoff_CreateFcn(hObject, eventdata, handles)
function filter_revdisc_Callback(hObject, eventdata, handles)
function filter_disc_rev_CreateFcn(hObject, eventdata, handles)
function filter_disc_CreateFcn(hObject, eventdata, handles)
function filter_err67_CreateFcn(hObject, eventdata, handles)
function filter_204_CreateFcn(hObject, eventdata, handles)
function comment6_sum_std_Callback(hObject, eventdata, handles)
function comment6_sum_std_CreateFcn(hObject, eventdata, handles)
function comment6_sum_unk_Callback(hObject, eventdata, handles)
function comment6_sum_unk_CreateFcn(hObject, eventdata, handles)
function comment7_sum_unk_Callback(hObject, eventdata, handles)
function comment7_sum_unk_CreateFcn(hObject, eventdata, handles)
function comment7_sum_std_Callback(hObject, eventdata, handles)
function comment7_sum_std_CreateFcn(hObject, eventdata, handles)
function comment5_sum_unk_Callback(hObject, eventdata, handles)
function comment5_sum_unk_CreateFcn(hObject, eventdata, handles)
function comment5_sum_std_Callback(hObject, eventdata, handles)
function comment5_sum_std_CreateFcn(hObject, eventdata, handles)
function comment4_sum_unk_Callback(hObject, eventdata, handles)
function comment4_sum_unk_CreateFcn(hObject, eventdata, handles)
function comment4_sum_std_Callback(hObject, eventdata, handles)
function comment4_sum_std_CreateFcn(hObject, eventdata, handles)
function comment3_sum_unk_Callback(hObject, eventdata, handles)
function comment3_sum_unk_CreateFcn(hObject, eventdata, handles)
function comment2_sum_unk_Callback(hObject, eventdata, handles)
function comment2_sum_unk_CreateFcn(hObject, eventdata, handles)
function comment8_sum_unk_Callback(hObject, eventdata, handles)
function comment8_sum_unk_CreateFcn(hObject, eventdata, handles)
function comment8_sum_std_Callback(hObject, eventdata, handles)
function comment8_sum_std_CreateFcn(hObject, eventdata, handles)
function rejected_unk_sum_Callback(hObject, eventdata, handles)
function rejected_unk_sum_CreateFcn(hObject, eventdata, handles)
function rejected_std_sum_Callback(hObject, eventdata, handles)
function rejected_std_sum_CreateFcn(hObject, eventdata, handles)
function comment9_sum_unk_Callback(hObject, eventdata, handles)
function comment9_sum_unk_CreateFcn(hObject, eventdata, handles)
function comment9_sum_std_Callback(hObject, eventdata, handles)
function comment9_sum_std_CreateFcn(hObject, eventdata, handles)
function StdErr82_Callback(hObject, eventdata, handles)
function StdErr82_CreateFcn(hObject, eventdata, handles)
%function edit271_Callback(hObject, eventdata, handles)
%function edit271_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit271 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%function edit272_Callback(hObject, eventdata, handles)
%function edit272_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit272 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function comment10_sum_std_Callback(hObject, eventdata, handles)
function comment10_sum_std_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comment10_sum_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function comment11_sum_std_Callback(hObject, eventdata, handles)
function comment11_sum_std_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comment11_sum_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
