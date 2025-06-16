/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_DSIO.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/3/18
/************************************************************************************/
/*<PackageID>RSUDSIO</PackageID>*/
/*<CategoryID>Cate_DataHandling</CategoryID>*/
/*<PackagePurpose ja_jp>データセットの入出力</PackagePurpose ja_jp>*/
/*<PackageDesc ja_jp>SAS データセットの入出力操作関数を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions of dataset input/output</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>データセット入出力パッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUDSIO, RSUDSIO__)

/*<FunctionDesc ja_jp>テキストファイルをデータセットにロードします（既存データセットによってデータセットの定義を行います）</FunctionDesc ja_jp>*/
%macro RSUDSIO__LoadTextIntoFrame(
/*<FunctionArgDesc ja_jp>ロードテキストのフルパス（デフォルトはタブ区切りテキスト）</FunctionArgDesc ja_jp>*/
											i_file_path =
/*<FunctionArgDesc ja_jp>ロード先のデータセットの attribute を定義するデータセット</FunctionArgDesc ja_jp>*/
											, iods_frame_ds =
/*<FunctionArgDesc ja_jp>読み込み対象絞り込みクエリ</FunctionArgDesc ja_jp>*/
											, i_query =
/*<FunctionArgDesc ja_jp>ロード開始行</FunctionArgDesc ja_jp>*/
											, i_firstobs = 2
/*<FunctionArgDesc ja_jp>ロードテキストの区切り文字</FunctionArgDesc ja_jp>*/
											, i_delimiter = &RSUTab.
/*<FunctionArgDesc ja_jp>追加フラグ（1の場合、ロードテキストが既存データセットに追記されます）</FunctionArgDesc ja_jp>*/
											, i_append = %&RSUBool.False
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path iods_frame_ds i_delimiter)
	%&RSUFile.VerifyExists(i_file_path = &i_file_path.)
	%&RSUDS.VerifyExists(ids_dataset = &iods_frame_ds.)

	/* 枠だけコピー */
	%local /readonly _RSU_TMP_FRAME_DS_ = %RSUDS__GetTempDSName();
	data &_RSU_TMP_FRAME_DS_.;
		if (_N_ = 0) then do;
			set &iods_frame_ds.;
		end;
		call missing(of _all_);
		stop;
	run;
	quit;

	/* 読み込み */
	%local /readonly _RSU_TMP_OUTPUT_DS_ = %RSUDS__GetTempDSName();
	%local _tmp_fref_input;
	%let _tmp_fref_input = %&RSUFile.GetFileRef(&i_file_path.);
	%Prv_RSUDSIO_LoadTextHelper(i_file_ref = &_tmp_fref_input.
										, iods_frame_ds = &_RSU_TMP_FRAME_DS_.
										, i_delimiter = &i_delimiter.
										, i_firstobs = &i_firstobs.
										, ods_output_ds = &_RSU_TMP_OUTPUT_DS_.)
	%&RSUFile.ClearFileRef(_tmp_fref_input)
	%&RSUDS.Delete(&_RSU_TMP_FRAME_DS_.)

	/* 出力 */
	%if (&i_append.) %then %do;
		data &iods_frame_ds.;
			set
				&iods_frame_ds.
				&_RSU_TMP_OUTPUT_DS_.
			;
		run;
		quit;
	%end;
	%else %do;
		data &iods_frame_ds.;
			set &_RSU_TMP_OUTPUT_DS_.;
		run;
		quit;
	%end;

	%if (not %&RSUMacroVariable.IsBlank(i_query)) %then %do;
		data &iods_frame_ds.;
			set &iods_frame_ds.(where = (&i_query.));
		run;
		quit;
	%end;
	%&RSUDS.Delete(&_RSU_TMP_OUTPUT_DS_.)
%mend RSUDSIO__LoadTextIntoFrame;

