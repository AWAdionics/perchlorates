function perchlorates_excel_writechar(char_cell_array, cells, file_name, sheet_name,output)
    %sulfates_excel_writechar writes an array of chars into an excel
    %
    %   Args :
    %       char_cell_array : cell array of chars to write into excel
    %       cells : cell array of cell coordinates in 'A2' format
    %       file_name : char of filename (including extension!)
    %       sheet_name : char of sheet to write into
    %       output : bool indicating if file is in input or in output (default false)
    %
    % see also sulfates_excel_index (index)
    % sulfates_p_export (called)

    if nargin < 5
        output = true;
    end

    % Get the path of the current function's file
    functionDir = fileparts(mfilename('fullpath'));  % Get the directory of this function
    % Define the relative path to the Excel file from the function directory
    if output
        file_path = fullfile(functionDir, '..', '..', 'output', 'excel', file_name);
    else
        file_path = fullfile(functionDir, '..', '..', 'input', 'excel', file_name);
    end


    % Validate inputs
    if length(char_cell_array) ~= length(cells)
        error('char_cell_array and cells must be the same length.');
    end

    % Launch Excel
    excel = actxserver('Excel.Application');
    excel.DisplayAlerts = false;  % Prevent prompts

    % Open or create the workbook
    if isfile(file_path)
        wb = excel.Workbooks.Open(file_path);
    else
        wb = excel.Workbooks.Add;
        wb.SaveAs(file_path);
    end

    % Check if sheet exists, else add it
    try
        sheet = wb.Sheets.Item(sheet_name);
    catch
        sheet = wb.Sheets.Add([], wb.Sheets.Item(wb.Sheets.Count));
        sheet.Name = sheet_name;
    end

    % Write each character string to its target cell
    for i = 1:length(cells)
        sheet.Range(cells{i}).Value = char_cell_array{i};
    end

    % Save and close
    wb.Save;
    wb.Close(false);
    excel.Quit;

    % Clean up
    delete(excel);
end
