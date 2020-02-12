%% ACF MATLAB code for ACF.fig %%


%% SET DEFAULT COMMAND LINE AND HANDLE STRUCTURE %%
function varargout = ACF(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@ACF_OpeningFcn,'gui_OutputFcn',@ACF_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
gui_mainfcn(gui_State, varargin{:});
end
function ACF_OpeningFcn(hObject, eventdata, H2, varargin)
H2.output = hObject;
guidata(hObject, H2);
function varargout = ACF_OutputFcn(hObject, eventdata, H2) 
varargout{1} = H2.output;
global use_avg_ACF use_235 use_FC_68 use_FC_67 use_SL_68 use_SL_67 use_R33_68 deadtime lowint_238 lin_238 lowint_206 lin_206 

set(H2.dt,'Value', deadtime) %slider for change in deadtime 
set(H2.slider_lowint_238,'Value',((lowint_238+50)/100)); %slider val
set(H2.slider_lin_238,'Value',((lin_238+50)/100)); %slider val
set(H2.slider_lowint_206,'Value',((lowint_206+50)/100)); %slider val
set(H2.slider_lin_206,'Value',((lin_206+50)/100)); %slider val

set(H2.lowint_val_238,'String',lowint_238);
set(H2.lin_val_238,'String',lin_238);
set(H2.lowint_val_206,'String',lowint_206);
set(H2.lin_val_206,'String',lin_206);





%set(H2.slider_lin_232,'Value',((lin_232+50)/100)); %slider val

set(H2.Use_avg_ACF, 'Value',use_avg_ACF); % checkbox
set(H2.Use_235, 'Value',use_235); % checkbox
set(H2.Use_FC, 'Value',use_FC_68); % checkbox
set(H2.Use_FC, 'Value',use_FC_67); % checkbox
set(H2.Use_SL, 'Value',use_SL_68); % checkbox
set(H2.Use_SL, 'Value',use_SL_67); % checkbox
set(H2.Use_R33, 'Value',use_R33_68); % checkbox

ACF_Corr(hObject, eventdata, H2)

guidata(hObject,H2);

function ACF_Corr(hObject, eventdata, H2)

cla(H2.axes1,'reset');
cla(H2.axes2,'reset');

global factor64 rejectFC rejectSL rejectR33 odf68 bestage_cutoff filter_cutoff filter_err68 filter_err67 filter_disc filter_disc_rev filter_64 UPBdata2

deadtime = str2num(get(H2.dt,'String')); %slider for change in deadtime 
lowint_238 = get(H2.slider_lowint_238,'Value')*100-50; %slider val
lin_238 = get(H2.slider_lin_238,'Value')*100-50; %slider val
lowint_206 = get(H2.slider_lowint_206,'Value')*100-50; %slider val
lin_206 = get(H2.slider_lin_206,'Value')*100-50; %slider val
%lin_232 = get(H2.slider_lin_232,'Value')*100-50; %slider val
lin_232 = 0.5*100-50; %slider val



lowint68 = (lowint_238 + 50)*0.1-5;
lin68 = (lin_238 + 50)*0.1-5;
lowint67 = -(lowint_206+50)*0.005+0.25;
lin67 = -(lin_206 + 50)*0.0005+0.025;
lin82 = lin_232*0.1;

use_avg_ACF = get(H2.Use_avg_ACF, 'Value'); % checkbox
use_235 = get(H2.Use_235, 'Value'); % checkbox
use_FC_68 = get(H2.Use_FC, 'Value'); % checkbox
use_FC_67 = get(H2.Use_FC, 'Value'); % checkbox
use_SL_68 = get(H2.Use_SL, 'Value'); % checkbox
use_SL_67 = get(H2.Use_SL, 'Value'); % checkbox
use_R33_68 = get(H2.Use_R33, 'Value'); % checkbox

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


global numbers data sample2 values_all data_count STD1a_idx STD1b_idx STD2_idx sample_idx UPBdata UPB_pre

UPBdata2 = UPBdata;

sample = sample2;

for i = 1:data_count
	for j = 1:57
		%UPBdata2(j,3,i) = (values_all(j+16,3,i)-UPB_pre(i,3))/(1-(values_all(j+16,3,i)-UPB_pre(i,3))*deadtime/1000000000);
		UPBdata2(j,4,i) = (values_all(j+16,4,i)-UPB_pre(i,4))*(1+lowint67*exp(-1*(values_all(j+16,4,i)-UPB_pre(i,4))/10000) + lin67*(values_all(j+16,4,i)-UPB_pre(i,4))/10000);
		%UPBdata2(j,5,i) = (values_all(j+16,5,i)-UPB_pre(i,5))/(1-(values_all(j+16,5,i)-UPB_pre(i,5))*deadtime/1000000000);
		%UPBdata2(j,6,i) = (values_all(j+16,6,i)-UPB_pre(i,6))/(1-(values_all(j+16,6,i)-UPB_pre(i,6))*deadtime/1000000000);
		%UPBdata2(j,7,i) = (values_all(j+16,7,i)-UPB_pre(i,7))/(1-(values_all(j+16,7,i)-UPB_pre(i,7))*deadtime/1000000000);
		if UPBdata2(j,7,i)*137.82 > 5000000
			UPBdata2(j,8,i) = UPBdata2(j,7,i)*(1+(0.3*lin68*((137.82*UPBdata2(j,7,i))^1.5)/100000000000));
		else
			UPBdata2(j,8,i) = UPBdata2(j,7,i)*(1+0.2*lowint68*exp(-0.000001*(UPBdata2(j,7,i)*137.82)));
		end
		%UPBdata2(j,9,i) = (values_all(j+16,8,i)-UPB_pre(i,8))/(1-(values_all(j+16,8,i)-UPB_pre(i,8))*deadtime/1000000000);
		if UPBdata2(j,9,i) > 5000000
			UPBdata2(j,10,i) = UPBdata2(j,9,i)*(1+(0.3*lin68*(UPBdata2(j,9,i)^1.5)/100000000000));
		else
			UPBdata2(j,10,i) = UPBdata2(j,9,i)*(1+0.2*lowint68*exp(-0.000001*UPBdata2(j,9,i)));
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
	if mean(UPBdata2(4:38,10,i)) < 50000 || mean(UPBdata2(4:38,2,i)) > 100000
		mode(i,1) = {'bad'}; 
	elseif countsum(1,i) < 3
		mode(i,1) = {'IC'};
	elseif mean(UPBdata2(4:38,10,i)) > 5000000
		mode(i,1) = {'AN'};
	else
		mode(i,1) = {'MI'};
	end
end

for i = 1:data_count
	for j = 1:57
		if UPBdata2(j,8,i) == 0 || UPBdata2(j,10,i) == 0
			UPBdata2(j,11,i) = 1.3;
		elseif strcmp(mode{i,1}, 'IC') == 1
			UPBdata2(j,11,i) = UPBdata2(j,3,i)/UPBdata2(j,10,i);
		else
			UPBdata2(j,11,i) = UPBdata2(j,3,i)/(UPBdata2(j,8,i)*137.82);
		end
	end
end
		
for i = 1:data_count
	for j = 1:57
		if UPBdata2(j,3,i)/UPBdata2(j,4,i) > 30
			UPBdata2(j,12,i) = 30;
		elseif UPBdata2(j,3,i)/UPBdata2(j,4,i) < 1.5
			UPBdata2(j,12,i) = 1.5;
		else
			UPBdata2(j,12,i) = UPBdata2(j,3,i)/UPBdata2(j,4,i);
		end
	end
end

for  i = 1:data_count
	[p68(i,:)] = polyfit((1:1:35)',UPBdata(4:38,11,i),1);
	%[p82(i,:)] = polyfit((1:1:35)',UPBdata(4:38,14,i),1);
end

for  i = 1:data_count
f68(:,i) = polyval(p68(i,:),(1:1:35)');
%f82(:,i) = polyval(p82(i,:),(1:1:35)');
end


for  i = 1:data_count
	f68r(:,i) = f68(:,i) - UPBdata(4:38,11,i); %calculate residual
	%f82r(:,i) = f82(:,i) - UPBdata(4:38,14,i); %calculate residual
end

for  i = 1:data_count
	fit68_err(i,1) = (std(f68r(:,i))/sqrt(35))*2;
	%fit82_err(i,1) = (std(f82r(:,i))/sqrt(35))*2;
end


UPB_reduced = zeros(data_count,18);
for i = 1:data_count
	UPB_reduced(i,1) = abs(mean(UPBdata2(4:38,2,i)));
	UPB_reduced(i,2) = abs(mean(UPBdata2(4:38,3,i)));
	UPB_reduced(i,3) = abs(mean(UPBdata2(4:38,4,i)));
	UPB_reduced(i,4) = abs(mean(UPBdata2(4:38,5,i)));
	if mean(UPBdata2(4:38,6,i)) < 1000
		UPB_reduced(i,5) = 1;
	else
		UPB_reduced(i,5) = abs(mean(UPBdata2(4:38,6,i)));
	end
	if mean(UPBdata2(4:38,8,i)) < 1000
		UPB_reduced(i,6) = 1;
	else
		UPB_reduced(i,6) = abs(mean(UPBdata2(4:38,8,i)));
	end
	if mean(UPBdata2(4:38,10,i)) < 1000
		UPB_reduced(i,7) = 1;
	else
		UPB_reduced(i,7) = abs(mean(UPBdata2(4:38,10,i)));
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,8) = 1.3;
	elseif use_235 == 1
		UPB_reduced(i,8) = sum(UPBdata2(:,3,i))./(137.82*sum(UPBdata2(:,8,i)));
	else
		UPB_reduced(i,8) = sum(UPBdata2(:,3,i))./sum(UPBdata2(:,10,i));
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
	elseif sum(UPBdata2(:,3,i))/sum(UPBdata2(:,4,i)) < 1.5
		UPB_reduced(i,11) = 1.5;
	elseif sum(UPBdata2(:,3,i))/sum(UPBdata2(:,4,i)) > 30
		UPB_reduced(i,11) = 30;
	else
		UPB_reduced(i,11) = sum(UPBdata2(:,3,i))/sum(UPBdata2(:,4,i));
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,12) = 1;
	elseif 100*std(UPBdata2(4:38,12,i))/UPB_reduced(i,11)/sqrt(35) > 50
		UPB_reduced(i,12) = 50;
	else
		UPB_reduced(i,12) = 100*std(UPBdata2(4:38,12,i))/UPB_reduced(i,11)/sqrt(35);
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
	elseif (100*std(UPBdata2(4:38,13,i))/UPB_reduced(i,13))/sqrt(35) > 100
		UPB_reduced(i,14) = 100;
	else
		UPB_reduced(i,14) = (100*std(UPBdata2(4:38,13,i))/UPB_reduced(i,13))/sqrt(35);
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
	elseif 100*std(UPBdata2(4:38,15,i))/UPB_reduced(i,17)/sqrt(35) > 50
		UPB_reduced(i,18) = 50;
	else
		UPB_reduced(i,18) = 100*std(UPBdata2(4:38,15,i))/UPB_reduced(i,17)/sqrt(35);
	end
end

for i = 1:data_count
	serial{i,1} = i;
end

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

for i = 1:data_count %cols DD, DE, DF vs ET. should these have *0.01?
	if sample_idx(i,1) == 1 && strcmp(mode{i,1}, 'IC') == 1 && isempty(comment{i,1}) == 1 && ... 
			Age68(i,1) > (1-filter_disc*0.05)*cell2num(Age67(i,1)) && Age68(i,1) < (1+filter_disc_rev*0.05)*cell2num(Age67(i,1))
		Unk_IC_x(i,1) = UPB_reduced(i,7);
		Unk_IC_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_IC_x(i,1) = 0;
		Unk_IC_y(i,1) = 0;
	end
	if sample_idx(i,1) == 1 && strcmp(mode{i,1}, 'MI') == 1 && isempty(comment{i,1}) == 1 && ... 
			Age68(i,1) > (1-filter_disc*0.05)*cell2num(Age67(i,1)) && Age68(i,1) < (1+filter_disc_rev*0.05)*cell2num(Age67(i,1))
		Unk_MI_x(i,1) = UPB_reduced(i,7);
		Unk_MI_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_MI_x(i,1) = 0;
		Unk_MI_y(i,1) = 0;
	end
	if sample_idx(i,1) == 1 && strcmp(mode{i,1}, 'AN') == 1 && isempty(comment{i,1}) == 1 && ... 
			Age68(i,1) > (1-filter_disc*0.05)*cell2num(Age67(i,1)) && Age68(i,1) < (1+filter_disc_rev*0.05)*cell2num(Age67(i,1))
		Unk_AN_x(i,1) = UPB_reduced(i,7);
		Unk_AN_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_AN_x(i,1) = 0;
		Unk_AN_y(i,1) = 0;
	end
end

for i = 1:data_count %cols HO, HP, HQ vs ET
	if sample_idx(i,1) == 1 && strcmp(mode{i,1}, 'IC') == 1 &&  Age68(i,1) > filter_cutoff && ... 
			Age68(i,1) < (1-filter_disc*0.01)*cell2num(Age67(i,1))
		Unk_IC_D_x(i,1) = UPB_reduced(i,7);
		Unk_IC_D_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_IC_D_x(i,1) = 0;
		Unk_IC_D_y(i,1) = 0;
	end
	if sample_idx(i,1) == 1 && strcmp(mode{i,1}, 'MI') == 1 &&  Age68(i,1) > filter_cutoff && ... 
			Age68(i,1) < (1-filter_disc*0.01)*cell2num(Age67(i,1)) 
		Unk_MI_D_x(i,1) = UPB_reduced(i,7);
		Unk_MI_D_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_MI_D_x(i,1) = 0;
		Unk_MI_D_y(i,1) = 0;
	end
	if sample_idx(i,1) == 1 && strcmp(mode{i,1}, 'AN') == 1 && Age68(i,1) > filter_cutoff && ... 
			Age68(i,1) < (1-filter_disc*0.01)*cell2num(Age67(i,1)) 
		Unk_AN_D_x(i,1) = UPB_reduced(i,7);
		Unk_AN_D_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_AN_D_x(i,1) = 0;
		Unk_AN_D_y(i,1) = 0;
	end
end

for i = 1:data_count % cols HR, HS, HT vs ET
	if sample_idx(i,1) == 1 && strcmp(mode{i,1}, 'IC') == 1 &&  Age68(i,1) > filter_cutoff && ... 
			Age68(i,1) > (1+filter_disc_rev*0.01)*cell2num(Age67(i,1))
		Unk_IC_RD_x(i,1) = UPB_reduced(i,7);
		Unk_IC_RD_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_IC_RD_x(i,1) = 0;
		Unk_IC_RD_y(i,1) = 0;
	end
	if sample_idx(i,1) == 1 && strcmp(mode{i,1}, 'MI') == 1 &&  Age68(i,1) > filter_cutoff && ... 
			Age68(i,1) > (1+filter_disc_rev*0.01)*cell2num(Age67(i,1))
		Unk_MI_RD_x(i,1) = UPB_reduced(i,7);
		Unk_MI_RD_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_MI_RD_x(i,1) = 0;
		Unk_MI_RD_y(i,1) = 0;
	end
	if sample_idx(i,1) == 1 && strcmp(mode{i,1}, 'AN') == 1 && Age68(i,1) > filter_cutoff && ... 
			Age68(i,1) > (1+filter_disc_rev*0.01)*cell2num(Age67(i,1))
		Unk_AN_RD_x(i,1) = UPB_reduced(i,7);
		Unk_AN_RD_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_AN_RD_x(i,1) = 0;
		Unk_AN_RD_y(i,1) = 0;
	end
end

Unk_IC_x = nonzeros(Unk_IC_x);
Unk_IC_y = nonzeros(Unk_IC_y);
Unk_MI_x = nonzeros(Unk_MI_x);
Unk_MI_y = nonzeros(Unk_MI_y);
Unk_AN_x = nonzeros(Unk_AN_x);
Unk_AN_y = nonzeros(Unk_AN_y);
Unk_IC_D_x = nonzeros(Unk_IC_D_x);
Unk_IC_D_y = nonzeros(Unk_IC_D_y);
Unk_MI_D_x = nonzeros(Unk_MI_D_x);
Unk_MI_D_y = nonzeros(Unk_MI_D_y);
Unk_AN_D_x = nonzeros(Unk_AN_D_x);
Unk_AN_D_y = nonzeros(Unk_AN_D_y);
Unk_IC_RD_x = nonzeros(Unk_IC_RD_x);
Unk_IC_RD_y = nonzeros(Unk_IC_RD_y);
Unk_MI_RD_x = nonzeros(Unk_MI_RD_x);
Unk_MI_RD_y = nonzeros(Unk_MI_RD_y);
Unk_AN_RD_x = nonzeros(Unk_AN_RD_x);
Unk_AN_RD_y = nonzeros(Unk_AN_RD_y);

for i = 1:data_count % cols HR, HS, HT vs ET
	if sample_idx(i,1) == 1 &&  Age68(i,1) > filter_cutoff && Age68(i,1) > (1-filter_disc*0.01)*cell2num(Age67(i,1)) && Age68(i,1) < (1+filter_disc_rev*0.01)*cell2num(Age67(i,1))
		Unk_206_x(i,1) = UPB_reduced(i,2); %col HY
		Unk_206_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_206_x(i,1) = 0;
		Unk_206_y(i,1) = 0;
	end
	if sample_idx(i,1) == 1 &&  Age68(i,1) > filter_cutoff && Age68(i,1) < (1-filter_disc*0.01)*cell2num(Age67(i,1))
		Unk_206_D_x(i,1) = UPB_reduced(i,2); %col HW
		Unk_206_D_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_206_D_x(i,1) = 0;
		Unk_206_D_y(i,1) = 0;
	end
	if sample_idx(i,1) == 1 &&  Age68(i,1) > filter_cutoff && Age68(i,1) > (1+filter_disc_rev*0.01)*cell2num(Age67(i,1))
		Unk_206_RD_x(i,1) = UPB_reduced(i,2); %col HX
		Unk_206_RD_y(i,1) = ((100*Age68(i,1)/cell2num(Age67(i,1)))-100)/5;
	else
		Unk_206_RD_x(i,1) = 0;
		Unk_206_RD_y(i,1) = 0;
	end	
end
Unk_206_x = nonzeros(Unk_206_x);
Unk_206_y = nonzeros(Unk_206_y);
Unk_206_D_x = nonzeros(Unk_206_D_x);
Unk_206_D_y = nonzeros(Unk_206_D_y);
Unk_206_RD_x = nonzeros(Unk_206_RD_x);
Unk_206_RD_y = nonzeros(Unk_206_RD_y);

hold on

	dtcut = [5000000, 30; 5000000,-30];
	z = [0, 0; 30000000, 0];

	axes(H2.axes1);
	hold on
		plot(dtcut(:,1),dtcut(:,2),'k','LineWidth', 1); 
		plot(z(:,1),z(:,2),'k','LineWidth', 1); 
		h1 = scatter(Unk_IC_x, Unk_IC_y, 75,  'd', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5]);
		h1D = scatter(Unk_IC_D_x, Unk_IC_D_y, 75,  'd', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5], 'MarkerFaceColor', [.5 .5 .5]);
		h1RD = scatter(Unk_IC_RD_x, Unk_IC_RD_y, 75,  'd', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5], 'MarkerFaceColor', [.5 .5 .5]);
		h2 = scatter(FC_IC_238, FC_IC_OS, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
		h3 = scatter(SL_IC_238, SL_IC_OS, 75, 'b', 'filled', 'd', 'LineWidth', 1.25);
		h4 = scatter(R33_IC_238, R33_IC_OS, 75,  'd','MarkerEdgeColor', [0.1 0.7 0.1], 'MarkerFaceColor', [0.1 0.7 0.1], 'LineWidth', 1.25);
		h5 = scatter(Unk_MI_x, Unk_MI_y, 75,  'o', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5]);
		h5D = scatter(Unk_MI_D_x, Unk_MI_D_y, 75,  'o', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5], 'MarkerFaceColor', [.5 .5 .5]);
		h5RD = scatter(Unk_MI_RD_x, Unk_MI_RD_y, 75,  'o', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5], 'MarkerFaceColor', [.5 .5 .5]);
		h6 = scatter(FC_MI_238, FC_MI_OS, 75, 'r', 'o', 'LineWidth', 1.25);
		h7 = scatter(SL_MI_238, SL_MI_OS, 75, 'b', 'o', 'LineWidth', 1.25);
		h8 = scatter(R33_MI_238, R33_MI_OS, 75, 'g', 'o','MarkerEdgeColor', [0.1 0.7 0.1], 'LineWidth', 1.25);
		h9 = scatter(Unk_AN_x, Unk_AN_y, 75,  'x', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5]);
		h9D = scatter(Unk_AN_D_x, Unk_AN_D_y, 75,  's', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5], 'MarkerFaceColor', [.5 .5 .5]);
		h9RD = scatter(Unk_AN_RD_x, Unk_AN_RD_y, 75,  's', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5], 'MarkerFaceColor', [.5 .5 .5]);
		h10 = scatter(FC_AN_238, FC_AN_OS, 75, 'r', 'x', 'LineWidth', 1.25);
		h11 = scatter(SL_AN_238, SL_AN_OS, 75, 'b', 'x', 'LineWidth', 1.25);
		h12 = scatter(R33_AN_238, R33_AN_OS, 75, 'g', 'x', 'MarkerEdgeColor', [0.1 0.7 0.1], 'LineWidth', 1.25);
		leg = legend([h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12],{'Unk-IC' 'FC-IC', 'SL-IC', 'R33-IC', 'Unk-MI', 'FC-MI', 'SL-MI', 'R33-MI', 'Unk-AN', 'FC-AN', 'SL-AN', 'R33-AN'});
		%leg.NumColumns = 3;
		xlabel('U average intensity (cps)')
		ylabel('Age Offset (%)')
		axis([0 24999999 -15 15])
		ax = gca;
		ax.XRuler.Exponent = 0;
		box on
	
	axes(H2.axes2);
	hold on
		plot(dtcut(:,1),dtcut(:,2),'k','LineWidth', 1); 
		plot(z(:,1),z(:,2),'k','LineWidth', 1); 
		h1 = scatter(FC_206, FC_67_OS, 75, 'r', 'filled', 'd', 'LineWidth', 1.25);
		h2 = scatter(Unk_206_x, Unk_206_y, 75,  'o', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5]);
		h3 = scatter(SL_206, SL_67_OS, 75, 'b', 'filled', 'd', 'LineWidth', 1.25);
		h4 = scatter(Unk_206_D_x, Unk_206_D_y, 75, 'b', 'filled', 'o', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5], 'MarkerFaceColor', [.5 .5 .5]);
		h5 = scatter(R33_206, R33_67_OS, 75,  'd','MarkerEdgeColor', [0.1 0.7 0.1], 'MarkerFaceColor', [0.1 0.7 0.1], 'LineWidth', 1.25);
		h6 = scatter(Unk_206_RD_x, Unk_206_RD_y, 75, 'b', 'filled', 'o', 'LineWidth', 1.25, 'MarkerEdgeColor', [.5 .5 .5], 'MarkerFaceColor', [.5 .5 .5]);
		leg = legend([h1 h2 h3 h4 h5 h6],{'FC' 'UNK-acc', 'SL', 'Unk-Disc', 'R33', 'Unk-RD'});
		%leg.NumColumns = 3;
		xlabel('206Pb average intensity (cps)')
		ylabel('Age Offset (%)')
		axis([0 3999999 -25 25])
		ax = gca;
		ax.XRuler.Exponent = 0;
		box on

