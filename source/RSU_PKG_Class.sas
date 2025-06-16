/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Class.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/4/2
/*
/************************************************************************************/
/*<PackageID>RSUClass</PackageID>*/
/*<CategoryID>Cate_ProgramDesign</CategoryID>*/
/*<PackagePurpose ja_jp>クラス管理</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Managing class</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>クラスを管理するマクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manage class</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>クラスパッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUClass, RSUClass__)

/*<FunctionDesc ja_jp>クラスメンバ変数を登録します（ここで登録されたマクロ変数は Dispose関数によって自動的に破棄されます）</FunctionDesc ja_jp>*/
%macro RSUClass__DeclareVar(
/*<FunctionArgDesc ja_jp>インスタンスID</FunctionArgDesc ja_jp>*/
									i_instance_name
/*<FunctionArgDesc ja_jp>クラスメンバ変数名</FunctionArgDesc ja_jp>*/
									, i_var_name
									);
	%global &i_instance_name.&i_var_name.;
%mend RSUClass__DeclareVar;

/*<FunctionDesc ja_jp>クラスを破棄します</FunctionDesc ja_jp>*/
%macro RSUClass__Dispose(
/*<FunctionArgDesc ja_jp>インスタンスの別名を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
								i_class_alias_var
								);
	%Prv_RSUClass_DisposeHelper(i_instance_name = &&&i_class_alias_var.)
%mend RSUClass__Dispose;

/*<FunctionDesc ja_jp>残存しているインスタンスをすべて破棄します（ただし使用中のインスタンスは削除されません）</FunctionDesc ja_jp>*/
%macro RSUClass__CleanUpAll();
	/* インスタンスマクロ変数削除 */
	%local _no_of_debries;
	%&RSUMacroVariable.Delete(i_regex = /^&RSU_G_GLOBAL_INSTANCE_PREFIX._/i
									, ovar_no_of_removed_macro_var = _no_of_debries)
	%if (&_no_of_debries. ne 0) %then %do;
		%put WARNING: &_no_of_debries. debri marcro variable(s) removed.;
	%end;

	%local /readonly _NO_OF_TABLE_DEBRIES = %&RSUDS.GetCount(SASHELP.vtable(where = (libname = 'WORK' and memname like upcase("&RSU_G_GLOBAL_INSTANCE_PREFIX._%"))));
	%if (&_NO_OF_TABLE_DEBRIES. = 0) %then %do;
		%return;
	%end;
	%local /readonly _DSITER_DELETE_DEBRIES = %&RSUDSIterator.Create(SASHELP.vtable(where = (libname = 'WORK' and memname like upcase("&RSU_G_GLOBAL_INSTANCE_PREFIX._%"))));
	%local _debri_table;
	%do %while(%&RSUDSIterator.Next(_DSITER_DELETE_DEBRIES));
		%let _debri_table = %&RSUDSIterator.Current(_DSITER_DELETE_DEBRIES, memname);
		%put &_debri_table;
		proc delete
			data = &_debri_table.;
		run;
		quit;
	%end;
	%&RSUDSIterator.Dispose(_DSITER_DELETE_DEBRIES)
	%put WARNING: &_NO_OF_TABLE_DEBRIES. debri table(s) removed;
%mend RSUClass__CleanUpAll;