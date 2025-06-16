%macro Prv_RSUCounter_CalcHelper(i_index =
											, i_start =
											, i_step =
											, i_mod =
											, i_div =
											, i_intercept =);
	%local _current_index;
	%if (&i_div. = 1) %then %do;
		%let _current_index = &i_index.;
	%end;
	%else %do;
		%let _current_index = %eval(&i_index. / &i_div.);
	%end;
	%local _the_count;
	%let _the_count = %eval(&i_step. * &_current_index. + &i_start.);
	%if (&i_mod. ne 1) %then %do;
		%let _the_count = %sysfunc(mod(&_the_count., &i_mod.));
	%end;
	%let _the_count = %eval(&_the_count. + &i_intercept.);
	&_the_count.
%mend Prv_RSUCounter_CalcHelper;
