/***********************************************************************************
* PROGRAM NAME : RSU_PKG_Timer.sas
* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
* DATE WRITTEN : 2021/2/22
*
************************************************************************************/
/*<PackageID>RSUTimer</PackageID>*/
/*<CategoryID>Cate_DebuggingAndLogging</CategoryID>*/
/*<PackagePurpose ja_jp>タイマー</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Timer</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>処理の経過時間を計測するタイマー機能に係るマクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions of a timer</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>タイマーパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Timer Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSUTimer, RSUTimer__)

/*<FunctionDesc ja_jp>プロセスを一時停止します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Pause the process</FunctionDesc en_us>*/
%macro RSUTimer__Sleep(
/*<FunctionArgDesc ja_jp>停止期間を整数で与えます（単位時間間隔に対する乗数）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Gives the pause period as an integer(multiplier for unit time interval)</FunctionArgDesc en_us>*/
							i_count
/*<FunctionArgDesc ja_jp>時間単位を10のべき乗の秒単位で与えます</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Gives the unit of time in seconds to the power of 10</FunctionArgDesc en_us>*/
							, i_unit = 1
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_count)
	%local /readonly _RSU_TIMER_TMP_SLEEPING = %sysfunc(sleep(&i_count., &i_unit.));
%mend RSUTimer__Sleep;

/*<FunctionDesc ja_jp>現在時刻を返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the current time</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>現在時刻（YYYY/MM/DD HH:mm:SS形式）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Current time（YYYY/MM/DD HH:mm:SS format）</FunctionReturn en_us>*/
%macro RSUTimer__GetNow(
/*<FunctionArgDesc ja_jp>文字列をフォーマッティングするか</FunctionArgDesc ja_jp>*/
								i_is_formatted = %&RSUBool.True
								);
	%local /readonly _RSU_TIMER_NOW = %sysfunc(datetime());
	%local /readonly _RSU_TIMER_TMP_DATE_PART = %sysfunc(datepart(&_RSU_TIMER_NOW.));
	%local /readonly _RSU_TIMER_TMP_TIME_PART = %sysfunc(timepart(&_RSU_TIMER_NOW.));
	%local /readonly _RSU_TIMER_TIME_FORMATTED = %sysfunc(putn(&_RSU_TIMER_TMP_TIME_PART., time));
	%if (&i_is_formatted.) %then %do;
		%local /readonly _RSU_TIMER_DATE_FORMATTED = %sysfunc(putn(&_RSU_TIMER_TMP_DATE_PART., yymmdds10));
		&_RSU_TIMER_DATE_FORMATTED. &_RSU_TIMER_TIME_FORMATTED.
	%end;
	%else %do;
		%local /readonly _RSU_TIMER_DATE_UNFORMATTED = %sysfunc(putn(&_RSU_TIMER_TMP_DATE_PART., yymmddn8));
		%local /readonly _RSU_TIMER_TIME_UNFORMATTED = %sysfunc(compress(&_RSU_TIMER_TIME_FORMATTED, :));
		&_RSU_TIMER_DATE_UNFORMATTED.&_RSU_TIMER_TIME_UNFORMATTED.
	%end;
%mend RSUTimer__GetNow;

/*<FunctionDesc ja_jp>現在時刻のタイムスタンプ返します（YYYYMMDDHHmmSS形式）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the current timestamp (YYYYMMDDHHmmSS format)</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>現在時刻のタイムスタンプ（YYYYMMDDHmmMSS形式）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Current timestamp（YYYYMMDDHHmmSS format）</FunctionReturn en_us>*/
%macro RSUTimer__GetTimeStamp();
	%local /readonly _RSU_TIMER_NOW = %sysfunc(datetime());
	%local /readonly _TIMESTAMP = %sysfunc(nldatm(&_RSU_TIMER_NOW., %nrbquote(%)Y%nrbquote(%)m%nrbquote(%)D%nrbquote(%)H%nrbquote(%)M%nrbquote(%)S));
	&_TIMESTAMP.
%mend RSUTimer__GetTimeStamp;

/*<FunctionDesc ja_jp>タイマーインスタンスを作成します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Create a Timer instance</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>生成されたタイマーインスタンスのインスタンスID</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Generated instance's ID</FunctionReturn en_us>*/
%macro RSUTimer__Start(
/*<FunctionArgDesc ja_jp>生成時にメッセージを表示するか否か</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Whether to display a message after generation or not</FunctionArgDesc en_us>*/
								i_show_message = %&RSUBool.True
								);
	%local /readonly _TIMER_ID = %Prv_RSUClass_CreateInstance(i_prefix = TM
																				, i_sequence_var = RSU_g_sequence_timer);
	%local /readonly _TIMER_NOW = %sysfunc(datetime());
	%global &_TIMER_ID._lap;
	%let &_TIMER_ID._lap = 0;
	%global &_TIMER_ID._start;
	%let &_TIMER_ID._start = &_TIMER_NOW.;
	%global &_TIMER_ID._prev;
	%let &_TIMER_ID._prev = &_TIMER_NOW.;
	%if (&i_show_message.) %then %do;
		%&RSULogger.PutParagraph(%&RSUMsg.TIMER_START %RSUTimer__GetNow())
	%end;
	&_TIMER_ID.
