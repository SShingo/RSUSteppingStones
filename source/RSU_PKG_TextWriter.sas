/************************************************************************************/
/* PROGRAM NAME : RSU_PKG_TextWriter.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/3/7
/*
/************************************************************************************/
/*<PackageID>RSUTextWriter</PackageID>*/
/*<CategoryID>Cate_ExternalFile</CategoryID>*/
/*<PackagePurpose ja_jp>サーバーのファイル操作（ファイル書き込み）</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Handle files on server(writing file)</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>テキストファイルに１行ずつ書きこむ機能を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions writing text file line by line</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>ファイルライターパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>File Writer Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSUTextWriter, RSUTextWriter__)

/*******************************************/
/* Public Macros
/*******************************************/
/*<FunctionDesc ja_jp>ファイルライターを生成します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Create file writer</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>ファイルライターID</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>ID of file writer</FunctionReturn en_us>*/
%macro RSUTextWriter__Create(
/*<FunctionArgDesc ja_jp>ファイルのフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file</FunctionArgDesc en_us>*/
									i_file_path =
/*<FunctionArgDesc ja_jp>追記モードか否か</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Append mode or not</FunctionArgDesc en_us>*/
									, i_is_append = %&RSUBool.False
									);
	%if (&i_is_append.) %then %do;
		%&RSUFile.VerifyExists(&i_file_path.)
	%end;
	%local /readonly _FWRITER_ID = %Prv_RSUClass_CreateInstance(i_prefix = TW
																				, i_sequence_var = RSU_g_sequence_file_writer);
	%global &_FWRITER_ID._fref;
	%let &_FWRITER_ID._fref = %&RSUFile.GetFileRef(&i_file_path.);
	%global &_FWRITER_ID._fid;
	%let &_FWRITER_ID._fid = %Int_RSUUtil_VerifyID(i_id = %sysfunc(fopen(&&&_FWRITER_ID._fref., %&RSUUtil.Choose(&i_is_append., a, o), 0)));
	&_FWRITER_ID.
%mend RSUTextWriter__Create;

/*<FunctionDesc ja_jp>ファイルライターを破棄します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Dispose file writer</FunctionDesc en_us>*/
%macro RSUTextWriter__Dispose(
/*<FunctionArgDesc ja_jp>ファイルライターのIDを保持する変数</FunctionArgDesc ja_jp>*/
									ivar_filewriter
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_filewriter)
	%local /readonly _FWRITER_ID_DISPOSE = &&&ivar_filewriter.;
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fclose(&&&_FWRITER_ID_DISPOSE._fid.)))
	%&RSUFile.ClearFileRef(&_FWRITER_ID_DISPOSE._fref)
	%&RSUMacroVariable.Delete(i_regex = /^&_FWRITER_ID_DISPOSE._/i)
%mend RSUTextWriter__Dispose;

/*<FunctionDesc ja_jp>ファイルにテキストを一行書き込みます</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Write a line to the file</FunctionDesc en_us>*/
%macro RSUTextWriter__PutLine(
/*<FunctionArgDesc ja_jp>ファイルライターのIDを保持する変数</FunctionArgDesc ja_jp>*/
										ivar_filewriter
/*<FunctionArgDesc ja_jp>テキスト</FunctionArgDesc ja_jp>*/
										, i_line
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_filewriter)
	%local /readonly _FWRITER_ID_PUTLINE = &&&ivar_filewriter.;
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fput(&&&_FWRITER_ID_PUTLINE._fid., &i_line.)))
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fwrite(&&&_FWRITER_ID_PUTLINE._fid., +)))
%mend RSUTextWriter__PutLine;

/*<FunctionDesc ja_jp>外部ファイルにテキストを1行書き込みます</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Write one line of text to an external file</FunctionDesc en_us>*/
%macro RSUTextWriter__WriteLine(
/*<FunctionArgDesc ja_jp>ファイルのフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file</FunctionArgDesc en_us>*/
										i_file_path =
/*<FunctionArgDesc ja_jp>書き込むテキスト</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Text to be written</FunctionArgDesc en_us>*/
										, i_line =
/*<FunctionArgDesc ja_jp>追記の場合は 1 を指定します</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Specify 1 for appending</FunctionArgDesc en_us>*/
										, i_append = %&RSUBool.False
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path)
	%local _filrf;
	%let _filrf = %RSUFile__GetFileRef(&i_file_path.);
	%local /readonly _OPEN_ACTION = %&RSUUtil.Choose(&i_append., a, o);
	%local /readonly _RSU_FILE_FID = %Int_RSUUtil_VerifyID(i_id = %sysfunc(fopen(&_filrf, &_OPEN_ACTION., 0)));
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fput(&_RSU_FILE_FID, &i_line.)))
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fwrite(&_RSU_FILE_FID)))
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fclose(&_RSU_FILE_FID.)))
	%RSUFile__ClearFileRef(_filrf)
%mend RSUTextWriter__WriteLine;
