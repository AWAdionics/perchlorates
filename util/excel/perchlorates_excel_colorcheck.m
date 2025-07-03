function is_match = perchlorates_excel_colorcheck(cells,rgb, file_name,sheet_name,folder)
    % colorcheck checks if all specified cells have the given RGB background color
    %
    % Args:
    %   cells: cell array of strings like {'B2','C3'}
    %   sheet_name: sheet name (e.g., 'Sheet1') or index (e.g., 1)
    %   rgb: 1x3 array of [R G B] (e.g., [255 0 0])
    %   file_path: full path to Excel workbook
    %
    % Output:
    %   is_match: true if all cells match the color, false otherwise
    %
    % see also sulfates_excel_index (index)
    % sulfates_p_export (called)

    % Get the path of the current function's file
    functionDir = fileparts(mfilename('fullpath'));  % Get the directory of this function
    % Define the relative path to the Excel file from the function directory
    file_path = fullfile(functionDir, '..', '..', folder, 'excel', file_name);

    % Open Excel
    excel = actxserver('Excel.Application');
    excel.Visible = false;

    try
        % Open workbook
        workbook = excel.Workbooks.Open(file_path);

        % Access sheet
        if ischar(sheet_name) || isstring(sheet_name)
            % Validate sheet by name
            sheet = [];
            for i = 1:workbook.Sheets.Count
                current = workbook.Sheets.Item(i);
                if strcmpi(current.Name, sheet_name)
                    sheet = current;
                    break;
                end
            end
            if isempty(sheet)
                error('Sheet "%s" not found.', sheet_name);
            end
        else
            sheet = workbook.Sheets.Item(sheet_name);
        end

        % Convert target RGB to Excel color value
        targetColor = rgb(1) + rgb(2)*256 + rgb(3)*256^2;

        % Loop through each cell
        is_match = true;
        for k = 1:length(cells)
            range = sheet.Range(cells{k});
            colorValue = range.Interior.Color;

            if isempty(colorValue)
                is_match = false;
                break;
            end

            % Compare raw value directly
            if colorValue ~= targetColor
                is_match = false;
                break;
            end
        end

        % Close workbook without saving
        workbook.Close(false);
    catch ME
        warning('Error checking Excel cells: %s', ME.message);
        is_match = false;
    end

    % Quit Excel
    excel.Quit;
    delete(excel);
end
