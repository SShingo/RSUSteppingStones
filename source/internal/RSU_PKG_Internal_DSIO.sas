%macro Prv_RSUDSIO_LoadTableDefFile(i_schema_file_ref =
												, ods_definition_ds =
												, ods_frame_ds =
												, ods_constraint_ds =);
	/*
		! スキーマファイルはフォーマット固定
		NOTE: スキーマファイルから
		NOTE: 枠データセット
		NOTE: 制約データセット
		NOTE: を作成
	*/
	/* Read table def */
	data &ods_definition_ds.;
		attrib
			var_name length = $32.
			var_type length = $1.
			var_length length = $4.
			var_format length = $49.
			var_informat length = $49.
			var_label length = $255.
			src_var_name length = $32.
			is_primary_key length = $1.
			is_nullable length = $1.
			is_unique length = $1.
		;
		infile &i_schema_file_ref. delimiter = &RSUTab. dsd missover firstobs = 2 end = eof;
		input 
			var_name
			var_type
			var_length
			var_format
			var_informat
			var_label
			is_primary_key
			is_nullable
			is_unique
		;
	run;
	quit;
	/* 枠定義データセット作成 */
	%Prv_RSUDSIO_ConfigureFrameDS(ids_table_def_ds = &ods_definition_ds.
											, ods_frame_ds = &ods_frame_ds.)
	/* 制約条件データセット作成 */
	%Prv_RSUDSIO_ConfigureConstDS(ids_table_def_ds = &ods_definition_ds.
											, ods_constraint_ds = &ods_constraint_ds.)
%mend Prv_RSUDSIO_LoadTableDefFile;

%macro Prv_RSUDSIO_ConfigureFrameDS(ids_table_def_ds =
												, ods_frame_ds =);
	%local _tmp_fref_out;
	%let _tmp_fref_out = %&RSUFile.GetFileRef;
	data _null_;
		attrib
			_attrib_var length = $32.
			_attrib_length length = $20.
			_attrib_format length = $60.
			_attrib_informat length = $60.
			_attrib_label length = $200.
			_attrib_line length = $1000.
		;
		set &ids_table_def_ds.;
		file &_tmp_fref_out;
		_index = _N_;
		/* name */
		if (var_name ne "&RSUSkipCol.") then do;
			_attrib_var = var_name;
			if (upcase(var_type) = 'C') then do;
				/* 文字型 */
				_attrib_length = '';
				if (not missing(var_length)) then do;
					_attrib_length = cats('length = $', var_length);
				end;
				_attrib_format = '';
				_attrib_informat = '';
			end;
			else do;
				/* 数値型（数値/日付) */
				_attrib_length = 'length = 8.';
				if (not missing(var_length)) then do;
					_attrib_length = cats('length = ', var_length);
				end;
				_attrib_format = '';
				if (not missing(var_format)) then do;
					_attrib_format = cats('format = ', var_format);
				end;
				_attrib_informat = '';
				if (not missing(var_informat)) then do;
					_attrib_informat = cats('informat = ', var_informat);
				end;
			end;
			_attrib_label = '';
			if (not missing(var_label)) then do;
				_attrib_label = cats('label = "', var_label, '"');
			end;
		end;
		else do;
			_attrib_var = catx('_', "&RSUSkippedVar.", _index);
			_attrib_length = 'length = $1000.';
			_attrib_format = '';
			_attrib_informat = '';
			_attrib_label = '';
		end;
		/* Attribute */
		_attrib_line = catx(' ', _attrib_var, _attrib_length, _attrib_format, _attrib_informat, _attrib_label);
		put _attrib_line;
	run;
	quit;

	/* Frame DS */
	data &ods_frame_ds.(label = 'Frame');
		attrib
		%include &_tmp_fref_out.;
		;
		call missing(of _all_);
		stop;
	run;
	quit;
	%&RSUFile.ClearFileRef(_tmp_fref_out)
%mend Prv_RSUDSIO_ConfigureFrameDS;

