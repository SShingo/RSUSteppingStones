/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Date.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/9/4
/*
/************************************************************************************/
/*<PackageID>RSUDate</PackageID>*/
/*<CategoryID>Cate_Misc</CategoryID>*/
/*<PackagePurpose ja_jp>日付関連</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Macros related to date</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>日付関連の関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating date value</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>日付パッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Date Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSUDate, RSUDate__)

/*<FunctionDesc ja_jp>``yyyymmdd''形式の日付文字列をSAS日付（数値）に変換します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Transform a date string in ``yyyymmdd'' format into a SAS date (numerical value)</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>SAS日付（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>SAS date (numerical value) </FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDD2SASDate(
/*<FunctionArgDesc ja_jp>``yyyymmdd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyymmdd'' format </FunctionArgDesc en_us>*/
											i_yyyymmdd
											);
	%sysfunc(RSU_fcmp_yyyymmdd2date(&i_yyyymmdd.))
%mend RSUDate__YYYYMMDD2SASDate;

/*<FunctionDesc ja_jp>``yyyymmdd''形式の日付文字列をExcel日付（数値）に変換します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Transform a date string in ``yyyy/mm/dd'' format into an Excel date (numerical value)</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>SAS日付（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>SAS date（numerical value）</FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDD2ExcelDate(
/*<FunctionArgDesc ja_jp>``yyyymmdd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyymmdd'' format</FunctionArgDesc en_us>*/
												i_yyyymmdd
												);
	%local _date;
	%let _date = %sysfunc(RSU_fcmp_yyyymmdd2date(&i_yyyymmdd.));
	%let _date = %eval(&_date. + &RSUExcelDateOffset.);
	&_date.
%mend RSUDate__YYYYMMDD2ExcelDate;

/*<FunctionDesc ja_jp>``yyyymmdd''形式の日付文字列の「年」（数値）を返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the "year" (numerical value) from a date string in ``yyyymmdd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>「年」（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>"year" (numerical value)</FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDD2Year(
/*<FunctionArgDesc ja_jp>``yyyymmdd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyymmdd'' format</FunctionArgDesc en_us>*/
										i_yyyymmdd
										);
	%sysfunc(RSU_fcmp_yyyymmdd2year(&i_yyyymmdd.))
%mend RSUDate__YYYYMMDD2Year;

/*<FunctionDesc ja_jp>``yyyymmdd''形式の日付文字列の「月」（数値）を返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the "month" (numerical value) from a date string in ``yyyymmdd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>「月」（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>"month" (numerical value)</FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDD2Month(
/*<FunctionArgDesc ja_jp>``yyyymmdd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyymmdd'' format</FunctionArgDesc en_us>*/
										i_yyyymmdd
										);
	%sysfunc(RSU_fcmp_yyyymmdd2month(&i_yyyymmdd.))
%mend RSUDate__YYYYMMDD2Month;

/*<FunctionDesc ja_jp>``yyyymmdd''形式の日付文字列の「日」（数値）を返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the "day" (numerical value) from a date string in ``yyyymmdd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>「日」（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>"day" (numerical value)</FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDD2Day(
/*<FunctionArgDesc ja_jp>``yyyymmdd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyymmdd'' format</FunctionArgDesc en_us>*/
										i_yyyymmdd
										);
	%sysfunc(RSU_fcmp_yyyymmdd2day(&i_yyyymmdd.))
%mend RSUDate__YYYYMMDD2Day;

/*<FunctionDesc ja_jp>``yyyymmdd''形式の日付文字列の「曜日」（数値）を返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the "day of the week" (numerical value) from a date string in ``yyyymmdd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>「曜日」（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>"day of the week" (numerical value)</FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDD2Weekday(
/*<FunctionArgDesc ja_jp>``yyyymmdd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyymmdd'' format</FunctionArgDesc en_us>*/
											i_yyyymmdd
											);
	%sysfunc(RSU_fcmp_yyyymmdd2weekday(&i_yyyymmdd.))
%mend RSUDate__YYYYMMDD2Weekday;

/*<FunctionDesc ja_jp>``yyyy/mm/dd''形式の日付文字列をSAS日付（数値）に変換します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Transform a date string in ``yyyy/mm/dd'' format into a SAS date (numerical value)</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>SAS日付（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>SAS date (numerical value)</FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDDs2SASDate(
/*<FunctionArgDesc ja_jp>``yyyy/mm/dd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyy/mm/dd'' format</FunctionArgDesc en_us>*/
											i_yyyysmmsdd
											);
	%sysfunc(RSU_fcmp_yyyymmdds2date(&i_yyyysmmsdd.))
%mend RSUDate__YYYYMMDDs2SASDate;

/*<FunctionDesc ja_jp>``yyyy/mm/dd''形式の日付文字列をExcel日付（数値）に変換します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Transform a date string in ``yyyy/mm/dd'' format into an Excel date (numerical value)</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>SAS日付（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>SAS date (numerical value)</FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDDs2ExcelDate(
/*<FunctionArgDesc ja_jp>``yyyy/mm/dd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyy/mm/dd'' format</FunctionArgDesc en_us>*/
												i_yyyysmmsdd
												);
	%local _date;
	%let _date = %sysfunc(RSU_fcmp_yyyymmdds2date(&i_yyyysmmsdd.));
	%let _date = %eval(&_date. + &RSUExcelDateOffset.);
	&_date.
%mend RSUDate__YYYYMMDDs2ExcelDate;

