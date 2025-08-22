function perchlorates_ms_iso(casename)
    %perchlorates_ms_iso given a casename runs and displays the simulated isotherme vs the experimental one
    %
    % to do so it minimizes perchlorates_org_eq and then plots the solutions 
    %
    % Args:
    %   casename : char of case name in input/excel (sulfates_ms_casename.xlsx)
    %
    % see also perchlorates_ms_index (index)
    % perchlorates_ms_make (used)
    % perchlorates_cclo4_eq_org (used)
    % perchlorates_ctoy (used)
    % perchlorates_ceq_aq (used)
    % pitzer_ms_gamma (external)
    % perchlorates_org_eq (called)
    % mvu_scatter (external)
    % perchlorates_mss_iso (sister)
    % perchlorates_palgo_eq (cousin)
    simulation = perchlorates_ms_make(casename);

    Kapp = simulation.input.Kapp;
    cation = simulation.input.cation;
    anion = simulation.input.anion;
    cc_ini = simulation.input.ini.(cation);
    cc_org_ini = cc_ini*mvu(0,'');
    ca_ini = simulation.input.ini.(anion);
    ca_org_ini = ca_ini*mvu(0,'');
    rho = simulation.constants.rho;
    OA = mvu(1,'');
    zc = mvu(ConstantsPitzer.charges.(cation),'');

    function error = objective(input,i)
        cc = mvu(input,'mmol/ L');
        ca = perchlorates_cclo4_eq_org(zc,cc);
        yc = perchlorates_ctoy(perchlorates_ceq_aq(cc,cc_ini(i),cc_org_ini(i),OA),rho(i));
        ya = perchlorates_ctoy(perchlorates_ceq_aq(ca,ca_ini(i),ca_org_ini(i),OA),rho(i));
        gamma = pitzer_ms_gamma(simulation,yc,ya,simulation.input.T(i)).value;
        gamma = mvu(gamma,'');
        raw_error = perchlorates_org_eq(cc,yc,ya,zc,Kapp(i),gamma);
        error = sulfates_mae(raw_error);
    end

    function [c, ceq] = constraint(input,i)
        cc = mvu(input,'mmol/ L');
        ca = perchlorates_cclo4_eq_org(zc,cc);
        cac = perchlorates_ceq_aq(cc,cc_ini(i),cc_org_ini(i),OA);
        caa = perchlorates_ceq_aq(ca,ca_ini(i),ca_org_ini(i),OA);
        c = -[cc.value,ca.value,cac.value,caa.value];     % Enforces: x > 0 ⇒ -x < 0
        ceq = [];   % No equality constraints
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
        'OutputFcn', @stop_func,'StepTolerance', 1e-13,'Algorithm', 'interior-point', ...
        'MaxFunctionEvaluations',1000, ...
        'OptimalityTolerance',1e-13);
    lb = 0;
    cc_org = mvu([],'mmol/ L');
    for i=1:length(cc_ini)
        [x_opt, fval_opt] = fmincon(@(x) objective(x,i),0,...
            [],[], [], [], lb, [],@(x) constraint(x,i), options);
        cc_org = [cc_org;mvu(x_opt,'mmol/ L')];
    end
    cc_aq = perchlorates_ceq_aq(cc_org,cc_ini,cc_org_ini,OA);

    ccs_org = [cc_org,simulation.input.orgeq.(cation)];
    ccs_aq = [cc_aq,simulation.input.aqeq.(cation)];

    mvu_scatter(ccs_aq,ccs_org,'Aqueous','Organic', ...
        ['Isothermes ',cation,' Monosels ',num2str(simulation.input.T.celsius.value(1)),' C'], ...
        {'trial','truth'})
    %lim([0,150])
end