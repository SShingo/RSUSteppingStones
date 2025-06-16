/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_DS.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/2/13
/*
/* ! 20220215 hashを使うとinsertとかもできる！
/* マニュアルDATA Step Component Objects
/* add
/* output
/* has_next
/************************************************************************************/
/*<PackageID>RSUDS</PackageID>*/
/*<CategoryID>Cate_DataHandling</CategoryID>*/
/*<PackagePurpose ja_jp>データセット操作</PackagePurpose ja_jp>*/
/*<PackageDesc ja_jp>SAS データセットに関連する操作を行うマクロ群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulate dataset</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>データセットパッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUDS, RSUDS__)
/*<ConstantDesc ja_jp>データセットイテレータクラス定義ファイル</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_CLASS_FILE_DS_ITERATOR, RSU_PKG_Class_IteratorDS)

/*<FunctionDesc ja_jp>一時データセットの名称を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>一時データセット名称</FunctionReturn ja_jp>*/
%macro RSUDS__GetTempDSName(
/*<FunctionArgDesc ja_jp>Prefix 追加文字列</FunctionArgDesc ja_jp>*/
									i_prefix
/*<FunctionArgDesc ja_jp>連番部桁数</FunctionArgDesc ja_jp>*/
									, i_digit = &RSU_G_DATASET_ID_DIGIT.
									);
/*<FunctionDetail ja_jp>
プログラム内で一時データセットをWORKライブラリに生成するケースは頻繁に発生します。このとき、``\texttt{WORK.temp}''などという安易な名称のデータセットを生成すると、他の場所で同名称のデータセットを使っている場合に深刻な結果をもたらす可能性があります。
このマクロはセッションで完全に一意のデータセット名称を払い出すので、一時データセット名はこのマクロを使って生成することを勧めます。
</FunctionDetail ja_jp>*/
	%local /readonly _PREFIX = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_prefix), RSU_TMP_DS, &i_prefix.)_;
	/* !一度ここでマクロ変数に格納しないと、使う側でスペースがはいってしまう */
	%local /readonly _RSU_DS_GETTMPDSNAME = %&RSUUtil.GetSequenceId(i_prefix = &_PREFIX.
																								, iovar_sequence = RSU_g_sequence_dataset
																								, i_digit = &i_digit.);
	WORK.&_RSU_DS_GETTMPDSNAME.
%mend RSUDS__GetTempDSName;

/*<FunctionDesc ja_jp>データセットが存在しているか否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0:存在しない、1:存在する</FunctionReturn ja_jp>*/
%macro RSUDS__Exists(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
							ids_dataset
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%sysfunc(exist(&ids_dataset))
%mend RSUDS__Exists;

/*<FunctionDesc ja_jp>データセットの存在を検証します（検証に失敗した場合処理が中断します）</FunctionDesc ja_jp>*/
%macro RSUDS__VerifyExists(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
									ids_dataset
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%&&RSUError.AbortIf(not %RSUDS__Exists(ids_dataset = &ids_dataset.)
							, i_msg = %&RSUMsg.DATASET_NOT_FOUND(&ids_dataset.))
%mend RSUDS__VerifyExists;

/*<FunctionDesc ja_jp>データセット（1レベル、または2レベル）のライブラリ名を返します</FunctionDesc ja_jp>*/
%macro RSUDS__GetLibname(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
								ids_dataset
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%local _lib;
	%if (0 < %index(&ids_dataset., .)) %then %do;
		%let _lib = %scan(&ids_dataset., 1, .);
	%end;
	%else %do;
		%let _lib = WORK;
	%end;
	&_lib.
%mend RSUDS__GetLibname;

/*<FunctionDesc ja_jp>データセット（1レベル、または2レベル）のデータセット名を返します</FunctionDesc ja_jp>*/
%macro RSUDS__GetDSname(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
								ids_dataset
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%scan(&ids_dataset., -1, .)
%mend RSUDS__GetDSname;

/*<FunctionDesc ja_jp>データセットに付与されているラベルを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>データセットラベル</FunctionReturn ja_jp>*/
%macro RSUDS__GetLabel(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
								ids_dataset
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%Prv_RSUDS__GetDSPropertyC(ids_dataset = &ids_dataset.
										, i_property_name = label)
%mend RSUDS__GetLabel;

/*<FunctionDesc ja_jp>指定データセットのレコード数を返します。</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>レコード数</FunctionReturn ja_jp>*/
%macro RSUDS__GetCount(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
								ids_dataset
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%Prv_RSUDS__GetDSPropertyN(ids_dataset = &ids_dataset.
										, i_property_name = nlobsf)
%mend RSUDS__GetCount;

/*<FunctionDesc ja_jp>データセットの変数数を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>変数の数</FunctionReturn ja_jp>*/
%macro RSUDS__GetNoOfVariables(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
										ids_dataset
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%Prv_RSUDS__GetDSPropertyN(ids_dataset = &ids_dataset.
										, i_property_name = nvars)
%mend RSUDS__GetNoOfVariables;

/*<FunctionDesc ja_jp>元データセットに指定変数が定義されているか否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: 変数が定義されていない\quad \%\&RSUBool.True: 変数が定義されている</FunctionReturn ja_jp>*/
%macro RSUDS__IsVarDefined(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
									ids_dataset =
/*<FunctionArgDesc ja_jp>変数名</FunctionArgDesc ja_jp>*/
									, i_var_name =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset i_var_name)
	%local /readonly _RSU_DS_DSID = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&ids_dataset., I)));
	%local /readonly _RSU_DS_RESULT = %Int_RSUDS_IsVarDefined(i_dsid = &_RSU_DS_DSID.
																				, i_var_name = &i_var_name.);
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&_RSU_DS_DSID.)))
	&_RSU_DS_RESULT.
%mend RSUDS__IsVarDefined;

/*<FunctionDesc ja_jp>指定データセットが空か否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: データセットは空ではない\quad \%\&RSUBool.True: データセットが空</FunctionReturn ja_jp>*/
%macro RSUDS__IsDSEmpty(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
								ids_dataset
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%local /readonly _NO_OF_OBS = %RSUDS__GetCount(ids_dataset = &ids_dataset.);
	%eval(&_no_of_obs. = 0)
%mend RSUDS__IsDSEmpty;

/*<FunctionDesc ja_jp>データセットの変数の配列を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>データセットの変数名の配列</FunctionReturn ja_jp>*/
%macro RSUDS__GetVariableArray(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
										ids_dataset
/*<FunctionArgDesc ja_jp>走査対象変数名フィルタ正規表現</FunctionArgDesc ja_jp>*/
										, i_regex_include =
/*<FunctionArgDesc ja_jp>除外変数正規表現（優先）</FunctionArgDesc ja_jp>*/
										, i_regex_exclude =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%local _var_regex_include;
	%if (%&RSUMacroVariable.IsBlank(i_regex_include)) %then %do;
		%let _var_regex_include = %sysfunc(prxparse(/./));
	%end;
	%else %do;
		%let _var_regex_include = %sysfunc(prxparse(&i_regex_include.));
	%end;
	%local _var_regex_exclude;
	%if (%&RSUMacroVariable.IsBlank(i_regex_exclude)) %then %do;
		%let _var_regex_exclude = %sysfunc(prxparse(/_{50}/));	/* ! 絶対存在しない変数名 */
	%end;
	%else %do;
		%let _var_regex_exclude = %sysfunc(prxparse(&i_regex_exclude.));
	%end;

	%local /readonly _RSU_DS_GETCOLUMN_DSID = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&ids_dataset., I)));
	%local /readonly __ARRAY_VARIABLES = %&RSUArray.CreateBlank();
	%local __index_variable;
	%local __name_variable;
	%do __index_variable = 1 %to %sysfunc(attrn(&_RSU_DS_GETCOLUMN_DSID., nvars));
		%let __name_variable = %sysfunc(varname(&_RSU_DS_GETCOLUMN_DSID., &__index_variable.));
		%if (%sysfunc(prxmatch(&_var_regex_include., &__name_variable.)) and not %sysfunc(prxmatch(&_var_regex_exclude., &__name_variable.))) %then %do;
			%&RSUArray.Add(__ARRAY_VARIABLES
								, &__name_variable.);
		%end;
	%end;
	%syscall prxfree(_var_regex_include);
	%syscall prxfree(_var_regex_exclude);
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&_RSU_DS_GETCOLUMN_DSID.)))
	&__ARRAY_VARIABLES.
