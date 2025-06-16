/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Text.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/9/4
/*
/************************************************************************************/
/*<PackageID>RSUText</PackageID>*/
/*<CategoryID>Cate_MacroVariable</CategoryID>*/
/*<PackagePurpose ja_jp>文字列操作</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Manipulate text strings</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>文字列関連の関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating text string</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>テキストパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Text Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSUText, RSUText__)

/*<FunctionDesc ja_jp>文字列を連結します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Append text strings</FunctionDesc en_us>*/
%macro RSUText__Append(
/*<FunctionArgDesc ja_jp>基となるテキストを保持するマクロ変数名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Macro variable name that contains target text</FunctionArgDesc en_us>*/
							iovar_base =
/*<FunctionArgDesc ja_jp>接続する値</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Value to be appended</FunctionArgDesc en_us>*/
							, i_append_text =
/*<FunctionArgDesc ja_jp>区切り文字</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Delimiter</FunctionArgDesc en_us>*/
							, i_delimiter = %str( ));
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_base)
	%if (%&RSUMacroVariable.IsBlank(&iovar_base.)) %then %do;
		%let &iovar_base. = &i_append_text.;
	%end;
	%else %do;
		%if (not %&RSUMacroVariable.IsBlank(i_append_text)) %then %do;
			%local _appended_text_var;
			%let _appended_text_var = &&&iovar_base.;
			%let &iovar_base. = &_APPENDED_TEXT_VAR.&i_delimiter.&i_append_text.;
		%end;
	%end;
%mend RSUText__Append;

/*<FunctionDesc ja_jp>文字列が空か否かを判定します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Determine whether the text string is empty or not</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>0:マクロ変数は空ではない\quad 1:マクロ変数が空</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>0:Macro variable is not empty\quad 1:Macro variable is empty</FunctionReturn en_us>*/
%macro RSUText__IsBlank(
/*<FunctionArgDesc ja_jp>判定対象の文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target text string</FunctionArgDesc en_us>*/
								i_text
								);
	%sysevalf(%length(&i_text.) = 0, boolean)
%mend RSUText__IsBlank;

/*<FunctionDesc ja_jp>文字列の長さを返します（倍角文字も1文字と数えます）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the length of a text string (double-size character is counted as 1) </FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>文字数</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Text length</FunctionReturn en_us>*/
%macro RSUText__Length(
/*<FunctionArgDesc ja_jp>文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Text string</FunctionArgDesc en_us>*/
								i_text
								);
	%&RSUUtil.Choose(%&RSUText.IsBlank(i_text), 0, %sysfunc(klength(&i_text.)))
%mend RSUText__Length;

/*<FunctionDesc ja_jp>文字列の長さ（バイト数）を返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the length (byte count) of a text string</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>バイト数</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Byte count</FunctionReturn en_us>*/
%macro RSUText__Byte(
/*<FunctionArgDesc ja_jp>文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Text string</FunctionArgDesc en_us>*/
							i_text
							);
	%&RSUUtil.Choose(%&RSUText.IsBlank(i_text), 0, %sysfunc(length(&i_text.)))
%mend RSUText__Byte;

/*<FunctionDesc ja_jp>文字列の左側から指定文字数だけ切り出します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Extract designated number of characters from the left-end of a text string</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>切り出された文字列</FunctionReturn ja_jp>*/
/*<FunctionReturn ja_jp>Extracted text string</FunctionReturn ja_jp>*/
%macro RSUText__Left(
/*<FunctionArgDesc ja_jp>文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Text string</FunctionArgDesc en_us>*/
							i_text
/*<FunctionArgDesc ja_jp>切り出す文字数</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Number of character to be extracted</FunctionArgDesc en_us>*/
							, i_length
							);
	%local _result;
	%if (not %&RSUMacroVariable.IsBlank(i_text) and not %&RSUMacroVariable.IsBlank(i_length)) %then %do;
		%local /readonly _ORG_LEN = %sysfunc(klength(&i_text.));
		%if (0 < &_ORG_LEN.) %then %do;
			%local /readonly _SLICE_LEN = %&RSUUtil.Choose(%eval(&_ORG_LEN. < &i_length.), &_ORG_LEN., &i_length.);
			%if (0 < &_SLICE_LEN.) %then %do;
				/* ! 切り出し長 = 0とするとERRORが出るため、処理を分ける */
				/* ! Divide the process to avoid the ERROR when the extract length = 0 */
				%let _result = %sysfunc(ksubstr(&i_text., 1, &_SLICE_LEN.));
			%end;
		%end;
	%end;
	%else %do;
		%let _result = &i_text.;
	%end;
	&_result.
