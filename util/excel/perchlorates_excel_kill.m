function perchlorates_excel_kill()
    % killExcelWithPrompt prompts before killing all Excel (EXCEL.EXE) processes
    %
    % Usage:
    %   killExcelWithPrompt()
    %
    % see also sulfates_excel_index (index)
    % sulfates_p_run (called)

    % GUI prompt
    choice = questdlg('Do you want to kill all Excel processes?', ...
                      'Confirm Excel Termination', ...
                      'Yes', 'No', 'No');

    switch choice
        case 'Yes'
            [status, result] = system('taskkill /f /im excel.exe');
            if status == 0
                disp('✅ All Excel processes were terminated.');
            else
                fprintf('⚠️ Failed to kill Excel processes:\n%s\n', result);
            end
        case 'No'
            disp('❎ Operation canceled. Excel processes remain running.');
    end
end