%mend RSUDS__GetVariableArray;

/*<FunctionDesc ja_jp>データセットの定義を取得します。</FunctionDesc ja_jp>*/
%macro RSUDS__GetDSDefinition(
/*<FunctionArgDesc ja_jp>対象データセット</FunctionArgDesc ja_jp>*/
										ids_dataset =
/*<FunctionArgDesc ja_jp>走査対象変数名フィルタ正規表現</FunctionArgDesc ja_jp>*/
										, i_regex_include =
/*<FunctionArgDesc ja_jp>除外変数正規表現（優先）</FunctionArgDesc ja_jp>*/
										, i_regex_exclude =
/*<FunctionArgDesc ja_jp>データセット定義を保持するデータセット</FunctionArgDesc ja_jp>*/
										, ods_definition_ds =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset ods_definition_ds)
	%local _var_regex_include;
	%if (%&RSUMacroVariable.IsBlank(i_regex_include)) %then %do;
		%let _var_regex_include = /./;
	%end;
	%else %do;
		%let _var_regex_include = &i_regex_include.;
	%end;
	%local _var_regex_exclude;
	%if (%&RSUMacroVariable.IsBlank(i_regex_exclude)) %then %do;
		%let _var_regex_exclude = /_{50}/;	/* ! 絶対存在しない変数名 */
	%end;
	%else %do;
		%let _var_regex_exclude = &i_regex_exclude.;
	%end;

	%local /readonly _RSU_DS_LIBNAME = %&RSUDS.GetLibname(ids_dataset = &ids_dataset.);
	%local /readonly _RSU_DS_DATASET = %&RSUDS.GetDSname(ids_dataset = &ids_dataset.);
	data &ods_definition_ds.;
		set SASHELP.vcolumn(where = (upcase(libname) = upcase("&_RSU_DS_LIBNAME.")
												and upcase(memname) = upcase("&_RSU_DS_DATASET.")
												and prxmatch("&_var_regex_include.i", trim(name))
												and not prxmatch("&_var_regex_exclude.i", trim(name))));
		rename
			libname = library
			memname = dataset_name
			varnum = variable_num
			name = variable
			type = variable_type
			length = variable_length
			label = variable_label
		;
		keep
			libname
			memname
			varnum
			name
			type
			length
			label
			format
			informat
		;
	run;
	quit;
	proc sort data = &ods_definition_ds.;
		by
			variable_num
		;
	run;
	quit;
%mend RSUDS__GetDSDefinition;

/*<FunctionDesc ja_jp>データセットの属性を取得します。</FunctionDesc ja_jp>*/
%macro RSUDS__GetDSAttribution(
/*<FunctionArgDesc ja_jp>対象データセット</FunctionArgDesc ja_jp>*/
										ids_dataset
/*<FunctionArgDesc ja_jp>取得対象変数（変数名を変更する場合は``:''区切で指定）</FunctionArgDesc ja_jp>*/
										, i_variables = 
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset i_variables)
	%local _variable_info;
	%local _index_variable_info;
	%local _pos_delimiter;
	%local _variable_copy_from;
	%local _variable_copy_to;
	%local _rename_code;
	%local _keep_code;
	%do %while(%&RSUUtil.ForEach(i_items = &i_variables.
										, ovar_item = _variable_info
										, iovar_index = _index_variable_info));
		%let _variable_copy_from = %scan(&_variable_info., 1, :); 
		%let _pos_delimiter = %sysfunc(find(&_variable_info, :));
		%&RSUText.Append(iovar_base = _keep_code
							, i_append_text = &_variable_copy_from.)
		%if (0 < &_pos_delimiter.) %then %do;
			%let _variable_copy_to = %scan(&_variable_info., 2, :);
			%&RSUText.Append(iovar_base = _rename_code
								, i_append_text = &_variable_copy_from. = &_variable_copy_to.)
		%end;
		%else %do;
			%let _variable_copy_to = &_variable_copy_from.;
		%end;
	%end;
	%if (not %&RSUMacroVariable.IsBlank(_rename_code)) %then %do;
		%let _rename_code = rename = &_rename_code.;
	%end;

	%local /readonly _OPTION_CODE = (keep = &_keep_code. &_rename_code.);
	%local /readonly _ATTRIBUTION_CODE = if(_N_ = 0) then do%str(;) set &ids_dataset.&_OPTION_CODE.%str(;) end%str(;);
	&_ATTRIBUTION_CODE.
%mend RSUDS__GetDSAttribution;

/*<FunctionDesc ja_jp>データセットの属性コードを取得します。</FunctionDesc ja_jp>*/
%macro RSUDS__GetDSAttributionCode(
/*<FunctionArgDesc ja_jp>対象データセット</FunctionArgDesc ja_jp>*/
												ids_dataset
/*<FunctionArgDesc ja_jp>走査対象変数名フィルタ正規表現</FunctionArgDesc ja_jp>*/
												, i_regex_include =
/*<FunctionArgDesc ja_jp>除外変数正規表現（優先）</FunctionArgDesc ja_jp>*/
												, i_regex_exclude =
/*<FunctionArgDesc ja_jp>attrib codeを保持するマクロ変数</FunctionArgDesc ja_jp>*/
												, ovar_attrib_code =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset ovar_attrib_code)
	%local /readonly _TMP_DEFINITION_DS = %RSUDS__GetTempDSName(var_info);
	%RSUDS__GetDSDefinition(ids_dataset = &ids_dataset.
									, i_regex_include = &i_regex_include.
									, i_regex_exclude = &i_regex_exclude.
									, ods_definition_ds = &_TMP_DEFINITION_DS.)
	data _null_;
		set &_TMP_DEFINITION_DS. end = eof;
		attrib
			_attrib_code length = $5000.
			_length_code length = $20.
			_format_code length = $20.
			_informat_code length = $20.
			_label_code length = $260.
		;
		retain _attrib_code;
		if (variable_type = 'char') then do;
			_length_code = cats('length=$', put(variable_length, BEST.-L), '.');
		end;
		else do;
			_length_code = cats('length=', put(variable_length, BEST.-L), '.');
		end;
		if (not missing(format)) then do;
			_format_code = cats('format=', format);
		end;
		if (not missing(informat)) then do;
			_informat_code = cats('informat=', informat);
		end;
		if (not missing(variable_label)) then do;
			_label_code = cats('label=', EncloseDQuote(variable_label));
		end;
		_attrib_code = cats(_attrib_code, catx(' ', variable, _length_code, _format_code, _informat_code, _label_code), ';');
		if (eof) then do;
			call symputx("&ovar_attrib_code.", _attrib_code);
		end;
	run;
	quit;
%mend RSUDS__GetDSAttributionCode;

