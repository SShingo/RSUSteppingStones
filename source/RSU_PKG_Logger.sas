/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Logger.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/2/13
/*
/* NOTE: PUTはproc printtoに従った出力先への出力
/* NOTE: PRINTは一旦強制的に proc printto をデフォルトに設定してから出力（ログ出力後に戻す）
/*
/* ! 2021/10/16 ログ関数内に proc printto を入れると引数有りマクロ関数実行ができなくなる！
/************************************************************************************/
/*<PackageID>RSULogger</PackageID>*/
/*<CategoryID>Cate_DebuggingAndLogging</CategoryID>*/
/*<PackagePurpose ja_jp>ロガー</PackagePurpose ja_jp>*/
/*<PackageDesc ja_jp>ログ出力を操作するマクロ群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions for logging</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>ロガーパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Logger Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSULogger, RSULogger__)

/*<FunctionDesc ja_jp>デフォルト設定を用いてロガーの設定を行います</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Use default setting for the logger configuration</FunctionDesc en_us>*/
%macro RSULogger__Initialize(
/*<FunctionArgDesc ja_jp>設定キー</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Configuration Key</FunctionArgDesc en_us>*/
										i_conf_id =
										);
	%RSULogger__DisableOption()
%mend RSULogger__Initialize;

/* <MarcroDesc ja_jp>ログオプションを有効にします</FunctionDesc ja_jp>*/
%macro RSULogger__EnableOption(
/*<FunctionArgDesc ja_jp>有効にするログオプション（空欄の場合、すべてを有効にします）</FunctionArgDesc ja_jp>*/
										i_logger_options
										);
	%local /readonly __ALL_OPTIONS = notes source source2 mprint mlogic symbolgen;
	%local /readonly __LOGGER_OPTIONS = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_logger_options), &__ALL_OPTIONS., &i_logger_options);
	%local __logger_option;
	%local __index_logger_option;
	%do %while(%&RSUUtil.ForEach(i_items = &__ALL_OPTIONS., ovar_item = __logger_option, iovar_index = __index_logger_option));
		options no&__logger_option.;
	%end;
	%do %while(%&RSUUtil.ForEach(i_items = &__LOGGER_OPTIONS., ovar_item = __logger_option, iovar_index = __index_logger_option));
		options &__logger_option.;
	%end;
%mend RSULogger__EnableOption;

/* <MarcroDesc ja_jp>ログオプションを無効にします</FunctionDesc ja_jp>*/
%macro RSULogger__DisableOption(
/*<FunctionArgDesc ja_jp>有効にするログオプション（空欄の場合、すべてを無効にします）</FunctionArgDesc ja_jp>*/
											i_logger_options
											);
	%local /readonly __ALL_OPTIONS = notes source source2 mprint mlogic symbolgen;
	%local /readonly __LOGGER_OPTIONS = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_logger_options), &__ALL_OPTIONS., &i_logger_options);
	%local __logger_option;
	%local __index_logger_option;
	%do %while(%&RSUUtil.ForEach(i_items = &__LOGGER_OPTIONS., ovar_item = __logger_option, iovar_index = __index_logger_option));
		options no&__logger_option.;
	%end;
	%do %while(%&RSUUtil.ForEach(i_items = &__ALL_OPTIONS., ovar_item = __logger_option, iovar_index = __index_logger_option));
		%if (%sysfunc(find(&i_logger_options., &__logger_option.)) ne 0) %then %do;
			options &__logger_option.;
		%end;
	%end;
%mend RSULogger__DisableOption;

/*<FunctionDesc ja_jp>マクロ呼び出し追跡ログに引数を出力します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export arguments for macro call tracking log</FunctionDesc en_us>*/
%macro RSULogger__ShowMacroArgs;
	%put &RSU_G_MSG_INDENT_PLANE.%&RSUMsg.LOGGER_SETTING %&RSUMsg.MACRO_ARGS_ON;
	%let RSU_g_log_conf_show_arguments = %&RSUBool.True;
%mend RSULogger__ShowMacroArgs;

/*<FunctionDesc ja_jp>マクロ呼び出し追跡ログに引数を表示しないようにします</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Make macro call tracking log not display arguments</FunctionDesc en_us>*/

%macro RSULogger__HideMacroArgs;
	%put &RSU_G_MSG_INDENT_PLANE.%&RSUMsg.LOGGER_SETTING %&RSUMsg.MACRO_ARGS_OFF;
	%let RSU_g_log_conf_show_arguments = %&RSUBool.False;
%mend RSULogger__HideMacroArgs;

