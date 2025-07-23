classdef ConstantsPerchlorates
    properties (Constant)
        Tref = mvu(40,' C')
        Treg = mvu(80,' C')
        cations = {'Li','Ca','Mg' ... %Extracted
                   ,'Na','K'}         %Not Extracted
        anions = {'ClO4',...          %Extracted
                  'Cl','NO3','SO4'}     %Not Extracted
        cations_extracted = {'Li','Ca','Mg'}
        anions_extracted = {'ClO4'}
        c0 = mvu(1000,'mmol/ L')
        y0 = mvu(1000,'mmol/kg_eau')
        Qorg = mvu(6.67e-7,' m^3/ s')
        Vmix = mvu(1.7e-4,' m^3')
        ak_ext = mvu(1.8e-2,'/ s')
        ak_rege = mvu(2*2.18,'/ s') %2.4222*1.8e-2 is more likely
        c_exctot = mvu(50,'mmol/ L')

        %Process only
        TKapp1 = mvu(40,' C')
        TKapp2 = mvu(80,' C')
        Kapp1 = mvu([40113,2342300,23581000],'')
        Kapp2 = mvu([25.81038,53.56554,83.3374],'')
    end
end