FC_IC_OS_mean = mean(abs(FC_IC_OS));		
FC_MI_OS_mean = mean(abs(FC_MI_OS));
FC_AN_OS_mean = mean(abs(FC_AN_OS));
FC_ALL_OS_mean = mean(abs([FC_IC_OS;FC_MI_OS;FC_AN_OS]));		

SL_IC_OS_mean = mean(abs(SL_IC_OS));		
SL_MI_OS_mean = mean(abs(SL_MI_OS));
SL_AN_OS_mean = mean(abs(SL_AN_OS));
SL_ALL_OS_mean = mean(abs([SL_IC_OS;SL_MI_OS;SL_AN_OS]));
				
R33_IC_OS_mean = mean(abs(R33_IC_OS));		
R33_MI_OS_mean = mean(abs(R33_MI_OS));
R33_AN_OS_mean = mean(abs(R33_AN_OS));
R33_ALL_OS_mean = mean(abs([R33_IC_OS;R33_MI_OS;R33_AN_OS]));
		


function std_int68_Callback(hObject, eventdata, H)

function std_int67_Callback(hObject, eventdata, H)

function std_int82_Callback(hObject, eventdata, H)

function export_comparison_Callback(hObject, eventdata, H)
H.export_comp = 1;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

%% ACF CORRECTIONS %%
function slider_lowint_238_Callback(hObject, eventdata, H)
lowint_238 = get(H.slider_lowint_238,'Value')*100-50; %slider val
set(H.lowint_val_238, 'String', lowint_238);

