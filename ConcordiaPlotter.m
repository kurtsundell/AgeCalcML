%% CONCORDIAPLOTTER MATLAB code for ConcordiaPlotter.fig %%

%% SET DEFAULT COMMAND LINE AND HANDLE STRUCTURE %%
function varargout = ConcordiaPlotter(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@ConcordiaPlotter_OpeningFcn,'gui_OutputFcn',@ConcordiaPlotter_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);

if nargin && ischar(varargin{1})
	gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
	[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
	gui_mainfcn(gui_State, varargin{:});
end

function ConcordiaPlotter_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
guidata(hObject, H);

function varargout = ConcordiaPlotter_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;
set(H.conc1s,'Value', 1)
H.export_comp = 0;
%plot_compare(hObject, eventdata, H)
guidata(hObject,H);

%% CONCORDIA PLOTTER %%
function load_Callback(hObject, eventdata, H)
[filename pathname] = uigetfile({'*'},'File Selector');
data = readtable(char(strcat(pathname, filename)));
data = table2array(data);
set(H.uitable1, 'Data', data);
data = get(H.uitable1, 'Data');
set(H.filepath,'String',[strcat(pathname, filename)])
plot_compare(hObject, eventdata, H)

function plot_compare(hObject, eventdata, H)

if get(H.setax,'Value') == 1
	az = get(H.axes_comp, 'View');
end

	if H.export_comp == 1
		figure;
	end
	if H.export_comp == 0
		cla(H.axes_comp,'reset');
		axes(H.axes_comp);	
	end
	H.export_comp = 0;
	guidata(hObject,H);
	
data = get(H.uitable1, 'Data');

if iscell(data) == 1
	data = cell2num(data);
end

data = data(any(data ~= 0,2),:);

if get(H.input1sp,'Value') == 1
	columnname =   {'7/5', '±1s (%)', '6/8', '±1s (%)', 'Rho'};
	set(H.uitable1, 'ColumnName', columnname);
end

if get(H.input1sa,'Value') == 1
	columnname =   {'7/5', '±1s', '6/8', '±1s', 'Rho'};
	set(H.uitable1, 'ColumnName', columnname);
	data(:,2) = data(:,2)./data(:,1).*100;
	data(:,4) = data(:,4)./data(:,3).*100;	
end

if get(H.input2sp,'Value') == 1
	columnname =   {'7/5', '±2s (%)', '6/8', '±2s (%)', 'Rho'};
	set(H.uitable1, 'ColumnName', columnname);
	data(:,2) = data(:,2)./2;
	data(:,4) = data(:,2)./2;
end

if get(H.input2sa,'Value') == 1
	columnname =   {'7/5', '±2s', '6/8', '±2s', 'Rho'};
	set(H.uitable1, 'ColumnName', columnname);
	data(:,2) = data(:,2)./data(:,1).*100./2;
	data(:,4) = data(:,4)./data(:,3).*100./2;
end


%%%% All calculations assume 1 sigma % input below. Adjusted above if needed.

hold on

		xlo = str2double(get(H.setxmin,'String'));
		xhi = str2double(get(H.setxmax,'String'));
		ylo = str2double(get(H.setymin,'String'));
		yhi = str2double(get(H.setymax,'String'));
		
center=[data(:,1),data(:,3)];

	if get(H.setax,'Value') == 1
		for i = 1:length(data(:,1))
			if center(i,1) > xlo && center(i,1) < xhi && center(i,2) > ylo && center(i,2) < yhi
				data(i,:) = data(i,:);
			else
				data(i,1:5) = 0;
			end
		end
	end


	for i = 1:length(data(:,1))
		for j = 1:length(data(1,:))
			if isnan(data(i,j)) == 1
				data(i,:) = 0;
			end
		end
	end
		 
	
data = data(any(data ~= 0,2),:);
clear center
center=[data(:,1),data(:,3)];

rho = data(:,5);

sigx_abs = data(:,1).*data(:,2).*0.01;
sigy_abs = data(:,3).*data(:,4).*0.01;

sigx_sq = sigx_abs.*sigx_abs;
sigy_sq = sigy_abs.*sigy_abs;
rho_sigx_sigy = sigx_abs.*sigy_abs.*rho;
sigmarule=1.25;
numpoints=50;

	timemin = 0;
	timemax = 4500000000;
	timeinterval = str2num(get(H.concint,'String'))*1000000;
	time = timemin:timeinterval:timemax;
	x = exp(0.00000000098485.*time)-1;
	y = exp(0.000000000155125.*time)-1;
	
	% CONCORDIAS %

		agelabelmin = 0;
		agelabelint = str2num(get(H.concint,'String'))*1000000;
		agelabelmax = 4000000000;

	sigmarule1s=1.5;
	sigmarule2s=2.5;
	scalar = .01;
	scaling = 2^9;

		%set(H.conct,'enable','on')
		%set(H.concmin,'enable','on')
		%set(H.concmint,'enable','on')
		%set(H.concmax,'enable','on')
		%set(H.concmaxt,'enable','on')
		set(H.concint,'enable','on')
		set(H.concintt,'enable','on')

		timemin = 0;
		timemax = 4500000000;
		timeinterval = 5000000;
		time = timemin:timeinterval:timemax;
		xC = exp(0.00000000098485.*time)-1;
		yC = exp(0.000000000155125.*time)-1;

		age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
		age_label_x = exp(0.00000000098485.*age_label_num)-1;
		age_label_y = exp(0.000000000155125.*age_label_num)-1;

		for i=1:length(age_label_num)
			age_label(i,1) = {sprintf('%.0f',age_label_num(1,i)/1000000)};
			age_label2(i,1) = strcat(age_label(i,1),' Ma');
		end

	% 1 sigma 2D concordia
	for i = 1:length(center(:,1))
		covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
		[PD,PV]=eig(covmat);
		PV=diag(PV).^.5;
		theta=linspace(0,2.*pi,numpoints)';
		elpt1s=[cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma1s=length(sigmarule1s);
		elpt1s=repmat(elpt1s,1,numsigma1s).*repmat(sigmarule1s(floor(1:.5:numsigma1s+.5)),numpoints,1);
		elpt1s=elpt1s+repmat(center(i,1:2),numpoints,numsigma1s);
		elpt1s_out(:,:,i)=elpt1s+repmat(center(i,1:2),numpoints,numsigma1s);
		if get(H.conc1s,'Value') == 1 && get(H.conc3D,'Value') == 0


			
				plot(elpt1s(:,1:2:end),elpt1s(:,2:2:end),'b','LineWidth', 1);
		
		end
	end

	% 2 sigma 2D concordia
	for i = 1:length(center(:,1))
		covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
		[PD,PV]=eig(covmat);
		PV=diag(PV).^.5;
		theta=linspace(0,2.*pi,numpoints)';
		elpt2s=[cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma2s=length(sigmarule2s);
		elpt2s=repmat(elpt2s,1,numsigma2s).*repmat(sigmarule2s(floor(1:.5:numsigma2s+.5)),numpoints,1);
		elpt2s=elpt2s+repmat(center(i,1:2),numpoints,numsigma2s);
		elpt2s_out(:,:,i)=elpt2s;
		if get(H.conc2s,'Value') == 1 && get(H.conc3D,'Value') == 0
			
			plot(elpt2s(:,1:2:end),elpt2s(:,2:2:end),'b','LineWidth', 1);
			
		end
	end
	% set x-y limits
	
	if get(H.setax,'Value') == 1

		
		
		
		
	end
	
	if get(H.defaultaxes,'Value') == 1
		if min(min(elpt2s_out(:,1,:)))-max(max(elpt2s_out(:,1,:)))*scalar <= 0 
			xlo = 0;
		else
			xlo = min(min(elpt2s_out(:,1,:)))-max(max(elpt2s_out(:,1,:)))*scalar;
		end
		if min(min(elpt2s_out(:,2,:)))-max(max(elpt2s_out(:,2,:)))*scalar <= 0
			ylo = 0;
		else
			ylo = min(min(elpt2s_out(:,2,:)))-max(max(elpt2s_out(:,2,:)))*scalar; 
		end
		xhi = max(max(elpt2s_out(:,1,:)))+max(max(elpt2s_out(:,1,:)))*scalar;
		yhi = max(max(elpt2s_out(:,2,:)))+max(max(elpt2s_out(:,2,:)))*scalar;

	end
	
	if get(H.conc3D,'Value') == 1
	xdiff = xhi - xlo;
	ydiff = yhi - ylo;
	xr = xdiff/(scaling);
	yr = ydiff/(scaling);
	xF = xlo:xr:xhi;
	yF = ylo:yr:yhi;
	[X,Y] = meshgrid(xF,yF);

	for i = 1:length(center(:,1))	
		covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
		F = mvnpdf([X(:) Y(:)],center(i,1:2),covmat);
		F = reshape(F,length(yF),length(xF));
		zmax = max(max(F));
		F_out(:,:,i) = F./sum(F,'All');
	end
	Fsum = sum(F_out,3);
	Fnorm = Fsum./sum(Fsum,'All');
	Fnormmax = max(max(Fnorm));
	H.Fnormmax = Fnormmax;
	F1s = Fnormmax*0.317;
	F2s = Fnormmax*0.05;
	surf(xF,yF,Fnorm);
	caxis([min(Fnorm(:))-.5*range(Fnorm(:)),max(Fnorm(:))]);
	colormap(jet)
	shading interp

	if get(H.conc3D,'Value') == 1 && get(H.conc3D1s,'Value') == 1
		contour3(xF,yF,Fnorm,[F1s F1s], 'b', 'LineWidth', 4)
	end
	if get(H.conc3D,'Value') == 1 && get(H.conc3D2s,'Value') == 1
		contour3(xF,yF,Fnorm,[F2s F2s], 'b', 'LineWidth', 4)
	end

	if get(H.conc1s,'Value') == 1
		for i = 1:length(center(:,1))
			covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
			[PD,PV]=eig(covmat);
			PV=diag(PV).^.5;
			theta=linspace(0,2.*pi,numpoints)';
			elpt1s=[cos(theta),sin(theta)]*diag(PV)*PD';
			numsigma1s=length(sigmarule1s);
			elpt1s=repmat(elpt1s,1,numsigma1s).*repmat(sigmarule1s(floor(1:.5:numsigma1s+.5)),numpoints,1);
			elpt1s=elpt1s+repmat(center(i,1:2),numpoints,numsigma1s);
			zrep1s = repmat(Fnormmax,[length(elpt1s(:,1)),1]);
			plot3(elpt1s(:,1:2:end),elpt1s(:,2:2:end),zrep1s,'b','LineWidth', 0.5);
		end
	end

	if get(H.conc2s,'Value') == 1
		for i = 1:length(center(:,1))
			covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
			[PD,PV]=eig(covmat);
			PV=diag(PV).^.5;
			theta=linspace(0,2.*pi,numpoints)';
			elpt2s=[cos(theta),sin(theta)]*diag(PV)*PD';
			numsigma2s=length(sigmarule2s);
			elpt2s=repmat(elpt2s,1,numsigma2s).*repmat(sigmarule2s(floor(1:.5:numsigma2s+.5)),numpoints,1);
			elpt2s=elpt2s+repmat(center(i,1:2),numpoints,numsigma2s);
			zrep2s = repmat(Fnormmax,[length(elpt2s(:,1)),1]);
			plot3(elpt2s(:,1:2:end),elpt2s(:,2:2:end),zrep2s,'b','LineWidth', 0.5);
		end
	end

	zrep1 = repmat(Fnormmax,[length(xC(1,:)),1]);
	plot3(xC',yC',zrep1,'k','LineWidth',1.4)
	plot3(xC',yC',zrep1.*0.25,'k','LineWidth',0.5)
	plot3(xC',yC',zrep1.*0.5,'k','LineWidth',0.5)
	plot3(xC',yC',zrep1.*0.75,'k','LineWidth',0.5)
		for i = 1:length(age_label_num)
			if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
				scatter3(age_label_x(1,i), age_label_y(1,i), Fnormmax+Fnormmax*.01, 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
				text(age_label_x(1,i)+0.1, age_label_y(1,i),Fnormmax+Fnormmax*.001, age_label2(i,1), 'FontWeight', 'bold')
				plot3([age_label_x(1,i), age_label_x(1,i)], [age_label_y(1,i), age_label_y(1,i)], [0, Fnormmax], 'LineWidth', 1, 'Color', 'k')
			end
		end
	end
	
	
		if get(H.conc3D,'Value') == 0
			plot(xC,yC,'k','LineWidth',1.4)
			for i = 1:length(age_label_num)
				if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
					scatter3(age_label_x(1,i), age_label_y(1,i), 1, 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
					text(age_label_x(1,i)+0.1, age_label_y(1,i),age_label2(i,1), 'FontWeight', 'bold')
				end
			end
		end
		
		if get(H.conc3D,'Value') == 0
			if get(H.concpoints,'Value') == 1
				for i = 1:length(data(:,1))
					if center(i,1) > str2double(get(H.setxmin,'String')) && center(i,1) < str2double(get(H.setxmax,'String')) ...
							&& center(i,2) > str2double(get(H.setymin,'String')) && center(i,2) < str2double(get(H.setymax,'String'))
						
						if get(H.concpoints,'Value') == 1
							
								scatter3(center(i,1), center(i,2), 1, 50, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b', 'LineWidth', 1.5)
		
						end
					end
				end
			end
		end
		if get(H.conc3D,'Value') == 1
			if get(H.concpoints,'Value') == 1
				for i = 1:length(center(:,1))
					if center(i,1) > str2double(get(H.setxmin,'String')) && center(i,1) < str2double(get(H.setxmax,'String')) ...
							&& center(i,2) > str2double(get(H.setymin,'String')) && center(i,2) < str2double(get(H.setymax,'String'))
						
						
						
								scatter3(center(i,1), center(i,2), Fnormmax+Fnormmax*.01, 50, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b', 'LineWidth', 1.5)
							
							
					end
				end
			end
		end
	
	
	%if get(H.Unk_conc,'Value') == 1 && get(H.comp_legon,'Value') == 1
	%	legend([p1,p2],'Accepted Analyses','Rejected Analyses','Location','northwest');
	%end
	


	xlabel('207Pb/235U');
	ylabel('206Pb/238U');
	if get(H.defaultaxes,'Value') == 1
		axis([xlo xhi ylo yhi])
		set(H.setxmin,'String',xlo)
		set(H.setxmax,'String',xhi)
		set(H.setymin,'String',ylo)
		set(H.setymax,'String',yhi)
	end
	if get(H.setax,'Value') == 1
		axis([str2double(get(H.setxmin,'String')) str2double(get(H.setxmax,'String')) str2double(get(H.setymin,'String')) str2double(get(H.setymax,'String'))])
	end
	
if get(H.setax,'Value') == 1
	view(az);
end

guidata(hObject,H);

function uitable1_CellEditCallback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)

function setxmin_Callback(hObject, eventdata, H)
set(H.setax,'Value',1)
set(H.defaultaxes,'Value',0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function setxmax_Callback(hObject, eventdata, H)
set(H.setax,'Value',1)
set(H.defaultaxes,'Value',0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function setymin_Callback(hObject, eventdata, H)
set(H.setax,'Value',1)
set(H.defaultaxes,'Value',0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function setymax_Callback(hObject, eventdata, H)
set(H.setax,'Value',1)
set(H.defaultaxes,'Value',0)
H.point = 0;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function concmin_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)

function concmax_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)

function concint_Callback(hObject, eventdata, H)
plot_compare(hObject, eventdata, H)

function setax_Callback(hObject, eventdata, H)
set(H.setax,'Value',1)
set(H.defaultaxes,'Value',0)
limx = get(H.axes_comp,'XLim');
limy = get(H.axes_comp,'YLim');
set(H.setxmin,'String',limx(1,1))
set(H.setxmax,'String',limx(1,2))
set(H.setymin,'String',limy(1,1))
set(H.setymax,'String',limy(1,2))
plot_compare(hObject, eventdata, H)

function defaultaxes_Callback(hObject, eventdata, H)
set(H.defaultaxes,'Value',1)
set(H.setax,'Value',0)

plot_compare(hObject, eventdata, H)

function conc1s_Callback(hObject, eventdata, H)
%set(H.conc1s,'Value',1)
%set(H.conc2s,'Value',0)

plot_compare(hObject, eventdata, H)

function conc2s_Callback(hObject, eventdata, H)
%set(H.conc1s,'Value',0)
%set(H.conc2s,'Value',1)

plot_compare(hObject, eventdata, H)

function concpoints_Callback(hObject, eventdata, H)

plot_compare(hObject, eventdata, H)

function conc3D_Callback(hObject, eventdata, H)

if get(H.conc3D,'Value') == 0 
	set(H.conc3D1s,'Value', 0)
	set(H.conc3D2s,'Value', 0)
end

plot_compare(hObject, eventdata, H)

function conc3D1s_Callback(hObject, eventdata, H)
if get(H.conc3D,'Value') == 0
	set(H.conc3D,'Value', 1)
end

plot_compare(hObject, eventdata, H)

function conc3D2s_Callback(hObject, eventdata, H)
if get(H.conc3D,'Value') == 0
	set(H.conc3D,'Value', 1)
end

plot_compare(hObject, eventdata, H)

function exportplot_Callback(hObject, eventdata, H)
H.export_comp = 1;
guidata(hObject,H);
plot_compare(hObject, eventdata, H)

function savesession_Callback(hObject, eventdata, H)
[file,path] = uiputfile('*.mat','Save file');
save([path file],'H')

function loadsession_Callback(hObject, eventdata, H)
[filename pathname] = uigetfile({'*'},'File Selector','MultiSelect','on');
fullpathname = strcat(pathname, filename);
close(ConcordiaPlotter_0_1)
load(fullpathname,'H')

function copytable_Callback(hObject, eventdata, H)
data = get(H.uitable1, 'Data');
copy(data);

function pastetable_Callback(hObject, eventdata, H)
data = paste;
if iscell(data(1,1))
	data= cell2num(data);
end

	for i = 1:length(data(:,1))
		for j = 1:length(data(1,:))
			if isnan(data(i,j)) == 1
				data(i,:) = 0;
			end
		end
	end
		 
	
data = data(any(data ~= 0,2),:);






set(H.uitable1, 'Data', data);

plot_compare(hObject, eventdata, H)

function saveplot_Callback(hObject, eventdata, H)

FIG = figure('visible', 'off');

%%%%%%% plot code

if get(H.setax,'Value') == 1
	az = get(H.axes_comp, 'View');
end
%{
	if H.export_comp == 1
		figure;
	end
	if H.export_comp == 0
		cla(H.axes_comp,'reset');
		axes(H.axes_comp);	
	end
	H.export_comp = 0;
	guidata(hObject,H);
%}	
data = get(H.uitable1, 'Data');
%data = cell2num(data);
data = data(any(data ~= 0,2),:);

hold on

		xlo = str2double(get(H.setxmin,'String'));
		xhi = str2double(get(H.setxmax,'String'));
		ylo = str2double(get(H.setymin,'String'));
		yhi = str2double(get(H.setymax,'String'));
		
center=[data(:,1),data(:,3)];

	if get(H.setax,'Value') == 1
		for i = 1:length(data(:,1))
			if center(i,1) > xlo && center(i,1) < xhi && center(i,2) > ylo && center(i,2) < yhi
				data(i,:) = data(i,:);
			else
				data(i,1:5) = 0;
			end
		end
	end

data = data(any(data ~= 0,2),:);
clear center
center=[data(:,1),data(:,3)];

rho = data(:,5);

sigx_abs = data(:,1).*data(:,2).*0.01;
sigy_abs = data(:,3).*data(:,4).*0.01;

sigx_sq = sigx_abs.*sigx_abs;
sigy_sq = sigy_abs.*sigy_abs;
rho_sigx_sigy = sigx_abs.*sigy_abs.*rho;
sigmarule=1.25;
numpoints=50;

	timemin = 0;
	timemax = 4500000000;
	timeinterval = str2num(get(H.concint,'String'))*1000000;
	time = timemin:timeinterval:timemax;
	x = exp(0.00000000098485.*time)-1;
	y = exp(0.000000000155125.*time)-1;
	
	% CONCORDIAS %

		agelabelmin = 0;
		agelabelint = str2num(get(H.concint,'String'))*1000000;
		agelabelmax = 4000000000;

	sigmarule1s=1.5;
	sigmarule2s=2.5;
	scalar = .01;
	scaling = 2^9;

		set(H.conct,'enable','on')
		set(H.concmin,'enable','on')
		set(H.concmint,'enable','on')
		set(H.concmax,'enable','on')
		set(H.concmaxt,'enable','on')
		set(H.concint,'enable','on')
		set(H.concintt,'enable','on')

		timemin = 0;
		timemax = 4500000000;
		timeinterval = 5000000;
		time = timemin:timeinterval:timemax;
		xC = exp(0.00000000098485.*time)-1;
		yC = exp(0.000000000155125.*time)-1;

		age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
		age_label_x = exp(0.00000000098485.*age_label_num)-1;
		age_label_y = exp(0.000000000155125.*age_label_num)-1;

		for i=1:length(age_label_num)
			age_label(i,1) = {sprintf('%.0f',age_label_num(1,i)/1000000)};
			age_label2(i,1) = strcat(age_label(i,1),' Ma');
		end

	% 1 sigma 2D concordia
	for i = 1:length(center(:,1))
		covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
		[PD,PV]=eig(covmat);
		PV=diag(PV).^.5;
		theta=linspace(0,2.*pi,numpoints)';
		elpt1s=[cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma1s=length(sigmarule1s);
		elpt1s=repmat(elpt1s,1,numsigma1s).*repmat(sigmarule1s(floor(1:.5:numsigma1s+.5)),numpoints,1);
		elpt1s=elpt1s+repmat(center(i,1:2),numpoints,numsigma1s);
		elpt1s_out(:,:,i)=elpt1s+repmat(center(i,1:2),numpoints,numsigma1s);
		if get(H.conc1s,'Value') == 1 && get(H.conc3D,'Value') == 0


			
				plot(elpt1s(:,1:2:end),elpt1s(:,2:2:end),'b','LineWidth', 1);
		
		end
	end

	% 2 sigma 2D concordia
	for i = 1:length(center(:,1))
		covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
		[PD,PV]=eig(covmat);
		PV=diag(PV).^.5;
		theta=linspace(0,2.*pi,numpoints)';
		elpt2s=[cos(theta),sin(theta)]*diag(PV)*PD';
		numsigma2s=length(sigmarule2s);
		elpt2s=repmat(elpt2s,1,numsigma2s).*repmat(sigmarule2s(floor(1:.5:numsigma2s+.5)),numpoints,1);
		elpt2s=elpt2s+repmat(center(i,1:2),numpoints,numsigma2s);
		elpt2s_out(:,:,i)=elpt2s;
		if get(H.conc2s,'Value') == 1 && get(H.conc3D,'Value') == 0
			
			plot(elpt2s(:,1:2:end),elpt2s(:,2:2:end),'b','LineWidth', 1);
			
		end
	end
	% set x-y limits
	
	if get(H.setax,'Value') == 1

		
		
		
		
	end
	
	if get(H.defaultaxes,'Value') == 1
		if min(min(elpt2s_out(:,1,:)))-max(max(elpt2s_out(:,1,:)))*scalar <= 0 
			xlo = 0;
		else
			xlo = min(min(elpt2s_out(:,1,:)))-max(max(elpt2s_out(:,1,:)))*scalar;
		end
		if min(min(elpt2s_out(:,2,:)))-max(max(elpt2s_out(:,2,:)))*scalar <= 0
			ylo = 0;
		else
			ylo = min(min(elpt2s_out(:,2,:)))-max(max(elpt2s_out(:,2,:)))*scalar; 
		end
		xhi = max(max(elpt2s_out(:,1,:)))+max(max(elpt2s_out(:,1,:)))*scalar;
		yhi = max(max(elpt2s_out(:,2,:)))+max(max(elpt2s_out(:,2,:)))*scalar;

	end
	
	if get(H.conc3D,'Value') == 1
	xdiff = xhi - xlo;
	ydiff = yhi - ylo;
	xr = xdiff/(scaling);
	yr = ydiff/(scaling);
	xF = xlo:xr:xhi;
	yF = ylo:yr:yhi;
	[X,Y] = meshgrid(xF,yF);

	for i = 1:length(center(:,1))	
		covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
		F = mvnpdf([X(:) Y(:)],center(i,1:2),covmat);
		F = reshape(F,length(yF),length(xF));
		zmax = max(max(F));
		F_out(:,:,i) = F./sum(F,'All');
	end
	Fsum = sum(F_out,3);
	Fnorm = Fsum./sum(Fsum,'All');
	Fnormmax = max(max(Fnorm));
	H.Fnormmax = Fnormmax;
	F1s = Fnormmax*0.317;
	F2s = Fnormmax*0.05;
	surf(xF,yF,Fnorm);
	caxis([min(Fnorm(:))-.5*range(Fnorm(:)),max(Fnorm(:))]);
	colormap(jet)
	shading interp

	if get(H.conc3D,'Value') == 1 && get(H.conc3D1s,'Value') == 1
		contour3(xF,yF,Fnorm,[F1s F1s], 'b', 'LineWidth', 4)
	end
	if get(H.conc3D,'Value') == 1 && get(H.conc3D2s,'Value') == 1
		contour3(xF,yF,Fnorm,[F2s F2s], 'b', 'LineWidth', 4)
	end

	if get(H.conc1s,'Value') == 1
		for i = 1:length(center(:,1))
			covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
			[PD,PV]=eig(covmat);
			PV=diag(PV).^.5;
			theta=linspace(0,2.*pi,numpoints)';
			elpt1s=[cos(theta),sin(theta)]*diag(PV)*PD';
			numsigma1s=length(sigmarule1s);
			elpt1s=repmat(elpt1s,1,numsigma1s).*repmat(sigmarule1s(floor(1:.5:numsigma1s+.5)),numpoints,1);
			elpt1s=elpt1s+repmat(center(i,1:2),numpoints,numsigma1s);
			zrep1s = repmat(Fnormmax,[length(elpt1s(:,1)),1]);
			plot3(elpt1s(:,1:2:end),elpt1s(:,2:2:end),zrep1s,'b','LineWidth', 0.5);
		end
	end

	if get(H.conc2s,'Value') == 1
		for i = 1:length(center(:,1))
			covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
			[PD,PV]=eig(covmat);
			PV=diag(PV).^.5;
			theta=linspace(0,2.*pi,numpoints)';
			elpt2s=[cos(theta),sin(theta)]*diag(PV)*PD';
			numsigma2s=length(sigmarule2s);
			elpt2s=repmat(elpt2s,1,numsigma2s).*repmat(sigmarule2s(floor(1:.5:numsigma2s+.5)),numpoints,1);
			elpt2s=elpt2s+repmat(center(i,1:2),numpoints,numsigma2s);
			zrep2s = repmat(Fnormmax,[length(elpt2s(:,1)),1]);
			plot3(elpt2s(:,1:2:end),elpt2s(:,2:2:end),zrep2s,'b','LineWidth', 0.5);
		end
	end

	zrep1 = repmat(Fnormmax,[length(xC(1,:)),1]);
	plot3(xC',yC',zrep1,'k','LineWidth',1.4)
	plot3(xC',yC',zrep1.*0.25,'k','LineWidth',0.5)
	plot3(xC',yC',zrep1.*0.5,'k','LineWidth',0.5)
	plot3(xC',yC',zrep1.*0.75,'k','LineWidth',0.5)
		for i = 1:length(age_label_num)
			if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
				scatter3(age_label_x(1,i), age_label_y(1,i), Fnormmax+Fnormmax*.01, 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
				text(age_label_x(1,i)+0.1, age_label_y(1,i),Fnormmax+Fnormmax*.001, age_label2(i,1), 'FontWeight', 'bold')
				plot3([age_label_x(1,i), age_label_x(1,i)], [age_label_y(1,i), age_label_y(1,i)], [0, Fnormmax], 'LineWidth', 1, 'Color', 'k')
			end
		end
	end
	
	
		if get(H.conc3D,'Value') == 0
			plot(xC,yC,'k','LineWidth',1.4)
			for i = 1:length(age_label_num)
				if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
					scatter3(age_label_x(1,i), age_label_y(1,i), 1, 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
					text(age_label_x(1,i)+0.1, age_label_y(1,i),age_label2(i,1), 'FontWeight', 'bold')
				end
			end
		end
		
		if get(H.conc3D,'Value') == 0
			if get(H.concpoints,'Value') == 1
				for i = 1:length(data(:,1))
					if center(i,1) > str2double(get(H.setxmin,'String')) && center(i,1) < str2double(get(H.setxmax,'String')) ...
							&& center(i,2) > str2double(get(H.setymin,'String')) && center(i,2) < str2double(get(H.setymax,'String'))
						
						if get(H.concpoints,'Value') == 1
							
								scatter3(center(i,1), center(i,2), 1, 50, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b', 'LineWidth', 1.5)
		
						end
					end
				end
			end
		end
		if get(H.conc3D,'Value') == 1
			if get(H.concpoints,'Value') == 1
				for i = 1:length(center(:,1))
					if center(i,1) > str2double(get(H.setxmin,'String')) && center(i,1) < str2double(get(H.setxmax,'String')) ...
							&& center(i,2) > str2double(get(H.setymin,'String')) && center(i,2) < str2double(get(H.setymax,'String'))
						
						
						
								scatter3(center(i,1), center(i,2), Fnormmax+Fnormmax*.01, 50, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b', 'LineWidth', 1.5)
							
							
					end
				end
			end
		end
	
	
	%if get(H.Unk_conc,'Value') == 1 && get(H.comp_legon,'Value') == 1
	%	legend([p1,p2],'Accepted Analyses','Rejected Analyses','Location','northwest');
	%end
	


	xlabel('207Pb/235U');
	ylabel('206Pb/238U');
	if get(H.defaultaxes,'Value') == 1
		axis([xlo xhi ylo yhi])
		set(H.setxmin,'String',xlo)
		set(H.setxmax,'String',xhi)
		set(H.setymin,'String',ylo)
		set(H.setymax,'String',yhi)
	end
	if get(H.setax,'Value') == 1
		axis([str2double(get(H.setxmin,'String')) str2double(get(H.setxmax,'String')) str2double(get(H.setymin,'String')) str2double(get(H.setymax,'String'))])
	end
	
if get(H.setax,'Value') == 1
	view(az);
end




%%%%%%% save code

[file,path] = uiputfile('*.eps','Save file');

if get(H.conc3D,'Value') == 0 && get(H.conc3D1s,'Value') == 1 || get(H.conc3D,'Value') == 0 && get(H.conc3D2s,'Value') == 1
	print(FIG,'-depsc','-painters',[path file]);
	epsclean([path file]); 
elseif get(H.conc3D,'Value') == 1 
	print(FIG,'-depsc',[path file]);
else
	print(FIG,'-depsc','-painters',[path file]);
end

function input1sp_Callback(hObject, eventdata, H)
set(H.input1sp,'Value',1)
set(H.input1sa,'Value',0)
set(H.input2sp,'Value',0)
set(H.input2sa,'Value',0)
plot_compare(hObject, eventdata, H)

function input1sa_Callback(hObject, eventdata, H)
set(H.input1sp,'Value',0)
set(H.input1sa,'Value',1)
set(H.input2sp,'Value',0)
set(H.input2sa,'Value',0)
plot_compare(hObject, eventdata, H)

function input2sp_Callback(hObject, eventdata, H)
set(H.input1sp,'Value',0)
set(H.input1sa,'Value',0)
set(H.input2sp,'Value',1)
set(H.input2sa,'Value',0)
plot_compare(hObject, eventdata, H)

function input2sa_Callback(hObject, eventdata, H)
set(H.input1sp,'Value',0)
set(H.input1sa,'Value',0)
set(H.input2sp,'Value',0)
set(H.input2sa,'Value',1)
plot_compare(hObject, eventdata, H)
