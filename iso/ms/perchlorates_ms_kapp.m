function [kapp,err] = perchlorates_ms_kapp(casename)
    %perchlorates_ms_kapp used to compute an "optimized" monosels Kapp
    %
    %   solves perchlorates_org_eq given experimental values and finds Kapp
    %   which minimizes it
    %
    %   Args :
    %       casename : char of case name in input/excel (perchlorates_ms_casename.xlsx)
    %
    %   Returns : 
    %       kapp_opt : Optimized Kapp
    %       error_opt : error remaining at best Kapp
    %
    %   see also : perchlorates_ms_index (index)
    %   perchlorates_ms_make (used)
    %   perchlorates_yli_aq_eq (used)
    %   pitzer_ms_gamma (external)
    %   perchlorates_exa_eq_eq (used)
    %   mvu_mse (external)
    %   perchlorates_mss_kapp (sister)
    simulation = perchlorates_ms_make(casename);

    Kapp = simulation.input.Kapp;
    cation = simulation.input.cation;
    rho = simulation.constants.rho;
    zc = mvu(ConstantsPitzer.charges.(cation),'');
    cc = simulation.constants.orgeq_c;
    yc = perchlorates_ctoy(simulation.constants.aqeq_c,rho);
    ya = perchlorates_ctoy(simulation.constants.aqeq_a,rho);
    gamma = pitzer_ms_gamma(simulation,yc,ya,simulation.input.T);

    function error = objective(input)
        Kapp = mvu(input,'');
        raw_error = mvu([],'mmol/ L');
        for i=1:simulation.constants.n_pts
            raw_error = [raw_error;perchlorates_org_eq(cc(i),yc(i),ya(i),zc,Kapp,gamma(i))];
        end
        error = perchlorates_mse(raw_error);
    end


    function stop = stop_func(x, optimValues, state)
        stop = false;  % Default is not to stop
        if strcmp(state, 'iter')
            % Set a condition to stop immediately
            if optimValues.fval < 1e-9  % or any other custom condition
                disp('Terminating immediately as f(x) is small enough.');
                stop = true;  % Set stop to true to stop the optimization
            end
        end
    end

    options = optimoptions('fmincon', 'Display', 'iter', ...
        'OutputFcn', @stop_func,'StepTolerance', 1e-9,'Algorithm', 'interior-point', ...
        'MaxFunctionEvaluations',1000, ...
        'OptimalityTolerance',1e-9);
    lb = 0;
    [x_opt, fval_opt] = fmincon(@(x) objective(x),696.5799,...
        [],[], [], [], lb, [],[], options);
    kapp = mvu(x_opt,'');
    err = fval_opt;
end