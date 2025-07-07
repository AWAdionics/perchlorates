classdef NamesMssPerchlorates
    properties (Constant)
        excel_name = 'perchlorates_mss'
        aqini_name = ' aq ini';
        orgini_name = ' org ini';
        aqeq_name = ' aq eq';
        orgeq_name = ' org eq';
        mass_name = 'Masse Volumique'
        kapp_name = ' Kapp'
        OA_name = 'O/A'
        temperature_name = 'T'
        cations_extracted = {'Li','Ca','Mg'}
        anions_extracted = {'ClO4'}
        cations = {'Li','Ca','Mg' ... %Extracted
                   ,'Na','K'}         %Not Extracted
        anions = {'ClO4',...          %Extracted
                  'Cl','NO3','SO4'}     %Not Extracted
        max_row = 9
        max_col = 33
    end
end