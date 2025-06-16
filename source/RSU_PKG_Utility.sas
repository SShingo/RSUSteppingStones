/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Util.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/2/13
/*
/************************************************************************************/
/*<PackageID>RSUUtil</PackageID>*/
/*<CategoryID>Cate_Misc</CategoryID>*/
/*<PackagePurpose ja_jp>ユーティリティ</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Utility</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>様々な場面で用いるユーティリティマクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>This package provides utility macro functions</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>ユーティリティパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Utility Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSUUtil, RSUUtil__)

/*<FunctionDesc ja_jp>プログラムを強制終了します（セッション切断）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Abort the program (session disconnect) </FunctionDesc en_us>*/
%macro RSUUtil__Terminate;
	%Int_RSULogger_PutTerminate
	%&RSULogger.PutWarning(Cleaning up all debries...)
   %&RSUClass.CleanUpAll()
	%abort return;
%mend RSUUtil__Terminate;

/*<FunctionDesc ja_jp>処理を強制終了します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Abort the process</FunctionDesc en_us>*/
%macro RSUUtil__Abort(i_option =);
	%Int_RSULogger_PutAbort
	%&RSULogger.PutWarning(Cleaning up all debries...)
   %&RSUClass.CleanUpAll()
	%abort &i_option.;
%mend RSUUtil__Abort;

/*<FunctionDesc ja_jp>RSU パッケージ停止 </FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Deactivate RSU package</FunctionDesc en_us>*/
%macro RSUUtil__Deactivate;
   %&RSUClass.CleanUpAll()
   libname L_RSUMDL clear;
%mend RSUUtil__Deactivate;

/*<FunctionDesc ja_jp>マクロ変数が等しいか否かを判定します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Determine whether the macro variables are the same</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>1: マクロ変数が等しい\quad 0: マクロ変数が等しくない</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>1: Macro variables are the same \quad 0: Macro variables are not the same</FunctionReturn en_us>*/
%macro RSUUtil__Eq(
/*<FunctionArgDesc ja_jp>比較対象のマクロ変数名（左辺）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target macro variable name (Left-hand side) /FunctionArgDesc en_us>*/
						ivar_macro_lhs
/*<FunctionArgDesc ja_jp>比較対象のマクロ変数名（右辺）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target macro variable name (Right-hand side) /FunctionArgDesc en_us>*/
						, ivar_macro_rhs
						);
	%sysevalf(%superq(&ivar_macro_lhs.) = %superq(&ivar_macro_rhs.), boolean)
%mend RSUUtil__Eq;

/*<FunctionDesc ja_jp>右辺のマクロ値が左辺のマクロ値以上であるかを判定します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Determine whether the right-hand side macro value is equal to or greater than left-hand side macro value</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>1: 左辺マクロが変数が右辺以下\quad 0: 左辺マクロ変数が右辺より大</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>1: Left-hand side macro value is equal to or less than right-hand side macro value\quad 0: Left-hand side macro value is greater than right-hand side macro value</FunctionReturn en_us>*/
%macro RSUUtil__GE(
/*<FunctionArgDesc ja_jp>比較対象のマクロ変数名（左辺）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target macro variable name (Left-hand side) </FunctionArgDesc en_us>*/
						ivar_macro_lhs
						, ivar_macro_rhs
/*<FunctionArgDesc ja_jp>比較対象のマクロ変数名（右辺）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target macro variable name (Right-hand side) </FunctionArgDesc en_us>*/
						);
	%sysevalf(%superq(&ivar_macro_lhs.) <= %superq(&ivar_macro_rhs.), boolean)
%mend RSUUtil__GE;

/*<FunctionDesc ja_jp>右辺のマクロ値が左辺のマクロ値超であるかを判定します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Determine whether the right-hand side macro value is greater than left-hand side macro value</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>1: 左辺マクロが変数が右辺未満\quad 0: 左辺マクロ変数が右辺以上</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Left-hand side macro value is less than right-hand side macro value\quad 0: Left-hand side macro value is equal to or greater than right-hand side macro value</FunctionReturn en_us>*/
%macro RSUUtil__GT(
/*<FunctionArgDesc ja_jp>比較対象のマクロ変数名（左辺）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target macro variable name (Left-hand side) </FunctionArgDesc en_us>*/
						ivar_macro_lhs
/*<FunctionArgDesc ja_jp>比較対象のマクロ変数名（右辺）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target macro variable name (Right-hand side) </FunctionArgDesc en_us>*/
						, ivar_macro_rhs
						);
	%sysevalf(%superq(&ivar_macro_lhs.) < %superq(&ivar_macro_rhs.), boolean)
%mend RSUUtil__GT;

