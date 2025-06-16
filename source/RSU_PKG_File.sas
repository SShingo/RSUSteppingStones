/************************************************************************************/
/* PROGRAM NAME : RSU_PKG_File.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/2/13
/*
/************************************************************************************/
/*<PackageID>RSUFile</PackageID>*/
/*<CategoryID>Cate_ExternalFile</CategoryID>*/
/*<PackagePurpose ja_jp>サーバーのファイル操作</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Handle files on server</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>サーバーのファイル操作に係るマクロ群を提供するパッケージ（Linux）</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating external file (Linux)</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>ファイルパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>File Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSUFile, RSUFile__)

/*******************************************/
/* Public Macros
/*******************************************/
/*<FunctionDesc ja_jp>ファイルの存在を確認します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Check whether the file exists</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>0:ファイルが存在しない、1:ファイルが存在する</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>0:File does not exist,1:File exists</FunctionReturn en_us>*/
%macro RSUFile__Exists(
/*<FunctionArgDesc ja_jp>ファイルのフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file</FunctionArgDesc en_us>*/
								i_file_path
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path)
	%sysfunc(fileexist(&i_file_path.))
%mend RSUFile__Exists;

/*<FunctionDesc ja_jp>ファイルの存在を検証します（存在しない場合はプログラムが中断）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Verify whether the file exists (if not the program will be stopped)</FunctionDesc en_us>*/
%macro RSUFile__VerifyExists(
/*<FunctionArgDesc ja_jp>ファイルのフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file</FunctionArgDesc en_us>*/
										i_file_path
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path)
	%&RSUError.AbortIf(not %RSUFile__Exists(i_file_path = &i_file_path.)
							, i_msg = %&RSUMsg.FILE_NOT_FOUND(&i_file_path.))
%mend RSUFile__VerifyExists;

/*<FunctionDesc ja_jp>ファイルの拡張子を返します（入力文字列の最後のピリオドに続く文字列を拡張子とする）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Return the file's extension (The extension is determined as the characters following the last period)</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>ファイル拡張子</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>The file's extension</FunctionReturn en_us>*/
%macro RSUFile__GetExtension(
/*<FunctionArgDesc ja_jp>ファイルのフルパス、またはファイル名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file or the file name</FunctionArgDesc en_us>*/
										i_file_path
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path)
	%local /readonly _RSU_FILE_PERIOD_POS = %sysfunc(find(&i_file_path., .));
	%local /readonly _EXTENSION = %&RSUUtil.Choose(%eval(&_RSU_FILE_PERIOD_POS. = 0), , %scan(&i_file_path., -1, .));
	&_EXTENSION.
%mend RSUFile__GetExtension;

/*<FunctionDesc ja_jp>フルパスからファイル名を切り出して返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Return the file name from the full path</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>ファイル名</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>file name</FunctionReturn en_us>*/
%macro RSUFile__GetFileName(
/*<FunctionArgDesc ja_jp>ファイルフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file</FunctionArgDesc en_us>*/
									i_file_path
/*<FunctionArgDesc ja_jp>拡張子を含めるか否か</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Whether to include the extension or not</FunctionArgDesc en_us>*/
									, i_extension = %&RSUBool.True
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path)
	%local _last_entry_name;
	%let _last_entry_name = %scan(&i_file_path., -1, &RSU_G_PATH_SEPARATOR.);
	%if (not &i_extension.) %then %do;
		%let _last_entry_name = %scan(&_last_entry_name., 1, .);
	%end;
	&_last_entry_name.
%mend RSUFile__GetFileName;

/*<FunctionDesc ja_jp>フルパスからディレクトリパス（親ディレクトリパス）を切り出して返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Return the directory path (parent directory) from the full path</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>ディレクトリパス</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Directory path</FunctionReturn en_us>*/
%macro RSUFile__GetDir(
/*<FunctionArgDesc ja_jp>ファイルフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file</FunctionArgDesc en_us>*/
								i_file_path
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path)
	%local /readonly _RSU_FILE_START_POS = -%length(&i_file_path.);
	%local /readonly _RSU_FILE_SLASH_POS = %sysfunc(find(&i_file_path, &RSU_G_PATH_SEPARATOR., i, &_RSU_FILE_START_POS.));
	%local /readonly _DIR = %&RSUUtil.Choose(%eval(&_RSU_FILE_SLASH_POS. = 0 or &_RSU_FILE_SLASH_POS. = 1), , %substr(&i_file_path., 1, &_RSU_FILE_SLASH_POS. - 1));
	&_DIR.
%mend RSUFile__GetDir;

