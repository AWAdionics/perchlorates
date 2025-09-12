function [c_aq_c_extracted,c_aq_a_extracted,c_org_c_extracted,c_org_a_extracted] = ...
    perchlorates_palgo_ode(simulation,step_size,end_time,diagnostic)
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
    %times = 0:step_size:end_time;
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
    for i=1:n_ext+3
        if i <= n_ext
            c_org_eq_c(1:n_c,i) = mvu(0*[13.34;1.2;13.70],'mmol/ L');
        else
            c_org_eq_c(1:n_c,i) = mvu(0*[1.334;0.12;1.370],'mmol/ L');
        end
    end
    %Initialize aqueous to input feed for cations
    c_aq_c = c_aq_eq_c;
    %Initialize organic to input feed for cations
    c_org_c = c_org_eq_c;
    %Initialize aqueous equilibrium to input feed for anions
    c_aq_eq_a = [repmat(ext_feed_a,1,n_ext),...
                 repmat(rege_feed_a,1,3)];
    %Initialize organic equilibrium to input feed for anions
    c_org_eq_a = c_aq_eq_a*mvu(0,'');
    for i=1:n_ext+3
        if i <= n_ext
            c_org_eq_a(1:n_a,i) = mvu(0*43.23,'mmol/ L');
        else
            c_org_eq_a(1:n_a,i) = mvu(0*4.323,'mmol/ L');
        end
    end
    %Initialize aqueous to input feed for anions
    c_aq_a = c_aq_eq_a;
    %Initialize organic to input feed for anions
    c_org_a = c_org_eq_a;
    %Optimization inputs
    %take first n_c or n_a columns of the inflow
    A = [c_aq_c(1:n_c,:);c_aq_a(1:n_a,:)]';
    B = [c_org_c(1:n_c,:);c_org_a(1:n_a,:)]';
    a = A(:);
    b = B(:);
    x_ini = [a;b];
    scaler = 1+0*x_ini.value;
    %initialize matrices
    caq_extracted_mat = mavu(zeros(n_c+n_a,n_tot),unit); 
    corg_extracted_mat = mavu(zeros(n_c+n_a,n_tot),unit); 
    
    dcaqdt_extracted_mat = mavu(zeros(n_c+n_a,n_tot),unit)*mvu(1,'/ s'); 
    dcorgdt_extracted_mat = mavu(zeros(n_c+n_a,n_tot),unit)*mvu(1,'/ s'); 
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

    function [dcaqdt,daaqdt,dcorgdt,daorgdt] = state_derivative(dxdt)
        % % Get individual state vectors % %
        % aq %
        caq_extracted_vec = dxdt(1:n_i*n_tot);
        
        dcaqdt_extracted_mat = perchlorates_palgo_cvecmat(dcaqdt_extracted_mat, ...
                                                       caq_extracted_vec, ...
                                                       is,js);
        %cations
        dcaqdt = dcaqdt_extracted_mat(1:n_c,:);
        %anions
        daaqdt = dcaqdt_extracted_mat(n_c+1:n_c+n_a,:);
        % %
        
        % org %
        corg_extracted_vec = dxdt(n_i*n_tot+1:2*n_i*n_tot);
        dcorgdt_extracted_mat = perchlorates_palgo_cvecmat(dcorgdt_extracted_mat, ...
                                                        corg_extracted_vec, ...
                                                        is,js);
        %cations
        dcorgdt = dcorgdt_extracted_mat(1:n_c,:);
        %anions
        daorgdt = dcorgdt_extracted_mat(n_c+1:n_c+n_a,:);
        % %
        % %  % %
    end
    %% %% %% %%
    
    %% %% Function  %% %%
    function dxdt = ddt_func(t,x_in)
        time = t
        %input must be greater than 0, cut off when below 0.
        c_extracted_vec = mavu(x_in.*scaler,unit);

        % updates c_aq_c,c_aq_a,c_org_c,c_org_a
        state_update(c_extracted_vec);
        
        
        % % Compute equilibriums % %
        [c_aq_eq_c_,c_org_eq_c_,c_aq_eq_a_,c_org_eq_a_,success] = ...
            perchlorates_palgo_eq(c_aq_eq_c,c_org_eq_c,c_aq_eq_a,c_org_eq_a, ...
                                  c_aq_c,c_aq_a,c_org_c,c_org_a,...
                                  simulation);
        if success
            c_aq_eq_c = mavu((c_aq_eq_c_.value),c_aq_eq_c_.unit);
            c_org_eq_c = mavu((c_org_eq_c_.value),c_org_eq_c_.unit);
            c_aq_eq_a = mavu((c_aq_eq_a_.value),c_aq_eq_a_.unit);
            c_org_eq_a = mavu((c_org_eq_a_.value),c_org_eq_a_.unit);

            disp('eq')
            test1 = c_org_eq_a_(1:3,:)
            disp('actual')
            test2 = c_org_a(1:3,:)
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
            dxdt = dxdt.value./scaler;
            [dcaqdt,daaqdt,dcorgdt,daorgdt] = state_derivative(mavu(dxdt,dcaqdt_extracted_mat.unit));
            disp('org')
            daorgdt
            c_aq_eq_c.value(1:n_c,n_ext+1);
            c_aq_c.value(1:n_c,n_ext+1);
            dcaqdt.value(:,n_ext+1);
            % %  % %
        else
            error('Palgo_ode:EqNonConvergence','Equilibrium did Not Converge')
        end
    end

    
    function [dcaqdt_rterm,daaqdt_rterm,dcorgdt_rterm,daorgdt_rterm,...
              dcaqdt_eqterm,daaqdt_eqterm,dcorgdt_eqterm,daorgdt_eqterm,...
              dcaqdt_vec,daaqdt_vec,dcorgdt_vec,daorgdt_vec] = state_derivative_terms(x_in)
        %input must be greater than 0, cut off when below 0.
        c_extracted_vec = mavu(max(x_in,0),unit);

        % updates c_aq_c,c_aq_a,c_org_c,c_org_a
        state_update(c_extracted_vec);
        
        
        % % Compute equilibriums % %
        [c_aq_eq_c_,c_org_eq_c_,c_aq_eq_a_,c_org_eq_a_,success] = ...
            perchlorates_palgo_eq(c_aq_eq_c,c_org_eq_c,c_aq_eq_a,c_org_eq_a, ...
                                  c_aq_c,c_aq_a,c_org_c,c_org_a,...
                                  simulation);
            c_aq_eq_c = mavu(c_aq_eq_c_.value,c_aq_eq_c_.unit);
            c_org_eq_c = mavu(c_org_eq_c_.value,c_org_eq_c_.unit);
            c_aq_eq_a = mavu(c_aq_eq_a_.value,c_aq_eq_a_.unit);
            c_org_eq_a = mavu(c_org_eq_a_.value,c_org_eq_a_.unit);
        
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
            rterm = rmat*c_extracted_vec;
            eqterm = eqmat*c_extracted_vec_eq;
            [dcaqdt_rterm,daaqdt_rterm,dcorgdt_rterm,daorgdt_rterm] = state_derivative(rterm);
            [dcaqdt_eqterm,daaqdt_eqterm,dcorgdt_eqterm,daorgdt_eqterm] = state_derivative(eqterm);
            [dcaqdt_vec,daaqdt_vec,dcorgdt_vec,daorgdt_vec] = state_derivative(vec);
            % %  % %
    end


    %% %%  %% %%

    %% %% ODE solver %% %%
    options = odeset('Stats','off',...
            'NonNegative',1:8*(n_ext+3),...
            'NormControl',"on","JPattern",mask,...
            "RelTol",1e-1,"AbsTol",1e2);
    %[t,x_out] = ode15s(@(t,x) ddt_func(t,x),times,x_ini.value./scaler,options);
    [times,x_out] = perchlorates_palgo_ode_ss(@(t,x) ddt_func(t,x), x_ini.value./scaler,options);
    %[t,x_out] = ode45(@(t,x) ddt_func(t,x),times,x_ini.value./scaler,options);
    %[t,x_out] = ode89(@(t,x) ddt_func(t,x),times,x_ini.value./scaler,options);
    %% %%  %% %%
    
    state_update(mavu(x_out(end,:).*scaler',unit)) 
    c_aq_c_extracted = c_aq_c(1:n_c,:);
    c_aq_a_extracted = c_aq_a(1:n_a,:);
    c_org_c_extracted = c_org_c(1:n_c,:);
    c_org_a_extracted = c_org_a(1:n_a,:);

    if diagnostic
        dliaqdt = mavu([],dcaqdt_extracted_mat.unit);
        dcaaqdt = mavu([],dcaqdt_extracted_mat.unit);
        dmgaqdt = mavu([],dcaqdt_extracted_mat.unit);
        dclo4aqdt = mavu([],dcaqdt_extracted_mat.unit);
        dliorgdt = mavu([],dcaqdt_extracted_mat.unit);
        dcaorgdt = mavu([],dcaqdt_extracted_mat.unit);
        dmgorgdt = mavu([],dcaqdt_extracted_mat.unit);
        dclo4orgdt = mavu([],dcaqdt_extracted_mat.unit);
    
        dclo4aqdt_r = mavu([],dcaqdt_extracted_mat.unit);
        dclo4aqdt_e = mavu([],dcaqdt_extracted_mat.unit);
        dclo4aqdt_v = mavu([],dcaqdt_extracted_mat.unit);
    
        dclo4orgdt_r = mavu([],dcaqdt_extracted_mat.unit);
        dclo4orgdt_e = mavu([],dcaqdt_extracted_mat.unit);
        dclo4orgdt_v = mavu([],dcaqdt_extracted_mat.unit);
        for j=1:length(x_out(:,1))
            x = x_out(j,:);
            dxdt = ddt_func(times(j),x');
            [dcaqdt,daaqdt,dcorgdt,daorgdt] = state_derivative(mavu(dxdt,dcaqdt_extracted_mat.unit));
            dliaqdt = [dliaqdt;dcaqdt(1,:)];
            dcaaqdt = [dcaaqdt;dcaqdt(2,:)];
            dmgaqdt = [dmgaqdt;dcaqdt(3,:)];
            dclo4aqdt = [dclo4aqdt;daaqdt(1,:)];
            dliorgdt = [dliorgdt;dcorgdt(1,:)];
            dcaorgdt = [dcaorgdt;dcorgdt(2,:)];
            dmgorgdt = [dmgorgdt;dcorgdt(3,:)];
            dclo4orgdt = [dclo4orgdt;daorgdt(1,:)];
    
            [dcaqdt_rterm,daaqdt_rterm,dcorgdt_rterm,daorgdt_rterm,...
             dcaqdt_eqterm,daaqdt_eqterm,dcorgdt_eqterm,daorgdt_eqterm,...
             dcaqdt_vec,daaqdt_vec,dcorgdt_vec,daorgdt_vec] = state_derivative_terms(x');
    
            dclo4orgdt_r = [dclo4orgdt_r;daorgdt_rterm(1,:)];
            dclo4orgdt_e = [dclo4orgdt_e;daorgdt_eqterm(1,:)];
            dclo4orgdt_v = [dclo4orgdt_v;daorgdt_vec(1,:)];
    
            dclo4aqdt_r = [dclo4aqdt_r;daaqdt_rterm(1,:)];
            dclo4aqdt_e = [dclo4aqdt_e;daaqdt_eqterm(1,:)];
            dclo4aqdt_v = [dclo4aqdt_v;daaqdt_vec(1,:)];
        end
        
        stages = arrayfun(@(n) sprintf('stage %d', n), 1:n_ext+3, 'UniformOutput', false);
    
        mvu_scatter(mvu(times,' s'),dliaqdt','Time','dLi_{aq,stage}/dt', ...
                        'Aqueous Li derivatives', ...
                        stages)
        mvu_scatter(mvu(times,' s'),dcaaqdt','Time','dCa_{aq,stage}/dt', ...
                        'Aqueous Ca derivatives', ...
                        stages)
        mvu_scatter(mvu(times,' s'),dmgaqdt','Time','dMg_{aq,stage}/dt', ...
                        'Aqueous Mg derivatives', ...
                        stages)
        mvu_scatter(mvu(times,' s'),dclo4aqdt','Time','dClO4_{aq,stage}/dt', ...
                        'Aqueous ClO4 derivatives', ...
                        stages)
    
    
        mvu_scatter(mvu(times,' s'),dliorgdt','Time','dLi_{org,stage}/dt', ...
                        'Organic Li derivatives', ...
                        stages)
        mvu_scatter(mvu(times,' s'),dcaorgdt','Time','dCa_{org,stage}/dt', ...
                        'Organic Ca derivatives', ...
                        stages)
        mvu_scatter(mvu(times,' s'),dmgorgdt','Time','dMg_{org,stage}/dt', ...
                        'Organic Mg derivatives', ...
                        stages)
        mvu_scatter(mvu(times,' s'),dclo4orgdt','Time','dClO4_{org,stage}/dt', ...
                        'Organic ClO4 derivatives', ...
                        stages)
        
    
        mvu_scatter(mvu(times,' s'),dclo4aqdt_r','Time','Value', ...
                        'ClO4 aq rterm', ...
                        stages)
        mvu_scatter(mvu(times,' s'),dclo4aqdt_e','Time','Value', ...
                        'ClO4 aq eqterm', ...
                        stages)
        mvu_scatter(mvu(times,' s'),dclo4aqdt_v','Time','Value', ...
                        'ClO4 aq vec', ...
                        stages)
    
        mvu_scatter(mvu(times,' s'),dclo4orgdt_r','Time','Value', ...
                        'ClO4 org rterm', ...
                        stages)
        mvu_scatter(mvu(times,' s'),dclo4orgdt_e','Time','Value', ...
                        'ClO4 org eqterm', ...
                        stages)
        mvu_scatter(mvu(times,' s'),dclo4orgdt_v','Time','Value', ...
                        'ClO4 org vec', ...
                        stages)
    end
end