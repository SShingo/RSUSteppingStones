/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_CAS.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/5/20
/************************************************************************************/
/*<PackageID>RSUCAS</PackageID>*/
/*<CategoryID>Cate_DataHandling</CategoryID>*/
/*<PackagePurpose ja_jp>CAS操作</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>CAS operation</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>CAS操作に係るマクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating cas</PackageDesc en_us>*/

%macro RSUCAS__CreateSession();

%mend RSUCAS__CreateSession;

%macro RSUCAS__TerminateSession();

%mend RSUCAS__TerminateSession;

%macro RSUCAS__LoadTable();

%mend RSUCAS__LoadTable;