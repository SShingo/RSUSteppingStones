/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Excel.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/8/29
/*
/************************************************************************************/
/*<PackageID>RSUExcel</PackageID>*/
/*<CategoryID>Cate_ExternalFile</CategoryID>*/
/*<PackagePurpose ja_jp>エクセルファイルに対するファイル操作</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Manipulate Excel files</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>エクセルファイル操作に係るマクロ群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating Excel file</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>エクセルファイルパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Excel File Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSUExcel, RSUExcel__)

/*<FunctionDesc ja_jp>データセットをエクセルファイルにエクスポートします</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export dataset into Excel file</FunctionDesc en_us>*/
%macro RSUExcel__ExportDS(
/*<FunctionArgDesc ja_jp>保存ファイルフルパス（.xlsxファイル）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Full path to the file being saved (.xlsx file)</FunctionArgDesc en_us>*/
								i_file_path =
/*<FunctionArgDesc ja_jp>保存対象データセット</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target dataset</FunctionArgDesc en_us>*/
								, ids_dataset =
/*<FunctionArgDesc ja_jp>保存シート名 </FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Sheet being saved </FunctionArgDesc en_us>*/
								, i_sheet_name =
/*<FunctionArgDesc ja_jp>'0'：新規保存、'1'：追記</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>'0'：Save as new、'1'：Save to an existing file</FunctionArgDesc en_us>*/
								, i_append = %&RSUBool.False
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path ids_dataset i_sheet_name)
	proc export
		data = &ids_dataset.
		dbms = xlsx
		outfile = "&i_file_path."
	%if (not &i_append.) %then %do;
		replace
	%end;
		;
		sheet = "&i_sheet_name.";
	run;
	/* Delete .bak file */
	%&RSUFile.Delete(i_file_path = &i_file_path..bak)
%mend RSUExcel__ExportDS;

/*<FunctionDesc ja_jp>エクセルブックのシート一覧の配列を返します </FunctionDesc ja_jp>*/
%macro RSUExcel__GetSheets(
									/*<FunctionArgDesc ja_jp>エクセルファイルフルパス</FunctionArgDesc ja_jp>*/
									/*<FunctionArgDesc en_us>Full path to the excel file</FunctionArgDesc en_us>*/
									i_file_path =
									/*<FunctionArgDesc ja_jp>エクセルシート名正規表現</FunctionArgDesc ja_jp>*/
									, i_regex_sheet_name =
									/*<FunctionArgDesc ja_jp>出力データセット</FunctionArgDesc ja_jp>*/
									, ods_sheets =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path ods_sheets)
	%local /readonly _RSU_EXCEL_TMP_LIBNAME = %Int_RSULib_GetTempLibName();
	%local _rc_getsheets;
	%let _rc_getsheets = %sysfunc(libname(&_RSU_EXCEL_TMP_LIBNAME., &i_file_path., xlsx, access = readonly));
	%local _filter_code;
	%if (not %&RSUMacroVariable.IsBlank(i_regex_sheet_name)) %then %do;
		%local /readonly _REGEX_OPTION = %scan(&i_regex_sheet_name., 3, /);
		%if (%index(&_REGEX_OPTION., i) = 0) %then %do;
			%let i_regex_sheet_name = &i_regex_sheet_name.i;
		%end;
		%let _filter_code = and prxmatch("&i_regex_sheet_name.", trim(memname));
	%end;
	%&RSUDS.Let(i_query = SASHELP.vmember(where = (upcase(libname) = "%upcase(&_RSU_EXCEL_TMP_LIBNAME.)" and memtype = 'DATA' &_filter_code.))
					, ods_dest_ds = &ods_sheets.)
	%let _rc_getsheets = %sysfunc(libname(&_RSU_EXCEL_TMP_LIBNAME));
%mend RSUExcel__GetSheets;

