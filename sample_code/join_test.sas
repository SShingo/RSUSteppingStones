%rsu_steppingstones_activate()
%macro DetermineJoinKey(i_condition =
								, ovar_keys_lhs =
								, ovar_keys_rename_code_lhs =
								, ovar_keys_substitution_code_lhs =
								, ovar_keys_rhs =
								, ovar_keys_rename_code_rhs =
								, ovar_keys_substitution_code_rhs =
								, ovar_hash_define_key_code =);
	%let &ovar_keys_lhs. = %sysfunc(RemoveEnclosure(%scan(&i_condition., 1, =)));
	%let &ovar_keys_rhs. = %sysfunc(RemoveEnclosure(%scan(&i_condition., 2, =)));
	%local _key;
	%local _index_key;
	%let &ovar_keys_rename_code_lhs. =;
	%let &ovar_keys_substitution_code_lhs. =;
	%do %while(%&RSUUtil.ForEach(i_items = &_KEYS_LHS.
										, ovar_item = _key
										, iovar_index = _index_key));
		%&RSUText.Append(iovar_base = &ovar_keys_rename_code_lhs.
							, i_append_text = &_key. = __rsu_join_temp_key_&_index_key.)
		%&RSUText.Append(iovar_base = &ovar_keys_substitution_code_lhs.
							, i_append_text = __rsu_join_temp_key_&_index_key. = &_key.;)
	%end;
	%let &ovar_keys_rename_code_rhs. =;
	%let &ovar_keys_substitution_code_rhs. =;
	%let &ovar_hash_define_key_code. =;
	%do %while(%&RSUUtil.ForEach(i_items = &_KEYS_RHS.
										, ovar_item = _key
										, iovar_index = _index_key));
		%&RSUText.Append(iovar_base = &ovar_keys_rename_code_rhs.
							, i_append_text = &_key. = __rsu_join_temp_key_&_index_key.)
		%&RSUText.Append(iovar_base = &ovar_keys_substitution_code_rhs.
							, i_append_text = __rsu_join_temp_key_&_index_key. = &_key.;)
		%&RSUText.Append(iovar_base = &ovar_hash_define_key_code.
							, i_append_text = h_rhs.definekey("__rsu_join_temp_key_&_index_key.");)
	%end;
%mend DetermineJoinKey;

%macro FindDuplicatedVariables(ids_lhs_ds =
										, ids_rhs_ds =
										, i_keys_lhs =
										, i_keys_rhs =
										, ovar_duplicated_vars_regex =);
	%local _key;
	%local _index_key;
	%local _exclude_regex_lhs;
	%do %while(%&RSUUtil.ForEach(i_items = &i_keys_lhs.
										, ovar_item = _key
										, iovar_index = _index_key));
		%&RSUText.Append(iovar_base = _exclude_regex_lhs
							, i_append_text = (&_key.))
	%end;

	%local /readonly _TMP_DS_COLUMNS_LHS = %&RSUDS.GetTempDSName(lhs_columns);
	%RSUDS__GetDSDefinition(ids_dataset = &ids_lhs_ds.
									, ods_definition_ds = &_TMP_DS_COLUMNS_LHS.
									, i_regex_exclude = /&_exclude_regex_lhs./)
	data &_TMP_DS_COLUMNS_LHS.;
		set &_TMP_DS_COLUMNS_LHS.;
		variable = upcase(variable);
	run;
	quit;

	%local _exclude_regex_rhs;
	%do %while(%&RSUUtil.ForEach(i_items = &i_keys_rhs.
										, ovar_item = _key
										, iovar_index = _index_key));
		%&RSUText.Append(iovar_base = _exclude_regex_rhs
							, i_append_text = (&_key.))
	%end;
	%local /readonly _TMP_DS_COLUMNS_RHS = %&RSUDS.GetTempDSName(rhs_columns);
	%RSUDS__GetDSDefinition(ids_dataset = &ids_rhs_ds.
									, ods_definition_ds = &_TMP_DS_COLUMNS_RHS.
									, i_regex_exclude = /&_exclude_regex_rhs./)
	data &_TMP_DS_COLUMNS_RHS.;
		set &_TMP_DS_COLUMNS_RHS.;
		variable = upcase(variable);
	run;
	quit;
	data _null_;
		set &_TMP_DS_COLUMNS_LHS. end = eof;
		attrib
			_drop_vars length = $3000.
		;
		retain _drop_vars;
		if (_N_ = 1) then do;
			declare hash h_lower(dataset: " &_TMP_DS_COLUMNS_RHS.");
			h_lower.definekey('variable');
			h_lower.definedone();
		end;
		if (h_lower.check() = 0) then do;
			_drop_vars = catx('|', _drop_vars, EncloseRound(variable));
		end;
		if (eof) then do;
			call symputx("&ovar_duplicated_vars_regex.", _drop_vars);
		end;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_COLUMNS_LHS.)
	%&RSUDS.Delete(&_TMP_DS_COLUMNS_RHS.)
