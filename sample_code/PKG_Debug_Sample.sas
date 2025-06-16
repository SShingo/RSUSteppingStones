%rsu_dev_module_activate_test(i_version = 200)

%macro DebugTest1(test =);
	%&RSUDebug.PutFootprint;
	%local _tmp_a;
	%let _tmp_a = SAS;
	%local _tmp_b;
	%let _tmp_b = Japan;
	%&RSUDebug.TakeMacroSnapshot(i_dir_path = /tmp)
	
	%local _tmp_c;
	%let _tmp_c = RSU;
	%let _tmp_b = Japan_institute;
	%&RSUDebug.TakeMacroSnapshot(i_dir_path = /tmp)
%mend DebugTest1;
%DebugTest1

%macro DebugTest2;
	libname L_TEST "/tmp/dir1" compress = yes;
	data L_TEST.tmp_ds1;
		set SASHELP.cars;
	run;
	quit;

	data L_TEST.tmp_ds2;
		set SASHELP.class;
	run;
	quit;

	%&RSUDebug.TakeDSSnapshot(i_dir_path = /tmp
									, i_libname = L_TEST)

	data L_TEST.tmp_ds2;
		set SASHELP.air;
	run;
	%&RSUDebug.TakeDSSnapshot(i_dir_path = /tmp
									, i_libname = L_TEST)

%mend DebugTest2;
%DebugTest2