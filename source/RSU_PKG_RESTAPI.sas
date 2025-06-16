/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_REST_API.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/12/18
/*
/************************************************************************************/
/*<PackageID>RSURESTAPI</PackageID>*/
/*<CategoryID>Cate_Misc</CategoryID>*/
/*<PackagePurpose ja_jp>Rest API</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Rest API</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>Rest APIを操作するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating Rest API</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>Rest API パッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSURESTAPI, RSURESTAPI__)

/*<FunctionDesc ja_jp>REST APIオブジェクトを生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>REST APIオブジェクトID</FunctionReturn ja_jp>*/
%macro RSURESTAPI__Create(
/*<FunctionArgDesc ja_jp>サーバーURL</FunctionArgDesc ja_jp>*/
								i_server_url =
/*<FunctionArgDesc ja_jp>作業ディレクトリ</FunctionArgDesc ja_jp>*/
								, i_working_dir =);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_server_url)
	%local /readonly _REST_API_ID = %Prv_RSUClass_CreateInstance(i_prefix = RA
																					, i_sequence_var = RSU_g_sequence_rest_api);
	%global &_REST_API_ID._server_url;
	%let &_REST_API_ID._server_url = &i_server_url.;
	%global &_REST_API_ID._working_dir;
	%let &_REST_API_ID._working_dir = &i_working_dir.;
	%global &_REST_API_ID._access_token;
	&_REST_API_ID.
%mend RSURESTAPI__Create;

/*=======================================*/
/* 接続（Access Token取得）
/*=======================================*/
/*<FunctionDesc ja_jp>サーバーに接続します（Access Token取得）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Connect to server(Retrieve Access Token)</FunctionDesc ja_jp>*/
%macro RSURESTAPI__Connect(
/*<FunctionArgDesc ja_jp>REST APIオブジェクトIDを保持する変数名</FunctionArgDesc ja_jp>*/
									ivar_restapi
/*<FunctionArgDesc ja_jp>接続ユーザー</FunctionArgDesc ja_jp>*/
									, i_user =
/*<FunctionArgDesc ja_jp>パスワード</FunctionArgDesc ja_jp>*/
									, i_password =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_restapi i_user i_password)
	%local /readonly _RESTAPI_ID_CONNECT = &&&ivar_restapi.;
	%&RSULogger.PutNote(Connect to host "&&&_RESTAPI_ID_CONNECT._server_url.;")

	filename f_outres temp;
	filename f_outhdr temp;
	proc http 
			auth_basic
			url = "&&&_RESTAPI_ID_CONNECT._server_url./SASLogon/oauth/token"
			in = "grant_type=password%str(&)username=&i_user.%str(&)password=&i_password." 
			ct = "application/x-www-form-urlencoded"
			out = f_outres
			headerout = f_outhdr 
			method = 'POST'
			webusername = "sas.cli"
			webpassword = ""
		;
	run;
	quit;
	%local _is_succeded;
	%Int_RSURESTAPI_GetReponseResult(ifref_hdr = f_outhdr
												, ifref_res = f_outres
												, i_body = Connect
												, i_working_dir = &&&_RESTAPI_ID_CONNECT._working_dir
												, ovar_is_succeeded = _is_succeded)
	%if (not &_is_succeded.) %then %do;
		%&RSULogger.PutError(Failed to retreive access token(Access token is blank), i_abort = none);
		%abort;
	%end;
	filename f_outhdr temp;

	%global &_RESTAPI_ID_CONNECT._access_token;
	libname L_REST json fileref = f_outres;
	data _null_;
		set L_REST.alldata(where = (p1 = 'access_token'));
		call symputx("&_RESTAPI_ID_CONNECT._access_token", value, 'G');
		stop;
	run;
	quit;
	%if (%&RSUMacroVariable.IsBlank(&_RESTAPI_ID_CONNECT._access_token)) %then %do;
		%&RSULogger.PutError(Access token is blank. Failed to retreive access token, i_abort = none);
		%abort;
	%end;
	libname L_REST clear;
	filename f_outres temp;

	%local /readonly _SUMMARY_ACCESS_TOKEN = %substr(&&&_RESTAPI_ID_CONNECT._access_token., 1, 20);
	%local /readonly _LEN_ACCESS_TOKEN = %length(&&&_RESTAPI_ID_CONNECT._access_token.);
	%&RSULogger.PutInfo(Connection established)
	%&RSULogger.PutInfo(Access token:&_SUMMARY_ACCESS_TOKEN....(&_LEN_ACCESS_TOKEN. characters))
%mend RSURESTAPI__Connect;

/*=======================================*/
/* REST API オブジェクト破棄
/*=======================================*/
/*<FunctionDesc ja_jp>REST APIオブジェクトを破棄します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Dispose REST API object</FunctionDesc en_us>*/
%macro RSURESTAPI__Dispose(
/*<FunctionArgDesc ja_jp>REST APIオブジェクトIDを保持する変数名</FunctionArgDesc ja_jp>*/
									ivar_restapi
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_restapi)
	%local /readonly _RESTAPI_ID_DISPOSE = &&&ivar_restapi.;
	%&RSUMacroVariable.Delete(i_regex = /^&_RESTAPI_ID_DISPOSE._/i)
