function rho = perchlorates_density(rho_brine_init,c_c_ini,c_a_ini,M_c,M_a,to_kg_eau)
    %perchlorates_density computes density of brine
    %
    % FORMULA
    %   rho = rho_brine_init - sum_{ion in all ions} c_ion,ini * M_ion
    %
    %   Args:
    %       rho_brine_init : mvu in kg/ L of density of brine
    %       c_c_ini : mvu of initial cation concentrations in mmol/ L
    %       c_a_ini : mvu of initial anion concentrations in mmol/ L
    %       M_c : mvu of molar mass of cations in g/mol
    %       M_a : mvu of molar mass of anions in g/mol
    %       to_kg_eau : optional (default True) bool indicating if output is in kg_eau/L or kg/L 
    %   Returns:
    %       rho : mvu in kg/L or kg_eau/L of density
    %
    %   see also 
    persistent converter
    if isempty(converter) 
        converter = mvu(1,'kg_eau/kg');
    end
    if nargin <= 5
        to_kg_eau = true;
    end
    rho = rho_brine_init - c_c_ini'*M_c - c_a_ini'*M_a;
    if to_kg_eau
        %converts mmol/kg -> mmol/kg_eau
        rho = rho.to('kg/ L').*converter;
    end
end