/*<FunctionDesc ja_jp>データセットの変数リストを取得します。</FunctionDesc ja_jp>*/
%macro RSUDS__GetDSVariables(
/*<FunctionArgDesc ja_jp>対象データセット</FunctionArgDesc ja_jp>*/
										ids_dataset
/*<FunctionArgDesc ja_jp>走査対象変数名フィルタ正規表現</FunctionArgDesc ja_jp>*/
										, i_regex_include =
/*<FunctionArgDesc ja_jp>除外変数正規表現（優先）</FunctionArgDesc ja_jp>*/
										, i_regex_exclude =
/*<FunctionArgDesc ja_jp>attrib codeを保持するマクロ変数</FunctionArgDesc ja_jp>*/
										, ovar_variables =
/*<FunctionArgDesc ja_jp>変数リストを保持するデータセット</FunctionArgDesc ja_jp>*/
										, ods_variables =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%local /readonly _TMP_DS_DEFINITION = %RSUDS__GetTempDSName(i_prefix = dataset_def);
	%RSUDS__GetDSDefinition(ids_dataset = &ids_dataset.
									, i_regex_include = &i_regex_include.
									, i_regex_exclude = &i_regex_exclude.
									, ods_definition_ds = &_TMP_DS_DEFINITION.)
	%if (not %&RSUMacroVariable.IsBlank(ovar_variables)) %then %do;
		%local /readonly _DS_ITER_DS_VARS = %&RSUDSIterator.Create(&_TMP_DS_DEFINITION.);
		%do %while(%&RSUDSIterator.Next(_DS_ITER_DS_VARS));
			%&RSUText.Append(iovar_base = &ovar_variables.
								, i_append_text = %&RSUDSIterator.Current(_DS_ITER_DS_VARS, variable))
		%end;
		%&RSUDSIterator.Dispose(_DS_ITER_DS_VARS)
	%end;
	%else %if (not %&RSUMacroVariable.IsBlank(ods_variables)) %then %do;
		%&RSUDS.Let(i_query = &_TMP_DS_DEFINITION.
						, ods_dest_ds = &ods_variables.)
	%end;
	%&RSUDS.Delete(&_TMP_DS_DEFINITION.)
%mend RSUDS__GetDSVariables;

/*<FunctionDesc ja_jp>変数の属性をコピーするコードを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>変数の属性を設定するattrib コードー（data step内で使用するコード）</FunctionReturn ja_jp>*/
%macro RSUDS__GetVariableAttr(
/*<FunctionArgDesc ja_jp>コピー元データセット</FunctionArgDesc ja_jp>*/
										ids_dataset =
/*<FunctionArgDesc ja_jp>コピー元変数。空欄の場合、元データセットの変数をすべてコピーします。var_a(var_b) とすると、元データセットの変数var_aを変数var_bとして生成します。</FunctionArgDesc ja_jp>*/
										, i_variables =
/*<FunctionArgDesc ja_jp>コピー先変数名（修正子）</FunctionArgDesc ja_jp>*/
										, i_variable_modifier =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%if (%&RSUMacroVariable.IsBlank(i_variables)) %then %do;
		if (0) then set &ids_dataset.;
		%return;
	%end;

	%local _variable_info;
	%local _index_variable_info;
	%local _regex_rc;
	%local _variable_src;
	%local _variable_dest;
	%local _keep_code;
	%local _rename_code;
	%local /readonly _REGEX_VAR_INFO = %sysfunc(prxparse(/^(\w+)(\((\w+)\))?$/));
	%do %while(%&RSUUtil.ForEach(i_items = &i_variables.
										, ovar_item = _variable_info
										, iovar_index = _index_variable_info));
		%let _regex_rc = %sysfunc(prxmatch(&_REGEX_VAR_INFO., &_variable_info.));
		%let _variable_src = %sysfunc(prxposn(&_REGEX_VAR_INFO., 1, &_variable_info.));
		%let _variable_dest = %sysfunc(prxposn(&_REGEX_VAR_INFO., 3, &_variable_info.));
		%if (%&RSUMacroVariable.IsBlank(_variable_dest)) %then %do;
			%let _variable_dest = &_variable_src.;
		%end;
		%&RSUText.Append(iovar_base = _variable_dest
							, i_append_text = &i_variable_modifier.
							, i_delimiter = _)
		%&RSUText.Append(iovar_base = _keep_code
							, i_append_text = &_variable_src.)
		%if (&_variable_src. ne &_variable_dest.) %then %do;
			%&RSUText.Append(iovar_base = _rename_code
								, i_append_text = &_variable_src. = &_variable_dest.)
		%end;
	%end;
	%if (not %&RSUMacroVariable.IsBlank(_rename_code)) %then %do;
		%let _rename_code = rename = (&_rename_code.);
	%end;

	if (0) then set &ids_dataset.(keep = &_keep_code. &_rename_code.);
%mend RSUDS__GetVariableAttr;

/*<FunctionDesc ja_jp>データセットの最初のレコードを取得します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>データセットの最初のレコードの値を区切り文字で連結した文字列</FunctionReturn ja_jp>*/
%macro RSUDS__Get1stRecord(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
									ids_dataset =
/*<FunctionArgDesc ja_jp>区切り文字</FunctionArgDesc ja_jp>*/
									, i_delimiter = %str(,)
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%local /readonly _RSU_DS_DSID = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&i_query., I)));

	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fetch(&_RSU_DS_DSID.)))
	%let _values = %Int_RSUDS_GetCurrentRecord(i_dsid = &_RSU_DS_DSID.
															, i_delimiter = &i_delimiter.);
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&_DS_RSU_DS_DSIDID.)))
	&_values.
%mend RSUDS__Get1stRecord;

/*<FunctionDesc ja_jp>指定変数で一意化したデータセットを取得します</FunctionDesc ja_jp>*/
%macro RSUDS__GetUniqueList(
/*<FunctionArgDesc ja_jp>入力データ</FunctionArgDesc ja_jp>*/
									i_query =
/*<FunctionArgDesc ja_jp>一意対象変数リスト（ソート順のオプション含むコード）</FunctionArgDesc ja_jp>*/
									, i_by_variables =
/*<FunctionArgDesc ja_jp>代表値抽出タイプ</FunctionArgDesc ja_jp>*/
									, i_pickup_type = %&RSUPickup.First
/*<FunctionArgDesc ja_jp>一意化されたデータセット</FunctionArgDesc ja_jp>*/
									, ods_output_ds =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_by_variables i_pickup_type ods_output_ds)
	%local /readonly _TMP_DS_SOURCE = %RSUDS__GetTempDSName();
	%RSUDS__Let(i_query = &i_query.
					, ods_dest_ds = &_TMP_DS_SOURCE.)

	%local /readonly _TMP_DS_OUTPUT_FRAME = %RSUDS__GetTempDSName();
	data &_TMP_DS_OUTPUT_FRAME.;
		attrib
			_tmp_index length = 8.
		;
		set &_TMP_DS_SOURCE.(obs = 0);
	run;
	quit;

	%local _key_variable;
	%local _index_key_variable;
	data _null_;
		attrib
			_tmp_index length = 8.
		;
		set &_TMP_DS_SOURCE. end = eof;
		if (_N_ = 1) then do;
			declare hash h_src();
	%do %while(%&RSUUtil.ForEach(i_items = &i_by_variables.
										, ovar_item = _key_variable
										, iovar_index = _index_key_variable));
			_rc = h_src.definekey("&_key_variable.");
			_rc = h_src.definedata("&_key_variable.");
	%end;
			_rc = h_src.definedata('_tmp_index');
			_rc = h_src.definedone();
			
			declare hash h_unique_list(dataset: "&_TMP_DS_OUTPUT_FRAME.", ordered: 'yes');
			_rc = h_unique_list.definekey('_tmp_index');
			_rc = h_unique_list.definedata(all: 'yes');
			_rc = h_unique_list.definedone();
		end;
		_tmp_index = _N_;
		_rc = h_src.find();
		if (_rc ne 0) then do;
			h_src.add();
		end;
	%if (&i_pickup_type. = %&RSUPickup.First) %then %do;
		_rc = h_unique_list.add();
	%end;
	%else %do;
		_rc = h_unique_list.replace();
	%end;
		if (eof) then do;
			_rc = h_unique_list.output(dataset: "&ods_output_ds.(drop = _tmp_index)");
		end;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_OUTPUT_FRAME.)
	%&RSUDS.Delete(&_TMP_DS_SOURCE.)