function lowint_val_238_Callback(hObject, eventdata, H)
lowint_238 = str2num(get(H.lowint_val_238,'String'));
lowint_val_dec_238 = str2num(get(H.lowint_val_238,'String'))/100+0.5; %slider val
set(H.slider_lowint_238, 'Value', lowint_val_dec_238);

function slider_lin_238_Callback(hObject, eventdata, H)
lin_238 = get(H.slider_lin_238,'Value')*100-50; %slider val
set(H.lin_val_238, 'String', lin_238);

function lin_val_238_Callback(hObject, eventdata, H)
lin_238 = str2num(get(H.lin_val_238,'String'));
lin_val_dec_238 = str2num(get(H.lin_val_238,'String'))/100+0.5; %slider val
set(H.slider_lin_238, 'Value', lin_val_dec_238);

function slider_lowint_206_Callback(hObject, eventdata, H)
lowint_206 = get(H.slider_lowint_206,'Value')*100-50; %slider val
set(H.lowint_val_206, 'String', lowint_206);

function lowint_val_206_Callback(hObject, eventdata, H)
lowint_206 = str2num(get(H.lowint_val_206,'String'));
lowint_val_dec_206 = str2num(get(H.lowint_val_206,'String'))/100+0.5; %slider val
set(H.slider_lowint_206, 'Value', lowint_val_dec_206);