%macro Prv_RSUDSIO_LoadTextIntoDS(i_file_ref =
											, ids_frame_ds =
											, i_firstobs =
											, i_delimiter =
											, ods_output_ds =);
	/* Template */
	%local /readonly _TMP_DS_COLUMNS = %&RSUDS.GetTempDSName();
	%&RSUDS.GetDSVariables(&ids_frame_ds.
								, ods_variables = &_TMP_DS_COLUMNS.)
	%local _ar_frame_colmns;
	%&RSUArray.CreateByDataset(&_TMP_DS_COLUMNS.
										, i_variable
										, _ar_frame_colmns);
	/* Import text file into output dataset */
	%local _variable;
	data &ods_output_ds.;
		if (_N_ = 0) then do;
			set &ids_frame_ds.;
		end;
		infile &i_file_ref. dlm = &i_delimiter. firstobs = &i_firstobs. dsd missover;
		input
	%do %while(%&RSUArray.ForEach(_AR_FRAME_COLMNS, _variable));
			&_variable.
	%end;
		;
	run;
	quit;
	%&RSUArray.Dispose(_AR_FRAME_COLMNS)
	%&RSUDS.Delete(&_TMP_DS_COLUMNS.)

	/* ダミー削除 */
	%local /readonly _TMP_DS_COLUMNS_DUMMY = %&RSUDS.GetTempDSName();
	%&RSUDS.GetDSVariables(&ids_frame_ds.
								, ods_variables = &_TMP_DS_COLUMNS_DUMMY.
								, i_regex_include = /^&RSUSkippedVar./i);
	%if (not %&RSUDS.IsDSEmpty(&_TMP_DS_COLUMNS_DUMMY.)) %then %do;
		%local /readonly _AR_FRAME_COLMNS_DUMMY = %&RSUDS.CreateByDataset(&_TMP_DS_COLUMNS_DUMMY.
																								, i_variable = variable);
		data &ods_output_ds.;
			set &ods_output_ds.;
			drop
		%do %while(%&RSUArray.ForEach(_AR_FRAME_COLMNS_DUMMY, _variable));
				&_variable.
		%end;
			;
		run;
		quit;
		%&RSUArray.Dispose(_AR_FRAME_COLMNS_DUMMY)
	%end;
	%&RSUDS.Delete(&_TMP_DS_COLUMNS_DUMMY.)
%mend Prv_RSUDSIO_LoadTextIntoDS;

%macro Prv_RSUDSIO_CreateDummyFrame(ids_frame_ds =
												, ods_dummy_frame_ds =);
	%local _tmp_fref_out;
	%let _tmp_fref_out = %&RSUFile.GetFileRef;
	data _null_;
		attrib
			_attrib_line length = $100.
		;
		_regex_dummy_var = prxparse("/^&RSUSkippedVar./");
		_dsid = open("&ids_frame_ds.", 'I');
		_no_of_vars = attrn(_dsid, "nvars");
		file &_tmp_fref_out.;
		do _var_index = 1 to _no_of_vars;
			if (prxmatch(_regex_dummy_var, varname(_dsid, _var_index))) then do;
				_attrib_line = cat("&RSUSkippedVar._", strip(put(_var_index, best.)), ' length = $1000.');
			end;
			else do;
				_attrib_line = cat('_raw_var_', strip(put(_var_index, best.)), ' length = $1000.');
			end;
			put _attrib_line;
		end;
		_rc = close(_dsid);
		call prxfree(_regex_dummy_var);
	run;
	quit;

	data &ods_dummy_frame_ds.(label= 'Dummy frame');
		attrib
		%include &_tmp_fref_out.;
		;
		call missing(of _all_);
		stop;
	run;
	quit;
	%&RSUFile.ClearFileRef(_tmp_fref_out)
%mend Prv_RSUDSIO_CreateDummyFrame;

