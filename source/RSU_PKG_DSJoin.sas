/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_DSJoin.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/3/17
/***********************************************************************************/
/*<PackageID>RSUDSJoin/PackageID>*/
/*<CategoryID>Cate_DataHandling</CategoryID>*/
/*<PackagePurpose ja_jp>データセットジョイン</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Join of 2 datasets</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>2つのデータセットのジョイン操作関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions for joining 2 datasets</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>データセットジョインパッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUDSJoin, RSUDSJoin__)

/*<FunctionDesc ja_jp>Left-Join</FunctionDesc ja_jp>*/
%macro RSUDSJoin__LeftJoin(
/*<FunctionArgDesc ja_jp>transaction データセット（左辺）</FunctionArgDesc ja_jp>*/
									ids_lhs_ds
/*<FunctionArgDesc ja_jp>master データセット（右辺）</FunctionArgDesc ja_jp>*/
									, ids_rhs_ds
/*<FunctionArgDesc ja_jp>結合条件（例： (a b)=(c d)のように設定）</FunctionArgDesc ja_jp>*/
									, i_condition =
/*<FunctionArgDesc ja_jp>master データセットのデータ変数</FunctionArgDesc ja_jp>*/
									, i_data_variables =
/*<FunctionArgDesc ja_jp>1つのキーに複数のレコードがある場合、すべてを結合するか否か</FunctionArgDesc ja_jp>*/
									, i_multidata = %&RSUBool.False
/*<FunctionArgDesc ja_jp>右辺の値によって左辺の値を上書きするか否か</FunctionArgDesc ja_jp>*/
									, i_update_by_rhs = %&RSUBool.True
/*<FunctionArgDesc ja_jp>出力データセット（省略時は左辺の更新）</FunctionArgDesc ja_jp>*/
									, ods_output_ds =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_lhs_ds ids_rhs_ds i_condition)
	%local /readonly _TMP_DS_WORKING_LHS = %&RSUDS.GetTempDSName(work_lhs);
	%local /readonly _TMP_DS_WORKING_RHS = %&RSUDS.GetTempDSName(work_rhs);
	%local _hash_define_key_code;
	%local _hash_option_code;
	%Prv_RSUDSJoin_PrepareJoin(ids_lhs_ds = &ids_lhs_ds.
										, ids_rhs_ds = &ids_rhs_ds.
										, i_condition = &i_condition.
										, i_data_variables = &i_data_variables.
										, i_multidata = &i_multidata.
										, ods_work_ds_lhs = &_TMP_DS_WORKING_LHS.
										, ods_work_ds_rhs = &_TMP_DS_WORKING_RHS.
										, ovar_hash_define_key_code = _hash_define_key_code
										, ovar_hash_option_code = _hash_option_code)
	%local /readonly _DS_OUTPUT = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_lhs_ds., &ods_output_ds.);
	data &_DS_OUTPUT.;
		set &_TMP_DS_WORKING_LHS.;
		if (_N_ = 1) then do;
			declare hash h_rhs(dataset: "&_TMP_DS_WORKING_RHS." &_hash_option_code.);
			&_hash_define_key_code.
			h_rhs.definedata(all: 'yes');
			h_rhs.definedone();
		end;
		__rsu_join_rc = h_rhs.find();
		output;
	%if (&i_multidata.) %then %do;
		if (__rsu_join_rc = 0) then do;
			__rsu_join_rc = h_rhs.find_next();
			do while(__rsu_join_rc = 0);
				output;
				__rsu_join_rc = h_rhs.find_next();
			end;
		end;
	%end;
		drop
			__rsu_join_:
		;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_WORKING_LHS. &_TMP_DS_WORKING_RHS.)
%mend RSUDSJoin__LeftJoin;