/*<FunctionDesc ja_jp>ログのデフォルトの書き出し先を設定します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Set the default log export destination</FunctionDesc en_us>*/
%macro RSULogger__SetDestination(
/*<FunctionArgDesc ja_jp>デフォルトのログ書き出し先（空欄の場合、SASデフォルト）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Default log export destination（If empty, SAS Dafault）</FunctionArgDesc en_us>*/
											i_file_path =
/*<FunctionArgDesc ja_jp>0: 追記\quad 1: 新規</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>0: Append\quad 1: New</FunctionArgDesc en_us>*/
											, i_is_replace = %&RSUBool.False
											);
	%let RSU_g_current_log_dest = &i_file_path.;
	%if (%&RSUMacroVariable.IsBlank(i_file_path)) %then %do;
		proc printto;
		run;
		quit;
	%end;
	%else %do;
		%local _option;
		%if (&i_is_replace.) %then %do;
			%let _option = new;
		%end;
		proc printto log = "&i_file_path." &_option.;
		run;
		quit;
	%end;
%mend RSULogger__SetDestination;

/*<FunctionDesc ja_jp>のログを出力します（現在の出力先）</FunctionDesc ja_jp>*/
%macro RSULogger__Put(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
							i_msg
							);
	%put &RSU_G_MSG_INDENT_PLANE.&i_msg.;
%mend RSULogger__Put;

/*<FunctionDesc ja_jp>装飾なしのログを出力します（現在の出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export plain log（Current destination）</FunctionDesc en_us>*/
%macro RSULogger__PutLog(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
								i_msg
								);
	%Prv_RSULogger_OutputMsg(i_msg = &i_msg.
									, i_msg_header_key = HEADER_PLANE
									, i_log_type = &RSU_G_MSG_INDENT_PLANE.)
%mend RSULogger__PutLog;

/*<FunctionDesc ja_jp>装飾なしのログを表示します（デフォルト出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export plain log（Default destination）</FunctionDesc en_us>*/
%macro RSULogger__PrintLog(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
									i_msg
									);
	proc printto;
	run;
	quit;
	%RSULogger__PutLog(i_msg = &i_msg.)
	%RSULogger__SetDestination(i_file_path = &RSU_g_current_log_dest.)
%mend RSULogger__PrintLog;

/*<FunctionDesc ja_jp>Infoスタイルのログを出力します（現在の出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Info style log（Current destination）</FunctionDesc en_us>*/
%macro RSULogger__PutInfo(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
								i_msg
								);
	%Prv_RSULogger_OutputMsg(i_msg = &i_msg.
									, i_msg_header_key = HEADER_INFO
									, i_log_type = &RSU_G_MSG_INDENT_PLANE.)
%mend RSULogger__PutInfo;

/*<FunctionDesc ja_jp>Infoスタイルのログを出力します（デフォルト出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Info style log（Default destination）</FunctionDesc en_us>*/
%macro RSULogger__PrintInfo(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
									i_msg
									);
	proc printto;
	run;
	quit;
	%Prv_RSULogger__PutInfo(i_msg = &i_msg.)
	%RSULogger__SetDestination(i_file_path = &RSU_g_current_log_dest.)
%mend RSULogger__PrintInfo;

/*<FunctionDesc ja_jp>Noteスタイルのログを出力します（現在の出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Note style log（Current destination）</FunctionDesc en_us>*/

%macro RSULogger__PutNote(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
								i_msg
								);
	%Prv_RSULogger_OutputMsg(i_msg = &i_msg.
									, i_msg_header_key = HEADER_NOTE
									, i_log_type = &RSU_G_MSG_INDENT_NOTE.)
%mend RSULogger__PutNote;

/*<FunctionDesc ja_jp>Noteスタイルのログを出力します（デフォルト出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Note style log（Default destination）</FunctionDesc en_us>*/
%macro RSULogger__PrintNote(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
									i_msg
									);
	proc printto;
	run;
	quit;
	%RSULogger__PutNote(i_msg = &i_msg.)
	%RSULogger__SetDestination(i_file_path = &RSU_g_current_log_dest.)
%mend RSULogger__PrintNote;

/*<FunctionDesc ja_jp>Warningログを出力します（現在の出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Warning log（Current destination）</FunctionDesc en_us>*/
%macro RSULogger__PutWarning(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
									i_msg
									);
	%Prv_RSULogger_OutputMsg(i_msg = &i_msg.
									, i_msg_header_key = HEADER_Warning
									, i_log_type = &RSU_G_MSG_INDENT_WARNING.)
%mend RSULogger__PutWarning;