/*<FunctionDesc ja_jp>指定文字列がリストに含まれているか否かを返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Determine whether target string is included in the list</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>0:文字列がリストに含まれていない\quad 1:文字列がリストに含まれている</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>0:String is not included in the list\quad 1:String is included in the list</FunctionReturn en_us>*/
%macro RSUUtil__IsValueInList(
/*<FunctionArgDesc ja_jp>検索文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target string</FunctionArgDesc en_us>*/
										i_value =
/*<FunctionArgDesc ja_jp>文字列リスト</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>String list</FunctionArgDesc en_us>*/
										, i_list =
										) /minoperator;
	%&RSUUtil.VerifyRequiredArgs(i_args = i_value i_list)
	%eval(&i_value. in (&i_list.))
%mend RSUUtil__IsValueInList;

/*<FunctionDesc ja_jp>指定文字列がリストに含まれているかを検証します（含まれていない場合、処理が中断します）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Verify whether target string is included in the list (if not, the process will be stopped)</FunctionDesc en_us>*/
%macro RSUUtil__VerifyValueInList(
/*<FunctionArgDesc ja_jp>検索文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target string</FunctionArgDesc en_us>*/
											i_value =
/*<FunctionArgDesc ja_jp>文字列リスト</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>String list</FunctionArgDesc en_us>*/
											, i_list =
											);
	%if (not %RSUUtil__IsValueInList(i_value = &i_value
												, i_list = &i_list.)) %then %do;
		%&RSULogger.PutError(%&RSUMsg.VALUE_NOT_IN_LIST(&i_value., &i_list.));
	%end;
%mend RSUUtil__VerifyValueInList;

/*<FunctionDesc ja_jp>引数リストに空文字列が含まれていないかを検証します（空の変数がある場合、処理が中断します）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Verify whether empty string is included in the argument list (if not, the process will be stopped)</FunctionDesc en_us>*/
%macro RSUUtil__VerifyRequiredArgs(
/*<FunctionArgDesc ja_jp>検証対象となる引数変数名リスト</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target argument names list</FunctionArgDesc en_us>*/
											i_args =
											);
	%if (%&RSUMacroVariable.IsBlank(i_args)) %then %do;
		%put Critical Error in RSUUtil__VerifyRequiredArgs;
	%end;

	%local _arg;
	%local _index;
	%let _index = 1;
	%let _arg = %scan(&i_args., &_index., %str( ));
	%do %while(not %&RSUMacroVariable.IsBlank(_arg));
		%if (%&RSUMacroVariable.IsBlank(&_arg.)) %then %do;
			%&RSULogger.PutError(%&RSUMsg.MACRO_VAR_BLANK(&_arg.));
		%end;

		%let _index = %eval(&_index. + 1);
		%let _arg = %scan(&i_args., &_index., %str( ));
	%end;
%mend RSUUtil__VerifyRequiredArgs;

/*<FunctionDesc ja_jp>要素を走査して、値、インデックスを取得します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Scan the elements to obtain value and index</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>要素が取得出来たら1、取得できない（ループ終了）したら0</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Return 1 If element can be obtained, 0 if element cannot be obtained(end of loop)</FunctionReturn en_us>*/
%macro RSUUtil__ForEach(
/*<FunctionArgDesc ja_jp>配列文字列（デフォルトでスペース区切り）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>String array (separated by space by default) </FunctionArgDesc en_us>*/
								i_items =
/*<FunctionArgDesc ja_jp>要素の区切り文字</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Delimiter for elements</FunctionArgDesc en_us>*/
								, i_delimiter = %str( )
/*<FunctionArgDesc ja_jp>進行方向（\%\&RSUDirection.Forward: Forward、\%\&RSUDirection.Backward: Backward）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Direction（\%\&RSUDirection.Forward: Forward、\%\&RSUDirection.Backward: Backward）</FunctionArgDesc en_us>*/
								, i_direction = 1
/*<FunctionArgDesc ja_jp>要素を受け取るマクロ変数名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Macro variable name that receives the element</FunctionArgDesc en_us>*/
								, ovar_item =
/*<FunctionArgDesc ja_jp>要素番号を受け取るマクロ変数名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Macro variable name that receives the index</FunctionArgDesc en_us>*/
								, iovar_index =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ovar_item iovar_index)
	%local _rsu_utile_foreach_rc;
	%if (not %&RSUMacroVariable.IsBlank(i_items)) %then %do;
		%if (%&RSUMacroVariable.IsBlank(&iovar_index.) or &&&iovar_index = -1) %then %do;
			%let &iovar_index. = 0;
		%end;
		%let &iovar_index. = %eval(&&&iovar_index. + 1);
		%local /readonly _RSU_UTIL_FOREACH_INDEX = %eval(&&&iovar_index. * &i_direction.);
		%let &ovar_item. = %scan(%quote(&i_items.), &_RSU_UTIL_FOREACH_INDEX., &i_delimiter.);
		%if (%&RSUMacroVariable.IsBlank(&ovar_item.)) %then %do;
			%let _rsu_utile_foreach_rc = %&RSUBool.False;
			%let &ovar_item =;
			%let &iovar_index. = -1;
		%end;
		%else %do;
			%let _rsu_utile_foreach_rc = %&RSUBool.True;
		%end;
	%end;
	%else %do;
		%let _rsu_utile_foreach_rc = %&RSUBool.False;
	%end;
	&_rsu_utile_foreach_rc.
