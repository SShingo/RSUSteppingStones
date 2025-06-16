%macro Prv_RSUDebug_SetSequenceIndex(i_init_index =
												, i_index_var =);
	%if (not %&RSUMacroVariable.IsBlank(i_init_index)) %then %do;
		%let &i_index_var. = &i_init_index.;
	%end;
	%local /readonly _RSU_DEBUG_SEQUENCE_INDEX  = %sysfunc(putn(&&&i_index_var., Z3.));
	%let &i_index_var. = %eval(&&&i_index_var. + 1);
	&_RSU_DEBUG_SEQUENCE_INDEX.
%mend Prv_RSUDebug_SetSequenceIndex;

%macro Prv_RSUDebug_ShowFootprint(i_msg =
											, i_init_index =);
	%local /readonly _RSU_DEBUG_FOOTPRINT_INDEX = %Prv_RSUDebug_SetSequenceIndex(i_init_index = &i_init_index.
																										, i_index_var = RSU_g_sequence_footpint);
	%local /readonly _RSU_DEBUG_FOOTPRINT_BREADCRUMBS = %&RSUDebug.GetBreadcrumbs(i_depth_offset = -1);
	%Prv_RSULogger_OutputMsg(i_msg = &_RSU_DEBUG_FOOTPRINT_BREADCRUMBS. - (&_RSU_DEBUG_FOOTPRINT_INDEX.) &i_msg., i_msg_header_key = HEADER_DEBUG)
%mend Prv_RSUDebug_ShowFootprint;

%macro Prv_RSUDebug_TakeMacroSnapshot(i_is_global =
												, i_dir_path =
												, i_init_index =
												, i_suffix =
												, i_varname_regex =);
	/* マクロ一覧の出力ファイル確定 */
	%local _RSU_Debug_macro_scope;
	%if (&i_is_global. = 1) %then %do;
		%let _RSU_Debug_macro_scope = GLOBAL;
	%end;
	%else %do;
		%let _RSU_Debug_macro_scope = %sysmexecname(%sysmexecdepth - 2);
	%end;

	%local /readonly _RSU_DEBUG_MACRO_SNAPSHOT_INDEX = %Prv_RSUDebug_SetSequenceIndex(i_init_index = &i_init_index.
																												, i_index_var = RSU_g_sequence_macro_snapshot);
	%local _RSU_Debug_tmp_file_path;
	%if (%&RSUMacroVariable.IsBlank(i_suffix)) %then %do;
		%let _RSU_Debug_tmp_file_path = &i_dir_path./macro_var_&_RSU_Debug_macro_scope._&_RSU_DEBUG_MACRO_SNAPSHOT_INDEX..txt;
	%end;
	%else %do;
		%let _RSU_Debug_tmp_file_path = &i_dir_path./macro_var_&_RSU_Debug_macro_scope._&_RSU_DEBUG_MACRO_SNAPSHOT_INDEX._&i_suffix..txt;
	%end;

	/* put memo */
	%local /readonly _RSU_DEBUG_BREADCRUMBS = %&RSUDebug.GetBreadcrumbs(i_depth_offset = -1);
	%local _rd_fref;
	%let _rd_fref = %&RSUFile.GetFileRef(&_RSU_Debug_tmp_file_path.);
	data _null_;
		file &_rd_fref.;
		put "Snapshot at: &_RSU_DEBUG_BREADCRUMBS.(&_RSU_DEBUG_MACRO_SNAPSHOT_INDEX.)";
		put "Scope: &_RSU_Debug_macro_scope.";
	run;
	quit;

	%local /readonly _RSU_DEBUG_TMP_MACRO_LIST = %&RSUDS.GetTempDSName(); 
	data &_RSU_DEBUG_TMP_MACRO_LIST.;
		set SASHELP.vmacro(where = (scope = "&_RSU_Debug_macro_scope."));
	run;
	quit;
	
	%if (not %&RSUMacroVariable.IsBlank(i_varname_regex)) %then %do;
		data &_RSU_DEBUG_TMP_MACRO_LIST.;
			set &_RSU_DEBUG_TMP_MACRO_LIST.;
			_varname_regex = prxparse(cats('/', "&i_varname_regex.", '/o'));
			if (prxmatch(_varname_regex, name)) then do;
				output;
			end;
		run;
		quit;
		data _null_;
			file &_rd_fref. mod;
			put "Macro name filter: &i_varname_regex.";
		run;
		quit;
	%end;
	data _null_;
		attrib
			line length = $200.
		;
		file &_rd_fref. mod;
		set &_RSU_DEBUG_TMP_MACRO_LIST.;
		line = catx(&RSUTab., scope, name, value);
		put line;
	run;
	quit;
	%&RSUFile.ClearFileRef(_rd_fref)
	%&RSUDS.Delete(&_RSU_DEBUG_TMP_MACRO_LIST.)
