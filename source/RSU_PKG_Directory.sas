/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Dir.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* PROGRAMMER : Shingo Suzuki (RSU SAS Institute Japan)
/* DATE WRITTEN : 2021/3/08
/*
/************************************************************************************/
/*<PackageID>RSUDir</PackageID>*/
/*<CategoryID>Cate_ExternalFile</CategoryID>*/
/*<PackagePurpose ja_jp>ディレクトリの操作</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Manipulate Directories</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>サーバーのディレクトリの操作、アクセス関連のマクロ群を提供するパッケージ (Linux)</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating external direcotry(Linux)</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>ディレクトリパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Directory Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSUDirectory, RSUDir__)

/*<FunctionDesc ja_jp>ディレクトリが存在しているか否かを返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Return whether the directory exists</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>0: 指定ディレクトリが存在していない\quad 1: 指定ディレクトリが存在する</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>0: Target directory does not exist\quad 1: Target directory exists</FunctionReturn en_us>*/
%macro RSUDir__Exists(
/*<FunctionArgDesc ja_jp>ディレクトリパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Directory path</FunctionArgDesc en_us>*/
							i_dir_path
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_dir_path)
	%sysfunc(fileexist(&i_dir_path.))
%mend RSUDir__Exists;

/*<FunctionDesc ja_jp>ディレクトリが存在しているか否かを検証します（検証失敗時には処理が中断されます）</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Validate whether the directory exists or not（If the validation fails, the process will be stopped）</FunctionDesc en_us>*/
%macro RSUDir__VerifyExists(i_dir_path =);
/*<FunctionArgDesc ja_jp>ディレクトリパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Directory path</FunctionArgDesc en_us>*/
	%if (not %RSUDir__Exists(i_dir_path = &i_dir_path.)) %then %do;
		%&RSULogger.PutError(%&RSUMsg.FILE_NOT_FOUND(&i_dir_path.))
	%end;
%mend RSUDir__VerifyExists;

/*<FunctionDesc ja_jp>指定ディレクトリの内容（ファイル、ディレクトリ）をデータセットに格納します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Store the contents of the target directory (files and direcotries) in a dataset</FunctionDesc en_us>*/
%macro RSUDir__GetContents(
/*<FunctionArgDesc ja_jp>ディレクトリパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Directory path</FunctionArgDesc en_us>*/
									i_dir_path =
/*<FunctionArgDesc ja_jp>出力データセット</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Output dataset</FunctionArgDesc en_us>*/
									, ods_output_ds =
/*<FunctionArgDesc ja_jp>対象コンテンツ種別</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target contents type</FunctionArgDesc en_us>*/
									, i_content_type = %&RSUFileType.Both
/*<FunctionArgDesc ja_jp>サブディレクトリも走査するか否か</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Whether to scan the subdirectories or not</FunctionArgDesc en_us>*/
									, i_is_recursive = %&RSUBool.True
/*<FunctionArgDesc ja_jp>ファイル名フィルター用正規表現</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Regular expressions to filter the file name</FunctionArgDesc en_us>*/
									, i_regex =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_dir_path ods_output_ds)
	%local /readonly _TMP_CONTENT_LIST = %&RSUDS.GetTempDSName();
	data &_TMP_CONTENT_LIST.;
		attrib
			_entry_type length = $1.
			_entry_name length = $100.
			_entry_parent_path length = $1000.
			_entry_full_path length = $1000.
		;
		stop;
	run;

	%Prv_RSUDir_GetContentsHelper(i_dir_path = &i_dir_path.
											, ods_output_ds = &_TMP_CONTENT_LIST.
											, i_is_recursive = &i_is_recursive.)

	%if (not %&RSUMacroVariable.IsBlank(i_regex)) %then %do;
		data &_TMP_CONTENT_LIST.;
			set &_TMP_CONTENT_LIST.;
			if (prxmatch("&i_regex.", trim(_entry_name))) then do;
				output;
			end;
		run;
		quit;
	%end;
	%if (%upcase(&i_content_type.) = %&RSUFileType.File) %then %do;
		%RSUDS__Let(i_query = &_TMP_CONTENT_LIST.(where = (_entry_type = "%&RSUFileType.File"))
						, ods_dest_ds = &ods_output_ds.)
	%end;
	%else %if (%upcase(&i_content_type.) = %&RSUFileType.Directory) %then %do;
		%RSUDS__Let(i_query = &_TMP_CONTENT_LIST.(where = (_entry_type = "%&RSUFileType.Directory"))
						, ods_dest_ds = &ods_output_ds.)
	%end;
	%else %do;
		%RSUDS__Let(i_query = &_TMP_CONTENT_LIST.
						, ods_dest_ds = &ods_output_ds.)
	%end;
	data &ods_output_ds.;
		set &ods_output_ds.;
		index = _N_;
	run;
	quit;
	%&RSUDS.Delete(&_TMP_CONTENT_LIST.)
