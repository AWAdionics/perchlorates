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
    err_tol = 1e-3;
    infeasible_tol = 1e-12;

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


    function error = objective(input_,i)
        %get relevant inflows (from prior in aq, from posterior in org)
        [aq_prior_c,org_posterior_c,aq_prior_a,org_posterior_a] = ...
                        prior_posterior(i);
        %input to mvu represents extracted cation concentration in org
        cc = mavu(input_,input.unit); 
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
            fyc(extracted_cations,i) = abs(yc); %can be negative, but that is handled via constraints
            fya(extracted_anions,i) = abs(ya); %can be negative, but that is handled via constraints
            %compute gamma, the activity coefficient
            if any(abs(fyc(:,i)) >= mvu(1e-6,'mmol/kg_eau'))
                gamma = pitzer_mss_gamma(simulation,fyc(:,i),fya(:,i),simulation.constants.T(i), ...
                                         extracted_cations,extracted_anions);
            else
                gamma = mvu(1,'');
            end
            %with the computations above, deduce the error in the org equation
            %raw_error = perchlorates_org_eq(cc,yc,ya,zc,Kapp(:,i),gamma);
            raw_error = perchlorates_org_clo4_eq(ca,yc,ya,zc,Kapp(:,i),gamma);
            %mae the error to generate an objective
            error = abs(raw_error.value);
        %end
    end

    function [c, ceq] = constraint(input_,i)
        %get relevant inflows (from prior in aq, from posterior in org)
        [aq_prior_c,org_posterior_c,aq_prior_a,org_posterior_a] = ...
                        prior_posterior(i);
        %input to mvu represents extracted cation concentration in org
        c_org_c_i = mavu(input_,input.unit);
        %ccmat = perchlorates_palgo_cvecmat(ccmat,cc,is,js);
        %deduce extracted anion concentration in org
        c_org_a_i = perchlorates_cclo4_eq_org(zc,c_org_c_i);
        %deduce aq concentration in mol/kg_eau using the aq equation
        c_aq_c_i = perchlorates_ceq_aq( ...
            c_org_c_i,aq_prior_c(extracted_cations),org_posterior_c(extracted_cations),OA(i));
        c_aq_a_i = perchlorates_ceq_aq( ...
            c_org_a_i,aq_prior_a(extracted_anions),org_posterior_a(extracted_anions),OA(i));

        c_org_c_neq_i = c_org_neq_c(extracted_cations,i);
        c_org_a_neq_i = c_org_neq_a(extracted_anions,i);
        c_aq_c_neq_i = c_aq_neq_c(extracted_cations,i);
        c_aq_a_neq_i = c_aq_neq_a(extracted_anions,i);

        %if i <= n_ext
        %    ineq3 = c_org_c_neq_i - c_org_c_i; % eq > neq (aq -> org)
        %    ineq4 = c_org_a_neq_i - c_org_a_i; % eq > neq (aq -> org)
        %else
        %    ineq3 = c_org_c_i - c_org_c_neq_i; % eq < neq (aq <- org)
        %    ineq4 = c_org_a_i - c_org_a_neq_i; % eq < neq (aq <- org)
        %    
        %end
        %nobody should be negative

        %inequalites are of the form f(x) < 0

        c = [-c_aq_c_i.value',-c_aq_a_i.value];  %enforce positivity for aq (org already enforced)
        ceq = [];   % No equality constraints
    end


    function stop = stop_func(x, optimValues, state,i)
        stop = false;  % Default is not to stop
        if strcmp(state, 'iter')
            % Set a condition to stop immediately
            if optimValues.fval < err_tol  % or any other custom condition
                %disp('Terminating immediately as f(x) is small enough.');
                [c, ceq] = constraint(x,i);
                if all(c < 0)
                    stop = true;  % Set stop to true to stop the optimization
                end
            end
        end
    end

    
    
    for i=1:simulation.input.n_ext+3
        
        %if i > n_ext
        %    [aq_prior_c,org_posterior_c,aq_prior_a,org_posterior_a] = ...
        %                prior_posterior(i);
        %    trial = perchlorates_aq_eq_small_regime(aq_prior_c(extracted_cations),org_posterior_c(extracted_cations),c_org_neq_c(extracted_cations,i),OA(i));
        %    if all(abs(trial.value)<=1e1)
        %        c_aq_c(extracted_cations,i) = trial;
        %        c_aq_a(extracted_anions,i) = perchlorates_aq_eq_small_regime(aq_prior_a(extracted_anions),org_posterior_a(extracted_anions),c_org_neq_a(extracted_anions,i),OA(i));
        %        
        %        yc_ = perchlorates_ctoy(c_aq_c(extracted_cations,i),rho(i));
        %        ya_ = perchlorates_ctoy(c_aq_a(extracted_anions,i),rho(i));%
        %
        %       c_org_c(extracted_cations,i) = perchlorates_org_eq_small_regime(aq_prior_c(extracted_cations),org_posterior_c(extracted_cations),yc_,ya_,OA,zc,Kapp(:,i),rho(i));

        %       c_org_a(extracted_anions,i) = perchlorates_cclo4_eq_org(zc,c_org_c(extracted_cations,i));
                
        %       disp('Small Regime')
        %       continue
        %   end
        %end

        input = c_org_c(extracted_cations,i);

        %get relevant inflows (from prior in aq, from posterior in org)
        [aq_prior_c,org_posterior_c,aq_prior_a,org_posterior_a] = ...
                        prior_posterior(i);

        [A,b,fromaq_ub] = perchlorates_org_fromaq_ub(aq_prior_c(extracted_cations),org_posterior_c(extracted_cations), ...
                                aq_prior_a(extracted_anions),org_posterior_a(extracted_anions),zc,OA(i));
        fromaq_ub = fromaq_ub.qto(input.unit); %make sure in input units
        if i > n_ext
            ub = org_posterior_c(extracted_cations);
            %ub = c_org_neq_c(extracted_cations,i);
            ub = ub.qto(input.unit); %make sure in input units
            ub = min(ub.value,fromaq_ub.value);
            lb = [0;0;0];
        else
            lb = org_posterior_c(extracted_cations);
            %lb = c_org_neq_c(extracted_cations,i);
            lb = lb.qto(input.unit); %make sure in input units
            lb = lb.value;
            ub = fromaq_ub.value;
        end
        options = optimoptions('fmincon', 'Display', 'off', ...
        'OutputFcn', @(x,optim,state) stop_func(x,optim,state,i),'StepTolerance',0,'Algorithm', 'interior-point', ...
        'MaxFunctionEvaluations',1000, ...
        'OptimalityTolerance',1e-9,'ConstraintTolerance',infeasible_tol);
        if i == 6
            a=1;
        end
        if all(ub > lb)

            fval_opt = objective(input.value,i);
            x_opt = input.value;

            if fval_opt > err_tol || any(x_opt<lb) || any(x_opt>ub) || A.value*x_opt-b.value > 0
                [x_opt, fval_opt] = fmincon(@(x) objective(x,i),input.value,...
                        A.value,b.value, [], [], lb, ub,[], options); %@(x) constraint(x,i)
            else
                %disp('Skipped')
            end
        else
            x_opt = [0;0;0];
            fval_opt = objective(x_opt,i);
        end

        %[c_, ceq_] = constraint(x_opt,i);
        if fval_opt > err_tol
            warning('Palgo_eq:NonConvergence',['Equilibrium at stage ', num2str(i),' did not converge !'])

            success = false;
            return
        end
        %save org eq results 
        c_org_c(extracted_cations,i) = mvu(x_opt,'mmol/ L');
        c_org_a(extracted_anions,i) = perchlorates_cclo4_eq_org(zc,c_org_c(extracted_cations,i));
        
        %save aq results
        c_aq_c(extracted_cations,i) = perchlorates_ceq_aq(c_org_c(extracted_cations,i),aq_prior_c(extracted_cations),org_posterior_c(extracted_cations),OA(i));
        c_aq_a(extracted_anions,i) = perchlorates_ceq_aq(c_org_a(extracted_anions,i),aq_prior_a(extracted_anions),org_posterior_a(extracted_anions),OA(i));
        
        %c1 = c_org_c(extracted_cations,i);
        %c2 = c_org_a(extracted_anions,i);
        %c3 = c_aq_c(extracted_cations,i);
        %c4 = c_aq_a(extracted_anions,i);
        %if any(c1.value<-infeasible_tol*100) || any(c2.value<-infeasible_tol*100) || any(c3.value<-infeasible_tol*100) || any(c4.value<-infeasible_tol*100)
        %    warning('Palgo_eq:NonConvergence',['Equilibrium at stage ', num2str(i),' is negative !'])
            
            %success = false;
            %return
        %end
    end
end