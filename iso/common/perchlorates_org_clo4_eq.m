function error = perchlorates_org_clo4_eq(ca_org_eq,yc_aq_eq,ya_aq_eq,zc,Kapps,gammas)
%perchlorates_org_eq 

    arguments (Input)
        ca_org_eq MatrixValueUnit
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
    %LHS = (one+sum(kapp_term)).*cc_org_eq;
    %RHS = c_exctot.*kapp_term;
    %error = LHS-RHS;
    
    %true_ratio = ca_org_eq./c_exctot;
    %estimated_ratio = kapp_term./(one+sum(kapp_term));
    %error = mvu(100,'')*(true_ratio-sum(zc.*estimated_ratio));

    estimated_ratio = kapp_term./(one+sum(kapp_term));
    error = ca_org_eq-sum(zc.*estimated_ratio).*c_exctot;
end