function slider_lin_206_Callback(hObject, eventdata, H)
lin_206 = get(H.slider_lin_206,'Value')*100-50; %slider val
set(H.lin_val_206, 'String', lin_206);

function lin_val_206_Callback(hObject, eventdata, H)
lin_206 = str2num(get(H.lin_val_206,'String'));
lin_val_dec_206 = str2num(get(H.lin_val_206,'String'))/100+0.5; %slider val
set(H.slider_lin_206, 'Value', lin_val_dec_206);

function slider_lin_232_Callback(hObject, eventdata, H)
lin_232 = get(H.slider_lin_232,'Value')*100-50; %slider val
set(H.lin_val_232, 'String', lin_232);

%function lin_val_232_Callback(hObject, eventdata, H)
%lin_232 = str2num(get(H.lin_val_232,'String'));
%lin_val_dec_232 = str2num(get(H.lin_val_232,'String'))/100+0.5; %slider val
%set(H.slider_lin_232, 'Value', lin_val_dec_232);

function Use_235_Callback(hObject, eventdata, H)

function dt_Callback(hObject, eventdata, H)
deadtime = str2num(get(H.dt,'String')); %slider for change in deadtime 



% --- Executes on button press in pushbutton106.
function pushbutton106_Callback(hObject, eventdata, H2)
% hObject    handle to pushbutton106 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ACF_Corr(hObject, eventdata, H2)


% --- Executes on button press in Use_avg_ACF.
function Use_avg_ACF_Callback(hObject, eventdata, handles)
% hObject    handle to Use_avg_ACF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Use_avg_ACF


% --- Executes during object creation, after setting all properties.
function dt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Use_FC.
function Use_FC_Callback(hObject, eventdata, handles)
% hObject    handle to Use_FC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Use_FC


% --- Executes on button press in Use_SL.
function Use_SL_Callback(hObject, eventdata, handles)
% hObject    handle to Use_SL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Use_SL


% --- Executes on button press in Use_R33.
function Use_R33_Callback(hObject, eventdata, handles)
% hObject    handle to Use_R33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Use_R33



function fc_ic_mean_Callback(hObject, eventdata, handles)
% hObject    handle to fc_ic_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fc_ic_mean as text
%        str2double(get(hObject,'String')) returns contents of fc_ic_mean as a double


% --- Executes during object creation, after setting all properties.
function fc_ic_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fc_ic_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fc_mi_mean_Callback(hObject, eventdata, handles)
% hObject    handle to fc_mi_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fc_mi_mean as text
%        str2double(get(hObject,'String')) returns contents of fc_mi_mean as a double


% --- Executes during object creation, after setting all properties.
function fc_mi_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fc_mi_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fc_an_mean_Callback(hObject, eventdata, handles)
% hObject    handle to fc_an_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fc_an_mean as text
%        str2double(get(hObject,'String')) returns contents of fc_an_mean as a double


% --- Executes during object creation, after setting all properties.
function fc_an_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fc_an_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fc_all_mean2_Callback(hObject, eventdata, handles)
% hObject    handle to fc_all_mean2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fc_all_mean2 as text
%        str2double(get(hObject,'String')) returns contents of fc_all_mean2 as a double


% --- Executes during object creation, after setting all properties.
function fc_all_mean2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fc_all_mean2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sl_ic_mean_Callback(hObject, eventdata, handles)
% hObject    handle to sl_ic_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sl_ic_mean as text
%        str2double(get(hObject,'String')) returns contents of sl_ic_mean as a double


% --- Executes during object creation, after setting all properties.
function sl_ic_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_ic_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sl_mi_mean_Callback(hObject, eventdata, handles)
% hObject    handle to sl_mi_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sl_mi_mean as text
%        str2double(get(hObject,'String')) returns contents of sl_mi_mean as a double


% --- Executes during object creation, after setting all properties.
function sl_mi_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_mi_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sl_an_mean_Callback(hObject, eventdata, handles)
% hObject    handle to sl_an_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sl_an_mean as text
%        str2double(get(hObject,'String')) returns contents of sl_an_mean as a double


% --- Executes during object creation, after setting all properties.
function sl_an_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_an_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sl_all_mean_Callback(hObject, eventdata, handles)
% hObject    handle to sl_all_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sl_all_mean as text
%        str2double(get(hObject,'String')) returns contents of sl_all_mean as a double


% --- Executes during object creation, after setting all properties.
function sl_all_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_all_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function r33_ic_mean_Callback(hObject, eventdata, handles)
% hObject    handle to r33_ic_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r33_ic_mean as text
%        str2double(get(hObject,'String')) returns contents of r33_ic_mean as a double


% --- Executes during object creation, after setting all properties.
function r33_ic_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r33_ic_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function r33_mi_mean_Callback(hObject, eventdata, handles)
% hObject    handle to r33_mi_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r33_mi_mean as text
%        str2double(get(hObject,'String')) returns contents of r33_mi_mean as a double


% --- Executes during object creation, after setting all properties.
function r33_mi_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r33_mi_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function r33_an_mean_Callback(hObject, eventdata, handles)
% hObject    handle to r33_an_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r33_an_mean as text
%        str2double(get(hObject,'String')) returns contents of r33_an_mean as a double


