function perchlorates_excel_copy(source_file, source_sheet, source_folder, ...
                             target_file, target_sheet, target_folder)
    %sulfates_excel_copy copies a source sheet to a target excel
    %
    %   Args:
    %       source_file : char of source filename (including extension!)
    %       source_sheet : char of source sheet to copy
    %       source_folder : char of folder (input or output)
    %       target_file : char of target filename (including extension!)
    %       target_sheet : char of sheet into which we copy source
    %       target_folder : char of folder (input or output)
    %
    % see also sulfates_excel_index (index)
    % sulfates_p_export (called)

    % Launch Excel
    excel = actxserver('Excel.Application');
    excel.DisplayAlerts = false;  % Suppress alerts like overwrite prompts

    % Get the path of the current function
    functionDir = fileparts(mfilename('fullpath'));

    % Construct full paths to source and target workbooks
    source_path = fullfile(functionDir, '..', '..', source_folder, 'excel', source_file);
    target_path = fullfile(functionDir, '..', '..', target_folder, 'excel', target_file);

    % Open source and target workbooks
    wbSource = excel.Workbooks.Open(source_path);
    wbTarget = excel.Workbooks.Open(target_path);

    try
        % Get the sheet from the source file
        sheetSource = wbSource.Sheets.Item(source_sheet);
    catch
        wbSource.Close(false);
        wbTarget.Close(false);
        excel.Quit;
        error("Source sheet '%s' not found in file '%s'.", source_sheet, source_file);
    end

    % Copy the source sheet into the target workbook (after the last sheet)
    sheetSource.Copy([], wbTarget.Sheets.Item(wbTarget.Sheets.Count));

    % Rename the newly copied sheet
    newSheet = wbTarget.Sheets.Item(wbTarget.Sheets.Count);
    
    % If a sheet with the target name already exists, delete it
    try
        existingSheet = wbTarget.Sheets.Item(target_sheet);
        existingSheet.Delete;
    catch
        % No sheet with that name — no deletion needed
    end

    newSheet.Name = target_sheet;

    % Save and close
    wbTarget.Save;
    wbSource.Close(false);
    wbTarget.Close(false);
    excel.Quit;

    % Clean up
    delete(excel);
end
