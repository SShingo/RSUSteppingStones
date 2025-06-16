/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_DSIterator.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/3/7
/************************************************************************************/
/*<PackageID>RSUDSIterator</PackageID>*/
/*<CategoryID>Cate_DataHandling</CategoryID>*/
/*<PackagePurpose ja_jp>データセットイテレータ</PackagePurpose ja_jp>*/
/*<PackageDesc ja_jp>SAS データセットの反復子を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions of dataset iterator</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>データセットイテレータパッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUDSIterator, RSUDSIter__)

/*******************************************/
/* Public Macros
/*******************************************/
/*<FunctionDesc ja_jp>データセットイテレータを生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>データセットイテレータID</FunctionReturn ja_jp>*/
%macro RSUDSIter__Create(
/*<FunctionArgDesc ja_jp>クエリ</FunctionArgDesc ja_jp>*/
								i_query
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query)
	%local /readonly _DSITER_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = DI
																							, i_sequence_var = RSU_g_sequence_dataset_iterator);
	%global &_DSITER_ID_CREATE._dsid;
	%let &_DSITER_ID_CREATE._dsid = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&i_query., IN)));
	%global &_DSITER_ID_CREATE._index;
	%let &_DSITER_ID_CREATE._index = 0;
	%global &_DSITER_ID_CREATE._term;
	%global &_DSITER_ID_CREATE._prev_by;
	%RSUDSIter__Reset(_DSITER_ID_CREATE)
	&_DSITER_ID_CREATE.
%mend RSUDSIter__Create;

