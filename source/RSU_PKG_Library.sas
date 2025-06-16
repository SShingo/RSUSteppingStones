/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Lib.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/3/14
/*
/************************************************************************************/
/*<PackageID>RSULib</PackageID>*/
/*<CategoryID>Cate_DataHandling</CategoryID>*/
/*<PackagePurpose ja_jp>ライブラリ操作</PackagePurpose ja_jp>*/
/*<PackageDesc ja_jp>ライブラリに対する操作を行うマクロ群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions for SAS library</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>ライブラリパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Library Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSULib, RSULib__)
/*<ConstantDesc ja_jp>ライブラリクラス定義ファイル名</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Library definition file name</ConstantDesc en_us>*/
%RSUSetConstant(RSU_G_CLASS_FILE_LIB, RSU_PKG_Class_Lib)

/*<FunctionDesc ja_jp>ライブラリをアサインされているか否かを返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns whether the library is assigned or not</FunctionDesc en_us>*/
%macro RSULib__IsAssigned(
/*<FunctionArgDesc ja_jp>ライブラリ名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>library name</FunctionArgDesc en_us>*/
									i_libname
								);
	%eval(%sysfunc(libref(&i_libname.)) = 0)
%mend RSULib__IsAssigned;

/*<FunctionDesc ja_jp>ライブラリをアサインします</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Assign a library</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>ライブラリの物理名</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Physical name of the library</FunctionReturn en_us>*/
%macro RSULib__Assign(
/*<FunctionArgDesc ja_jp>ライブラリにアサインされるディレクトリフルパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>The full path of the directory to be assigned to the library</FunctionArgDesc en_us>*/
							i_dir_path =
/*<FunctionArgDesc ja_jp>ライブラリエンジン</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Library engine</FunctionArgDesc en_us>*/
							, i_engine =
/*<FunctionArgDesc ja_jp>ライブラリオプション</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Library options</FunctionArgDesc en_us>*/
							, i_options =
							);
	%&RSUDirectory.VerifyExists(i_dir_path = &i_dir_path)
	%local /readonly _RSU_LIB_LIBBANE = %Int_RSULib_GetTempLibName();
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(libname(&_RSU_LIB_LIBBANE., &i_dir_path., &i_engine., &i_options.)))
	%local /readonly _RSU_LIB_INSTANCE = %Int_RSUClass_Create(i_template_name = &RSU_G_CLASS_FILE_LIB);
	%Int_&_RSU_LIB_INSTANCE.Initialize(i_libname = &_RSU_LIB_LIBBANE.)
	&_RSU_LIB_INSTANCE.
%mend RSULib__Assign;

/*<FunctionDesc ja_jp>ライブラリを解放します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Deassign the library</FunctionDesc en_us>*/
%macro RSULib__Deassign(
/*<FunctionArgDesc ja_jp>ライブラリ名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Library name</FunctionArgDesc en_us>*/
								i_libname
								);
	%if (%sysfunc(libref(&i_libname.)) = 0) %then %do;
		libname &i_libname. clear;
	%end;
%mend RSULib__Deassign;

/*<FunctionDesc ja_jp>ライブラリの割り当てディレクトリのフルパスを取得します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Get the full path of the directory assigned to the library</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>ライブラリの割り当てディレクトリパス</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>The path of the directory assigned to the library</FunctionReturn en_us>*/
%macro RSULib__GetPath(
/*<FunctionArgDesc ja_jp>対象ライブラリ名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target library name</FunctionArgDesc en_us>*/
								i_libname
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_libname)
	%sysfunc(pathname(&i_libname.))
%mend RSULib__GetPath;

/*<FunctionDesc ja_jp>ライブラリが空か否かを返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Return whether the library is empty or not</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.True: ライブラリは空\quad \%\&RSUBool.False: ライブラリにデータセットが存在する</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>\%\&RSUBool.True: Library is empty\quad \%\&RSUBool.False: Library has a dataset</FunctionReturn en_us>*/
%macro RSULib__IsLibEmpty(
/*<FunctionArgDesc ja_jp>対象ライブラリ名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target library name</FunctionArgDesc en_us>*/
									i_libname
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_libname)
	%Local /readonly _RSU_LIB_NO_OF_DS = %&RSUDS.GetCount(ids_dataset = SASHELP.vtable(where = (upcase(libname) = "%upcase(&i_libname.)")));
	%&RSUUtil.Choose(%eval(&_RSU_LIB_NO_OF_DS. = 0), %&RSUBool.True, %&RSUBool.False)
