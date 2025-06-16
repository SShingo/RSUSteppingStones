%macro rsu_steppingstones_activate_test(i_version =);
	%if (%sysevalf(%superq(i_version) =, boolean)) %then %do;
		%put ERROR: Argument "i_version = ***"(3 digits integer) is required;
	%end;
	%else %do;
		%include "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./RSU_DevModule_Boxing_Tool.sas";
		%DoBoxing(i_module_root_dir = &G_SAS_RSU_DEV_MODULE_ROOT_DIR.
					, i_module_dataset_name = rsu_stepping_stones
					, i_version = v&i_version.)
		%rsu_steppingstones_activate(i_dir = &G_SAS_RSU_DEV_MODULE_ROOT_DIR./developing
											, i_version = &i_version.
											, i_execution_mode = DEBUG
											, i_recreate_suppl_ds = 1)
	%end;
%mend rsu_steppingstones_activate_test;
