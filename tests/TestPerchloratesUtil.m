classdef TestPerchloratesUtil < matlab.unittest.TestCase
    %TestPerchloratesUtil Test Suite for perchlorates_excel_index
    methods (Test)
        function test_excel_read(testCase)
            trial = perchlorates_excel_read('testread.xlsx','Data',[3:8],[1:6]);
            truth = [1,0,0,0,0,1;
                     0,1,0,0,0,0;
                     0,0,1,0,0,0;
                     0,0,0,1,0,0;
                     0,0,0,0,1,0;
                     0,0,0,0,0,1];
            testCase.verifyEqual(trial,truth);
        end

        function test_excel_copy(testCase)
            perchlorates_excel_copy('testread','Data','input','testwrite','Input','output')
            trial = perchlorates_excel_read('testwrite.xlsx','Input',[3,4,5,6,7,8], [1,2,3,4,5,6],true,true);
            truth = perchlorates_excel_read('testread.xlsx','Data',[3,4,5,6,7,8], [1,2,3,4,5,6],true,false);
            testCase.verifyEqual(trial,truth);
        end

        function test_excel_writematrix(testCase)
            truth = [1,2,3,4,5,6;7,8,9,10,11,12;13,14,15,16,17,18];
            perchlorates_excel_writematrix(truth,'A3','testwrite.xlsx','Data')
            trial = perchlorates_excel_read('testwrite.xlsx','Data',[3,4,5], [1,2,3,4,5,6],true,true);
            testCase.verifyEqual(trial,truth);
        end

        function test_excel_writechar(testCase)
            char_cell_array = {'A1','B1','C1','A2','B2','C2','A3','B3','C3'};
            cells = {'A1','B1','C1','A2','B2','C2','A3','B3','C3'};
            perchlorates_excel_writechar(char_cell_array, cells,'testwrite.xlsx','Char')
            trial = perchlorates_excel_read('testwrite.xlsx','Char',[1,2,3], [1,2,3],false,true);
            truth = {'A1','B1','C1';'A2','B2','C2';'A3','B3','C3'};
            testCase.verifyEqual(trial,truth);
        end
        
        function test_excel_col(testCase)
            truth = 'J';
            trial = perchlorates_excel_col(10);
            testCase.verifyEqual(trial,truth);

            truth = 'AA';
            trial = perchlorates_excel_col(27);
            testCase.verifyEqual(trial,truth);
        end

        function test_excel_color(testCase) 
            perchlorates_excel_color({'A1','B1','C1'},[0,255,0],'testwrite.xlsx','Char','output')
            is_match = perchlorates_excel_colorcheck({'A1','B1','C1'},[0,255,0],'testwrite.xlsx','Char','output');
            testCase.verifyTrue(is_match)
        end

    end
end