/*<FunctionDesc ja_jp>Inner-Join</FunctionDesc ja_jp>*/
%macro RSUDSJoin__InnerJoin(
/*<FunctionArgDesc ja_jp>transaction データセット（左辺）</FunctionArgDesc ja_jp>*/
									ids_lhs_ds
/*<FunctionArgDesc ja_jp>master データセット（右辺）</FunctionArgDesc ja_jp>*/
									, ids_rhs_ds
/*<FunctionArgDesc ja_jp>結合条件（例： (a b)=(c d)のように設定）</FunctionArgDesc ja_jp>*/
									, i_condition =
/*<FunctionArgDesc ja_jp>master データセットのデータ変数</FunctionArgDesc ja_jp>*/
									, i_data_variables =
/*<FunctionArgDesc ja_jp>1つのキーに複数のレコードがある場合、すべてを結合するか否か</FunctionArgDesc ja_jp>*/
									, i_multidata = %&RSUBool.False
/*<FunctionArgDesc ja_jp>右辺の値によって左辺の値を上書きするか否か</FunctionArgDesc ja_jp>*/
									, i_update_by_rhs = %&RSUBool.True
/*<FunctionArgDesc ja_jp>出力データセット（省略時は左辺の更新）</FunctionArgDesc ja_jp>*/
									, ods_output_ds =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_lhs_ds ids_rhs_ds i_condition)
	%local /readonly _TMP_DS_WORKING_LHS = %&RSUDS.GetTempDSName(work_lhs);
	%local /readonly _TMP_DS_WORKING_RHS = %&RSUDS.GetTempDSName(work_rhs);
	%local _hash_define_key_code;
	%local _hash_option_code;
	%Prv_RSUDSJoin_PrepareJoin(ids_lhs_ds = &ids_lhs_ds.
										, ids_rhs_ds = &ids_rhs_ds.
										, i_condition = &i_condition.
										, i_data_variables = &i_data_variables.
										, i_multidata = &i_multidata.
										, ods_work_ds_lhs = &_TMP_DS_WORKING_LHS.
										, ods_work_ds_rhs = &_TMP_DS_WORKING_RHS.
										, ovar_hash_define_key_code = _hash_define_key_code
										, ovar_hash_option_code = _hash_option_code)
	%local /readonly _DS_OUTPUT = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_lhs_ds., &ods_output_ds.);
	data &_DS_OUTPUT.;
		set &_TMP_DS_WORKING_LHS.;
		if (_N_ = 1) then do;
			declare hash h_rhs(dataset: "&_TMP_DS_WORKING_RHS." &_hash_option_code.);
			&_hash_define_key_code.
			h_rhs.definedata(all: 'yes');
			h_rhs.definedone();
		end;
		__rsu_join_rc = h_rhs.find();
		if (__rsu_join_rc = 0) then do;
			output;
		end;
	%if (&i_multidata.) %then %do;
		if (__rsu_join_rc = 0) then do;
			__rsu_join_rc = h_rhs.find_next();
			do while(__rsu_join_rc = 0);
				output;
				__rsu_join_rc = h_rhs.find_next();
			end;
		end;
	%end;
		drop
			__rsu_join_:
		;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_WORKING_LHS. &_TMP_DS_WORKING_RHS.)
%mend RSUDSJoin__InnerJoin;

/*<FunctionDesc ja_jp>Full-Join</FunctionDesc ja_jp>*/
%macro RSUDSJoin__FullJoin(
/*<FunctionArgDesc ja_jp>transaction データセット（左辺）</FunctionArgDesc ja_jp>*/
									ids_lhs_ds
/*<FunctionArgDesc ja_jp>master データセット（右辺）</FunctionArgDesc ja_jp>*/
									, ids_rhs_ds
/*<FunctionArgDesc ja_jp>結合条件（例： (a b)=(c d)のように設定）</FunctionArgDesc ja_jp>*/
									, i_condition =
/*<FunctionArgDesc ja_jp>master データセットのデータ変数</FunctionArgDesc ja_jp>*/
									, i_data_variables =
/*<FunctionArgDesc ja_jp>1つのキーに複数のレコードがある場合、すべてを結合するか否か</FunctionArgDesc ja_jp>*/
									, i_multidata = %&RSUBool.False
/*<FunctionArgDesc ja_jp>右辺の値によって左辺の値を上書きするか否か</FunctionArgDesc ja_jp>*/
									, i_update_by_rhs = %&RSUBool.True
/*<FunctionArgDesc ja_jp>出力データセット（省略時は左辺の更新）</FunctionArgDesc ja_jp>*/
									, ods_output_ds =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_lhs_ds ids_rhs_ds i_condition)
	%local /readonly _TMP_DS_WORKING_LHS = %&RSUDS.GetTempDSName(work_lhs);
	%local /readonly _TMP_DS_WORKING_RHS = %&RSUDS.GetTempDSName(work_rhs);
	%local _hash_define_key_code;
	%local _hash_option_code;
	%Prv_RSUDSJoin_PrepareJoin(ids_lhs_ds = &ids_lhs_ds.
										, ids_rhs_ds = &ids_rhs_ds.
										, i_condition = &i_condition.
										, i_data_variables = &i_data_variables.
										, i_multidata = &i_multidata.
										, ods_work_ds_lhs = &_TMP_DS_WORKING_LHS.
										, ods_work_ds_rhs = &_TMP_DS_WORKING_RHS.
										, ovar_hash_define_key_code = _hash_define_key_code
										, ovar_hash_option_code = _hash_option_code)
	%local /readonly _DS_OUTPUT = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_lhs_ds., &ods_output_ds.);
	data &_DS_OUTPUT.;
		set &_TMP_DS_WORKING_LHS. end = eof;
		if (_N_ = 1) then do;
			declare hash h_rhs(dataset: "&_TMP_DS_WORKING_RHS." &_hash_option_code.);
			&_hash_define_key_code.
			h_rhs.definedata(all: 'yes');
			h_rhs.definedone();
		end;
		__rsu_join_rc = h_rhs.find();
		__rsu_join_is_joined = (__rsu_join_rc = 0);
		output;
		if (__rsu_join_is_joined) then do;
			h_rhs.replace();
		end;
	%if (&i_multidata.) %then %do;
		if (__rsu_join_rc = 0) then do;
			__rsu_join_rc = h_rhs.find_next();
			do while(__rsu_join_rc = 0);
				__rsu_join_is_joined = 1;
				h_rhs.replace();
				output;
				__rsu_join_rc = h_rhs.find_next();
			end;
		end;
	%end;
		if (eof) then do;
			call missing(of _all_);
			declare hiter hi_rhs('h_rhs');
			do while(hi_rhs.next() = 0);
				if (__rsu_join_is_joined ne 1) then do;
					output;
				end;
			end;
		end;
		drop
			__rsu_join_:
		;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_WORKING_LHS. &_TMP_DS_WORKING_RHS.)