%mend RSUUtil__ForEach;

/*<FunctionDesc ja_jp>セッションで一意になる文字列を作成します（連番部は36進数）</FunctionDesc ja_jp>*/
/*<FunctionArgDesc en_us>Create unique strings within the session </FunctionArgDesc en_us>*/
%macro RSUUtil__GetSequenceId(
/*<AgrDesc ja_jp>接頭語</FunctionArgDesc ja_jp>*/
/*<AgrDesc en_us>Prefix</FunctionArgDesc en_us>*/
										i_prefix =
/*<AgrDesc ja_jp>連番を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
/*<AgrDesc en_us>Macro variable that contains the serial numbers</FunctionArgDesc en_us>*/
										, iovar_sequence =
/*<AgrDesc ja_jp>接尾語</FunctionArgDesc ja_jp>*/
/*<AgrDesc en_us>Suffix</FunctionArgDesc en_us>*/
										, i_suffix =
/*<AgrDesc ja_jp>連番部分の桁数</FunctionArgDesc ja_jp>*/
/*<AgrDesc en_us>Digits of serial numbers</FunctionArgDesc en_us>*/
										, i_digit =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_sequence)
   %local /readonly _SEQUENCE_NO = %sysfunc(RSU_fcmp_get_sequence(&&&iovar_sequence., 36, &i_digit.));
	%let &iovar_sequence. = %eval(&&&iovar_sequence. + 1);
   &i_prefix._&_SEQUENCE_NO.&i_suffix.
%mend RSUUtil__GetSequenceId;

/*<FunctionDesc ja_jp>システムオプションに新規エントリを追加します </FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Add new entry to system options</FunctionDesc en_us>*/
%macro RSUUtil__InsertDirSASOption(
/*<FunctionArgDesc ja_jp>オプション名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Option name</FunctionArgDesc en_us>*/
											i_option =
/*<FunctionArgDesc ja_jp>新規エントリ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>New entry</FunctionArgDesc en_us>*/
											, i_new_option =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_option i_new_option)
   %Int_InsertDirSASOptionHelper(i_option = &i_option.
											, i_new_option = &i_new_option.)
%mend RSUUtil__InsertDirSASOption;

/*<FunctionDesc ja_jp>データセットを使ってグローバルマクロ変数に値を代入します </FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Assign value into global macro variable using dataset</FunctionDesc en_us>*/
%macro RSUUtil__AssignMacroVarByDS(
/*<FunctionArgDesc ja_jp>入力データセット</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Input dataset</FunctionArgDesc en_us>*/
											ids_input_ds =
/*<FunctionArgDesc ja_jp>マクロ変数名を規定する変数名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Name of the variable that contains macro variable names</FunctionArgDesc en_us>*/
											, i_name_variable =
/*<FunctionArgDesc ja_jp>マクロ変数値を規定する変数名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Name of the variable that contains macro variable values</FunctionArgDesc en_us>*/
											, i_value_variable =
/*<FunctionArgDesc ja_jp>マクロ変数に付与する Prefix</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Prefix for macro variables</FunctionArgDesc en_us>*/
											, i_var_name_prefix =
/*<FunctionArgDesc ja_jp>マクロ変数に付与する Suffix</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Suffix for macro variables</FunctionArgDesc en_us>*/
											, i_var_name_suffix =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_input_ds i_name_variable i_value_variable)
	data _null_;
		set &ids_input_ds.;
		attrib
			_macro_name length = $32.
		;
		_macro_name = cats("&i_var_name_prefix.", &i_name_variable., "&i_var_name_suffix.");
		call symputx(_macro_name, &i_value_variable., 'G');
	run;
	quit;
%mend RSUUtil__AssignMacroVarByDS;

