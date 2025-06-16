/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_System.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2022/1/18
/*
/************************************************************************************/
/*<PackageID>RSUSystem</PackageID>*/
/*<CategoryID>Cate_Misc</CategoryID>*/
/*<PackagePurpose ja_jp>システム情報</PackagePurpose ja_jp>*/
/*<PackageDesc ja_jp>RSU Development Moduleの情報などを返すマクロ群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions which return RSU Development Module information</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>システムパッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUSys, RSUSys__)

/*<FunctionDesc ja_jp>RSU Development Module の基本情報（バージョンなど）を取得します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>キーに対応するパッケージ基本情報</FunctionReturn ja_jp>*/
%macro RSUSys__GetInfo(
/*<FunctionArgDesc ja_jp>情報キー</FunctionArgDesc ja_jp>*/
								i_info_key =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_info_key)
	%&RSUDS.GetValue(i_query = L_RSUMDL.&RSU_G_DEV_MODULE_NAME.(where = (name = "INFO_%upcase(&i_info_key.)"))
						, i_variable = code)
%mend RSUSys__GetInfo;

/*<FunctionDesc ja_jp>RSU Development Module のバージョン番号を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>バージョン番号（3桁整数、または <Major>.<Minor>.<Revision> 形式）</FunctionReturn ja_jp>*/
%macro RSUSys__GetVersion(
/*<FunctionArgDesc ja_jp>成型されたバージョン番号形式で出力するか否か</FunctionArgDesc ja_jp>*/
									i_formatting = %&RSUBool.False
									);
	%local /readonly _RSU_SYS_VERSION_INFO = %&RSUDS.GetValue(i_query = L_RSUMDL.&RSU_G_DEV_MODULE_NAME.(where = (name = 'INFO_VERSION'))
																				, i_variable = code);
	%local _result;
	%if (&i_formatting. = %&RSUBool.True) %then %do;
		%local _RSU_Sys_regex_id;
		%let _RSU_Sys_regex_id = %sysfunc(prxparse(s/v(\d)(\d)(\d)/$1.$2.$3/));
		%let _result = %sysfunc(prxchange(&_RSU_Sys_regex_id., -1, &_RSU_SYS_VERSION_INFO.));
		%syscall prxfree(_RSU_Sys_regex_id);
	%end;
	%else %do;
		%let _result = &_RSU_SYS_VERSION_INFO.;
	%end;
	&_result.
%mend RSUSys__GetVersion;

/*<FunctionDesc ja_jp>モジュールの基本情報（バージョンなど）を出力します</FunctionDesc ja_jp>*/
%macro RSUSys__ShowModuleInfo;
	%RSUShowActivationStartTitle(i_rsu_dev_module_name = &RSU_G_DEV_MODULE_NAME.)
%mend RSUSys__ShowModuleInfo;

/*<FunctionDesc ja_jp>RSU パッケージのソースコードを書き出します</FunctionDesc ja_jp>*/
%macro RSUSys__DumpCode(
/*<FunctionArgDesc ja_jp>書き出し先ディレクトリパス</FunctionArgDesc ja_jp>*/
								i_dir_path =
								);
	%&RSUDirectory.VerifyExists(i_dir_path = &i_dir_path.)
	%local /readonly _RSU_TMP_CODE = %&RSUDS.GetTempDSName();
	%&RSUDS.Let(i_query = L_RSUMDL.&RSU_G_DEV_MODULE_NAME.(where = (name like 'RSU_PKG_%'))
					, ods_dest_ds = &_RSU_TMP_CODE.)
	%local /readonly _RSU_TMP_PACKAGES = %&RSUDS.GetTempDSName();
   %&RSUDS.GetUniqueList(i_query = &_RSU_TMP_CODE.
								, i_by_variables = name
								, ods_output_ds = &_RSU_TMP_PACKAGES.)

	%local /readonly _RSU_TMP_CODE_IN_PACKAGE = %&RSUDS.GetTempDSName();
   %local _package_name;
	%local /readonly _DS_ITER_CODE = %&RSUDSIterator.Create(&_RSU_TMP_PACKAGES.);
	%do %while(%&RSUDSIterator.Next(_DS_ITER_CODE));
		%let _package_name = %&RSUDSIterator.Current(_DS_ITER_CODE, name);
      data &_RSU_TMP_CODE_IN_PACKAGE.;
         set &_RSU_TMP_CODE.(where = (name = "&_package_name"));
         keep
            code
         ;
      run;
      quit;

      %&RSUDSIO.SaveAsText(ids_dataset = &_RSU_TMP_CODE_IN_PACKAGE.
                        , i_file_path = &i_dir_path./&_package_name..sas)
		%&RSUDS.Delete(&_RSU_TMP_CODE_IN_PACKAGE.)
	%end;
	%&RSUDSIterator.Dispose(_DS_ITER_CODE)
	%&RSUDS.Delete(&_RSU_TMP_CODE. &_RSU_TMP_PACKAGES.)
%mend RSUSys__DumpCode;
