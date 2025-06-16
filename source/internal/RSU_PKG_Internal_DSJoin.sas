/*******************************************/
/* Internal Macros
/*******************************************/
%macro Prv_RSUDSJoin_PrepareJoin(ids_lhs_ds =
											, ids_rhs_ds =
											, i_condition =
											, i_data_variables =
											, i_multidata =
											, ods_work_ds_lhs =
											, ods_work_ds_rhs =
											, ovar_hash_define_key_code =
											, ovar_hash_option_code =);
	%local _keys_lhs;
	%local _keys_rename_code_lhs;
	%local _keys_substitution_code_lhs;
	%local _keys_rhs;
	%local _keys_rename_code_rhs;
	%local _keys_substitution_code_rhs;
	%DetermineJoinKey(i_condition = &i_condition.
							, ovar_keys_lhs = _keys_lhs
							, ovar_keys_rename_code_lhs = _keys_rename_code_lhs
							, ovar_keys_substitution_code_lhs = _keys_substitution_code_lhs
							, ovar_keys_rhs = _keys_rhs
							, ovar_keys_rename_code_rhs = _keys_rename_code_rhs
							, ovar_keys_substitution_code_rhs = _keys_substitution_code_rhs
							, ovar_hash_define_key_code = &ovar_hash_define_key_code.)

	%local _duplicated_vars_regex;
	%if (not &i_update_by_rhs. and "&i_data_variables." = "*") %then %do;
		%FindDuplicatedVariables(ids_lhs_ds = &ids_lhs_ds.
										, ids_rhs_ds = &ids_rhs_ds.
										, i_keys_lhs = &_keys_lhs.
										, i_keys_rhs = &_keys_rhs.
										, ovar_duplicated_vars_regex = _duplicated_vars_regex)
	%end;
	%local _array_hash_data_def;
	%if (not %&RSUMacroVariable.IsBlank(i_data_variables)) %then %do;
		%DetermineHashData(ids_rhs_ds = &ids_rhs_ds.
								, i_data_variables = &i_data_variables.
								, i_exclude_regex_rhs = &_duplicated_vars_regex.
								, ovar_array_hash_data = _array_hash_data_def)
	%end;
	%else %do;
		%let _array_hash_data_def = %&RSUArray.CreateBlank();
	%end;
	%local _data_varirable;
	data &ods_work_ds_rhs.;
		set &ids_rhs_ds.;
		if (0) then do;
			set &ids_rhs_ds.(keep = &_keys_rhs. rename = (&_keys_rename_code_rhs.));
		end;
		attrib
			__rsu_join_is_joined length = 3.
		;
		&_keys_substitution_code_rhs.
		keep
			__rsu_join_temp_key_:
			__rsu_join_is_joined
		%do %while(%&RSUArray.ForEach(_array_hash_data_def, _data_varirable));
			&_data_varirable.
		%end;
		;
	run;
	quit;
	%&RSUArray.Dispose(_array_hash_data_def)
	data &ods_work_ds_lhs.;
		set &ids_lhs_ds.;
		if (0) then do;
			set &ids_lhs_ds.(keep = &_keys_lhs. rename = (&_keys_rename_code_lhs.));
			set &ods_work_ds_rhs.;
		end;
		&_keys_substitution_code_lhs.
	run;
	quit;
	%let &ovar_hash_option_code. = %&RSUUtil.Choose(&i_multidata., %str(,)multidata: 'yes'%str(,)ordered: 'yes');
%mend Prv_RSUDSJoin_PrepareJoin;

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
	%if ("%sysfunc(substr(&i_data_variables, 1, 1))" = "/") %then %do;
		/* 正規表現 */
		%local /readonly _TMP_DS_COLUMNS_RHS = %&RSUDS.GetTempDSName(rhs_columns);
		%&RSUDS.GetDSDefinition(ids_dataset = &ids_rhs_ds.
										, ods_definition_ds = &_TMP_DS_COLUMNS_RHS.
										, i_regex_include = &i_data_variables.)
		%let &ovar_array_hash_data. = %&RSUArray.CreateByDataset(&_TMP_DS_COLUMNS_RHS.
																					, variable);
		%&RSUDS.Delete(&_TMP_DS_COLUMNS_RHS.)
	%end;
	%else %if ("&i_data_variables." = "*") %then %do;
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
		%let &ovar_array_hash_data. = %&RSUArray.CreateByDataset(&_TMP_DS_COLUMNS_RHS.
																					, variable);
		%&RSUDS.Delete(&_TMP_DS_COLUMNS_RHS.)
	%end;
	%else %do;
		%let &ovar_array_hash_data. = %&RSUArray.Create(&i_data_variables.);
	%end;
%mend DetermineHashData;
