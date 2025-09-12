function c_aq_eq = perchlorates_aq_eq_small_regime(c_aq_prior,c_org_posterior,c_org_current,OA)
%perchlorates_aq_eq computes the equilibrium error for the aqueous phase
%
%   Args:
%       y_aq_eq : mvu in mmol/kg_eau of concentrations in aq phase
%       c_org_eq : mvu in mmol/L of concentrations in org phase
%       c_aq_ini : mvu in mmol/L of concentrations in initial aq phase
%       rho : mvu in kg_eau/ L of brine density
%       OA : mvu unitless of O/A
%
%   Returns:
%       error : mvu in mmol/L of equilibrium error in aqueous phase
%
%   see also
c_aq_eq = c_aq_prior - OA.*(c_org_current-c_org_posterior);
end