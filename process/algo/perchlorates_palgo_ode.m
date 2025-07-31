function [c_aq_c_extracted,c_aq_a_extracted,c_org_c_extracted,c_org_a_extracted] = ...
                    perchlorates_palgo_ode(simulation,step_size,end_time)
    %perchlorates_palgo_ode given a simulation input solves ODE and returns stable state
    %
    % Best aks found (02/07/2025):
    % ext = 1,04e-2 
    % rege = 7,03e-2
    % Best inputs : 
    % step_size = 10 = diag_step_size
    % end_time = 500
    % 
    % Args:
    %   simulation : simulation struct from sulfates_p_make
    %   step_size : step size (in s) of ODE solver
    %   diag_step_size : step size (in s) for diagnostic (for debugging, set it to different value to step_size to make diagnostics)
    %   end_time : ode solves until this time (in s)
    %
    % Returns:
    %   cli_aq_end : mvu of Li in aqueous phase at the end of ODE for each stage
    %   cso4_aq_end : mvu of SO4 in aqueous phase at the end of ODE for each stage
    %   cli_org_end : mvu of Li in organic phase at the end of ODE for each stage
    %   cso4_org_end : mvu of SO4 in organic phase at the end of ODE for each stage
    %
    % see also 
    
    %% %% Initinialization %% %%
    % Global Constants % 
    times = 0:step_size:end_time;
    %number of cations extracted
    n_c = length(simulation.constants.cations_extracted);
    %number of anions extracted
    n_a = length(simulation.constants.anions_extracted);
    %number of extracted ions
    n_i = n_c + n_a;
    %extractions
    n_ext = simulation.input.n_ext;
    %total number of stages
    n_tot = n_ext+3;
    %output units
    unit = simulation.input.output_unit;

    ext_feed_c = simulation.constants.ext_feed_c;
    ext_feed_a = simulation.constants.ext_feed_a;
    rege_feed_c = simulation.constants.rege_feed_c;
    rege_feed_a = simulation.constants.rege_feed_a;
    % %

    % Make matrices %
    [aq_real_mat,aq_feed_vec,aq_eq_mat] = perchlorates_palgo_daqdt_mat(simulation);
    [org_real_mat,org_eq_mat] = perchlorates_palgo_dorgdt_mat(simulation);
    %add 0s
    O = aq_real_mat*mvu(0,'');
    rmat = [aq_real_mat,O;
            O,org_real_mat];
    O = aq_eq_mat*mvu(0,'');
    eqmat = [aq_eq_mat,O
             O,org_eq_mat];
    O = aq_feed_vec*mvu(0,'');
    vec = [aq_feed_vec;O];
    %Make is,ks for mapping vector version to matrix version of
    %concentrations
    [is,js] = perchlorates_palgo_ijs(n_ext,n_c,n_a);
    % %

    % Mask %
    %determine which are 0 entries
    mask = abs(rmat)+abs(eqmat);
    mask = mask.value;
    mask(mask~=0) = 1;
    % %
    
    % Initial Values of Equilibrium & State %
    %Initialize aqueous equilibrium to input feed for cations
    c_aq_eq_c = [repmat(ext_feed_c,1,n_ext),...
                 repmat(rege_feed_c,1,3)];
    %Initialize organic equilibrium to input feed for cations
    c_org_eq_c = c_aq_eq_c*mvu(0,'');
    %Initialize aqueous to input feed for cations
    c_aq_c = c_aq_eq_c;
    %Initialize organic to input feed for cations
    c_org_c = c_org_eq_c*mvu(0,'');
    %Initialize aqueous equilibrium to input feed for anions
    c_aq_eq_a = [repmat(ext_feed_a,1,n_ext),...
                 repmat(rege_feed_a,1,3)];
    %Initialize organic equilibrium to input feed for anions
    c_org_eq_a = c_aq_eq_a*mvu(0,'');
    %Initialize aqueous to input feed for anions
    c_aq_a = c_aq_eq_a;
    %Initialize organic to input feed for anions
    c_org_a = c_org_eq_a*mvu(0,'');
    %Optimization inputs
    %take first n_c or n_a columns of the inflow
    A = [c_aq_c(1:n_c,:);c_aq_a(1:n_a,:)]';
    B = [c_org_c(1:n_c,:);c_org_a(1:n_a,:)]';
    a = A(:);
    b = B(:);
    x_ini = [a;b];
    %initialize matrices
    caq_extracted_mat = mavu(zeros(n_c+n_a,n_tot),unit); 
    corg_extracted_mat = mavu(zeros(n_c+n_a,n_tot),unit); 
    % %
    %% %%  %% %%

    %% %% Vecmat %% %%
    function state_update(x_in)
        % % Get individual state vectors % %
        % aq %
        caq_extracted_vec = x_in(1:n_i*n_tot);
        caq_extracted_mat = perchlorates_palgo_cvecmat(caq_extracted_mat, ...
                                                       caq_extracted_vec, ...
                                                       is,js);
        %cations
        c_aq_c(1:n_c,:) = caq_extracted_mat(1:n_c,:);
        %anions
        c_aq_a(1:n_a,:) = caq_extracted_mat(n_c+1:n_c+n_a,:);
        % %
        
        % org %
        corg_extracted_vec = x_in(n_i*n_tot+1:2*n_i*n_tot);
        corg_extracted_mat = perchlorates_palgo_cvecmat(corg_extracted_mat, ...
                                                        corg_extracted_vec, ...
                                                        is,js);
        %cations
        c_org_c(1:n_c,:) = corg_extracted_mat(1:n_c,:);
        %anions
        c_org_a(1:n_a,:) = corg_extracted_mat(n_c+1:n_c+n_a,:);
        % %
        % %  % %
    end
    %% %% %% %%
    
    %% %% Function  %% %%
    function dxdt = ddt_func(t,x_in)
        %input must be greater than 0, cut off when below 0.
        c_extracted_vec = mavu(max(x_in,0),unit);

        % updates c_aq_c,c_aq_a,c_org_c,c_org_a
        state_update(c_extracted_vec);
        
        
        % % Compute equilibriums % %
        [c_aq_eq_c,c_org_eq_c,c_aq_eq_a,c_org_eq_a] = ...
            perchlorates_palgo_eq(c_aq_eq_c,c_org_eq_c,c_aq_eq_a,c_org_eq_a, ...
                                  c_aq_c,c_aq_a,c_org_c,c_org_a,...
                                  simulation);
        
        % %  % %

        % % Compute ODE % %
        %convert vector
        caq_eq_mat = [c_aq_eq_c(1:n_c,:);c_aq_eq_a(1:n_a,:)];
        caq_extracted_vec_eq = c_extracted_vec(1:n_i*n_tot);
        caq_extracted_vec_eq = perchlorates_palgo_cmatvec(caq_eq_mat, ...
                                                       caq_extracted_vec_eq, ...
                                                       is,js);

        corg_eq_mat = [c_org_eq_c(1:n_c,:);c_org_eq_a(1:n_a,:)];
        corg_extracted_vec_eq = c_extracted_vec(n_i*n_tot+1:2*n_i*n_tot);
        corg_extracted_vec_eq = perchlorates_palgo_cmatvec(corg_eq_mat, ...
                                                       corg_extracted_vec_eq, ...
                                                       is,js);
        c_extracted_vec_eq = [caq_extracted_vec_eq;corg_extracted_vec_eq];

        %compute dxdt
        dxdt = rmat*c_extracted_vec + eqmat*c_extracted_vec_eq + vec;
        dxdt = dxdt.value;
        % %  % %
    end
    %% %%  %% %%

    %% %% ODE solver %% %%
    options = odeset('Stats','on', 'OutputFcn', @odeplot,...
        'NonNegative',1:4*(n_ext+3),...
        'NormControl',"on","JPattern",mask,...
        "RelTol",1e-1,"AbsTol",1e-1,'MaxStep',step_size);
    %[t,out] = ode15s(@(t,x) ddt_func(t,x),times,x_ini.value,options);
    [t,x_out] = ode89(@(t,x) ddt_func(t,x),times,x_ini.value,options);
    %% %%  %% %%
    
    state_update(mavu(max(x_out(end,:),0),unit)) 
    c_aq_c_extracted = c_aq_c(1:n_c,:);
    c_aq_a_extracted = c_aq_a(1:n_a,:);
    c_org_c_extracted = c_org_c(1:n_c,:);
    c_org_a_extracted = c_org_a(1:n_a,:);
end