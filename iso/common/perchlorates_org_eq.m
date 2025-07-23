function error = perchlorates_org_eq(cc_org_eq,yc_aq_eq,ya_aq_eq,zc,Kapps,gammas)
%perchlorates_org_eq 

    arguments (Input)
        cc_org_eq MatrixValueUnit
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
    %at = gammas.^(zc+one).*yc_aq_eq./y0.*(ya_aq_eq./y0).^zc
    kapp_term = Kapps.*gammas.^(zc+one).*yc_aq_eq./y0.*(ya_aq_eq./y0).^zc;
    LHS = (one+sum(kapp_term));
    RHS = c_exctot.*kapp_term./cc_org_eq;
    %tri = kapp_term/(one+sum(kapp_term))*c_exctot;
    error = LHS-RHS;
end