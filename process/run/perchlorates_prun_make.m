function simulations = perchlorates_prun_make(lines)
    %perchlorates_prun_make makes the list of simulation structs for process
    %
    %   Args:
    %       lines : line to make a simulation from
    %   Returns :
    %       simulation : struct containing simulation data
    %
    %   see also sulfates_p_run_index (index)
    %   sulfates_p_run (called)
    
    if nargin < 1
        lines = 3:NamesPrunPerchlorates.max_row;
    end
    

    name = NamesPrunPerchlorates.input_name;

    name_row = perchlorates_excel_read(name,'p_input', ...
                                   [1], ...
                                   [1:NamesPrunPerchlorates.max_col],false);
    unit_row = perchlorates_excel_read(name,'p_input', ...
                                   [2], ...
                                   [1:NamesPrunPerchlorates.max_col],false);
    
    values = perchlorates_excel_read(name,'p_input', ...
                                 lines, ...
                                 [1:NamesPrunPerchlorates.max_col]);
    shape = size(values);
    n_lines = shape(1);
    
    
    simulations = [];
    for j=1:n_lines
        line = lines(j);
        
        %% make simulation object %%
        simulation = ...
            struct( ...
                    'line',...
                    line,...
                    'pitzer', ...
                    struct(), ...
                   'input', ...
                   struct('ext_feed',struct(),'rege_feed',struct()),...
                   'constants', ...
                   struct(), ...
                   'ions', ...
                   struct('M',struct()) ...
                   );
        %% %%

        %% %%
        cations_on_file = ConstantsPerchlorates.cations;
        anions_on_file = ConstantsPerchlorates.anions;
        simulation.constants.cations = {};
        simulation.constants.anions = {};
        simulation.constants.cations_extracted = ConstantsPerchlorates.cations_extracted;
        simulation.constants.anions_extracted = ConstantsPerchlorates.anions_extracted;
        output_unit = 0;
        output_unit_set = false;
        %% %%
        
        %% iterate of columns and fill in inputs on the fly %%
        for i=1:length(name_row)
            switch true
                case endsWith(name_row{i},NamesPrunPerchlorates.extfeed_name)
                    %save extraction feed under this ion
                    ion = erase(name_row{i},NamesPrunPerchlorates.extfeed_name);
                    simulation.input.ext_feed.(ion) = ...
                        mvu(values(j,i),unit_row{i});
                    %add cation
                    if ismember(ion,cations_on_file)
                        simulation.constants.cations{end+1} = ion;
                    else 
                        if ismember(ion,anions_on_file)
                            simulation.constants.anions{end+1} = ion;
                        else
                            error('InputFile:IonNotOnFile',['Ion ',ion, 'is not on file, either it is missing from NanesPSulfates or it is missing from Pitzer.'])
                        end
                    end
                    if ~output_unit_set
                        output_unit = simulation.input.ext_feed.(ion).unit;
                        output_unit_set = true;
                    end
                case endsWith(name_row{i},NamesPrunPerchlorates.regefeed_name)
                    %save regeneration feed under this ion
                    simulation.input.rege_feed.(erase(name_row{i},NamesPrunPerchlorates.regefeed_name)) = ...
                        mvu(values(j,i),unit_row{i});
                case strcmp(name_row{i},NamesPrunPerchlorates.extmass_name)
                    %brine mass for extraction
                    simulation.input.ext_brinemass = mvu(values(j,i),unit_row{i});
                case strcmp(name_row{i},NamesPrunPerchlorates.regemass_name)
                    %brine mass for regeneration
                    simulation.input.rege_brinemass = mvu(values(j,i),unit_row{i});
                case strcmp(name_row{i},NamesPrunPerchlorates.temperature_ext_name)
                    %temperature for extraction
                    simulation.input.ext_T = mvu(values(j,i),[' ',unit_row{i}]);
                    simulation.input.ext_T = simulation.input.ext_T.kelvin();
                case strcmp(name_row{i},NamesPrunPerchlorates.temperature_rege_name)
                    %temperature for regeneration
                    simulation.input.rege_T = mvu(values(j,i),[' ',unit_row{i}]);
                    simulation.input.rege_T = simulation.input.rege_T.kelvin();
                case strcmp(name_row{i},NamesPrunPerchlorates.oa_ext_name)
                    %O/A for extraction
                    simulation.input.ext_OA = mvu(values(j,i),'');
                case strcmp(name_row{i},NamesPrunPerchlorates.oa_rege_name)
                    %O/A for regeneration
                    simulation.input.rege_OA = mvu(values(j,i),'');
                case strcmp(name_row{i},NamesPrunPerchlorates.n_ext_name)
                    %number of extractions (always 3 regenerations)
                    simulation.input.n_ext = values(j,i);
                    n_ext = values(j,i);
                case strcmp(name_row{i},NamesPrunPerchlorates.ext_ak_name)
                    %get first Kapp (typically extraction)
                    simulation.input.ext_ak = mvu(values(j,i),unit_row{i});
                case strcmp(name_row{i},NamesPrunPerchlorates.rege_ak_name)
                    %get second Kapp (typically regeneration)
                    simulation.input.rege_ak = mvu(values(j,i),unit_row{i});
            end
        end
        simulation.input.output_unit = output_unit;
        %% %%

        %% Make Pitzer
        simulation.pitzer = pitzer_make(simulation.constants.cations, ...
                                        simulation.constants.anions);
        %%

        %% Now compute constants (which do not change in 1 simulation) %%
        n = 1;
        % O/A %
        simulation.constants.OA = [repmat(simulation.input.ext_OA,n_ext,1);
                               repmat(simulation.input.rege_OA,3,1)];
        % %

        % rho and feeds %
        
        %reorg initials into matrix for solver
        ext_feed_aq_c = cellfun(@(k) simulation.input.ext_feed.(k),  ...
                                   simulation.constants.cations, ...
                                   'UniformOutput', false);
        ext_feed_aq_c = [ext_feed_aq_c{:}]';
        ext_feed_aq_a = cellfun(@(k) simulation.input.ext_feed.(k),  ...
                                  simulation.constants.anions, ...
                                  'UniformOutput', false);
        ext_feed_aq_a = [ext_feed_aq_a{:}]';
    
        rege_feed_aq_c = cellfun(@(k) simulation.input.rege_feed.(k),  ...
                                   simulation.constants.cations, ...
                                   'UniformOutput', false);
        rege_feed_aq_c = [rege_feed_aq_c{:}]';
        rege_feed_aq_a = cellfun(@(k) simulation.input.rege_feed.(k),  ...
                                  simulation.constants.anions, ...
                                  'UniformOutput', false);
        rege_feed_aq_a = [rege_feed_aq_a{:}]';
        
        %molar masses struct
        for i=1:length(simulation.constants.cations)
            ion = simulation.constants.cations{i};
            simulation.ions.M.(ion) = mavu(ConstantsIonsPitzer.molar_mass.(ion).value+zeros(n,1), ...
                                           ConstantsIonsPitzer.molar_mass.(ion).unit);
        end
        for i=1:length(simulation.constants.anions)
            ion = simulation.constants.anions{i};
            simulation.ions.M.(ion) = mavu(ConstantsIonsPitzer.molar_mass.(ion).value+zeros(n,1), ...
                                           ConstantsIonsPitzer.molar_mass.(ion).unit);
        end
        %molar mass vectors
        cations_M = cellfun(@(k) simulation.ions.M.(k),  ...
                             simulation.constants.cations, ...
                             'UniformOutput', false);
        cations_M = [cations_M{:}]';
        anions_M  = cellfun(@(k) simulation.ions.M.(k),  ...
                                 simulation.constants.anions, ...
                                 'UniformOutput', false);
        anions_M = [anions_M{:}]';
        
        %put into simulation
        simulation.constants.ext_feed_c = ext_feed_aq_c;
        simulation.constants.ext_feed_a = ext_feed_aq_a;
        simulation.constants.rege_feed_c = rege_feed_aq_c;
        simulation.constants.rege_feed_a = rege_feed_aq_a;
        simulation.constants.cations_M = cations_M;
        simulation.constants.anions_M = anions_M;
        
        %compute rho
        ext_rho = sulfates_density( ...
                               simulation.input.ext_brinemass, ... 
                               ext_feed_aq_c, ...
                               ext_feed_aq_a, ...
                               cations_M, ...
                               anions_M);
        rege_rho = sulfates_density( ...
                               simulation.input.rege_brinemass, ... 
                               ext_feed_aq_c, ...
                               ext_feed_aq_a, ...
                               cations_M, ...
                               anions_M);

        rho = [repmat(ext_rho,n_ext,1);repmat(rege_rho,3,1)];
        simulation.constants.rho = rho';
        % %

        % Construct Temperatures %
        T = [repmat(simulation.input.ext_T,n_ext,1);
             repmat(simulation.input.rege_T,3,1)];
        simulation.constants.T = T;
        % %

        % Construct Kapp %
        Kapp1 = ConstantsPerchlorates.Kapp1;
        TKapp1 = ConstantsPerchlorates.TKapp1;
        Kapp2 = ConstantsPerchlorates.Kapp2;
        TKapp2 = ConstantsPerchlorates.TKapp2;
        deltaH = pitzer_deltah(Kapp1,TKapp1,Kapp2,TKapp2);
        Kapp = pitzer_kapp(T,Kapp1,TKapp1,deltaH);
        simulation.constants.Kapp = Kapp';
        % %

        % Qorg, Qrege Qext %
        simulation.constants.Qorg = ConstantsPerchlorates.Qorg;
        simulation.constants.Qext = ConstantsPerchlorates.Qorg./simulation.input.ext_OA;
        simulation.constants.Qrege = ConstantsPerchlorates.Qorg./simulation.input.rege_OA;
        simulation.constants.n = n;
        simulation.constants.zc = simulation.pitzer.z_c;
        % %


        %% Add to simulations
        simulations = [simulations,simulation];
        %%
    end
end