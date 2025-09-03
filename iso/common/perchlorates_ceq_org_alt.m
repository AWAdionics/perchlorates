function cc_org_eq = perchlorates_ceq_org_alt(yc_aq_eq,ya_aq_eq,zc,Kapps,gammas)
%perchlorates_ceq_org_alt 

    arguments (Input)
        yc_aq_eq MatrixValueUnit
        ya_aq_eq MatrixValueUnit
        zc MatrixValueUnit
        Kapps MatrixValueUnit
        gammas MatrixValueUnit
    end
    persistent one
    if isempty(one)
        one = mvu(1,'');
    end
    y0 = ConstantsPerchlorates.y0;
    c_exctot = ConstantsPerchlorates.c_exctot;
    kapp_term = Kapps.*gammas.^(zc+one).*yc_aq_eq./y0.*(ya_aq_eq./y0).^zc;
    denom = (one+sum(kapp_term));
    num = c_exctot.*kapp_term;
    cc_org_eq = num./denom;


    
end