%mend Prv_RSUDebug_TakeMacroSnapshot;

/*
	データセットのスナップショット
	NOTE: 指定ライブラリ内のデータセットのコピーを保存する
	NOTE: 保存先は &i_dir_path./&i_libname./連番
*/
%macro Prv_RSUDebug_TakeDSSnapshot(i_dir_path
											, i_libname =
											, i_init_index =
											, i_suffix =
											, i_dsname_regex =);
	%local /readonly _RSU_DEBUG_MACRO_SNAPSHOT_INDEX = %Prv_RSUDebug_SetSequenceIndex(i_init_index = &i_init_index.
																									, i_index_var = RSU_g_sequence_ds_snapshot);
	%local _dir_path;
	%if (%&RSUMacroVariable.IsBlank(i_suffix)) %then %do;
		%let _dir_path = &i_dir_path./&i_libname./&_RSU_DEBUG_MACRO_SNAPSHOT_INDEX.;
	%end;
	%else %do;
		%let _dir_path = &i_dir_path./&i_libname./&_RSU_DEBUG_MACRO_SNAPSHOT_INDEX._&i_suffix.;
	%end;

	%&RSUDirectory.CreateDir(&_dir_path.)
	%if (%&RSUDirectory.Exists(i_dir_path = &_dir_path.)) %then %do;
		%&RSULib.CopyDSInLib(i_libname = &i_libname.
									, i_dir_path = &_dir_path.
									, i_dsname_regex = &i_dsname_regex.)
		/* put memo */
		%local /readonly _RSU_DEBUG_BREADCRUMBS = %&RSUDebug.GetBreadcrumbs(i_depth_offset = -1);
		%&RSUFile.WriteLine(i_file_path = &_dir_path./snapshot_info.txt
								, i_line = Snapshot at: &_RSU_DEBUG_BREADCRUMBS. (&_RSU_DEBUG_MACRO_SNAPSHOT_INDEX.))
		%&RSUFile.WriteLine(i_file_path = &_dir_path./snapshot_info.txt
								, i_line = Library: &i_libname.
								, i_append = %&RSUBool.True)
		%if (not %&RSUMacroVariable.IsBlank(i_dsname_regex)) %then %do;
			%&RSUFile.WriteLine(i_file_path = &_dir_path./snapshot_info.txt
									, i_line = Dataset filter: &i_dsname_regex.
									, i_append %&RSUBool.True)
		%end;
	%end;
	%else %do;
		%&RSULogger.Warninig(%&RSUMsg.DIR_NOT_FOUND(&_dir_path))
	%end;
%mend Prv_RSUDebug_TakeDSSnapshot;

%macro Prv_RSUDebug_AssertHelper(i_eval_result =
											, i_msg =);
	%local /readonly _RSU_DEBUG_BREADCRUMBS = %&RSUDebug.GetBreadcrumbs(i_depth_offset = -1);
	%if (not &i_eval_result.) %then %do;
		%&RSULogger.PutError(%&RSUMsg.ASSERTION_VIOLATED(&i_msg., &_RSU_DEBUG_BREADCRUMBS.))
	%end;
%mend Prv_RSUDebug_AssertHelper;
