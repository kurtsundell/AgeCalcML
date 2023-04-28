%% STACKEDDISTRIBUTIONPLOTTER MATLAB code for StackedDistributionPlotter.fig %%

%% SET DEFAULT COMMAND LINE AND HANDLE STRUCTURE %%
function varargout = StackedDistributionPlotter(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@StackedDistributionPlotter_OpeningFcn,'gui_OutputFcn',@StackedDistributionPlotter_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
gui_mainfcn(gui_State, varargin{:});
end
function StackedDistributionPlotter_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
guidata(hObject, H);
function varargout = StackedDistributionPlotter_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;
set(H.input1s,'Value',1)
H.export_dist = 0;
%plot_distribution(hObject, eventdata, H)
guidata(hObject,H);

%% STACKED DISTRIBUTION PLOTTER %%
function load_Callback(hObject, eventdata, H)
% [filename pathname] = uigetfile({'*'},'File Selector');
% data = readtable(char(strcat(pathname, filename)));
% 
% get(t,'columnname')
% 
% data = table2array(data);


[filename pathname] = uigetfile({'*'},'File Selector'); %load the supplemental file with zircon age eHfT data

if ispc == 1
	fullpathname = char(strcat(pathname, '\', filename));
end
if ismac == 1
	fullpathname = char(strcat(pathname, '/', filename));
end

[numbers text1, data] = xlsread(fullpathname);
numbers = num2cell(numbers);

for i = 1:size(numbers,1)
	for j = 1:size(numbers,2)
		if cellfun('isempty', numbers(i,j)) == 0
			if cellfun(@isnan, numbers(i,j)) == 1
				numbers(i,j) = {[]};
			end
		end
	end
end

% pull the names from the headers
for i = 1:(size(data,2)+1)/2
	Name(i,1) = data(1,i*2-1);
end

for i = 1:size(data,2)/2
	headers(1,i*2-1) = Name(i,1);
	if get(H.input1s,'Value') == 1
		headers(1,i*2) = {'1s'};
	end
	if get(H.input2s,'Value') == 1
		headers(1,i*2) = {'2s'};
	end
end


% if iscell(data) == 0 
% 	data = num2cell(data);
% end
% 
% for i = 1:length(data(:,1))
% 	for j = 1:length(data(1,:))
% 		if cellfun('isempty', data(i,j)) == 0
% 			if cellfun(@isnan, data(i,j)) == 1
% 				data(i,j) = {[]};
% 			end	
% 		end
% 	end
% end

set(H.uitable1, 'columnname', headers);
set(H.uitable1, 'Data', numbers);
data = get(H.uitable1, 'Data');
H.Name = Name;
H.headers = headers;
set(H.filepath,'String',[strcat(pathname, filename)])
plot_distribution(hObject, eventdata, H)
guidata(hObject,H);


function plot_distribution(hObject, eventdata, H)

Name = H.Name;

	if H.export_dist == 1
		figure;
		set(gca,'FontSize',str2num(get(H.fontsize_n,'String')));
	end
	if H.export_dist == 0
		cla(H.axes_comp,'reset');
		axes(H.axes_comp);	
		set(H.axes_comp,'FontSize',str2num(get(H.fontsize_n,'String')));
	end
	H.export_dist = 0;
	guidata(hObject,H);
	
data = get(H.uitable1, 'Data');

if iscell(data) == 0
	data = num2cell(data);
end

hold on
	
xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
bins = str2num(get(H.bins,'String'));
x=xmin:xint:xmax;
	
N = length(data(1,:))/2;

% 	if get(H.input1s,'Value') == 1
% 		columnname =   {'Age', '±1s'};
% 		set(H.uitable1, 'ColumnName', columnname);
% 	end
% 
% 	if get(H.input2s,'Value') == 1
% 		columnname =   {'Age', '±2s'};
% 		set(H.uitable1, 'ColumnName', columnname);
% 	end

gap = 15; % in percent
binset = 0;
pdpmax = 0;
kdemax = 0;

spac = str2num(get(H.spacing,'String'));

if get(H.s_color, 'Value') == 1
	face = 'r';
elseif get(H.s_color, 'Value') == 2
	face = 'g';
elseif get(H.s_color, 'Value') == 3
	face = 'b';
elseif get(H.s_color, 'Value') == 4
	face = 'y';
elseif get(H.s_color, 'Value') == 5
	face = 'm';
elseif get(H.s_color, 'Value') == 6
	face = 'c';	
elseif get(H.s_color, 'Value') == 7
	face = 'w';
elseif get(H.s_color, 'Value') == 8
	face = 'k';
elseif get(H.s_color, 'Value') == 9
	face = 'none';	
end

if get(H.s_edge, 'Value') == 1
	edge = 'r';
elseif get(H.s_edge, 'Value') == 2
	edge = 'g';
elseif get(H.s_edge, 'Value') == 3
	edge = 'b';
elseif get(H.s_edge, 'Value') == 4
	edge = 'y';
elseif get(H.s_edge, 'Value') == 5
	edge = 'm';
elseif get(H.s_edge, 'Value') == 6
	edge = 'c';	
elseif get(H.s_edge, 'Value') == 7
	edge = 'w';
elseif get(H.s_edge, 'Value') == 8
	edge = 'k';
elseif get(H.s_edge, 'Value') == 9
	edge = 'none';	
end


base = 0;
for k = 1:N
	data_tmp = data(:,k*2-1:k*2);
	
	
	
	dist_data = [];
	
	for i = 1:length(data_tmp(:,1))
		if cellfun('isempty', data_tmp(i,1)) == 0 && cellfun('isempty', data_tmp(i,2)) == 0
			if cell2num(data_tmp(i,1)) >= xmin && cell2num(data_tmp(i,1)) <= xmax
				dist_data(i,1:2) = cell2num(data_tmp(i,1:2));
			end
		end
	end
	
	if isempty(dist_data) == 0 && sum(length(nonzeros(dist_data(:,1)))) > 1
		
		dist_data = dist_data(any(dist_data ~= 0,2),:);
		if get(H.input2s,'Value') == 1
			dist_data(:,2) = dist_data(:,2)./2;
		end
		
		if get(H.radio_hist, 'Value') == 1
			[counts bincenters] = hist(dist_data(:,1), bins);
			bindiff = bincenters(1,2) - bincenters(1,1);
			for i = 1:length(bincenters)
				rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
			end
			binset = max(counts) + binset + 1;
			n_tmp = length(dist_data(:,1));
			text(xmax, base + max(counts)/2, strcat(Name(k,1),'{ }','(n =','{ }',num2str(n_tmp),')'),'fontsize',str2num(get(H.font_anot,'String')), 'horizontalAlignment', 'right')
			base = base + max(counts);				
			plot([xmin xmax], [binset binset],'k')
			clear data_tmp dist_data counts bincenters bindiff
			axis([xmin xmax 0 binset+1])
			xlabel('Age (Ma)')
			ylabel('Number')
		end
		
		
		
		
		
		if get(H.radio_pdp, 'Value') == 1
			pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
			patch([x,xmax,xmin], [pdp+base,min(pdp)+base,min(pdp)+base],face)
			p = plot(x, pdp+base, 'Color', edge, 'LineWidth', 2);
			n_tmp = length(dist_data(:,1));
			text(xmax, base + max(pdp)/2, strcat(Name(k,1),'{ }','(n =','{ }',num2str(n_tmp),')'),'fontsize',str2num(get(H.font_anot,'String')), 'horizontalAlignment', 'right')
			base = base + max(pdp) + spac;
			lgnd=legend(p, 'Probability Density Plot');
			set(lgnd,'Color','w');
			xlabel('Age (Ma)','Color','k')
			ylabel('Probability','Color','k')
			axis([xmin xmax 0 base])
		end
		
		if get(H.radio_kde, 'Value') == 1
			if get(H.optimize,'Value') == 1
				xA = transpose(x);
				n = length(dist_data(:,1));
				[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
				kdeA=transpose(interp1(xmesh1, kdeA, xA));
				patch([x,xmax,xmin], [kdeA+base,min(kdeA)+base,min(kdeA)+base],face)
				hl1 = plot(x,kdeA+base,'Color', edge,'LineWidth',2);
				n_tmp = length(dist_data(:,1));
				text(xmax, base + max(kdeA)/2, strcat(Name(k,1),'{ }','(n =','{ }',num2str(n_tmp),')'),'fontsize',str2num(get(H.font_anot,'String')), 'horizontalAlignment', 'right')
				base = base + max(kdeA);	
				set(hl1,'linewidth',2)
				set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
			end
			if get(H.Myr_kernel,'Value') == 1
				kernel = str2num(get(H.Myr_Kernel_text,'String'));
				kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
				kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);
				
				if get(H.yeq,'Value') == 1
					kde1 = kde1*(1/(max(kde1)/(1/N)));
				end
				if get(H.s_color,'Value') < 9
					patch([x,xmax,xmin], [kde1+base,min(kde1)+base,min(kde1)+base],face)
				end
				hl1 = plot(x,kde1+base,'Color',edge,'LineWidth',2);
				n_tmp = length(dist_data(:,1));
				text(xmax, base + max(kde1)/2, strcat(Name(k,1),'{ }','(n =','{ }',num2str(n_tmp),')'),'fontsize',str2num(get(H.font_anot,'String')), 'horizontalAlignment', 'right')
				base = base + max(kde1);
				set(hl1,'linewidth',2)
				set(gca,'box','off')
			end
			%lgnd=legend('Kernel Density Estimate');
			%set(lgnd,'Color','w');
			%legend boxoff
			xlabel('Age (Ma)','Color','k')
			ylabel('Probability','Color','k')
			axis([xmin xmax 0 base])
		end
		
		if get(H.radio_pdp_kde, 'Value') == 1
			if get(H.optimize,'Value') == 1
				xA = transpose(x);
				n = length(dist_data(:,1));
				[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
				kdeA=transpose(interp1(xmesh1, kdeA, xA));
				set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
				pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
				pdpm = max(pdp);
				kde_adj = kdeA*(1/(max(kdeA)/max(pdp)));
				pdp = pdp + pdpmax;
				kdeA = kde_adj + kdemax;
				p1 = plot(x,kdeA,'Color',[1 0 0],'LineWidth',2);
				p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
				plot([xmin xmax], [pdpmax pdpmax],'k')
				pdpmax = max(pdp);
				kdemax = max(pdp);
				n_tmp = length(dist_data(:,1));
				text(xmax, base + pdpm/2, strcat(Name(k,1),'{ }','(n =','{ }',num2str(n_tmp),')'),'fontsize',str2num(get(H.font_anot,'String')), 'horizontalAlignment', 'right')
				base = base + pdpm;	
				set(p1,'linewidth',2)
				lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
				axis([xmin xmax 0 pdpmax+0.2*pdpmax])
			end
			if get(H.Myr_kernel,'Value') == 1
				kernel = str2num(get(H.Myr_Kernel_text,'String'));
				kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
				kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);
				pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
				pdpm = max(pdp);
				kde_adj = kde1*(1/(max(kde1)/max(pdp)));
				pdp = pdp + pdpmax;
				kde1 = kde_adj + kdemax;
				p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
				p1 = plot(x,kde1,'Color',[1 0 0],'LineWidth',2);
				plot([xmin xmax], [pdpmax pdpmax],'k')
				pdpmax = max(pdp);
				kdemax = max(pdp);
				n_tmp = length(dist_data(:,1));
				text(xmax, base + pdpm/2, strcat(Name(k,1),'{ }','(n =','{ }',num2str(n_tmp),')'),'fontsize',str2num(get(H.font_anot,'String')), 'horizontalAlignment', 'right')
				base = base + pdpm;	
				set(p1,'linewidth',2)
				axis([xmin xmax 0 pdpmax+0.2*pdpmax])
				lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
				set(p1,'linewidth',2)
			end
			set(lgnd,'Color','w');
			%legend boxoff
			xlabel('Age (Ma)','Color','k')
			ylabel('Probability','Color','k')
			axis([xmin xmax 0 pdpmax])
		end
		
		if get(H.radio_hist_pdp, 'Value') == 1
			pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
			[counts bincenters] = hist(dist_data(:,1), bins);
			bindiff = bincenters(1,2) - bincenters(1,1);
			for i = 1:length(bincenters)
				rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
			end
			pdp_adj = pdp*(1/(max(pdp)/max(counts)));
			pdp = pdp_adj + binset;
			p = plot(x, pdp, 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
			plot([xmin xmax], [binset binset],'k')
			binset = max(counts) + binset + 1;
			%clear data_tmp dist_data counts bincenters bindiff
			n_tmp = length(dist_data(:,1));
			text(xmax, base + max(counts)/2, strcat(Name(k,1),'{ }','(n =','{ }',num2str(n_tmp),')'),'fontsize',str2num(get(H.font_anot,'String')), 'horizontalAlignment', 'right')
			base = base + max(counts);	
			axis([xmin xmax 0 binset+1])
			lgnd=legend(p, 'Probability Density Plot');
			set(lgnd,'color','w');
			%legend boxoff
			xlabel('Age (Ma)','Color','k')
			ylabel('Number','Color','k')
		end
		
		if get(H.radio_hist_kde, 'Value') == 1
			if get(H.optimize,'Value') == 1
				xA = transpose(x);
				[counts bincenters] = hist(dist_data(:,1), bins);
				bindiff = bincenters(1,2) - bincenters(1,1);
				for i = 1:length(bincenters)
					rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
				end
				[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
				kdeA=transpose(interp1(xmesh1, kdeA, xA));
				kde_adj = kdeA*(1/(max(kdeA)/max(counts)));
				kdeA = kde_adj + binset;
				p1 = plot(x,kdeA,'Color',[1 0 0],'LineWidth',2);
				plot([xmin xmax], [binset binset],'k')
				binset = max(counts) + binset + 1;
				n_tmp = length(dist_data(:,1));
				text(xmax, base + max(counts)/2, strcat(Name(k,1),'{ }','(n =','{ }',num2str(n_tmp),')'),'fontsize',str2num(get(H.font_anot,'String')), 'horizontalAlignment', 'right')
				base = base + max(counts);					
				lgnd=legend(p1,'Kernel Density Estimate');
				set(p1,'linewidth',2)
				set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
				xlabel('Age (Ma)','Color','k')
				ylabel('Number','Color','k')
				axis([xmin xmax 0 binset])
			end
			if get(H.Myr_kernel,'Value') == 1
				[counts bincenters] = hist(dist_data(:,1), bins);
				bindiff = bincenters(1,2) - bincenters(1,1);
				for i = 1:length(bincenters)
					rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
				end
				kernel = str2num(get(H.Myr_Kernel_text,'String'));
				kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
				kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);
				kde_adj = kde1*(1/(max(kde1)/max(counts)));
				kde1 = kde_adj + binset;
				p1 = plot(x,kde1,'Color',[1 0 0],'LineWidth',2);
				plot([xmin xmax], [binset binset],'k')
				binset = max(counts) + binset + 1;
				n_tmp = length(dist_data(:,1));
				text(xmax, base + max(counts)/2, strcat(Name(k,1),'{ }','(n =','{ }',num2str(n_tmp),')'),'fontsize',str2num(get(H.font_anot,'String')), 'horizontalAlignment', 'right')
				base = base + max(counts);					
				axis([xmin xmax 0 binset+1])
				lgnd=legend(p1,'Kernel Density Estimate');
				set(p1,'linewidth',2)
			end
			set(lgnd,'color','w');
			%legend boxoff
			xlabel('Age (Ma)','Color','k')
			ylabel('Number','Color','k')
		end
		
		if get(H.radio_hist_pdp_kde, 'Value') == 1
			if get(H.optimize,'Value') == 1
				[counts bincenters] = hist(dist_data(:,1), bins);
				bindiff = bincenters(1,2) - bincenters(1,1);
				for i = 1:length(bincenters)
					rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
				end
				xA = transpose(x);
				[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
				kdeA=transpose(interp1(xmesh1, kdeA, xA));
				pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
				pdp_adj = pdp*(1/(max(pdp)/max(counts)));
				pdp = pdp_adj + binset;
				p = plot(x, pdp, 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
				[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
				kdeA=transpose(interp1(xmesh1, kdeA, xA));
				kde_adj = kdeA*(1/(max(kdeA)/max(counts)));
				kdeA = kde_adj + binset;
				p1 = plot(x,kdeA,'Color',[1 0 0],'LineWidth',2);
				plot([xmin xmax], [binset binset],'k')
				binset = max(counts) + binset + 1;
				n_tmp = length(dist_data(:,1));
				text(xmax, base + max(counts)/2, strcat(Name(k,1),'{ }','(n =','{ }',num2str(n_tmp),')'),'fontsize',str2num(get(H.font_anot,'String')), 'horizontalAlignment', 'right')
				base = base + max(counts);					
				axis([xmin xmax 0 binset])
				lgnd=legend([p,p1],'Probability Density Plot','Kernel Density Estimate');
				set(p1,'linewidth',2)
				set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
				xlabel('Age (Ma)','Color','k')
				ylabel('Number','Color','k')
			end
			if get(H.Myr_kernel,'Value') == 1
				[counts bincenters] = hist(dist_data(:,1), bins);
				bindiff = bincenters(1,2) - bincenters(1,1);
				for i = 1:length(bincenters)
					rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
				end
				kernel = str2num(get(H.Myr_Kernel_text,'String'));
				kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
				kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);
				kde_adj = kde1*(1/(max(kde1)/max(counts)));
				kde1 = kde_adj + binset;
				p1 = plot(x,kde1,'Color',[1 0 0],'LineWidth',2);
				pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
				pdp_adj = pdp*(1/(max(pdp)/max(counts)));
				pdp = pdp_adj + binset;
				p = plot(x, pdp, 'Color', [0.1 0.8 0.1], 'LineWidth', 2);
				plot([xmin xmax], [binset binset],'k')
				binset = max(counts) + binset + 1;
				n_tmp = length(dist_data(:,1));
				text(xmax, base + max(counts)/2, strcat(Name(k,1),'{ }','(n =','{ }',num2str(n_tmp),')'),'fontsize',str2num(get(H.font_anot,'String')), 'horizontalAlignment', 'right')
				base = base + max(counts);				
				axis([xmin xmax 0 binset])
				lgnd=legend([p,p1], 'Probability Density Plot','Kernel Density Estimate');
			end
			set(lgnd,'Color','w');
			%legend boxoff
			xlabel('Age (Ma)','Color','k')
			ylabel('Number','Color','k')
		end
		clear data_tmp dist_data
	end
	
	
	
	
	
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
close(StackedDistributionPlotter)
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


Name = H.Name;

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

if iscell(data) == 0
	data = num2cell(data);
end

hold on
	
xmin = str2num(get(H.xmin,'String'));
xmax = str2num(get(H.xmax,'String'));
xint = str2num(get(H.xint,'String'));
bins = str2num(get(H.bins,'String'));
x=xmin:xint:xmax;
	
N = length(data(1,:))/2;

% 	if get(H.input1s,'Value') == 1
% 		columnname =   {'Age', '±1s'};
% 		set(H.uitable1, 'ColumnName', columnname);
% 	end
% 
% 	if get(H.input2s,'Value') == 1
% 		columnname =   {'Age', '±2s'};
% 		set(H.uitable1, 'ColumnName', columnname);
% 	end

gap = 15; % in percent
binset = 0;
pdpmax = 0;
kdemax = 0;

colors = jet(N);



base = 0;
for k = 1:N
	data_tmp = data(:,k*2-1:k*2);
	
	for i = 1:length(data_tmp(:,1)) 
		if cellfun('isempty', data_tmp(i,1)) == 0 && cellfun('isempty', data_tmp(i,2)) == 0 
			if cell2num(data_tmp(i,1)) >= xmin && cell2num(data_tmp(i,1)) <= xmax
				dist_data(i,1:2) = cell2num(data_tmp(i,1:2));
			end
		end
	end
	dist_data = dist_data(any(dist_data ~= 0,2),:);
	if get(H.input2s,'Value') == 1
		dist_data(:,2) = dist_data(:,2)./2;
	end
	
	if get(H.radio_hist, 'Value') == 1
		[counts bincenters] = hist(dist_data(:,1), bins);
		bindiff = bincenters(1,2) - bincenters(1,1);
		for i = 1:length(bincenters)
			rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
		end
		binset = max(counts) + binset + 1;
		plot([xmin xmax], [binset binset],'k')
		clear data_tmp dist_data counts bincenters bindiff
		axis([xmin xmax 0 binset+1])
		xlabel('Age (Ma)')
		ylabel('Number')
	end
	
	
	
	
	
	if get(H.radio_pdp, 'Value') == 1
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		patch([x,xmax,xmin], [pdp+base,min(pdp)+base,min(pdp)+base],colors(k,:))
		p = plot(x, pdp+base, 'Color', 'k', 'LineWidth', 2);	
		text(xmax, base + max(pdp)/2, Name(k,1),'fontsize',16, 'horizontalAlignment', 'right')
		base = base + max(pdp);
		lgnd=legend(p, 'Probability Density Plot');
		set(lgnd,'Color','w');
		xlabel('Age (Ma)','Color','k')
		ylabel('Probability','Color','k')
		axis([xmin xmax 0 base])
	end

	if get(H.radio_kde, 'Value') == 1
		if get(H.optimize,'Value') == 1
			xA = transpose(x);
			n = length(dist_data(:,1));
			[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
			kdeA=transpose(interp1(xmesh1, kdeA, xA));
			
			
			patch([x,xmax,xmin], [kdeA+base,min(kdeA)+base,min(kdeA)+base],colors(k,:))
			hl1 = plot(x,kdeA+base,'Color','k','LineWidth',2);
			text(xmax, base + max(kdeA)/2, Name(k,1),'fontsize',16, 'horizontalAlignment', 'right')
			
			
			base = base + max(kdeA);
			
	
			set(hl1,'linewidth',2)
			set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
		end
		if get(H.Myr_kernel,'Value') == 1
			kernel = str2num(get(H.Myr_Kernel_text,'String'));
			kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
			kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);
			patch([x,xmax,xmin], [kde1+base,min(kde1)+base,min(kde1)+base],colors(k,:))
			hl1 = plot(x,kde1+base,'Color','k','LineWidth',2);
			text(xmax, base + max(kde1)/2, Name(k,1),'fontsize',16, 'horizontalAlignment', 'right')
			base = base + max(kde1);			
			set(hl1,'linewidth',2)
			set(gca,'box','off')
		end	
		lgnd=legend('Kernel Density Estimate');
		set(lgnd,'Color','w');
		%legend boxoff
		xlabel('Age (Ma)','Color','k')
		ylabel('Probability','Color','k')
		axis([xmin xmax 0 base])
	end

	if get(H.radio_pdp_kde, 'Value') == 1
		if get(H.optimize,'Value') == 1
			xA = transpose(x);
			n = length(dist_data(:,1));
			[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
			kdeA=transpose(interp1(xmesh1, kdeA, xA));
			set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
			pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
			kde_adj = kdeA*(1/(max(kdeA)/max(pdp)));
			pdp = pdp + pdpmax;
			kdeA = kde_adj + kdemax;
			p1 = plot(x,kdeA,'Color',[1 0 0],'LineWidth',2);
			p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
			plot([xmin xmax], [pdpmax pdpmax],'k')
			pdpmax = max(pdp);
			kdemax = max(pdp);			
			set(p1,'linewidth',2)
			lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
			axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		end
		if get(H.Myr_kernel,'Value') == 1
			kernel = str2num(get(H.Myr_Kernel_text,'String'));
			kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;	
			kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint); 
			pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data	
			kde_adj = kde1*(1/(max(kde1)/max(pdp)));	
			pdp = pdp + pdpmax;
			kde1 = kde_adj + kdemax;		
			p = plot(x, pdp, 'Color', 'b', 'LineWidth', 2);
			p1 = plot(x,kde1,'Color',[1 0 0],'LineWidth',2);
			plot([xmin xmax], [pdpmax pdpmax],'k')
			pdpmax = max(pdp);
			kdemax = max(pdp);
			set(p1,'linewidth',2)
			axis([xmin xmax 0 pdpmax+0.2*pdpmax])
			lgnd=legend([p, p1], 'Probability Density Plot', 'Kernel Density Estimate');
			set(p1,'linewidth',2)
		end
		set(lgnd,'Color','w');
		%legend boxoff
		xlabel('Age (Ma)','Color','k')
		ylabel('Probability','Color','k')
		axis([xmin xmax 0 pdpmax])
	end
	
	if get(H.radio_hist_pdp, 'Value') == 1
		pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
		[counts bincenters] = hist(dist_data(:,1), bins);
		bindiff = bincenters(1,2) - bincenters(1,1);
		for i = 1:length(bincenters)
			rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
		end	
		pdp_adj = pdp*(1/(max(pdp)/max(counts)));	
		pdp = pdp_adj + binset;	
		p = plot(x, pdp, 'Color', [0.1 0.8 0.1], 'LineWidth', 2);	
		plot([xmin xmax], [binset binset],'k')	
		binset = max(counts) + binset + 1;
		%clear data_tmp dist_data counts bincenters bindiff
		axis([xmin xmax 0 binset+1])
		lgnd=legend(p, 'Probability Density Plot');
		set(lgnd,'color','w');
		%legend boxoff
		xlabel('Age (Ma)','Color','k')
		ylabel('Number','Color','k')
		end
		
	if get(H.radio_hist_kde, 'Value') == 1
		if get(H.optimize,'Value') == 1
			xA = transpose(x);
			[counts bincenters] = hist(dist_data(:,1), bins);
			bindiff = bincenters(1,2) - bincenters(1,1);
			for i = 1:length(bincenters)
				rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
			end	
			[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
			kdeA=transpose(interp1(xmesh1, kdeA, xA));
			kde_adj = kdeA*(1/(max(kdeA)/max(counts)));
			kdeA = kde_adj + binset;	
			p1 = plot(x,kdeA,'Color',[1 0 0],'LineWidth',2);
			plot([xmin xmax], [binset binset],'k')	
			binset = max(counts) + binset + 1;
			lgnd=legend(p1,'Kernel Density Estimate');
			set(p1,'linewidth',2)
			set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
			xlabel('Age (Ma)','Color','k')
			ylabel('Number','Color','k')
			axis([xmin xmax 0 binset])
		end
		if get(H.Myr_kernel,'Value') == 1
			[counts bincenters] = hist(dist_data(:,1), bins);
			bindiff = bincenters(1,2) - bincenters(1,1);
			for i = 1:length(bincenters)
				rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
			end					
			kernel = str2num(get(H.Myr_Kernel_text,'String'));
			kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
			kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);	
			kde_adj = kde1*(1/(max(kde1)/max(counts)));
			kde1 = kde_adj + binset;	
			p1 = plot(x,kde1,'Color',[1 0 0],'LineWidth',2);
			plot([xmin xmax], [binset binset],'k')	
			binset = max(counts) + binset + 1;	
			axis([xmin xmax 0 binset+1])
			lgnd=legend(p1,'Kernel Density Estimate');
			set(p1,'linewidth',2)
		end
		set(lgnd,'color','w');
		%legend boxoff
		xlabel('Age (Ma)','Color','k')
		ylabel('Number','Color','k')
	end
		
	if get(H.radio_hist_pdp_kde, 'Value') == 1
		if get(H.optimize,'Value') == 1
			[counts bincenters] = hist(dist_data(:,1), bins);
			bindiff = bincenters(1,2) - bincenters(1,1);
			for i = 1:length(bincenters)
				rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
			end				
			xA = transpose(x);
			[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
			kdeA=transpose(interp1(xmesh1, kdeA, xA));	
			pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
			pdp_adj = pdp*(1/(max(pdp)/max(counts)));	
			pdp = pdp_adj + binset;		
			p = plot(x, pdp, 'Color', [0.1 0.8 0.1], 'LineWidth', 2);		
			[bandwidth,kdeA,xmesh1,cdf]=kde(dist_data(:,1),length(x),xmin,xmax);
			kdeA=transpose(interp1(xmesh1, kdeA, xA));
			kde_adj = kdeA*(1/(max(kdeA)/max(counts)));
			kdeA = kde_adj + binset;				
			p1 = plot(x,kdeA,'Color',[1 0 0],'LineWidth',2);	
			plot([xmin xmax], [binset binset],'k')				
			binset = max(counts) + binset + 1;	
			axis([xmin xmax 0 binset])
			lgnd=legend([p,p1],'Probability Density Plot','Kernel Density Estimate');
			set(p1,'linewidth',2)
			set(H.Myr_Kernel_text, 'String', round(bandwidth, 2));
			xlabel('Age (Ma)','Color','k')
			ylabel('Number','Color','k')
			end
		if get(H.Myr_kernel,'Value') == 1	
			[counts bincenters] = hist(dist_data(:,1), bins);
			bindiff = bincenters(1,2) - bincenters(1,1);
			for i = 1:length(bincenters)
				rectangle('Position',[bincenters(1,i)-bindiff+bindiff*gap*.01 binset bindiff-bindiff*gap*.01 counts(1,i)],'FaceColor','b','EdgeColor','k')
			end					
			kernel = str2num(get(H.Myr_Kernel_text,'String'));
			kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
			kde1=pdp5(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);	
			kde_adj = kde1*(1/(max(kde1)/max(counts)));
			kde1 = kde_adj + binset;	
			p1 = plot(x,kde1,'Color',[1 0 0],'LineWidth',2);	
			pdp=pdp5(dist_data(:,1),dist_data(:,2),xmin,xmax,xint); %1 sigma pdp input data
			pdp_adj = pdp*(1/(max(pdp)/max(counts)));	
			pdp = pdp_adj + binset;		
			p = plot(x, pdp, 'Color', [0.1 0.8 0.1], 'LineWidth', 2);				
			plot([xmin xmax], [binset binset],'k')				
			binset = max(counts) + binset + 1;				
			axis([xmin xmax 0 binset])
			lgnd=legend([p,p1], 'Probability Density Plot','Kernel Density Estimate');
		end
		set(lgnd,'Color','w');
		%legend boxoff
		xlabel('Age (Ma)','Color','k')
		ylabel('Number','Color','k')
	end	
	clear data_tmp dist_data
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

function fontsize_n_Callback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)

function font_anot_Callback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)

function s_edge_Callback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)

function s_color_Callback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)


function yeq_Callback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)


function spacing_Callback(hObject, eventdata, H)
plot_distribution(hObject, eventdata, H)
