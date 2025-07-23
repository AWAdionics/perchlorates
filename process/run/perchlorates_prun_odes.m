function [c_aq_c_ends,c_aq_a_ends,c_org_c_ends,c_org_a_ends,n] = perchlorates_prun_odes(simulations,step_size,end_time)
    %sulfates_p_odes runs all ode simulations
    %
    % Simple function that executes a bunch of sulfates_p_ode and stiches
    % the results together.
    %
    %   Args:
    %       simulations : array of simulations structs
    %       step_size : algorithm maximum step size
    %       end_time : final time
    %
    %   Returns:
    %       c_aq_c_ends : mvu in mmol/L of extracted cations in aqueous phase at each stage at end time
    %       c_aq_a_ends : mvu in mmol/L of extracted anions in aqueous phase at each stage at end time
    %       c_org_c_ends : mvu in mmol/L of extracted cations in organic phase at each stage at end time
    %       c_org_a_ends : mvu in mmol/L of extracted anions in organic phase at each stage at end time
    %       n : total number of stages
    %
    %   see also 
    c_aq_c_ends = mvu([],'mmol/ L');
    c_aq_a_ends = mvu([],'mmol/ L');
    c_org_c_ends = mvu([],'mmol/ L');
    c_org_a_ends = mvu([],'mmol/ L');
    n = 1;
    for i =1:length(simulations)
        n = max(n,simulations(i).input.n_ext);
    end
    n=n+3;
    for i =1:length(simulations)
        [c_aq_c_end,c_aq_a_end,c_org_c_end,c_org_a_end] = ...
                    perchlorates_palgo_ode(simulation,step_size,end_time);
        k = simulations(i).input.n_ext;
        c_aq_c_ends = [c_aq_c_ends;perchlorates_prun_pad(c_aq_c_end,n,k)];
        c_aq_a_ends = [c_aq_a_ends;perchlorates_prun_pad(c_aq_a_end,n,k)];
        c_org_c_ends = [c_org_c_ends;perchlorates_prun_pad(c_org_c_end,n,k)];
        c_org_a_ends = [c_org_a_ends;perchlorates_prun_pad(c_org_a_end,n,k)];
    end
end