%mend RSUDir__GetContents;

/*<FunctionDesc ja_jp>ディレクトリを作成します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Create directory</FunctionDesc en_us>*/
%macro RSUDir__CreateDir(
/*<FunctionArgDesc ja_jp>作成ディレクトリパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target directory path</FunctionArgDesc en_us>*/
								i_dir_path
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_dir_path);
	/*
		! 再帰呼び出しがあるので readonly は使えない
		! Cannot use readonly because of the recursive call 
	*/
	%local _the_last_char;
	%let _the_last_char = %&RSUText.Right(&i_dir_path., 1);
	%local _target_dir_path;
	%local _target_dir_len;
	%if (%&RSUUtil.Eq(_the_last_char, RSU_G_PATH_SEPARATOR)) %then %do;
		%if (%&RSUText.Length(&i_dir_path.) = 1) %then %do;
			%return;
		%end;
		%let _target_dir_path = %&RSUText.Left(&i_dir_path., %&RSUText.Length(&i_dir_path.) - 1);
	%end;
	%else %do;
		%let _target_dir_path = &i_dir_path.;
	%end;
	%let _target_dir_len = %&RSUText.Length(&_target_dir_path.);

	%if (not %RSUDir__Exists(&_target_dir_path.)) %then %do;
		%local _creating_dir_name;
		%let _creating_dir_name = %scan(&_target_dir_path., -1, &RSU_G_PATH_SEPARATOR.);
		%local _creating_dir_name_len;
		%let _creating_dir_name_len = %&RSUText.Length(&_creating_dir_name);
		%local _creating_parent_dir_path;
		%let _creating_parent_dir_path = %&RSUText.Left(&_target_dir_path., %eval(&_target_dir_len. - &_creating_dir_name_len.));
		%if (not %&RSUDirectory.Exists(&_creating_parent_dir_path.)) %then %do;
			%RSUDir__CreateDir(&_creating_parent_dir_path.)
		%end;

		%local _created_dir_name;
		%let _created_dir_name = %sysfunc(dcreate(&_creating_dir_name, &_creating_parent_dir_path.));
		%if (%&RSUMacroVariable.IsBlank(_created_dir_name)) %then %do;
			%&RSULogger.PutError(%sysfunc(sysmsg()))
			%&RSULogger.PutError(%&RSUMsg.FAIL_CREATE_DIR(&_creating_parent_dir_path.&RSU_G_PATH_SEPARATOR.&_creating_dir_name.))
			%return;
		%end;
		%else %do;
			%&RSULogger.PutNote(%&RSUMsg.DIR_CREATED(&_created_dir_name))
			%return;
		%end;
	%end;
	%else %do;
		%&RSULogger.PutNote(%&RSUMsg.DIR_ALREADY_EXISTS(&_target_dir_path))
	%end;
%mend RSUDir__CreateDir;

