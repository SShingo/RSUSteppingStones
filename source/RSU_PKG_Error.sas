/************************************************************************************/
/* PROGRAM NAME : RSU_PKG_Error.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2022/9/3
/*
/************************************************************************************/
/*<PackageID>RSUError</PackageID>*/
/*<CategoryID>Cate_DebuggingAndLogging</CategoryID>*/
/*<PackagePurpose ja_jp>エラーハンドリング</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Handle errors</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>マクロ実行エラーをハンドリングするマクロ群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions handling errors</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>エラーパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Error Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSUError, RSUError__)

/*******************************************/
/* Public Macros
/*******************************************/
/*<FunctionDesc ja_jp>エラー状態をクリアします</FunctionDesc ja_jp>*/
%macro RSUError__Initialize(
/*<FunctionArgDesc ja_jp>警告をエラーとして扱うか否か</FunctionArgDesc ja_jp>*/
									i_is_warning_error =
									);
	%let RSU_g_is_exception_thrown = %&RSUBool.False;
	%if (not %&RSUMacroVariable.IsBlank(i_is_warning_error)) %then %do;
		%let RSU_g_is_warning_error = &i_is_warning_error.;
	%end;
%mend RSUError__Initialize;

/*<FunctionDesc ja_jp>条件に一致した場合に処理を停止します</FunctionDesc ja_jp>*/
%macro RSUError__AbortIf(
/*<FunctionArgDesc ja_jp>停止条件</FunctionArgDesc ja_jp>*/
								i_condition
/*<FunctionArgDesc ja_jp>停止レベル</FunctionArgDesc ja_jp>*/
								, i_abort =
/*<FunctionArgDesc ja_jp>停止時メッセージ</FunctionArgDesc ja_jp>*/
								, i_msg =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_condition)
	%if (&i_condition.) %then %do;
		%local _msg;
		%let _msg = ABORT!;
		%if (not %&RSUMacroVariable.IsBlank(i_msg)) %then %do;
			%let _msg = &_msg. &i_msg;
		%end;
		%&RSULogger.PutError(&i_msg., i_abort = none)
		%abort &i_abort.;
	%end;
%mend RSUError__AbortIf;