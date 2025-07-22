function simulation = perchlorates_mss_make(case_name)
    %sulfates_mss_make makes the simulation struct for multisel 
    %
    %   Args :
    %       casename : char of casename in input/excel/perchlorates_mss_casename.xslx
    %
    %   Returns :
    %       simulation : struct containing simulation data
    %
    %   see also sulfates_ms_index (index)
    %   sulfates_excel_read (used)
    %   sulfates_density (used)
    
    excel_name = [NamesMssPerchlorates.excel_name,'_',case_name,'.xlsx'];
    cations = NamesMssPerchlorates.cations;
    anions = NamesMssPerchlorates.anions;
    cations_extracted = NamesMssPerchlorates.cations_extracted;
    anions_extracted = NamesMssPerchlorates.anions_extracted;
    aqini_name = NamesMssPerchlorates.aqini_name;
    orgini_name = NamesMssPerchlorates.orgini_name;
    aqeq_name = NamesMssPerchlorates.aqeq_name;
    orgeq_name = NamesMssPerchlorates.orgeq_name;
    mass_name = NamesMssPerchlorates.mass_name;
    kapp_name = NamesMssPerchlorates.kapp_name;
    temperature_name = NamesMssPerchlorates.temperature_name;
    max_row = NamesMssPerchlorates.max_row;
    max_col = NamesMssPerchlorates.max_col;
    OA_name = NamesMssPerchlorates.OA_name;
    molar_mass = ConstantsIonsPitzer.molar_mass;


    

    simulation = struct('pitzer', ...
                        struct(), ...
                        'input', ...
        struct('ini',struct(),'aqeq',struct(),'orgeq',struct(),'T',mvu(293.15,' K')), ...
                        'ions',...
        struct('M',struct()),...
                        'constants', ...
        struct('OA',struct()) ...
                       );

    name_row = perchlorates_excel_read(excel_name,'Data',[1],[1:max_col],false);
    unit_row = perchlorates_excel_read(excel_name,'Data',[2],[1:max_col],false);
    values = perchlorates_excel_read(excel_name,'Data',[3:max_row],[1:max_col],true);

    for i=1:length(name_row)
        switch true 
            case endsWith(name_row{i},aqini_name)
                %initializing at aq
                ion = erase(name_row{i}, aqini_name);
                simulation.input.aqini.(ion) = mvu(values(:,i),unit_row{i});
                %if initializng at aq, ini org is 0
                simulation.input.orgini.(ion) = mvu(0*values(:,i),unit_row{i});
            case endsWith(name_row{i},orgini_name)
                %initializing at org
                ion = erase(name_row{i}, orgini_name);
                simulation.input.aqini.(ion) = mvu(values(:,i),unit_row{i});
                %if initializng at org, ini aq is 0
                simulation.input.orgini.(ion) = mvu(0*values(:,i),unit_row{i});
            case endsWith(name_row{i},aqeq_name)
                %equilibrium
                ion = erase(name_row{i}, aqeq_name);
                simulation.input.aqeq.(ion) = mvu(values(:,i),unit_row{i});
            case endsWith(name_row{i},orgeq_name)
                %equilibrium
                ion = erase(name_row{i}, orgeq_name);
                simulation.input.orgeq.(ion) = mvu(values(:,i),unit_row{i});
            case strcmp(name_row{i},mass_name)
                simulation.input.brinemass = mvu(values(:,i),unit_row{i});
            case strcmp(name_row{i},OA_name)
                simulation.input.OA = mvu(values(:,i),'');
            case strcmp(name_row{i},temperature_name)
                simulation.input.T = mvu(values(:,i),[' ',unit_row{i}]);
                simulation.input.T = simulation.input.T.kelvin();
            case endsWith(name_row{i},kapp_name)
                ion = erase(name_row{i},kapp_name);
                simulation.input.Kapps.(ion) = mvu(values(:,i),'');
        end
    end
    
    % reorganize into mss simulation format
    %molar masses
    n = length(values(:,i));
    for i=1:length(cations)
        ion = cations{i};
        simulation.ions.M.(ion) = mavu(molar_mass.(ion).value+zeros(n,1),molar_mass.(ion).unit);
    end
    for i=1:length(anions)
        ion = anions{i};
        simulation.ions.M.(ion) = mavu(molar_mass.(ion).value+zeros(n,1),molar_mass.(ion).unit);
    end

    %ions
    simulation.constants.cations = cations;
    simulation.constants.anions = anions;
    simulation.constants.cations_extracted = cations_extracted;
    simulation.constants.anions_extracted = anions_extracted;
    simulation.constants.OA = simulation.input.OA';
    
    %charge vector
    zcs = mvu([],'');
    for i=1:length(cations_extracted)
        cation = cations_extracted{i};
        zcs = [zcs;mvu(ConstantsPitzer.charges.(cation),'')];
    end
    simulation.constants.zc = zcs;
    
    %Kapp VECTOR
    simulation.constants.Kapp = mvu([],'');
    for i=1:length(cations_extracted)
        ion = cations{i};
        simulation.constants.Kapp = [simulation.constants.Kapp;simulation.input.Kapps.(ion)'];
    end
    
    %pitzer model
    simulation.pitzer = pitzer_make(cations,anions);

    %construct feed matrices
    feed_aq_c = cellfun(@(k) simulation.input.aqini.(k),  ...
                               simulation.constants.cations, ...
                               'UniformOutput', false);
    feed_aq_c = [feed_aq_c{:}]';
    simulation.constants.feed_aq_c = feed_aq_c;
    feed_aq_a = cellfun(@(k) simulation.input.aqini.(k),  ...
                              simulation.constants.anions, ...
                              'UniformOutput', false);
    feed_aq_a = [feed_aq_a{:}]';
    simulation.constants.feed_aq_a = feed_aq_a;
    feed_org_c = cellfun(@(k) simulation.input.orgini.(k),  ...
                               simulation.constants.cations, ...
                               'UniformOutput', false);
    feed_org_c = [feed_org_c{:}]';
    simulation.constants.feed_org_c = feed_org_c;
    feed_org_a = cellfun(@(k) simulation.input.orgini.(k),  ...
                              simulation.constants.anions, ...
                              'UniformOutput', false);
    feed_org_a = [feed_org_a{:}]';
    simulation.constants.feed_org_a = feed_org_a;
    %equlibriums
    aqeq_c = cellfun(@(k) simulation.input.aqeq.(k),  ...
                               simulation.constants.cations, ...
                               'UniformOutput', false);
    aqeq_c = [aqeq_c{:}]';
    simulation.constants.aqeq_c = aqeq_c;
    aqeq_a = cellfun(@(k) simulation.input.aqeq.(k),  ...
                              simulation.constants.anions, ...
                              'UniformOutput', false);
    aqeq_a = [aqeq_a{:}]';
    simulation.constants.aqeq_a = aqeq_a;
    orgeq_c = cellfun(@(k) simulation.input.orgeq.(k),  ...
                               simulation.constants.cations, ...
                               'UniformOutput', false);
    orgeq_c = [orgeq_c{:}]';
    simulation.constants.orgeq_c = orgeq_c;
    orgeq_a = cellfun(@(k) simulation.input.orgeq.(k),  ...
                              simulation.constants.anions, ...
                              'UniformOutput', false);
    orgeq_a = [orgeq_a{:}]';
    simulation.constants.orgeq_a = orgeq_a;

    

    %molar mass vectors
    cations_M = cellfun(@(k) simulation.ions.M.(k),  ...
                             simulation.constants.cations, ...
                             'UniformOutput', false);
    cations_M = [cations_M{:}]';
    anions_M  = cellfun(@(k) simulation.ions.M.(k),  ...
                             simulation.constants.anions, ...
                             'UniformOutput', false);
    anions_M = [anions_M{:}]';

    %

    %precompute
    
    %density
    n = length(simulation.input.aqini.Li);
    rhoval = zeros(n,1);
    
    for i=1:n
        rhoval(i) = perchlorates_density( ...
                           simulation.input.brinemass(i), ... 
                           feed_aq_c(:,i), ...
                           feed_aq_a(:,i), ...
                           cations_M(:,i), ...
                           anions_M(:,i)).value;
    end
    simulation.constants.rho = mvu(rhoval,'kg_eau/ L')';
    simulation.constants.n = n;
    %
end