/*<FunctionDesc ja_jp>テキストファイルをデータセットにロードします（定義ファイルによってデータセットの定義を行います）</FunctionDesc ja_jp>*/
%macro RSUDSIO__LoadText(
/*<FunctionArgDesc ja_jp>テキストのフルパス（デフォルトはタブ区切りテキスト） </FunctionArgDesc ja_jp>*/
								i_file_path =
/*<FunctionArgDesc ja_jp>テーブルスキーマファイルフルパス</FunctionArgDesc ja_jp>*/
								, i_schema_file_path =
/*<FunctionArgDesc ja_jp>読み込み対象絞り込みクエリ</FunctionArgDesc ja_jp>*/
								, i_query =
/*<FunctionArgDesc ja_jp>ロード開始行</FunctionArgDesc ja_jp>*/
								, i_firstobs = 2
/*<FunctionArgDesc ja_jp>テキストの区切り文字</FunctionArgDesc ja_jp>*/
								, i_delimiter = &RSUTab.
/*<FunctionArgDesc ja_jp>出力先データセット</FunctionArgDesc ja_jp>*/
								, ods_output_ds =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_schema_file_path ods_output_ds i_delimiter)
	%&RSUFile.VerifyExists(i_file_path = &i_file_path.)
	%&RSUFile.VerifyExists(i_file_path = &i_schema_file_path.)

	/* 枠と制約条件を読み込み */
	%local _tmp_fref_schema_file;
	%let _tmp_fref_schema_file = %&RSUFile.GetFileRef(&i_schema_file_path.);
	%local /readonly _TMP_DEF_TABLE = %RSUDS__GetTempDSName();
	%local /readonly _TMP_FRAME_DS = %RSUDS__GetTempDSName();
	%local /readonly _TMP_CONSTRAINT_DS = %RSUDS__GetTempDSName();
	%Prv_RSUDSIO_LoadTableDefFile(i_schema_file_ref = &_tmp_fref_schema_file.
											, ods_definition_ds = &_TMP_DEF_TABLE.
											, ods_frame_ds = &_TMP_FRAME_DS.
											, ods_constraint_ds = &_TMP_CONSTRAINT_DS.)
	%&RSUFile.ClearFileRef(_tmp_fref_schema_file)
	%&RSUDS.Delete(&_TMP_DEF_TABLE.)
	/* 読み込み */
	%local /readonly _TMP_OUTPUT_DS = %RSUDS__GetTempDSName();
	%local _tmp_fref_input;
	%let _tmp_fref_input = %&RSUFile.GetFileRef(&i_file_path.);
	%Prv_RSUDSIO_LoadTextHelper(i_file_ref = &_tmp_fref_input.
										, iods_frame_ds = &_TMP_FRAME_DS.
										, i_delimiter = &i_delimiter.
										, i_firstobs = &i_firstobs.
										, ods_output_ds = &_TMP_OUTPUT_DS.)
	%&RSUFile.ClearFileRef(_tmp_fref_input)
	%&RSUDS.Delete(&_TMP_FRAME_DS.)

	/* 制約条件を適用 */
	%if (not %&RSUDS.IsDSEmpty(&_TMP_CONSTRAINT_DS.)) %then %do;
		%Prv_RSUDSIO_ApplyConstraint(iods_dataset = &_tmp_output_ds.
											, ids_constraint_ds = &_TMP_CONSTRAINT_DS.)
	%end;
	%&RSUDS.Delete(&_TMP_CONSTRAINT_DS.)

	/* 出力 */
	data &ods_output_ds.;
		set &_TMP_OUTPUT_DS.;
	run;
	quit;

	%if (not %&RSUMacroVariable.IsBlank(i_query)) %then %do;
		data &ods_output_ds.;
			set &ods_output_ds.(where = (&i_query.));
		run;
		quit;
	%end;
	%&RSUDS.Delete(&_TMP_OUTPUT_DS.)
%mend RSUDSIO__LoadText;

