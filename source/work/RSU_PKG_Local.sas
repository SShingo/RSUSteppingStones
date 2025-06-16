/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Locla.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2022/9/11
/*
/* !保留
/************************************************************************************/
/*<PackageID>RSULocal</PackageID>*/
/*<CategoryID>Cate_Misc</CategoryID>*/
/*<PackagePurpose ja_jp>ローカルスコープのオブジェクト</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Objects in local scope</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>ローカルスコープのオブジェクトを取り扱うパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions handling local scope objects</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>ローカルオブジェクトパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Local Object Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSULocal, RSULocal__)

%macro RSULocal__Initialize();
	data WORK.____RSU_LOCAL_WORKING_DS___;
		attrib
			bread_crumbs length = $2000.
			dataset_name length = $32.
			keep_alive length = $1.
		;
		stop;
	run;
	quit;

	data WORK.____RSU_LOCAL_INSTANCE___;
		attrib
			bread_crumbs length = $2000.
			instance_name length = $32.
			keep_alive length = $1.
		;
		stop;
	run;
	quit;
%mend RSULocal__Initialize;

%macro RSULocal__GetWorkDS(i_label =
									, i_is_keep_alive = %&RSUBool.False
									);
	%local /readonly _BREAD_CRUMBS = %&RSUDebug.GetBreadcrumbs(-1);
%mend RSULocal__GetWorkDS;

%macro RSULocal__GetLocalInstance(i_label =
											, i_is_keep_alive = %&RSUBool.False
											);
	%local /readonly _BREAD_CRUMBS = %&RSUDebug.GetBreadcrumbs(-1);
%mend RSULocal__GetLocalInstance;

%macro RSULocal__Leave();
	%local /readonly _BREAD_CRUMBS = %&RSUDebug.GetBreadcrumbs(-1);
	%DeleteWorkingDataset(i_bread_crumbs = &_BREAD_CRUMBS.)
	%DisposeInstances(i_bread_crumbs = &_BREAD_CRUMBS.)
%mend RSULocal__Leave;

%macro DeleteWorkingDataset(i_bread_crumbs =);
	%local _dataset_name;
	proc sql noprint;
		select
			dataset_name into :_dataset_name separated by ' '
		from
			WORK.____RSU_LOCAL_WORKING_DS___
		where
			bread_crumbs = "&i_bread_crumbs."
			and keep_alive ne '1'
		;
	run;
	quit;
	%if (not %&RSUMacroVariable.IsBlank(_dataset_name)) %then %do;
		%&RSUDS.Delete(&_dataset_name.)
	%end;
%mend DeleteWorkingDataset;

%macro DisposeInstances(i_bread_crumbs =);
	%local _instance_name;
	data _null_;
		set WORK.____RSU_LOCAL_INSTANCE___(where = (bread_crumbs = "&i_bread_crumbs." and keep_alive ne '1'));
		call execute(cats(cats('%Prv_RSUClass_DisposeHelper(i_instance_name = ', instance_name, ')');
	quit;
%mend DisposeInstances;