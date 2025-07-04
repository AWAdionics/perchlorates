classdef TestPerchloratesCommon < matlab.unittest.TestCase
    %TestPerchloratesCommon Test Suite for common perchlorates
    methods (Test)
        function density(testCase)
            rho = mvu(1e3,'kg/ L');
            cc =  mvu([3;5],'mmol/ L');
            Mc =  mvu([13;17],'kg/mmol');
            ca =  mvu([7;11],'mmol/ L');
            Ma =  mvu([19;23],'kg/mmol');
            trial = perchlorates_density(rho,cc,ca,Mc,Ma);
            truth = mvu(1e3 - (3*13+5*17+7*19+11*23),'kg_eau/ L');
            testCase.verifyEqual(trial,truth)
        end

        function cclo4_eq_org(testCase)
           zc = mvu([1,2,3],'');
           cc = mvu([4,5,6],'mmol/ L');
           trial = perchlorates_cclo4_eq_org(zc,cc);
           truth = mvu(32,'mmol/ L');
           testCase.verifyEqual(trial,truth)
        end

        function perchlorates_ctoy(testCase)
            cs = mvu([8,4],'mmol/ L');
            rho = mvu(2,'kg_eau/ L');
            trial = perchlorates_ctoy(cs,rho);
            truth = mvu([4,2],'mmol/kg_eau');
            testCase.verifyEqual(trial,truth)
        end

        function perchlorates_ytoc(testCase)
            ys = mvu([8,4],'mmol/kg_eau');
            rho = mvu(2,'kg_eau/ L');
            trial = perchlorates_ytoc(ys,rho);
            truth = mvu([16,8],'mmol/ L');
            testCase.verifyEqual(trial,truth)
        end

        function perchlorates_aq_eq(testCase)
            y_aq_eq = mvu([1,2],'mmol/kg_eau');
            rho =  mvu(3,'kg_eau/ L');
            c_aq_ini = mvu([1,1],'mmol/ L');
            OA = mvu(4,'');
            c_org_eq = mvu([1,2],'mmol/ L');
            trial = perchlorates_aq_eq(y_aq_eq,c_org_eq,c_aq_ini,rho,OA);
            truth = mvu([6,13],'mmol/ L');
            testCase.verifyEqual(trial,truth)
        end

        function perchlorates_org_eq(testCase)
            Kapps = mvu([1;2],'');
            gammas = mvu([1/3;1/2],'');
            zc = mvu([1;2],'');
            yc = mvu([500;250],'mmol/kg_eau');
            ya = mvu(500,'mmol/kg_eau');
            cc = mvu([50;100],'mmol/ L');
            trial = perchlorates_org_eq(cc,yc,ya,zc,Kapps,gammas);
            lhs_mult =1 +(1/36+1/64);
            truth = mvu([lhs_mult*50-150/36;lhs_mult*100-150/64],'mmol/ L');
            testCase.verifyEqual(trial,truth)
        end
    end
end