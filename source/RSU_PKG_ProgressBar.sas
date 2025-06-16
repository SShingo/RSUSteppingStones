/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_ProgressBar.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/4/2
/*
/* <PkgParent>RSUCounter<PkgParent>
/************************************************************************************/
/*<PackageID>RSUProgressBar</PackageID>*/
/*<CategoryID>Cate_DebuggingAndLogging</CategoryID>*/
/*<PackagePurpose ja_jp>プログレスバー</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Progress bar</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>処理の進捗を状況を可視化するプログレスバー提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions of a progress bar</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>プログレスバーパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Progress Bar Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSUProgressBar, RSUPrgBar__)

/*<FunctionDesc ja_jp>プログレスバーインスタンスを作成します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Create a Progress bar instance</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>生成されたプログレスバーのインスタンスID</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Generated instance's ID</FunctionReturn en_us>*/
%macro RSUPrgBar__Create(
/*<FunctionArgDesc ja_jp>全処理数</FunctionArgDesc ja_jp>*/
								i_max_count
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_max_count)
	%local /readonly _PROGRESS_BAR_ID = %Prv_RSUClass_CreateInstance(i_prefix = PB
																						, i_sequence_var = RSU_g_sequence_prgbar);
	%global &_PROGRESS_BAR_ID._max_count;
	%let &_PROGRESS_BAR_ID._max_count = &i_max_count.;
	%global &_PROGRESS_BAR_ID._current_count;
	%let &_PROGRESS_BAR_ID._current_count = 0;
	%global &_PROGRESS_BAR_ID._progress;
	%let &_PROGRESS_BAR_ID._progress = 0;
	%global &_PROGRESS_BAR_ID._timer;
	%let &_PROGRESS_BAR_ID._timer = %&RSUTimer.Start(i_show_message = %&RSUBool.False);
	&_PROGRESS_BAR_ID.
%mend RSUPrgBar__Create;

/*<FunctionArgDesc ja_jp>現在の進捗状況を返します</FunctionArgDesc ja_jp>*/
%macro RSUPrgBar__GetStatus(
/*<FunctionArgDesc ja_jp>プログレスバーIDを保持する変数</FunctionArgDesc ja_jp>*/
									ivar_progress_bar
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_progress_bar)
	%local /readonly _PROGRESS_BAR_ID_GET_STATUS = &&&ivar_progress_bar.;
	&&&_PROGRESS_BAR_ID_GET_STATUS._progress
%mend RSUPrgBar__GetStatus;

/*<FunctionArgDesc ja_jp>プログレスバーを進行させます</FunctionArgDesc ja_jp>*/
%macro RSUPrgBar__Progress(
/*<FunctionArgDesc ja_jp>プログレスバーIDを保持する変数</FunctionArgDesc ja_jp>*/
									ivar_progress_bar
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_progress_bar)
	%local /readonly _PROGRESS_BAR_ID_PROGRESS = &&&ivar_progress_bar.;
	%let &_PROGRESS_BAR_ID_PROGRESS._current_count = %eval(&&&_PROGRESS_BAR_ID_PROGRESS._current_count. + 1);
	%local _tmp_progress;
	%let _tmp_progress = %eval(&&&_PROGRESS_BAR_ID_PROGRESS._progress. + 1);
	%do %while(%eval(&_tmp_progress. * &&&_PROGRESS_BAR_ID_PROGRESS._max_count.) < %eval(&&&_PROGRESS_BAR_ID_PROGRESS._current_count * 10));
		%let _tmp_progress = %eval(&_tmp_progress. + 1);
	%end;
	%local _is_progressed;
	%if (%eval(&&&_PROGRESS_BAR_ID_PROGRESS._current_count. * 10) < %eval(&_tmp_progress. * &&&_PROGRESS_BAR_ID_PROGRESS._max_count.)) %then %do;
		%let _is_progressed = %&RSUBool.False;
	%end;
	%else %do;
		%let &_PROGRESS_BAR_ID_PROGRESS._progress = &_TMP_PROGRESS.;
		%let _is_progressed = %&RSUBool.True;
	%end;
	%if (&_is_progressed.) %then %do;
		%ShowProgressBar(_PROGRESS_BAR_ID_PROGRESS)
	%end;
%mend RSUPrgBar__Progress;

/*<FunctionArgDesc ja_jp>プログレスバーを表示します</FunctionArgDesc ja_jp>*/
%macro ShowProgressBar(
/*<FunctionArgDesc ja_jp>プログレスバーIDを保持する変数</FunctionArgDesc ja_jp>*/
							ivar_progress_bar
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_progress_bar)
	%local /readonly _PROGRESS_BAR_ID_GET_ROGRESS_BAR = &&&ivar_progress_bar.;
	%local __tmp_progress_bar_view__;
	%local _progress;
	%do _progress = 1 %to &&&_PROGRESS_BAR_ID_GET_ROGRESS_BAR._progress;
		%&RSUText.Append(iovar_base = __tmp_progress_bar_view__
							, i_append_text = +
							, i_delimiter =)
	%end;
	%do _progress = %eval(&&&_PROGRESS_BAR_ID_GET_ROGRESS_BAR._progress + 1) %to 10;
		%&RSUText.Append(iovar_base = __tmp_progress_bar_view__
							, i_append_text = -
							, i_delimiter =)
	%end;
	%local _lap;
	%&RSUTimer.Lap(&_PROGRESS_BAR_ID_GET_ROGRESS_BAR._timer
						, i_show_message = %&RSUBool.False
						, ovar_lap_time = _lap)
	%local /readonly _PROGRESS_PERCENTAGE = %eval(&&&_PROGRESS_BAR_ID_GET_ROGRESS_BAR._progress * 10);
	%put Progress:[&__tmp_progress_bar_view__.](&&&_PROGRESS_BAR_ID_GET_ROGRESS_BAR._current_count. / &&&_PROGRESS_BAR_ID_GET_ROGRESS_BAR._max_count &_PROGRESS_PERCENTAGE.%nrbquote(%) &_lap.);
%mend ShowProgressBar;

/*<FunctionDesc ja_jp>プログレスバーを破棄します</FunctionDesc ja_jp>*/
%macro RSUPrgBar__Dispose(
/*<FunctionArgDesc ja_jp>プログレスバーIDを保持する変数</FunctionArgDesc ja_jp>*/
								ivar_progress_bar
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_progress_bar)
	%local /readonly _PROGRESS_BAR_ID_DISPOSE = &&&ivar_progress_bar.;
	%&RSUTimer.Stop(&_PROGRESS_BAR_ID_DISPOSE._timer
						, i_show_message = %&RSUBool.False)
	%&RSUMacroVariable.Delete(i_regex = /^&_PROGRESS_BAR_ID_DISPOSE._/i)
%mend RSUPrgBar__Dispose;