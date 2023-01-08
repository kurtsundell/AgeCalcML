function varargout = Scanlist(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn', @Scanlist_OpeningFcn,'gui_OutputFcn',@Scanlist_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function Scanlist_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
H.loaded = 0;
set(H.chk_T,'Value',0)
set(H.name_T,'Enable','off')
set(H.n_T,'Enable','off')
set(H.add_T,'Enable','off')
set(H.range_T,'Enable','off')
guidata(hObject, H);
run(hObject, eventdata, H)

function varargout = Scanlist_OutputFcn(hObject, eventdata, H) 
varargout{1} = H.output;

function loadscancsv_Callback(hObject, eventdata, H)
[file,path,indx] = uigetfile({'*.scancsv'},'Select a File');
H.fullpathname = [path,file];
set(H.filepath, 'String', H.fullpathname); %show path name
H.input = importdata(H.fullpathname);
H.Names = H.input(2:end,1);
H.loaded = 1;
guidata(hObject, H);
run(hObject, eventdata, H)

function run(hObject, eventdata, H)

n = str2num(get(H.n_U,'String')); % number of unknowns
n_s = str2num(get(H.n_S,'String')); % number of secondaries
if get(H.chk_T,'Value') == 1
	n_t = str2num(get(H.n_T,'String')); % number of tertiaries
else
	n_t = 0;
end

Unknown_Name = get(H.name_U,'String');
Primary_Name = get(H.name_P,'String');
Secondary_Name = get(H.name_S,'String');;
Tertiary_Name = get(H.name_T,'String');;

% place primaries and determine how many based on number of unknowns
div_p = floor(n/5);
rem_p = rem(n,div_p);

for i = 1:div_p+1
	list_p(i+(i-1)*5,1) = 1;
end

list_p(end+1:end+rem_p,1) = 0;

% place secondaries within primary list based on user defined amount
div_s = floor(length(list_p)/n_s);
rem_s = rem(length(list_p),n_s);

for i = 1:n_s
	list_s(i+(i-1)*div_s+div_s,1) = 2;
	list_s(i+(i-1)*div_s:i+(i-1)*div_s+div_s-1,1) = ...
		list_p(1+(i-1)*div_s:i*div_s,1);	
end

list_s(end+1:end+rem_s,1) = ...
	list_p(end-rem_s+1:end,1);

if n_t > 0 && get(H.chk_T,'Value') == 1
	
	% place tertiaries within secondary list based on user defined amount
	
	div_t = floor(length(list_s)/n_t);
	rem_t = rem(length(list_s),n_t);
	
	for i = 1:n_t
		list_t(i+i*div_t,1) = 3;
		list_t(i+(i-1)*div_t:i+(i-1)*div_t+div_t-1) = ...
			list_s(1+(i-1)*div_t:i*div_t,1);
	end
	
	list_t(end+1:end+rem_t,1) = ...
		list_s(end-rem_t+1:end,1);
end
	
Add_P = str2num(get(H.add_P,'String'));
Add_S = str2num(get(H.add_S,'String'));
Add_T = str2num(get(H.add_T,'String'));

n_p = sum(list_p)+Add_P*2; % number of primaries
set(H.n_P,'String',n_p)

n_s = n_s + Add_S*2;

if n_t > 0 && get(H.chk_T,'Value') == 1
	n_t = n_t + Add_T*2;
end

if n_t > 0 && get(H.chk_T,'Value') == 1
	list_complete = list_t;
else
	list_complete = list_s;
end

if n_t > 0 && get(H.chk_T,'Value') == 1
	list_complete(1+Add_T:length(list_complete)+Add_T,1) = list_complete;
	list_complete(1:Add_T,1) = 3;
	list_complete(end+1:end+Add_T,1) = 3;
end

if n_s > 0
	list_complete(1+Add_S:length(list_complete)+Add_S,1) = list_complete;
	list_complete(1:Add_S,1) = 2;
	list_complete(end+1:end+Add_S,1) = 2;
end

list_complete(1+Add_P:length(list_complete)+Add_P,1) = list_complete;
list_complete(1:Add_P,1) = 1;
list_complete(end+1:end+Add_P,1) = 1;


if get(H.shuffle,'Value') == 1
	
	if get(H.chk_T,'Value') == 1
		block = sum(Add_P+Add_S+Add_T);
	else
		block = sum(Add_P+Add_S);
	end
	
	beg_tmp = list_complete(1:block,1);
	[r_1 c_1] = size(beg_tmp);
	shuffledRow_1 = randperm(r_1);
	beg_shuf = beg_tmp(shuffledRow_1, :);
	
	end_tmp = list_complete(1:block,1);
	[r_2 c_2] = size(end_tmp);
	shuffledRow_2 = randperm(r_2);
	end_shuf = end_tmp(shuffledRow_2, :);
	
	list_complete(1:block,1) = beg_shuf;
	list_complete(end-block+1:end,1) = end_shuf;

end

count = 1;
for i = 1:length(list_complete)
	if list_complete(i,1) == 0
		list_named(i,1) = strcat(Unknown_Name, {' '}, num2str(count));
		count = count + 1;
	end
end

count = 1;
for i = 1:length(list_complete)
	if list_complete(i,1) == 1
		list_named(i,1) = strcat(Primary_Name, {' '}, num2str(count));
		count = count + 1;
	end
end

count = 1;
for i = 1:length(list_complete)
	if list_complete(i,1) == 2
		list_named(i,1) = strcat(Secondary_Name, {' '}, num2str(count));
		count = count + 1;
	end
end

count = 1;
for i = 1:length(list_complete)
	if list_complete(i,1) == 3
		list_named(i,1) = strcat(Tertiary_Name, {' '}, num2str(count));
		count = count + 1;
	end
end

set(H.uitable1,'Data',list_named)

pick = sort(list_complete);
unknown_beg = 1;
unknown_end = n;
primary_beg = min(find(pick==1));
primary_end = max(find(pick==1));
secondary_beg = min(find(pick==2));
secondary_end = max(find(pick==2));
if n_t > 0 && get(H.chk_T,'Value') == 1
	tertiary_beg = min(find(pick==3));
	tertiary_end = max(find(pick==3));
end

Range_U = strcat(num2str(unknown_beg),{' - '},num2str(unknown_end));
Range_P = strcat(num2str(primary_beg),{' - '},num2str(primary_end));
Range_S = strcat(num2str(secondary_beg),{' - '},num2str(secondary_end));
if n_t > 0 && get(H.chk_T,'Value') == 1
	Range_T = strcat(num2str(tertiary_beg),{' - '},num2str(tertiary_end));
end

set(H.range_U,'String',Range_U)
set(H.range_P,'String',Range_P)
set(H.range_S,'String',Range_S)
if n_t > 0 && get(H.chk_T,'Value') == 1
	set(H.range_T,'String',Range_T)
else
	set(H.range_T,'String','N/A')
end

if H.loaded == 1
	
	Unknowns = H.Names(1:n);
	Primaries_tmp = H.Names(primary_beg:primary_end);
	Secondaries_tmp = H.Names(secondary_beg:secondary_end);
	if n_t > 0 && get(H.chk_T,'Value') == 1
		Tertiaries_tmp = H.Names(tertiary_beg:tertiary_end);
	end
	
	if get(H.randomize,'Value') == 1
	
		[r_p c_p] = size(Primaries_tmp);
		shuffledRow_p = randperm(r_p);
		Primaries = Primaries_tmp(shuffledRow_p, :);

		[r_s c_s] = size(Secondaries_tmp);
		shuffledRow_s = randperm(r_s);
		Secondaries = Secondaries_tmp(shuffledRow_s, :);

		if n_t > 0 && get(H.chk_T,'Value') == 1
			[r_t c_t] = size(Tertiaries_tmp);
			shuffledRow_t = randperm(r_t);
			Tertiaries = Tertiaries_tmp(shuffledRow_t, :);
		end
		
	else
		
		Primaries = Primaries_tmp;
		Secondaries = Secondaries_tmp;
		if n_t > 1 && get(H.chk_T,'Value') == 1
			Tertiaries = Tertiaries_tmp;
		end
			
	end
	
	for i = 1:n_p 
		Primaries(i,1) = replaceBetween(Primaries(i,1),'Spot,"','",1,0,1,',char(strcat(Primary_Name, {' '}, num2str(i))));
	end
	
	for i = 1:n_s
		Secondaries(i,1) = replaceBetween(Secondaries(i,1),'Spot,"','",1,0,1,',char(strcat(Secondary_Name, {' '}, num2str(i))));
	end
	
	if n_t > 1 && get(H.chk_T,'Value') == 1
		for i = 1:n_t
			Tertiaries(i,1) = replaceBetween(Tertiaries(i,1),'Spot,"','",1,0,1,',char(strcat(Tertiary_Name, {' '}, num2str(i))));
		end
	end
	
	count = 1;
	for i = 1:length(list_complete)
		if list_complete(i,1) == 0
			list_OUT(i,1) = H.Names(count,1);
			count = count + 1;
		end
	end
	
	count = 1;
	for i = 1:length(list_complete)
		if list_complete(i,1) == 1
			list_OUT(i,1) = Primaries(count,1);
			count = count + 1;
		end
	end
	
	count = 1;
	for i = 1:length(list_complete)
		if list_complete(i,1) == 2
			list_OUT(i,1) = Secondaries(count,1);
			count = count + 1;
		end
	end
	
	if n_t > 0 && get(H.chk_T,'Value') == 1
		count = 1;
		for i = 1:length(list_complete)
			if list_complete(i,1) == 3
				list_OUT(i,1) = Tertiaries(count,1);
				count = count + 1;
			end
		end
	end
	
	set(H.uitable2,'Data',list_OUT)

	list_OUT(2:length(list_OUT)+1) = list_OUT;
	list_OUT(1,1) = H.input(1,1);

	H.list_OUT = list_OUT;
	guidata(hObject, H);
	
	set(H.n_U,'Enable','off')
	set(H.n_S,'Enable','off')
	set(H.n_T,'Enable','off')
	set(H.add_P,'Enable','off')
	set(H.add_S,'Enable','off')
	set(H.add_T,'Enable','off')
	
	
	
	
	
end

function savefile_Callback(hObject, eventdata, H)
if H.loaded == 1
	list_OUT = H.list_OUT;
	[file,path] = uiputfile('*.scancsv','Save file');
	dlmcell([path,file],list_OUT)
end

function deletecurrent_Callback(hObject, eventdata, H)
set(H.filepath,'String','')
set(H.uitable1,'Data',[])
set(H.uitable2,'Data',[])
clear H.input H.fullpathname H.Names
H.loaded = 0;
set(H.n_U,'Enable','on')
set(H.n_S,'Enable','on')
set(H.n_T,'Enable','on')
set(H.add_P,'Enable','on')
set(H.add_S,'Enable','on')
set(H.add_T,'Enable','on')
guidata(hObject, H);

function chk_T_Callback(hObject, eventdata, H)
if get(H.chk_T,'Value') == 1
	set(H.name_T,'Enable','on')
	set(H.n_T,'Enable','on')
	set(H.add_T,'Enable','on')
	set(H.range_T,'Enable','on')
end
if get(H.chk_T,'Value') == 0
	set(H.name_T,'Enable','off')
	set(H.n_T,'Enable','off')
	set(H.add_T,'Enable','off')
	set(H.range_T,'Enable','off')
end
run(hObject, eventdata, H)

function name_U_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function name_P_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function name_S_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function name_T_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function n_U_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function n_P_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function n_S_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function n_T_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function range_U_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function range_P_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function range_S_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function range_T_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function NA_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function add_P_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function add_S_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function add_T_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function randomize_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function shuffle_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)