%mend RSULib__IsLibEmpty;

/*<FunctionDesc ja_jp>ライブラリ内のデータセット配列を取得します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Get the dataset array inside the library</FunctionDesc en_us>*/
/*<Return ja_jp>ライブラリ内のデータセット名の配列</Return ja_jp>*/
/*<Return en_us>Dataset name array inside the library</Return en_us>*/
%macro RSULib__GetDSInLib(
/*<FunctionArgDesc ja_jp>対象ライブラリ名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target library name</FunctionArgDesc en_us>*/
									i_libname
									);
	/* データセットリストをマクロ変数に保持 */
	/* ! データセット名（エクセルシート名）にはスペースが入る可能性があるので、単純な文字列連結は難しい */
	%&RSUUtil.VerifyRequiredArgs(i_args = i_libname)
	%local _array_excel_sheets;
	%&RSUArray.CreateByDataset(SASHELP.vmember(where = (upcase(libname) = "%upcase(&i_libname.)" and memtype = 'DATA'))
										, memname
										, _array_excel_sheets);
	&_array_excel_sheets.
%mend RSULib__GetDSInLib;

/*<FunctionDesc ja_jp>ライブラリ内のデータセットをすべて削除します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Clear all datasets inside the library</FunctionDesc en_us>*/
%macro RSULib__ClearLib(
/*<FunctionArgDesc ja_jp>対象ライブラリ名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target library name</FunctionArgDesc en_us>*/
								i_libname
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_libname)
	proc datasets lib = &i_libname. kill nodetails nolist;
	run;
	quit;
%mend RSULib__ClearLib;

/*<FunctionDesc ja_jp>ライブラリ内のデータセットを指定ディレクトリにコピーします</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Copy all datasets inside the library to a target directory</FunctionDesc en_us>*/
%macro RSULib__CopyDSInLib(
/*<FunctionArgDesc ja_jp>コピー対象ライブラリ名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target library name</FunctionArgDesc en_us>*/
									i_libname =
/*<FunctionArgDesc ja_jp>コピー先ディレクトリパス</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Target directory path</FunctionArgDesc en_us>*/
									, i_dir_path =
/*<FunctionArgDesc ja_jp>データセットフィルター用正規表現</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Regular expression for filtering the dataset</FunctionArgDesc en_us>*/
									, i_dsname_regex =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_libname i_dir_path)
	%&RSUDirectory.VerifyExists(i_dir_path = &i_dir_path)
	/* コピー対象 */
	/* Copy target */
	%local /readonly _RSU_LIB_DS_LIST = %&RSUDS.GetTempDSName();
	%&RSUDS.Let(i_query = SASHELP.vmember(where = (upcase(libname) = "%upcase(&i_libname.)" and memtype = 'DATA'))
					, ods_dest_ds = &_RSU_LIB_DS_LIST.)

	%local _select_code;
	%if (not %&RSUDS.IsDSEmpty(&_RSU_LIB_DS_LIST.)) %then %do;
		%if (not %&RSUMacroVariable.IsBlank(i_dsname_regex)) %then %do;
			data &_RSU_LIB_DS_LIST.;
				set &_RSU_LIB_DS_LIST.;
				_dsname_regex = prxparse(cats('/', "&i_dsname_regex.", '/io'));
				if (prxmatch(_dsname_regex, memname)) then do;
					output;
				end;
			run;
			quit;

			data _null_;
				attrib
					_ds_names length = $1000.
				;
				retain _ds_names 'SELECT';
				set &_RSU_LIB_DS_LIST. end = eof;
				_ds_names = cat(_ds_names, ' ', memname);
				if (eof) then do;
					call symputx('_select_code', _ds_names);
				end;
			run;
			quit;
			%let _select_code = &_select_code.%str(;);
		%end;

		/* Copy library */
		%put &_select_code.;
		%local /readonly _RSU_TMP_DESST_LIBNAME = %Int_RSULib_GetTempLibName();
		libname &_RSU_TMP_DESST_LIBNAME. "&i_dir_path." compress = yes;
		proc copy
			in = &i_libname.
			out = &_RSU_TMP_DESST_LIBNAME.
			memtype = data
			&_select_code.
			;
		run;
		quit;
		libname &_RSU_TMP_DESST_LIBNAME. clear;
	%end;
	%&RSUDS.Delete(&_RSU_LIB_DS_LIST.)
%mend RSULib__CopyDSInLib;