/*<FunctionDesc ja_jp>指定ディレクトリ内をクリアします</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Clear the target directory</FunctionDesc en_us>*/
%macro RSUDir__ClearDir(
/*<FunctionArgDesc ja_jp>クリア対象のディレクトリパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target directory path</FunctionArgDesc en_us>*/
								i_dir_path
/*<FunctionArgDesc ja_jp>最上位ディレクトリを残すか否か</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Whether to keep the root directory</FunctionArgDesc en_us>*/
								, i_remove_root = %&RSUBool.False
/*<FunctionArgDesc ja_jp>サブディレクトリは残す場合は1を指定します（ファイルのみ削除）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>To keep subdirectory, select 1 (delete only the files)</FunctionArgDesc en_us>*/
								, i_is_keep_dir = %&RSUBool.True
/*<FunctionArgDesc ja_jp>サブディレクトリ内もクリアする場合は 1 を指定します</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>To clear contents within the subdirectory, select 1</FunctionArgDesc en_us>*/
								, i_is_recursive = %&RSUBool.True
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_dir_path);
	%local /readonly _CONTENT_TYPE = %&RSUUtil.Choose(&i_is_keep_dir., %&RSUFileType.File, %&RSUFileType.Both);

	%local /readonly _TMP_CONTENTS_LIST = %&RSUDS.GetTempDSName();
	%RSUDir__GetContents(i_dir_path = &i_dir_path.
								, ods_output_ds = &_TMP_CONTENTS_LIST.
								, i_content_type = &_content_type.
								, i_is_recursive = &i_is_recursive.)
	%local /readonly _DS_ITER_CONTENTS = %&RSUDSIterator.Create(&_TMP_CONTENTS_LIST.);
	%local _tmp_fref;
	%local _rsu_dir_clear_rc;
	%do %while(%&RSUDSIterator.Next(_DS_ITER_CONTENTS));
		%let _tmp_fref = %&RSUFile.GetFileRef(%&RSUDSIterator.Current(_DS_ITER_CONTENTS, _entry_full_path));
		%let _rsu_dir_clear_rc = %sysfunc(fdelete(&_tmp_fref.));
		%if (&_rsu_dir_clear_rc. ne 0) %then %do;
			%&RSULogger.PutWarning(%sysfunc(sysmsg()));
		%end;
		%&RSUFile.ClearFileRef(_tmp_fref)
	%end;
	%&RSUDSIterator.Dispose(_DS_ITER_CONTENTS)
	%&RSUDS.Delete(&_TMP_CONTENTS_LIST.)
	%if (&i_remove_root. and not &i_is_keep_dir.) %then %do;
		%let _tmp_fref = %&RSUFile.GetFileRef(&i_dir_path.);
		%let _rsu_dir_clear_rc = %sysfunc(fdelete(&_tmp_fref.));
		%&RSUFile.ClearFileRef(_tmp_fref)
		%if (%&RSUDirectory.Exists(&i_dir_path.)) %then %do;
			%&RSULogger.PutError(%&RSUMsg.FAIL_DELETE_DIR(&i_dir_path.))
		%end;
	%end;
%mend RSUDir__ClearDir;

/*<FunctionDesc ja_jp>（x command バージョン）ディレクトリを作成します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>(x command version) Create directory</FunctionDesc en_us>*/
%macro RSUDir__CreateDirX(
/*<FunctionArgDesc ja_jp>作成ディレクトリパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target directory path</FunctionArgDesc en_us>*/
									i_dir_path
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_dir_path);
	x mkdir -p &i_dir_path.;
%mend RSUDir__CreateDirX;

/*<FunctionDesc ja_jp>（x command バージョン）指定ディレクトリ内をクリアします</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>(x command version) Clear the target directory</FunctionDesc en_us>*/
%macro RSUDir__ClearDirX(
/*<FunctionArgDesc ja_jp>クリア対象のディレクトリパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target directory path</FunctionArgDesc en_us>*/
								i_dir_path =
/*<FunctionArgDesc ja_jp>サブディレクトリは残す場合は1を指定します（ファイルのみ削除）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>To keep subdirectory, select 1 (delete only the files)</FunctionArgDesc en_us>*/
								, i_keep_dir =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_dir_path);
	%if (&i_keep_dir = 1) %then %do;
		x find &i_dir_path. -type f -delete;
	%end;
	%else %do;
		x rm -rf "&i_dir_path./"*;
	%end;
%mend RSUDir__ClearDirX;