%mend RSUText__Left;

/*<FunctionDesc ja_jp>文字列の右側から指定文字数だけ切り出します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Extract designated number of characters from the right-end of a text string</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>切り出された文字列</FunctionReturn ja_jp>*/
/*<FunctionReturn ja_jp>Extracted text string</FunctionReturn ja_jp>*/
%macro RSUText__Right(
/*<FunctionArgDesc ja_jp>文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Text string</FunctionArgDesc en_us>*/
							i_text
/*<FunctionArgDesc ja_jp>切り出す文字数</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Number of character to be extracted</FunctionArgDesc en_us>*/
							, i_length
							);
	%local _result;
	%if (not %&RSUMacroVariable.IsBlank(i_text) and not %&RSUMacroVariable.IsBlank(i_length)) %then %do;
		%local /readonly _ORG_LEN = %sysfunc(klength(&i_text.));
		%if (0 < &_ORG_LEN.) %then %do;
			%local /readonly _SLICE_LEN = %&RSUUtil.Choose(%eval(&_ORG_LEN. < &i_length.), &_ORG_LEN., &i_length.);
			%local /readonly _POS = %eval(&_ORG_LEN. - &_SLICE_LEN. + 1);
			%if (&_POS. <= &_ORG_LEN.) %then %do;
				%let _result = %sysfunc(ksubstr(&i_text., &_ORG_LEN. - &_SLICE_LEN. + 1, &_SLICE_LEN.));
			%end;
		%end;
	%end;
	%else %do;
		%let _result = &i_text.;
	%end;
	&_result.
%mend RSUText__Right;

/*<FunctionDesc ja_jp>文字列の指定位置から指定文字数だけ切り出します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Extract designated number of characters from the designated index of a text string</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>切り出された文字列</FunctionReturn ja_jp>*/
/*<FunctionReturn ja_jp>Extracted text string</FunctionReturn ja_jp>*/
%macro RSUText__Mid(
/*<FunctionArgDesc ja_jp>文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Text string</FunctionArgDesc en_us>*/
						i_text
/*<FunctionArgDesc ja_jp>切り出し開始文字位置</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Designated index of a text string</FunctionArgDesc en_us>*/
						, i_pos
/*<FunctionArgDesc ja_jp>切り出す文字数（0を許容します）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Number of character to be extracted (0 is allowed)</FunctionArgDesc en_us>*/
						, i_length
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_pos)
	%local _result;
	%if (not %&RSUMacroVariable.IsBlank(i_text)) %then %do;
		%local /readonly _ORG_LEN = %sysfunc(klength(&i_text.));
		%local /readonly _REMAINING_LEN = %eval(&_ORG_LEN. - &i_pos. + 1);
		%if (0 < &_REMAINING_LEN.) %then %do;
			/*
				! 切り出し長
				! 省略時、または残り文字数より長い場合は残り文字列すべて
			*/
			/*
				! Number of character to be extracted
				! When the number is omitted or exceeds the remaining character length, the number becomes the remaining character length
			*/
			%local _slice_len;
			%if (%&RSUMacroVariable.IsBlank(i_length)) %then %do;
				%let _slice_len = &_REMAINING_LEN.;
			%end;
			%else %do;
				%if (&_REMAINING_LEN. < &i_length.) %then %do;
					%let _slice_len = &_REMAINING_LEN.;
				%end;
				%else %do;
					%let _slice_len = &i_length.;
				%end;
			%end;

			%if (0 < &_slice_len.) %then %do;
				/* ! 切り出し長 = 0とするとWARNINGが出るため、処理を分ける */
				/* ! Divide the process to avoid the WARNING when the extract length = 0 */
				%let _result = %sysfunc(substr(&i_text., &i_pos., &_slice_len.));
			%end;
		%end;
	%end;
	%else %do;
		%let _result = &i_text.;
	%end;
	&_result.
