/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Class_Rest.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/4/29
/*
/* <PkgParent>RSUPkgRest<PkgParent>
/************************************************************************************/
/*<ClassID>RSU_PKG_Class_Rest</ClassID>*/
/*<ClassCreator>%&RSUFile.Create</ClassCreator>*/
/*<ClassPurpose ja_jp>REST APIクラス</ClassPurpose ja_jp>*/

%&RSUClass.DeclareVar(<instance>, m_rest_server_url)

%macro Int_<instance>Initialize(i_rest_server_url =);
	%let <instance>m_rest_server_url = &i_rest_server_url.;
%mend Int_<instance>Initialize;

/*******************************************/
/* Public Macros
/*******************************************/
/*<FunctionDesc ja_jp>Get リクエストを送信します</FunctionDesc ja_jp>*/
%macro <instance>Get(
/*<FunctionArgDesc ja_jp>リスクエスト文字列</FunctionArgDesc ja_jp>*/
						i_request =
/*<FunctionArgDesc ja_jp>入力文字列</FunctionArgDesc ja_jp>*/
						, i_body =
/*<FunctionArgDesc ja_jp>リクエストヘッダー文字列</FunctionArgDesc ja_jp>*/
						, i_header_in_string =
/*<FunctionArgDesc ja_jp>コンテンツタイプ文字列</FunctionArgDesc ja_jp>*/
						, i_content_type =
/*<FunctionArgDesc ja_jp>レスポンス出力先ファイル参照</FunctionArgDesc ja_jp>*/
						, i_file_ref_out =
/*<FunctionArgDesc ja_jp>レスポンス結果（成功/失敗）保持変数名</FunctionArgDesc ja_jp>*/
						, ovar_is_response_ok =
/*<FunctionArgDesc ja_jp>レスポンスステータス保持変数名</FunctionArgDesc ja_jp>*/
						, ovar_response_status =
						);
	%RSURest__SendRequestToken(i_method = get
										, i_url = &<instance>m_rest_server_url/&i_request.
										, i_body = &i_body.
										, i_header_in_string = &i_header_in_string.
										, i_content_type = &i_content_type.
										, i_file_ref_out = &i_file_ref_out.
										, ovar_is_response_ok = &ovar_is_response_ok.
										, ovar_response_status = &ovar_is_response_ok.);
%mend <instance>Get;

/*<FunctionDesc ja_jp>Put リクエストを送信します</FunctionDesc ja_jp>*/
%macro <instance>Put(
/*<FunctionArgDesc ja_jp>リスクエスト文字列</FunctionArgDesc ja_jp>*/
						i_request =
/*<FunctionArgDesc ja_jp>入力文字列</FunctionArgDesc ja_jp>*/
						, i_body =
/*<FunctionArgDesc ja_jp>リクエストヘッダー文字列</FunctionArgDesc ja_jp>*/
						, i_header_in_string =
/*<FunctionArgDesc ja_jp>コンテンツタイプ文字列</FunctionArgDesc ja_jp>*/
						, i_content_type =
/*<FunctionArgDesc ja_jp>レスポンス出力先ファイル参照</FunctionArgDesc ja_jp>*/
						, i_file_ref_out =
/*<FunctionArgDesc ja_jp>レスポンス結果（成功/失敗）保持変数名</FunctionArgDesc ja_jp>*/
						, ovar_is_response_ok =
/*<FunctionArgDesc ja_jp>レスポンスステータス保持変数名</FunctionArgDesc ja_jp>*/
						, ovar_response_status =
						);
	%RSURest__SendRequestToken(i_method = put
										, i_url = &<instance>m_rest_server_url/&i_request.
										, i_body = &i_body.
										, i_header_in_string = &i_header_in_string.
										, i_content_type = &i_content_type.
										, i_file_ref_out = &i_file_ref_out.
										, ovar_is_response_ok = &ovar_is_response_ok.
										, ovar_response_status = &ovar_response_status.);
%mend <instance>Put;

/*<FunctionDesc ja_jp>Delete リクエストを送信します</FunctionDesc ja_jp>*/
%macro <instance>Delete(
/*<FunctionArgDesc ja_jp>リスクエスト文字列</FunctionArgDesc ja_jp>*/
								i_request =
/*<FunctionArgDesc ja_jp>入力文字列</FunctionArgDesc ja_jp>*/
								, i_body =
/*<FunctionArgDesc ja_jp>リクエストヘッダー文字列</FunctionArgDesc ja_jp>*/
								, i_header_in_string =
/*<FunctionArgDesc ja_jp>コンテンツタイプ文字列</FunctionArgDesc ja_jp>*/
								, i_content_type =
/*<FunctionArgDesc ja_jp>レスポンス出力先ファイル参照</FunctionArgDesc ja_jp>*/
								, i_file_ref_out =
/*<FunctionArgDesc ja_jp>レスポンス結果（成功/失敗）保持変数名</FunctionArgDesc ja_jp>*/
								, ovar_is_response_ok =
/*<FunctionArgDesc ja_jp>レスポンスステータス保持変数名</FunctionArgDesc ja_jp>*/
								, ovar_response_status =
								);
	%RSURest__SendRequestToken(i_method = delete
										, i_url = &<instance>m_rest_server_url/&i_request.
										, i_body = &i_body.
										, i_header_in_string = &i_header_in_string.
										, i_content_type = &i_content_type.
										, i_file_ref_out = &i_file_ref_out.
										, ovar_is_response_ok = &ovar_is_response_ok.
										, ovar_response_status = &ovar_response_status.);
%mend <instance>Delete;

/*<FunctionDesc ja_jp>Post リクエストを送信します</FunctionDesc ja_jp>*/
%macro <instance>Post(
/*<FunctionArgDesc ja_jp>リスクエスト文字列</FunctionArgDesc ja_jp>*/
							i_request =
/*<FunctionArgDesc ja_jp>入力文字列</FunctionArgDesc ja_jp>*/
							, i_body =
/*<FunctionArgDesc ja_jp>リクエストヘッダー文字列</FunctionArgDesc ja_jp>*/
							, i_header_in_string =
/*<FunctionArgDesc ja_jp>コンテンツタイプ文字列</FunctionArgDesc ja_jp>*/
							, i_content_type =
/*<FunctionArgDesc ja_jp>レスポンス出力先ファイル参照</FunctionArgDesc ja_jp>*/
							, i_file_ref_out =
/*<FunctionArgDesc ja_jp>レスポンス結果（成功/失敗）保持変数名</FunctionArgDesc ja_jp>*/
							, ovar_is_response_ok =
/*<FunctionArgDesc ja_jp>レスポンスステータス保持変数名</FunctionArgDesc ja_jp>*/
							, ovar_response_status =
							);
	%RSURest__SendRequestToken(i_method = post
										, i_url = &<instance>m_rest_server_url/&i_request.
										, i_body = &i_body.
										, i_header_in_string = &i_header_in_string.
										, i_content_type = &i_content_type.
										, i_file_ref_out = &i_file_ref_out.
										, ovar_is_response_ok = &ovar_is_response_ok.
										, ovar_response_status = &ovar_response_status.);
%mend <instance>Post;
