function perchlorates_excel_clearsheet(file_name, sheet_name)
    % Clears all contents from a specific sheet in an Excel file

    % Check file existence
    if ~isfile(file_name)
        error('File "%s" does not exist.', file_name);
    end

    % Start Excel COM server
    Excel = actxserver('Excel.Application');
    Excel.DisplayAlerts = false;  % Suppress overwrite prompts

    try
        % Open the workbook
        Workbook = Excel.Workbooks.Open(fullfile(pwd, file_name));
        
        % Try to access the sheet
        try
            Sheet = Workbook.Sheets.Item(sheet_name);
        catch
            error('Sheet "%s" not found in "%s".', sheet_name, file_name);
        end

        % Clear the sheet's contents
        Sheet.Cells.Clear;

        % Save and close
        Workbook.Save();
        Workbook.Close();
        Excel.Quit();
        delete(Excel);  % Release COM server

        fprintf('Sheet "%s" cleared in file "%s".\n', sheet_name, file_name);
    catch ME
        Excel.Quit();
        delete(Excel);
        rethrow(ME);
    end
end
