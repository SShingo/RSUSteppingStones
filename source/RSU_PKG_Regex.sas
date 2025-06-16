/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Regex.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/5/1
/*
/************************************************************************************/
/*<PackageID>RSURegex</PackageID>*/
/*<CategoryID>Cate_MacroVariable</CategoryID>*/
/*<PackagePurpose ja_jp>正規表現</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Regular expression</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>正規表現機能に係るマクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions about regural expression</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>正規表現パッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSURegex, RSURegex__)
/*<ConstantDesc ja_jp>正規表現クラス定義ファイル名</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_CLASS_FILE_REGEX_ITE, RSU_PKG_Class_IteratorRegex)

/*<FunctionDesc ja_jp>正規表現に合致するかを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: 一致しない\quad \%\&RSUBool.True:一致する</FunctionReturn ja_jp>*/
%macro RSURegex__IsMatch(
/*<FunctionArgDesc ja_jp>正規表現ID</FunctionArgDesc ja_jp>*/
								i_regex_id =
/*<FunctionArgDesc ja_jp>入力文字列</FunctionArgDesc ja_jp>*/
								, i_text =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_regex_id)
	%local _output;
	%let _output = %sysfunc(prxmatch(&i_regex_id., &i_text.));
	%&RSUUtil.Choose(%eval(0 < &_output.), %&RSUBool.True, %&RSUBool.False)
%mend RSURegex__IsMatch;

/*<FunctionDesc ja_jp>正規表現に一致する文字列を返します */
/*<FunctionReturn ja_jp>一致箇所の文字列</FunctionReturn ja_jp>*/
%macro RSURegex__Pos(
/*<FunctionArgDesc ja_jp>正規表現ID</FunctionArgDesc ja_jp>*/
							i_regex_id =
/*<FunctionArgDesc ja_jp>入力文字列</FunctionArgDesc ja_jp>*/
							, i_text =
/*<FunctionArgDesc ja_jp>一致場所</FunctionArgDesc ja_jp>*/
							, i_pos =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_regex_id i_pos)
	%local _output;
	%local _is_match;
	%if (%&RSURegex.IsMatch(i_regex_id = &i_regex_id., i_text = &i_text.)) %then %do;
		%let _output = %sysfunc(prxposn(&i_regex_id., &i_pos., &i_text.));
	%end;
	&_output.
%mend RSURegex__Pos;

/*<FunctionDesc ja_jp>正規表現に一致する文字列を置換します */
/*<FunctionReturn ja_jp>置換済み文字列</FunctionReturn ja_jp>*/
%macro RSURegex__Replace(
/*<FunctionArgDesc ja_jp>正規表現ID</FunctionArgDesc ja_jp>*/
								i_regex_id =
/*<FunctionArgDesc ja_jp>入力文字列</FunctionArgDesc ja_jp>*/
								, i_text =
/*<FunctionArgDesc ja_jp>置換対象場所</FunctionArgDesc ja_jp>*/
								, i_pos =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_regex_id i_pos)
	%local _output;
	%let _output = %sysfunc(prxchange(&i_regex_id., &i_pos., &i_text.));
	&_output.
%mend RSURegex__Replace;

/*<FunctionDesc ja_jp>正規表現による繰り返し一致イテレータを生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>生成された正規表現インスタンス</FunctionReturn ja_jp>*/
%macro RSURegex__CreateCaptureIterator(
/*<FunctionArgDesc ja_jp>検索元文字列</FunctionArgDesc ja_jp>*/
													i_regex_expression =
/*<FunctionArgDesc ja_jp>正規表現</FunctionArgDesc ja_jp>*/
													, i_text =
													);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_regex_expression i_text)
	%local /readonly __TMP_REGEX_INSTANCE = %Int_RSUClass_Instantiate(i_template_name = &RSU_G_CLASS_FILE_REGEX_ITE.);
	%Int_&__TMP_REGEX_INSTANCE.Initialize(i_regex = &i_regex_expression.
													, i_text = &i_text.)
	&__TMP_REGEX_INSTANCE.
%mend RSURegex__CreateCaptureIterator;