%mend RSURESTAPI__Dispose;

/*=================================*/
/* REST API Http Get
/*=================================*/
/*<FunctionDesc ja_jp>REST API Getメソッドを送信します</FunctionDesc ja_jp>*/
%macro RSURESTAPI__Get(
/*<FunctionArgDesc ja_jp>REST APIオブジェクトIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_restapi
							, i_url =
							, i_headers =
							, ifref_result =
							, i_libname =
							, ovar_is_succeeded =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_restapi i_url ovar_is_succeeded)
	%Int_RSURESTAPI_VerifyConnected(&ivar_restapi.)
	%&RSULogger.PutNote(Call REST API(Get): &i_url.)
	%local /readonly _RESTAPI_ID_HTTPGET = &&&ivar_restapi.;
	%local _fref_outhdr;
	%local _fref_outres;
	%Int_RSURESTAPI_PrepareFile(ovar_filename_header = _fref_outhdr
										, ovar_filename_response = _fref_outres
										, ifref_result = &ifref_result.)
	proc http
			oauth_bearer = "&&&_RESTAPI_ID_HTTPGET._access_token."
			url = "&&&_RESTAPI_ID_HTTPGET._server_url.&i_url."
			method = 'GET'
			out = &_fref_outres.
			headerout = &_fref_outhdr. 
		;
		%if (not %&RSUMacroVariable.IsBlank(i_headers)) %then %do;
		headers
			&i_headers.
		;
		%end;
	run;
	quit;
	%Int_RSURESTAPI_PostProcess(ifref_output_hdr = &_fref_outhdr. 
										, ifref_output_res = &_fref_outres.
										, i_body = Get
										, i_working_dir = &&&_RESTAPI_ID_HTTPGET._working_dir
										, i_libname = &i_libname.
										, ovar_is_succeeded = &ovar_is_succeeded.)
	%Int_RSURESTAPI_CloseFile(i_filename_header = &_fref_outhdr.
									, i_filename_response = &_fref_outres.
									, ifref_result = &ifref_result.)
%mend RSURESTAPI__Get;

/*=================================*/
/* REST API Http Put
/*=================================*/
/*<FunctionDesc ja_jp>REST API Putメソッドを送信します</FunctionDesc ja_jp>*/
%macro RSURESTAPI__Put(
/*<FunctionArgDesc ja_jp>REST APIオブジェクトIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_restapi
							, i_url =
							, i_headers =
							, ifref_input =
							, ifref_result =
							, i_libname =
							, ovar_is_succeeded =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_restapi i_url ovar_is_succeeded)
	%Int_RSURESTAPI_VerifyConnected(&ivar_restapi.)
	%&RSULogger.PutNote(Call REST API(Put): &i_url.)
	%local /readonly _RESTAPI_ID_HTTPGET = &&&ivar_restapi.;
	%local _fref_outhdr;
	%local _fref_outres;
	%Int_RSURESTAPI_PrepareFile(ovar_filename_header = _fref_outhdr
										, ovar_filename_response = _fref_outres
										, ifref_result = &ifref_result.)
	proc http
			oauth_bearer = "&&&_RESTAPI_ID_HTTPGET._access_token."
			url = "&&&_RESTAPI_ID_HTTPGET._server_url.&i_url."
			method = 'PUT'
			in = &ifref_input.
			out = &_fref_outres.
			headerout = &_fref_outhdr. 
		;
		%if (not %&RSUMacroVariable.IsBlank(i_headers)) %then %do;
		headers
			&i_headers.
		;
		%end;
	run;
	quit;
	%Int_RSURESTAPI_PostProcess(ifref_output_hdr = &_fref_outhdr. 
										, ifref_output_res = &_fref_outres.
										, i_body = Post
										, i_working_dir = &&&_RESTAPI_ID_HTTPGET._working_dir
										, i_libname = &i_libname.
										, ovar_is_succeeded = &ovar_is_succeeded.)
	%Int_RSURESTAPI_CloseFile(i_filename_header = &_fref_outhdr.
									, i_filename_response = &_fref_outres.
									, ifref_result = &ifref_result.)
%mend RSURESTAPI__Put;

/*=================================*/
/* REST API Http Post
/*=================================*/
/*<FunctionDesc ja_jp>REST API Postメソッドを送信します</FunctionDesc ja_jp>*/
%macro RSURESTAPI__Post(
/*<FunctionArgDesc ja_jp>REST APIオブジェクトIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_restapi
								, i_url =
								, i_headers =
								, ifref_input =
								, ifref_result =
								, i_libname =
								, ovar_is_succeeded =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_restapi i_url ovar_is_succeeded)
	%Int_RSURESTAPI_VerifyConnected(&ivar_restapi.)
	%&RSULogger.PutNote(Call REST API(Post): &i_url.)
	%local /readonly _RESTAPI_ID_HTTPGET = &&&ivar_restapi.;
	%local _fref_outhdr;
	%local _fref_outres;
	%Int_RSURESTAPI_PrepareFile(ovar_filename_header = _fref_outhdr
										, ovar_filename_response = _fref_outres
										, ifref_result = &ifref_result.)
	proc http
			oauth_bearer = "&&&_RESTAPI_ID_HTTPGET._access_token."
			url = "&&&_RESTAPI_ID_HTTPGET._server_url.&i_url."
			method = 'POST'
			in = &ifref_input.
			out = &_fref_outres.
			headerout = &_fref_outhdr. 
		;
		%if (not %&RSUMacroVariable.IsBlank(i_headers)) %then %do;
		headers
			&i_headers.
		;
		%end;
	run;
	quit;
	%Int_RSURESTAPI_PostProcess(ifref_output_hdr = &_fref_outhdr. 
										, ifref_output_res = &_fref_outres.
										, i_body = Post
										, i_working_dir = &&&_RESTAPI_ID_HTTPGET._working_dir
										, i_libname = &i_libname.
										, ovar_is_succeeded = &ovar_is_succeeded.)
	%Int_RSURESTAPI_CloseFile(i_filename_header = &_fref_outhdr.
									, i_filename_response = &_fref_outres.
									, ifref_result = &ifref_result.)
%mend RSURESTAPI__Post;

/*=================================*/
/* REST API Http Head
/*=================================*/
/*<FunctionDesc ja_jp>REST API Headメソッドを送信します</FunctionDesc ja_jp>*/
%macro RSURESTAPI__Head(
/*<FunctionArgDesc ja_jp>REST APIオブジェクトIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_restapi
								, i_url =
								, i_headers =
								, ifref_input =
								, ifref_result =
								, i_libname =
								, ovar_is_succeeded =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_restapi i_url ovar_is_succeeded)
	%Int_RSURESTAPI_VerifyConnected(&ivar_restapi.)
	%&RSULogger.PutNote(Call REST API(Head): &i_url.)
	%local /readonly _RESTAPI_ID_HTTPGET = &&&ivar_restapi.;
	%local _fref_outhdr;
	%local _fref_outres;
	%Int_RSURESTAPI_PrepareFile(ovar_filename_header = _fref_outhdr
										, ovar_filename_response = _fref_outres
										, ifref_result = &ifref_result.)
	proc http
			oauth_bearer = "&&&_RESTAPI_ID_HTTPGET._access_token."
			url = "&&&_RESTAPI_ID_HTTPGET._server_url.&i_url."
			method = 'HEAD'
			in = &ifref_input.
			out = &_fref_outres.
			headerout = &_fref_outhdr. 
		;
		%if (not %&RSUMacroVariable.IsBlank(i_headers)) %then %do;
		headers
			&i_headers.
		;
		%end;
	run;
	quit;
	%Int_RSURESTAPI_PostProcess(ifref_output_hdr = &_fref_outhdr. 
										, ifref_output_res = &_fref_outres.
										, i_body = Post
										, i_working_dir = &&&_RESTAPI_ID_HTTPGET._working_dir
										, i_libname = &i_libname.
										, ovar_is_succeeded = &ovar_is_succeeded.)
	%Int_RSURESTAPI_CloseFile(i_filename_header = &_fref_outhdr.
									, i_filename_response = &_fref_outres.
									, ifref_result = &ifref_result.)
%mend RSURESTAPI__Head;

/*=================================*/
/* REST API Http Delete
/*=================================*/
/*<FunctionDesc ja_jp>REST API Deleteメソッドを送信します</FunctionDesc ja_jp>*/
%macro RSURESTAPI__Delete(
/*<FunctionArgDesc ja_jp>REST APIオブジェクトIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_restapi
								, i_url =
								, ovar_is_succeeded =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_restapi i_url ovar_is_succeeded)
	%Int_RSURESTAPI_VerifyConnected(&ivar_restapi.)
	%&RSULogger.PutNote(Call REST API(Delete): &i_url.)
	%local /readonly _RESTAPI_ID_HTTPDEL = &&&ivar_restapi.;
	%local _fref_outhdr;
	%local _fref_outres;
	%Int_RSURESTAPI_PrepareFile(ovar_filename_header = _fref_outhdr
										, ovar_filename_response = _fref_outres)
	proc http
			oauth_bearer = "&&&_RESTAPI_ID_HTTPDEL._access_token."
			url = "&&&_RESTAPI_ID_HTTPDEL._server_url.&i_url."
			method = 'DELETE'
			headerout = &_fref_outhdr. 
		;
	run;
	quit;
	%Int_RSURESTAPI_PostProcess(ifref_output_hdr = &_fref_outhdr.
										, ifref_output_res = &_fref_outres.
										, i_body = Delete
										, i_working_dir = &&&_RESTAPI_ID_HTTPDEL._working_dir
										, ovar_is_succeeded = &ovar_is_succeeded.)
	%Int_RSURESTAPI_CloseFile(i_filename_header = &_fref_outhdr.
									, i_filename_response = &_fref_outres.)
%mend RSURESTAPI__Delete;