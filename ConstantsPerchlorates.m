classdef ConstantsPerchlorates
    properties (Constant)
        Tref = mvu(20,' C')
        Treg = mvu(80,' C')
        Cations = {'Li','Na','K','Mg','Ca'}
        Anions = {'ClO4','Cl','SO4','NO3'}
        ExtractedCations = {'Li','Ca','Mg'}
        ExtractedAnions = {'ClO4'}
        c0 = mvu(1000,'mmol/ L')
        y0 = mvu(1000,'mmol/kg_eau')
        Qorg = mvu(6.67e-7,' m^3/ s')
        Vmix = mvu(1.7e-4,' m^3')
        ak_ext = mvu(1.8e-2,'/ s')
        ak_rege = mvu(2*2.18,'/ s') %2.4222*1.8e-2 is more likely

        %Process only
        TKapp1 = mvu(20,' C')
        TKapp2 = mvu(80,' C')
        Kapp1 = mvu(19006.279,'')
        Kapp2 = mvu(95.025,'')
        small_regime = mvu(0.001,'')
    end
end