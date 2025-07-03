function perchlorates_excel_writematrix(matrix, top_right_cell, file_name, sheet_name,output)
    %sulfates_excel_writematrix writes a matrix of numbers into an excel
    %
    %   Args :
    %       matrix : matrix to write into excel
    %       top_right_cell : to right cell coordinate in "D3" format
    %       file_name : char of filename (including extension!)
    %       sheet_name : char of sheet to write into
    %       output : bool indicating if file is in input or in output (default false)
    %
    % see also sulfates_excel_index (index)
    % sulfates_p_export (called)
    
    if nargin < 5
        output = true;
    end
    % Convert Excel cell (e.g., "D3") to row and column indices
    [row, col] = excelCellToRowCol(top_right_cell);

    % Build the cell range for xlswrite
    top_left_cell = rowcolToExcelCell(row, col);

    % Get the path of the current function's file
    functionDir = fileparts(mfilename('fullpath'));  % Get the directory of this function
    % Define the relative path to the Excel file from the function directory
    if output
        file_path = fullfile(functionDir, '..', '..', 'output', 'excel', file_name);
    else
        file_path = fullfile(functionDir, '..', '..', 'input', 'excel', file_name);
    end

    % Write to Excel using writematrix
    writematrix(matrix, file_path, ...
        'Sheet', sheet_name, ...
        'Range', top_left_cell);
end

function [row, col] = excelCellToRowCol(cellStr)
    % Extract letters and numbers
    colStr = regexp(cellStr, '[A-Z]+', 'match', 'once');
    rowStr = regexp(cellStr, '\d+', 'match', 'once');

    % Convert column letters to number
    col = 0;
    for i = 1:length(colStr)
        col = col * 26 + (double(colStr(i)) - double('A') + 1);
    end
    row = str2double(rowStr);
end

function cellStr = rowcolToExcelCell(row, col)
    % Convert column number to letters
    letters = '';
    while col > 0
        rem = mod(col - 1, 26);
        letters = [char('A' + rem), letters];
        col = floor((col - 1) / 26);
    end
    cellStr = [letters, num2str(row)];
end
