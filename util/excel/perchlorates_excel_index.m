function perchlorates_excel_index()
    %sulfates_excel_index index of excel handles in sulfates module
    %
    % Excels are organized into 3 folders:
    %   - archive/excel/* -> for archives of past runs
    %   - input/excel/* -> for input files
    %   - output/excel/* -> for output files
    %
    % some functions have a binary check for if they are input or output 
    % (archive is specific to only archive), others will require user to
    % specify one of the three above ('archive','input','output') when it 
    % asks for the excel folder
    %   
    % Writers
    %   - sulfates_excel_color (colors cells)
    %   - sulfates_excel_writechar (for writing chars into excel)
    %   - sulfates_excel_writematrix (for writing numerical matrices into excel)
    %
    % Readers
    %   - sulfates_read (generic excel reader)
    %   - sulfates_colorcheck (used in debugging and testing, checks cell colors)
    %
    % Copiers
    %   - sulfates_excel_copy (copies an excel sheet)
    %   - sulfates_excel_archive (copies an entire excel and archives it)
    %
    % Killers
    %   - sulfates_kill (kills all excels)
    %   - sulfates_kill_this (looks for specific excel and kills it)
    %
    % see also sulfates_index (index)
    % TestSulfatesUtil (tests)
end