/*<FunctionDesc ja_jp>データセットイテレータを破棄します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Dispose dataset iterator</FunctionDesc en_us>*/
%macro RSUDSIter__Dispose(
/*<FunctionArgDesc ja_jp>データセットイテレータIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_dsiterator
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_dsiterator)
	%RSUDSIter__Close(&ivar_dsiterator)
	%local /readonly _DSITER_ID_DISPOSE = &&&ivar_dsiterator.;
	%&RSUMacroVariable.Delete(i_regex = /^&_DSITER_ID_DISPOSE._/i)
%mend RSUDSIter__Dispose;

/*<FunctionDesc ja_jp>データセットイテレータをリセットします</FunctionDesc ja_jp>*/
%macro RSUDSIter__Reset(
/*<FunctionArgDesc ja_jp>データセットイテレータIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_dsiterator
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_dsiterator)
	%local /readonly _DSITER_ID_RESET = &&&ivar_dsiterator.;
   %Int_RSUUtil_VerifyRC(i_rc = %sysfunc(rewind(&&&_DSITER_ID_RESET._dsid.)))
	%let &_DSITER_ID_RESET._index = 0;
	%let &_DSITER_ID_RESET._term = %&RSUBool.False;
%mend RSUDSIter__Reset;

%macro RSUDSIter__Close(
								ivar_dsiterator
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_dsiterator)
	%if (%RSUDSIter__IsOpen(&ivar_dsiterator.)) %then %do;
		%local /readonly _DSITER_ID_CLOSE = &&&ivar_dsiterator.;
		%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&&&_DSITER_ID_CLOSE._dsid.)))
		%let &_DSITER_ID_CLOSE._index =;
		%let &_DSITER_ID_CLOSE._dsid =;
	%end;
%mend RSUDSIter__Close;

/*<FunctionDesc ja_jp>データセットイテレータの基データセットが開いているか否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>1: 開いている、0: 閉じている</FunctionReturn ja_jp>*/
%macro RSUDSIter__IsOpen(
/*<FunctionArgDesc ja_jp>データセットイテレータIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_dsiterator
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_dsiterator)
	%local /readonly _DSITER_ID_ISOPEN = &&&ivar_dsiterator.;
	%eval(not %&RSUMacroVariable.IsBlank(&_DSITER_ID_ISOPEN._dsid))
%mend RSUDSIter__IsOpen;

/*<FunctionDesc ja_jp>データセットイテレータの基データセットが開いているか否かを検証します（開いていない場合エラー）</FunctionDesc ja_jp>*/
%macro RSUDSIter__VerifyOpen(ivar_dsiterator);
	%if (not %RSUDSIter__IsOpen(&ivar_dsiterator.)) %then %do;
		%&RSULogger.PutError(Dataset iterator fail. Dataset is not open
									, i_abort = cancel)
	%end;
%mend RSUDSIter__VerifyOpen;

/*<FunctionDesc ja_jp>データセットイテレータの現在値を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>現在値</FunctionReturn ja_jp>*/
%macro RSUDSIter__Current(
/*<FunctionArgDesc ja_jp>データセットイテレータIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_dsiterator
/*<FunctionArgDesc ja_jp>変数名（省略時は最初の変数）</FunctionArgDesc ja_jp>*/
								, i_variable
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_dsiterator)
	%RSUDSIter__VerifyOpen(&ivar_dsiterator.)
	%local /readonly _DSITER_ID_GET = &&&ivar_dsiterator.;
	%if (&&&_DSITER_ID_GET._index = 0) %then %do;
		%&RSULogger.PutError(Dataset iterator fail. Iterator not started
									, i_abort = cancel)
	%end;
	%local _result;
	%if (%&RSUMacroVariable.IsBlank(i_variable)) %then %do;
		%let _result = %sysfunc(RSU_fcmp_get_curr_by_num(&&&_DSITER_ID_GET._dsid., 1));
	%end;
	%else %do;
		%let _result = %sysfunc(fcmp_rsu_ds_get_curr_by_name(&&&_DSITER_ID_GET._dsid., &i_variable.));
	%end;
	&_result.
%mend RSUDSIter__Current;

/*<FunctionDesc ja_jp>データセットイテレータの現在のインデックスを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>現在のインデックス</FunctionReturn ja_jp>*/
%macro RSUDSIter__Index(
/*<FunctionArgDesc ja_jp>データセットイテレータIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_dsiterator
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_dsiterator)
	%RSUDSIter__VerifyOpen(&ivar_dsiterator.)
	&_DSITER_ID_GET._index
%mend RSUDSIter__Index;

/*<FunctionDesc ja_jp>データセットイテレータを進めます</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>1: 成功、0: 失敗（終了）</FunctionReturn ja_jp>*/
%macro RSUDSIter__Next(
/*<FunctionArgDesc ja_jp>データセットイテレータIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_dsiterator
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_dsiterator)
	%local /readonly _DSITER_ID_NEXT = &&&ivar_dsiterator.;
	%if (&&&_DSITER_ID_NEXT._term.) %then %do;
		%let &_DSITER_ID_NEXT._term = %&RSUBool.False;
		%&RSUBool.False
		%return;
	%end;
	%RSUDSIter__VerifyOpen(&ivar_dsiterator.)
	%local /readonly _RC_DSITER_NEXT = %sysfunc(fetch(&&&_DSITER_ID_NEXT._dsid.));
	%if (&_RC_DSITER_NEXT. ne 0 and &_RC_DSITER_NEXT. ne -1) %then %do;
		%&RSULogger.PutError(%&RSUMsg.SYS_ERROR(%sysfunc(sysmsg()), &_RC_DSITER_NEXT.)
									, i_abort = cancel)
	%end;
	%let &_DSITER_ID_NEXT._index  = %eval(&&&_DSITER_ID_NEXT._index. + 1);
	%eval(&_RC_DSITER_NEXT. = 0)
%mend RSUDSIter__Next;

/*<FunctionDesc ja_jp>データセットイテレータを進めます（グループ毎）</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>1: 成功、0: 失敗（終了）</FunctionReturn ja_jp>*/
%macro RSUDSIter__NextBy(
/*<FunctionArgDesc ja_jp>データセットイテレータIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_dsiterator
/*<FunctionArgDesc ja_jp>グループ変数</FunctionArgDesc ja_jp>*/
								, i_by_variable
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_dsiterator)
	%local /readonly _DSITER_ID_NEXT = &&&ivar_dsiterator.;
	%if (&&&_DSITER_ID_NEXT._term.) %then %do;
		%let &_DSITER_ID_NEXT._term = %&RSUBool.False;
		%&RSUBool.False
		%return;
	%end;
	%RSUDSIter__VerifyOpen(&ivar_dsiterator.)

	%if (&_DSITER_ID_NEXT._index = 0) %then %do;
		%let &_DSITER_ID_NEXT._prev_by =;
	%end;
	
	%local _rc_fetch;	
	%let _rc_fetch = 0;
	%local _is_in_same_by;
	%let _is_in_same_by = %&RSUBool.True;
	%do %while(&_rc_fetch. = 0 and &_is_in_same_by.);
		%let _rc_fetch = %sysfunc(fetch(&&&_DSITER_ID_NEXT._dsid.));
		%if (&_rc_fetch. ne 0 and &_rc_fetch. ne -1) %then %do;
			%&RSULogger.PutError(%&RSUMsg.SYS_ERROR(%sysfunc(sysmsg()), &_RC_DSITER_NEXT.)
										, i_abort = cancel)
		%end;
		%let &_DSITER_ID_NEXT._index  = %eval(&&&_DSITER_ID_NEXT._index. + 1);
		%let _by_current = %sysfunc(fcmp_rsu_ds_get_curr_by_name(&&&_DSITER_ID_NEXT._dsid., &i_by_variable.));
		%if ("&_by_current." ne "&&&_DSITER_ID_NEXT._prev_by") %then %do;
			%let &_DSITER_ID_NEXT._prev_by = &_by_current.;
			%let _is_in_same_by = %&RSUBool.False;
		%end;
	%end;
	%eval(&_rc_fetch. = 0)
%mend RSUDSIter__NextBy;

/*<FunctionDesc ja_jp>データセットイテレータを強制終了します</FunctionDesc ja_jp>*/
%macro RSUDSIter__Terminate(
/*<FunctionArgDesc ja_jp>データセットイテレータIDを保持する変数名</FunctionArgDesc ja_jp>*/
									ivar_dsiterator
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_dsiterator)
	%local /readonly _DSITER_ID_TERMINATE = &&&ivar_dsiterator.;
	%if (%RSUDSIter__IsOpen(&ivar_dsiterator.)) %then %do;
		%RSUDSIter__Close(&ivar_dsiterator.)
		%let &_DSITER_ID_TERMINATE._term = %&RSUBool.True;
	%end;
%mend RSUDSIter__Terminate;