/*<FunctionDesc ja_jp>エクセルブックにシートが含まれているかを返します </FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Return whether the Excel file has the target sheets</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>0: 指定シートが含まれていない\quad 1: 指定シートが含まれている</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>0: Target sheet not included\quad 1: Target sheet is included</FunctionReturn en_us>*/
%macro RSUExcel__ContainsSheet(
/*<FunctionArgDesc ja_jp>エクセルファイルフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Full path to the Excel file</FunctionArgDesc en_us>*/
										i_file_path =
/*<FunctionArgDesc ja_jp>シート名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Excel sheet name</FunctionArgDesc en_us>*/
										, i_sheet_name =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_sheet_name)
	%local /readonly _RSU_EXCEL_TMP_LIBNAME = %Int_RSULib_GetTempLibName();
	%local _rc_getsheets;
	%let _rc_getsheets = %sysfunc(libname(&_RSU_EXCEL_TMP_LIBNAME., &i_file_path., xlsx, access = readonly));
	%local _dsid;
	%let _dsid = %sysfunc(open(SASHELP.vmember(where = (upcase(libname) = "%upcase(&_RSU_EXCEL_TMP_LIBNAME.)" and memtype = 'DATA' and upcase(memname) = upcase("&i_sheet_name."))), IN));
	%local _rc_ds;
	%let _rc_ds = %sysfunc(fetchobs(&_dsid., 1));
	%local /readonly _RESULT = %eval(&_rc_ds. = 0);
	%let _rc_ds = %sysfunc(close(&_dsid.));
	%let _rc_getsheets = %sysfunc(libname(&_RSU_EXCEL_TMP_LIBNAME));
	&_RESULT.
%mend RSUExcel__ContainsSheet;

/*<FunctionDesc ja_jp>エクセルブックにシートが含まれているかを検証します（検証失敗時は処理中断） </FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Validate whether the Excel book has the target sheets（If the validation fails, the process will be stopped）</FunctionDesc en_us>*/
%macro RSUExcel__VerifyContains(
/*<FunctionArgDesc ja_jp>エクセルファイルフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Full path to the Excel file</FunctionArgDesc en_us>*/
											i_file_path =
/*<FunctionArgDesc ja_jp>シート名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Sheet name</FunctionArgDesc en_us>*/
											, i_sheet_name =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_sheet_name)
	%&RSUError.AbortIf(not %RSUExcel__ContainsSheet(i_file_path = &i_file_path., i_sheet_name = &i_sheet_name.)
							, %&RSUMsg.EXCEL_SHEET_NOT_FOUND(&i_file_path., &i_sheet_name.))
%mend RSUExcel__VerifyContains;

/*<FunctionDesc ja_jp>エクセルを読み込みます</FunctionDesc ja_jp>*/
%macro RSUExcel__Import(
/*<FunctionArgDesc ja_jp>エクセルファイルフルパス</FunctionArgDesc ja_jp>*/
								i_file_path =
/*<FunctionArgDesc ja_jp>シート名</FunctionArgDesc ja_jp>*/
								, i_sheet_name =
/*<FunctionArgDesc ja_jp>読み込みレンジ</FunctionArgDesc ja_jp>*/
								, i_range =
/*<FunctionArgDesc ja_jp>ヘッダーをスキップするか否か</FunctionArgDesc ja_jp>*/
								, i_skip_header =
/*<FunctionArgDesc ja_jp>出力データセット</FunctionArgDesc ja_jp>*/
								, ods_output_ds =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_sheet_name)
	proc import
			out = &ods_output_ds.
			datafile = "&i_file_path" 
			dbms = xlsx
			replace
		;
		%if (not %&RSUMacroVariable.IsBlank(i_range)) %then %do;
			range = "&i_sheet_name.$&i_range.";
		%end;
		%else %do;
			sheet = "&i_sheet_name.";
		%end;
		getnames = %&RSUUtil.Choose(&i_skip_header., yes, no); 
	run;
	quit;
%mend RSUExcel__Import;

