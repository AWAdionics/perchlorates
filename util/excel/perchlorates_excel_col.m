function col_letter = perchlorates_excel_col(n)
    %sulfates_excel_col converts column number to column letter
    %
    %   Args:
    %       n : integer of column number
    %
    %   see also sulfates_excel_index (index)
    %   sulfates_p_export (called)

    % Validate input
    if ~isscalar(n) || n < 1 || n ~= floor(n)
        error('Input must be a positive integer.');
    end

    % Initialize
    col_letter = '';
    
    while n > 0
        r = mod(n - 1, 26);
        col_letter = [char(r + 'A'), col_letter];
        n = floor((n - 1) / 26);
    end
end