% --- Executes during object creation, after setting all properties.
function r33_an_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r33_an_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function r33_all_mean_Callback(hObject, eventdata, handles)
% hObject    handle to r33_all_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r33_all_mean as text
%        str2double(get(hObject,'String')) returns contents of r33_all_mean as a double


% --- Executes during object creation, after setting all properties.
function r33_all_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r33_all_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in calc1.
function calc1_Callback(hObject, eventdata, H2)

global factor64 rejectFC rejectSL rejectR33 odf68 bestage_cutoff filter_cutoff filter_err68 filter_err67 filter_disc filter_disc_rev filter_64 UPBdata2

use_avg_ACF = get(H2.Use_avg_ACF, 'Value'); % checkbox
use_235 = get(H2.Use_235, 'Value'); % checkbox
use_FC_68 = get(H2.Use_FC, 'Value'); % checkbox
use_FC_67 = get(H2.Use_FC, 'Value'); % checkbox
use_SL_68 = get(H2.Use_SL, 'Value'); % checkbox
use_SL_67 = get(H2.Use_SL, 'Value'); % checkbox
use_R33_68 = get(H2.Use_R33, 'Value'); % checkbox

n = 0;

h = waitbar(0);

r1min = str2num(get(H2.R1min,'String'));
r1max = str2num(get(H2.R1max,'String'));
r2min = str2num(get(H2.R2min,'String'));
r2max = str2num(get(H2.R2max,'String'));

waiter = numel(r1min:1:r1max)*numel(r2min:1:r2max);

for q = r1min:r1max
	for w = r2min:r2max

lowint_238 = q;
lin_238 = w;
lowint_206 = get(H2.slider_lowint_206,'Value')*100-50; %slider val
lin_206 = get(H2.slider_lin_206,'Value')*100-50; %slider val
		
set(H2.slider_lowint_238,'Value',((lowint_238+50)/100)); %slider val
set(H2.slider_lin_238,'Value',((lin_238+50)/100)); %slider val
set(H2.slider_lowint_206,'Value',((lowint_206+50)/100)); %slider val
set(H2.slider_lin_206,'Value',((lin_206+50)/100)); %slider val

lowint_238 = get(H2.slider_lowint_238,'Value')*100-50; %slider val
lin_238 = get(H2.slider_lin_238,'Value')*100-50; %slider val
lowint_206 = get(H2.slider_lowint_206,'Value')*100-50; %slider val
lin_206 = get(H2.slider_lin_206,'Value')*100-50; %slider val
lin_232 = 0.5*100-50; %slider val

lowint68 = (lowint_238 + 50)*0.1-5;
lin68 = (lin_238 + 50)*0.1-5;
lowint67 = -(lowint_206+50)*0.005+0.25;
lin67 = -(lin_206 + 50)*0.0005+0.025;
lin82 = lin_232*0.1;

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


global numbers data sample2 values_all data_count STD1a_idx STD1b_idx STD2_idx sample_idx UPBdata UPB_pre

UPBdata2 = UPBdata;

sample = sample2;

for i = 1:data_count
	for j = 1:57
		%UPBdata2(j,3,i) = (values_all(j+16,3,i)-UPB_pre(i,3))/(1-(values_all(j+16,3,i)-UPB_pre(i,3))*deadtime/1000000000);
		UPBdata2(j,4,i) = (values_all(j+16,4,i)-UPB_pre(i,4))*(1+lowint67*exp(-1*(values_all(j+16,4,i)-UPB_pre(i,4))/10000) + lin67*(values_all(j+16,4,i)-UPB_pre(i,4))/10000);
		%UPBdata2(j,5,i) = (values_all(j+16,5,i)-UPB_pre(i,5))/(1-(values_all(j+16,5,i)-UPB_pre(i,5))*deadtime/1000000000);
		%UPBdata2(j,6,i) = (values_all(j+16,6,i)-UPB_pre(i,6))/(1-(values_all(j+16,6,i)-UPB_pre(i,6))*deadtime/1000000000);
		%UPBdata2(j,7,i) = (values_all(j+16,7,i)-UPB_pre(i,7))/(1-(values_all(j+16,7,i)-UPB_pre(i,7))*deadtime/1000000000);
		if UPBdata2(j,7,i)*137.82 > 5000000
			UPBdata2(j,8,i) = UPBdata2(j,7,i)*(1+(0.3*lin68*((137.82*UPBdata2(j,7,i))^1.5)/100000000000));
		else
			UPBdata2(j,8,i) = UPBdata2(j,7,i)*(1+0.2*lowint68*exp(-0.000001*(UPBdata2(j,7,i)*137.82)));
		end
		%UPBdata2(j,9,i) = (values_all(j+16,8,i)-UPB_pre(i,8))/(1-(values_all(j+16,8,i)-UPB_pre(i,8))*deadtime/1000000000);
		if UPBdata2(j,9,i) > 5000000
			UPBdata2(j,10,i) = UPBdata2(j,9,i)*(1+(0.3*lin68*(UPBdata2(j,9,i)^1.5)/100000000000));
		else
			UPBdata2(j,10,i) = UPBdata2(j,9,i)*(1+0.2*lowint68*exp(-0.000001*UPBdata2(j,9,i)));
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
	if mean(UPBdata2(4:38,10,i)) < 50000 || mean(UPBdata2(4:38,2,i)) > 100000
		mode(i,1) = {'bad'}; 
	elseif countsum(1,i) < 3
		mode(i,1) = {'IC'};
	elseif mean(UPBdata2(4:38,10,i)) > 5000000
		mode(i,1) = {'AN'};
	else
		mode(i,1) = {'MI'};
	end
end

for i = 1:data_count
	for j = 1:57
		if UPBdata2(j,8,i) == 0 || UPBdata2(j,10,i) == 0
			UPBdata2(j,11,i) = 1.3;
		elseif strcmp(mode{i,1}, 'IC') == 1
			UPBdata2(j,11,i) = UPBdata2(j,3,i)/UPBdata2(j,10,i);
		else
			UPBdata2(j,11,i) = UPBdata2(j,3,i)/(UPBdata2(j,8,i)*137.82);
		end
	end
end
		
for i = 1:data_count
	for j = 1:57
		if UPBdata2(j,3,i)/UPBdata2(j,4,i) > 30
			UPBdata2(j,12,i) = 30;
		elseif UPBdata2(j,3,i)/UPBdata2(j,4,i) < 1.5
			UPBdata2(j,12,i) = 1.5;
		else
			UPBdata2(j,12,i) = UPBdata2(j,3,i)/UPBdata2(j,4,i);
		end
	end
end