/*<FunctionDesc ja_jp>``yyyy/mm/dd''形式の日付文字列の「年」（数値）を返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the "year" (numerical value) from a date string in ``yyyy/mm/dd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>「年」（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>"year" (numerical value)</FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDDs2Year(
/*<FunctionArgDesc ja_jp>``yyyy/mm/dd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyy/mm/dd'' format</FunctionArgDesc en_us>*/
										i_yyyysmmsdd
										);
	%sysfunc(RSU_fcmp_yyyymmdd2year(&i_yyyymmdd.))
%mend RSUDate__YYYYMMDDs2Year;

/*<FunctionDesc ja_jp>``yyyy/mm/dd''形式の日付文字列の「月」（数値）を返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the "month" (numerical value) from a date string in ``yyyy/mm/dd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>「月」（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>"month" (numerical value)</FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDDs2Month(
/*<FunctionArgDesc ja_jp>``yyyy/mm/dd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyy/mm/dd'' format</FunctionArgDesc en_us>*/
											i_yyyysmmsdd
											);
	%sysfunc(RSU_fcmp_yyyymmdd2month(&i_yyyymmdd.))
%mend RSUDate__YYYYMMDDs2Month;

/*<FunctionDesc ja_jp>``yyyy/mm/dd''形式の日付文字列の「日」（数値）を返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the "day" (numerical value) from a date string in ``yyyy/mm/dd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>「日」（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>"day" (numerical value)</FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDDs2Day(
/*<FunctionArgDesc ja_jp>``yyyy/mm/dd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyy/mm/dd'' format</FunctionArgDesc en_us>*/
										i_yyyysmmsdd
										);
	%sysfunc(RSU_fcmp_yyyymmdd2day(&i_yyyymmdd.))
%mend RSUDate__YYYYMMDDs2Day;

/*<FunctionDesc ja_jp>``yyyy/mm/dd''形式の日付文字列の「曜日」（数値）を返します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Returns the "day of the week" (numerical value) from a date string in ``yyyy/mm/dd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>「曜日」（数値）</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>"day of the week" (numerical value)</FunctionReturn en_us>*/
%macro RSUDate__YYYYMMDDs2Weekday(
/*<FunctionArgDesc ja_jp>``yyyy/mm/dd''形式の日付文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date string in ``yyyy/mm/dd'' format</FunctionArgDesc en_us>*/
											i_yyyymmdd
											);
	%sysfunc(RSU_fcmp_yyyymmdds2weekday(&i_yyyymmdd.))
%mend RSUDate__YYYYMMDDs2Weekday;

/*<FunctionDesc ja_jp>SAS日付（数値）を``yyyymmdd''形式の日付文字列に変換します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Transform a SAS date (numerical value) into a date string in ``yyyymmdd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>``yyyymmdd''形式の日付文字列</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Date string in ``yyyymmdd'' format</FunctionReturn en_us>*/
%macro RSUDate__SASDate2YYYYMMDD(
/*<FunctionArgDesc ja_jp>日付（数値）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date (numerical value)</FunctionArgDesc en_us>*/
											i_date
											);
	%sysfunc(RSU_fcmp_date2yyyymmdd(&i_date.))
%mend RSUDate__SASDate2YYYYMMDD;

/*<FunctionDesc ja_jp>Excel日付（数値）を``yyyymmdd''形式の日付文字列に変換します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Transform an Excel date (numerical value) into a date string in ``yyyymmdd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>``yyyymmdd''形式の日付文字列</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Date string in ``yyyymmdd'' format</FunctionReturn en_us>*/
%macro RSUDate__ExcelDate2YYYYMMDD(
/*<FunctionArgDesc ja_jp>日付（数値）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date (numerical value)</FunctionArgDesc en_us>*/
												i_date
												);
	%local /readonly _SAS_DATE = %eval(&i_date. - &RSUExcelDateOffset.);
	%sysfunc(RSU_fcmp_date2yyyymmdd(&_SAS_DATE.))
%mend RSUDate__ExcelDate2YYYYMMDD;

/*<FunctionDesc ja_jp>SAS日付（数値）を``yyyy/mm/dd''形式の日付文字列に変換します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Transform a SAS date (numerical value) into a date string in ``yyyy/mm/dd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>``yyyy/mm/dd''形式の日付文字列</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Date string in ``yyyy/mm/dd'' format</FunctionReturn en_us>*/
%macro RSUDate__SASDate2YYYYMMDDs(
/*<FunctionArgDesc ja_jp>日付（数値）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date (numerical value)</FunctionArgDesc en_us>*/
											i_date
											);
	%sysfunc(RSU_fcmp_date2yyyymmdds(&i_date.))
%mend RSUDate__SASDate2YYYYMMDDs;

/*<FunctionDesc ja_jp>Excel日付（数値）を``yyyy/mm/dd''形式の日付文字列に変換します</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Transform an Excel date (numerical value) into a date string in ``yyyy/mm/dd'' format</FunctionDesc en_us>*/
/*<FunctionReturn ja_jp>``yyyy/mm/dd''形式の日付文字列</FunctionReturn ja_jp>*/
/*<FunctionReturn en_us>Date string in ``yyyy/mm/dd'' format</FunctionReturn en_us>*/
%macro RSUDate__ExcelDate2YYYYMMDDs(
/*<FunctionArgDesc ja_jp>日付（数値）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Date (numerical value)</FunctionArgDesc en_us>*/
												i_date
												);
	%local /readonly _SAS_DATE = %eval(&i_date. - &RSUExcelDateOffset.);
	%sysfunc(RSU_fcmp_date2yyyymmdds(&_SAS_DATE.))
%mend RSUDate__ExcelDate2YYYYMMDDs;
