function cs = perchlorates_ytoc(ys,rho)
%perchlorates_ytoc converts ys (mmol/L) to cs (mmol/kg_eau)
%
%   FORMULA:
%       c = y*rho
%
%   Args:
%       ys : mvu of concentrations in mmol/kg_eau
%       rho : brine density as computed by perchlorates_density
%
%   Returns:
%       cs : mvu of concentrations in mmol/L to convert
%
%   see also
    cs = ys.*rho;
end