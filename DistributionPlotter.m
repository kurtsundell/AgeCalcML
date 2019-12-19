%% DISTRIBUTIONPLOTTER MATLAB code for DistributionPlotter.fig %%

%% SET DEFAULT COMMAND LINE AND HANDLE STRUCTURE %%
function varargout = DistributionPlotter(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@DistributionPlotter_OpeningFcn,'gui_OutputFcn',@DistributionPlotter_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
gui_mainfcn(gui_State, varargin{:});
end
function DistributionPlotter_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
guidata(hObject, H);
function varargout = DistributionPlotter_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;
set(H.input1s,'Value',1)
H.export_dist = 0;
%plot_distribution(hObject, eventdata, H)
guidata(hObject,H);

%% DISTRIBUTION PLOTTER %%
function load_Callback(hObject, eventdata, H)
[filename pathname] = uigetfile({'*'},'File Selector');
data = readtable(char(strcat(pathname, filename)));
data = table2array(data);
set(H.uitable1, 'Data', data);
data = get(H.uitable1, 'Data');
set(H.filepath,'String',[strcat(pathname, filename)])
plot_distribution(hObject, eventdata, H)

function plot_distribution(hObject, eventdata, H)

	if H.export_dist == 1
		figure;
	end
	if H.export_dist == 0
		cla(H.axes_comp,'reset');
		axes(H.axes_comp);	
	end
	H.export_dist = 0;
	guidata(hObject,H);
	
data = get(H.uitable1, 'Data');

if iscell(data) == 1
	data = cell2num(data);
end

for i = 1:length(data(:,1))
	if data(i,1) > str2double(get(H.xmin,'String')) && data(i,1) < str2double(get(H.xmax,'String'))
		data(i,:) = data(i,:);
	else
		data(i,1:2) = 0;
	end
end

data = data(any(data ~= 0,2),:);

if get(H.input1s,'Value') == 1
	columnname =   {'Age', '±1s'};
	set(H.uitable1, 'ColumnName', columnname);
	dist_data = data;
end

if get(H.input2s,'Value') == 1
	columnname =   {'Age', '±2s'};
	set(H.uitable1, 'ColumnName', columnname);
	dist_data(:,1) = data(:,1);
	dist_data(:,2) = data(:,2)./2;
end

%%%% All calculations assume 1 sigma % input below. Adjusted above if needed.

	hold on
	
	xmin = str2num(get(H.xmin,'String'));
	xmax = str2num(get(H.xmax,'String'));
	xint = str2num(get(H.xint,'String'));
	bins = str2num(get(H.bins,'String'));
	x=xmin:xint:xmax;
	
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

function uitable1_CellEditCallback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)

function exportplot_Callback(hObject, eventdata, H)
H.export_dist = 1;
guidata(hObject,H);
plot_distribution(hObject, eventdata, H)

function savesession_Callback(hObject, eventdata, H)
[file,path] = uiputfile('*.mat','Save file');
save([path file],'H')

function loadsession_Callback(hObject, eventdata, H)
[filename pathname] = uigetfile({'*'},'File Selector','MultiSelect','on');
fullpathname = strcat(pathname, filename);
close(DistributionPlotter)
load(fullpathname,'H')

function copytable_Callback(hObject, eventdata, H)
data = get(H.uitable1, 'Data');
copy(data);

function pastetable_Callback(hObject, eventdata, H)
data = paste;
set(H.uitable1, 'Data', data);
plot_distribution(hObject, eventdata, H)

function saveplot_Callback(hObject, eventdata, H)

FIG = figure('visible', 'off');

%%%%%%% plot code


data = get(H.uitable1, 'Data');

for i = 1:length(data(:,1))
	if data(i,1) > str2double(get(H.xmin,'String')) && data(i,1) < str2double(get(H.xmax,'String'))
		data(i,:) = data(i,:);
	else
		data(i,1:2) = 0;
	end
end

data = data(any(data ~= 0,2),:);

if get(H.input1s,'Value') == 1
	columnname =   {'Age', '±1s'};
	set(H.uitable1, 'ColumnName', columnname);
	dist_data = data;
end

if get(H.input2s,'Value') == 1
	columnname =   {'Age', '±2s'};
	set(H.uitable1, 'ColumnName', columnname);
	dist_data(:,1) = data(:,1);
	dist_data(:,2) = data(:,2)./2;
end

%%%% All calculations assume 1 sigma % input below. Adjusted above if needed.

	hold on
	
	xmin = str2num(get(H.xmin,'String'));
	xmax = str2num(get(H.xmax,'String'));
	xint = str2num(get(H.xint,'String'));
	bins = str2num(get(H.bins,'String'));
	x=xmin:xint:xmax;
	
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


%%%%%%% save code

[file,path] = uiputfile('*.eps','Save file');
print(FIG,'-depsc','-painters',[path file]);

function input1s_Callback(hObject, eventdata, H)
set(H.input1s,'Value',1)
set(H.input2s,'Value',0)
plot_distribution(hObject, eventdata, H)

function input2s_Callback(hObject, eventdata, H)
set(H.input1s,'Value',0)
set(H.input2s,'Value',1)
plot_distribution(hObject, eventdata, H)

function Myr_kernel_text_Callback(hObject, eventdata, handles)
plot_distribution(hObject, eventdata, H)