%mend FindDuplicatedVariables;

%macro DetermineHashData(ids_rhs_ds =
								, i_data_variables =
								, i_exclude_regex_rhs =
								, ovar_array_hash_data =);
	%if ("&i_data_variables." = "*") %then %do;
		%local /readonly _TMP_DS_COLUMNS_RHS = %&RSUDS.GetTempDSName(rhs_columns);
		%if (not %&RSUMacroVariable.IsBlank(i_exclude_regex_rhs)) %then %do;
			%&RSUDS.GetDSDefinition(ids_dataset = &ids_rhs_ds.
											, ods_definition_ds = &_TMP_DS_COLUMNS_RHS.
											, i_regex_exclude = /&i_exclude_regex_rhs./)
		%end;
		%else %do;
			%&RSUDS.GetDSDefinition(ids_dataset = &ids_rhs_ds.
											, ods_definition_ds = &_TMP_DS_COLUMNS_RHS.)
		%end;
		%let &ovar_array_hash_data. = %&RSUArrayEx.CreateByDataset(&_TMP_DS_COLUMNS_RHS.);
		%&RSUDS.Delete(&_TMP_DS_COLUMNS_RHS.)
	%end;
	%else %do;
		%let &ovar_array_hash_data. = %&RSUArrayEx.Create(&i_data_variables.);
	%end;
%mend DetermineHashData;



%macro AddDummyKey(iods_lhs_ds =
						, iods_rhs_ds =
						, ovar_hash_define_key_code =);
	%&RSUDS.AddSequenceVariable(i_query = &iods_lhs_ds.
										, i_sequence_variable_name = __rsu_join_temp_key_1)
	%&RSUDS.AddSequenceVariable(i_query = &iods_rhs_ds.
										, i_sequence_variable_name = __rsu_join_temp_key_1)
	%let &ovar_hash_define_key_code. = h_rhs.definekey('__rsu_join_temp_key_1');
%mend AddDummyKey;