for  i = 1:data_count
	[p68(i,:)] = polyfit((1:1:35)',UPBdata(4:38,11,i),1);
	%[p82(i,:)] = polyfit((1:1:35)',UPBdata(4:38,14,i),1);
end

for  i = 1:data_count
f68(:,i) = polyval(p68(i,:),(1:1:35)');
%f82(:,i) = polyval(p82(i,:),(1:1:35)');
end


for  i = 1:data_count
	f68r(:,i) = f68(:,i) - UPBdata(4:38,11,i); %calculate residual
	%f82r(:,i) = f82(:,i) - UPBdata(4:38,14,i); %calculate residual
end

for  i = 1:data_count
	fit68_err(i,1) = (std(f68r(:,i))/sqrt(35))*2;
	%fit82_err(i,1) = (std(f82r(:,i))/sqrt(35))*2;
end


UPB_reduced = zeros(data_count,18);
for i = 1:data_count
	UPB_reduced(i,1) = abs(mean(UPBdata2(4:38,2,i)));
	UPB_reduced(i,2) = abs(mean(UPBdata2(4:38,3,i)));
	UPB_reduced(i,3) = abs(mean(UPBdata2(4:38,4,i)));
	UPB_reduced(i,4) = abs(mean(UPBdata2(4:38,5,i)));
	if mean(UPBdata2(4:38,6,i)) < 1000
		UPB_reduced(i,5) = 1;
	else
		UPB_reduced(i,5) = abs(mean(UPBdata2(4:38,6,i)));
	end
	if mean(UPBdata2(4:38,8,i)) < 1000
		UPB_reduced(i,6) = 1;
	else
		UPB_reduced(i,6) = abs(mean(UPBdata2(4:38,8,i)));
	end
	if mean(UPBdata2(4:38,10,i)) < 1000
		UPB_reduced(i,7) = 1;
	else
		UPB_reduced(i,7) = abs(mean(UPBdata2(4:38,10,i)));
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,8) = 1.3;
	elseif use_235 == 1
		UPB_reduced(i,8) = sum(UPBdata2(:,3,i))./(137.82*sum(UPBdata2(:,8,i)));
	else
		UPB_reduced(i,8) = sum(UPBdata2(:,3,i))./sum(UPBdata2(:,10,i));
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
	elseif sum(UPBdata2(:,3,i))/sum(UPBdata2(:,4,i)) < 1.5
		UPB_reduced(i,11) = 1.5;
	elseif sum(UPBdata2(:,3,i))/sum(UPBdata2(:,4,i)) > 30
		UPB_reduced(i,11) = 30;
	else
		UPB_reduced(i,11) = sum(UPBdata2(:,3,i))/sum(UPBdata2(:,4,i));
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,12) = 1;
	elseif 100*std(UPBdata2(4:38,12,i))/UPB_reduced(i,11)/sqrt(35) > 50
		UPB_reduced(i,12) = 50;
	else
		UPB_reduced(i,12) = 100*std(UPBdata2(4:38,12,i))/UPB_reduced(i,11)/sqrt(35);
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
	elseif (100*std(UPBdata2(4:38,13,i))/UPB_reduced(i,13))/sqrt(35) > 100
		UPB_reduced(i,14) = 100;
	else
		UPB_reduced(i,14) = (100*std(UPBdata2(4:38,13,i))/UPB_reduced(i,13))/sqrt(35);
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
	elseif 100*std(UPBdata2(4:38,15,i))/UPB_reduced(i,17)/sqrt(35) > 50
		UPB_reduced(i,18) = 50;
	else
		UPB_reduced(i,18) = 100*std(UPBdata2(4:38,15,i))/UPB_reduced(i,17)/sqrt(35);
	end
end

for i = 1:data_count
	serial{i,1} = i;
end

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

n = n+1;

FC_IC_OS_mean(n,1) = mean(abs(FC_IC_OS));		
FC_MI_OS_mean(n,1) = mean(abs(FC_MI_OS));
FC_AN_OS_mean(n,1) = mean(abs(FC_AN_OS));
FC_ALL_OS_mean(n,1) = mean(abs([FC_IC_OS;FC_MI_OS;FC_AN_OS]));
FC_ALL_OS_mean_out(n,1) = mean(abs([FC_IC_OS;FC_MI_OS;FC_AN_OS]));
	
%set(H2.fc_ic_mean, 'Value', FC_IC_OS_mean)
%set(H2.fc_mi_mean,'String',FC_MI_OS_mean)		
%set(H2.fc_an_mean,'String',FC_AN_OS_mean)		
%set(H2.fc_all_mean2,'String',FC_ALL_OS_mean);		

SL_IC_OS_mean(n,1) = mean(abs(SL_IC_OS));		
SL_MI_OS_mean(n,1) = mean(abs(SL_MI_OS));
SL_AN_OS_mean(n,1) = mean(abs(SL_AN_OS));
SL_ALL_OS_mean(n,1) = mean(abs([SL_IC_OS;SL_MI_OS;SL_AN_OS]));
SL_ALL_OS_mean_out(n,1) = mean(abs([SL_IC_OS;SL_MI_OS;SL_AN_OS]));
		
%set(H2.sl_ic_mean,'String',SL_IC_OS_mean)
%set(H2.sl_mi_mean,'String',SL_MI_OS_mean)		
%set(H2.sl_an_mean,'String',SL_AN_OS_mean)		
%set(H2.sl_all_mean,'String',SL_ALL_OS_mean)		


R33_IC_OS_mean(n,1) = mean(abs(R33_IC_OS));		
R33_MI_OS_mean(n,1) = mean(abs(R33_MI_OS));
R33_AN_OS_mean(n,1) = mean(abs(R33_AN_OS));
R33_ALL_OS_mean(n,1) = mean(abs([R33_IC_OS;R33_MI_OS;R33_AN_OS]));
R33_ALL_OS_mean_out(n,1) = mean(abs([R33_IC_OS;R33_MI_OS;R33_AN_OS]));
		
%set(H2.r33_ic_mean,'String',R33_IC_OS_mean)
%set(H2.r33_mi_mean,'String',R33_MI_OS_mean)		
%set(H2.r33_an_mean,'String',R33_AN_OS_mean)		
%set(H2.r33_all_mean,'String',R33_ALL_OS_mean)	

%set(H2.slider_lowint_238,'Value',((q+50)/100)); %slider val
%set(H2.slider_lin_238,'Value',((w+50)/100)); %slider val

%set(H2.lowint_val_238,'String',q); 
%set(H2.lin_val_238,'String',w);

waitbar((n/waiter), h, 'Please wait...');



qwe(n,1) = {[q,w]};

xlab(n,1) = strcat('[',num2str(q),{','},{' '},num2str(w),']');

	end
end

close(h)




Mean_ALL = mean([FC_ALL_OS_mean_out,R33_ALL_OS_mean_out,SL_ALL_OS_mean_out],2);

Mean_sq_ALL = sqrt(FC_ALL_OS_mean_out.*FC_ALL_OS_mean_out+SL_ALL_OS_mean_out.*SL_ALL_OS_mean_out+R33_ALL_OS_mean_out.*R33_ALL_OS_mean_out);



[Mean_All_min Mean_All_idx] = min(Mean_ALL);

idx = qwe{Mean_All_idx};

x = 1:numel(qwe);

cla(H2.axes3,'reset');
axes(H2.axes3);
hold on

if get(H2.plotall1,'Value') == 1
v1 = plot(x,FC_IC_OS_mean,':','Color','r','LineWidth', .5);
v2 = plot(x,FC_MI_OS_mean,'--','Color','r','LineWidth', .5);
v3 = plot(x,FC_AN_OS_mean,'Color','r','LineWidth', .5);
v4 = plot(x,FC_ALL_OS_mean_out,'Color','r','LineWidth', 2);

v5 = plot(x,SL_IC_OS_mean,':','Color','b','LineWidth', .5);
v6 = plot(x,SL_MI_OS_mean,'--','Color','b','LineWidth', .5);
v7 = plot(x,SL_AN_OS_mean,'Color','b','LineWidth', .5);
v8 = plot(x,SL_ALL_OS_mean_out,'Color','b','LineWidth', 2);

v9 = plot(x,R33_IC_OS_mean,':','Color',[0.1 0.7 0.1],'LineWidth', .5);
v10 = plot(x,R33_MI_OS_mean,'--','Color',[0.1 0.7 0.1],'LineWidth', .5);
v11 = plot(x,R33_AN_OS_mean,'Color',[0.1 0.7 0.1],'LineWidth', .5);
v12 = plot(x,R33_ALL_OS_mean_out,'Color',[0.1 0.7 0.1],'LineWidth', 2);

v0 = plot(x,Mean_ALL,'Color','k','LineWidth', 4);
end

if get(H2.plotall1,'Value') == 0
v0 = plot(x,Mean_ALL,'Color','k','LineWidth', 4);
end

scatter(Mean_All_idx,Mean_ALL(Mean_All_idx,1), 150, 'MarkerFaceColor', 'g')
scatter(Mean_All_idx,Mean_ALL(Mean_All_idx,1), 150, 'MarkerEdgeColor', 'k')

if get(H2.plotall1,'Value') == 0
legend([v0], 'Mean FC SL R33')
end

if get(H2.plotall1,'Value') == 1
legend([v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v0], 'FC-IC','FC-MI','FC-AN','FC mean','SL-IC','SL-MI','SL-AN','SL mean','R33-IC','R33-MI','R33-AN','R33 mean', 'Mean FC SL R33')
end

xticks(1:1:n)
xticklabels(xlab)

set(H2.slider_lowint_238,'Value',((idx(1,1)+50)/100)); %slider val
set(H2.slider_lin_238,'Value',((idx(1,2)+50)/100)); %slider val

set(H2.lowint_val_238,'String',idx(1,1)); 
set(H2.lin_val_238,'String',idx(1,2));

xlabel('Combination [Low-Int 238U, Linear 238U]')
ylabel('Percent Offset')

ACF_Corr(hObject, eventdata, H2)
%}

function R1min_Callback(hObject, eventdata, handles)
% hObject    handle to R1min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R1min as text
%        str2double(get(hObject,'String')) returns contents of R1min as a double


% --- Executes during object creation, after setting all properties.
function R1min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R1min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function R1max_Callback(hObject, eventdata, handles)
% hObject    handle to R1max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R1max as text
%        str2double(get(hObject,'String')) returns contents of R1max as a double


% --- Executes during object creation, after setting all properties.
function R1max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R1max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function R2min_Callback(hObject, eventdata, handles)
% hObject    handle to R2min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R2min as text
%        str2double(get(hObject,'String')) returns contents of R2min as a double


% --- Executes during object creation, after setting all properties.
function R2min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R2min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function R2max_Callback(hObject, eventdata, handles)
% hObject    handle to R2max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R2max as text
%        str2double(get(hObject,'String')) returns contents of R2max as a double


% --- Executes during object creation, after setting all properties.
function R2max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R2max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveandclose.
function saveandclose_Callback(hObject, eventdata, H2)
	
global lowint_238 use_235 lin_238 lowint_206 lin_206

lowint_238 = str2num(get(H2.lowint_val_238,'String'));
lin_238 = str2num(get(H2.lin_val_238,'String'));
lowint_206 = str2num(get(H2.lowint_val_206,'String'));
lin_206 = str2num(get(H2.lin_val_206,'String'));
use_235 = get(H2.Use_235,'Value');

close(ACF)




function R3min_Callback(hObject, eventdata, handles)
% hObject    handle to R3min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R3min as text
%        str2double(get(hObject,'String')) returns contents of R3min as a double


% --- Executes during object creation, after setting all properties.
function R3min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R3min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function R4min_Callback(hObject, eventdata, handles)
% hObject    handle to R4min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R4min as text
%        str2double(get(hObject,'String')) returns contents of R4min as a double


% --- Executes during object creation, after setting all properties.
function R4min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R4min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function R4max_Callback(hObject, eventdata, handles)
% hObject    handle to R4max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R4max as text
%        str2double(get(hObject,'String')) returns contents of R4max as a double


% --- Executes during object creation, after setting all properties.
function R4max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R4max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function R3max_Callback(hObject, eventdata, handles)
% hObject    handle to R3max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R3max as text
%        str2double(get(hObject,'String')) returns contents of R3max as a double


% --- Executes during object creation, after setting all properties.
function R3max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R3max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function calc2_Callback(hObject, eventdata, H2)
global factor64 rejectFC rejectSL rejectR33 odf68 bestage_cutoff filter_cutoff filter_err68 filter_err67 filter_disc filter_disc_rev filter_64 UPBdata2

use_avg_ACF = get(H2.Use_avg_ACF, 'Value'); % checkbox
use_235 = get(H2.Use_235, 'Value'); % checkbox
use_FC_68 = get(H2.Use_FC, 'Value'); % checkbox
use_FC_67 = get(H2.Use_FC, 'Value'); % checkbox
use_SL_68 = get(H2.Use_SL, 'Value'); % checkbox
use_SL_67 = get(H2.Use_SL, 'Value'); % checkbox
use_R33_68 = get(H2.Use_R33, 'Value'); % checkbox

n = 0;

h = waitbar(0);

r3min = str2num(get(H2.R3min,'String'));
r3max = str2num(get(H2.R3max,'String'));
r4min = str2num(get(H2.R4min,'String'));
r4max = str2num(get(H2.R4max,'String'));

waiter = numel(r3min:1:r3max)*numel(r4min:1:r4max);

for q = r3min:r4max
	for w = r4min:r4max

lowint_238 = get(H2.slider_lowint_238,'Value')*100-50; %slider val;
lin_238 = get(H2.slider_lin_238,'Value')*100-50; %slider val;
lowint_206 = q;
lin_206 = w;
		
set(H2.slider_lowint_238,'Value',((lowint_238+50)/100)); %slider val
set(H2.slider_lin_238,'Value',((lin_238+50)/100)); %slider val
set(H2.slider_lowint_206,'Value',((lowint_206+50)/100)); %slider val
set(H2.slider_lin_206,'Value',((lin_206+50)/100)); %slider val

lowint_238 = get(H2.slider_lowint_238,'Value')*100-50; %slider val
lin_238 = get(H2.slider_lin_238,'Value')*100-50; %slider val
lowint_206 = get(H2.slider_lowint_206,'Value')*100-50; %slider val
lin_206 = get(H2.slider_lin_206,'Value')*100-50; %slider val
lin_232 = 0.5*100-50; %slider val

lowint68 = (lowint_238 + 50)*0.1-5;
lin68 = (lin_238 + 50)*0.1-5;
lowint67 = -(lowint_206+50)*0.005+0.25;
lin67 = -(lin_206 + 50)*0.0005+0.025;
lin82 = lin_232*0.1;

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


global numbers data sample2 values_all data_count STD1a_idx STD1b_idx STD2_idx sample_idx UPBdata UPB_pre

UPBdata2 = UPBdata;

sample = sample2;

for i = 1:data_count
	for j = 1:57
		%UPBdata2(j,3,i) = (values_all(j+16,3,i)-UPB_pre(i,3))/(1-(values_all(j+16,3,i)-UPB_pre(i,3))*deadtime/1000000000);
		UPBdata2(j,4,i) = (values_all(j+16,4,i)-UPB_pre(i,4))*(1+lowint67*exp(-1*(values_all(j+16,4,i)-UPB_pre(i,4))/10000) + lin67*(values_all(j+16,4,i)-UPB_pre(i,4))/10000);
		%UPBdata2(j,5,i) = (values_all(j+16,5,i)-UPB_pre(i,5))/(1-(values_all(j+16,5,i)-UPB_pre(i,5))*deadtime/1000000000);
		%UPBdata2(j,6,i) = (values_all(j+16,6,i)-UPB_pre(i,6))/(1-(values_all(j+16,6,i)-UPB_pre(i,6))*deadtime/1000000000);
		%UPBdata2(j,7,i) = (values_all(j+16,7,i)-UPB_pre(i,7))/(1-(values_all(j+16,7,i)-UPB_pre(i,7))*deadtime/1000000000);
		if UPBdata2(j,7,i)*137.82 > 5000000
			UPBdata2(j,8,i) = UPBdata2(j,7,i)*(1+(0.3*lin68*((137.82*UPBdata2(j,7,i))^1.5)/100000000000));
		else
			UPBdata2(j,8,i) = UPBdata2(j,7,i)*(1+0.2*lowint68*exp(-0.000001*(UPBdata2(j,7,i)*137.82)));
		end
		%UPBdata2(j,9,i) = (values_all(j+16,8,i)-UPB_pre(i,8))/(1-(values_all(j+16,8,i)-UPB_pre(i,8))*deadtime/1000000000);
		if UPBdata2(j,9,i) > 5000000
			UPBdata2(j,10,i) = UPBdata2(j,9,i)*(1+(0.3*lin68*(UPBdata2(j,9,i)^1.5)/100000000000));
		else
			UPBdata2(j,10,i) = UPBdata2(j,9,i)*(1+0.2*lowint68*exp(-0.000001*UPBdata2(j,9,i)));
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
	if mean(UPBdata2(4:38,10,i)) < 50000 || mean(UPBdata2(4:38,2,i)) > 100000
		mode(i,1) = {'bad'}; 
	elseif countsum(1,i) < 3
		mode(i,1) = {'IC'};
	elseif mean(UPBdata2(4:38,10,i)) > 5000000
		mode(i,1) = {'AN'};
	else
		mode(i,1) = {'MI'};
	end
end

for i = 1:data_count
	for j = 1:57
		if UPBdata2(j,8,i) == 0 || UPBdata2(j,10,i) == 0
			UPBdata2(j,11,i) = 1.3;
		elseif strcmp(mode{i,1}, 'IC') == 1
			UPBdata2(j,11,i) = UPBdata2(j,3,i)/UPBdata2(j,10,i);
		else
			UPBdata2(j,11,i) = UPBdata2(j,3,i)/(UPBdata2(j,8,i)*137.82);
		end
	end
end
		
for i = 1:data_count
	for j = 1:57
		if UPBdata2(j,3,i)/UPBdata2(j,4,i) > 30
			UPBdata2(j,12,i) = 30;
		elseif UPBdata2(j,3,i)/UPBdata2(j,4,i) < 1.5
			UPBdata2(j,12,i) = 1.5;
		else
			UPBdata2(j,12,i) = UPBdata2(j,3,i)/UPBdata2(j,4,i);
		end
	end
end

for  i = 1:data_count
	[p68(i,:)] = polyfit((1:1:35)',UPBdata(4:38,11,i),1);
	%[p82(i,:)] = polyfit((1:1:35)',UPBdata(4:38,14,i),1);
end

for  i = 1:data_count
f68(:,i) = polyval(p68(i,:),(1:1:35)');
%f82(:,i) = polyval(p82(i,:),(1:1:35)');
end


for  i = 1:data_count
	f68r(:,i) = f68(:,i) - UPBdata(4:38,11,i); %calculate residual
	%f82r(:,i) = f82(:,i) - UPBdata(4:38,14,i); %calculate residual
end

for  i = 1:data_count
	fit68_err(i,1) = (std(f68r(:,i))/sqrt(35))*2;
	%fit82_err(i,1) = (std(f82r(:,i))/sqrt(35))*2;
end


UPB_reduced = zeros(data_count,18);
for i = 1:data_count
	UPB_reduced(i,1) = abs(mean(UPBdata2(4:38,2,i)));
	UPB_reduced(i,2) = abs(mean(UPBdata2(4:38,3,i)));
	UPB_reduced(i,3) = abs(mean(UPBdata2(4:38,4,i)));
	UPB_reduced(i,4) = abs(mean(UPBdata2(4:38,5,i)));
	if mean(UPBdata2(4:38,6,i)) < 1000
		UPB_reduced(i,5) = 1;
	else
		UPB_reduced(i,5) = abs(mean(UPBdata2(4:38,6,i)));
	end
	if mean(UPBdata2(4:38,8,i)) < 1000
		UPB_reduced(i,6) = 1;
	else
		UPB_reduced(i,6) = abs(mean(UPBdata2(4:38,8,i)));
	end
	if mean(UPBdata2(4:38,10,i)) < 1000
		UPB_reduced(i,7) = 1;
	else
		UPB_reduced(i,7) = abs(mean(UPBdata2(4:38,10,i)));
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,8) = 1.3;
	elseif use_235 == 1
		UPB_reduced(i,8) = sum(UPBdata2(:,3,i))./(137.82*sum(UPBdata2(:,8,i)));
	else
		UPB_reduced(i,8) = sum(UPBdata2(:,3,i))./sum(UPBdata2(:,10,i));
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
	elseif sum(UPBdata2(:,3,i))/sum(UPBdata2(:,4,i)) < 1.5
		UPB_reduced(i,11) = 1.5;
	elseif sum(UPBdata2(:,3,i))/sum(UPBdata2(:,4,i)) > 30
		UPB_reduced(i,11) = 30;
	else
		UPB_reduced(i,11) = sum(UPBdata2(:,3,i))/sum(UPBdata2(:,4,i));
	end
end

for i = 1:data_count
	if strcmp(mode{i,1}, 'bad') == 1
		UPB_reduced(i,12) = 1;
	elseif 100*std(UPBdata2(4:38,12,i))/UPB_reduced(i,11)/sqrt(35) > 50
		UPB_reduced(i,12) = 50;
	else
		UPB_reduced(i,12) = 100*std(UPBdata2(4:38,12,i))/UPB_reduced(i,11)/sqrt(35);
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
	elseif (100*std(UPBdata2(4:38,13,i))/UPB_reduced(i,13))/sqrt(35) > 100
		UPB_reduced(i,14) = 100;
	else
		UPB_reduced(i,14) = (100*std(UPBdata2(4:38,13,i))/UPB_reduced(i,13))/sqrt(35);
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
	elseif 100*std(UPBdata2(4:38,15,i))/UPB_reduced(i,17)/sqrt(35) > 50
		UPB_reduced(i,18) = 50;
	else
		UPB_reduced(i,18) = 100*std(UPBdata2(4:38,15,i))/UPB_reduced(i,17)/sqrt(35);
	end
end

for i = 1:data_count
	serial{i,1} = i;
end

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

n = n+1;


FC_ALL_OS_mean_out(n,1) = mean(abs(FC_67_OS));
	
SL_ALL_OS_mean_out(n,1) = mean(abs(SL_67_OS));
		
R33_ALL_OS_mean_out(n,1) = mean(abs(R33_67_OS));
		

waitbar((n/waiter), h, 'Please wait...');



qwe(n,1) = {[q,w]};

xlab(n,1) = strcat('[',num2str(q),{','},{' '},num2str(w),']');

	end
end

close(h)


Mean_ALL = mean([FC_ALL_OS_mean_out,R33_ALL_OS_mean_out,SL_ALL_OS_mean_out],2);

[Mean_All_min Mean_All_idx] = min(Mean_ALL);

idx = qwe{Mean_All_idx};

x = 1:numel(qwe);

cla(H2.axes4,'reset');
axes(H2.axes4);
hold on

if get(H2.plotall2,'Value') == 1
	p0 = plot(x,FC_ALL_OS_mean_out,'Color','r','LineWidth', 2);
	p1 = plot(x,SL_ALL_OS_mean_out,'Color','b','LineWidth', 2);
	p2 = plot(x,R33_ALL_OS_mean_out,'Color',[0.1 0.7 0.1],'LineWidth', 2);
	p3 = plot(x,Mean_ALL,'Color','k','LineWidth', 4);
	
end

if get(H2.plotall2,'Value') == 0
	p4 = plot(x,Mean_ALL,'Color','k','LineWidth', 4);
end

scatter(Mean_All_idx,Mean_ALL(Mean_All_idx,1), 150, 'MarkerFaceColor', 'g')
scatter(Mean_All_idx,Mean_ALL(Mean_All_idx,1), 150, 'MarkerEdgeColor', 'k')

if get(H2.plotall2,'Value') == 1
	legend([p0, p1, p2, p3], 'FC','SL','R33','Mean')
end

if get(H2.plotall2,'Value') == 0
	legend([p4],'Mean')
end

xticks(1:1:n)
xticklabels(xlab)

set(H2.slider_lowint_206,'Value',((idx(1,1)+50)/100)); %slider val
set(H2.slider_lin_206,'Value',((idx(1,2)+50)/100)); %slider val

set(H2.lowint_val_206,'String',idx(1,1)); 
set(H2.lin_val_206,'String',idx(1,2));

xlabel('Combination [Low-Int 206Pb, Linear 206Pb]')
ylabel('Percent Offset')

ACF_Corr(hObject, eventdata, H2)


% --- Executes on button press in plotall2.
function plotall2_Callback(hObject, eventdata, handles)
% hObject    handle to plotall2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotall2


function plotall1_Callback(hObject, eventdata, H2)


% --- Executes during object creation, after setting all properties.
function saveandclose_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveandclose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
