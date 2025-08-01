function perchlorates_mss_iso(casename)
    %perchlorates_ms_iso given a casename runs and displays the simulated isotherme vs the experimental one
    %
    % to do so it minimizes sulfates_exa_eq_eq and then plots the solutions 
    %
    % Args:
    %   casename : char of case name in input/excel (perchlorates_mss_casename.xlsx)
    %
    % see also 
    arguments (Input)
        casename char
    end
    simulation = perchlorates_mss_make(casename);

    Kapp = simulation.constants.Kapp;
    feed_aq_c = simulation.constants.feed_aq_c.to('mmol/ L');
    feed_aq_a = simulation.constants.feed_aq_a.to('mmol/ L');
    feed_org_c = simulation.constants.feed_org_c.to('mmol/ L');
    feed_org_a = simulation.constants.feed_org_a.to('mmol/ L');
    cations = simulation.constants.cations_extracted;
    anions = simulation.constants.anions_extracted;
    rho = simulation.constants.rho;
    OA = simulation.constants.OA;
    zc = simulation.constants.zc;
    extracted_cations = 1:length(cations);
    extracted_anions = [1];
    fyc = perchlorates_ctoy(feed_aq_c,rho);
    fyc = fyc.to('mmol/kg_eau');
    fya = perchlorates_ctoy(feed_aq_a,rho);
    fya = fya.to('mmol/kg_eau');

    gamma = pitzer_mss_gamma(simulation,fyc(:,1),fya(:,1),simulation.input.T(1), ...
                                 extracted_cations,extracted_anions);

    function error = objective(input,i)
        cc = mvu(input,'mmol/ L');
        ca = perchlorates_cclo4_eq_org(zc,cc);
        yc = perchlorates_ctoy(perchlorates_ceq_aq( ...
            cc,feed_aq_c(extracted_cations,i),feed_org_c(extracted_cations,i),OA(i)),rho(i));
        ya = perchlorates_ctoy(perchlorates_ceq_aq( ...
            ca,feed_aq_a(extracted_anions,i),feed_org_a(extracted_anions,i),OA(i)),rho(i));
        fyc(extracted_cations,i) = yc;
        fya(extracted_anions,i) = ya;
        gamma = pitzer_mss_gamma(simulation,fyc(:,i),fya(:,i),simulation.input.T(i), ...
                                 extracted_cations,extracted_anions);
        raw_error = perchlorates_org_eq(cc,yc,ya,zc,Kapp(:,i),gamma);
        error = sulfates_mae(raw_error);
    end

    function [c, ceq] = constraint(input,i)
        cc = mvu(input,'mmol/ L');
        ca = perchlorates_cclo4_eq_org(zc,cc);
        cac = perchlorates_ceq_aq(cc,feed_aq_c(extracted_cations,i), ...
            feed_org_c(extracted_cations,i),OA(i));
        caa = perchlorates_ceq_aq(ca,feed_aq_a(extracted_anions,i), ...
            feed_org_a(extracted_anions,i),OA(i));
        c = -[cc.value',ca.value,cac.value',caa.value];     % Enforces: x > 0 ⇒ -x < 0
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
        'OutputFcn', @stop_func,'StepTolerance', 1e-16,'Algorithm', 'interior-point', ...
        'MaxFunctionEvaluations',1000, ...
        'OptimalityTolerance',1e-16);
    lb = [0,0,0];
    cc_org = mvu([],'mmol/ L');
    for i=1:length(feed_org_c(:,1))
        input = mvu([],'mmol/ L');
        for j=1:length(cations)
            cation = cations{j};
            cat = simulation.input.orgeq.(cation);
            input = [input;cat(i)];
        end
        %input = feed_org_c(extracted_cations,i);
        [x_opt, fval_opt] = fmincon(@(x) objective(x,i),input.value,...
            [],[], [], [], lb, [],@(x) constraint(x,i), options);
        cc_org = [cc_org,mvu(x_opt,'mmol/ L')];
    end
    cc_aq = perchlorates_ceq_aq(cc_org,feed_aq_c(extracted_cations,:),feed_org_c(extracted_cations,:),OA);
    ca_org = perchlorates_cclo4_eq_org(zc,cc_org);
    ca_aq = perchlorates_ceq_aq(ca_org,feed_aq_a(extracted_anions,:),feed_org_a(extracted_anions,:),OA);
    
    for i=1:length(cations)
        ion = cations{i};
        ccs_org = [cc_org(i,:)',simulation.input.orgeq.(ion)];
        ccs_aq = [cc_aq(i,:)',simulation.input.aqeq.(ion)];
    
        mvu_scatter(ccs_aq,ccs_org,'Aqueous','Organic', ...
            ['Isothermes ',ion,' Multisels ',num2str(simulation.input.T.celsius.value(1)),' C'], ...
            {'trial','truth'})

        if simulation.input.T.celsius.value(1) <= 60
            switch ion
                case 'Li'
                   ylim([0 50]);
                   xlim([40 49]);
                case 'Ca'
                   ylim([0 50]);
                   xlim([3 5.5]);
                case 'Mg'
                   ylim([0 50]);
                   xlim([1000 1250]);
            end
        else
             switch ion
                case 'Li'
                   ylim([0 50]);
                   xlim([0 120]);
                case 'Ca'
                   ylim([0 50]);
                   xlim([0 6]);
                case 'Mg'
                   ylim([0 50]);
                   xlim([0 300]);
             end
        end
    end

    for i=1:length(anions)
        ion = anions{i};
        cas_org = [ca_org(i,:)',simulation.input.orgeq.(ion)];
        cas_aq = [ca_aq(i,:)',simulation.input.aqeq.(ion)];
        mvu_scatter(cas_aq,cas_org,'Aqueous','Organic', ...
            ['Isothermes ',ion,' Multisels ',num2str(simulation.input.T.celsius.value(1)),' C'], ...
            {'trial','truth'})

        if simulation.input.T.celsius.value(1) <= 60
            switch ion
                case 'ClO4'
                   ylim([0 100]);
                   xlim([0 50]);
            end
        else
             switch ion
                case 'ClO4'
                   ylim([0 100]);
                   xlim([0 800]);
             end
        end
    end
    %lim([0,150])
end