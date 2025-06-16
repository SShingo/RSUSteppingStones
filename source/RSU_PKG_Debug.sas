/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Debug.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/2/13
/*
/************************************************************************************/
/*<PackageID>RSUDebug</PackageID>*/
/*<CategoryID>Cate_DebuggingAndLogging</CategoryID>*/
/*<PackagePurpose ja_jp>デバッグ</PackagePurpose ja_jp>*/
/*<PackageDesc ja_jp>デバッグ関連マクロ群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions used for debugging</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>デバッグパッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUDebug, RSUDebug__)

/*<FunctionDesc ja_jp>実行モードがデバッグモードか否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0:リリースモード時\quad 1: デバッグモード時</FunctionReturn ja_jp>*/
%macro RSUDebug__IsDebugMode;
	%eval(%upcase(&RSU_g_execution_mode.) = DEBUG)
%mend RSUDebug__IsDebugMode;

/*<FunctionDesc ja_jp>実行モードをデバッグモードにします</FunctionDesc ja_jp>*/
%macro RSUDebug__Enable(
/*<FunctionArgDesc ja_jp>分析モードを有効にするか</FunctionArgDesc ja_jp>*/
								i_is_diag_mode = %&RSUBool.False
								);
	%let RSU_g_execution_mode = DEBUG;
	%let debug__ = * */;
	%let release__ = *;
	%let RSU_g_is_diag_on = &i_is_diag_mode.;
	%if (&RSU_g_is_diag_on.) %then %do;
		%let diag = * */;
	%end;
	%else %do;
		%let diag = *;
	%end;
	%&RSULogger.PutParagraph(%&RSUMsg.EXEC_MODE_CHANGED(&RSU_g_execution_mode.))
%mend RSUDebug__Enable;

/*<FunctionDesc ja_jp>実行モードをリリースモードにします</FunctionDesc ja_jp>*/
%macro RSUDebug__Disable();
	%let RSU_g_execution_mode = RELEASE;
	%let debug__ = *;
	%let release__ = * */;
	%let RSU_g_is_diag_on = %&RSUBool.False;
	%let diag = *;
	%&RSULogger.PutParagraph(%&RSUMsg.EXEC_MODE_CHANGED(&RSU_g_execution_mode.))
%mend RSUDebug__Disable;

/*<FunctionDesc ja_jp>分析モードがonか否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0:分析モードでない\quad 1: 分析モード</FunctionReturn ja_jp>*/
%macro RSUDebug__IsDiagOn();
	&RSU_g_is_diag_on.
%mend RSUDebug__IsDiagOn;

/*<FunctionDesc ja_jp>デバッグモード時にのみ有効のアサーション関数</FunctionDesc ja_jp>*/
%macro RSUDebug__Assert(
/*<FunctionArgDesc ja_jp>評価値（0の場合はアサーション違反）</FunctionArgDesc ja_jp>*/
								i_eval_result
/*<FunctionArgDesc ja_jp>違反時メッセージ</FunctionArgDesc ja_jp>*/
								, i_msg
								);
	/&debug__.
		%Prv_RSUDebug_AssertHelper(i_eval_result = &i_eval_result.
											, i_msg = &i_msg.)
	&__debug.**/
%mend RSUDebug__Assert;

/*<FunctionDesc ja_jp>デバッグメッセージを出力します（デバッグモード時にのみ有効）</FunctionDesc ja_jp>*/
%macro RSUDebug__PutLog(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
								i_msg
								);
	/&debug__.
		%Prv_RSULogger_OutputMsg(i_msg = &i_msg.
										, i_msg_header_key = HEADER_DEBUG)
	&__debug.**/
%mend RSUDebug__PutLog;

/*<FunctionDesc ja_jp>分析メッセージを出力します（デバッグモード時にのみ有効）</FunctionDesc ja_jp>*/
%macro RSUDebug__PutDiag(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
								i_msg
								);
	/&debug__.
	/&diag__.
				%Prv_RSULogger_OutputMsg(i_msg = &i_msg.
												, i_msg_header_key = HEADER_DIAG)
	&__diag.**/
	&__debug.**/
%mend RSUDebug__PutDiag;

/*<FunctionDesc ja_jp>フットプリントメッセージを表示します（デバッグモード時にのみ有効）</FunctionDesc ja_jp>*/
%macro RSUDebug__PutFootprint(
/*<FunctionArgDesc ja_jp>追加メッセージ</FunctionArgDesc ja_jp>*/
									i_msg
/*<FunctionArgDesc ja_jp>連番初期値</FunctionArgDesc ja_jp>*/
									, i_init_index =
									);
	/* デバッグマクロを有効にするためマクロ呼び出しにしている */
	/&debug__.
		%Prv_RSUDebug_ShowFootprint(i_msg = &i_msg.
											, i_init_index = &i_init_index.)
	&__debug.**/
%mend RSUDebug__PutFootprint;

