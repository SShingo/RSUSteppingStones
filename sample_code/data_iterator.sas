%rsu_steppingstones_activate()


%macro RSUDSIter__Create(i_query);
	%local /readonly _DSITER_ID_RESET_CREATE = %&RSUUtil.GetSequenceId(i_prefix = g_RSU_INST_DSI_
																							, iovar_sequence = RSU_g_sequence_library
																							, i_digit = 4);
	%local _dsid;
	%local _rc_ds;
	%global &_DSITER_ID_RESET_CREATE._dsid;
	%global &_DSITER_ID_RESET_CREATE._indx;
	%global &_DSITER_ID_RESET_CREATE._isterm;
	%let &_DSITER_ID_RESET_CREATE._dsid = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&i_query., IN)));
	%put open &&&_DSITER_ID_RESET_CREATE._dsid.;
	%RSUDSIter__Reset(_DSITER_ID_RESET_CREATE)
	&_DSITER_ID_RESET_CREATE.
%mend RSUDSIter__Create;

%macro RSUDSIter__Dispose(ivar_dsiterator);
	%local /readonly _DSITER_ID_DISPOSE = &&&ivar_dsiterator.;
	%Dispose(&_DSITER_ID_DISPOSE.)
%mend RSUDSIter__Dispose;

%macro RSUDSIter__Reset(ivar_dsiterator);
	%put Reset;
	%local /readonly _DSITER_ID_RESET = &&&ivar_dsiterator.;
	%let &_DSITER_ID_RESET._indx = 0;
   %Int_RSUUtil_VerifyRC(i_rc = %sysfunc(rewind(&&&_DSITER_ID_RESET._dsid.)))
%mend RSUDSIter__Reset;

%macro RSUDSIter__Close(ivar_dsiterator);
	%put close;
	%if (%RSUDSIter__IsOpen(&ivar_dsiterator.)) %then %do;
		%local /readonly _DSITER_ID_CLOSE = &&&ivar_dsiterator.;
		%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&&&_DSITER_ID_CLOSE._dsid.)))
		%let &_DSITER_ID_CLOSE._indx =.;
		%let &_DSITER_ID_CLOSE._dsid =;
	%end;
%mend RSUDSIter__Close;

%macro RSUDSIter__IsOpen(ivar_dsiterator);
	%local /readonly _DSITER_ID_ISOPEN = &&&ivar_dsiterator.;
	%eval(not %&RSUMacroVariable.IsBlank(&_DSITER_ID_ISOPEN._dsid))
%mend RSUDSIter__IsOpen;

%macro RSUDSIter__Next(ivar_dsiterator);
	%if (not %RSUDSIter__IsOpen(&ivar_dsiterator.)) %then %do;
		%&RSULogger.PutError(Dataset iterator faile. Dataset is not open
									, i_abort = cancel)
	%end;
	%local /readonly _DSITER_ID_NEXT = &&&ivar_dsiterator.;
	%local /readonly _RC = %sysfunc(fetch(&&&_DSITER_ID_NEXT._dsid.));
	%if (&_RC. ne 0 and &_RC. ne -1) %then %do;
		%&RSULogger.PutError(%&RSUMsg.SYS_ERROR(%sysfunc(sysmsg()), &_RC.)
									, i_abort = cancel)
	%end;
	%let &_DSITER_ID_NEXT._indx  = %eval(&&&_DSITER_ID_NEXT._indx. + 1);
	%&RSUUtil.Choose(%eval(&_RC. = 0), %&RSUBool.True, %&RSUBool.False)
%mend RSUDSIter__Next;

%macro RSUDSIter__Current(ivar_dsiterator_info);
	%local _regex_dsrow;
	%let _regex_dsrow = %sysfunc(prxparse(/^(\w+)\[(\w+)\]$/));
	%local /readonly _MATCHED = %sysfunc(prxmatch(&_regex_dsrow., &ivar_dsiterator_info.));
	%local _dsiterator;
	%let _dsiterator = %sysfunc(prxposn(&_regex_dsrow., 1, &ivar_dsiterator_info.));
	%local _varname;
	%let _varname = %sysfunc(prxposn(&_regex_dsrow., 2, &ivar_dsiterator_info.));
	%if (not %RSUDSIter__IsOpen(&_dsiterator.)) %then %do;
		%&RSULogger.PutError(Dataset iterator faile. Dataset is not open
									, i_abort = cancel)
	%end;
	%local /readonly _DSITER_ID_GET = &&&_dsiterator.;
	%sysfunc(fcmp_rsu_ds_get_curr_by_name(&&&_DSITER_ID_GET._dsid., &_varname.))
%mend RSUDSIter__Current;

%macro RSUDSIter__Index(ivar_dsiterator);
	%local /readonly _DSITER_ID_INDEX = &&&ivar_dsiterator.;
	&&&_DSITER_ID_INDEX._indx.
%mend RSUDSIter__Index;

%macro test();
	data x;
		set SASHELP.class;
	run;

	%local /readonly _DS_ITERATOR = %RSUDSIter__Create(WORK.x(where = (14 < age)));
	%do %while(%RSUDSIter__Next(_DS_ITERATOR));
		%put %RSUDSIter__Index(_DS_ITERATOR) %RSUDSIter__Current(_DS_ITERATOR[name]);
	%end;
	%RSUDSIter__Close(_DS_ITERATOR)
%mend;
%test