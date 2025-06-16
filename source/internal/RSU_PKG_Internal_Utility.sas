%macro Int_RSUUtil_VerifyRC(i_rc =);
	%if (&i_rc. ne 0) %then %do;
		%local /readonly _MSG = %sysfunc(sysmsg());
		%&RSULogger.PutError(%&RSUMsg.SYS_ERROR(%nrbquote(&_MSG.), &i_rc.)
									, i_abort = cancel)
	%end;
	%&RSUDebug.PutLog(Return code has been verified.)
%mend Int_RSUUtil_VerifyRC;

%macro Int_RSUUtil_VerifyID(i_id =);
	%if (&i_id. <= 0) %then %do;
		%local /readonly _MSG = %sysfunc(sysmsg());
		%&RSULogger.PutError(%&RSUMsg.SYS_ERROR(%nrbquote(&_MSG.), &i_id.)
									, i_abort = cancel)
	%end;
	%&RSUDebug.PutLog(ID has been verified.)
	&i_id.
%mend Int_RSUUtil_VerifyID;