/*<FunctionDesc ja_jp>ファイルの内容をログに出力します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Output the file's content to the log</FunctionDesc en_us>*/
%macro RSUFile__Print(
/*<FunctionArgDesc ja_jp>ファイルのフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file</FunctionArgDesc en_us>*/
							i_file_path
/*<FunctionArgDesc ja_jp>最大表示行数</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Maximum rows to be displayed</FunctionArgDesc en_us>*/
							, i_line_size = 500
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path)
	%local /readonly _RSU_FILE_FILE_ITERATOR = %RSUFile__CreateTextReader(i_file_path = &i_file_path.);
	%local _line;
	%do %while(%&_RSU_FILE_FILE_ITERATOR.Next()
				and %&RSUCounter.Draw(i_start = 1) <= &i_line_size.);
		%let _line = %&_RSU_FILE_FILE_ITERATOR.Current();
		%put &_line.;
	%end;
	%&RSUClass.Dispose(_RSU_FILE_FILE_ITERATOR)
%mend RSUFile__Print;

/*<FunctionDesc ja_jp>ファイルを削除します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Delete the file</FunctionDesc en_us>*/
%macro RSUFile__Delete(
/*<FunctionArgDesc ja_jp>削除ファイルフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file to be deleted</FunctionArgDesc en_us>*/
								i_file_path
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path)
	%if (not %RSUFile__Exists(i_file_path = &i_file_path.)) %then %do;
		%return;
	%end;
	%local _filrf;
	%let _filrf = %RSUFile__GetFileRef(&i_file_path.);
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fdelete(&_filrf.)))
	%RSUFile__ClearFileRef(_filrf);
%mend RSUFile__Delete;

/*<FunctionDesc ja_jp>ファイルをコピーします</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Copy the file</FunctionDesc en_us>*/
%macro RSUFile__Copy(
/*<FunctionArgDesc ja_jp>コピー元ファイルフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file to be copied</FunctionArgDesc en_us>*/
						i_file_path =
/*<FunctionArgDesc ja_jp>コピー先ディレクトリパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the destination directory</FunctionArgDesc en_us>*/
						, i_dir_path =
/*<FunctionArgDesc ja_jp>コピー先ファイル名（省略時は元ファイルと同一名称）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The name of the destination file (If omitted, the same name as the original file)</FunctionArgDesc en_us>*/
						, i_file_name_new =
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_dir_path)
	/* Excelファイルはfcopyでコピーできない
		そこでbyte-by-byteであらゆるファイルを複製するようにした
		参考
		https://blogs.sas.com/content/sasdummy/2011/06/17/how-to-use-sas-data-step-to-copy-a-file-from-anywhere/
	*/
	/* Excel files cannot be copied using fcopy 
		Hence all file are copied byte-by-byte
		Reference
		https://blogs.sas.com/content/sasdummy/2011/06/17/how-to-use-sas-data-step-to-copy-a-file-from-anywhere/
	*/
	%local _file_path_dest;
	%if (%&RSUMacroVariable.IsBlank(i_file_name_new)) %then %do;
		%local /readonly _DEST_FILE_NAME = %RSUFile__GetFileName(i_file_path = &i_file_path.);
		%let _file_path_dest = &i_dir_path.&RSU_G_PATH_SEPARATOR.&_DEST_FILE_NAME.;
	%end;
	%else %do;
		%let _file_path_dest = &i_dir_path.&RSU_G_PATH_SEPARATOR.&i_file_name_new.;
	%end;
	%local _fref_src_file;
	%let _fref_src_file = %RSUFile__GetFileRef(&i_file_path.);
	%local _fref_dest_file;
	%let _fref_dest_file = %RSUFile__GetFileRef(&_file_path_dest.);
	data _null_;
		attrib
			filein length = 8
			fileid length = 8
		;
		filein = fopen("&_fref_src_file.", 'I', 1, 'B');
		fileid = fopen("&_fref_dest_file.", 'O', 1, 'B');
		rec = '20'x;
		do while(fread(filein) = 0);
			rc = fget(filein, rec, 1);
			rc = fput(fileid, rec);
			rc = fwrite(fileid);
		end;
		rc = fclose(filein);
		rc = fclose(fileid);
	run;
	quit;
	%RSUFile__ClearFileRef(_fref_dest_file)
	%RSUFile__ClearFileRef(_fref_src_file)
%mend RSUFile__Copy;