/*<FunctionDesc ja_jp>マクロ変数のスナップショットを撮ります</FunctionDesc ja_jp>*/
%macro RSUDebug__TakeMacroSnapshot(
/*<FunctionArgDesc ja_jp>グローバルを対象にする場合1</FunctionArgDesc ja_jp>*/
											i_is_global =
/*<FunctionArgDesc ja_jp>コピー先親ディレクトリパス</FunctionArgDesc ja_jp>*/
											, i_dir_path =
/*<FunctionArgDesc ja_jp>連番初期値</FunctionArgDesc ja_jp>*/
											, i_init_index =
/*<FunctionArgDesc ja_jp>ディレクトリ名に付与する添え字</FunctionArgDesc ja_jp>*/
											, i_suffix =
/*<FunctionArgDesc ja_jp>コピー対象となるマクロ変数名フィルター用正規表現</FunctionArgDesc ja_jp>*/
											, i_varname_regex =
											);
	/* デバッグマクロを有効にするためマクロ呼び出しにしている */
	/&debug__.
		%Prv_RSUDebug_TakeMacroSnapshot(i_is_global = &i_is_global.
													, i_dir_path = &i_dir_path.
													, i_init_index = &i_init_index.
													, i_suffix = &i_suffix.
													, i_varname_regex = &i_varname_regex.)
	&__debug.**/
%mend RSUDebug__TakeMacroSnapshot;

/*<FunctionDesc ja_jp>指定ライブラリ内のデータセットのスナップショットを撮ります</FunctionDesc ja_jp>*/
%macro RSUDebug__TakeDSSnapshot(
/*<FunctionArgDesc ja_jp>コピー対象ライブラリ名</FunctionArgDesc ja_jp>*/
										i_libname =
/*<FunctionArgDesc ja_jp>コピー先親ディレクトリパス</FunctionArgDesc ja_jp>*/
										, i_dir_path =
/*<FunctionArgDesc ja_jp>連番初期値</FunctionArgDesc ja_jp>*/
										, i_init_index =
/*<FunctionArgDesc ja_jp>ディレクトリ名に付与する添え字</FunctionArgDesc ja_jp>*/
										, i_suffix =
/*<FunctionArgDesc ja_jp>コピー対象となるデータセット名フィルター用正規表現</FunctionArgDesc ja_jp>*/
										, i_dsname_regex =
										);
	/* デバッグマクロを有効にするためマクロ呼び出しにしている */
	/&debug__.
		%Prv_RSUDebug_TakeDSSnapshot(i_libname = &i_libname.
												, i_dir_path = &i_dir_path.
												, i_init_index = &i_init_index.
												, i_suffix = &i_suffix.
												, i_dsname_regex = &i_dsname_regex.)
	&__debug.**/
%mend RSUDebug__TakeDSSnapshot;

/*<FunctionDesc ja_jp>マクロ呼び出しのパン屑を取得します </FunctionDesc ja_jp>*/
%macro RSUDebug__GetBreadcrumbs(
/*<FunctionArgDesc ja_jp>表示するマクロの呼び出し深度の調整</FunctionArgDesc ja_jp>*/
											i_depth_offset = 0
											);
	%local _breadcrumbs;
	%let _breadcrumbs = <OPEN CODE>;
	%local _depth;
	%do _depth = 1 %to %sysmexecdepth - 2 + &i_depth_offset.;
		%let _breadcrumbs = &_breadcrumbs./%sysmexecname(&_depth.);
	%end;
	&_breadcrumbs.
%mend RSUDebug__GetBreadcrumbs;

/*<FunctionDesc ja_jp>マクロ実行開始追跡ログを出力します </FunctionDesc ja_jp>*/
%macro rsu_macro_start;
	%if (%sysmexecdepth = 1) %then %do;
		%let RSU_g_log_conf_show_macro = 1;
	%end;
	%if (&RSU_g_log_conf_show_macro.) %then %do;
		%let RSU_g_current_macro_depth = %eval(%sysmexecdepth - 1);
		%let _hier_lines = %Prv_RSULogger_GetHierLine(i_depth_adj = 1);
		%if (0 < %sysmexecdepth) %then %do;
			/* 空行（区切り）*/
			%put &RSU_G_MSG_INDENT_PLANE.&_hier_lines.;
		%end;
		%local _current_macro;
		%let _current_macro = %sysmexecname(%sysmexecdepth - 1);
		%put &RSU_G_MSG_INDENT_PLANE.&_hier_lines./-------[START](%&RSUTimer.GetNow):&_current_macro.-------;
		%if (&RSU_g_log_conf_show_arguments.) %then %do;
			%local /readonly _DS_ITER_ARGS = %&RSUDSIterator.Create(SASHELP.vmacro(where =(scope = "%upcase(&_current_macro.)")));
			%do %while(%&RSUDSIterator.ForEach(_DS_ITER_ARGS));
				%put &RSU_G_MSG_INDENT_PLANE.&_hier_lines.-ARGUMENT-: %&RSUDSIterator.Current(_DS_ITER_ARGS, name) %str(=) %&RSUDSIterator.Current(_DS_ITER_ARGS, value);
			%end;
			%&RSUDSIterator.Dispose(_DS_ITER_ARGS)
		%end;
	%end;
%mend rsu_macro_start;

/*<FunctionDesc ja_jp>マクロ実行終了追跡ログを出力します </FunctionDesc ja_jp>*/
%macro rsu_macro_end;
	%if (&RSU_g_log_conf_show_macro.) %then %do;
		%let RSU_g_current_macro_depth = %eval(%sysmexecdepth - 1);
		%put &RSU_G_MSG_INDENT_PLANE.%Prv_RSULogger_GetHierLine(i_depth_adj = 1)\-------[END](%&RSUTimer.GetNow):%sysmexecname(%sysmexecdepth - 1)-------;
		%let RSU_g_current_macro_depth = %eval(&RSU_g_current_macro_depth. - 1);
		%if (&RSU_g_current_macro_depth. = 0) %then %do;
			%let RSU_g_log_conf_show_macro = 0;
		%end;
	%end;
%mend rsu_macro_end;