/*<FunctionDesc ja_jp>Warningログを出力します（デフォルト出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Warning log（Default destination）</FunctionDesc en_us>*/
%macro RSULogger__PrintWarning(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
										i_msg
										);
	proc printto;
	run;
	quit;
	%RSULogger__PutWarning(i_msg = &i_msg.)
	%RSULogger__SetDestination(i_file_path = &RSU_g_current_log_dest.)
%mend RSULogger__PrintWarning;

/*<FunctionDesc ja_jp>Errorログを出力します（現在の出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Error log（Current destination）</FunctionDesc en_us>*/
%macro RSULogger__PutError(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
									i_msg
/*<FunctionArgDesc ja_jp>エラーログ表示後の中断処理</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Abot procedure after displaying the error log</FunctionArgDesc en_us>*/
									, i_abort =
									);
	%Prv_RSULogger_OutputMsg(i_msg = &i_msg.
									, i_msg_header_key = HEADER_ERROR
									, i_log_type = &RSU_G_MSG_INDENT_ERROR.)
	%if (&i_abort. ne none) %then %do;
		%&RSUUtil.Abort(i_option = &i_abort.);
	%end;
%mend RSULogger__PutError;

/*<FunctionDesc ja_jp>Errorログを出力します（デフォルト出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Error log（Default destination）</FunctionDesc en_us>*/
%macro RSULogger__PrintError(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
									i_msg
/*<FunctionArgDesc ja_jp>ログ表示後の処理（1: 継続、0：終了、-1：切断）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Procedure after displaying the log（1: Continue 0：Terminate、-1：Disconnect）</FunctionArgDesc en_us>*/
									, i_abort =
									);
	proc printto;
	run;
	quit;
	%RSULogger__PutError(i_msg = &i_msg.
									, i_abort = &i_abort.)
	%RSULogger__SetDestination(i_file_path = &RSU_g_current_log_dest.)
%mend RSULogger__PrintError;

/*<FunctionDesc ja_jp>Sectionログを出力します（現在の出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Section log（Current destination）</FunctionDesc en_us>*/
%macro RSULogger__PutSection(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
										i_msg
										) / parmbuff;
	%local _parms;
	%let _parms = %qsubstr(&syspbuff., 2, %length(&syspbuff.) - 2);
	%local _delimiter_line;
	%Prv_RSULogger_GetDelimiterLine(i_msg = %nrbquote(&_parms.)
											, i_char = *
											, i_buffer_length = 5
											, ovar_delimiter_line = _delimiter_line)
	%put;
	%put **&_delimiter_line.;
	%put **&_delimiter_line.;
	%put **;
	%Prv_RSULogger_PutMultLine(i_msg = %nrbquote(&_parms.)
										, i_header = **%str( ))
	%put **;
	%put **&_delimiter_line.;
	%put **&_delimiter_line.;
	%put;
%mend RSULogger__PutSection;

/*<FunctionDesc ja_jp>Sectionログを出力します（デフォルト出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Section log（Default destination）</FunctionDesc en_us>*/
%macro RSULogger__PrintSection(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
										i_msg
										);
	proc printto;
	run;
	quit;
	%RSULogger__PutSection(i_msg = &i_msg.)
	%RSULogger__SetDestination(i_file_path = &RSU_g_current_log_dest.)
%mend RSULogger__PrintSection;

/*<FunctionDesc ja_jp>Subsectionログを出力します（現在の出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Subsection log（Current destination）</FunctionDesc en_us>*/
%macro RSULogger__PutSubsection(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
											i_msg
											) / parmbuff;
	%local _parms;
	%let _parms = %qsubstr(&syspbuff., 2, %length(&syspbuff.) - 2);
	%local _delimiter_line;
	%Prv_RSULogger_GetDelimiterLine(i_msg = %nrbquote(&_parms.)
											, i_char = *
											, i_buffer_length = 12
											, ovar_delimiter_line = _delimiter_line)
	%put;
	%put &RSU_G_MSG_INDENT_PLANE.&_delimiter_line.;
	%Prv_RSULogger_PutMultLine(i_msg = %nrbquote(&_parms.)
										, i_header = &RSU_G_MSG_INDENT_PLANE.%str(***** ))
	%put &RSU_G_MSG_INDENT_PLANE.&_delimiter_line.;
	%put;
%mend RSULogger__PutSubsection;

/*<FunctionDesc ja_jp>Subsectionログを出力します（デフォルト出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Subsection log（Default destination）</FunctionDesc en_us>*/
%macro RSULogger__PrintSubsection(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
												i_msg
												);
	proc printto;
	run;
	quit;
	%RSULogger__PutSubsection(i_msg = &i_msg.)
	%RSULogger__SetDestination(i_file_path = &RSU_g_current_log_dest.)
