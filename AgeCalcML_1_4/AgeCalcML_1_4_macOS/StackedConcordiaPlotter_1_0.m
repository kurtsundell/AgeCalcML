%% STACKEDCONCORDIAPLOTTER_1_0 MATLAB code for StackedConcordiaPlotter_1_0.fig %%

%% SET DEFAULT COMMAND LINE AND HANDLE STRUCTURE %%
function varargout = StackedConcordiaPlotter_1_0(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@StackedConcordiaPlotter_1_0_OpeningFcn,'gui_OutputFcn',@StackedConcordiaPlotter_1_0_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
gui_mainfcn(gui_State, varargin{:});
end
function StackedConcordiaPlotter_1_0_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
guidata(hObject, H);
function varargout = StackedConcordiaPlotter_1_0_OutputFcn(hObject, eventdata, H) 
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

spacing = str2num(get(H.spacing,'String'));

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
	
data_tmp = get(H.uitable1, 'Data');

if iscell(data_tmp) == 0
	data_tmp = num2cell(data_tmp);
end

N = length(data_tmp(1,:))/5;

for k = 1:N
	
	data = data_tmp(:,5*(k-1)+1:5*(k-1)+5);	
	data(all(cellfun('isempty',data),2),:) = [];
	data = cell2num(data);
	
	data(any(isnan(data), 2), :) = [];

	
	if k > 1
		data(:,1) = data(:,1) + (k-1)*spacing;
	end
	
	
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

data = data(any(data ~= 0,2),:);
clear center
center=[data(:,1),data(:,3)];



rho = data(:,5);


if k > 1
	data(:,1) = data(:,1) - (k-1)*spacing;
end
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
	scaling = str2num(get(H.res,'String'));

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
		if k > 1
			xC = xC+(k-1)*spacing;
		end
		yC = exp(0.000000000155125.*time)-1;

		age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
		age_label_x = exp(0.00000000098485.*age_label_num)-1;
		if k > 1
			age_label_x = age_label_x + (k-1)*spacing;
		end
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
	for i = 1:length(Fnorm(:,1))
		for j = 1:length(Fnorm(1,:))
			if Fnorm(i,j) < 1E-10
				Fnorm(i,j) = 0;
			end
		end
	end
	Fnormmax = max(max(Fnorm));
	H.Fnormmax = Fnormmax;
	F1s = Fnormmax*0.317;
	F2s = Fnormmax*0.05;
	surf(xF,yF,Fnorm);
	%caxis([min(Fnorm(:))-.5*range(Fnorm(:)),max(Fnorm(:))]);
	%jet
	cmap = [1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.0625	0.125	0.1875	0.25	0.3125	0.375	0.4375	0.5	0.5625	0.625	0.6875	0.75	0.8125	0.875	0.9375	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.9375	0.875	0.8125	0.75	0.6875	0.625	0.5625	0.5
	1	0	0	0	0	0	0	0	0.0625	0.125	0.1875	0.25	0.3125	0.375	0.4375	0.5	0.5625	0.625	0.6875	0.75	0.8125	0.875	0.9375	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.9375	0.875	0.8125	0.75	0.6875	0.625	0.5625	0.5	0.4375	0.375	0.3125	0.25	0.1875	0.125	0.0625	0	0	0	0	0	0	0	0	0
	1	0.625	0.6875	0.75	0.8125	0.875	0.9375	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.9375	0.875	0.8125	0.75	0.6875	0.625	0.5625	0.5	0.4375	0.375	0.3125	0.25	0.1875	0.125	0.0625	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0]';
	%parula
	%cmap = [[1,0.250390476190476,0.257771428571429,0.264728571428571,0.270647619047619,0.275114285714286,0.278300000000000,0.280333333333333,0.281338095238095,0.281014285714286,0.279466666666667,0.275971428571429,0.269914285714286,0.260242857142857,0.244033333333333,0.220642857142857,0.196333333333333,0.183404761904762,0.178642857142857,0.176438095238095,0.168742857142857,0.154000000000000,0.146028571428571,0.138023809523810,0.124814285714286,0.111252380952381,0.0952095238095238,0.0688714285714285,0.0296666666666667,0.00357142857142858,0.00665714285714287,0.0433285714285715,0.0963952380952380,0.140771428571429,0.171700000000000,0.193766666666667,0.216085714285714,0.246957142857143,0.290614285714286,0.340642857142857,0.390900000000000,0.445628571428572,0.504400000000000,0.561561904761905,0.617395238095238,0.671985714285714,0.724200000000000,0.773833333333333,0.820314285714286,0.863433333333333,0.903542857142857,0.939257142857143,0.972757142857143,0.995647619047619,0.996985714285714,0.995204761904762,0.989200000000000,0.978628571428571,0.967647619047619,0.961009523809524,0.959671428571429,0.962795238095238,0.969114285714286,0.976900000000000;1,0.164995238095238,0.181780952380952,0.197757142857143,0.214676190476190,0.234238095238095,0.255871428571429,0.278233333333333,0.300595238095238,0.322757142857143,0.344671428571429,0.366680952380952,0.389200000000000,0.412328571428571,0.435833333333333,0.460257142857143,0.484719047619048,0.507371428571429,0.528857142857143,0.549904761904762,0.570261904761905,0.590200000000000,0.609119047619048,0.627628571428572,0.645928571428571,0.663500000000000,0.679828571428571,0.694771428571429,0.708166666666667,0.720266666666667,0.731214285714286,0.741095238095238,0.750000000000000,0.758400000000000,0.766961904761905,0.775766666666667,0.784300000000000,0.791795238095238,0.797290476190476,0.800800000000000,0.802871428571429,0.802419047619048,0.799300000000000,0.794233333333333,0.787619047619048,0.779271428571429,0.769842857142857,0.759804761904762,0.749814285714286,0.740600000000000,0.733028571428571,0.728785714285714,0.729771428571429,0.743371428571429,0.765857142857143,0.789252380952381,0.813566666666667,0.838628571428572,0.863900000000000,0.889019047619048,0.913457142857143,0.937338095238095,0.960628571428571,0.983900000000000;1,0.707614285714286,0.751138095238095,0.795214285714286,0.836371428571429,0.870985714285714,0.899071428571429,0.922100000000000,0.941376190476191,0.957885714285714,0.971676190476191,0.982904761904762,0.990600000000000,0.995157142857143,0.998833333333333,0.997285714285714,0.989152380952381,0.979795238095238,0.968157142857143,0.952019047619048,0.935871428571429,0.921800000000000,0.907857142857143,0.897290476190476,0.888342857142857,0.876314285714286,0.859780952380952,0.839357142857143,0.816333333333333,0.791700000000000,0.766014285714286,0.739409523809524,0.712038095238095,0.684157142857143,0.655442857142857,0.625100000000000,0.592300000000000,0.556742857142857,0.518828571428572,0.478857142857143,0.435447619047619,0.390919047619048,0.348000000000000,0.304480952380953,0.261238095238095,0.222700000000000,0.191028571428571,0.164609523809524,0.153528571428571,0.159633333333333,0.177414285714286,0.209957142857143,0.239442857142857,0.237147619047619,0.219942857142857,0.202761904761905,0.188533333333333,0.176557142857143,0.164290476190476,0.153676190476191,0.142257142857143,0.126509523809524,0.106361904761905,0.0805000000000000]]';
	
	colormap(cmap)
	shading interp

	if get(H.conc3D,'Value') == 1 && get(H.conc3D1s,'Value') == 1
		contour3(xF,yF,Fnorm,[F1s F1s], 'm', 'LineWidth', 4)
	end
	if get(H.conc3D,'Value') == 1 && get(H.conc3D2s,'Value') == 1
		contour3(xF,yF,Fnorm,[F2s F2s], 'm', 'LineWidth', 4)
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
				text(age_label_x(1,i)+0.01, age_label_y(1,i),Fnormmax+Fnormmax*.001, age_label2(i,1), 'FontWeight', 'bold')
				plot3([age_label_x(1,i), age_label_x(1,i)], [age_label_y(1,i), age_label_y(1,i)], [0, Fnormmax], 'LineWidth', 1, 'Color', 'k')
			end
		end
	end
	
		if get(H.conc3D,'Value') == 0
			plot(xC,yC,'k','LineWidth',1.4)
			for i = 1:length(age_label_num)
				if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
					scatter3(age_label_x(1,i), age_label_y(1,i), 1, 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
					text(age_label_x(1,i)+0.01, age_label_y(1,i),age_label2(i,1), 'FontWeight', 'bold')
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
		
	xloset(k,1) = xlo;
	xhiset(k,1) = xhi;
	yloset(k,1) = ylo;
	yhiset(k,1) = yhi;
	
	clear data
end
	
	xlabel('207Pb/235U');
	ylabel('206Pb/238U');
	if get(H.defaultaxes,'Value') == 1
		axis([min(xloset) max(xhiset) min(yloset) max(yhiset)])
		set(H.setxmin,'String',min(xloset))
		set(H.setxmax,'String',max(xhiset))
		set(H.setymin,'String',min(yloset))
		set(H.setymax,'String',max(yhiset))
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

function spacing_Callback(hObject, eventdata, H)
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

function res_Callback(hObject, eventdata, H)
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
close(ConcordiaPlotter)
load(fullpathname,'H')

function copytable_Callback(hObject, eventdata, H)
data = get(H.uitable1, 'Data');
copy(data);

function pastetable_Callback(hObject, eventdata, H)
data = paste;
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
				text(age_label_x(1,i)+0.01, age_label_y(1,i),Fnormmax+Fnormmax*.001, age_label2(i,1), 'FontWeight', 'bold')
				plot3([age_label_x(1,i), age_label_x(1,i)], [age_label_y(1,i), age_label_y(1,i)], [0, Fnormmax], 'LineWidth', 1, 'Color', 'k')
			end
		end
	end
	
	
		if get(H.conc3D,'Value') == 0
			plot(xC,yC,'k','LineWidth',1.4)
			for i = 1:length(age_label_num)
				if age_label_x(1,i) > xlo && age_label_x(1,i) < xhi && age_label_y(1,i) > ylo && age_label_y(1,i) < yhi
					scatter3(age_label_x(1,i), age_label_y(1,i), 1, 40, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', 'LineWidth', 1.5)
					text(age_label_x(1,i)+0.01, age_label_y(1,i),age_label2(i,1), 'FontWeight', 'bold')
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
