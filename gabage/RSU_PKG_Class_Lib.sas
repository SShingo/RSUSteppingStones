/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Class_Lib.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/3/14
/*
/* <PkgParent>RSULib<PkgParent>
/************************************************************************************/
/*<ClassID>RSU_PKG_Class_Lib</ClassID>*/
/*<ClassCreator>%&RSULib.Assign</ClassCreator>*/
/*<ClassPurpose ja_jp>ライブラリクラス</ClassPurpose ja_jp>*/

%&RSUClass.DeclareVar(<instance>, m_libname)

/*******************************************/
/* Internal Macros
/*******************************************/
%macro Int_<instance>Initialize(i_libname =);
	%let <instance>m_libname = &i_libname.;
	%let <instance>m_dir_path = &i_dir_path.;
	%&RSULogger.PutNote(%&RSUMsg.LIB_ASSIGNED(&<instance>m_libname., %<instance>Path))
%mend Int_<instance>Initialize;

%macro Int_<instance>Release;
	%if (%sysfunc(libref(&<instance>m_libname.)) = 0) %then %do;
		%local _path;
		%let _path = %<instance>Path;
		%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(libname(&<instance>m_libname.)))
		%&RSULogger.PutNote(%&RSUMsg.LIB_DEASSIGNED(&<instance>m_libname., &_path.))
	%end;
%mend Int_<instance>Release;

/*******************************************/
/* Public Macros
/*******************************************/
/*<FunctionDesc ja_jp>ライブラリ内のデータセットをクリアします</FunctionDesc ja_jp>*/
%macro <instance>Clear;
	%RSULib__ClearLib(i_libname = &<instance>m_libname.)
%mend <instance>Clear;

/*<FunctionDesc ja_jp>ライブラリの物理パスを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>ライブラリの物理パス</FunctionReturn ja_jp>*/
%macro <instance>Path;
	%RSULib__GetPath(i_libname = &<instance>m_libname.)
%mend <instance>Path;

/*<FunctionDesc ja_jp>ライブラリ内のデータセットの配列を取得します</FunctionDesc ja_jp>*/
%macro <instance>GetDS;
	%local /readonly _TMP_ARRAY_EXCELSHEET = %RSULib__GetDSInLib(i_libname = &<instance>m_libname.);
	&_TMP_ARRAY_EXCELSHEET.
%mend <instance>GetDS;

/*<FunctionDesc ja_jp>ライブラリか空か否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0:ライブラリにデータセットが存在する\quad 1:ライブラリにデータセットが存在しない</FunctionReturn ja_jp>*/
%macro <instance>IsEmpty;
	%RSULib__IsLibEmpty(i_libname = &<instance>m_libname.)
%mend <instance>IsEmpty;

/*<FunctionDesc ja_jp>ライブラリの参照名を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>ライブラリの参照名</FunctionReturn ja_jp>*/
%macro <instance>;
	&<instance>m_libname.
%mend <instance>;