%mend RSUTimer__Start;

/*<FunctionDesc ja_jp>ラップタイムを表示します</FunctionDesc ja_jp>*/
%macro RSUTimer__Lap(
/*<FunctionArgDesc ja_jp>タイマーIDを保持する変数</FunctionArgDesc ja_jp>*/
							ivar_timer
/*<FunctionArgDesc ja_jp>メッセージを表示するか否か</FunctionArgDesc ja_jp>*/
							, i_show_message = %&RSUBool.True
/*<FunctionArgDesc ja_jp>ラップタイムを受け取る変数</FunctionArgDesc ja_jp>*/
							, ovar_lap_time =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_timer)
	%local /readonly _TIMRE_ID_LAP = &&&ivar_timer.;
	%if (%&RSUMacroVariable.IsBlank(&_TIMRE_ID_LAP._start)) %then %do;
		%&RSULogger.PutError(%&RSUMsg.TIMER_NOTSTART
								, i_abort = cancel)
	%end;
	%local /readonly _TIMER_NOW = %sysfunc(datetime());
	%local /readonly _LAP_TIME_FMT = %Int_RSU_Timer_CalcTimeInterval(i_time_from = &&&_TIMRE_ID_LAP._prev., i_time_to = &_TIMER_NOW.);
	%local /readonly _TOTAL_TIME_FMT = %Int_RSU_Timer_CalcTimeInterval(i_time_from = &&&_TIMRE_ID_LAP._start., i_time_to = &_TIMER_NOW.);
	%let &_TIMRE_ID_LAP._lap = %eval(&&&_TIMRE_ID_LAP._lap. + 1);
	%let &_TIMRE_ID_LAP._prev = &_TIMER_NOW.;
	%if (&i_show_message.) %then %do;
		%&RSULogger.PutInfo(%&RSUMsg.TIMER_LAP_TIME(&&&_TIMRE_ID_LAP._lap., &_LAP_TIME_FMT.)%str(	)%&RSUMsg.TIMER_TOTAL_TIME(&_TOTAL_TIME_FMT.))
	%end;
	%if (not %&RSUMacroVariable.IsBlank(ovar_lap_time)) %then %do;
		%let &ovar_lap_time. = &_LAP_TIME_FMT.;
	%end;
%mend RSUTimer__Lap;

/*<FunctionDesc ja_jp>タイマーを停止し、経過時間を表示します</FunctionDesc ja_jp>*/
%macro RSUTimer__Stop(
/*<FunctionArgDesc ja_jp>タイマーIDを保持する変数</FunctionArgDesc ja_jp>*/
							ivar_timer
/*<FunctionArgDesc ja_jp>メッセージを表示するか否か</FunctionArgDesc ja_jp>*/
							, i_show_message = %&RSUBool.True
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_timer)
	%local /readonly _TIMRE_ID_STOP = &&&ivar_timer.;
	%let &_TIMRE_ID_STOP._lap = %eval(&&&_TIMRE_ID_STOP._lap. + 1);
	%local /readonly _TIMER_NOW = %sysfunc(datetime());
	%local /readonly _LAP_TIME_FMT = %Int_RSU_Timer_CalcTimeInterval(i_time_from = &&&_TIMRE_ID_STOP._prev., i_time_to = &_TIMER_NOW.);
	%local /readonly _TOTAL_TIME_FMT = %Int_RSU_Timer_CalcTimeInterval(i_time_from = &&&_TIMRE_ID_STOP._start., i_time_to = &_TIMER_NOW.);
	%if (&i_show_message.) %then %do;
		%&RSULogger.PutParagraph(%&RSUMsg.TIMER_STOP %RSUTimer__GetNow()
										, %&RSUMsg.TIMER_LAP_TIME(&&&_TIMRE_ID_STOP._lap., &_LAP_TIME_FMT.)%str(	)%&RSUMsg.TIMER_TOTAL_TIME(&_total_time_fmt.))
	%end;
	%&RSUMacroVariable.Delete(i_regex = /^&_TIMRE_ID_STOP._/i)
%mend RSUTimer__Stop;