%macro RSUDSIO__LoadExcel(
/*<FunctionArgDesc ja_jp>エクセルファイルフルパス</FunctionArgDesc ja_jp>*/
								i_file_path =
/*<FunctionArgDesc ja_jp>インポート対象シート名</FunctionArgDesc ja_jp>*/
								, i_sheet_name =
/*<FunctionArgDesc ja_jp>テーブルスキーマ定義テキストファイルフルパス（優先）</FunctionArgDesc ja_jp>*/
								, i_schema_text_file_path =
/*<FunctionArgDesc ja_jp>テーブルスキーマエクセルファイルフルパス</FunctionArgDesc ja_jp>*/
								, i_schema_excel_file_path =
/*<FunctionArgDesc ja_jp>テーブルスキーマシート名</FunctionArgDesc ja_jp>*/
								, i_schema_sheet_name =
/*<FunctionArgDesc ja_jp>インポート対象レンジ</FunctionArgDesc ja_jp>*/
								, i_range =
/*<FunctionArgDesc ja_jp>読み込み対象絞り込みクエリ</FunctionArgDesc ja_jp>*/
								, i_query =
/*<FunctionArgDesc ja_jp>ヘッダーが含まれる場合は1</FunctionArgDesc ja_jp>*/
								, i_contain_header = %&RSUBool.True
/*<FunctionArgDesc ja_jp>文字列の長さを強制的に設定するためのダミーレコード位置（空欄:ダミーレコードなし、1：ヘッダーの一行後）</FunctionArgDesc ja_jp>*/
								, i_dummy_row = %&RSUBool.False
/*<FunctionArgDesc ja_jp>出力データセット</FunctionArgDesc ja_jp>*/
								, ods_output_ds =);
	%&RSUFile.VerifyExists(&i_excel_file_path.)
	%&RSUExcel.VerifyContains(i_file_path = &i_excel_file_path.
										, i_sheet_name = &i_sheet_name.)
	%local _tmp_fref_schema_file;
	%if (not %&RSUMacroVariable.IsBlank(i_schema_text_file_path)) %then %do;
		%&RSUFile.VerifyExists(&i_schema_text_file_path.)
		%let _tmp_fref_schema_file = %&RSUFile.GetFileRef(&i_schema_text_file_path.);
	%end;
	%else %do;
		%&RSUFile.VerifyExists(&i_schema_excel_file_path.)
		%local /readonly _SCHEMA_SHEET_NAME = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_schema_name), #&i_sheet_name., #&i_schema_name.);
		%&RSULogger.PutBlock(Target excel file
									, Data: "&i_excel_file_path." [&i_sheet_name.]
									, Schema: "&i_setting_excel_file_path." [&_SCHEMA_SHEET_NAME.])
		%&RSUExcel.VerifyContains(i_file_path = &i_setting_excel_file_path.
										, i_sheet_name = &_SCHEMA_SHEET_NAME.)
		%let _tmp_fref_schema_file = %&RSUFile.GetFileRef();
		%&RSUExcel.ExportToText(i_file_path =	&i_setting_excel_file_path.
										, i_sheet_name = &_SCHEMA_SHEET_NAME.
										, i_output_fileref =	&_tmp_fref_schema_file.)
	%end;
	%Prv_RSUDSIO_LoadExcel(i_file_path = &i_file_path.
								, i_sheet_name = &i_sheet_name.
								, i_range = &i_range.
								, i_schema_file_ref = &_tmp_fref_schema_file.
								, i_query = &i_query.
								, i_contain_header = &i_contain_header.
								, i_dummy_row = &i_dummy_row.
								, ods_output_ds = &ods_output_ds.)
	%&RSUFile.ClearFileRef(_tmp_fref_schema_file)
	%&RSUDS.VerifyExists(&ods_output_ds.)
%mend RSUDSIO__LoadExcel;

