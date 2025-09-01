function [c_aq_c,c_org_c,c_aq_a,c_org_a,success] = perchlorates_palgo_eq( ...
                                        c_aq_c,c_org_c,c_aq_a,c_org_a, ...
                               c_aq_neq_c,c_aq_neq_a,c_org_neq_c,c_org_neq_a, ...
                                        simulation)
    %perchlorates_palgo_eq solves the equilibrium equations
    %
    % see also 
    arguments (Input)
        c_aq_c MatrixValueUnit
        c_org_c MatrixValueUnit
        c_aq_a MatrixValueUnit
        c_org_a MatrixValueUnit
        c_aq_neq_c MatrixValueUnit
        c_aq_neq_a MatrixValueUnit
        c_org_neq_c MatrixValueUnit
        c_org_neq_a MatrixValueUnit
        simulation struct
    end 
    
    success = true;

    Kapp = simulation.constants.Kapp;
    cations = simulation.constants.cations_extracted;
    nc = length(cations);
    anions = simulation.constants.anions_extracted;
    na = length(anions);
    n_ext = simulation.input.n_ext;
    rho = simulation.constants.rho;
    OA = simulation.constants.OA;
    extracted_cations = 1:nc;
    extracted_anions = 1:na;
    err_tol = 1e-2;

    %[is,js] = perchlorates_palgo_ijs(n_ext,nc,0);

    zc = simulation.constants.zc(extracted_cations);
    c_ext_feed_c = simulation.constants.ext_feed_c(extracted_cations,:);
    c_ext_feed_a = simulation.constants.ext_feed_a(extracted_anions,:);
    c_rege_feed_c = simulation.constants.rege_feed_c(extracted_cations,:);
    c_rege_feed_a = simulation.constants.rege_feed_a(extracted_anions,:);

    fyc = perchlorates_ctoy(c_aq_c,rho);
    fyc = fyc.to(' mol/kg_eau');
    fya = perchlorates_ctoy(c_aq_a,rho);
    fya = fya.to(' mol/kg_eau');

    %ccmat = mavu(zeros(size(c_org_c(extracted_cations,:))),c_org_c.unit);
    function [aq_prior_c,org_posterior_c,aq_prior_a,org_posterior_a] = ...
                                                    prior_posterior(k)
        %determines the inflows into stage k (inflows are non-eq concenctrations)
        %prior and posterior depend on stage
            switch true
                case k == 1
                    aq_prior_c = c_ext_feed_c;
                    org_posterior_c = c_org_neq_c(:,k+1);
                    aq_prior_a = c_ext_feed_a;
                    org_posterior_a = c_org_neq_a(:,k+1);
                case k == n_ext+1
                    aq_prior_c = c_rege_feed_c;
                    org_posterior_c = c_org_neq_c(:,k+1);
                    aq_prior_a = c_rege_feed_a;
                    org_posterior_a = c_org_neq_a(:,k+1);
                case k == n_ext+3
                    aq_prior_c = c_aq_neq_c(:,k-1);
                    org_posterior_c = c_org_neq_c(:,1);
                    aq_prior_a = c_aq_neq_a(:,k-1);
                    org_posterior_a = c_org_neq_a(:,1);
                otherwise
                    aq_prior_c = c_aq_neq_c(:,k-1);
                    org_posterior_c = c_org_neq_c(:,k+1);
                    aq_prior_a = c_aq_neq_a(:,k-1);
                    org_posterior_a = c_org_neq_a(:,k+1);
            end
    end


    function error = objective(input,i)
        %get relevant inflows (from prior in aq, from posterior in org)
        [aq_prior_c,org_posterior_c,aq_prior_a,org_posterior_a] = ...
                        prior_posterior(i);
        %input to mvu represents extracted cation concentration in org
        cc = mvu(input,'mmol/ L');
        %ccmat = perchlorates_palgo_cvecmat(ccmat,cc,is,js);
        %deduce extracted anion concentration in org
        ca = perchlorates_cclo4_eq_org(zc,cc);
        %deduce aq concentration in mol/kg_eau using the aq equation
        yc = perchlorates_ctoy(perchlorates_ceq_aq( ...
            cc,aq_prior_c(extracted_cations),org_posterior_c(extracted_cations),OA(i)),rho(i));
        ya = perchlorates_ctoy(perchlorates_ceq_aq( ...
            ca,aq_prior_a(extracted_anions),org_posterior_a(extracted_anions),OA(i)),rho(i));
        %now put updated extracted ys into y for gamma computations
        %if any(yc<mvu(0,'mmol/kg_eau')) || any(ya<mvu(0,'mmol/kg_eau'))
        %    error = sulfates_mse(yc) + sulfates_mse(ya);
        %else
            fyc(extracted_cations,i) = yc; %can be negative, but that is handled via constraints
            fya(extracted_anions,i) = ya; %can be negative, but that is handled via constraints
            %compute gamma, the activity coefficient
            gamma = pitzer_mss_gamma(simulation,fyc(:,i),fya(:,i),simulation.constants.T(i), ...
                                     extracted_cations,extracted_anions);
            %with the computations above, deduce the error in the org equation
            %raw_error = perchlorates_org_eq(cc,yc,ya,zc,Kapp(:,i),gamma);
            raw_error = perchlorates_org_clo4_eq(ca,yc,ya,zc,Kapp(:,i),gamma);
            %mae the error to generate an objective
            error = sulfates_mae(raw_error);
        %end
    end

    function [c, ceq] = constraint(input,i)
        %get relevant inflows (from prior in aq, from posterior in org)
        [aq_prior_c,org_posterior_c,aq_prior_a,org_posterior_a] = ...
                        prior_posterior(i);
        %input to mvu represents extracted cation concentration in org
        cc = mvu(input,'mmol/ L');
        %ccmat = perchlorates_palgo_cvecmat(ccmat,cc,is,js);
        %deduce extracted anion concentration in org
        ca = perchlorates_cclo4_eq_org(zc,cc);
        %deduce aq concentration in mol/kg_eau using the aq equation
        yc = perchlorates_ctoy(perchlorates_ceq_aq( ...
            cc,aq_prior_c(extracted_cations),org_posterior_c(extracted_cations),OA(i)),rho(i));
        ya = perchlorates_ctoy(perchlorates_ceq_aq( ...
            ca,aq_prior_a(extracted_anions),org_posterior_a(extracted_anions),OA(i)),rho(i));
        %nobody should be negative
        c = -[input',ca.value,yc.value',ya.value];     % Enforces: x > 0 ⇒ -x < 0
        ceq = [];   % No equality constraints
    end


    function stop = stop_func(x, optimValues, state)
        stop = false;  % Default is not to stop
        if strcmp(state, 'iter')
            % Set a condition to stop immediately
            if optimValues.fval < err_tol  % or any other custom condition
                %disp('Terminating immediately as f(x) is small enough.');
                stop = true;  % Set stop to true to stop the optimization
            end
        end
    end

    options = optimoptions('fmincon', 'Display', 'off', ...
        'OutputFcn', @stop_func,'StepTolerance', 1e-12,'Algorithm', 'interior-point', ...
        'MaxFunctionEvaluations',1000, ...
        'OptimalityTolerance',1e-3,'ConstraintTolerance',0);
    lb = [0,0,0];
    for i=1:simulation.input.n_ext+3
        input = c_org_c(extracted_cations,i);

        [x_opt, fval_opt] = fmincon(@(x) objective(x,i),input.value,...
                [],[], [], [], lb, [],@(x) constraint(x,i), options);
        if fval_opt > err_tol*10
            warning('Palgo_eq:NonConvergence',['Equilibrium at stage ', num2str(i),' did not converge !'])

            success = false;
            return
        end
        %save org eq results 
        c_org_c(extracted_cations,i) = mvu(x_opt,'mmol/ L');
        c_org_a(extracted_anions,i) = perchlorates_cclo4_eq_org(zc,c_org_c(extracted_cations,i));
        %get relevant inflows (from prior in aq, from posterior in org)
        [aq_prior_c,org_posterior_c,aq_prior_a,org_posterior_a] = ...
                        prior_posterior(i);
        %save aq results
        c_aq_c(extracted_cations,i) = perchlorates_ceq_aq(c_org_c(extracted_cations,i),aq_prior_c(extracted_cations),org_posterior_c(extracted_cations),OA(i));
        c_aq_a(extracted_anions,i) = perchlorates_ceq_aq(c_org_a(extracted_anions,i),aq_prior_a(extracted_anions),org_posterior_a(extracted_anions),OA(i));
        
        c1 = c_org_c(extracted_cations,i);
        c2 = c_org_a(extracted_anions,i);
        c3 = c_aq_c(extracted_cations,i);
        c4 = c_aq_a(extracted_anions,i);
        if any(c1.value<0) || any(c2.value<0) || any(c3.value<0) || any(c4.value<0)
            warning('Palgo_eq:NonConvergence',['Equilibrium at stage ', num2str(i),' is negative !'])
            
            success = false;
            return
        end
    end
end