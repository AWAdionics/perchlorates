function perchlorates_prun_run(step_size,end_time,killall,lines)
    %sulfates_p_run runs the simulation 
    % 
    % takes from input/excel/sulfates_p_input and puts results into 
    % output/excel/sulfates_p_output
    %
    %   Args :
    %       step_size : algorithm maximum step size
    %       end_time : final time
    %       killall : kills all excel (default False)
    %       lines : lines to run (default all)
    %   
    %   see also 
    
    %default
    if nargin < 3
        killall = false;
    end
    
    %kill all excels !
    if killall
        perchlorates_excel_kill()
    end
    
    
    %if no lines given, take them all
    if nargin < 4
        simulations = perchlorates_prun_make();
    else
        simulations = perchlorates_prun_make(lines);
    end
    

    [c_aq_cs,c_aq_as,c_org_cs,c_org_as,n_stages] = perchlorates_prun_odes(simulations,step_size,end_time);

    perchlorates_prun_export(c_aq_cs,c_aq_as,c_org_cs,c_org_as,n_stages)
end