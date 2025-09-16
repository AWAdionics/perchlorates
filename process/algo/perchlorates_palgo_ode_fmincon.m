function [t_outer,x_out_outer] = perchlorates_palgo_ode_fmincon(ddt_func,x_ini,options,err_tol,infeasible_tol)
    %defunct
    arguments
        ddt_func
        x_ini 
        options 
        err_tol = 1e-3
        infeasible_tol = 1e-6
    end
    lb = 0*x_ini;

    function stop = stop_func(x, optimValues, state,i)
        stop = false;  % Default is not to stop
        if strcmp(state, 'iter')
            % Set a condition to stop immediately
            if optimValues.fval < err_tol  % or any other custom condition
               stop = true;  % Set stop to true to stop the optimization
            end
        end
    end

    options = optimoptions('fmincon', 'Display', 'iter', ...
        'OutputFcn', @(x,optim,state) stop_func(x,optim,state),'StepTolerance',0,'Algorithm', 'sqp', ...
        'MaxFunctionEvaluations',400, ...
        'OptimalityTolerance',1e-9,'ConstraintTolerance',infeasible_tol);

    [x_opt, fval_opt] = fmincon(@(x) norm(ddt_func(0,x)),x_ini,...
                        [],[], [], [], lb, [],[], options); %@(x) constraint(x,i)
    
    t_outer = [0,100,200,300,400,500];

    x_out_outer = x_opt;
end