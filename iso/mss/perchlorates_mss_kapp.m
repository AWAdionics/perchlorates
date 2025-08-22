function [Kapps, err] = perchlorates_mss_kapp(casename)
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
    cations = simulation.constants.cations_extracted;
    anions = simulation.constants.anions_extracted;
    rho = simulation.constants.rho;
    zc = simulation.constants.zc;
    extracted_cations = 1:length(cations);
    extracted_anions = [1];
    cc = simulation.constants.orgeq_c;
    ca = perchlorates_cclo4_eq_org(zc,cc(extracted_cations,:));
    fyc = perchlorates_ctoy(simulation.constants.aqeq_c,rho);
    fya = perchlorates_ctoy(simulation.constants.aqeq_a,rho);
    gamma = mvu([],'');
    for i=1:length(simulation.input.T)
        gamma = [gamma,pitzer_mss_gamma(simulation,fyc(:,i),fya(:,i), ...
                                        simulation.input.T(i), ...
                                        extracted_cations, ...
                                        extracted_anions)];
    end

    function error = objective(input)
        Kapps = mvu(input,'');
        error = 0;
        j=0;
        if j == 0
            for i=1:length(simulation.input.T)
                %raw_error = perchlorates_org_eq(cc(extracted_cations,i), ...
                %                                fyc(extracted_cations,i), ...
                %                                fya(extracted_cations,i), ...
                %                                zc,Kapps,gamma(:,i));
                raw_error = perchlorates_org_clo4_eq(ca(extracted_anions,i),fyc(extracted_cations,i),fya(extracted_cations,i),zc,Kapps,gamma(:,i));
                error = error + sulfates_mae(raw_error);
            end
        else
            %raw_error = perchlorates_org_eq(cc(extracted_cations,j), ...
            %                                    fyc(extracted_cations,j), ...
            %                                    fya(extracted_cations,j), ...
            %                                    zc,Kapps,gamma(:,j));
            raw_error = perchlorates_org_clo4_eq(ca(extracted_anions,j),fyc(extracted_cations,j),fya(extracted_cations,j),zc,Kapps,gamma(:,j));
            error = error + sulfates_mae(raw_error);
        end
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
        'OutputFcn', @stop_func,'StepTolerance',1e-13,'Algorithm', 'interior-point', ...
        'MaxFunctionEvaluations',1000, ...
        'OptimalityTolerance',1e-13,...
        'FunctionTolerance',1e-13);
    lb = [0,0,0];
    
    [kapp, err] = fmincon(@(x) objective(x),Kapp.value(:,1),...
                [],[], [], [], lb, [],[], options);
    Kapps = mvu(kapp,'');
end