/*<FunctionDesc ja_jp>ファイルを移動します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Move the file</FunctionDesc en_us>*/
%macro RSUFile__Move(
/*<FunctionArgDesc ja_jp>移動元ファイルフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file to be moved</FunctionArgDesc en_us>*/
							i_file_path =
/*<FunctionArgDesc ja_jp>移動先ディレクトリパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the destination directory</FunctionArgDesc en_us>*/
							, i_dir_path =
/*<FunctionArgDesc ja_jp>移動後ファイル名（省略時は元ファイルと同一名称）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The name of the destination file (If omitted, the same name as the original file)</FunctionArgDesc en_us>*/
							, i_file_name_new =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_dir_path)
	%RSUFile__Copy(i_file_path = &i_file_path.
						, i_dir_path = &i_dir_path.
						, i_file_name_new = &i_file_name_new.)
	%RSUFile__Delete(i_file_path = &i_file_path.)
%mend RSUFile__Move;

/*<FunctionDesc ja_jp>ファイルの名称を変更します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Change the name of the file</FunctionDesc en_us>*/
%macro RSUFile__Rename(
/*<FunctionArgDesc ja_jp>元ファイルフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the file to be changed</FunctionArgDesc en_us>*/
							i_file_path =
/*<FunctionArgDesc ja_jp>新ファイル名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>New file name</FunctionArgDesc en_us>*/
							, i_file_name_new =
/*<FunctionArgDesc ja_jp>ファイル名フィルタ（拡張子を除く）</FunctionArgDesc ja_jp>*/
							, i_file_name_regex =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_dir_path)
	%RSUFile__Move(i_file_path = &i_file_path.
						, i_dir_path = %RSUFile__GetDir(i_file_path = &i_file_path.)
						, i_file_name_new = &i_file_name_new.)
%mend RSUFile__Rename;

/*<FunctionDesc ja_jp>ディレクトリ内の .sas ファイルをインクルードします</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Include the .sas files in the directory/FunctionDesc en_us>*/
%macro RSUFile__IncludeSASCodeIn(
/*<FunctionArgDesc ja_jp>.sasファイルを保持しているディレクトリフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path to the directory that contains the .sas files</FunctionArgDesc en_us>*/
											i_dir_path
/*<FunctionArgDesc ja_jp>サブディレクトリも含めるか否か</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Whether to include the subdirectories or not</FunctionArgDesc en_us>*/
											, i_is_recursive = %&RSUBool.True
/*<FunctionArgDesc ja_jp>ログを抑制するか否か</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Whether to supress the log or not</FunctionArgDesc en_us>*/
											, i_is_silent_mode = %&RSUBool.True
/*<FunctionArgDesc ja_jp>拡張子を除くファイル名のフィルタ（正規表現）</FunctionArgDesc ja_jp>*/
											, i_file_name_regex =
/*<FunctionArgDesc ja_jp>優先読み込みファイルリスト</FunctionArgDesc ja_jp*/
											, i_priority_files =
											);
