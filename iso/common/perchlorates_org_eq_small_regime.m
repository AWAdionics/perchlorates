function cc = perchlorates_org_eq_small_regime(c_aq_neq_prior,c_org_neq_post,yc,ya,OA,zc,Kapp,rho)
    y0 = ConstantsPerchlorates.y0;
    c_exctot = ConstantsPerchlorates.c_exctot;
    
    persistent one
    if isempty(one)
        one = mvu(1,'');
    end

    A = (y0./ya).^zc.*y0./(Kapp.*yc.*c_exctot);

    AO = one./OA;

    cc = one./(rho.*A+AO).*(c_aq_neq_prior-OA.*c_org_neq_post);
end