%mend RSUText__Mid;

/*<FunctionDesc ja_jp>連結文字列のスタイルを変更します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>スタイルが変更された連結文字列</FunctionReturn ja_jp>*/
%macro RSUText__ChangeConcatStyle(
/*<FunctionArgDesc ja_jp>入力連結文字列</FunctionArgDesc ja_jp>*/
											i_concat_text =
/*<FunctionArgDesc ja_jp>入力連結文字列の区切り文字</FunctionArgDesc ja_jp>*/
											, i_delimiter = %str( )
/*<FunctionArgDesc ja_jp>入力連結文字列の囲み文字を取り除くか否か</FunctionArgDesc ja_jp>*/
											, i_remove_enclosure = %&RSUBool.False
/*<FunctionArgDesc ja_jp>新規区切り文字</FunctionArgDesc ja_jp>*/
											, i_new_delimiter = %str( )
/*<FunctionArgDesc ja_jp>新規囲み文字</FunctionArgDesc ja_jp>*/
											, i_new_enclosure = %&RSUEnclosure.None
											);
	%local _new_concat_text;
	%if (%&RSUMacroVariable.IsBlank(i_concat_text)) %then %do;
		%goto __leave_change_conacat;
	%end;
	%local _element;
	%local _index_element;
	%do %while(%&RSUUtil.ForEach(i_items = &i_concat_text.
										, ovar_item = _element
										, iovar_index = _index_element
										, i_delimiter = &i_delimiter.));
		%if (&i_remove_enclosure.) %then %do;
			%let _element = %RSUText__Mid(&_element.
													, 2
													, %length(&_element.) - 2);
		%end;
		%if (&i_new_enclosure. ne %&RSUEnclosure.None) %then %do;
			%let _element = %sysfunc(&i_new_enclosure.(&_element.));
		%end;
		%RSUText__Append(iovar_base = _new_concat_text
							, i_append_text = &_element.
							, i_delimiter = &i_new_delimiter.)
	%end;
%__leave_change_conacat:
	&_new_concat_text.
%mend RSUText__ChangeConcatStyle;

/*<FunctionDesc ja_jp>文字列置換</FunctionDesc ja_jp>*/
%macro RSUText__ScanReplaceWord(
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
/*<FunctionArgDesc ja_jp>区切り文字</FunctionArgDesc ja_jp>*/
											, i_delimiter =
/*<FunctionArgDesc ja_jp>未置換キーを保持するデータセット</FunctionArgDesc ja_jp>*/
											, ods_unreplaced_keys =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_dataset i_variable ids_replacing_values i_key_variable i_data_variable i_delimiter)
	%&RSUDS.VerifyExists(&iods_dataset.)
	%&RSUDS.VerifyExists(&ids_replacing_values.)
	data &iods_dataset.;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__tmp_decmp_definition))
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
		__tmp_decmp_index = 1;
		__tmp_decmp_definition = &i_variable.;
		&i_key_variable. = scan(__tmp_decmp_definition, __tmp_decmp_index, &i_delimiter.);
		call missing(&i_variable.);
		do while(not missing(&i_key_variable.));
			if (h_hash_master.find() = 0) then do;
				&i_variable. = catx(&i_delimiter., &i_variable., &i_data_variable.);			
			end;
			else do;
				&i_variable. = catx(&i_delimiter., &i_variable., &i_key_variable.);			
				__tmp_decmp_rc = h_hash_unreplaced.add();
			end;
			__tmp_decmp_index = __tmp_decmp_index + 1;
			&i_key_variable. = scan(__tmp_decmp_definition, __tmp_decmp_index, &i_delimiter.);
		end;
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
%mend RSUText__ScanReplaceWord;
