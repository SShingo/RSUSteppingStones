
/*-------------------------------------*/
/* Internal: 接続検証
/*-------------------------------------*/
%macro Int_RSURESTAPI_VerifyConnected(ivar_restapi);
	%local /readonly _RESTAPI_ID_VERIFYCONNECTED = &&&ivar_restapi.;
	%if (%&RSUMacroVariable.IsBlank(&_RESTAPI_ID_VERIFYCONNECTED._access_token)) %then %do;
		%&RSULogger.PutError(REST API not connected to server "&&&_RESTAPI_ID_VERIFYCONNECTED._server_url", i_abort = none)
		%abort;
	%end;
%mend Int_RSURESTAPI_VerifyConnected;

%macro Int_RSURESTAPI_PrepareFile(ifref_result =
											, ovar_filename_header =
											, ovar_filename_response =);
	%if (%&RSUMacroVariable.IsBlank(ifref_result)) %then %do;
		filename _f_res temp;
		%let &ovar_filename_response. = _f_res;
	%end;
	%else %do;
		%let &ovar_filename_response. = &ifref_result.;
	%end;
	filename _f_hder temp;
	%let &ovar_filename_header. = _f_hder;
%mend Int_RSURESTAPI_PrepareFile;

%macro Int_RSURESTAPI_CloseFile(ifref_result =
										, i_filename_header =
										, i_filename_response =);
	filename &i_filename_header. clear;
	%if (%&RSUMacroVariable.IsBlank(ifref_result)) %then %do;
		filename &i_filename_response. clear;
	%end;
%mend Int_RSURESTAPI_CloseFile;

/*-------------------------------------*/
/* Internal: Response処理
/*-------------------------------------*/
%macro Int_RSURESTAPI_PostProcess(ifref_output_hdr =
											, ifref_output_res =
											, i_body =
											, i_working_dir =
											, i_libname =
											, ovar_is_succeeded =);
	%Int_RSURESTAPI_GetReponseResult(ifref_hdr = &ifref_output_hdr.
												, ifref_res = &ifref_output_res.
												, i_body = &i_body.
												, i_working_dir = &i_working_dir.
												, ovar_is_succeeded = &ovar_is_succeeded.)
	%if (not &&&ovar_is_succeeded.) %then %do;
		%return;
	%end;
	%if (not %&RSUMacroVariable.IsBlank(i_libname)) %then %do;
		libname &i_libname. json fileref = &ifref_output_res.;
	%end;
%mend Int_RSURESTAPI_PostProcess;

/*-------------------------------------*/
/* Internal: Response検証
/*-------------------------------------*/
%macro Int_RSURESTAPI_GetReponseResult(ifref_hdr =
													, ifref_res =
													, i_body =
													, i_working_dir =
													, ovar_is_succeeded =);
	%local __get_respoonse_response_code;
	data _null_;
		infile &ifref_hdr. delimiter = &RSUNULL.;
		attrib
			line length = $100.
			responce_code length = 8.
			is_success length = 8;
		;
		input line;
		_regex_response = prxparse('/^HTTP\/1\.1 (\d{3})/i');
		if (prxmatch(_regex_response, trim(line))) then do;
			responce_code = input(prxposn(_regex_response, 1, trim(line)), BEST.);
			is_success = (200 <= responce_code and responce_code < 300);
			call symputx('__get_respoonse_response_code', responce_code);
			call symputx("&ovar_is_succeeded.", is_success);
		end;
		stop;
	run;
	quit;
	%if (not &&&ovar_is_succeeded.) %then %do;
		%&RSULogger.PutError(REST API Returns Error!(&__get_respoonse_response_code.), i_abort = none)
		%if (not %&RSUMacroVariable.IsBlank(i_working_dir)) %then %do;
			%local /readonly __RESTAPI_TIMESTAMP = %&RSUTimer.GetTimeStamp();
			%local /readonly __GET_HEADER_FILE_PATH = &i_working_dir./REST_&i_body._&__RESTAPI_TIMESTAMP._HEADER.txt;
			filename f_dest "&__GET_HEADER_FILE_PATH.";
			data _null_;
				_rc = fcopy("&ifref_hdr.", 'f_dest');
			run;
			quit;
			filename f_dest clear;
			%local /readonly __GET_RESPONSE_FILE_PATH = &i_working_dir./REST_&i_body._&__RESTAPI_TIMESTAMP._RESPONSE.txt;
			filename f_dest "&__GET_RESPONSE_FILE_PATH.";
			data _null_;
				_rc = fcopy("&ifref_res.", 'f_dest');
			run;
			quit;
			filename f_dest clear;
			%&RSULogger.PutInfo(i_msg = Server Response is copied to: &__GET_HEADER_FILE_PATH. and &__GET_RESPONSE_FILE_PATH.)
		%end;
	%end;
	%else %do;
		%&RSULogger.PutInfo(Calling REST API scceeded.(&__get_respoonse_response_code.))
	%end;
%mend Int_RSURESTAPI_GetReponseResult;
