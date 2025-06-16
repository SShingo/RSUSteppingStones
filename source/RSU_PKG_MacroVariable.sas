%RSUSetConstant(RSUMacroVariable, RSUMacVar__)


/*<FunctionDesc ja_jp>マクロ変数が定義されているか否かを判定します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Return whether the macro variable is defined or not</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>0: マクロが変数が定義されていない\quad 1: マクロ変数が定義されている</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>0: macro variable is not defined\quad 1: macro variable is defined</FunctionReturn en_us>*/
%macro RSUMacVar__IsDefined(
/*<FunctionArgDesc ja_jp>判定対象のマクロ変数名</FunctionArgDesc ja_jp>*/
									i_macro_var_name
									);
	%eval(not %&RSUDS.IsDSEmpty(SASHELP.vmacro(where = (upcase(name) = upcase("&i_macro_var_name.")))))
%mend RSUMacVar__IsDefined;

/*<FunctionDesc ja_jp>マクロ変数が空か否かを判定します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Return whether the macro variable is empty or not</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>1: マクロが変数が空\quad 0: マクロ変数が空でない</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>1: macro variable is empty\quad 0: macro variable is not empty</FunctionReturn en_us>*/
%macro RSUMacVar__IsBlank(
/*<FunctionArgDesc ja_jp>判定対象のマクロ変数名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Name of the target macro variable</FunctionArgDesc en_us>*/
								ivar_macro
								);
	%sysevalf(%superq(&ivar_macro.) =, boolean)
%mend RSUMacVar__IsBlank;

/*<FunctionDesc ja_jp>データセットの内容を基にグローバル変数（定数）を設定します</FunctionDesc ja_jp>*/
%macro RSUMacVar__SetGlobalMacroByDS(
/*<FunctionArgDesc ja_jp>設定内容データセット</FunctionArgDesc ja_jp>*/
												ids_dataset =
/*<FunctionArgDesc ja_jp>マクロ変数名を保持している変数</FunctionArgDesc ja_jp>*/
												, i_variable_name =
/*<FunctionArgDesc ja_jp>マクロ変数に設定する値を保持している変数</FunctionArgDesc ja_jp>*/
												, i_variable_value =
/*<FunctionArgDesc ja_jp>定数として設定するか否か</FunctionArgDesc ja_jp>*/
												, i_is_readonly = %&RSUBool.True
/*<FunctionArgDesc ja_jp>結果を表示するか否か</FunctionArgDesc ja_jp>*/
												, i_is_result_shown = %&RSUBool.False
												);
	%local /readonly _DS_GLOBAL_MACROS = %&RSUDSIterator.Create(&ids_dataset.);
	%do %while(%&RSUDSIterator.Next(_DS_GLOBAL_MACROS));
		%if (&i_is_readonly.) %then %do;
			%RSUSetConstant(%&RSUDSIterator.Current(_DS_GLOBAL_MACROS, &i_variable_name.)
								, %&RSUDSIterator.Current(_DS_GLOBAL_MACROS, &i_variable_value.))
		%end;
		%else %do;
			%global %&RSUDSIterator.Current(_DS_GLOBAL_MACROS, &i_variable_name.);
			%let %&RSUDSIterator.Current(_DS_GLOBAL_MACROS, &i_variable_name.) = %&RSUDSIterator.Current(_DS_GLOBAL_MACROS, &i_variable_value.);
		%end;
	%end;
	%&RSUDSIterator.Dispose(_DS_GLOBAL_MACROS)
	%if (&i_is_result_shown.) %then %do;
		%&RSUUtil.ShowSingleColumn(i_query = &ids_dataset.
										, i_variable_def = catx(':=', &i_variable_name., EncloseQuote(&i_variable_value.))
										, i_title = [Global macros])
	%end;
%mend RSUMacVar__SetGlobalMacroByDS;

