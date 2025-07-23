function perchlorates_prun_export(c_aq_cs,c_aq_as,c_org_cs,c_org_as,n_stages)
    %perchlorates_p_export exports results to excel
    %
    % also kills old excels and archives old output excel
    %
    % Args:
    %
    % see also 
    
    input_name = NamesPrunPerchlorates.input_name;
    input_sheet = NamesPrunPerchlorates.input_sheet;
    output_name = NamesPrunPerchlorates.output_name;
    output_sheet = NamesPrunPerchlorates.output_sheet;
    cations = ConstantsPerchlorates.cations_extracted;
    n_c = length(cations);
    anions = ConstantsPerchlorates.annions_extracted;
    n_a = length(anions);
    
    %kill the below
    perchlorates_excel_killthis(input_name,'input')
    perchlorates_excel_killthis(output_name,'output')
    
    %copy input into output
    perchlorates_excel_copy(input_name,input_sheet,'input',output_name,input_sheet,'output')

    
    %Write names of each ion,phase and stage in top row
    c_aq_names = {};
    a_aq_names = {};
    c_org_names = {};
    a_org_names = {};
    cells = {};
    cell2s = {};
    for i=1:n_stages
        for j=1:n_c
            ion = cations{j};
            c_aq_names{end+1} = [ion,' aq ',num2str(i)];
            c_org_names{end+1} = [ion,' org ',num2str(i)];
        end
        for j=1:n_a
            ion = anions{j};
            a_aq_names{end+1} = [ion,' aq ',num2str(i)];
            a_org_names{end+1} = [ion,' org ',num2str(i)];
        end
    end
    %find colord cells
    blue_cells = {};
    orange_cells = {};
    for i=1:n_stages*2*(n_c+n_a)
        cells{end+1} = [perchlorates_excel_col(i),num2str(1)];
        cell2s{end+1} = [perchlorates_excel_col(i),num2str(2)];
        if i <= n_stages*(n_c+n_a)
            %blue for aq
            blue_cells{end+1} = [perchlorates_excel_col(i),num2str(1)];
            blue_cells{end+1} = [perchlorates_excel_col(i),num2str(2)];
        else
            %orange for org
            orange_cells{end+1} = [perchlorates_excel_col(i),num2str(1)];
            orange_cells{end+1} = [perchlorates_excel_col(i),num2str(2)];
        end
    end
    %write names
    perchlorates_excel_writechar([c_aq_names,a_aq_names,c_org_names,a_org_names], cells,output_name,output_sheet)
    %color blue cells
    perchlorates_excel_color(blue_cells,[15,158,213],output_name,output_sheet,'output')
    %color orange
    perchlorates_excel_color(orange_cells,[233,113,50],output_name,output_sheet,'output')

    %Write output unit in second row
    output_unit = NamesPrunPerchlorates.output_unit;
    unit_names = repmat({output_unit}, 1, n_stages*4);
    perchlorates_excel_writechar(unit_names, cell2s,output_name,output_sheet)

    %Convert results to appropriate units c_aq_cs,c_aq_as,c_org_cs,c_org_as
    c_aq_cs = c_aq_cs.to(output_unit);
    c_aq_as = c_aq_as.to(output_unit);
    c_org_cs = c_org_cs.to(output_unit);
    c_org_as = c_org_as.to(output_unit);

    %Write results
    perchlorates_excel_writematrix(c_aq_cs.value,[perchlorates_excel_col(1),num2str(3)],output_name,output_sheet,true) %write in cations
    perchlorates_excel_writematrix(c_aq_as.value,[perchlorates_excel_col(n_stages*n_c+1),num2str(3)],output_name,output_sheet,true) %write in anions
    perchlorates_excel_writematrix(c_org_cs.value,[perchlorates_excel_col(n_stages*(n_c+n_a)+1),num2str(3)],output_name,output_sheet,true) %write in cations
    perchlorates_excel_writematrix(c_org_as.value,[perchlorates_excel_col(n_stages*(n_c+n_a)+n_stages*n_c+1),num2str(3)],output_name,output_sheet,true) %write in anions

    %archive results
    perchlorates_excel_archive(output_name,'output')
end