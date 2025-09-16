function perchlorates_prun_run(lines,ode_tolerance,max_steps,diagnostic,killall)
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

    arguments
        lines = -1
        ode_tolerance = 1e-1
        max_steps = 300 
        diagnostic = false
        killall = false
    end
    
    %kill all excels !
    if killall
        perchlorates_excel_kill()
    end
    
    
    %if no lines given, take them all
    if lines == -1
        simulations = perchlorates_prun_make();
    else
        simulations = perchlorates_prun_make(lines);
    end
    

    [c_aq_cs,c_aq_as,c_org_cs,c_org_as,n_stages] = perchlorates_prun_odes(simulations,diagnostic,ode_tolerance,max_steps);

    perchlorates_prun_export(c_aq_cs,c_aq_as,c_org_cs,c_org_as,n_stages)
end