%macro RSUJoin__LeftJoin(ids_lhs_ds
								, ids_rhs_ds
								, i_condition =
								, i_data_variables =
								, i_regex_data_variables =
								, i_multidata = %&RSUBool.False
								, i_update_by_rhs = %&RSUBool.True
								, i_is_key_variables_dropped = %&RSUBool.False
								, ods_output_ds =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_lhs_ds ids_rhs_ds i_condition)

	%local _keys_lhs;
	%local _keys_rename_code_lhs;
	%local _keys_substitution_code_lhs;
	%local _keys_rhs;
	%local _keys_rename_code_rhs;
	%local _keys_substitution_code_rhs;
	%local _hash_define_key_code;
	%DetermineJoinKey(i_condition = &i_condition.
							, ovar_keys_lhs = _keys_lhs
							, ovar_keys_rename_code_lhs = _keys_rename_code_lhs
							, ovar_keys_substitution_code_lhs = _keys_substitution_code_lhs
							, ovar_keys_rhs = _keys_rhs
							, ovar_keys_rename_code_rhs = _keys_rename_code_rhs
							, ovar_keys_substitution_code_rhs = _keys_substitution_code_rhs
							, ovar_hash_define_key_code = _hash_define_key_code)

	%local _duplicated_vars_regex;
	%if (not &i_update_by_rhs. and "&i_data_variables." = "*") %then %do;
		%FindDuplicatedVariable(ids_lhs_ds = &ids_lhs_ds.
										, ids_rhs_ds = &ids_rhs_ds.
										, i_keys_lhs = &_keys_lhs.
										, i_keys_rhs = &_keys_rhs.
										, ovar_duplicated_vars_regex = _duplicated_vars_regex)
	%end;
	%local _array_hash_data_def;
	%local _no_of_data_vars;
	%let _no_of_data_vars = 0;
	%if (not %&RSUMacroVariable.IsBlank(i_data_variables)) %then %do;
		%DetermineHashData(ids_rhs_ds = &ids_rhs_ds.
								, i_data_variables = &i_data_variables.
								, i_exclude_regex_rhs = &_duplicated_vars_regex.
								, ovar_array_hash_data = _array_hash_data_def)
		%let _no_of_data_vars = %&RSUArrayEx.Size(_array_hash_data_def);
	%end;
	%local _index_data_var;
	%local /readonly _TMP_DS_WORKING_RHS = %&RSUDS.GetTempDSName(work_rhs);
	data &_TMP_DS_WORKING_RHS.;
		set &ids_rhs_ds.;
		if (0) then do;
			set &ids_rhs_ds.(keep = &_keys_rhs. rename = &_keys_rename_code_rhs.);
		end;
		&_keys_substitution_code_rhs.
		keep
			__rsu_join_temp_key_:
	%do _index_data_var = 1 %to &_no_of_data_vars;
			&&&_array_hash_data_def._&_index_data_var.
	%end;
		;
	run;
	quit;
	%&RSUArrayEx.Dispose(_array_hash_data_def)
	%local /readonly _TMP_DS_WORKING_LHS = %&RSUDS.GetTempDSName(work_lhs);
	data &_TMP_DS_WORKING_LHS.;
		set &ids_lhs_ds.;
		if (0) then do;
			set &ids_lhs_ds.(keep = &_keys_lhs. rename = &_keys_rename_code_lhs.);
			set &_TMP_DS_WORKING_RHS.
		end;
		&_keys_substitution_code_lhs.
	run;
	quit;

	%local /readonly _HASH_OPTION_CODE = %&RSUUtil.Choose(&i_multidata., %str(,)multidata: 'yes'%str(,)ordered: 'yes'); 
	%local /readonly _DROP_KEY_CODE = %&RSUUtil.Choose(&i_is_key_variables_dropped., &_keys_lhs.,); 
	%local /readonly _DS_OUTPUT = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_lhs_ds., &ods_output_ds.);
	data &_DS_OUTPUT.(drop = _rsu_join_rc __rsu_join_temp_key_: &_drop_key_code.);
		set &_TMP_DS_WORKING_LHS.;
		if (_N_ = 1) then do;
			declare hash h_rhs(dataset: "&_TMP_DS_WORKING_RHS." &_HASH_OPTION_CODE.);
			&_hash_define_key_code.
			h_rhs.definedata(all: 'yes');
			h_rhs.definedone();
		end;
		_rsu_join_rc = h_rhs.find();
		output;
	%if (&i_multidata.) %then %do;
		if (_rsu_join_rc = 0) then do;
			_rsu_join_rc = h_rhs.find_next();
			do while(_rsu_join_rc = 0);
				output;
			end;
		end:
	%end;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_WORKING_LHS. &_TMP_DS_WORKING_RHS.)
%mend RSUJoin__LeftJoin;