/*<FunctionDesc ja_jp>テキストを使ってグローバルマクロ変数に値を代入します </FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Assign value into globl macro variable using texts</FunctionDesc en_us>*/
%macro RSUUtil__AssignMacroVarByText(
/*<FunctionArgDesc ja_jp>入力データのフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Full path to the input data</FunctionArgDesc en_us>*/
											i_file_path =
/*<FunctionArgDesc ja_jp>区切り文字</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Delimiter</FunctionArgDesc en_us>*/
											, i_delimiter = &RSUTab.
/*<FunctionArgDesc ja_jp>ヘッダー行をスキップするか否か</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Whether to skip the first row or not</FunctionArgDesc en_us>*/
											, i_skip_header = %&RSUBool.True
/*<FunctionArgDesc ja_jp>マクロ変数に付与する Prefix</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Prefix for macro variable</FunctionArgDesc en_us>*/
											, i_var_name_prefix =
/*<FunctionArgDesc ja_jp>マクロ変数に付与する Suffix</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Suffix for macro variable</FunctionArgDesc en_us>*/
											, i_var_name_suffix =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path)
	%local _skip_code;
	%if (&i_skip_header.) %then %do;
		_skip_code = firstobs = 2;
	%end;
	data _null_;
		attrib
			_macro_name length = $32.
			_macro_value length = $500.
		;
		infile "&i_file_path." delimiter = &i_delimiter. dsd missover &_skip_code.;
		input
			_macro_name
			_macro_value
		;
		_macro_name = cats("&i_var_name_prefix.", _macro_name, "&i_var_name_suffix.");
		call symputx(_macro_name, _macro_value, 'G');
	run;
	quit;
%mend RSUUtil__AssignMacroVarByText;

/*<FunctionDesc ja_jp>三項演算子</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\texttt{i\_condition}が真の場合、第二引数引数、\texttt{i\_condition}が偽の場合、第三引数要素</FunctionReturn ja_jp>*/
%macro RSUUtil__Choose(
/*<FunctionArgDesc ja_jp>条件</FunctionArgDesc ja_jp>*/
							i_condition
/*<FunctionArgDesc ja_jp>条件が真の場合の戻り値</FunctionArgDesc ja_jp>*/
							, i_ret_true
/*<FunctionArgDesc ja_jp>条件が偽の場合の戻り値</FunctionArgDesc ja_jp>*/
							, i_ret_false);
	%if ((&i_condition.) = %&RSUBool.True) %then %do;
		&i_ret_true.
	%end;
	%else %do;
		&i_ret_false.
	%end;
%mend RSUUtil__Choose;

/*<FunctionDesc ja_jp>データセットの1カラムをブロック表示</FunctionDesc ja_jp>*/
%macro RSUUtil__ShowSingleColumn(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
											i_query =
/*<FunctionArgDesc ja_jp>表示変数定義</FunctionArgDesc ja_jp>*/
											, i_variable_def =
/*<FunctionArgDesc ja_jp>ブロックタイトル</FunctionArgDesc ja_jp>*/
											, i_title =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_variable_def i_title)
	%local _ds_elements;
	%&RSUDS.GetConcatValue(i_query = &i_query.
								, i_variable_def = &i_variable_def.
								, i_delimiter = %str(,)
								, ovar_concat_text = _ds_elements)
	%&RSULogger.PutBlock(&i_title.
								, &_ds_elements.)
%mend RSUUtil__ShowSingleColumn;

/*<FunctionDesc ja_jp>データセットの値をマクロ変数に保持（連番自動付与）</FunctionDesc ja_jp>*/
%macro RSUUtil__StoreValueToMacro(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
											i_query =
/*<FunctionArgDesc ja_jp>マクロ変数名</FunctionArgDesc ja_jp>*/
											, i_macro_variable =
/*<FunctionArgDesc ja_jp>マクロ変数に保持する値の定義</FunctionArgDesc ja_jp>*/
											, i_value_def =
											);
/*<FunctionDetail ja_jp>
SASの仕様上、ローカルマクロ変数を他のマクロ内で定義できないので、グローバルマクロとして保持されます。使用後は``\text{DisposeMacro}''関数を使ってマクロ変数を削除することを勧めます。
</FunctionDetail ja_jp>*/
	data _null_;
		set &i_query.;
		attrib
			__macro_var_name length = $32.
		;
		__macro_var_name = catx('_', "&i_macro_variable.", _N_);
		call symputx(__macro_var_name, &i_value_def., 'G');
	run;
	quit;
%mend RSUUtil__StoreValueToMacro;

/*<FunctionDesc ja_jp>データセットの値によって保持されたグローバルマクロを削除します</FunctionDesc ja_jp>*/
%macro RSUUtil__DisposeMacro(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
									i_query =
/*<FunctionArgDesc ja_jp>マクロ変数名</FunctionArgDesc ja_jp>*/
									, i_macro_variable =
									);
	data _null_;
		set &i_query.;
		attrib
			__macro_var_name length = $32.
		;
		__macro_var_name = catx('_', "&i_macro_variable.", _N_);
		call execute(cat('%symdel ', __macro_var_name, ';'));
	run;
	quit;
%mend RSUUtil__DisposeMacro;