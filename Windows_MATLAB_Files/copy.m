% COPY puts a string, cell array, or numerical array into the clipboard,
% from where it can easily be imported by other programs.
%
% Usage:
%   copy(x)
%   copy(...,dec,sep,lf)
%
% x can be a numerical array (one or two dimensional), a cell array, a
% string, or a handle to a figure. The program does not handle other
% variable classes, such as struct etc. and also is not suitable for arrays
% with more than two dimensions.
%
% Optional arguments:
%   dec   Single character that indicates the decimal separator. Default is
%         the period ('.').
%   sep   Single character that indicates how horizontal neigbors of a
%         matrix or cell array are separated. Default is the tabulator code
%         (char 9).
%   lf    Single character that indicates how rows are separated. (lf
%         stands for line feed). Default is the line feed code (char 10).
%
% Examples:
%   copy('One small step for a man.')  pushes just this string to the
%                                      clipboard.
%   copy([1.2,-500])         pushes '1.2 -> -500' to the clipboard
%                            (-> is the tabulator code).
%   copy([1.2,-500],',','&') pushes '1,2 & -500' to the clipboard.
%   f = figure; surf(membrane); copy(f) copies the figure to the clipboard.
%
% Note: This program was inspired by NUM2CLIP on the Mathworks file
% exchange, see http://www.mathworks.com/matlabcentral/fileexchange/8472
%
% This program was selected 'Pick of the Week' on March 7, 2014. :-)
%
% Author : Yvan Lengwiler
% Release: 1.52
% Date   : 2014-11-30
%
% See also PASTE, CLIPBOARD, HGEXPORT

% History:
% 2010-06-25    First version.
% 2010-07-10    Now also covers multiline character arrays.
% 2011-06-05    Using strrep instead of regexprep.
% 2011-06-22    Special treatment of empty cells (Thank you, Joseph Burgel).
% 2013-03-19    Added dec, sep, and lf options.
% 2014-02-20    Support for tables (ML R2013b), suggested by Greg.
% 2014-02-21    Support for logical variables. Also, two small bug fixes.
% 2014-03-19    Bug fix, thanks to Soren Preus.
% 2014-11-30    Support for copying figures.

function copy(x,dec,sep,lf)
    % *** separators *****************************************************
    if nargin < 4
        lf = char(10);  % default is line feed (char 10)
    end
    if nargin < 3
        sep = char(9);  % default is tabulator (char 9)
    end
    if nargin < 2
        dec = '.';      % default is a period '.'
    end
    % *** figure *********************************************************
    if ishghandle(x,'figure');
        if nargin > 1
            warning('COPY:unused_parameters', ...
                ['Object is a figure, ignoring all parameters after ', ...
                    'the first one.']);
        end
        hgexport(x,'-clipboard');
    % *** string argument ************************************************
    elseif isa(x,'char')
        [r,c] = size(x);
        if r == 1                   % not a multi-line character array ...
            clipboard('copy',x);    % ... so just push the string into the
                                    %     clipboard
        else
            x = [x, repmat(lf,r,1)];        % append linefeed to each line
            x = reshape(x',1,r*(c+1));      % make it a single line
            clipboard('copy',x);            % push this to the clipboard
        end
    % *** numeric argument ***********************************************
    elseif isa(x,'numeric') || isa(x,'logical')
        s = mat2str(x);                 % write as [.. .. ..;.. .. ..]
        s = strrep(s,'.',dec);          % replace decimal separators
        if s(1)=='['                    % it's a proper array
            s = s(2:end-1);             % remove '[' and ']'
        end
        s = strrep(s,' ',sep);          % replace spaces with tabs
        s = strrep(s,';',lf);           % replace semicolons with linefeeds
        s(end+1) = lf;                  % append a linefeed
        clipboard('copy',s);            % place resulting string in clipboard
    % *** cell argument **************************************************
    elseif isa(x,'cell')
        [nrow, ncol] = size(x);
        str = '';
        for r = 1:nrow
            for c = 1:ncol-1
                str = onecell(str, x{r,c}, sep, dec);  % treat cell, append a tab
            end
            str = onecell(str, x{r,end}, lf, dec);     % treat cell, append a linefeed
        end
        clipboard('copy',str);          % copy to clipboard
    % *** table (This is Greg's contribution. Thank you, Greg!) **********
    elseif isa(x,'table')   % table is a feature of R2013b
        if nargin > 1
            warning('COPY:unused_parameters', ...
                'Object is a table, ignoring all parameters after the first one.');
        end
        xheaders = x.Properties.VariableNames;
        xrownames = x.Properties.RowNames;
        xdescr = {x.Properties.Description};
        xt = table2cell(x);
        if ~isempty(xt)     % it's an empty table
            if isempty(xrownames)
                xrownames = repmat({''},height(x),1);
            end
            xt = [xdescr,xheaders;xrownames,xt];
            if isempty(cat(2,xt{:,1}))
                xt(:,1) = [];
            end
        end
        copy(xt);   % recursive call of copy.m
    % *** anything else **************************************************
    else
        warning('COPY:unsupported_content', ...
            'Cannot copy this kind of object.');
    end

% *** convert one cell into a string; append it to str and append a special
%     character (ch = tab or linefeed)
function str = onecell(str,e,ch,dec)
    if isempty(e)
        str = [str, ch];            % copy nothing if cell is empty
    elseif isa(e,'char')
        if size(e,1) == 1           % not a multi-line char array?
            str = [str, e, ch];
        else
            str = [str, mat2str(e), ch];
        end
    elseif isa(e,'numeric') || isa(e,'logical')
        str = [str, strrep(mat2str(e),'.',dec), ch];
    else
        str = [str, '(cannot copy component)', ch];
    end