%macro RSUJoin__InnerJoin(ids_lhs_ds
								, ids_rhs_ds
								, i_condition =
								, i_data_variables =
								, i_regex_data_variables =
								, i_multidata = %&RSUBool.False
								, i_update_by_rhs = %&RSUBool.True
								, i_is_key_variables_dropped = %&RSUBool.False
								, ods_output_ds =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_lhs_ds ids_rhs_ds i_condition)

	%local _keys_lhs;
	%local _keys_rename_code_lhs;
	%local _keys_substitution_code_lhs;
	%local _keys_rhs;
	%local _keys_rename_code_rhs;
	%local _keys_substitution_code_rhs;
	%local _hash_define_key_code;
	%DetermineJoinKey(i_condition = &i_condition.
							, ovar_keys_lhs = _keys_lhs
							, ovar_keys_rename_code_lhs = _keys_rename_code_lhs
							, ovar_keys_substitution_code_lhs = _keys_substitution_code_lhs
							, ovar_keys_rhs = _keys_rhs
							, ovar_keys_rename_code_rhs = _keys_rename_code_rhs
							, ovar_keys_substitution_code_rhs = _keys_substitution_code_rhs
							, ovar_hash_define_key_code = _hash_define_key_code)

	%local /readonly _TMP_DS_WORKING_RHS = %&RSUDS.GetTempDSName(work_rhs);
	%&RSUDS.Let(i_query = &ids_rhs_ds.
					, ods_dest_ds = &_TMP_DS_WORKING_RHS.)
	%local _duplicated_vars_regex;
	%if (not &i_update_by_rhs. and "&i_data_variables." = "*") %then %do;
		%FindDuplicatedVariable(ids_lhs_ds = &_TMP_DS_WORKING_LHS.
										, ids_rhs_ds = &_TMP_DS_WORKING_RHS.
										, i_keys_lhs = &_keys_lhs.
										, i_keys_rhs = &_keys_rhs.
										, ovar_duplicated_vars_regex = _duplicated_vars_regex)
	%end;
	%local _array_hash_data_def;
	%local _no_of_data_vars;
	%DetermineHashData(ids_rhs_ds = &_TMP_DS_WORKING_RHS.
							, i_data_variables = &i_data_variables.
							, i_exclude_regex_rhs = &_duplicated_vars_regex.
							, ovar_array_hash_data = _array_hash_data_def
							, ovar_no_of_data_vars = _no_of_data_vars)
	%local _index_data_var;
	data &_TMP_DS_WORKING_RHS.;
		set &_TMP_DS_WORKING_RHS.;
		if (0) then do;
			set &_TMP_DS_WORKING_RHS.(keep = &_keys_rhs. rename = &_keys_rename_code_rhs.);
		end;
		&_keys_substitution_code_rhs.
		keep
			__rsu_join_temp_key_:
	%do _index_data_var = 1 %to &_no_of_data_vars;
			&&&_array_hash_data_def._&_index_data_var.
	%end;
		;
	run;
	quit;

	%local /readonly _HASH_OPTION_CODE = %&RSUUtil.Choose(&i_multidata., %str(,)multidata: 'yes'%str(,)ordered: 'yes'); 
	%local /readonly _DROP_KEY_CODE = %&RSUUtil.Choose(&i_is_key_variables_dropped., &_keys_lhs.,); 
	%local /readonly _TMP_DS_WORKING_LHS = %&RSUDS.GetTempDSName(work_lhs);
	%&RSUDS.Let(i_query = &ids_lhs_ds.
					, ods_dest_ds = &_TMP_DS_WORKING_LHS.)
	%local /readonly _DS_OUTPUT = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_lhs_ds., &ods_output_ds.);
	data &_DS_OUTPUT.(drop = _rsu_join_rc __rsu_join_temp_key_: &_drop_key_code.);
		set &_TMP_DS_WORKING_LHS.;
		if (0) then do;
			set &_TMP_DS_WORKING_RHS.(keep = &_keys_lhs. rename = &_keys_rename_code_lhs.);
		end;
		if (_N_ = 1) then do;
			declare hash h_rhs(dataset: "&_TMP_DS_WORKING_RHS." &_HASH_OPTION_CODE.);
			&_hash_define_key_code.
			h_rhs.definedata(all: 'yes');
			h_rhs.definedone();
		end;
		&_keys_substitution_code_lhs.
		_rsu_join_rc = h_rhs.find();
		if (_rsu_join_rc = 0) then do;
			output;
		end;
	%if (&i_multidata.) %then %do;
		if (_rsu_join_rc = 0) then do;
			_rsu_join_rc = h_rhs.find_next();
			do while(_rsu_join_rc = 0);
				output;
			end;
		end:
	%end;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_WORKING_LHS. &_TMP_DS_WORKING_RHS.)
%mend RSUJoin__InnerJoin;

