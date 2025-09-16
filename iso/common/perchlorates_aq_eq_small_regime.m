function c_aq_eq = perchlorates_aq_eq_small_regime(c_aq_prior,c_org_posterior,c_org_current,OA)
%perchlorates_aq_eq_small_regime defunct
c_aq_eq = c_aq_prior - OA.*(c_org_current-c_org_posterior);
end