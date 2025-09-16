%to compute optimized kapp for monosel
[kapp_opt, error_opt] = perchlorates_ms_kapp('mg80'); %replace input by relevant casename (perchlorates_ms_casename)
%this is an initial Kapp to put into the below

%to run monosel isothermes:
%input is an excel of the form perchlorates_ms_casename where casename is the
%name of the case (e.g. 20 => perchlorates_ms_20.xlsx)
%excel contains isothermes initial data, experimental data and a user
%defined Kapp (initialized by the results from perchlorates_ms_kapp) 
perchlorates_ms_iso('mg80') %replace input by relevant casename
%modify kapp until it matches experimental isothermes

%to compute optimized kapp for multisel
[kapp_opt, error_opt] = perchlorates_mss_kapp('40'); %replace input by relevant casename (perchlorates_ms_casename)
%this is an initial Kapp to put into the below

%to run multisel isothermes:
%input is an excel of the form perchlorates_ms_casename where casename is the
%name of the case (e.g. 40 => perchlorates_mss_40.xlsx)
%excel contains isothermes initial data, experimental data and a user
%defined Kapp (initialized by the results from perchlorates_mss_kapp) 
perchlorates_mss_iso('40') %replace input by relevant casename (perchlorates_ms_casename)
%modify kapp until it matches experimental isothermes


%To run process:
%go into input/excel and edit the perchlorates_p_input.xlsx file as appopriate
%(maintain template, else code will not work)
%run:
perchlorates_prun_run()
%then go into output/excel and look for perchlorates_p_output.xlsx for results
%alternatively go to archive/excel and look for end_time_and_date_p_output
%In both cases there will be a p_input sheet and a p_output sheet, the
%former contains the inputs giving the latter in the same order

%IMPORTANT
%in the event of some issue it may be necessary to employ optional
%arguments
%lines (default -1), allows the user to specify which lines to run
%perchlorates_prun_run(lines,ode_tolerance,max_steps,diagnostic,killall)
%ode_tolerance (default 1e-1) is the tolerance below which the problem is
%solved
%max_steps (default 300) is the maximum number of ode steps allowed
%diagnostic (default false) makes the program return diagnostics for every
%time step, that is graphs detailing different ode terms, very slow.
%killall (default false), kills all excels

%for optimizing ak constants, run perchlorates_prun_run for different aks until it
%matches experimental data
%real simulations can be run once ak constants optimized


%to merely run, this is all that is required
%should there be a bug or further issues a programmer will be needed
%automatic documentation is provided