%mend RSUDS__GetUniqueList;

/*<FunctionDesc ja_jp>データセットを一時データセットにコピーします</FunctionDesc ja_jp>*/
%macro RSUDS__CopyToTmp(
/*<FunctionArgDesc ja_jp>コピー元データセット</FunctionArgDesc ja_jp>*/
								ids_source_ds =
/*<FunctionArgDesc ja_jp>一時データセット名を保持する変数</FunctionArgDesc ja_jp>*/
								, ovar_tmp_dataset_name =
/*<FunctionArgDesc ja_jp>データセットラベル</FunctionArgDesc ja_jp>*/
								, i_label =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_source_ds ovar_tmp_dataset_name)
	%let &ovar_tmp_dataset_name. = %RSUDS__GetTempDSName();
	%RSUDS__Let(i_query = &ids_source_ds.
					, ods_dest_ds = &&&ovar_tmp_dataset_name.)
	%local /readonly _LABEL = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_label), &ids_source_ds., &i_label.);
	%RSUDS__SetLabel(iods_target_ds = &&&ovar_tmp_dataset_name.
						, i_label = &_LABEL.)
%mend RSUDS__CopyToTmp;

/*<FunctionDesc ja_jp>ディレクトリ内のデータセットをコピーします</FunctionDesc ja_jp>*/
%macro RSUDS__CopyDS(
/*<FunctionArgDesc ja_jp>コピー元ディレクトリ</FunctionArgDesc ja_jp>*/
							i_src_dir =
/*<FunctionArgDesc ja_jp>コピー先ディレクトリ</FunctionArgDesc ja_jp>*/
							, i_dest_dir =);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_src_dir i_dest_dir)
	libname L_SRC "&i_src_dir." compress = yes;
	%if (not %&RSULib.IsLibEmpty(L_SRC)) %then %do;
		libname L_DEST "&i_dest_dir." compress = yes;
		proc copy
			in = L_SRC
			out = L_DEST
			memtype = data
			;
		run;
		quit;
		libname L_DEST clear;
	%end;
	libname L_SRC clear;
%mend RSUDS__CopyDS;

/*<FunctionDesc ja_jp>クエリ結果をデータセットに格納します</FunctionDesc ja_jp>*/
%macro RSUDS__Let(
/*<FunctionArgDesc ja_jp>クエリ</FunctionArgDesc ja_jp>*/
						i_query =
/*<FunctionArgDesc ja_jp>出力データセット</FunctionArgDesc ja_jp>*/
						, ods_dest_ds =
/*<FunctionArgDesc ja_jp>枠のみ作成</FunctionArgDesc ja_jp>*/
						, i_is_frame_only = %&RSUBool.False
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = ods_dest_ds i_query)
	data &ods_dest_ds.;
		set &i_query.;
	%if (&i_is_frame_only.) %then %do;
		stop;
	%end;
	run;
	quit;
%mend RSUDS__Let;

/*<FunctionDesc ja_jp>クエリ結果をデータセットに格納し、元データセットを削除します</FunctionDesc ja_jp>*/
%macro RSUDS__Move(
/*<FunctionArgDesc ja_jp>クエリ</FunctionArgDesc ja_jp>*/
						i_query =
/*<FunctionArgDesc ja_jp>出力データセット</FunctionArgDesc ja_jp>*/
						, ods_dest_ds =
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = ods_dest_ds i_query)
	data &ods_dest_ds.;
		set &i_query.;
	run;
	quit;
	%local /readonly _RSU_DS_MOVE_SOURCE_DS = %scan(&i_query., 1, %str(%());
	%RSUDS__Delete(&_RSU_DS_MOVE_SOURCE_DS.)
%mend RSUDS__Move;

/*<FunctionDesc ja_jp>データセットに一定値の変数を付与します</FunctionDesc ja_jp>*/
%macro RSUDS__AddConstantVariable(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
											iods_dataset =
/*<FunctionArgDesc ja_jp>変数名</FunctionArgDesc ja_jp>*/
											, i_variable_name =
/*<FunctionArgDesc ja_jp>変数長さ</FunctionArgDesc ja_jp>*/
											, i_variable_len =
/*<FunctionArgDesc ja_jp>変数ラベル</FunctionArgDesc ja_jp>*/
											, i_variable_label =
/*<FunctionArgDesc ja_jp>設定値</FunctionArgDesc ja_jp>*/
											, i_variable_value =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_dataset i_variable_name i_variable_len)
	%local /readonly _LABEL_CODE = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_variable_label), , label%str(=)"&i_variable_label.");
	%if (not %&RSUMacroVariable.IsBlank(i_variable_len)) %then %do;
		%if (%substr(&i_variable_len., 1, 1) = $) %then %do;
			data &iods_dataset.;
				set &iods_dataset.;
				attrib
					&i_variable_name. length = &i_variable_len. &_LABEL_CODE.
				;
		%if (%&RSUMacroVariable.IsBlank(i_variable_value)) %then %do;
			call missing(&i_variable_name.);
		%end;
		%else %do;
			&i_variable_name. = "&i_variable_value.";
		%end;
			run;
			quit;
		%end;
		%else %do;
			data &iods_dataset.;
				set &iods_dataset.;
				attrib
					&i_variable_name. length = &i_variable_len. &_LABEL_CODE.
				;
		%if (%&RSUMacroVariable.IsBlank(i_variable_value)) %then %do;
				call missing(&i_variable_name.);
		%end;
		%else %do;
				&i_variable_name. = &i_variable_value.;
		%end;
			run;
			quit;
		%end;
	%end;
%mend RSUDS__AddConstantVariable;

/*<FunctionDesc ja_jp>データセットにグループ番号を付与</FunctionDesc ja_jp>*/
%macro RSUDS__AddGroupSequenceVariable(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
													i_query =
/*<FunctionArgDesc ja_jp>グループのキー変数</FunctionArgDesc ja_jp>*/
													, i_by_variables =
/*<FunctionArgDesc ja_jp>インデックス変数名</FunctionArgDesc ja_jp>*/
													, i_sequence_variable_name =
/*<FunctionArgDesc ja_jp>グループリスト</FunctionArgDesc ja_jp>*/
													, ods_dest_ds =
													);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_by_variables i_sequence_variable_name)
	%local /readonly _DEST_DS = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_dest_ds), %scan(&i_query., 1, %str(%()), &ods_dest_ds.);
	%local _key_variable;
	%local _index_key_variable;
	data &_DEST_DS.(drop = _rc _current_index);
		set &i_query. end = eof;
		attrib
			&i_sequence_variable_name. length = 8.
			_current_index length = 8.
		;
		if (_N_ = 1) then do;
			declare hash h_src();
	%do %while(%&RSUUtil.ForEach(i_items = &i_by_variables.
										, ovar_item = _key_variable
										, iovar_index = _index_key_variable));
			_rc = h_src.definekey("&_key_variable.");
	%end;
			_rc = h_src.definedata("&i_sequence_variable_name.");
			_rc = h_src.definedone();
		end;
		retain _current_index 0;
		if (h_src.check() ne 0) then do;
			&i_sequence_variable_name. = _current_index;
			h_src.add();
			_current_index = _current_index + 1;
		end;
		else do;
			h_src.find();
		end;
	run;
	quit;
%mend RSUDS__AddGroupSequenceVariable;

