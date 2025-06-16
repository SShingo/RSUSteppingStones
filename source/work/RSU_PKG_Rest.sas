/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Rest.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/4/29
/*
/************************************************************************************/
/*<PackageID>RSURest</PackageID>*/
/*<CategoryID>Cate_Misc</CategoryID>*/
/*<PackagePurpose ja_jp>Rest API</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Rest API</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>Rest APIを操作するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating Rest API</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>Rest パッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSURest, RSURest__)
/*<ConstantDesc ja_jp>Rest クラス定義ファイル名</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_CLASS_FILE_REST, RSU_PKG_Class_Rest)

/*<FunctionDesc ja_jp>REST APIオブジェクトを生成します</FunctionDesc ja_jp>*/
%macro RSURest__Create(i_rest_server_url =);
/*<FunctionArgDesc ja_jp>サーバーURL</FunctionArgDesc ja_jp>*/
	%local _instance;
	%let _instance = %Int_RSUClass_Create(i_template_name = &RSU_G_CLASS_FILE_REST);
	%Int_&_instance.Initialize(i_rest_server_url = &i_rest_server_url.)
	&_instance.
%mend RSURest__Create;

/*<FunctionDesc ja_jp>トークン認証によるリクエスト送信</FunctionDesc ja_jp>*/
%macro RSURest__SendRequestToken(
/*<FunctionArgDesc ja_jp>メソッド（GET/PUT/DELETE/POST）</FunctionArgDesc ja_jp>*/
											i_method =
/*<FunctionArgDesc ja_jp>URL（REST API URL/リクエスト文字列）</FunctionArgDesc ja_jp>*/
											, i_url =
/*<FunctionArgDesc ja_jp>インプットデータ文字列</FunctionArgDesc ja_jp>*/
											, i_body =
/*<FunctionArgDesc ja_jp>リクエストヘッダー文字列</FunctionArgDesc ja_jp>*/
											, i_header_in_string =
/*<FunctionArgDesc ja_jp>リクエストコンテンツタイプ</FunctionArgDesc ja_jp>*/
											, i_content_type =
/*<FunctionArgDesc ja_jp>レスポンス出力先ファイル参照名</FunctionArgDesc ja_jp>*/
											, i_file_ref_out =
/*<FunctionArgDesc ja_jp>成功（HTTP STATUS が 200番台）か否かを保持する変数名</FunctionArgDesc ja_jp>*/
											, ovar_is_response_ok =
/*<FunctionArgDesc ja_jp>レスポンスステータスを保持する変数名</FunctionArgDesc ja_jp>*/
											, ovar_response_status =
											);
	/* Pre process */
	filename _f_hout temp;
	%local _file_ref_header_in;
	%if (not %&RSUMacroVariable.IsBlank(i_header_in_string)) %then %do;
		%let _file_ref_header_in = _f_hin;
		filename &_file_ref_header_in. temp;
		%Prv_RSURest_CreateInputFile(i_file_ref = _f_hin
											, i_contents = &i_header_in_string.)
	%end;
	%local _file_ref_in;
	%if (not %&RSUMacroVariable.IsBlank(i_body)) %then %do;
		%let _file_ref_in = _f_in;
		filename &_file_ref_in. temp;
		%Prv_RSURest_CreateInputFile(i_file_ref = _f_in
											, i_contents = &i_body.)
	%end;

	/* Fire request */
	proc http
		http_tokenauth
		url = "%nrbquote(&i_url.)"
		%Prv_RSURest_ProcHttpHelper(i_method = &i_method.
											, i_file_ref_header_in = &_file_ref_header_in.
											, i_file_ref_header_out = _f_hout
											, i_file_ref_in = &_file_ref_in.
											, i_file_ref_out = &i_file_ref_out.
											, i_content_type = &i_content_type.)
		;
	run;
	quit;

	/* Parse response */
	%Int_RSURest_GetHTTPStatus(i_file_ref = _f_hout
									, ovar_is_response_ok = &ovar_is_response_ok.
									, ovar_response_status = &ovar_response_status.)

	/* Post process */
	%if (not %&RSUMacroVariable.IsBlank(_file_ref_in)) %then %do;
		filename &_file_ref_in. clear;
	%end;
	%if (not %&RSUMacroVariable.IsBlank(_file_ref_header_in)) %then %do;
		filename &_file_ref_header_in. clear;
	%end;
	filename _f_hout clear;
%mend RSURest__SendRequestToken;