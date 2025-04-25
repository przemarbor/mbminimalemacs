 
r2d = @(rad) 180*rad/pi ;
% postac algebraiczna na wykladnicza (radiany)
zExpR = @(Z) ([num2str(abs(Z)) '\cdot e^{' num2str(arg(Z))  'j}' ]) ;
% postac algebraiczna na wykladnicza (stopnie)
zExpD = @(Z) ([num2str(abs(Z)) '\cdot e^{' num2str( r2d( arg(Z)) )  '^\circ j}' ]) ;

% postaci czasowe: radiany
zTimR = @(Z) ([num2str(abs(Z)) '\sin (' num2str(arg(Z))  't)' ]) ;
  % stopnie
zTimD = @(Z) ([num2str(abs(Z)) '\sin (' num2str(r2d(arg(Z)))  '^\circ t)' ]) ;

nstr  = @(s) disp(s) ;
mstr  = @(s) disp( ['$',s,'$']) ;
nl = @() disp(['\newline']) ;


function [S] = mat2lat(A)
    S = strrep(strrep(mat2str(A)," "," & "),";","\\\\")(2:end-1) ;
    S = ['\left[\begin{matrix}' S '\end{matrix}\right]'] ;
end



function [S] = matrix2latexS(matrix, varargin)

% Modification of the M. Koehler's matrix2latex function.
    
% function: matrix2latex(...)
% Author:   M. Koehler
% Contact:  koehler@in.tum.de
% Version:  1.1
% Date:     May 09, 2004

% This software is published under the GNU GPL, by the free software
% foundation. For further reading see: http://www.gnu.org/licenses/licenses.html#GPL

% Usage:
% matrix2late(matrix, filename, varargs)
% where
%   - matrix is a 2 dimensional numerical or cell array
%   - filename is a valid filename, in which the resulting latex code will
%   be stored
%   - varargs is one ore more of the following (denominator, value) combinations
%      + 'rowLabels', array -> Can be used to label the rows of the
%      resulting latex table
%      + 'columnLabels', array -> Can be used to label the columns of the
%      resulting latex table
%      + 'alignment', 'value' -> Can be used to specify the alginment of
%      the table within the latex document. Valid arguments are: 'l', 'c',
%      and 'r' for left, center, and right, respectively
%      + 'format', 'value' -> Can be used to format the input data. 'value'
%      has to be a valid format string, similar to the ones used in
%      fprintf('format', value);
%      + 'size', 'value' -> One of latex' recognized font-sizes, e.g. tiny,
%      HUGE, Large, large, LARGE, etc.
%
% Example input:
%   matrix = [1.5 1.764; 3.523 0.2];
%   rowLabels = {'row 1', 'row 2'};
%   columnLabels = {'col 1', 'col 2'};
%   matrix2latex(matrix, 'out.tex', 'rowLabels', rowLabels, 'columnLabels', columnLabels, 'alignment', 'c', 'format', '%-6.2f', 'size', 'tiny');
%
% The resulting latex file can be included into any latex document by:
% /input{out.tex}
%
% Enjoy life!!!

    rowLabels = [];
    colLabels = [];
    alignment = 'l';
    format = [];
    textsize = [];

    % if (nargin < 1)
    %     error(['matrix2latexS: ', 'Incorrect number of arguments.']);
    % end
    
    if (rem(nargin,2) == 0 || nargin < 1)
        error('matrix2latexS: ', 'Incorrect number of arguments to %s.', mfilename);
    end

    okargs = {'rowlabels','columnlabels', 'alignment', 'format', 'size'};
    nargin
    varargin
    for j=1:2:(nargin-2)
        j
        pname = varargin{j}
        pval = varargin{j+1};
        k = strmatch(lower(pname), okargs);
        if isempty(k)
            error('matrix2latexS: ', 'Unknown parameter name: %s.', pname);
        elseif length(k)>1
            error('matrix2latexS: ', 'Ambiguous parameter name: %s.', pname);
        else
            switch(k)
                case 1  % rowlabels
                    rowLabels = pval;
                    if isnumeric(rowLabels)
                        rowLabels = cellstr(num2str(rowLabels(:)));
                    end
                case 2  % column labels
                    colLabels = pval;
                    if isnumeric(colLabels)
                        colLabels = cellstr(num2str(colLabels(:)));
                    end
                case 3  % alignment
                    alignment = lower(pval);
                    if alignment == 'right'
                        alignment = 'r';
                    end
                    if alignment == 'left'
                        alignment = 'l';
                    end
                    if alignment == 'center'
                        alignment = 'c';
                    end
                    if alignment ~= 'l' && alignment ~= 'c' && alignment ~= 'r'
                        alignment = 'l';
                        warning('matrix2latexS: ', 'Unkown alignment. (Set it to \''left\''.)');
                    end
                case 4  % format
                    format = lower(pval);
                case 5  % format
                    textsize = pval;
            end
        end
    end

    S = [''] ; %fid = fopen(filename, 'w');
    
    width = size(matrix, 2);
    height = size(matrix, 1);

    if isnumeric(matrix)
        matrix = num2cell(matrix);
        for h=1:height
            for w=1:width
                if(~isempty(format))
                    matrix{h, w} = num2str(matrix{h, w}, format);
                else
                    matrix{h, w} = num2str(matrix{h, w});
                end
            end
        end
    end
    
    if(~isempty(textsize))
        S = [S sprintf('\\begin{%s}', textsize) ] ; % fprintf(fid, '\\begin{%s}', textsize);
    end

    vline = '' ;
    S = [S sprintf(['\\begin{tabular}{' vline] ) ] ;  %fprintf(fid, '\\begin{tabular}{|');

    if(~isempty(rowLabels))
        S = [S sprintf(['l' vline])] ; % fprintf(fid, 'l|');
    end
    for i=1:width
        S = [S sprintf('%c', alignment) vline]; % fprintf(fid, '%c|', alignment);
    end
    S = [S sprintf('}\\r\\n')]; % fprintf(fid, '}\r\n');
    
    S = [S sprintf('\\hline\\r\\n')]; % fprintf(fid, '\\hline\r\n');
    
    if(~isempty(colLabels))
        if(~isempty(rowLabels))
            S = [S sprintf(' & ')]; % fprintf(fid, '&');
        end
        for w=1:width-1
            S = [S sprintf('\\textbf{%s} & ', colLabels{w})]; % fprintf(fid, '\\textbf{%s}&', colLabels{w});
        end
        S = [S sprintf('\\textbf{%s}\\\\ \\hline\\r\\n', colLabels{width})]; % fprintf(fid, '\\textbf{%s}\\\\\\hline\r\n', colLabels{width});
    end
    
    for h=1:height
        if(~isempty(rowLabels))
            S = [S sprintf('\\textbf{%s} & ', rowLabels{h})]; % fprintf(fid, '\\textbf{%s}&', rowLabels{h});
        end
        for w=1:width-1
            S = [S sprintf('%s & ', matrix{h, w})]; % fprintf(fid, '%s&', matrix{h, w});
        end
        S = [S sprintf('%s\\\\ \\hline\\r\\n', matrix{h, width})]; % fprintf(fid, '%s\\\\\\hline\r\n', matrix{h, width});
    end

    S = [S sprintf('\\end{tabular}\\r\\n')]; % fprintf(fid, '\\end{tabular}\r\n');
    
    if(~isempty(textsize))
        S = [S sprintf('\\end{%s}', textsize)]; % fprintf(fid, '\\end{%s}', textsize);
    end

    % fclose(fid);
    
end