/*<FunctionDesc ja_jp>データセットに通し番号を付与します</FunctionDesc ja_jp>*/
%macro RSUDS__AddSequenceVariable(
/*<FunctionArgDesc ja_jp>クエリ</FunctionArgDesc ja_jp>*/
											i_query =
/*<FunctionArgDesc ja_jp>連番の変数名</FunctionArgDesc ja_jp>*/
											, i_sequence_variable_name =
/*<FunctionArgDesc ja_jp>連番の開始値</FunctionArgDesc ja_jp>*/
											, i_start_with = 0
/*<FunctionArgDesc ja_jp>出力データセット（省略時は\texttt{i_query}で指定したデータセット</FunctionArgDesc ja_jp>*/
											, ods_dest_ds =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_sequence_variable_name)
	%local /readonly _DEST_DS = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_dest_ds), %scan(&i_query., 1, %str(%()), &ods_dest_ds.);
	data &_DEST_DS;
		set &i_query.;
		&i_sequence_variable_name. = _N_ - 1 + &i_start_with.;
	run;
	quit;
%mend RSUDS__AddSequenceVariable;

/*<FunctionDesc ja_jp>変数を削除します</FunctionDesc ja_jp>*/
%macro RSUDS__DropVariables(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
									iods_dataset =
/*<FunctionArgDesc ja_jp>削除変数</FunctionArgDesc ja_jp>*/
									, i_variables =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_dataset i_variables)
	%RSUDS__Let(i_query = &iods_dataset.(drop = &i_variables.)
					, ods_dest_ds = &iods_dataset.)
%mend RSUDS__DropVariables;

/*<FunctionDesc ja_jp>指定変数以外の変数を削除します</FunctionDesc ja_jp>*/
%macro RSUDS__DropVariablesExcept(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
											iods_dataset =
/*<FunctionArgDesc ja_jp>残す変数</FunctionArgDesc ja_jp>*/
											, i_variables =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_dataset i_variables)
	%RSUDS__Let(i_query = &iods_dataset.(keep = &i_variables.)
					, ods_dest_ds = &iods_dataset.)
%mend RSUDS__DropVariablesExcept;

/*<FunctionDesc ja_jp>指定変数を分割し新規のオブザベーションを生成します</FunctionDesc ja_jp>*/
%macro RSUDS__SplitRow(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
							ids_dataset =
/*<FunctionArgDesc ja_jp>分割対象変数</FunctionArgDesc ja_jp>*/
							, i_variable =
/*<FunctionArgDesc ja_jp>区切り文字</FunctionArgDesc ja_jp>*/
							, i_delimiter =
/*<FunctionArgDesc ja_jp>分割された文字を保持する変数</FunctionArgDesc ja_jp>*/
							, i_splitted_variable =
/*<FunctionArgDesc ja_jp>分割された文字を保持する変数の長さ</FunctionArgDesc ja_jp>*/
							, i_len_splitted_variable =
/*<FunctionArgDesc ja_jp>出力データセット</FunctionArgDesc ja_jp>*/
							, ods_output_ds =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset i_variable i_splitted_variable i_len_splitted_variable ods_output_ds)
	data &ods_output_ds.;
		attrib
			&i_splitted_variable. length = &i_len_splitted_variable.
		;
		set &ids_dataset.;
		_pos_index = 1;
		&i_splitted_variable. = scan(trim(&i_variable.), _pos_index, "&i_delimiter.");
		do while(not missing(&i_splitted_variable.));
			output;
			_pos_index = _pos_index + 1;
			&i_splitted_variable. = scan(trim(&i_variable.), _pos_index, "&i_delimiter.");
		end;
		drop
			_pos_index
		;
	run;
	quit;

%mend RSUDS__SplitRow;

/*<FunctionDesc ja_jp>データセットを複製します</FunctionDesc ja_jp>*/
%macro RSUDS__Clone(
/*<FunctionArgDesc ja_jp>複製元のデータセット</FunctionArgDesc ja_jp>*/
						ids_original_dataset
/*<FunctionArgDesc ja_jp>複製先のデータセット</FunctionArgDesc ja_jp>*/
						, ods_cloned_dataset
/*<FunctionArgDesc ja_jp>複製の際に、すべての変数名に付与する文字列</FunctionArgDesc ja_jp>*/
						, i_modifier =
/*<FunctionArgDesc ja_jp>変数名文字列を付与場所（PRE: 前、POST: 後）</FunctionArgDesc ja_jp>*/
						, i_mod_pos = POST
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_original_dataset ods_cloned_dataset)
	%local /readonly _RSU_DS_DSID = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&ids_original_dataset., I)));

	%local _rename_code;
	%if (not %&RSUMacroVariable.IsBlank(i_modifier)) %then %do;
		%local _var_name;
		%local _rename_element;
		%local _i;
		%do _i = 1 %to %sysfunc(attrn(&_RSU_DS_DSID., nvars));
			%let _var_name = %sysfunc(varname(&_RSU_DS_DSID., &_i.));
			%if (&i_mod_pos. = POST) %then %do;
				%let _rename_element = &_var_name.%str(=)&_var_name.&i_modifier.;
			%end;
			%else %do;
				%let _rename_element = &_var_name.%str(=)&i_modifier.&_var_name.;
			%end;
			%&RSUText.Append(iovar_base = _rename_code
								, i_append_text = &_rename_element.
								, i_delimiter = %str( ))
		%end;
		%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&_RSU_DS_DSID.)))
		%let _rename_code = rename &_rename_code. ;
	%end;

	%local /readonly _RSU_TMP_CLONED_DS = %RSUDS__GetTempDSName();
	data &_RSU_TMP_CLONED_DS.;
		set &ids_original_dataset.;
		&_rename_code.
	run;
	quit;

	%RSUDS__Move(i_query = &_RSU_TMP_CLONED_DS.
					, ods_dest_ds = &ods_cloned_dataset.)
%mend RSUDS__Clone;

/*<FunctionDesc ja_jp>変数を複製します</FunctionDesc ja_jp>*/
%macro RSUDS__CloneVariable(
/*<FunctionArgDesc ja_jp>元のデータセット</FunctionArgDesc ja_jp>*/
						iods_dataset =
/*<FunctionArgDesc ja_jp>複製する変数</FunctionArgDesc ja_jp>*/
						, i_target_variables =
/*<FunctionArgDesc ja_jp>複製の際に、すべての変数名に付与する文字列</FunctionArgDesc ja_jp>*/
						, i_modifier = _
/*<FunctionArgDesc ja_jp>変数名文字列を付与場所（PRE: 前、POST: 後）</FunctionArgDesc ja_jp>*/
						, i_mod_pos = POST
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_dataset i_target_variables i_modifier)
	data &iods_dataset.;
		set &iods_dataset.;
		___obs_index___ = _N_;
	run;
	quit;
	%local /readonly _TMP_CLONE_DS = %RSUDS__GetTempDSName();
	%RSUDS__Let(i_query = &iods_dataset.(keep = &i_target_variables. ___obs_index___)
					, ods_dest_ds = &_TMP_CLONE_DS.)

	%RSUDS__Clone(ids_original_dataset = &_TMP_CLONE_DS.
					, ods_cloned_dataset = &_TMP_CLONE_DS.
					, i_modifier = &i_modifier.
					, i_mod_pos = &i_mod_pos.)
	%RSUDS__InnerJoin(ids_lhs_ds = &iods_dataset.
							, ids_rhs_ds = &_TMP_CLONE_DS.
							, i_conditions = ___obs_index___:___obs_index____)
	%RSUDS__Let(i_query = &iods_dataset.(drop = ___obs_index:)
					, ods_dest_ds = &iods_dataset.)
	%RSUDS__Delete(&_TMP_CLONE_DS.)
%mend RSUDS__CloneVariable;

