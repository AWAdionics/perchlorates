function perchlorates_excel_clearsheet(folder, file_name, sheet_name)
    % Clears all contents from a specific sheet in an Excel file
    
    % Get the path of the current function's file
    functionDir = fileparts(mfilename('fullpath'));  % Get the directory of this function
    % Define the relative path to the Excel file from the function directory
    file_path = fullfile(functionDir, '..', '..', folder, 'excel', file_name);

    % Check file existence
    if ~isfile(file_path)
        error('File "%s" does not exist.', file_path);
    end

    % Start Excel COM server
    Excel = actxserver('Excel.Application');
    Excel.DisplayAlerts = false;  % Suppress overwrite prompts

    try
        % Open the workbook
        Workbook = Excel.Workbooks.Open(file_path);
        
        % Try to access the sheet
        try
            Sheet = Workbook.Sheets.Item(sheet_name);
        catch
            error('Sheet "%s" not found in "%s".', sheet_name, file_path);
        end

        % Clear the sheet's contents
        Sheet.Cells.Clear;

        % Save and close
        Workbook.Save();
        Workbook.Close();
        Excel.Quit();
        delete(Excel);  % Release COM server

        fprintf('Sheet "%s" cleared in file "%s".\n', sheet_name, file_path);
    catch ME
        Excel.Quit();
        delete(Excel);
        rethrow(ME);
    end
end