/*<FunctionNote ja_jp>
拡張子（.sas）部はcase insensitive です。
</FunctionNote ja_jp>*/
	%&RSUUtil.VerifyRequiredArgs(i_args = i_dir_path)
	%if (&i_is_recursive.) %then %do;
		%&RSULogger.PutParagraph(%&RSUMsg.INCLUDE_ALL_R(&i_dir_path.))
	%end;
	%else %do;
		%&RSULogger.PutParagraph(%&RSUMsg.INCLUDE_ALL(&i_dir_path.))
	%end;
	%local /readonly _TMP_FILES_DS = %&RSUDS.GetTempDSName();
	%&RSUDirectory.GetContents(i_dir_path = &i_dir_path.
										, ods_output_ds = &_TMP_FILES_DS.
										, i_content_type = %&RSUFileType.File
										, i_regex = /&i_file_name_regex.\.[sS][aA][sS]$/
										, i_is_recursive = &i_is_recursive.)

	%if (not %&RSUMacroVariable.IsBlank(i_priority_files)) %then %do;
		%local _priority_file;
		%local _index_priority_file;
		%local /readonly _TMP_DS_PRIORITY_FILE_LIST = %&RSUDS.GetTempDSName();

		data _null_;
			attrib
				_index length = 8.
				_entry_name length = $100.
			;
			declare hash hh_priority_files();
			_rc = hh_priority_files.definekey('_index');
			_rc = hh_priority_files.definekey('_entry_name');
			_rc = hh_priority_files.definedone();
		%do %while(%&RSUUtil.ForEach(i_items = &i_priority_files.
											, ovar_item = _priority_file
											, iovar_index = _index_priority_file));
			_index = &_index_priority_file.;
			_entry_name = "&_priority_file.";
			_rc = hh_priority_files.add();
		%end;
			_rc = hh_priority_files.output(dataset: "&_TMP_DS_PRIORITY_FILE_LIST.");
		run;
		quit;

		proc sort data = &_TMP_DS_PRIORITY_FILE_LIST. out = &_TMP_DS_PRIORITY_FILE_LIST.(drop = _index);
			by
				_index
			;
		run;
		quit;

		%local /readonly _TMP_DS_HI_PRIORITY_FILES = %&RSUDS.GetTempDSName();
		data &_TMP_DS_HI_PRIORITY_FILES.;
			if (_N_ = 0) then do;
				set &_TMP_FILES_DS.;
			end;
			set &_TMP_DS_PRIORITY_FILE_LIST.;
			if (_N_ = 1) then do;
				declare hash hh_hi_priority(dataset: "&_TMP_FILES_DS.");
				_rc = hh_hi_priority.definekey('_entry_name');
				_rc = hh_hi_priority.definedata(all: 'yes');
				_rc = hh_hi_priority.definedone();
			end;
			_rc = hh_hi_priority.find();
		run;
		quit;

		%local /readonly _TMP_DS_LOW_PRIORITY_FILES = %&RSUDS.GetTempDSName();
		data &_TMP_DS_LOW_PRIORITY_FILES.;
			if (_N_ = 0) then do;
				set &_TMP_DS_PRIORITY_FILE_LIST.;
			end;
			set &_TMP_FILES_DS.;
			if (_N_ = 1) then do;
				declare hash hh_low_priority(dataset: "&_TMP_DS_PRIORITY_FILE_LIST.");
				_rc = hh_low_priority.definekey('_entry_name');
				_rc = hh_low_priority.definedone();
			end;
			_rc = hh_low_priority.find();
			if (_rc ne 0) then do;
				output;
			end;
		run;
		quit;

		data &_TMP_FILES_DS.;
			set
				&_TMP_DS_HI_PRIORITY_FILES.
				&_TMP_DS_LOW_PRIORITY_FILES.
			;
		run;
		quit;

		%&RSUDS.Delete(&_TMP_DS_PRIORITY_FILE_LIST. &_TMP_DS_HI_PRIORITY_FILES. &_TMP_DS_LOW_PRIORITY_FILES.)
	%end;

	%local /readonly _RSU_FILE_NO_OF_FILES = %&RSUDS.GetCount(&_TMP_FILES_DS.);
	%if (0 < &_RSU_FILE_NO_OF_FILES.) %then %do;
		%local _entry_full_path;
		%local /readonly _DS_ITER_CONTENTS = %&RSUDSIterator.Create(&_TMP_FILES_DS.);
		%do %while(%&RSUDSIterator.Next(_DS_ITER_CONTENTS));
			%let _entry_full_path = %&RSUDSIterator.Current(_DS_ITER_CONTENTS, _entry_full_path);
			%if (not &i_is_silent_mode.) %then %do;
				%&RSULogger.PutNote(%&RSUMsg.FILE_INCLUDING(&_entry_full_path.))
			%end;
			%include "&_entry_full_path.";
			%if (not &i_is_silent_mode.) %then %do;
				%&RSULogger.PutInfo(%&RSUMsg.FILE_INCLUDED(&_entry_full_path.))
			%end;
		%end;
		%&RSUDSIterator.Dispose(_DS_ITER_CONTENTS)
		%&RSULogger.PutInfo(&_RSU_FILE_NO_OF_FILES. file(s) included)
	%end;
	%else %do;
		%&RSULogger.PutInfo(no file included)
	%end;
	%&RSUDS.Delete(&_TMP_FILES_DS.)
%mend RSUFile__IncludeSASCodeIn;

/*<FunctionDesc ja_jp>ファイル参照を返します。戻り値は "/readonly"で受け取らないこと（ファイル参照の開放ができなくなります）。</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns file reference. Avoid "/readonly" return value in order to release file reference</FunctionDesc en_us>*/
%macro RSUFile__GetFileRef(
/*<FunctionArgDesc ja_jp>ファイルパス（省略時は一時ファイルになります）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The file path (if omitted, it will be a temporary file)</FunctionArgDesc en_us>*/
									i_file_path
									);
	%local _rsu_file_tmp_fileref_name;
	%if (%&RSUMacroVariable.IsBlank(i_file_path)) %then %do;
		%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(filename(_rsu_file_tmp_fileref_name, ,temp)))
	%end;
	%else %do;
		%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(filename(_rsu_file_tmp_fileref_name, &i_file_path.)))
	%end;
	&_rsu_file_tmp_fileref_name.
%mend RSUFile__GetFileRef;

/*<FunctionDesc ja_jp>ファイル参照を解放します。</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Release the file reference</FunctionDesc en_us>*/
%macro RSUFile__ClearFileRef(
/*<FunctionArgDesc ja_jp>ファイル参照を保持しているマクロ変数</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Macro variable that contains the file reference</FunctionArgDesc en_us>*/
										i_fileref
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_fileref)
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(filename(&i_fileref.)))
%mend RSUFile__ClearFileRef;

