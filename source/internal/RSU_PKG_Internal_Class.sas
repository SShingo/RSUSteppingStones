/*******************************************/
/* Private Macros
/*******************************************/
%macro Prv_RSUClass_CreateInstance(i_prefix =
											, i_sequence_var =
											, iovar_sequence =);
	%local /readonly _INSTANCE_ID = %&RSUUtil.GetSequenceId(i_prefix = &RSU_G_GLOBAL_INSTANCE_PREFIX._&i_prefix.
																			, iovar_sequence = &i_sequence_var.
																			, i_digit = &RSU_G_INSTANCE_ID_DIGIT.);
	%global &_INSTANCE_ID._born;
	%let &_INSTANCE_ID._born = %&RSUDebug.GetBreadcrumbs;
	&_INSTANCE_ID.
%mend Prv_RSUClass_CreateInstance;

%macro Prv_RSUClass_DisposeHelper(i_instance_name =
											, i_force_dispose = %&RSUBool.False);
	/* Invoke instance clean-up code */
	%local /readonly _RSU_CLASS_DISPOSE_MAC_FUNC_NAME = %&RSUDS.GetTempDSName();
	proc catalog cat = WORK.sasmac1;
		contents out = &_RSU_CLASS_DISPOSE_MAC_FUNC_NAME.(where = (upcase(name) like upcase("&i_instance_name%") 
																							or upcase(name) like upcase("INT_&i_instance_name%")));
	run;
	quit;
	%InvokeReleaseFunctionIfExists(ids_macro_function_list = &_RSU_CLASS_DISPOSE_MAC_FUNC_NAME.
												, i_instance_name = &i_instance_name.
												, i_force_dispose = &i_force_dispose.)
	%DeleteMacroFunctions(ids_macro_function_list = &_RSU_CLASS_DISPOSE_MAC_FUNC_NAME.)
	%&RSUDS.Delete(&_RSU_CLASS_DISPOSE_MAC_FUNC_NAME.)

	%DeleteMacroVariables(i_instance_name = &i_instance_name.)
%mend Prv_RSUClass_DisposeHelper;

%macro InvokeReleaseFunctionIfExists(ids_macro_function_list =
												, i_instance_name =
												, i_force_dispose =);
	%if (%&RSUDS.GetCount(ids_dataset = &ids_macro_function_list.(where = (upcase(name) = upcase("INT_&i_instance_name.RELEASE")))) = 1
			and &i_force_dispose. = %&RSUBool.False) %then %do;
		%Int_&i_instance_name.Release()
	%end;
%mend InvokeReleaseFunctionIfExists;

%macro DeleteMacroFunctions(ids_macro_function_list =);
	%local /readonly _DS_ITER_MACRO = %&RSUDSIterator.Create(&ids_macro_function_list.);
	%do %while(%&RSUDSIterator.Next(_DS_ITER_MACRO));
		%sysmacdelete %&RSUDSIterator.Current(_DS_ITER_MACRO, name);
	%end;
	%&RSUDSIterator.Dispose(_DS_ITER_MACRO)
%mend DeleteMacroFunctions;
/*
%macro DeleteMacroVariables(i_instance_name =);
	%local /readonly _RSU_CLASS_DISPOSE_MAC_VAR_NAME = %&RSUDS.GetTempDSName();
	%&RSUDS.GetUniqueList(i_query = SASHELP.vmacro(where = (upcase(name) like upcase("&i_instance_name.M_%")) keep = name)
								, i_by_variables = name
								, ods_output_ds = &_RSU_CLASS_DISPOSE_MAC_VAR_NAME.)
	%local _macro_var_name;
	%local _dsid;
	%do %while(%&RSUDS.ForEach(i_query = &_RSU_CLASS_DISPOSE_MAC_VAR_NAME.
										, i_vars = _macro_var_name:name
										, ovar_dsid = _dsid));
		%if (%symexist(&_macro_var_name.)) %then %do;
			%symdel &_macro_var_name.;
		%end;
	%end;
	%&RSUDS.Delete(&_RSU_CLASS_DISPOSE_MAC_VAR_NAME.)
%mend DeleteMacroVariables;
*/

/*******************************************/
/* Internal Macros
/*******************************************/
%macro Int_RSUClass_Initialize(i_rsu_dev_module_name =);
	data L_RSUMDL.&RSU_G_CLASS_TEMPLATE_DS.(keep = lineno name code);
		set L_RSUMDL.&i_rsu_dev_module_name.(where = (trim(name) like 'RSU_PKG_Class_%') rename = code = code_org);
		attrib
			code length = $5000.
		;
		retain _start_reading 0;
		retain _is_in_macro 0;
		retain _regex_line_comment;
		retain _regex_comment_begin;
		retain _regex_macro_begin;
		retain _regex_macro_end;
		retain code '';
		_regex_comment_begin = prxparse('/^\s*\/\*/o');
		_regex_macro_begin = prxparse('/^\s*%macro\s*/o');
		_regex_macro_end = prxparse('/^\s*%mend\s*/o');
		if (not missing(code_org) and not prxmatch(_regex_comment_begin, code_org)) then do;
			if (prxmatch(_regex_macro_begin, code_org)) then do;
				_is_in_macro = 1;
			end;
			if (_is_in_macro) then do;
				code = cats(code, code_org);
				if (prxmatch(_regex_macro_end, code_org)) then do;
					output;
					_is_in_macro = 0;
					code = '';
				end;
			end;
			else do;
				code = code_org;
				output;
				code = '';
			end;
		end;
	run;
	quit;
%mend Int_RSUClass_Initialize;

%macro Int_RSUClass_Instantiate(i_template_name =);
	%local /readonly __TMP_INSTANCE_ID__ = %&RSUUtil.GetSequenceId(i_prefix = &RSU_G_INSTANCE_PREFIX.
																						, iovar_sequence = RSU_g_sequence_instance
																						, i_digit = &RSU_G_INSTANCE_ID_DIGIT.)_;
	%local _source_ds;
	%local _template_name;
	%local _instanice_name;
	%let _source_ds = L_RSUMDL.&RSU_G_CLASS_TEMPLATE_DS.;
	%let _template_name = &i_template_name.;
	%let _instanice_name = &__TMP_INSTANCE_ID__.;
	%syscall RSU_fcmp_instantiate(_source_ds, _template_name, _instanice_name);
	%&RSUDS.Delete(WORK.tmp_class_template_code)
	&__TMP_INSTANCE_ID__.
%mend Int_RSUClass_Instantiate;