/*<FunctionDesc ja_jp>データセットを配列に変換します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列ID</FunctionReturn ja_jp>*/
%macro RSUDS__ToArray(
/*<FunctionArgDesc ja_jp>元のデータセット</FunctionArgDesc ja_jp>*/
							i_query
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
							, i_variable
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_variable)
	%local /readonly __ARRAY_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = AR
																							, i_sequence_var = RSU_g_sequence_array);
	%Int_RSUArray_SetItemsByDS(ivar_array = __ARRAY_ID_CREATE
										, i_query = &i_query.
										, i_variable_value = &i_variable.)
	%global &__ARRAY_ID_CREATE._term;
	%let &__ARRAY_ID_RESET._term = %&RSUBool.False;
	%let &__ARRAY_ID_RESET._index = 0;
	&__ARRAY_ID_CREATE.
%mend RSUDS__ToArray;

/*<FunctionDesc ja_jp>データセットを転置します</FunctionDesc ja_jp>*/
%macro RSUDS__Transpose(
/*<FunctionArgDesc ja_jp>元のデータセット</FunctionArgDesc ja_jp>*/
								ids_dataset =
/*<FunctionArgDesc ja_jp>transpose by 変数</FunctionArgDesc ja_jp>*/
								, i_by_variables =
/*<FunctionArgDesc ja_jp>transpose var 変数</FunctionArgDesc ja_jp>*/
								, i_var_variables =
/*<FunctionArgDesc ja_jp>transpose id 変数</FunctionArgDesc ja_jp>*/
								, i_id_variables =
/*<FunctionArgDesc ja_jp>_NAME_ 変数の変更名称</FunctionArgDesc ja_jp>*/
								, i_name_variable_name =
/*<FunctionArgDesc ja_jp>_LABEL_ 変数の変更名称</FunctionArgDesc ja_jp>*/
								, i_label_variable_name =
/*<FunctionArgDesc ja_jp>出力データセット</FunctionArgDesc ja_jp>*/
								, ods_output_ds =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%RSUDS__VerifyExists(&ids_dataset.)
	%local _by_statement;
	%local _drop_code;
	%if (not %&RSUMacroVariable.IsBlank(i_by_variables)) %then %do;
		%RSUDS__AddGroupSequenceVariable(i_query = &ids_dataset.
													, i_by_variables = &i_by_variables.
													, i_sequence_variable_name = _by_index_var
													, ods_dest_ds = WORK.indexed_ds)
		%let _by_statement = by _by_index_var &i_by_variables.;
		%let _drop_code = drop = _by_index_var;
	%end;
	%else %do;
		%&RSUDS.Let(i_query = &ids_dataset.
						, ods_dest_ds = WORK.indexed_ds)
	%end;
	%local /readonly _DEST_DS = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(ods_output_ds), &ids_dataset., &ods_output_ds.);
	%local _rename_var_variable;
	%if (not %&RSUMacroVariable.IsBlank(i_name_variable_name)) %then %do;
		%let _rename_var_variable = _NAME_ = &i_name_variable_name.;
	%end;
	%if (not %&RSUMacroVariable.IsBlank(i_label_variable_name)) %then %do;
		%let _rename_var_variable = &_rename_var_variable. _LABEL_ = &i_label_variable_name.;
	%end;
	%let _rename_var_variable = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(_rename_var_variable), , rename%str(=)(&_rename_var_variable.));
	proc transpose data = WORK.indexed_ds out = &_DEST_DS.(&_drop_code. &_rename_var_variable.);
	%if (not %&RSUMacroVariable.IsBlank(i_by_variables)) %then %do;
		&_by_statement.
	%end;
		var
			&i_var_variables.
		;
	%if (not %&RSUMacroVariable.IsBlank(i_id_variables)) %then %do;
		id
			&i_id_variables.
		;
	%end;
	run;
	quit;
	%&RSUDS.Delete(WORK.indexed_ds)
%mend RSUDS__Transpose;

/*<FunctionDesc ja_jp>データセットの内容をログに出力します</FunctionDesc ja_jp>*/
%macro RSUDS__Print(
/*<FunctionArgDesc ja_jp>保存対象データセット</FunctionArgDesc ja_jp>*/
						ids_dataset =
/*<FunctionArgDesc ja_jp>最大出力レコード数</FunctionArgDesc ja_jp>*/
						, i_max_line = 100
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset i_max_line)
	%local _exported_count;
	data _null_;
		_max_line = &i_max_line.;
		if (_max_line < 0) then do;
			_max_line = 5000;
		end;
		else do;
			_max_line = min(_max_line, 5000);
		end;
		call symputx('_exported_count', _max_line);
	run;

	%local /readonly _RSU_DS_RECORD_COUNT = %RSUDS__GetCount(&ids_dataset.);
	%&RSULogger.PutLog(/////////////// Dataset: &ids_dataset. ///////////////)
	%Prv_RSUDS_PutDSHelper(i_dest_file = log
								, ids_src_dataset = %str(&ids_dataset.(obs = &_exported_count.))
								, i_delimiter = &RSUTab.
								, i_is_header_skipped = 0)
	%if (&_exported_count. < &_RSU_DS_RECORD_COUNT.) %then %do;
		%&RSULogger.PutLog(////////// %&RSUMsg.SHOW_RECORD(&_exported_count., &_RSU_DS_RECORD_COUNT.) /////////)
	%end;
%mend RSUDS__Print;

/*<FunctionDesc ja_jp>データセットの排他ロックを取得します（取得するまで待機）</FunctionDesc ja_jp>*/
%macro RSUDS__Lock(
/*<FunctionArgDesc ja_jp>対象データセット</FunctionArgDesc ja_jp>*/
						ids_dataset =
/*<FunctionArgDesc ja_jp>ロック取得までの最大試行時間（秒）</FunctionArgDesc ja_jp>*/
						, i_timeout = 300
/*<FunctionArgDesc ja_jp>ロック取得試行間隔（秒）</FunctionArgDesc ja_jp>*/
						, i_interval = 1
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%local /readonly _RSU_TMP_TIME_LIMIT_ = %sysevalf(%sysfunc(datetime()) + &i_timeout.);
	lock &ids_dataset.;
	%local _rsu_ds_lock_rc;
	%local _lock;
	%let _lock = &syslckrc.;
	%do %while(0 < &_lock. and %sysevalf(%sysfunc(datetime()) <= &_RSU_TMP_TIME_LIMIT_.));
		%let _rsu_ds_lock_rc = %sysfunc(sleep(&i_interval., 1));
		lock &ids_dataset.;
		%let _lock = &syslckrc.;
	%end;

	%if (0 < &_lock.) %then %do;
		%&RSULogger.PutError(%&RSUMsg.FAIL_GET_EXC_LOCK)
	%end;
%mend RSUDS__Lock;

/*<FunctionDesc ja_jp>データセットの排他ロックを開放します</FunctionDesc ja_jp>*/
%macro RSUDS__Unlock(
/*<FunctionArgDesc ja_jp>対象データセット</FunctionArgDesc ja_jp>*/
							ids_dataset =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	lock &ids_dataset. clear;
%mend RSUDS__Unlock;

/*<FunctionDesc ja_jp>指定変数の値を返します</FunctionDesc ja_jp>*/
%macro RSUDS__GetValue(
/*<FunctionArgDesc ja_jp>対象クエリ</FunctionArgDesc ja_jp>*/
							i_query
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
							, i_variable
							);
/*<FunctionDetail ja_jp>
クエリ検索結果が複数ある場合、最初に見つかった結果が返されます
</FunctionDetail ja_jp>*/
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_variable)
	%local /readonly _RSU_TMP_DS_GETVALUE_DSID_ = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&i_query., I)));
	%local /readonly _RSU_TMP_DS_GET_VALUE_RC_ = %sysfunc(fetch(&_RSU_TMP_DS_GETVALUE_DSID_.));
	%local _rsuds_get_value;
	%if (&_RSU_TMP_DS_GET_VALUE_RC_. = 0) %then %do;
		%let _rsuds_get_value = %sysfunc(fcmp_rsu_ds_get_curr_by_name(&_RSU_TMP_DS_GETVALUE_DSID_., &i_variable.));
	%end;
	%else %if (&_RSU_TMP_DS_GET_VALUE_RC_. = -1) %then %do;
		%&RSULogger.PutWarning(%&RSUMsg.NO_OBSERVATION)
	%end;
	%else %do;
		%&RSULogger.PutError(%&RSUMsg.FAIL_TO_FETCH_RECORD)
	%end;
   %Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&_RSU_TMP_DS_GETVALUE_DSID_.)))
	&_rsuds_get_value.