/*<FunctionDesc ja_jp>（Datastep内コードFragment）正規表現に一致する部分文字列を繰り返し探索するループの始まりコード</FunctionDesc ja_jp>*/
%macro RSURegex__StartIterationPRXNext(
/*<FunctionArgDesc ja_jp>探索対象変数</FunctionArgDesc ja_jp>*/
													i_target_variable =
/*<FunctionArgDesc ja_jp>探索対象変数の長さ</FunctionArgDesc ja_jp>*/
													, i_len_target_variable =
/*<FunctionArgDesc ja_jp>正規表現</FunctionArgDesc ja_jp>*/
													, i_regex_expression =
/*<FunctionArgDesc ja_jp>最大探索回数</FunctionArgDesc ja_jp>*/
													, i_max_iteration =
													);
	attrib
		__tmp_decmp_definition length = $&i_len_target_variable.
	;
	__tmp_decmp_regex_formula_ref = prxparse("&i_regex_expression.");
	__tmp_decmp_definition = EncloseGrave(strip(&i_target_variable.));
	__tmp_decmp_org_length = lengthn(__tmp_decmp_definition);
	__tmp_decmp_start = 1;
	__tmp_decmp_stop = __tmp_decmp_org_length;
	__tmp_decmp_position = 0;
	__tmp_decmp_length = 0;
	__tmp_decmp_prev_start = 1;
	__tmp_decmp_finished = 0;
	__tmp_decmp_safty_index = 0;
	do while(__tmp_decmp_safty_index < &i_max_iteration.);
		call prxnext(__tmp_decmp_regex_formula_ref, __tmp_decmp_start, __tmp_decmp_stop, __tmp_decmp_definition, __tmp_decmp_position, __tmp_decmp_length);
		if (__tmp_decmp_position = 0) then do;
			__tmp_decmp_position = __tmp_decmp_org_length;
			__tmp_decmp_finished = 1;
		end;
%mend RSURegex__StartIterationPRXNext;

/*<FunctionDesc ja_jp>（Datastep内コードFragment）正規表現に一致する部分文字列を繰り返し探索するループの終了コード</FunctionDesc ja_jp>*/
%macro RSURegex__EndIterationPRXNext(
/*<FunctionArgDesc ja_jp>探索対象変数</FunctionArgDesc ja_jp>*/
												i_target_variable =
/*<FunctionArgDesc ja_jp>置換キー変数名</FunctionArgDesc ja_jp>*/
												, i_key_variable =
/*<FunctionArgDesc ja_jp>エラー用Hash</FunctionArgDesc ja_jp>*/
												, i_hash_unreplaced =
/*<FunctionArgDesc ja_jp>未置換キーリスト</FunctionArgDesc ja_jp>*/
												, ods_unreplaced_keys =
												);
		if (__tmp_decmp_finished = 1) then do;
			leave;
		end;
	end;	
	&i_target_variable. = compress(__tmp_decmp_expression_replaced, '`');
	__tmp_decmp_rc = &i_hash_unreplaced..output(dataset: "&ods_unreplaced_keys.");
	drop
		__tmp_decmp:
		&i_key_variable.
	;
%mend RSURegex__EndIterationPRXNext;

