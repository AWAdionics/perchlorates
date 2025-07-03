function ys = perchlorates_ctoy(cs,rho)
%perchlorates_ctoy converts cs (mmol/L) to ys (mmol/kg_eau)
%
%   FORMULA:
%       y = c/rho
%
%   Args:
%       cs : mvu of concentrations in mmol/L to convert
%       rho : brine density as computed by perchlorates_density
%
%   Returns:
%       ys : mvu of concentrations in mmol/kg_eau
%
%   see also
    ys = cs./rho;
end