/*<FunctionDesc ja_jp>データセットの内容を基に連番添え字付きのグローバルマクロ変数を設定します</FunctionDesc ja_jp>*/
%macro DSUMacroVar__DefineMacroVarByDS(
/*<FunctionArgDesc ja_jp>設定内容データセット</FunctionArgDesc ja_jp>*/
													ids_dataset =
/*<FunctionArgDesc ja_jp>マクロ変数名を保持している変数</FunctionArgDesc ja_jp>*/
													, i_variable =
/*<FunctionArgDesc ja_jp>マクロ変数名</FunctionArgDesc ja_jp>*/
													, i_macro_variable_prefex =
													);
	data _null_;
		set &ids_dataset.;
		call symputx(catx('_', "&i_macro_variable_prefex.", _N_), &i_variable., 'G');
	run;
	quit;
%mend DSUMacroVar__DefineMacroVarByDS;

/*<FunctionDesc ja_jp>正規表現に一致するマクロ変数を削除します</FunctionDesc ja_jp>*/
%macro RSUMacVar__Delete(
/*<FunctionArgDesc ja_jp>削除するマクロ変数名の正規表現</FunctionArgDesc ja_jp>*/
								i_regex =
/*<FunctionArgDesc ja_jp>削除されたマクロ変数の数</FunctionArgDesc ja_jp>*/
								, ovar_no_of_removed_macro_var =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_regex)
	%local /readonly __DEL_GLOBAL_QUERY = SASHELP.vmacro(keep = name where = (prxmatch("&i_regex.", trim(name))));
	%local __del_global_dsid;
	%let __del_global_dsid = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&__DEL_GLOBAL_QUERY., IN)));
	%local __del_global_macro;
	%local __rc_del_global_fetch;
	%let __rc_del_global_fetch = %sysfunc(fetch(&__del_global_dsid.));
	%local __del_global_macro_index;
	%let __del_global_macro_index = 0;
	%do %while(&__rc_del_global_fetch. = 0);
		%let __del_global_macro = %sysfunc(fcmp_rsu_ds_get_curr_by_name(&__del_global_dsid., name));
		%let __del_global_macro_index = %eval(&__del_global_macro_index. + 1);
		%local __RSU_G_DEL_GLOBAL_MACRO_&__del_global_macro_index.;
		%let __RSU_G_DEL_GLOBAL_MACRO_&__del_global_macro_index. = &__del_global_macro.;
		%let __rc_del_global_fetch = %sysfunc(fetch(&__del_global_dsid.));
	%end;
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&__del_global_dsid.)))

	%local __del_index;
	%do __del_index = 1 %to &__del_global_macro_index.;
		%if (%symexist(&&&__RSU_G_DEL_GLOBAL_MACRO_&__del_index.)) %then %do;
			%symdel &&&__RSU_G_DEL_GLOBAL_MACRO_&__del_index.;
		%end;
	%end;
	%if (not %&RSUMacroVariable.IsBlank(ovar_no_of_removed_macro_var)) %then %do;
		%let &ovar_no_of_removed_macro_var. = &__del_global_macro_index.;
	%end;
%mend RSUMacVar__Delete;

/*<FunctionDesc ja_jp>マクロ変数の値を増加させます（減少も可）</FunctionDesc ja_jp>*/
%macro RSUMacVar__Increment(
/*<FunctionArgDesc ja_jp>対象のマクロ変数（数値が設定されていること）</FunctionArgDesc ja_jp>*/
									iovar_variable
/*<FunctionArgDesc ja_jp>変化幅</FunctionArgDesc ja_jp>*/
									, i_step = 1
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_variable i_step)
	%let &iovar_variable. = %eval(&&&iovar_variable. + &i_step.);
%mend RSUMacVar__Increment;

%macro RSUMacVar__IsNull(ivar_variable);
	%RSUUtil__Eq(&ivar_variable., RSUVarNULL)
%mend RSUMacVar__IsNull;