/*<FunctionDesc ja_jp>エクセルの内容をテキストに書き出します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Export Excel content as text</FunctionDesc en_us>*/
%macro RSUExcel__ExportToText(
/*<FunctionArgDesc ja_jp>エクセルファイルフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Full path to the Excel file</FunctionArgDesc en_us>*/
										i_file_path =
/*<FunctionArgDesc ja_jp>シート名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Sheet name</FunctionArgDesc en_us>*/
										, i_sheet_name =
/*<FunctionArgDesc ja_jp>対象データ範囲</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target date range</FunctionArgDesc en_us>*/
										, i_range =
/*<FunctionArgDesc ja_jp>出力ファイル参照</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Refer to the exported file</FunctionArgDesc en_us>*/
										, i_output_fileref =			
/*<FunctionArgDesc ja_jp>変数の長さ決定用ダミー行数</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Dummy row number for determining variable length</FunctionArgDesc en_us>*/
										, i_dummy_row = 0);		  	
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_sheet_name i_output_fileref)
	/*
		NOTE: エクセルファイルをテキスト出力します（データセット読み込み準備） 
		NOTE: Export Excel file as text (Preparation to read the dataset) 
	*/
	%&RSUFile.VerifyExists(i_file_path = &i_file_path.)
	/*
		NOTE: 基本方針
		NOTE: テーブル定義とデータをテキストとして書き出す
		NOTE: テキスト読み込みを行う

		NOTE: Basic Direction
		NOTE: Export table definition and data as text
		NOTE: Import the text		
	*/
	%if (not %RSUExcel__ContainsSheet(i_file_path = &i_file_path., i_sheet_name = &i_sheet_name.)) %then %do;
		%&RSULogger.PutError(%&RSUMsg.NO_EXCEL_SHEET(&i_file_path., &i_sheet_name.))
	%end;

	%local /readonly _TMP_EXCEL_DS = %&RSUDS.GetTempDSName();
	proc import
			out = &_TMP_EXCEL_DS.
			datafile = "&i_file_path" 
			dbms = xlsx
			replace
		;
		%if (not %&RSUMacroVariable.IsBlank(i_range)) %then %do;
			range = "&i_sheet_name.$&i_range.";
		%end;
		%else %do;
			sheet = "&i_sheet_name.";
		%end;
		getnames = no;	/* ! ヘッダーも取り込むために、データはすべて基本的に文字列型になる */ 
		/* ! To import headers as well, all data is converted to character strings */
	run;
	quit;

	%local /readonly _TMP_EXCEL_DEF_DS = %&RSUDS.GetTempDSName();
	%&RSUDS.GetDSDefinition(ids_dataset = &_TMP_EXCEL_DS.
									, ods_definition_ds = &_TMP_EXCEL_DEF_DS.)
	%local _var_list_text;
	%local /readonly _DS_ITER_ALL_VARS = %&RSUDSIterator.Create(&_TMP_EXCEL_DEF_DS.);
	%do %while(%&RSUDSIterator.Next(_DS_ITER_ALL_VARS));
		%&RSUText.Append(iovar_base = _var_list_text
							, i_append_text = %&RSUDSIterator.Current(_DS_ITER_ALL_VARS, variable)
							, i_delimiter = %str(,))
	%end;
	%&RSUDSIterator.Dispose(_DS_ITER_ALL_VARS)
	%&RSUDS.Delete(&_TMP_EXCEL_DEF_DS.)

	data &_TMP_EXCEL_DS.;
		set &_TMP_EXCEL_DS.;
		attrib
			_rsu_line_for_empty_row_ length = $30000.
		;
		_rsu_line_for_empty_row_ = cats(&_var_list_text.);
		if (0 < &i_dummy_row. and _N_ = &i_dummy_row. + 1) then do;
			delete;
		end;
		if (missing(_rsu_line_for_empty_row_)) then do;
			/* 一行全部空の行までが読み込み対象 */
			/* Read all rows until entirely empty row */
			stop;
		end;
		drop
			_rsu_line_for_empty_row_
		;
	run;
	quit;

	/* テキスト書き出し */
	/* Export the text */
	proc export
		data = &_TMP_EXCEL_DS.
		outfile = "&i_output_fileref."
		dbms = tab
		replace
		;
		putnames = no
		;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_EXCEL_DS.)
%mend RSUExcel__ExportToText;
