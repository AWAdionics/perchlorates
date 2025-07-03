function entry = perchlorates_excel_read(file_name, sheet_name, rows, cols, number, output)
    %sulfates_excel_read reads a sulfates excel sheet
    %
    %   Args:
    %       file_name : char of filename (including extension!)
    %       sheet_name : char of sheet to read
    %       rows : array of integer rows
    %       cols : array of integer columns
    %       number : bool indicating if outputs should be ints/floats (default true)
    %       output : bool indicating if file is in input or in output (default false)
    %
    %
    %   see also sulfates_excel_index (index)
    %   sulfates_ms_make (called)
    %   sulfates_mss_make (called)
    %   sulfates_p_make (called)
    %   sulfates_p_export (called)

    if nargin < 5
        number = true;
        output = false;
    else
        if nargin < 6
            output = false;
        end
    end
    
    % Get the path of the current function's file
    functionDir = fileparts(mfilename('fullpath'));  % Get the directory of this function
    % Define the relative path to the Excel file from the function directory
    if output
        file_path = fullfile(functionDir, '..', '..', 'output', 'excel', file_name);
    else
        file_path = fullfile(functionDir, '..', '..', 'input', 'excel', file_name);
    end
    
    % Check if the provided file exists
    if ~isfile(file_path)
        error('The specified Excel file does not exist: %s', file_path);
    end
    
    % Read the data from the specified sheet
    data = readcell(file_path, 'Sheet', sheet_name);

    % Identify filled rows and columns
    filled_rows = any(~cellfun(@isempty, data), 2);
    filled_cols = any(~cellfun(@isempty, data), 1);
    
    % Get indices of non-empty rows and columns
    filled_rows_indices = find(filled_rows);
    filled_cols_indices = find(filled_cols);

    % Adjust the rows and cols to exclude empty cells
    valid_rows = intersect(rows, filled_rows_indices);
    valid_cols = intersect(cols, filled_cols_indices);

    % Extract only the filled rows and columns
    data = data(filled_rows, filled_cols);
    
    % Check if valid rows and cols are empty
    if isempty(valid_rows) || isempty(valid_cols)
        error('No valid entries in the specified rows and columns.');
    end
    
    % Get the value at the specified row and column
    if number
        entry = cell2mat(data(valid_rows, valid_cols));
    else
        entry = data(valid_rows, valid_cols);
    end
end