/*<FunctionDesc ja_jp>文字列置換</FunctionDesc ja_jp>*/
%macro RSURegex__ReplaceWord(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
									iods_dataset =
/*<FunctionArgDesc ja_jp>置換対象変数</FunctionArgDesc ja_jp>*/
									, i_variable =
/*<FunctionArgDesc ja_jp>置換文字列マスタ</FunctionArgDesc ja_jp>*/
									, ids_replacing_values =
/*<FunctionArgDesc ja_jp>置換文字列マスタキー変数</FunctionArgDesc ja_jp>*/
									, i_key_variable =
/*<FunctionArgDesc ja_jp>置換文字列マスタデータ変数</FunctionArgDesc ja_jp>*/
									, i_data_variable =
/*<FunctionArgDesc ja_jp>置換正規表現（第1グルーピングが置換対象）</FunctionArgDesc ja_jp>*/
									, i_regex =
/*<FunctionArgDesc ja_jp>ループ最大階数</FunctionArgDesc ja_jp>*/
									, i_max_iteration = 100
/*<FunctionArgDesc ja_jp>未置換キーを保持するデータセット</FunctionArgDesc ja_jp>*/
									, ods_unreplaced_keys =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_dataset i_variable ids_replacing_values i_key_variable i_data_variable i_regex i_max_iteration)
	%&RSUDS.VerifyExists(&iods_dataset.)
	%&RSUDS.VerifyExists(&ids_replacing_values.)
	data &iods_dataset.;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__tmp_decmp_definition))
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__tmp_decmp_expression_replaced))
		set &iods_dataset. end = eof;
		%&RSUDS.CreateHash(i_hash_name = h_hash_master
								, ids_dataset = &ids_replacing_values.
								, i_key_vars = &i_key_variable.
								, i_data_vars = &i_data_variable.
								, i_is_create_at_top = %&RSUBool.True)
		%&RSUDS.CreateHash(i_hash_name = h_hash_unreplaced
								, i_key_vars = &i_key_variable.
								, i_data_vars = &i_key_variable.
								, i_is_create_at_top = %&RSUBool.True)
		__tmp_decmp_regex_formula_ref = prxparse("&i_regex.");
		__tmp_decmp_definition = EncloseGrave(strip(&i_variable.));
		__tmp_decmp_org_length = lengthn(__tmp_decmp_definition);
		__tmp_decmp_start = 1;
		__tmp_decmp_stop = __tmp_decmp_org_length;
		__tmp_decmp_position = 0;
		__tmp_decmp_length = 0;
		__tmp_decmp_prev_start = 1;
		__tmp_decmp_finished = 0;
		__tmp_decmp_safty_index = 0;
		do while(__tmp_decmp_safty_index < &i_max_iteration.);
			call prxnext(__tmp_decmp_regex_formula_ref, __tmp_decmp_start, __tmp_decmp_stop, __tmp_decmp_definition, __tmp_decmp_position, __tmp_decmp_length);
			if (__tmp_decmp_position = 0) then do;
				__tmp_decmp_position = __tmp_decmp_org_length;
				__tmp_decmp_finished = %&RSUBool.True;
			end;
			/* !空白ももれなく取り込むために EncloseGraveは使わない */
			__tmp_decmp_expression_replaced = catt(__tmp_decmp_expression_replaced, cat('`', substr(__tmp_decmp_definition, __tmp_decmp_prev_start, __tmp_decmp_position - __tmp_decmp_prev_start), '`'));
			if (__tmp_decmp_finished = %&RSUBool.True) then do;
				leave;
			end;
			else do;
				&i_key_variable. = prxposn(__tmp_decmp_regex_formula_ref, 1, __tmp_decmp_definition);
				if (h_hash_master.find() = 0) then do;
					__tmp_decmp_expression_replaced = catt(__tmp_decmp_expression_replaced, &i_data_variable.);			
				end;
				else do;
					__tmp_decmp_expression_replaced = catt(__tmp_decmp_expression_replaced, &i_key_variable.);			
					__tmp_decmp_rc = h_hash_unreplaced.add();
				end;
				__tmp_decmp_prev_start = __tmp_decmp_position + __tmp_decmp_length;
				__tmp_decmp_safty_index = __tmp_decmp_safty_index + 1;
			end;
		end;	
		&i_variable. = compress(__tmp_decmp_expression_replaced, '`');
	%if (not %&RSUMacroVariable.IsBlank(ods_unreplaced_keys)) %then %do;
			if (eof) then do;
				__tmp_decmp_rc = h_hash_unreplaced.output(dataset: "&ods_unreplaced_keys.");
			end;
	%end;
		drop
			__tmp_decmp:
			&i_key_variable.
			&i_data_variable.
		;
	run;
	quit;
%mend RSURegex__ReplaceWord;