function listbox1_Callback(hObject, eventdata, H)

function listbox2_Callback(hObject, eventdata, H)

function dlmcell(file,cell_array,varargin)
%% <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> %%
% <><><><><>     dlmcell - Write Cell Array to Text File      <><><><><> %
% <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> %
%                                                 Version:    01.06.2010 %
%                                                     (c) Roland Pfister %
%                                             roland_pfister@t-online.de %
%                        ...with many thanks to George Papazafeiropoulos %
%                        for his corrections and improvements.           %
% 1. Synopsis                                                            %
%                                                                        %
% A single cell array is written to an output file. Cells may consist of %
% any combination of (a) numbers, (b) letters, or (c) words. The inputs  %
% are as follows:                                                        %
%                                                                        %
%       - file       The output filename (string).                       %
%       - cell_array The cell array to be written.                       %
%       - delimiter  Delimiter symbol, e.g. ',' (optional;               %
%                    default: tab ('\t'}).                               %
%       - append     '-a' for appending the content to the               %
%                    output file (optional).                             %
%                                                                        %
% 2. Example                                                             %
%                                                                        %
%         mycell = {'Numbers', 'Letters', 'Words','More Words'; ...      %
%                    1, 'A', 'Apple', {'Apricot'}; ...                   %
%                    2, 'B', 'Banana', {'Blueberry'}; ...                %
%                    3, 'C', 'Cherry', {'Cranberry'}; };                 %
%         dlmcell('mytext.txt',mycell);                                  %
%                                                                        %
% <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> %
	

