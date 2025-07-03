function error = perchlorates_aq_eq(y_aq_eq,c_org_eq,c_aq_ini,rho,OA)
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
LHS = y_aq_eq.*rho;
RHS = c_aq_ini - OA.*c_org_eq;
error = LHS-RHS;
end