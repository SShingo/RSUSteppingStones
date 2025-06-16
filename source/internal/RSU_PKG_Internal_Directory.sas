%macro Prv_RSUDir_GetContentsHelper(i_dir_path =
												, ods_output_ds =
												, i_is_recursive =);
	/*
		! 再帰呼び出しのため、マクロ変数はreadonlyに出来ない
	*/
	%&RSUDebug.PutLog(&ods_output_ds.)
	%&RSUDebug.PutLog(&i_dir_path.)
	%RSUFile__VerifyExists(&i_dir_path.)

	%local _tmp_fileref_parent_dir;
	%let _tmp_fileref_parent_dir = %&RSUFile.GetFileRef(&i_dir_path.);
	%local _did_parent_dir;
	%let _did_parent_dir = %Int_RSUUtil_VerifyID(i_id = %sysfunc(dopen(&_tmp_fileref_parent_dir)));	
	%local _no_of_entries_in_parent_dir;
	%let _no_of_entries_in_parent_dir = %sysfunc(dnum(&_did_parent_dir));

	%local _entry_name;
	%local _entry_path;
	%local _entry_index;
	%local _tmp_fileref_child_dir;
	%do _entry_index = 1 %to &_no_of_entries_in_parent_dir.;	/* ディレクトリに含まれる全オブジェクト（ファイル、ディレクトリ）についてループ  */
		%let _entry_name = %qsysfunc(dread(&_did_parent_dir, &_entry_index));
		%let _entry_path = &i_dir_path.&RSU_G_PATH_SEPARATOR.&_entry_name.;
		%let _tmp_fileref_child_dir = %&RSUFile.GetFileRef(&_entry_path.);
		%let _did_child_dir = %sysfunc(dopen(&_tmp_fileref_child_dir.));	/* ディレクトリを開く */
		%if (0 < &_did_child_dir.) %then %do;
			/* オープン成功: このオブジェクトはディレクトリ */
			%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(dclose(&_did_child_dir.)))
			%&RSUFile.ClearFileRef(_tmp_fileref_child_dir)
			%&RSUDebug.PutLog("&_entry_path." is directory)
			%if (&i_is_recursive.) %then %do;
				/* 再帰呼び出し */
				%&RSUDebug.PutLog(Move to child directory "&_entry_path.")
				%Prv_RSUDir_GetContentsHelper(i_dir_path = &_entry_path.
														, ods_output_ds = &ods_output_ds.
														, i_is_recursive = &i_is_recursive.)
			%end;
			proc sql;
				insert into &ods_output_ds.(_entry_type, _entry_name, _entry_parent_path, _entry_full_path)
				values("%&RSUFileType.Directory", "&_entry_name.", "&i_dir_path.", "&_entry_path.");
			quit;
		%end;
		%else %do;
			/* オープン失敗: このオブジェクトはファイル */
			%&RSUFile.ClearFileRef(_tmp_fileref_child_dir)
			%&RSUDebug.PutLog("&_entry_path." is file)
			proc sql;
				insert into &ods_output_ds.(_entry_type, _entry_name, _entry_parent_path, _entry_full_path)
				values("%&RSUFileType.File", "&_entry_name.", "&i_dir_path.", "&_entry_path.");
			quit;
		%end;
	%end;
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(dclose(&_did_parent_dir.)))
	%&RSUFile.ClearFileRef(_tmp_fileref_parent_dir)
%mend Prv_RSUDir_GetContentsHelper;
