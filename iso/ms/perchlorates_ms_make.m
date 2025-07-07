function simulation = perchlorates_ms_make(case_name)
    %sulfates_ms_make makes the simulation struct for monosel 
    %
    %   Args :
    %       casename : char of casename in input/excel/perchlorates_ms_casename.xslx
    %
    %   Returns :
    %       simulation : struct containing simulation data
    %
    %   see also sulfates_ms_index (index)
    %   sulfates_excel_read (used)
    %   sulfates_density (used)
    arguments (Input)
        case_name char
    end
    excel_name = [NamesMsPerchlorates.excel_name,'_',case_name,'.xlsx'];
    cations = NamesMsPerchlorates.cations;
    anions = NamesMsPerchlorates.anions;
    ini_name = NamesMsPerchlorates.ini_name;
    aqeq_name = NamesMsPerchlorates.aqeq_name;
    orgeq_name = NamesMsPerchlorates.orgeq_name;
    mass_name = NamesMsPerchlorates.mass_name;
    kapp_name = NamesMsPerchlorates.kapp_name;
    temperature_name = NamesMsPerchlorates.temperature_name;
    max_row = NamesMsPerchlorates.max_row;
    max_col = NamesMsPerchlorates.max_col;
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
    values = perchlorates_excel_read(excel_name,'Data',[3:max_row],[1:max_col]);

    for i=1:length(name_row)
        switch true 
            case endsWith(name_row{i},ini_name)
                ion = erase(name_row{i}, ini_name);
                %only 1 cation, others are 0
                %only 1 anion, no others
                if (ismember(ion,cations) && any(values(:,i) > 0)) || ismember(ion,anions)
                    simulation.input.ini.(ion) = mvu(values(:,i),unit_row{i});
                    %save name of cation for final display
                    if ismember(ion,cations)
                        simulation.input.cation = ion;
                        simulation.input.anion = 'ClO4';
                        simulation.pitzer = pitzer_make({ion},{'ClO4'});
                    end
                end
            case endsWith(name_row{i},aqeq_name)
                ion = erase(name_row{i}, aqeq_name);
                %only 1 cation, others are 0
                %only 1 anion, no others
                if (ismember(ion,cations) && any(values(:,i) > 0)) || ismember(ion,anions)
                    simulation.input.aqeq.(ion) = mvu(values(:,i),unit_row{i});
                end
            case endsWith(name_row{i},orgeq_name)
                ion = erase(name_row{i}, orgeq_name);
                %only 1 cation, others are 0
                %only 1 anion, no others
                if (ismember(ion,cations) && any(values(:,i) > 0)) || ismember(ion,anions)
                    simulation.input.orgeq.(ion) = mvu(values(:,i),unit_row{i});
                end
            case strcmp(name_row{i},mass_name)
                simulation.input.brinemass = mvu(values(:,i),unit_row{i});
            case strcmp(name_row{i},temperature_name)
                simulation.input.T = mvu(values(:,i),[' ',unit_row{i}]);
                simulation.input.T = simulation.input.T.kelvin();
            case strcmp(name_row{i},kapp_name)
                simulation.input.Kapp = mvu(values(:,i),'');
        end
    end
    
    n = length(values(:,i));
    for i=1:length(cations)
        ion = cations{i};
        simulation.ions.M.(ion) = mavu(molar_mass.(ion).value+zeros(n,1),molar_mass.(ion).unit);
    end
    for i=1:length(anions)
        ion = anions{i};
        simulation.ions.M.(ion) = mavu(molar_mass.(ion).value+zeros(n,1),molar_mass.(ion).unit);
    end
    
    simulation.constants.OA = mvu(1,'');
    simulation.constants.cations = NamesMsPerchlorates.cations;
    simulation.constants.anions = NamesMsPerchlorates.anions;

    %precompute

    %feeds
    feed_c = cellfun(@(k) simulation.input.ini.(k),  ...
                               {simulation.input.cation}, ...
                               'UniformOutput', false);
    feed_c = [feed_c{:}]';
    feed_a = cellfun(@(k) simulation.input.ini.(k),  ...
                              simulation.constants.anions, ...
                              'UniformOutput', false);
    feed_a = [feed_a{:}]';
    %

    %molar mass vectors
    cations_M = cellfun(@(k) simulation.ions.M.(k),  ...
                             {simulation.input.cation}, ...
                             'UniformOutput', false);
    cations_M = [cations_M{:}]';
    anions_M  = cellfun(@(k) simulation.ions.M.(k),  ...
                             simulation.constants.anions, ...
                             'UniformOutput', false);
    anions_M = [anions_M{:}]';


    n = length(simulation.input.ini.Li);
    rhoval = zeros(n,1);
    
    for i=1:n
        rhoval(i) = perchlorates_density( ...
                           simulation.input.brinemass(i), ... 
                           feed_c(:,i), ...
                           feed_a(:,i), ...
                           cations_M(:,i), ...
                           anions_M(:,i)).value;
    end
    simulation.constants.rho = mvu(rhoval,'kg_eau/ L');
    simulation.constants.n = n;
end