%mend RSUDS__GetValue;

/*<FunctionDesc ja_jp>データセットの1カラムを連結した文字列を取得</FunctionDesc ja_jp>*/
%macro RSUDS__GetConcatValue(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
									i_query =
/*<FunctionArgDesc ja_jp>連結文字列定義</FunctionArgDesc ja_jp>*/
									, i_variable_def =
/*<FunctionArgDesc ja_jp>区切り文字列</<FunctionArgDesc ja_jp>*/
									, i_delimiter =
/*<FunctionArgDesc ja_jp>連結文字列を保持するマクロ</FunctionArgDesc ja_jp>*/
									, ovar_concat_text =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_variable_def ovar_concat_text)
	%local /readonly _DELIMITER = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_delimiter), %str( ), &i_delimiter.);
	%let &ovar_concat_text. =;
	proc sql noprint;
		select
			&i_variable_def into :&ovar_concat_text. separated by "&_DELIMITER."
		from
			&i_query.
		;
	quit;
%mend RSUDS__GetConcatValue;

/*<FunctionDesc ja_jp>データセットにラベルを付与します</FunctionDesc ja_jp>*/
%macro RSUDS__SetLabel(
/*<FunctionArgDesc ja_jp>対象のデータセット</FunctionArgDesc ja_jp>*/
							iods_target_ds =
/*<FunctionArgDesc ja_jp>ラベル</FunctionArgDesc ja_jp>*/
							, i_label =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_target_ds)
	%local /readonly _LIB_NAME = %RSUDS__GetLibname(&iods_target_ds.);
	%local /readonly _DS_NAME = %RSUDS__GetDSname(&iods_target_ds.);
	proc datasets lib = &_LIB_NAME. nolist;
		modify &_DS_NAME.(label = "&i_label.");
	run;
	quit;
%mend RSUDS__SetLabel;

/*<FunctionDesc ja_jp>データセットを削除します</FunctionDesc ja_jp>*/
%macro RSUDS__Delete(
/*<FunctionArgDesc ja_jp>削除対象のデータセット（スペース区切りで複数指定可）</FunctionArgDesc ja_jp>*/
							iods_datasets
							);
/*<FunctionDetail ja_jp>
存在しないデータセットを指定した場合何も起きません。
</FunctionDetail ja_jp>*/
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_datasets)
	%local _ds;
	%local _index;
	%do %while(%&RSUUtil.ForEach(i_items = &iods_datasets., ovar_item = _ds, iovar_index = _index));
		%if (%RSUDS__Exists(ids_dataset = &_ds.)) %then %do;
			proc delete
				data = &_ds.
				;
			run;
			quit;
		%end;
	%end;
%mend RSUDS__Delete;

/*<FunctionDesc ja_jp>データセットを空にします</FunctionDesc ja_jp>*/
%macro RSUDS__DeleteRows(
/*<FunctionArgDesc ja_jp>対象データセット</FunctionArgDesc ja_jp>*/
								iods_input_ds
								);
	%RSUDS__Let(ods_dest_ds = &iods_input_ds.
					, i_query = &iods_input_ds.(obs = 0))
%mend RSUDS__DeleteRows;

/*<FunctionDesc ja_jp>データセットの欠損値を指定値で置き換えます（数値型のみ）</FunctionDesc ja_jp>*/
%macro RSUDS__ReplaceNullN(
/*<FunctionArgDesc ja_jp>対象データセット</FunctionArgDesc ja_jp>*/
									iods_input_ds =
/*<FunctionArgDesc ja_jp>置き換え対象変数（数値型）</FunctionArgDesc ja_jp>*/
									, i_replaced_vars =
/*<FunctionArgDesc ja_jp>置き換え値</FunctionArgDesc ja_jp>*/
									, i_replace_value = 0);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_input_ds i_replaced_vars i_replace_value)
	data &iods_input_ds.;
		set &iods_input_ds.;
		array num_array &i_replaced_vars.;
		do over num_array;
			if (missing(num_array)) then do;
				num_array = &i_replace_value.;
			end;
		end;
	run;
	quit;
%mend RSUDS__ReplaceNullN;

/*<FunctionDesc ja_jp>データセットの欠損値を指定値で置き換えます（文字型のみ）</FunctionDesc ja_jp>*/
%macro RSUDS__ReplaceNullC(
/*<FunctionArgDesc ja_jp>対象データセット</FunctionArgDesc ja_jp>*/
									iods_input_ds =
/*<FunctionArgDesc ja_jp>置き換え対象変数（文字型）</FunctionArgDesc ja_jp>*/
									, i_replaced_vars =
/*<FunctionArgDesc ja_jp>置き換え値</FunctionArgDesc ja_jp>*/
									, i_replace_value =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_input_ds i_replaced_vars i_replace_value)
	data &iods_input_ds.;
		set &iods_input_ds.;
		array num_array &i_replaced_vars.;
		do over num_array;
			if (missing(num_array)) then do;
				num_array = "&i_replace_value.";
			end;
		end;
	run;
	quit;
%mend RSUDS__ReplaceNullC;

/*<FunctionDesc ja_jp>データセットのラベルをクリアします</FunctionDesc ja_jp>*/
%macro RSUDS__ClearVariableLabel(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
											iods_dataset =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_dataset)
	%&RSUDS.VerifyExists(&iods_dataset.)
	%local /readonly _LIBNAME = %RSUDS__GetLibname(&iods_dataset.);
	%local /readonly _DSNAME = %RSUDS__GetDSname(&iods_dataset.);
	proc datasets lib = &_LIBNAME. noprint;
		modify &_DSNAME.;
		attrib
			_all_ label = ''
		;
	run;
	quit;
%mend RSUDS__ClearVariableLabel;

/*<FunctionDesc ja_jp>データセットの変数を並べ替えます</FunctionDesc ja_jp>*/
%macro RSUDS__ArrangeVarOrder(
/*<FunctionArgDesc ja_jp>入力データセット</FunctionArgDesc ja_jp>*/
										iods_dataset =
/*<FunctionArgDesc ja_jp>先行させる変数リスト</FunctionArgDesc ja_jp>*/
										, i_leading_vars =
/*<FunctionArgDesc ja_jp>後方に移動させる変数リスト</FunctionArgDesc ja_jp>*/
										, i_following_vars =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_dataset)
	%local /readonly _RSU_TMP_VAR_LIST = %RSUDS__GetTempDSName();
	%&RSUDS.GetDSDefinition(ids_dataset = &iods_dataset.
									, ods_definition_ds = &_RSU_TMP_VAR_LIST.)
	%local _exclude_vars;
	data _null_;
		attrib
			_exclude_vars length = $1000.
		;
		_exclude_vars = prxchange('s/\s+/","/', -1, "&i_leading_vars. &i_following_vars.");
		_exclude_vars = cats('"', _exclude_vars, '"');
		call symputx('_exclude_vars', _exclude_vars);
	run;

	%local _org_vars;
	proc sql noprint;
		select
			variable into :_org_vars separated by ' '
		from
			&_RSU_TMP_VAR_LIST.
		where
			variable not in (&_exclude_vars.)
		;
	quit;
	%&RSUDS.Delete(&_RSU_TMP_VAR_LIST.)

	data &iods_dataset.;
		format
			&i_leading_vars.
			&_org_vars.
			&i_following_vars.
		;
		set &iods_dataset.;
	run;
	quit;