%macro Prv_RSUDSIO_LoadTextHelper(i_file_ref =
											, iods_frame_ds =
											, i_delimiter =
											, i_firstobs =
											, ods_output_ds =);
	/* 枠にデータを流し込む */
	%Prv_RSUDSIO_LoadTextIntoDS(i_file_ref = &i_file_ref.
										, ids_frame_ds = &iods_frame_ds.
										, i_delimiter = &i_delimiter.
										, i_firstobs = &i_firstobs.
										, ods_output_ds = &ods_output_ds.)
	/* 検証用ダミー：全部テキストで読み込む */
	%local /readonly _TMP_DUMMY_FRAME_DS = %&RSUDS.GetTempDSName();
	%Prv_RSUDSIO_CreateDummyFrame(ids_frame_ds = &iods_frame_ds.
											, ods_dummy_frame_ds = &_TMP_DUMMY_FRAME_DS.)
	%local /readonly _TMP_RAW_DS = %&RSUDS.GetTempDSName();
	%Prv_RSUDSIO_LoadTextIntoDS(i_file_ref = &i_file_ref.
										, ids_frame_ds = &_TMP_DUMMY_FRAME_DS.
										, i_delimiter = &i_delimiter.
										, i_firstobs = &i_firstobs.
										, ods_output_ds = &_TMP_RAW_DS.)
	%&RSUDS.Delete(&_TMP_DUMMY_FRAME_DS.)

	/* 型変換チェック */
	%Prv_RSUDSIO_FindConversionError(ids_output_ds = &ods_output_ds.
												, ids_raw_ds = &_TMP_RAW_DS.)
	%&RSUDS.Delete(&_TMP_RAW_DS.)
%mend Prv_RSUDSIO_LoadTextHelper;

%macro Prv_RSUDSIO_FindConversionError(ids_output_ds =
													, ids_raw_ds =);
	/* 型変換チェック */
	%local _err_vars;
	%local _tmp_fref_chk_err;
	%let _tmp_fref_chk_err = %&RSUFile.GetFileRef;
	data _null_;
		attrib
			_var_name_out length = $32.
			_var_name_raw length = $32.
			_var_name_err length = $32.
			_err_vars length = $30000.
			_error_message length = $5000.
		;
		file &_tmp_fref_chk_err;
		_dsid_out = open("&ids_output_ds.", 'I');
		_dsid_raw = open("&ids_raw_ds.", 'I');
		_err_vars = '';
		_no_of_vars = attrn(_dsid_out, 'nvars');
		put '_err = 0;';
		do _variable_index = 1 to _no_of_vars;
			_var_name_out = varname(_dsid_out, _variable_index);
			_var_name_raw = varname(_dsid_raw, _variable_index);
			_var_name_err = cats(_var_name_out, '_err');
			if (vartype(_dsid_out, _variable_index) = 'C') then do;
				/* 文字型：長さが一致しているか */
				_err_criteria = cats('lengthn(', _var_name_out, ') < lengthn(', _var_name_raw, ')');
				_err_message = cats('sasmsg("L_RSUMDL.&RSU_G_MESSAGE_DS.", "MSG_CONV_ERR_CHAR", "noquote", ', _var_name_raw, ',', _var_name_out, ');');
			end;
			else do;
				/* 数値型：数値として変換されているか */
				_err_criteria = cats('missing(', _var_name_out, ') and not missing(', _var_name_raw, ')');
				_err_message = cats('sasmsg("L_RSUMDL.&RSU_G_MESSAGE_DS.", "MSG_CONV_ERR_NUM", "noquote", ', _var_name_raw, ');');
			end;
			_err_message = cats(_var_name_err, '=', _err_message);
			put 'if (' _err_criteria ') then do;';
			put _err_message;
			put '_err = _err + 1;';
			put 'end;';
			_err_vars = catx(' ', _err_vars, _var_name_err);
		end;
		call symputx('_err_vars', _err_vars);
		_rc = close(_dsid_raw);
		_rc = close(_dsid_out);
	run;
	quit;

	/* エラーレコードをリストアップ */
	%local /readonly _TMP_ERROR_DS = %&RSUDS.GetTempDSName();
	data &_TMP_ERROR_DS.(label = 'Error records');
		merge
			&ids_output_ds.
			&ids_raw_ds
		;
		%include &_tmp_fref_chk_err.;
		if (0 < _err) then do;
			output;
		end;
		keep
		&_err_vars.
		;
	run;
	quit;
	%&RSUFile.ClearFileRef(_tmp_fref_chk_err)

	%local _err_count;
	%let _err_count = %&RSUDS.GetCount(&_TMP_ERROR_DS.);
	%if (0 < &_err_count.) %then %do;
		%&RSULogger.PutError(%&RSUMsg.CONV_ERR(&_err_count., &_TMP_ERROR_DS.)
									, i_abort = cancel)
	%end;
	%else %do;
		%&RSUDS.Delete(&_TMP_ERROR_DS.)
	%end;
