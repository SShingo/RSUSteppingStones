/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_LASR.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/3/1
/***********************************************************************************/
/*<PackageID>RSULASR</PackageID>*/
/*<CategoryID>Cate_Misc</CategoryID>*/
/*<PackagePurpose ja_jp>SAS9 LASRサーバー操作</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>SAS9 Manipulation of LASR server errors</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>SAS9 LASRサーバーをハンドリングするマクロ群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions handling SAS9 LASR server</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>エラーパッケージ Prefix</ConstantDesc ja_jp>*/
/*<ConstantDesc en_us>Error Package Prefix</ConstantDesc en_us>*/
%RSUSetConstant(RSULASR, RSULASR__)

%macro RSULASR__Start(i_lasr_server_name =
							, i_user_id =
							, i_tgt_ticket =
							, i_password =);
%mend RSULASR__Start;

%macro RSULASR__Stop(i_lasr_server_name =
							, i_user_id =
							, i_tgt_ticket =
							, i_password =);
%mend RSULASR__Stop;

%macro RSULASR__GetStatus(i_lasr_server_name =
								, ovar_status =
								, i_user_id =
								, i_tgt_ticket =
								, i_password =);
%mend RSULASR__GetStatus;

/**===================================================**/
/* LASRライブラリ割り当て
/**===================================================**/
%macro RSULASR__AssignLASRLibrary(i_library_name =
											, i_library_full_name =);
	libname &i_library_name. meta library = "&i_library_full_name." metaout = data;
	%if (%&RSULib.IsAssigned(&i_library_name.)) %then %do;
		%&RSULogger.PutInfo(&i_library_name.(&i_library_full_name.).... OK)
	%end;
	%else %do;
		%&RSUError.Throw(Failed to assign LASR Library)
	%end;
%mend RSULASR__AssignLASRLibrary;

/**===================================================**/
/* データアップロード & Meta 登録
/**===================================================**/
/*<FunctionDesc ja_jp>LASRサーバーにテーブルをアップロードします</FunctionDesc ja_jp>*/
%macro RSULASR__Upload(
/*<FunctionArgDesc ja_jp>LASRサーバーライブラリ</FunctionArgDesc ja_jp>*/
							i_library_full_name =
/*<FunctionArgDesc ja_jp>LASRサーバーライブラリ参照名</FunctionArgDesc ja_jp>*/
							, i_lasr_library =
/*<FunctionArgDesc ja_jp>アップロードするデータセット</FunctionArgDesc ja_jp>*/
							, ids_source_ds =
/*<FunctionArgDesc ja_jp>LASRサーバーフォルダパス</FunctionArgDesc ja_jp>*/
							, i_dest_location =
/*<FunctionArgDesc ja_jp>データをアペンドするか否か</FunctionArgDesc ja_jp>*/
							, i_is_append =
							);
	%&RSULogger.PutNote(Uploading and registering dataset to LASR Server)
	%&RSULogger.PutBlock(Dataset: &ids_source_ds.
								, LASR Library full name: &i_library_full_name.
								, Location: &i_dest_location.)
	%UploadTable(ids_uploading_ds = &ids_source_ds.
					, i_lasr_library = &i_lasr_library.
					, i_is_append = &i_is_append.)
	%RegisterTable(i_location_path = &i_dest_location.
						, ids_registering_ds = &ids_source_ds.
						, i_library_full_name = &i_library_full_name.)
%mend RSULASR__Upload;

%macro UploadTable(ids_uploading_ds =
						, i_lasr_library =
						, i_is_append =);
	%&RSULogger.PutNote(Uploading data "&ids_uploading_ds." to LASR library.)
	%local /readonly _UPLOADING_DS_NAME = %&RSUDS.GetDSName(&ids_uploading_ds.);
	%if (not &i_is_append.) %then %do;
		%&RSUDS.Delete(&i_lasr_library..&_UPLOADING_DS_NAME.)
	%end;
	%local /readonly _APPEND_OPTION = %&RSUUtil.Choose(&i_is_append., yes, no);
	data &i_lasr_library..&_UPLOADING_DS_NAME.(append = &_APPEND_OPTION.);
		set &ids_uploading_ds.;
	run;
	quit;
%mend UploadTable;

%macro RegisterTable(i_location_path =
							, ids_registering_ds =
							, i_library_full_name =);
	%local /readonly _UPLOADING_DS_NAME = %&RSUDS.GetDSName(&ids_registering_ds.);
	%&RSULogger.PutNote(Registering &i_location_path./&_UPLOADING_DS_NAME. to &i_library_full_name. library.)
	proc metalib;
		omr (library = "&i_library_full_name."); 
		folder = "&i_location_path.";
		select ("&_UPLOADING_DS_NAME."); 
	run; 
	quit;
%mend RegisterTable;