/*<FunctionDesc ja_jp>（Datastep内コードFragment）正規表現に一致する部分文字列を置換します</FunctionDesc ja_jp>*/
%macro RSURegex__ReplaceAllInVar(
/*<FunctionArgDesc ja_jp>探索対象変数名</FunctionArgDesc ja_jp>*/
											i_target_variable =
/*<FunctionArgDesc ja_jp>探索対象変数の長さ</FunctionArgDesc ja_jp>*/
											, i_len_target_variable =
/*<FunctionArgDesc ja_jp>置換キー変数名</FunctionArgDesc ja_jp>*/
											, i_key_variable =
/*<FunctionArgDesc ja_jp>正規表現</FunctionArgDesc ja_jp>*/
											, i_regex_expression =
/*<FunctionArgDesc ja_jp>キー値の正規表現position</FunctionArgDesc ja_jp>*/
											, i_key_pos =
/*<FunctionArgDesc ja_jp>置換文字列Hash</FunctionArgDesc ja_jp>*/
											, i_hash_master =
/*<FunctionArgDesc ja_jp>置換文字列変数名</FunctionArgDesc ja_jp>*/
											, i_data_variable =
/*<FunctionArgDesc ja_jp>最大探索回数</FunctionArgDesc ja_jp>*/
											, i_max_iteration =
/*<FunctionArgDesc ja_jp>エラー用Hash</FunctionArgDesc ja_jp>*/
											, i_hash_unreplaced =
/*<FunctionArgDesc ja_jp>未置換キーリスト</FunctionArgDesc ja_jp>*/
											, ods_unreplaced_keys =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_target_variable
													i_key_variable
													i_len_target_variable
													i_regex_expression
													i_key_pos
													i_hash_master
													i_data_variable
													i_max_iteration
													i_hash_unreplaced
													ods_unreplaced_keys)
	attrib
		__tmp_decmp_expression_replaced length = $&i_len_target_variable.
	;
	call missing(__tmp_decmp_expression_replaced);
	%RSURegex__StartIterationPRXNext(i_target_variable = &i_target_variable.
												, i_len_target_variable = &i_len_target_variable.
												, i_regex_expression = &i_regex_expression.
												, i_max_iteration = &i_max_iteration.)
		__tmp_decmp_expression_replaced = catt(__tmp_decmp_expression_replaced, EncloseGrave(substr(__tmp_decmp_definition, __tmp_decmp_prev_start, __tmp_decmp_position - __tmp_decmp_prev_start + 1)));
		if (__tmp_decmp_finished = 0) then do;
			&i_key_variable. = prxposn(__tmp_decmp_regex_formula_ref, &i_key_pos., __tmp_decmp_definition);
			__tmp_decmp_rc = &i_hash_master..find();
			if (__tmp_decmp_rc = 0) then do;
				__tmp_decmp_expression_replaced = catt(__tmp_decmp_expression_replaced, &i_data_variable.);			
			end;
			else do;
				__tmp_decmp_expression_replaced = catt(__tmp_decmp_expression_replaced, &i_key_variable.);			
				__tmp_decmp_rc = &i_hash_unreplaced..add();
			end;
			__tmp_decmp_prev_start = __tmp_decmp_position + __tmp_decmp_length;
			__tmp_decmp_safty_index = __tmp_decmp_safty_index + 1;
		end;
	%RSURegex__EndIterationPRXNext(i_target_variable = &i_target_variable.
											, i_hash_unreplaced = &i_hash_unreplaced.
											, ods_unreplaced_keys = &ods_unreplaced_keys.
											, i_key_variable = &i_key_variable)
%mend RSURegex__ReplaceAllInVar;

/*<FunctionDesc ja_jp>変数を正規表現に従って分解します</FunctionDesc ja_jp>*/
%macro RSURegex__DecomposeVar(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
										iods_dataset =
/*<FunctionArgDesc ja_jp>分解対象変数</FunctionArgDesc ja_jp>*/
										, i_variable =
/*<FunctionArgDesc ja_jp>正規表現</FunctionArgDesc ja_jp>*/
										, i_regex =
/*<FunctionArgDesc ja_jp>分解結果（正規表現に一致した要素）</FunctionArgDesc ja_jp>*/
										, i_variable_matched =
/*<FunctionArgDesc ja_jp>分解結果（正規表現に一致しない要素）</FunctionArgDesc ja_jp>*/
										, i_variable_unmatched =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_dataset i_variable i_regex i_variable_unmatched i_variable_matched)
	data &iods_dataset.(where = (not missing(&i_variable_matched.) or not missing(&i_variable_unmatched.)));
		set &iods_dataset.;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__tmp_decmp_definition))
		attrib
			&i_variable_matched. length = $100.
			&i_variable_unmatched. length = $5000.
		;
		__tmp_decmp_regex_formula_ref = prxparse("&i_regex.");
		__tmp_decmp_definition = EncloseGrave(strip(&i_variable.));
		__tmp_decmp_org_length = lengthn(__tmp_decmp_definition);
		__tmp_decmp_start = 1;
		__tmp_decmp_stop = __tmp_decmp_org_length;
		__tmp_decmp_position = 0;
		__tmp_decmp_length = 0;
		__tmp_decmp_prev_start = 1;
		__tmp_decmp_finished = 0;
		__tmp_decmp_safty_index = 0;
		do while(1);
			call prxnext(__tmp_decmp_regex_formula_ref, __tmp_decmp_start, __tmp_decmp_stop, __tmp_decmp_definition, __tmp_decmp_position, __tmp_decmp_length);
			if (__tmp_decmp_position = 0) then do;
				__tmp_decmp_position = __tmp_decmp_org_length + 1;
				__tmp_decmp_finished = 1;
			end;			
			call missing(&i_variable_matched.);
			&i_variable_unmatched. = substr(__tmp_decmp_definition, __tmp_decmp_prev_start, __tmp_decmp_position - __tmp_decmp_prev_start);
			output;
			if (__tmp_decmp_finished = 0) then do;
				call missing(&i_variable_unmatched.);
				&i_variable_matched. = prxposn(__tmp_decmp_regex_formula_ref, 1, __tmp_decmp_definition);
				output;
				__tmp_decmp_prev_start = __tmp_decmp_position + __tmp_decmp_length;
				__tmp_decmp_safty_index = __tmp_decmp_safty_index + 1;
			end;
			if (__tmp_decmp_finished = 1) then do;
				leave;
			end;
		end;
		drop
			__tmp_decmp:
		;
	run;
	quit;
