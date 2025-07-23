classdef NamesPrunPerchlorates
    properties (Constant)
        extfeed_name = ' ext feed';
        regefeed_name = ' rege feed';
        extmass_name = 'masse volumique extraction';
        regemass_name = 'masse volumique regeneration';
        oa_ext_name = 'ext O/A';
        oa_rege_name = 'rege O/A';
        n_ext_name = 'extractions';
        temperature_ext_name = 'ext T';
        temperature_rege_name = 'rege T';
        ext_ak_name = 'ext ak';
        rege_ak_name = 'rege ak';
        max_row = 200
        max_col = 36
        test_name = 'perchlorates_process.xlsx'
        input_name = 'perchlorates_p_input.xlsx'
        input_sheet = 'p_input'
        output_name = 'perchlorates_p_output.xlsx'
        output_sheet = 'p_output'
        out_aq_name = ' aq'
        out_org_name = ' org'
        output_unit = 'mmol/ L'
    end
end