/*<FunctionDesc ja_jp>データセットを指定ディレクトリに保存します</FunctionDesc ja_jp>*/
%macro RSUDSIO__SaveAs(
/*<FunctionArgDesc ja_jp>保存対象データセット</FunctionArgDesc ja_jp>*/
								ids_dataset =
/*<FunctionArgDesc ja_jp>保存先ディレクトリパス</FunctionArgDesc ja_jp>*/
								, i_dir_path =
/*<FunctionArgDesc ja_jp>1レベル保存データセット名（省略した場合、保存対象データセットと同一名称になります）</FunctionArgDesc ja_jp>*/
								, i_dsname =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset i_dir_path)
	%&RSUDirectory.VerifyExists(i_dir_path = &i_dir_path.)
	/* Source DS info */
	%local /readonly _RSU_TMP_SRC_DSNAME_ = %RSUDS__GetDSname(ids_dataset = &ids_dataset.);
	%local /readonly _RSU_TMP_SRC_LIBNAME_ = %RSUDS__GetLibname(ids_dataset = &ids_dataset.);
	%local /readonly _RSU_TMP_SRC_DIR_PATH_ = %&RSULib.GetPath(i_libname = &_RSU_TMP_SRC_LIBNAME_.);

	/* Destination DS Info */
	%local /readonly _RSU_TMP_DEST_DSNAME_ = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_dsname), &_RSU_TMP_SRC_DSNAME_., &i_dsname.);
	%local /readonly _RSU_TMP_DEST_DIR_PATH_ = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_dir_path), &_RSU_TMP_SRC_DIR_PATH_., &i_dir_path.);

	%if (%&RSUUtil.Eq(_src_dir_path, _RSU_TMP_DEST_DIR_PATH_)) %then %do;
		%if (%&RSUUtil.Eq(_RSU_TMP_SRC_DIR_PATH_, _RSU_TMP_DEST_DSNAME_)) %then %do;
			%&RSULogger.PutWarning(%&RSUMsg.FAIL_TO_SAVE_DS(&ids_dataset.))
		%end;
		%else %do;
			%RSUDS__Let(i_query = &ids_dataset.
							, ods_dest_ds = &_RSU_TMP_SRC_LIBNAME_..&_RSU_TMP_DEST_DSNAME_.)
		%end;
	%end;
	%else %do;
		%local /readonly _RSU_TMP_LIBRARY_NAME_ = %Int_RSULib_GetTempLibName();
		libname &_RSU_TMP_LIBRARY_NAME_. "&_RSU_TMP_DEST_DIR_PATH_." compress = yes;
		%RSUDS__Let(i_query = &ids_dataset.
						, ods_dest_ds = &_RSU_TMP_LIBRARY_NAME_..&_RSU_TMP_DEST_DSNAME_.)
		libname &_RSU_TMP_LIBRARY_NAME_. clear;
	%end;
%mend RSUDSIO__SaveAs;

/*<FunctionDesc ja_jp>データセットをテキストで保存します</FunctionDesc ja_jp>*/
%macro RSUDSIO__SaveAsText(
/*<FunctionArgDesc ja_jp>保存対象データセット</FunctionArgDesc ja_jp>*/
									ids_dataset =
/*<FunctionArgDesc ja_jp>保存ファイルフルパス（.txtファイル）</FunctionArgDesc ja_jp>*/
									, i_file_path =
/*<FunctionArgDesc ja_jp>区切り文字</FunctionArgDesc ja_jp>*/
									, i_delimiter = &RSUTab.
/*<FunctionArgDesc ja_jp>ヘッダーをスキップするか </FunctionArgDesc ja_jp>*/
									, i_is_header_skipped = %&RSUBool.False
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset i_file_path)
	%local _tmp_fref_output;
	%let _tmp_fref_output = %&RSUFile.GetFileRef(&i_file_path.);
	%Prv_RSUDS_PutDSHelper(i_dest_file = &_tmp_fref_output.
								, ids_src_dataset = &ids_dataset.
								, i_delimiter = &i_delimiter.
								, i_is_header_skipped = &i_is_header_skipped.)
	%&RSUFile.ClearFileRef(_tmp_fref_output)
%mend RSUDSIO__SaveAsText;

/*<FunctionDesc ja_jp>データセットをExcelで保存します</FunctionDesc ja_jp>*/
%macro RSUDSIO__SaveAsExcel(
/*<FunctionArgDesc ja_jp>保存対象データセット</FunctionArgDesc ja_jp>*/
									ids_dataset =
/*<FunctionArgDesc ja_jp>保存ファイルフルパス（.xlsxファイル）</FunctionArgDesc ja_jp>*/
									, i_file_path =
/*<FunctionArgDesc ja_jp>保存シート名 </FunctionArgDesc ja_jp>*/
									, i_sheet_name =
/*<FunctionArgDesc ja_jp>'0'：新規保存、'1'：追記</FunctionArgDesc ja_jp>*/
									, i_append = 0
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset i_file_path)
	%&RSUExcel.ExportDS(i_file_path = &i_file_path.
								, ids_dataset = &ids_dataset.
								, i_sheet_name = &i_sheet_name.
								, i_append = &i_append.)
%mend RSUDSIO__SaveAsExcel;
