%rsu_dev_module_activate_test(i_version = 200)

%put 20210118をSASの日付（整数）へ: %&RSUDate.YYYYMMDD2SASDate(20210118);		/* "YYYYMMDD2SASDate" yyyymmdd形式から SAS日付（整数）へ */
%put 2021/1/18をSASの日付（整数）へ: %&RSUDate.YYYYMMDDs2SASDate(2021/1/18);		/* "YYYYMMDDs2SASDate" yyyymmdd形式から SAS日付（整数）へ */
%put 20210118をExcelの日付（整数）へ: %&RSUDate.YYYYMMDD2ExcelDate(20210118);		/* "YYYYMMDD2ExcelDate" yyyymmdd形式から Excel日付（整数）へ */
%put 2021/1/18をExcelの日付（整数）へ: %&RSUDate.YYYYMMDDs2ExcelDate(2021/1/18);		/* "YYYYMMDDs2ExcelDate" yyyymmdd形式から Excel日付（整数）へ */