%macro RSUJoin__Subract(ids_lhs_ds
								, ids_rhs_ds
								, i_condition =
								, ods_output_ds =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_lhs_ds ids_rhs_ds i_condition)

	%local _keys_lhs;
	%local _keys_rename_code_lhs;
	%local _keys_substitution_code_lhs;
	%local _keys_rhs;
	%local _keys_rename_code_rhs;
	%local _keys_substitution_code_rhs;
	%local _hash_define_key_code;
	%DetermineJoinKey(i_condition = &i_condition.
							, ovar_keys_lhs = _keys_lhs
							, ovar_keys_rename_code_lhs = _keys_rename_code_lhs
							, ovar_keys_substitution_code_lhs = _keys_substitution_code_lhs
							, ovar_keys_rhs = _keys_rhs
							, ovar_keys_rename_code_rhs = _keys_rename_code_rhs
							, ovar_keys_substitution_code_rhs = _keys_substitution_code_rhs
							, ovar_hash_define_key_code = _hash_define_key_code)

	%local /readonly _TMP_DS_WORKING_RHS = %&RSUDS.GetTempDSName(work_rhs);
	%&RSUDS.Let(i_query = &ids_rhs_ds.
					, ods_dest_ds = &_TMP_DS_WORKING_RHS.)
	%local _index_data_var;
	data &_TMP_DS_WORKING_RHS.;
		set &_TMP_DS_WORKING_RHS.;
		if (0) then do;
			set &_TMP_DS_WORKING_RHS.(keep = &_keys_rhs. rename = &_keys_rename_code_rhs.);
		end;
		&_keys_substitution_code_rhs.
		keep
			__rsu_join_temp_key_:
		;
	run;
	quit;

	%local /readonly _TMP_DS_WORKING_LHS = %&RSUDS.GetTempDSName(work_lhs);
	%&RSUDS.Let(i_query = &ids_lhs_ds.
					, ods_dest_ds = &_TMP_DS_WORKING_LHS.)
	%local /readonly _DS_OUTPUT = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_lhs_ds., &ods_output_ds.);
	data &_DS_OUTPUT.(drop = _rsu_join_rc __rsu_join_temp_key_:);
		set &_TMP_DS_WORKING_LHS.;
		if (0) then do;
			set &_TMP_DS_WORKING_RHS.(keep = &_keys_lhs. rename = &_keys_rename_code_lhs.);
		end;
		if (_N_ = 1) then do;
			declare hash h_rhs(dataset: "&_TMP_DS_WORKING_RHS.");
			&_hash_define_key_code.
			h_rhs.definedone();
		end;
		&_keys_substitution_code_lhs.
		_rsu_join_rc = h_rhs.find();
		if (_rsu_join_rc ne 0) then do;
			output;
		end;
	%end;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_WORKING_LHS. &_TMP_DS_WORKING_RHS.)
%mend RSUJoin__Subract;

