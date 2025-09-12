function [A,b,ub] = perchlorates_org_fromaq_ub(c_aq_prior_c,c_org_posterior_c, ...
                                         c_aq_prior_a,c_org_posterior_a, ...
                                         zc,OA)
    ub = c_aq_prior_c./OA + c_org_posterior_c;
    A = zc';
    b = c_aq_prior_a./OA + c_org_posterior_a;
end