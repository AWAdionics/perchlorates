function c_aq_eq = perchlorates_ceq_aq(c_org_eq,c_aq_ini,OA)
%perchlorates_ceq_aq given organic and prior section, computes aq eq
arguments (Input)
    c_org_eq MatrixValueUnit
    c_aq_ini MatrixValueUnit
    OA MatrixValueUnit
end
    c_aq_eq = c_aq_ini - OA.*c_org_eq;
end