%macro RSUJoin__Union(ids_lhs_ds
							, ids_rhs_ds
							, i_condition =
							, i_data_variables =
							, i_regex_data_variables =
							, i_multidata = %&RSUBool.False
							, i_update_by_rhs = %&RSUBool.True
							, i_is_key_variables_dropped = %&RSUBool.False
							, ods_output_ds =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_lhs_ds ids_rhs_ds i_condition)

	%local _keys_lhs;
	%local _keys_rename_code_lhs;
	%local _keys_substitution_code_lhs;
	%local _keys_rhs;
	%local _keys_rename_code_rhs;
	%local _keys_substitution_code_rhs;
	%local _hash_define_key_code;
	%DetermineJoinKey(i_condition = &i_condition.
							, ovar_keys_lhs = _keys_lhs
							, ovar_keys_rename_code_lhs = _keys_rename_code_lhs
							, ovar_keys_substitution_code_lhs = _keys_substitution_code_lhs
							, ovar_keys_rhs = _keys_rhs
							, ovar_keys_rename_code_rhs = _keys_rename_code_rhs
							, ovar_keys_substitution_code_rhs = _keys_substitution_code_rhs
							, ovar_hash_define_key_code = _hash_define_key_code)

	%local /readonly _TMP_DS_WORKING_RHS = %&RSUDS.GetTempDSName(work_rhs);
	%&RSUDS.Let(i_query = &ids_rhs_ds.
					, ods_dest_ds = &_TMP_DS_WORKING_RHS.)
	%local _duplicated_vars_regex;
	%if (not &i_update_by_rhs. and "&i_data_variables." = "*") %then %do;
		%FindDuplicatedVariable(ids_lhs_ds = &_TMP_DS_WORKING_LHS.
										, ids_rhs_ds = &_TMP_DS_WORKING_RHS.
										, i_keys_lhs = &_keys_lhs.
										, i_keys_rhs = &_keys_rhs.
										, ovar_duplicated_vars_regex = _duplicated_vars_regex)
	%end;
	%local _array_hash_data_def;
	%local _no_of_data_vars;
	%DetermineHashData(ids_rhs_ds = &_TMP_DS_WORKING_RHS.
							, i_data_variables = &i_data_variables.
							, i_exclude_regex_rhs = &_duplicated_vars_regex.
							, ovar_array_hash_data = _array_hash_data_def
							, ovar_no_of_data_vars = _no_of_data_vars)
	%local _index_data_var;
	data &_TMP_DS_WORKING_RHS.;
		set &_TMP_DS_WORKING_RHS.;
		if (0) then do;
			set &_TMP_DS_WORKING_RHS.(keep = &_keys_rhs. rename = &_keys_rename_code_rhs.);
		end;
		__rsu_join_dummy_index = _N_;
		__rsu_join_is_joined = 0;
		&_keys_substitution_code_rhs.
		keep
			__rsu_join_temp_key_:
	%do _index_data_var = 1 %to &_no_of_data_vars;
			&&&_array_hash_data_def._&_index_data_var.
	%end;
		;
	run;
	quit;

	%local /readonly _HASH_OPTION_CODE = %&RSUUtil.Choose(&i_multidata., %str(,)multidata: 'yes'%str(,)ordered: 'yes'); 
	%local /readonly _DROP_KEY_CODE = %&RSUUtil.Choose(&i_is_key_variables_dropped., &_keys_lhs.,); 
	%local /readonly _TMP_DS_WORKING_LHS = %&RSUDS.GetTempDSName(work_lhs);
	%&RSUDS.Let(i_query = &ids_lhs_ds.
					, ods_dest_ds = &_TMP_DS_WORKING_LHS.)
	%local /readonly _DS_OUTPUT = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_lhs_ds., &ods_output_ds.);
	data &_DS_OUTPUT.(drop = _rsu_join_rc __rsu_join_temp_key_: __rus_join_is_joined &_drop_key_code.);
		set &_TMP_DS_WORKING_LHS. end = eof;
		if (0) then do;
			set &_TMP_DS_WORKING_RHS.(keep = &_keys_lhs. rename = &_keys_rename_code_lhs.);
		end;
		if (_N_ = 1) then do;
			declare hash h_rhs(dataset: "&_TMP_DS_WORKING_RHS." &_HASH_OPTION_CODE.);
			&_hash_define_key_code.
			h_rhs.definedata(all: 'yes');
			h_rhs.definedone();
		end;
		&_keys_substitution_code_lhs.
		_rsu_join_rc = h_rhs.find();
		output;
		__rus_join_is_joined = (_rsu_join_rc = 0);
		h_rhs.replace();
	%if (&i_multidata.) %then %do;
		if (_rsu_join_rc = 0) then do;
			_rsu_join_rc = h_rhs.find_next();
			do while(_rsu_join_rc = 0);
				output;
			__rus_join_is_joined = (_rsu_join_rc = 0);
			if (h_rhs.check() = 0) then do;
				__rsu_join_is_joined = (__rus_join_is_joined = 0);
				h_rhs.replace();
			end;
		end:
	%end;
		if (eof) then do;
			call missing(of _all_);
			declare hiter hi_rhs_remain('h_rhs');
			_rsu_join_rc = _hi_rhs.first();
			do while(_rsu_join_rc = 0);
				if (__rsu_join_is_joined = 0) then do;
					output;
				end;
				_rsu_join_rc = _hi_rhs.next();
			end;
		end;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_WORKING_LHS. &_TMP_DS_WORKING_RHS.)
%mend RSUJoin__Union;

