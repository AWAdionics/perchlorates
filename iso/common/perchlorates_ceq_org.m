function c_org_eq = perchlorates_ceq_org(c_aq_eq,c_aq_ini,c_org_ini,OA)
%perchlorates_ceq_aq given organic and prior section, computes aq eq
arguments (Input)
    c_aq_eq MatrixValueUnit
    c_aq_ini MatrixValueUnit
    c_org_ini MatrixValueUnit
    OA MatrixValueUnit
end
    AO = mvu(1,'')./OA;
    c_org_eq = AO.*c_aq_ini - (AO.*c_aq_eq - c_org_ini);
end