%mend RSUDSJoin__FullJoin;

/*<FunctionDesc ja_jp>共通部分以外を取り出します</FunctionDesc ja_jp>*/
%macro RSUDSJoin__NonIntersection(
/*<FunctionArgDesc ja_jp>transaction データセット（左辺）</FunctionArgDesc ja_jp>*/
											ids_lhs_ds
/*<FunctionArgDesc ja_jp>master データセット（右辺）</FunctionArgDesc ja_jp>*/
											, ids_rhs_ds
/*<FunctionArgDesc ja_jp>結合条件（例： (a b)=(c d)のように設定）</FunctionArgDesc ja_jp>*/
											, i_condition =
/*<FunctionArgDesc ja_jp>master データセットのデータ変数</FunctionArgDesc ja_jp>*/
											, i_data_variables =
/*<FunctionArgDesc ja_jp>1つのキーに複数のレコードがある場合、すべてを結合するか否か</FunctionArgDesc ja_jp>*/
											, i_multidata = %&RSUBool.False
/*<FunctionArgDesc ja_jp>右辺の値によって左辺の値を上書きするか否か</FunctionArgDesc ja_jp>*/
											, i_update_by_rhs = %&RSUBool.True
/*<FunctionArgDesc ja_jp>出力データセット（省略時は左辺の更新）</FunctionArgDesc ja_jp>*/
											, ods_output_ds =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_lhs_ds ids_rhs_ds i_condition)
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_lhs_ds ids_rhs_ds i_condition)
	%local /readonly _TMP_DS_WORKING_LHS = %&RSUDS.GetTempDSName(work_lhs);
	%local /readonly _TMP_DS_WORKING_RHS = %&RSUDS.GetTempDSName(work_rhs);
	%local _hash_define_key_code;
	%local _hash_option_code;
	%Prv_RSUDSJoin_PrepareJoin(ids_lhs_ds = &ids_lhs_ds.
										, ids_rhs_ds = &ids_rhs_ds.
										, i_condition = &i_condition.
										, i_data_variables = &i_data_variables.
										, i_multidata = &i_multidata.
										, ods_work_ds_lhs = &_TMP_DS_WORKING_LHS.
										, ods_work_ds_rhs = &_TMP_DS_WORKING_RHS.
										, ovar_hash_define_key_code = _hash_define_key_code
										, ovar_hash_option_code = _hash_option_code)
	%local /readonly _DS_OUTPUT = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_lhs_ds., &ods_output_ds.);
	data &_DS_OUTPUT.;
		set &_TMP_DS_WORKING_LHS. end = eof;
		if (_N_ = 1) then do;
			declare hash h_rhs(dataset: "&_TMP_DS_WORKING_RHS." &_hash_option_code.);
			&_hash_define_key_code.
			h_rhs.definedata(all: 'yes');
			h_rhs.definedone();
		end;
		__rsu_join_rc = h_rhs.find();
		__rsu_join_is_joined = (__rsu_join_rc = 0);
		if (not __rsu_join_is_joined) then do;
			output;
		end;
		if (__rsu_join_is_joined) then do;
			h_rhs.replace();
		end;
	%if (&i_multidata.) %then %do;
		if (__rsu_join_rc = 0) then do;
			__rsu_join_rc = h_rhs.find_next();
			do while(__rsu_join_rc = 0);
				__rsu_join_is_joined = 1;
				h_rhs.replace();
				output;
				__rsu_join_rc = h_rhs.find_next();
			end;
		end;
	%end;
		if (eof) then do;
			call missing(of _all_);
			declare hiter hi_rhs('h_rhs');
			do while(hi_rhs.next() = 0);
				if (__rsu_join_is_joined ne 1) then do;
					output;
				end;
			end;
		end;
		drop
			__rsu_join_:
		;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_WORKING_LHS. &_TMP_DS_WORKING_RHS.)