%% Check input arguments
if nargin < 2
    disp('Error - Give at least two input arguments!');
    return;
elseif nargin > 4
    disp('Error - Do not give more than 4 input arguments!');
    return;
end
if ~ischar(file)
    disp(['Error - File input has to be a string (e.g. ' ...
        char(39) 'output.txt' char(39) '!']);
    return;
end;
if ~iscell(cell_array)
    disp('Error - Input cell_array not of the type "cell"!');
    return;
end;
delimiter = '\t';
append = 'w';
if nargin > 2
    for i = 1:size(varargin,2)
        if strcmp('-a',varargin{1,i}) == 1
            append = 'a';
        else
            delimiter = varargin{1,i};
        end;
    end;
end

%% Open output file and prepare output array.
output_file = fopen(file,append);
output = cell(size(cell_array,1),size(cell_array,2));

%% Evaluate and write input array.
for i = 1:size(cell_array,1)
    for j = 1:size(cell_array,2)
        if numel(cell_array{i,j}) == 0
            output{i,j} = '';
            % Check whether the content of cell i,j is
            % numeric and convert numbers to strings.
        elseif isnumeric(cell_array{i,j}) || islogical(cell_array{i,j})
            output{i,j} = num2str(cell_array{i,j}(1,1));
            
            % Check whether the content of cell i,j is another cell (e.g. a
            % string of length > 1 that was stored as cell. If cell sizes
            % equal [1,1], convert numbers and char-cells to strings.
            %
            % Note that any other cells-within-the-cell will produce errors
            % or wrong results.
        elseif iscell(cell_array{i,j})
            if size(cell_array{i,j},1) == 1 && size(cell_array{i,j},1) == 1
                if isnumeric(cell_array{i,j}{1,1})
                    output{i,j} = num2str(cell_array{i,j}{1,1}(1,1));
                elseif ischar(cell_array{i,j}{1,1})
                    output{i,j} = cell_array{i,j}{1,1};
                end;
            end;
            
            % If the cell already contains a string, nothing has to be done.
        elseif ischar(cell_array{i,j})
            output{i,j} = cell_array{i,j};
        end;
        
        % Cell i,j is written to the output file. A delimiter is appended for
        % all but the last element of each row. At the end of a row, a newline
        % is written to the output file.
        if j < size(cell_array,2)
            fprintf(output_file,['%s',delimiter],output{i,j});
        else
            fprintf(output_file,'%s\r\n',output{i,j});
        end
    end;
end;

%% Close output file.
fclose(output_file);
