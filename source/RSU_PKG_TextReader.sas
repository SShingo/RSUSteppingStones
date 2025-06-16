/************************************************************************************/
/* PROGRAM NAME : RSU_PKG_TextReader.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/7/9
/*
/************************************************************************************/
/*<PackageID>RSUTextReader</PackageID>*/
/*<CategoryID>Cate_ExternalFile</CategoryID>*/
/*<PackagePurpose ja_jp>サーバーのファイル操作（ファイル読み込み）</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Handle files on server(reading file)</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>テキストファイルを１行ずつ読み込む機能を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions reading text file line by line</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>ファイルリーダーパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>File Reader Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSUTextReader, RSUTextReader__)

/*******************************************/
/* Public Macros
/*******************************************/
/*<FunctionDesc ja_jp>ファイルリーダーを生成します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Create file reader</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>ファイルリーダーID</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>ID of file reader</FunctionReturn en_us>*/
%macro RSUTextReader__Create(
/*<FunctionArgDesc ja_jp>ファイルのフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file</FunctionArgDesc en_us>*/
									i_file_path
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path)
	%&RSUFile.VerifyExists(&i_file_path.)
	%local /readonly _FREADER_ID = %Prv_RSUClass_CreateInstance(i_prefix = TR
																				, i_sequence_var = RSU_g_sequence_file_reader);
	%global &_FREADER_ID._fref;
	%let &_FREADER_ID._fref = %&RSUFile.GetFileRef(&i_file_path.);
	%global &_FREADER_ID._fid;
	%let &_FREADER_ID._fid = %Int_RSUUtil_VerifyID(i_id = %sysfunc(fopen(&&&_FREADER_ID._fref., i)));
	%local _rsu_text_reader_create_rc;
	%let _rsu_text_reader_create_rc = %sysfunc(fsep(&&&_FREADER_ID._fid., 0, x));
	%global &_FREADER_ID._term;
	%let &_FREADER_ID._term = %&RSUBool.False;
	&_FREADER_ID.
%mend RSUTextReader__Create;

/*<FunctionDesc ja_jp>ファイルリーダーを破棄します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Dispose file reader</FunctionDesc en_us>*/
%macro RSUTextReader__Dispose(
/*<FunctionArgDesc ja_jp>ファイルリーダーのIDを保持する変数</FunctionArgDesc ja_jp>*/
										ivar_filereader
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_filereader)
	%RSUTextReader__Close(&ivar_filereader.)
	%local /readonly _FREADER_ID_DISPOSE = &&&ivar_filereader.;
	%&RSUFile.ClearFileRef(&_FREADER_ID_DISPOSE._fref)
	%&RSUMacroVariable.Delete(i_regex = /^&_FREADER_ID_DISPOSE._/i)
%mend RSUTextReader__Dispose;

/*<FunctionDesc ja_jp>ファイルリーダーを閉じます</FunctionDesc ja_jp>*/
%macro RSUTextReader__Close(
/*<FunctionArgDesc ja_jp>ファイルリーダーのIDを保持する変数</FunctionArgDesc ja_jp>*/
									ivar_filereader
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_filereader)
	%if (%RSUTextReader__IsOpen(&ivar_filereader.)) %then %do;
		%local /readonly _FREADER_ID_CLOSE = &&&ivar_filereader.;
		%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fclose(&&&_FREADER_ID_CLOSE._fid.)))
		%let &_FREADER_ID_CLOSE._fid =;
	%end;
%mend RSUTextReader__Close;

/*<FunctionDesc ja_jp>ファイルリーダーが開いているか否かを返します</FunctionDesc ja_jp>*/
%macro RSUTextReader__IsOpen(ivar_filereader);
	%local /readonly _FREADER_ID_ISOPEN = &&&ivar_filereader.;
	%eval(not %&RSUMacroVariable.IsBlank(&_FREADER_ID_ISOPEN._fid))
%mend RSUTextReader__IsOpen;

/*<FunctionDesc ja_jp>ファイルリーダーが開いているか否かを検証します（開いていない場合はエラー）</FunctionDesc ja_jp>*/
%macro RSUTextReader__VerifyOpen(ivar_filereader);
	%if (not %RSUTextReader__IsOpen(&ivar_filereader.)) %then %do;
		%&RSULogger.PutError(Text file readear fail. File reader is not open
									, i_abort = cancel)
	%end;
%mend RSUTextReader__VerifyOpen;

/*<FunctionDesc ja_jp>一行読み込みます</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>read line from the file</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>0: 読み込み失敗（終了）、1: 読み込み成功</FunctionReturn ja_jp>*/
%macro RSUTextReader__Fetch(
/*<FunctionArgDesc ja_jp>ファイルリーダーのIDを保持する変数</FunctionArgDesc ja_jp>*/
									ivar_filereader
/*<FunctionArgDesc ja_jp>テキスト</FunctionArgDesc ja_jp>*/
									, ovar_line
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_filereader ovar_line)
	%let &ovar_line. =;
	%local /readonly _FREADER_ID_FETCH = &&&ivar_filereader.;
	%if (&&&_FREADER_ID_FETCH._term.) %then %do;
		%let &_FREADER_ID_FETCH._term = %&RSUBool.False;
		%&RSUBool.False
		%return;
	%end;

	%RSUTextReader__VerifyOpen(&ivar_filereader.)
	/* フェッチ */
	%local _rsu_text_reader_result;
	%local _rsu_text_reader_rc;
	%let _rsu_text_reader_rc = %sysfunc(fread(&&&_FREADER_ID_FETCH._fid.));
	%if (&_rsu_text_reader_rc. = 0) %then %do;
		/* フェッチ成功 */
		%let _rsu_text_reader_result = %&RSUBool.True;
		%let _rsu_text_reader_rc = %sysfunc(fget(&&&_FREADER_ID_FETCH._fid., &ovar_line.));
	%end;
	%else %if(&_rsu_text_reader_rc. = -1) %then %do;
		/* フェッチ終了 */
		%let _rsu_text_reader_result = %&RSUBool.False;
	%end;
	&_rsu_text_reader_result.
%mend RSUTextReader__Fetch;

/*<FunctionDesc ja_jp>ファイルリーダーを強制終了します</FunctionDesc ja_jp>*/
%macro RSUTextReader__Terminate(
/*<FunctionArgDesc ja_jp>ファイルリーダーIDを保持する変数名</FunctionArgDesc ja_jp>*/
										ivar_filereader
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_filereader)
	%if (%RSUTextReader__IsOpen(&ivar_filereader.)) %then %do;
		%RSUTextReader__Close(&ivar_filereader.)
		%local /readonly _FREADER_ID_TERMINATE = &&&ivar_filereader.;
		%let &_FREADER_ID_TERMINATE._term = %&RSUBool.True;
	%end;
%mend RSUTextReader__Terminate;