%mend RSULogger__PrintSubsection;

/*<FunctionDesc ja_jp>Paragraphログを出力します（現在の出力先）</FunctionDesc ja_jp>*/
%macro RSULogger__PutParagraph(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
									i_msg
									) / parmbuff;
	%local _parms;
	%let _parms = %qsubstr(&syspbuff., 2, %length(&syspbuff.) - 2);
	%local _delimiter_line;
	%Prv_RSULogger_GetDelimiterLine(i_msg = %nrbquote(&_parms.)
											, i_char = =
											, i_buffer_length = 6
											, ovar_delimiter_line = _delimiter_line)
	%put &RSU_G_MSG_INDENT_PLANE.&_delimiter_line.;
	%Prv_RSULogger_PutMultLine(i_msg = %nrbquote(&_parms.)
										, i_header = %str( )&RSU_G_MSG_INDENT_PLANE.)
	%put &RSU_G_MSG_INDENT_PLANE.&_delimiter_line.;
%mend RSULogger__PutParagraph;

/*<FunctionDesc ja_jp>Blockログを出力します（現在の出力先）</FunctionDesc ja_jp>*/
%macro RSULogger__PutBlock(
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
									i_msg
									) / parmbuff;
	%local _parms;
	%let _parms = %qsubstr(&syspbuff., 2, %length(&syspbuff.) - 2);
	%local _delimiter_line;
	%Prv_RSULogger_GetDelimiterLine(i_msg = %nrbquote(&_parms.)
											, i_char = -
											, ovar_delimiter_line = _delimiter_line)
	%put &RSU_G_MSG_INDENT_PLANE.&_delimiter_line.;
	%Prv_RSULogger_PutMultLine(i_msg = %nrbquote(&_parms.)
										, i_header = %str( )&RSU_G_MSG_INDENT_PLANE.)
	%put &RSU_G_MSG_INDENT_PLANE.&_delimiter_line.;
	%put;
%mend RSULogger__PutBlock;

/*<FunctionDesc ja_jp>条件が満たされた場合のみログを出力します（現在の出力先） </FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export log only when the conditions are met（Current destination） </FunctionDesc en_us>*/
%macro RSULogger__PutlogIf(
/*<FunctionArgDesc ja_jp>条件評価結果（1の場合にログが表示されます）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Evaluation result（Log is displayed when the result is 1）</FunctionArgDesc en_us>*/
									i_eval_result
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
									, i_msg
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_eval_result)
	%if (&i_eval_result.) %then %do;
		%Prv_RSULogger_OutputMsg(i_msg = &i_msg.
										, i_msg_header_key = HEADER_PLANE
										, i_log_type = &RSU_G_MSG_INDENT_PLANE.)
	%end;
%mend RSULogger__PutlogIf;

/*<FunctionDesc ja_jp>条件が満たされた場合のみログを出力します （デフォルト出力先）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export log only when the conditions are met（Default destination） </FunctionDesc en_us>*/
%macro RSULogger__PrintlogIf(
/*<FunctionArgDesc ja_jp>条件評価結果（1の場合にログが表示されます）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Evaluation result（Log is displayed when the result is 1）</FunctionArgDesc en_us>*/
									i_eval_result
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
									, i_msg
									);
	proc printto;
	run;
	quit;
	%RSULogger__PutlogIf(i_eval_result = &i_eval_result.
								, i_msg = &i_msg.)
	%RSULogger__SetDestination(i_file_path = &RSU_g_current_log_dest.)
%mend RSULogger__PrintlogIf;

/*<FunctionDesc ja_jp>条件が満たされた場合のみエラーログを出力します（現在の出力先） </FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export log only when the conditions are met（Current destination） </FunctionDesc en_us>*/
%macro RSULogger__PutErrorIf(
/*<FunctionArgDesc ja_jp>条件評価結果（1の場合にログが表示されます）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Evaluation result（Log is displayed when the result is 1）</FunctionArgDesc en_us>*/
									i_eval_result
/*<FunctionArgDesc ja_jp>メッセージ</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Message</FunctionArgDesc en_us>*/
									, i_msg
/*<FunctionArgDesc ja_jp>ログ表示後の処理（abortの引数。 'none': 停止しない）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Procedure after displaying the log（1: Continue 0：Terminate、-1：Disconnect）</FunctionArgDesc en_us>*/
									, i_abort =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_eval_result)
	%if (&i_eval_result.) %then %do;
		%RSULogger__PutError(i_msg = &i_msg.
									, i_abort = &i_abort.)
	%end;
%mend RSULogger__PutErrorIf;