%mend RSUDSJoin__NonIntersection;

/*<FunctionDesc ja_jp>左辺のデータセットから右辺データセットとのきゅつう部分を取り除きます</FunctionDesc ja_jp>*/
%macro RSUDSJoin__Subtract(
/*<FunctionArgDesc ja_jp>transaction データセット（左辺）</FunctionArgDesc ja_jp>*/
									ids_lhs_ds
/*<FunctionArgDesc ja_jp>master データセット（右辺）</FunctionArgDesc ja_jp>*/
									, ids_rhs_ds
/*<FunctionArgDesc ja_jp>結合条件（例： (a b)=(c d)のように設定）</FunctionArgDesc ja_jp>*/
									, i_condition =
/*<FunctionArgDesc ja_jp>出力データセット（省略時は左辺の更新）</FunctionArgDesc ja_jp>*/
									, ods_output_ds =
									);
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
	data &_TMP_DS_WORKING_RHS.;
		set &ids_rhs_ds.;
		if (0) then do;
			set &ids_rhs_ds.(keep = &_keys_rhs. rename = &_keys_rename_code_rhs.);
		end;
		&_keys_substitution_code_rhs.
		keep
			__rsu_join_temp_key_:
		;
	run;
	quit;
	%local /readonly _TMP_DS_WORKING_LHS = %&RSUDS.GetTempDSName(work_lhs);
	data &_TMP_DS_WORKING_LHS.;
		set &ids_lhs_ds.;
		if (0) then do;
			set &ids_lhs_ds.(keep = &_keys_lhs. rename = &_keys_rename_code_lhs.);
		end;
		&_keys_substitution_code_lhs.
	run;
	quit;

	%local /readonly _DS_OUTPUT = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_lhs_ds., &ods_output_ds.);
	data &_DS_OUTPUT.;
		set &_TMP_DS_WORKING_LHS.;
		if (_N_ = 1) then do;
			declare hash h_rhs(dataset: "&_TMP_DS_WORKING_RHS.");
			&_hash_define_key_code.
			h_rhs.definedone();
		end;
		__rsu_join_rc = h_rhs.find();
		if (h_rhs.check() = 0) then do;
			delete;
		end;
		drop
			__rsu_join_:
		;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_WORKING_LHS. &_TMP_DS_WORKING_RHS.)
%mend RSUDSJoin__Subtract;

