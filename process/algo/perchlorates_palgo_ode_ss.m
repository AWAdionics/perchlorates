function [t_outer,x_out_outer] = perchlorates_palgo_ode_ss(ddt_func,x_ini,options,outer_steps,tolerance,max_step,max_outer_step_size,min_outer_step_size)
    arguments
        ddt_func
        x_ini 
        options 
        outer_steps = 25
        tolerance = 1e-1
        max_step = 30
        max_outer_step_size = 50
        min_outer_step_size = 1e-3
    end

    max_outer_step_size = max(max_outer_step_size,outer_steps);
    cond = true;
    x_out_outer = [];
    t_outer = [];
    only_outer_ts = [];
    ddts = [];
    step = 0;
    x_ini = x_ini;
    options = odeset(options,'MaxStep',outer_steps/10,'MinStep',outer_steps/1000);
    
    

    f1 = figure;
    f2 = figure;


    ddt = ddt_func(0,x_ini);
    ddts = [ddts;norm(ddt)];
    if isscalar(ddts)
        ylims = [0,norm(ddt)];
    end
    only_outer_ts = [only_outer_ts;0];
    clf
    plot(only_outer_ts,ddts)
    ylim(ylims)
    drawnow;


    while cond
        if length(t_outer)> 1
            times = t_outer(end):outer_steps/10:t_outer(end)+outer_steps; 
        else
            times = 0:outer_steps/10:outer_steps; 
        end
        try
            %[t,x_out] = ode15s(ddt_func,times,x_ini,options);
            [t,x_out] = ode45(ddt_func,times,x_ini,options);
        catch ME
            if strcmp(ME.identifier, 'Palgo_ode:EqNonConvergence')
                outer_steps = outer_steps/10;
                options = odeset(options,'MaxStep',outer_steps/10,'MinStep',outer_steps/1000);
                warning(['Reducing outer step size to ',num2str(outer_steps)])
                continue
            else
                % Re-throw unexpected errors
                rethrow(ME);
            end
        end

        if length(t) < length(times)
            outer_steps = outer_steps/10;
            options = odeset(options,'MaxStep',outer_steps/10,'MinStep',outer_steps/1000);
            if outer_steps > min_outer_step_size
                warning(['Reducing outer step size to ',num2str(outer_steps)])
                continue
            else
                error('Minimum outer step size reached, convergence failure.')
            end
        else
            if outer_steps < max_outer_step_size
                outer_steps = outer_steps*2;
                options = odeset(options,'MaxStep',outer_steps/10,'MinStep',outer_steps/1000);
                %t = t(end);
                disp(['Increasing step size to ',num2str(outer_steps)])
            else
                outer_steps = max_outer_step_size;
                options = odeset(options,'MaxStep',outer_steps/10,'MinStep',outer_steps/1000);
                disp(['Max Step Size ',num2str(outer_steps)])
            end
        end


        %update outer
        x_out_outer = [x_out_outer;x_out];
        t_outer = [t_outer;t];
        ddt = ddt_func(t,x_out(end,:)');
        ddts = [ddts;norm(ddt)];
        ylims = [0,max(ddts)];
        x_ini = x_out(end,:)';
        only_outer_ts = [only_outer_ts;t(end)];

        %update scatter plot
        if exist('f1','var') && isvalid(f1) && ishghandle(f1) && strcmp(get(f1,'Type'),'figure')
            figure(f1);   % Reactivate existing figure
        else
            f1 = figure;  % Recreate if deleted or never existed
        end
        clf
        scatter(t_outer,x_out_outer)
        

        if exist('f2','var') && isvalid(f2) && ishghandle(f2) && strcmp(get(f2,'Type'),'figure')
            figure(f2);   % Reactivate existing figure
        else
            f2 = figure;  % Recreate if deleted or never existed
        end
        clf
        plot(only_outer_ts,ddts)
        ylim(ylims)
        drawnow;
        

        if norm(ddt) <= tolerance
            return
        end

        step = step + 1;
        
        if step > max_step
            warning('Max Step reached, terminating although we did not reach steady state.')
            return
        end
    end
end