%mend RSURegex__DecomposeVar;

%macro RSURegex__CreateParenIterator(i_text =
												, i_regex =);
	%local /readonly _REGEXPAREN_ID = %Prv_RSUClass_CreateInstance(i_prefix = RX
																				, i_sequence_var = RSU_g_sequence_regex);
	%global &_REGEXPAREN_ID._text;
	%let &_REGEXPAREN_ID._text = &i_text.;
	%global &_REGEXPAREN_ID._regex;
	%let &_REGEXPAREN_ID._regex = %sysfunc(prxparse(&i_regex.));
	%global &_REGEXPAREN_ID._matched;
	%let &_REGEXPAREN_ID._matched = %sysfunc(prxmatch(&&&_REGEXPAREN_ID._regex., &i_text.));
	%global &_REGEXPAREN_ID._max_paren;
	%let &_REGEXPAREN_ID._max_paren = %sysfunc(prxparen(&&&_REGEXPAREN_ID._regex.));
	%global &_REGEXPAREN_ID._paren_index;
	%let &_REGEXPAREN_ID._paren_index = 0;
	&_REGEXPAREN_ID.
%mend RSURegex__CreateParenIterator;

%macro RSURegex__NextParen(ivar_regexparen);
	%local /readonly _REGEXPAREN_NEXT_ID = &&&ivar_regexparen.;
	%if (not &&&_REGEXPAREN_NEXT_ID._matched.) %then %do;
		%&RSUBool.False
		%return;
	%end;
	%if (&&&_REGEXPAREN_NEXT_ID._paren_index. = &&&_REGEXPAREN_NEXT_ID._max_paren.) %then %do;
		%let &_REGEXPAREN_NEXT_ID._value =;
		%&RSUBool.False
		%return;
	%end;
	%let &_REGEXPAREN_NEXT_ID._paren_index = %eval(&&&_REGEXPAREN_NEXT_ID._paren_index. + 1);
	%&RSUBool.True
%mend RSURegex__NextParen;

%macro RSURegex__MatchedValue(ivar_regexparen);
	%local /readonly _REGEXPAREN_MATCHEDVALUE_ID = &&&ivar_regexparen.;
	%sysfunc(prxposn(&&&_REGEXPAREN_MATCHEDVALUE_ID._regex., &&&_REGEXPAREN_MATCHEDVALUE_ID._paren_index., &&&_REGEXPAREN_MATCHEDVALUE_ID._text.))
%mend RSURegex__MatchedValue;

%macro RSURegex__Dispose(ivar_regex);
	%local /readonly _REGEX_DISPOSE_ID = &&&ivar_regex.;
	%syscall prxfree(&_REGEX_DISPOSE_ID._regex);
	%&RSUMacroVariable.Delete(i_regex = /^&_REGEX_DISPOSE_ID._/i)
%mend RSURegex__Dispose;