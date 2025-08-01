function cclo4_eq_org = perchlorates_cclo4_eq_org(zcations,ccations_eq_org)
%cclo4_eq_org computes c^eq_{clo4 org} from cation equilibriums in org
%
%   FORMULA:
%       c^eq_{clo4 org} = sum_{c in extracted cations} z_c c^eq_{c org}
%
%   Args:
%       zcations: mvu of unitless charge of all cations
%       ccations_eq_org: mvu in mmol/ L of cations in org phase at equilibrium
%
%   Returns:
%       cclo4_eq_org : mvu in mmol/L of ClO4 in org phase at equilibrium
%
%   see also
    cclo4_eq_org = sum(zcations.*ccations_eq_org);
end