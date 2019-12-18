function varargout = WeightedMeanPlotter_1_0(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, 'gui_Singleton',  gui_Singleton, 'gui_OpeningFcn', @WeightedMeanPlotter_1_0_OpeningFcn, 'gui_OutputFcn',  @WeightedMeanPlotter_1_0_OutputFcn, ...
	'gui_LayoutFcn',  [], 'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function WeightedMeanPlotter_1_0_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
guidata(hObject, H);


function varargout = WeightedMeanPlotter_1_0_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;
%plot_Callback(hObject, eventdata, H)

function load_Callback(hObject, eventdata, H)
[filename pathname] = uigetfile({'*'},'File Selector');
data = readtable(char(strcat(pathname, filename)));
data = table2array(data);
set(H.uitable1, 'Data', data);
data = get(H.uitable1, 'Data');
plot_Callback(hObject, eventdata, H)



function plot_Callback(hObject, eventdata, H)

data = get(H.uitable1, 'Data');

if iscell(data) == 1
	data = cell2num(data);
end



data = data(any(data ~= 0,2),:);

if get(H.rank,'Value') == 1
	data = sortrows(data,1);
end

if get(H.inputperc,'Value') == 1
	data(:,2) = data(:,2)./100.*data(:,1); % convert percent uncertainty to absolute
end

if get(H.input2s,'Value') == 1
	data(:,2) = data(:,2)./2;
end



len = length(data(:,1));

x = 1:1:len;

xmin = 0; % make nice plots
xmax = len+1; % make nice plots


if get(H.sety,'Value') == 0
	ymin = min(data(:,1)-data(:,2)) - min(data(:,1)-data(:,2))*.05; % make nice plots
	ymax = max(data(:,1)+data(:,2)) +  max(data(:,1)+data(:,2)).*.05; % make nice plots
	
	set(H.yminp,'String',ymin)
	set(H.ymaxp,'String',ymax)
end

if get(H.sety,'Value') == 1
	ymin = str2num(get(H.yminp,'String'));
	ymax = str2num(get(H.ymaxp,'String'));
end




t = sum(data(:,1)./(data(:,2).*data(:,2))) / sum(1./(data(:,2).*data(:,2))); % Weighted Mean

%rad_on=get(H.inputs,'selectedobject');
%switch rad_on

%	case H.input1s
		data2 = data;
		data2(:,2) = data2(:,2).*2; % double the uncertainty to get the MSWD at 1 sigma.... THIS DOESN'T MAKE SENSE TO ME. SEEMS BACKWARDS!
		s = 1/sqrt(sum(1./(data2(:,2).*data2(:,2)))); % SE
		MSWD = 1/(length(data2(:,1))-1).*sum(((data2(:,1)- (sum(data2(:,1)./(data2(:,2).^2))/sum(1./(data2(:,2).^2))) ).^2)./((data2(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
	
%	case H.input2s 
%		s = 1/sqrt(sum(1./(data(:,2).*data(:,2)))) % SE
%		MSWD = 1/(length(data(:,1))-1).*sum(((data(:,1)- (sum(data(:,1)./(data(:,2).^2))/sum(1./(data(:,2).^2))) ).^2)./((data(:,2)./2).^2)) % MSWD at 2 sigma matches Isoplot

%end

students_t = [12.71	4.303	3.182	2.776	2.571	2.447	2.365	2.306	2.262	2.228	2.201	2.179	2.16	2.145	2.131	2.12	2.11	2.101	2.093	2.086	2.08 ...
	2.074	2.069	2.064	2.06	2.056	2.052	2.048	2.045];

% 95% confidence interval using 2-sided Student's t
if length(data(:,1))-1 < 30
	conf95 = students_t(1,(length(data(:,1))-1)) * s/2 *  sqrt(MSWD); 
elseif length(data(:,1))-1 >= 30 && length(data(:,1))-1 < 40
	conf95 = 2.042 * s/2 *  sqrt(MSWD); 
elseif length(data(:,1))-1 >= 40 && length(data(:,1))-1 < 50
	conf95 = 2.021 * s/2 *  sqrt(MSWD);
elseif length(data(:,1))-1 >= 50 && length(data(:,1))-1 < 60
	conf95 = 2.009 * s/2 *  sqrt(MSWD);
elseif length(data(:,1))-1 >= 60 && length(data(:,1))-1 < 80
	conf95 = 2.000 * s/2 *  sqrt(MSWD);
elseif length(data(:,1))-1 >= 80 && length(data(:,1))-1 < 100
	conf95 = 1.99 * s/2 *  sqrt(MSWD);
elseif length(data(:,1))-1 >= 100 && length(data(:,1))-1 < 120
	conf95 = 1.984 * s/2 *  sqrt(MSWD);
elseif length(data(:,1))-1 >= 120
	conf95 = 1.96 * s/2 *  sqrt(MSWD);
end

y = conf95/sqrt(MSWD); %y at 2 sigma


z = y*sqrt(MSWD);

dispersion_1sig= std(data(:,1))*1.96/2;
dispersion_2sig= std(data(:,1))*1.96;

dispersion_perc_1sig = dispersion_1sig/mean(data(:,1))*100;
dispersion_perc_2sig = dispersion_2sig/mean(data(:,1))*100;

cla(H.axes1, 'reset');
axes(H.axes1);
hold on % hold the line

if get(H.input1s, 'Value') == 1 && get(H.plot1s, 'Value') == 1 
	plot([x; x], [(data(:,1)+data(:,2))'; (data(:,1)-data(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5) % Error bars, much nicer than the errorbar function
	plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
	scatter(x, data(:,1), 75, 'b', 'filled','d')
	
elseif get(H.input1s, 'Value') == 1 && get(H.plot2s, 'Value') == 1 
	data2 = data;
	data2(:,2) = data2(:,2).*2; 
	plot([x; x], [(data2(:,1)+data2(:,2))'; (data2(:,1)-data2(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5) % Error bars, much nicer than the errorbar function
	plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
	scatter(x, data(:,1), 75, 'b', 'filled','d')
		
elseif get(H.input2s, 'Value') == 1 && get(H.plot1s, 'Value') == 1 
	plot([x; x], [(data(:,1)+data(:,2))'; (data(:,1)-data(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5) % Error bars, much nicer than the errorbar function
	plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
	scatter(x, data(:,1), 75, 'b', 'filled','d')		
	
elseif get(H.input2s, 'Value') == 1 && get(H.plot2s, 'Value') == 1 
	plot([x; x], [(data(:,1)+data(:,2))'; (data(:,1)-data(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5) % Error bars, much nicer than the errorbar function
	plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
	scatter(x, data(:,1), 75, 'b', 'filled','d')	
end

plot([xmin; xmax], [t+s; t+s], '-r', 'Color', 'k', 'LineWidth',1)
plot([xmin; xmax], [t-s; t-s], '-r', 'Color', 'k', 'LineWidth',1)


%fill([(1:1:len)';flipud((1:1:len)')], [wm+unc; flipud(ffse68_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);

axis([xmin xmax ymin ymax])

hold off

%delete(findall(gcf,'type','annotation'))

%dim = [.8 .65 .3 .3];
%str = {t,s, MSWD}
%annotation('textbox',dim,'String',str,'FitBoxToText','on');

set(H.wm,'String',round(t,str2num(get(H.sigfigs,'String'))))
set(H.unc,'String',round(s,str2num(get(H.sigfigs,'String'))))
set(H.mswd,'String',round(MSWD,str2num(get(H.sigfigs,'String'))))

axis([xmin xmax ymin ymax])







function rank_Callback(hObject, eventdata, H)
plot_Callback(hObject, eventdata, H)

function copy_Callback(hObject, eventdata, H)
data = get(H.uitable1, 'Data');
copy(data);

function pushbutton4_Callback(hObject, eventdata, H)
data = paste;
set(H.uitable1, 'Data', data);
plot_Callback(hObject, eventdata, H)

function cleartable_Callback(hObject, eventdata, H)
set(H.uitable1, 'Data', []);
cla(H.axes1, 'reset');

function rejectOK_Callback(hObject, eventdata, H)

function inputs_SelectionChangedFcn(hObject, eventdata, H)
plot_Callback(hObject, eventdata, H)

function plots_SelectionChangedFcn(hObject, eventdata, H)
plot_Callback(hObject, eventdata, H)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9



function sigfigs_Callback(hObject, eventdata, H)
plot_Callback(hObject, eventdata, H)


% --- Executes on button press in exp.
function exp_Callback(hObject, eventdata, H)

data = get(H.uitable1, 'Data');


%data = cell2num(data);


data = data(any(data ~= 0,2),:);

if get(H.rank,'Value') == 1
	data = sortrows(data,1);
end

if get(H.inputperc,'Value') == 1
	data(:,2) = data(:,2)./100.*data(:,1); % convert percent uncertainty to absolute
end

if get(H.input2s,'Value') == 1
	data(:,2) = data(:,2)./2;
end



len = length(data(:,1));

x = 1:1:len;

xmin = 0; % make nice plots
xmax = len+1; % make nice plots


if get(H.sety,'Value') == 0
	ymin = min(data(:,1)-data(:,2)) - min(data(:,1)-data(:,2))*.05; % make nice plots
	ymax = max(data(:,1)+data(:,2)) +  max(data(:,1)+data(:,2)).*.05; % make nice plots
	
	set(H.yminp,'String',ymin)
	set(H.ymaxp,'String',ymax)
end

if get(H.sety,'Value') == 1
	ymin = str2num(get(H.yminp,'String'));
	ymax = str2num(get(H.ymaxp,'String'));
end




t = sum(data(:,1)./(data(:,2).*data(:,2))) / sum(1./(data(:,2).*data(:,2))); % Weighted Mean

%rad_on=get(H.inputs,'selectedobject');
%switch rad_on

%	case H.input1s
		data2 = data;
		data2(:,2) = data2(:,2).*2; % double the uncertainty to get the MSWD at 1 sigma.... THIS DOESN'T MAKE SENSE TO ME. SEEMS BACKWARDS!
		s = 1/sqrt(sum(1./(data2(:,2).*data2(:,2)))); % SE
		MSWD = 1/(length(data2(:,1))-1).*sum(((data2(:,1)- (sum(data2(:,1)./(data2(:,2).^2))/sum(1./(data2(:,2).^2))) ).^2)./((data2(:,2)./2).^2)); %MSWD at 1 sigma matches Isoplot
	
%	case H.input2s 
%		s = 1/sqrt(sum(1./(data(:,2).*data(:,2)))) % SE
%		MSWD = 1/(length(data(:,1))-1).*sum(((data(:,1)- (sum(data(:,1)./(data(:,2).^2))/sum(1./(data(:,2).^2))) ).^2)./((data(:,2)./2).^2)) % MSWD at 2 sigma matches Isoplot

%end

students_t = [12.71	4.303	3.182	2.776	2.571	2.447	2.365	2.306	2.262	2.228	2.201	2.179	2.16	2.145	2.131	2.12	2.11	2.101	2.093	2.086	2.08 ...
	2.074	2.069	2.064	2.06	2.056	2.052	2.048	2.045];

% 95% confidence interval using 2-sided Student's t
if length(data(:,1))-1 < 30
	conf95 = students_t(1,(length(data(:,1))-1)) * s/2 *  sqrt(MSWD); 
elseif length(data(:,1))-1 >= 30 && length(data(:,1))-1 < 40
	conf95 = 2.042 * s/2 *  sqrt(MSWD); 
elseif length(data(:,1))-1 >= 40 && length(data(:,1))-1 < 50
	conf95 = 2.021 * s/2 *  sqrt(MSWD);
elseif length(data(:,1))-1 >= 50 && length(data(:,1))-1 < 60
	conf95 = 2.009 * s/2 *  sqrt(MSWD);
elseif length(data(:,1))-1 >= 60 && length(data(:,1))-1 < 80
	conf95 = 2.000 * s/2 *  sqrt(MSWD);
elseif length(data(:,1))-1 >= 80 && length(data(:,1))-1 < 100
	conf95 = 1.99 * s/2 *  sqrt(MSWD);
elseif length(data(:,1))-1 >= 100 && length(data(:,1))-1 < 120
	conf95 = 1.984 * s/2 *  sqrt(MSWD);
elseif length(data(:,1))-1 >= 120
	conf95 = 1.96 * s/2 *  sqrt(MSWD);
end

y = conf95/sqrt(MSWD); %y at 2 sigma


z = y*sqrt(MSWD);

dispersion_1sig= std(data(:,1))*1.96/2;
dispersion_2sig= std(data(:,1))*1.96;

dispersion_perc_1sig = dispersion_1sig/mean(data(:,1))*100;
dispersion_perc_2sig = dispersion_2sig/mean(data(:,1))*100;

figure
hold on % hold the line

if get(H.input1s, 'Value') == 1 && get(H.plot1s, 'Value') == 1 
	plot([x; x], [(data(:,1)+data(:,2))'; (data(:,1)-data(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5) % Error bars, much nicer than the errorbar function
	plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
	scatter(x, data(:,1), 75, 'b', 'filled','d')
	
elseif get(H.input1s, 'Value') == 1 && get(H.plot2s, 'Value') == 1 
	data2 = data;
	data2(:,2) = data2(:,2).*2; 
	plot([x; x], [(data2(:,1)+data2(:,2))'; (data2(:,1)-data2(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5) % Error bars, much nicer than the errorbar function
	plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
	scatter(x, data(:,1), 75, 'b', 'filled','d')
		
elseif get(H.input2s, 'Value') == 1 && get(H.plot1s, 'Value') == 1 
	plot([x; x], [(data(:,1)+data(:,2))'; (data(:,1)-data(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5) % Error bars, much nicer than the errorbar function
	plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
	scatter(x, data(:,1), 75, 'b', 'filled','d')		
	
elseif get(H.input2s, 'Value') == 1 && get(H.plot2s, 'Value') == 1 
	plot([x; x], [(data(:,1)+data(:,2))'; (data(:,1)-data(:,2))'], '-r', 'Color', [.4 .6 1], 'LineWidth',5) % Error bars, much nicer than the errorbar function
	plot([xmin; xmax], [t; t], '-r', 'Color', [.4 .6 1], 'LineWidth',5)
	scatter(x, data(:,1), 75, 'b', 'filled','d')	
end

plot([xmin; xmax], [t+s; t+s], '-r', 'Color', 'k', 'LineWidth',1)
plot([xmin; xmax], [t-s; t-s], '-r', 'Color', 'k', 'LineWidth',1)


%fill([(1:1:len)';flipud((1:1:len)')], [wm+unc; flipud(ffse68_lo)], 'b','FaceAlpha',.3,'EdgeAlpha',.5);

axis([xmin xmax ymin ymax])

hold off

%delete(findall(gcf,'type','annotation'))

%dim = [.8 .65 .3 .3];
%str = {t,s, MSWD}
%annotation('textbox',dim,'String',str,'FitBoxToText','on');

set(H.wm,'String',round(t,str2num(get(H.sigfigs,'String'))))
set(H.unc,'String',round(s,str2num(get(H.sigfigs,'String'))))
set(H.mswd,'String',round(MSWD,str2num(get(H.sigfigs,'String'))))

axis([xmin xmax ymin ymax])



function yminp_Callback(hObject, eventdata, H)
% hObject    handle to yminp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yminp as text
%        str2double(get(hObject,'String')) returns contents of yminp as a double
plot_Callback(hObject, eventdata, H)

% --- Executes during object creation, after setting all properties.
function yminp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yminp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ymaxp_Callback(hObject, eventdata, H)
% hObject    handle to ymaxp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymaxp as text
%        str2double(get(hObject,'String')) returns contents of ymaxp as a double
plot_Callback(hObject, eventdata, H)

% --- Executes during object creation, after setting all properties.
function ymaxp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymaxp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sety.
function sety_Callback(hObject, eventdata, H)
plot_Callback(hObject, eventdata, H)


% --- Executes on button press in inputabs.
function inputabs_Callback(hObject, eventdata, H)


% --- Executes when selected object is changed in uibuttongroup2.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, H)
% hObject    handle to the selected object in uibuttongroup2 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plot_Callback(hObject, eventdata, H)


% --- Executes during object creation, after setting all properties.
function uibuttongroup2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