/*<FunctionDesc ja_jp>CrossJoin（直積）</FunctionDesc ja_jp>*/
%macro RSUDSJoin__CrossJoin(
/*<FunctionArgDesc ja_jp>transaction データセット（左辺）</FunctionArgDesc ja_jp>*/
									ids_lhs_ds
/*<FunctionArgDesc ja_jp>master データセット（右辺）</FunctionArgDesc ja_jp>*/
									, ids_rhs_ds
/*<FunctionArgDesc ja_jp>master データセットのデータ変数</FunctionArgDesc ja_jp>*/
									, i_data_variables =
/*<FunctionArgDesc ja_jp>右辺の値によって左辺の値を上書きするか否か</FunctionArgDesc ja_jp>*/
									, i_update_by_rhs = %&RSUBool.True
/*<FunctionArgDesc ja_jp>出力データセット（省略時は左辺の更新）</FunctionArgDesc ja_jp>*/
									, ods_output_ds =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_lhs_ds ids_rhs_ds)

	%local _keys_lhs;
	%let _keys_lhs = __rsu_join_temp_key_1;
	%local _keys_rhs;
	%let _keys_rhs = __rsu_join_temp_key_1;
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
		%let _no_of_data_vars = %&RSUArray.Size(_array_hash_data_def);
	%end;
	%else %do;
		%let _array_hash_data_def = %&RSUArray.CreateBlank();
	%end;
	%local _data_variable;
	%local /readonly _TMP_DS_WORKING_RHS = %&RSUDS.GetTempDSName(work_rhs);
	data &_TMP_DS_WORKING_RHS.;
		set &ids_rhs_ds.;
		__rsu_join_temp_key_1 = _N_;
		keep
			__rsu_join_temp_key_1
	%do %while(%&RSUArray.ForEach(_array_hash_data_def, _data_variable));
			&_data_variable.
	%end;
		;
	run;
	quit;
	%&RSUArray.Dispose(_array_hash_data_def)

	%local /readonly _TMP_DS_WORKING_LHS = %&RSUDS.GetTempDSName(work_lhs);
	data &_TMP_DS_WORKING_LHS.;
		set &ids_lhs_ds.;
		if (0) then do;
			set &_TMP_DS_WORKING_RHS.;
		end;
	run;
	quit;
	%local /readonly _DS_OUTPUT = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_lhs_ds., &ods_output_ds.);
	data &_DS_OUTPUT.;
		set &_TMP_DS_WORKING_LHS.;
		if (_N_ = 1) then do;
			declare hash h_rhs(dataset: "&_TMP_DS_WORKING_RHS.");
			h_rhs.definekey('__rsu_join_temp_key_1');
			h_rhs.definedata(all: 'yes');
			h_rhs.definedone();
			declare hiter hi_rhs('h_rhs');
		end;
		__rsu_join_rc = hi_rhs.first();
		do while(__rsu_join_rc = 0);
			output;
			__rsu_join_rc = hi_rhs.next();
		end;
		drop
			__rsu_join_rc
			__rsu_join_temp_key_:
		;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_WORKING_LHS. &_TMP_DS_WORKING_RHS.)
%mend RSUDSJoin__CrossJoin;

/*<FunctionDesc ja_jp>データセットを連結（Append）します</FunctionDesc ja_jp>*/
%macro RSUDSJoin__Append(
/*<FunctionArgDesc ja_jp>Append元データセット</FunctionArgDesc ja_jp>*/
								iods_base_ds =
/*<FunctionArgDesc ja_jp>Appendするデータセット</FunctionArgDesc ja_jp>*/
								, ids_data_ds =
								);
/*<FunctionDetail ja_jp>
Append元が存在しない場合は新規に生成します
</FunctionDetail ja_jp>*/
/*<FunctionNote ja_jp>
内部では\texttt{proc append}を呼び出しているので、元データセットと追加データセットの定義が異なるなどの不整合がある場合にはエラーになります
</FunctionNote ja_jp>*/
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_base_ds ids_data_ds)
	%if (not %&RSUDS.Exists(ids_dataset = &iods_base_ds.)) %then %do;
		data &iods_base_ds.;
			set &ids_data_ds.;
		run;
		quit;
	%end;
	%else %do;
		proc append base = &iods_base_ds. data = &ids_data_ds.;
		run;
		quit;
	%end;
%mend RSUDSJoin__Append;

/*<FunctionDesc ja_jp>データセットを縦結合します</FunctionDesc ja_jp>*/
%macro RSUDSJoin__Concat(
/*<FunctionArgDesc ja_jp>縦結合元データセット</FunctionArgDesc ja_jp>*/
								iods_base_ds =
/*<FunctionArgDesc ja_jp>縦結合するデータセット</FunctionArgDesc ja_jp>*/
								, ids_data_ds =
								);
/*<FunctionDetail ja_jp>
Append元が存在しない場合は新規に生成します
</FunctionDetail ja_jp>*/
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_base_ds ids_data_ds);
	%if (not %&RSUDS.Exists(ids_dataset = &iods_base_ds.)) %then %do;
		data &iods_base_ds.;
			set &ids_data_ds.;
		run;
		quit;
	%end;
	%else %do;
		data &iods_base_ds.;
			set
				&iods_base_ds.
				&ids_data_ds.
			;
		run;
		quit;
	%end;
%mend RSUDSJoin__Concat;

