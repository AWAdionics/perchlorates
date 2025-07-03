function perchlorates_excel_killthis(file_name,folder)
    % closeExcelByPath opens and closes an Excel file by its full path
    %   
    %   The function opens the workbook if not already open, or activates
    %   it if already open, then closes it without saving.
    %
    %   Input:
    %       file_name : char of source filename (including extension!)
    %       folder : char of folder (input or output)
    %
    %   see also sulfates_excel_index (index)
    %   sulfates_p_export (called)

    % Get the path of the current function's file
    functionDir = fileparts(mfilename('fullpath'));  % Get the directory of this function
    % Define the relative path to the Excel file from the function directory
    file_path = fullfile(functionDir, '..', '..', folder, 'excel', file_name);

     % Attempt to connect to running Excel instance first
    try
        excel = actxGetRunningServer('Excel.Application');
        connectedToRunning = true;
    catch
        % No running Excel, create new instance
        excel = actxserver('Excel.Application');
        connectedToRunning = false;
        excel.Visible = false;
    end

    try
        % Look for workbook already open in this Excel instance
        wbToClose = [];
        for i = 1:excel.Workbooks.Count
            wb = excel.Workbooks.Item(i);
            if strcmpi(wb.FullName, file_path)
                wbToClose = wb;
                break;
            end
        end

        % If not open, open it
        if isempty(wbToClose)
            wbToClose = excel.Workbooks.Open(file_path);
        end

        % Close workbook without saving
        wbToClose.Close(false);

        % If we started Excel ourselves and no workbooks left, quit Excel
        if ~connectedToRunning && excel.Workbooks.Count == 0
            excel.Quit;
        end

    catch ME
        warning('Error processing file "%s": %s', file_path, ME.message);
    end

    % Clean up COM server reference only if we started Excel
    if connectedToRunning
        % Do not delete running Excel instance
    else
        delete(excel);
    end
end
