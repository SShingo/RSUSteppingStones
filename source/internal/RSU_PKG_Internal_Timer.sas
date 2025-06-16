%macro Int_RSU_Timer_CalcTimeInterval(i_time_from =
													, i_time_to =);
	%local /readonly _INTERVAL = %sysevalf(&i_time_to. - &i_time_from.);
	%sysfunc(putn(&_INTERVAL., TIME))
%mend Int_RSU_Timer_CalcTimeInterval;