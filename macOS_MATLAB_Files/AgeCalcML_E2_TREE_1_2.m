function varargout = AgeCalcML_E2_TREE_1_2(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@AgeCalcML_E2_TREE_1_2_OpeningFcn,'gui_OutputFcn',@AgeCalcML_E2_TREE_1_2_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
function AgeCalcML_E2_TREE_1_2_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
guidata(hObject, H);
function varargout = AgeCalcML_E2_TREE_1_2_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;
perc_MAD559 = get(H.calibslider,'Value');
perc_91500 = 1 - get(H.calibslider,'Value');
set(H.slider91500,'String',round(perc_91500*100,1))
set(H.sliderMAD559,'String',round(perc_MAD559*100,1))

function browser_Callback(hObject, eventdata, H)
folder_name = uigetdir; %prompt browser and select folder
set(H.filepath, 'String', folder_name); %show path name
H.folder_name = folder_name;
guidata(hObject, H);

function reducedata_Callback(hObject, eventdata, H)

cla(H.TREEcalib,'reset');
cla(H.TREEnorm,'reset');
cla(H.INDanalysis,'reset');

set(H.listbox1,'String','');

waitnum = 10;
h = waitbar(0,'Reducing TREE! Please wait...');

perc_MAD559 = get(H.calibslider,'Value');
perc_91500 = 1 - get(H.calibslider,'Value');
set(H.slider91500,'String',round(perc_91500*100,1))
set(H.sliderMAD559,'String',round(perc_MAD559*100,1))

Chapmanetal2016 = 1;
HintonUpton1991 = 0;
Nardietal2013 = 0;
Sanoetal2002 = 0;
Tayloretal2015 = 0;




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

waitbar(7/waitnum, h, 'Reducing TREE! Please wait...'); %%%%%%%%%%%%%%%%%% waitbar %%%%%%%%%%%%%%%%%%

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


close(h)












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
%set(gca, 'FontSize', 36, 'FontWeight', 'Bold')
ylim([-100 100])
%title('Session 1 Volcanic, 100% MAD559', 'FontSize', 50, 'FontWeight', 'Bold')









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
%set(gca, 'FontSize', 36, 'FontWeight', 'Bold')
%ylim([-100 100])
%title('Session 1 Volcanic, 100% MAD559', 'FontSize', 50, 'FontWeight', 'Bold')







H.ChonNormUnknowns = ChonNormUnknowns;

guidata(hObject, H);

listbox1_Callback(hObject, eventdata, H)







function listbox1_Callback(hObject, eventdata, H)


cla(H.INDanalysis,'reset');
selected = get(H.listbox1,'Value')
axes(H.INDanalysis)
hold on







%{
ChonNormUnknowns = H.ChonNormUnknowns;





s7 = plot([1:1:14], ChonNormUnknowns(selected,:),'k','LineWidth',1);
%}




function checkbox5_Callback(hObject, eventdata, H)
function checkbox6_Callback(hObject, eventdata, H)
function checkbox7_Callback(hObject, eventdata, H)
function checkbox8_Callback(hObject, eventdata, H)
function checkbox9_Callback(hObject, eventdata, H)
function checkbox10_Callback(hObject, eventdata, H)
function checkbox11_Callback(hObject, eventdata, H)




function autoreduce_Callback(hObject, eventdata, H)






function calibslider_Callback(hObject, eventdata, H)


perc_MAD559 = get(H.calibslider,'Value');
perc_91500 = 1 - get(H.calibslider,'Value');
set(H.slider91500,'String',round(perc_91500*100,1))
set(H.sliderMAD559,'String',round(perc_MAD559*100,1))
guidata(hObject, H);
reducedata_Callback(hObject, eventdata, H)

function slider91500_Callback(hObject, eventdata, H)
perc_91500 = str2num(get(H.slider91500,'String'))*.01;
perc_MAD559 = 1 - perc_91500;
set(H.calibslider,'Value',1 - perc_91500)
set(H.sliderMAD559,'String',round(perc_MAD559*100,1))
guidata(hObject, H);
reducedata_Callback(hObject, eventdata, H)

function sliderMAD559_Callback(hObject, eventdata, H)
perc_MAD559 = str2num(get(H.sliderMAD559,'String'))*.01;
perc_91500 = 1 - perc_MAD559;
set(H.calibslider,'Value',perc_MAD559)
set(H.slider91500,'String',(1 - perc_MAD559)*100)
guidata(hObject, H);
reducedata_Callback(hObject, eventdata, H)


function checkbox13_Callback(hObject, eventdata, H)

function checkbox14_Callback(hObject, eventdata, H)

function checkbox15_Callback(hObject, eventdata, H)


% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16