%mend RSUDS__ArrangeVarOrder;

/*<FunctionDesc ja_jp>データセットを書き込み禁止にします</FunctionDesc ja_jp>*/
%macro RSUDS__Protect(
/*<FunctionArgDesc ja_jp>書き込み禁止にするデータセット</FunctionArgDesc ja_jp>*/
							ids_dataset
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%&RSUDS.VerifyExists(ids_dataset = &ids_dataset.)
	%local /readonly _DSID = %sysfunc(open(&ids_dataset., I));
	%&RSUMap.Add(RSU_g_map_write_protected
					, i_key = %upcase(&ids_dataset.)
					, i_value = &_DSID.)
%mend RSUDS__Protect;

/*<FunctionDesc ja_jp>データセットの書き込み禁止を解除します</FunctionDesc ja_jp>*/
%macro RSUDS__Unprotect(
/*<FunctionArgDesc ja_jp>書き込み禁止になっているデータセットのID</FunctionArgDesc ja_jp>*/
								ids_dataset
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset)
	%&RSUDS.VerifyExists(ids_dataset = &ids_dataset.)
	%local /readonly _DSID = %&RSUMap.Get(RSU_g_map_write_protected
													, i_key = %upcase(&ids_dataset.));
	%if (0 < &_DSID.) %then %do;
		%local /readonly _RC = %sysfunc(close(&_DSID.));
		%&RSUMap.Delete(RSU_g_map_write_protected
							, i_key = %upcase(&ids_dataset.))
	%end;
%mend RSUDS__Unprotect;

/*<FunctionDesc ja_jp>Hash/Iterator オブジェクトを生成します（データステップ内で使う補助マクロ）</FunctionDesc ja_jp>*/
%macro RSUDS__CreateHash(
/*<FunctionArgDesc ja_jp>Hash オブジェクト名</FunctionArgDesc ja_jp>*/
								i_hash_name =
/*<FunctionArgDesc ja_jp>対象データセット</FunctionArgDesc ja_jp>*/
								, ids_dataset =
/*<FunctionArgDesc ja_jp>Multidata オプション設定値（ids_dataset設定時のみ有効）</FunctionArgDesc ja_jp>*/
								, i_is_multidata = %&RSUBool.False
/*<FunctionArgDesc ja_jp>orderd オプション設定値（ids_dataset設定時のみ有効）</FunctionArgDesc ja_jp>*/
								, i_ordered_option =
/*<FunctionArgDesc ja_jp>キー変数</FunctionArgDesc ja_jp>*/
								, i_key_vars =
/*<FunctionArgDesc ja_jp>データ変数（ids_datasetを指定し、かつ i_data_vars = * と指定した場合全変数を設定）</FunctionArgDesc ja_jp>*/
								, i_data_vars =
/*<FunctionArgDesc ja_jp>データセットの先頭で一度だけHash 生成コードを呼び出す場合は True</FunctionArgDesc ja_jp>*/
								, i_is_create_at_top = %&RSUBool.False
/*<FunctionArgDesc ja_jp>Iterator オブジェクト名</FunctionArgDesc ja_jp>*/
								, i_iterator_name =
/*<FunctionArgDesc ja_jp>Iterator の方向</FunctionArgDesc ja_jp>*/
								, i_iterator_direction = %&RSUDirection.Forward
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_hash_name i_key_vars)
	%if (not %&RSUMacroVariable.IsBlank(ids_dataset)) %then %do;
		if (_N_ = 0) then do;
			set &ids_dataset.;
		end;
	%end;
	%if (&i_is_create_at_top.) %then %do;
		if (_N_ = 1) then do;
	%end;
	%if (not %&RSUMacroVariable.IsBlank(ids_dataset)) %then %do;
		%local _initilaizing_option;
		%let _initilaizing_option = dataset: "&ids_dataset.";
		%if (&i_is_multidata.) %then %do;
			%&RSUText.Append(iovar_base = _initilaizing_option
								, i_append_text = multidata: 'yes'
								, i_delimiter = %str(,))
		%end;
		%if (not %&RSUMacroVariable.IsBlank(i_ordered_option)) %then %do;
			%&RSUText.Append(iovar_base = _initilaizing_option
								, i_append_text = ordered: "&i_ordered_option."
								, i_delimiter = %str(,))
		%end;
		declare hash &i_hash_name.(&_initilaizing_option.);
	%end;
	%else %do;
		declare hash &i_hash_name.();
	%end;
	%local _key_var;
	%local _index_key_var;
	%do %while(%&RSUUtil.ForEach(i_items = &i_key_vars.
										, ovar_item = _key_var
										, iovar_index = _index_key_var));
		&i_hash_name..definekey("&_key_var.");
	%end;
	%if ("&i_data_vars." = "*") %then %do;
		&i_hash_name..definedata(all: 'yes');
	%end;
	%else %do;
		%local _data_var;
		%local _index_data_var;
		%do %while(%&RSUUtil.ForEach(i_items = &i_data_vars.
											, ovar_item = _data_var
											, iovar_index = _index_data_var));
			&i_hash_name..definedata("&_data_var.");
		%end;
	%end;
	&i_hash_name..definedone();
	%if (not %&RSUMacroVariable.IsBlank(i_iterator_name)) %then %do;
		declare hiter &i_iterator_name.("&i_hash_name.");
		%RSUDS__ResetIter(&i_iterator_name.
								, i_iterator_direction = &i_iterator_direction.)
	%end;
	%if (&i_is_create_at_top.) %then %do;
		end;
	%end;
%mend RSUDS__CreateHash;

/*<FunctionDesc ja_jp>Iterator オブジェクトをリセット（データステップ内で使う補助マクロ）</FunctionDesc ja_jp>*/
%macro RSUDS__ResetIter(
/*<FunctionArgDesc ja_jp>Iteratorオブジェクト名</FunctionArgDesc ja_jp>*/
								i_iterator_name
/*<FunctionArgDesc ja_jp>Iterator の方向</FunctionArgDesc ja_jp>*/
								, i_iterator_direction = %&RSUDirection.Forward
								);
	%if (&i_iterator_direction. = %&RSUDirection.Forward) %then %do;
		_rsu_iter_rc = &i_iterator_name..first();
		_rsu_iter_rc = &i_iterator_name..prev();
	%end;
	%else %do;
		_rsu_iter_rc = &i_iterator_name..last();
		_rsu_iter_rc = &i_iterator_name..next();
	%end;
%mend RSUDS__ResetIter;

/*<FunctionDesc ja_jp>Iterator オブジェクトを進行させます（データステップ内で使う補助マクロ）</FunctionDesc ja_jp>*/
%macro RSUDS__MoveIter(
/*<FunctionArgDesc ja_jp>Iteratorオブジェクト名</FunctionArgDesc ja_jp>*/
							i_iterator_name
/*<FunctionArgDesc ja_jp>Iterator の方向</FunctionArgDesc ja_jp>*/
							, i_iterator_direction = %&RSUDirection.Forward
							);
	%if (&i_iterator_direction. = %&RSUDirection.Forward) %then %do;
		&i_iterator_name..next() = 0
	%end;
	%else %do;
		&i_iterator_name..prev() = 0
	%end;
%mend RSUDS__MoveIter;

%macro RSUDS__SetAttribFromDS(ids_src_query =
										, iods_dest_dataset =);
	data &iods_dest_dataset.;
		if (_N_ = 0) then do;
			set &ids_src_query.;
		end;
		set &iods_dest_dataset.;
	run;
	quit;
%mend RSUDS__SetAttribFromDS;