%mend Prv_RSUDSIO_FindConversionError;

%macro Prv_RSUDSIO_ApplyConstraint(iods_dataset = 
											, ids_constraint_ds =);
	%local /readonly _TMP_DS_CONSTRAINTED = %&RSUDS.GetTempDSName();
	data &_TMP_DS_CONSTRAINTED.(alter = sasrsu);
		set &iods_dataset.;
		stop;
	run;
	quit;

	%local /readonly _TMP_TABLE_KEY = %&RSUUtil.GetSequenceId(i_prefix = T
																				, iovar_sequence = RSU_g_sequence_dataset
																				, i_digit = 4);
	%local /readonly _TMP_DS_CONSTRAINT = %&RSUDS.GetTempDSName();
	data &_TMP_DS_CONSTRAINT.;
		set &ids_constraint_ds.;
		_var_constraint = tranwrd(_var_constraint, '<table>', trim("&_TMP_TABLE_KEY."));
	run;
	quit;

	%local _constraint_code;
	%local _array_ds_constraint;
	%&RSUArray.CreateByDataset(&_TMP_DS_CONSTRAINT.
										, _var_constraint
										, _array_ds_constraint)
	proc datasets lib = WORK nolist;
		modify %&RSUDS.GetDSname(&_TMP_DS_CONSTRAINTED.)(alter = sasrsu);
	%do %while(%&RSUArray.ForEach(_ARRAY_DS_CONSTRAINT, _constraint_code));
		&_constraint_code.
	%end;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DS_CONSTRAINT.)
	%&RSUArray.Dispose(_ARRAY_DS_CONSTRAINT)

	proc datasets library = WORK nolist;
		audit %&RSUDS.GetDSname(&_TMP_DS_CONSTRAINTED.)(alter = sasrsu);
		initiate;
	quit;
	%&RSUDSJoin.Append(iods_base_ds = &_TMP_DS_CONSTRAINTED.
						, ids_data_ds = &iods_dataset.)
	data &iods_dataset._ad(drop = _atdatetime_ _atobsno_ _atuserid_);
		set &_TMP_DS_CONSTRAINTED.(type = audit);
		where
			_atopcode_ = 'EA'
		;
	run;
	quit;

	proc datasets library = WORK nolist;
		audit %&RSUDS.GetDSname(&_TMP_DS_CONSTRAINTED.)(alter = sasrsu);
		terminate;
	quit;
	proc delete
		data = &&_TMP_DS_CONSTRAINTED.(alter = sasrsu)
		;
	run;
	%if (not %&RSUDS.IsDSEmpty(&iods_dataset._ad)) %then %do;
	proc print data = &iods_dataset._ad;
	run;
		%&RSULogger.PutError(Constraint violation. See &iods_dataset._ad.
								, i_abort = cancel)
	%end;
	%else %do;
		%&RSUDS.Delete(&iods_dataset._ad)
	%end;
%mend Prv_RSUDSIO_ApplyConstraint;

%macro Prv_RSUDSIO_ConfigureConstDS(ids_table_def_ds =
												, ods_constraint_ds =);
	data &ods_constraint_ds.(label = 'Constraint');
		set &ids_table_def_ds.;
		_index_ = put(_N_, Z4.);
		if (not missing(is_primary_key)) then do;
			_var_constraint = cat('ic create pk_<table>_', _index_, ' = primary key(', trim(var_name), ');');
		end;
		else do;
			if (missing(is_nullable)) then do;
				_var_constraint = cat('ic create nn_<table>_', _index_, ' = not null(', trim(var_name), ');');
			end;
			if (not missing(is_unique)) then do;
				_var_constraint = cat(_var_constraint, ' ', 'ic create nn_<table>_', _index_, ' = unique(', trim(var_name), ');');
			end;
		end;
		if (not missing(_var_constraint)) then do;
			output;
		end;
		keep
			_var_constraint
		;
	run;
	quit;
%mend Prv_RSUDSIO_ConfigureConstDS;