%macro RSUJoin__CrossJoin(ids_lhs_ds
								, ids_rhs_ds
								, i_condition =
								, i_data_variables =
								, i_regex_data_variables =
								, i_update_by_rhs = %&RSUBool.True
								, i_is_key_variables_dropped = %&RSUBool.False
								, ods_output_ds =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_lhs_ds ids_rhs_ds i_condition)

	%local _keys_lhs;
	%local _keys_rename_code_lhs;
	%local _keys_substitution_code_lhs;
	%local _keys_rhs;
	%local _keys_rename_code_rhs;
	%local _keys_substitution_code_rhs;
	%local _hash_define_key_code;
	%DetermineJoinKey(i_condition = &i_condition.
							, ovar_keys_lhs = _keys_lhs
							, ovar_keys_rename_code_lhs = _keys_rename_code_lhs
							, ovar_keys_substitution_code_lhs = _keys_substitution_code_lhs
							, ovar_keys_rhs = _keys_rhs
							, ovar_keys_rename_code_rhs = _keys_rename_code_rhs
							, ovar_keys_substitution_code_rhs = _keys_substitution_code_rhs
							, ovar_hash_define_key_code = _hash_define_key_code)

	%local /readonly _TMP_DS_WORKING_RHS = %&RSUDS.GetTempDSName(work_rhs);
	%&RSUDS.Let(i_query = &ids_rhs_ds.
					, ods_dest_ds = &_TMP_DS_WORKING_RHS.)
	%local _duplicated_vars_regex;
	%if (not &i_update_by_rhs. and "&i_data_variables." = "*") %then %do;
		%FindDuplicatedVariable(ids_lhs_ds = &_TMP_DS_WORKING_LHS.
										, ids_rhs_ds = &_TMP_DS_WORKING_RHS.
										, i_keys_lhs = &_keys_lhs.
										, i_keys_rhs = &_keys_rhs.
										, ovar_duplicated_vars_regex = _duplicated_vars_regex)
	%end;
	%local _array_hash_data_def;
	%local _no_of_data_vars;
	%DetermineHashData(ids_rhs_ds = &_TMP_DS_WORKING_RHS.
							, i_data_variables = &i_data_variables.
							, i_exclude_regex_rhs = &_duplicated_vars_regex.
							, ovar_array_hash_data = _array_hash_data_def
							, ovar_no_of_data_vars = _no_of_data_vars)
	%local _index_data_var;
	data &_TMP_DS_WORKING_RHS.;
		set &_TMP_DS_WORKING_RHS.;
		__rsu_join_temp_key_1 = _N_;
		keep
			__rsu_join_temp_key_:
	%do _index_data_var = 1 %to &_no_of_data_vars;
			&&&_array_hash_data_def._&_index_data_var.
	%end;
		;
	run;
	quit;

	%local /readonly _HASH_OPTION_CODE = %&RSUUtil.Choose(&i_multidata., %str(,)multidata: 'yes'%str(,)ordered: 'yes'); 
	%local /readonly _DROP_KEY_CODE = %&RSUUtil.Choose(&i_is_key_variables_dropped., &_keys_lhs.,); 
	%local /readonly _TMP_DS_WORKING_LHS = %&RSUDS.GetTempDSName(work_lhs);
	%&RSUDS.Let(i_query = &ids_lhs_ds.
					, ods_dest_ds = &_TMP_DS_WORKING_LHS.)
	%local /readonly _DS_OUTPUT = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_lhs_ds., &ods_output_ds.);
	data &_DS_OUTPUT.(drop = _rsu_join_rc __rsu_join_temp_key_: &_drop_key_code.);
		set &_TMP_DS_WORKING_LHS.;
		if (0) then do;
			set &_TMP_DS_WORKING_RHS.(keep = &_keys_lhs. rename = &_keys_rename_code_lhs.);
		end;
		if (_N_ = 1) then do;
			declare hash h_rhs(dataset: "&_TMP_DS_WORKING_RHS." &_HASH_OPTION_CODE.);
			h_rhs.definekey('__rsu_join_temp_key_1');
			h_rhs.definedata(all: 'yes');
			h_rhs.definedone();
			declare hash hi_rhs('h_rhs');
		end;
		_rsu_iter_rc = hi_rhs.first();
		do while(_rsu_iter_rc = 0);
			output;
			_rsu_iter_rc = hi_rhs.next();
		end;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_WORKING_LHS. &_TMP_DS_WORKING_RHS.)
%mend RSUJoin__CrossJoin;

%macro RSUJoin__IsLHSInRHS();
%mend RSUJoin__IsLHSInRHS;

%macro RSUJoin__Concat();
%mend RSUJoin__Concat;

%macro test();
	data x;
		set SASHELP.class;
	run;
	data y;
		name = 'Alfred';
		Age = 40;
		nation = 'US';
		output;
		name = 'Shingo';
		Age = 51;
		nation = 'JPS';
		output;
	run;
	%RSUJoin__InnerJoin(WORK.x
							, WORK.y
							, i_condition = (name) = (name)
							, i_data_variables = *
							, i_update_by_rhs = %&RSUBool.False
							, ods_output_ds = WORK.z)
%mend test;
%test