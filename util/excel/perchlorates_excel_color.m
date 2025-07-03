function perchlorates_excel_color(cells, rgb, file_name,sheet_name,folder)
    % colorExcelCells colors Excel cells given a list and RGB color
    % 
    % Args:
    %   cells : cell array of Excel cell references (e.g., {'A1','B2'})
    %   rgb : 1x3 array of RGB values (e.g., [255, 0, 0] for red)
    %   file_name : char of file name
    %   folder : char of input or output folder
    %
    % see also sulfates_excel_index (index)
    % sulfates_p_export (called)
    
    % Get the path of the current function's file
    functionDir = fileparts(mfilename('fullpath'));  % Get the directory of this function
    % Define the relative path to the Excel file from the function directory
    file_path = fullfile(functionDir, '..', '..', folder, 'excel', file_name);

    % Start Excel application
    excel = actxserver('Excel.Application');
    excel.Visible = true;

    % Open or create workbook
    if ~isempty(file_path) && isfile(file_path)
        workbook = excel.Workbooks.Open(file_path);
    else
        workbook = excel.Workbooks.Add;
    end

    % Use the first sheet
    sheet = workbook.Sheets.Item(sheet_name);

    % Convert RGB to Excel color format
    R = rgb(1);
    G = rgb(2);
    B = rgb(3);
    colorValue = R + G*256 + B*256^2;

    % Color each cell
    for i = 1:length(cells)
        cellRef = cells{i};
        range = sheet.Range(cellRef);
        range.Interior.Color = colorValue;
    end

    % Save or prompt user to save
    if ~isempty(file_path)
        workbook.Save;
    else
        % Optional: Prompt or autosave to a temp path
        % workbook.SaveAs('C:\Path\To\Save\ColoredWorkbook.xlsx');
    end

    % Cleanup (optional to leave Excel open for viewing)
    workbook.Close(false);
    excel.Quit;
    delete(excel);
end
