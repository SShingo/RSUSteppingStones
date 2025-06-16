%macro Prv_RSURest_ProcHttpHelper(i_method =
											, i_file_ref_header_in =
											, i_file_ref_header_out =
											, i_file_ref_in =
											, i_file_ref_out =
											, i_content_type =);
	method = "&i_method."
	%if (not %&RSUMacroVariable.IsBlank(i_file_ref_header_in)) %then %do;
		headerin = &i_file_ref_header_in.
	%end;
	headerout = &i_file_ref_header_out.
	%if (not %&RSUMacroVariable.IsBlank(i_file_ref_in)) %then %do;
		in = &i_file_ref_in.
	%end;
	out = &i_file_ref_out.
	%if (not %&RSUMacroVariable.IsBlank(i_content_type)) %then %do;
		ct = "&i_content_type."
	%end;
	clear_cache
	headerout_overwrite
%mend Prv_RSURest_ProcHttpHelper;

%macro Prv_RSURest_CreateInputFile(i_file_ref =
											, i_contents =);
	data _null_;
		attrib
			_contents length = $10000.
			_content length = $1000.
		;
		file &i_file_ref.;
		_index = 1;
		_contents = symget('i_contents');
		_content = scan(_contents, _index, '|');
		do while(0 < lengthn(_content));
			put _content;
			_index = _index + 1;
			_content = scan(_contents, _index, '|');
		end;
	run;
%mend Prv_RSURest_CreateInputFile;

%macro Int_RSURest_GetHTTPStatus(i_file_ref =
											, ovar_is_response_ok =
											, ovar_response_status =);
	%local _rc;
	%local _f_id;
	%let _f_id = %sysfunc(fopen(&i_file_ref.));
	%let _rc = %sysfunc(fsep(&_f_id., 7, x));
	%local _regex_res;
	%let _regex_res = %sysfunc(prxparse(/^HTTP\/1\.1\s+(\d+)/));
	%local _http_status;
	%let _http_status = NOTDEF;
	%local _line;
	%let _rc = %sysfunc(fread(&_f_id.));
	%do %while(&_rc. = 0 and &_http_status. eq NOTDEF);
		%let _rc = %sysfunc(fget(&_f_id., _line));
		%let _line = %quote(&_line.);

		%if (%sysfunc(prxmatch(&_regex_res., &_line.))) %then %do;
			%let _http_status = %sysfunc(prxposn(&_regex_res., 1, &_line.));
			%if (not %&RSUMacroVariable.IsBlank(ovar_response_status)) %then %do;
				%let &ovar_response_status. = &_line.;
			%end;
		%end;
		%let _rc = %sysfunc(fread(&_f_id.));
	%end;
	%let _rc = %sysfunc(fclose(&_f_id.));
	%syscall prxfree(_regex_res);

	%if (&_http_status. eq NOTDEF) %then %do;
		%put ERROR-No response from server.;
		%if (not %&RSUMacroVariable.IsBlank(ovar_is_response_ok)) %then %do;
			%let &ovar_is_response_ok. = 0;
		%end;
	%end;
	%else %if(&_http_status. < 200 or 300 <= &_http_status.) %then %do;
		%put ERROR-Fail to get tgt.;
		%if (not %&RSUMacroVariable.IsBlank(ovar_is_response_ok)) %then %do;
			%let &ovar_is_response_ok. = 0;
		%end;
	%end;
	%else %do;
		%put NOTE-OK!;
		%if (not %&RSUMacroVariable.IsBlank(ovar_is_response_ok)) %then %do;
			%let &ovar_is_response_ok. = 1;
		%end;
	%end;
	%let _rc = %sysfunc(fclose(&_f_id.));
%mend Int_RSURest_GetHTTPStatus;
