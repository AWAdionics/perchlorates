function perchlorates_excel_archive(file_name,folder)
    % archive copies an Excel file to a specified folder while dating it
    %
    % Usage:
    %   archive('file.xlsx', 'archive')
    %
    % Args:
    %   file_path : char of full path to the Excel file
    %   destinationFolder : char of path to the folder to copy into
    %
    % see also sulfates_excel_index (index)
    % sulfates_p_export (called)

    % Get the path of the current function's file
    functionDir = fileparts(mfilename('fullpath'));  % Get the directory of this function
    % Define the relative path to the Excel file from the function directory
    file_path = fullfile(functionDir, '..', '..', folder, 'excel', file_name);

    [year, month, day, hour, minute, second] = datevec(now);
    


    % Get filename and build destination path
    [~, baseName, ext] = fileparts(file_path);
    name = [num2str(year) '_' num2str(month) '_' num2str(day) '_' num2str(hour) '_' num2str(minute) '_' num2str(floor(second)) '_' baseName ext];
    archive_path = fullfile(functionDir, '..', '..', 'archive','excel', name);

    try
        copyfile(file_path, archive_path);
        fprintf('✅ File archived to: %s\n', archive_path);
    catch ME
        error('Failed to archive file: %s', ME.message);
    end
end