%macro Prv_RSUDSIO_LoadExcel(
									i_file_path =
									, i_sheet_name =
									, i_range =
									, i_schema_file_ref =
									, i_query =
									, i_contain_header =
									, i_dummy_row =
									, ods_output_ds =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_sheet_name ods_output_ds i_schema_file_ref)
	/*
		NOTE: 基本方針
		NOTE: テーブル定義とデータをテキストとして書き出す
		NOTE: スキーマ情報からデータセットの枠を作成（SAS日付とExcel日付の違いを吸収）
		NOTE: テキストを流し込む
	*/

	/* 枠と制約条件を読み込み */
	/* スキーマ */
	%local /readonly _TMP_DEF_TABLE_DS = %RSUDS__GetTempDSName();
	%local /readonly _TMP_FRAME_DS = %RSUDS__GetTempDSName();
	%local /readonly _TMP_CONSTRAINT_DS = %RSUDS__GetTempDSName();
	%Prv_RSUDSIO_LoadTableDefFile(i_schema_file_ref = &i_schema_file_ref.
											, ods_definition_ds = &_TMP_DEF_TABLE_DS.
											, ods_frame_ds = &_TMP_FRAME_DS.
											, ods_constraint_ds = &_TMP_CONSTRAINT_DS.)
	/* テキスト書き出し */
	%local _tmp_fref_excel_in;
	%let _tmp_fref_excel_in = %&RSUFile.GetFileRef;
	%&RSUExcel.ExportToText(i_file_path =	&i_file_path.
									, i_sheet_name = &i_sheet_name.
									, i_range =	&i_range.
									, i_dummy_row = &i_dummy_row.
									, i_output_fileref =	&_tmp_fref_excel_in.)
	/* 読み込み */
	%local _firstobs;
	%let _firstobs = %eval(1 + &i_contain_header.);
	%local /readonly _TMP_OUTPUT_DS = %RSUDS__GetTempDSName();
	%Prv_RSUDSIO_LoadTextHelper(i_file_ref = &_tmp_fref_excel_in.
										, iods_frame_ds = &_TMP_FRAME_DS.
										, i_delimiter = &RSUTab.
										, i_firstobs = &_firstobs.
										, ods_output_ds = &_TMP_OUTPUT_DS.)
	%&RSUFile.ClearFileRef(_tmp_fref_excel_in)
	%&RSUDS.Delete(&_TMP_FRAME_DS.)

	/* 制約条件を適用 */
	%if (not %&RSUDS.IsDSEmpty(&_TMP_CONSTRAINT_DS.)) %then %do;
		%Prv_RSUDSIO_ApplyConstraint(iods_dataset = &_tmp_output_ds.
											, ids_constraint_ds = &_TMP_CONSTRAINT_DS.)
	%end;
	%&RSUDS.Delete(&_TMP_CONSTRAINT_DS.)

	/*
		出力
		枠の日付インフォーマットを修正
		-	Excelからエクスポートされたテキストファイル内では、日付形式のデータは整数になっている
		-	ExcelとSASとでは日付の起点が違う
	*/
	%local _date_conv_code;
	data _null_;
		attrib
			_date_conv_code length = $1000.
		;
		set &_TMP_DEF_TABLE_DS. end = eof;
		retain _date_conv_code;
		/* name */
		if (not prxmatch("/^&RSUSkipCol./", var_name)) then do;
			if (upcase(var_type) = 'D') then do;
				_date_conv_code = cats(_date_conv_code, var_name, '=', var_name, '- &RSUExcelDateOffset.;');	/* SAS日付 = Excel日付 - &RSUExcelDateOffset. */
			end;
		end;
		if (eof) then do;
			call symputx('_date_conv_code', _date_conv_code);
		end;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_DEF_TABLE_DS.)

	data &ods_output_ds.;
		set &_TMP_OUTPUT_DS.;
		&_date_conv_code.
	run;
	quit;

	%if (not %&RSUMacroVariable.IsBlank(i_query)) %then %do;
		data &ods_output_ds.;
			set &ods_output_ds.(where = (&i_query.));
		run;
		quit;
	%end;
	%&RSUDS.Delete(&_TMP_OUTPUT_DS.)
%mend Prv_RSUDSIO_LoadExcel;