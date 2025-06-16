/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Struct.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/9/18
/*
/* NOTE: テキスト or データセットによる定義のみ
/* NOTE: 要素の追加・更新・削除は不可
/************************************************************************************/
/*<PackageID>RSUStruct</PackageID>*/
/*<CategoryID>Cate_ProgramDesign</CategoryID>*/
/*<PackagePurpose ja_jp>構造体（Structure）</PackagePurpose ja_jp>*/
/*<PackageDesc ja_jp>構造体を管理するするマクロ群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions for Structure</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>Structパッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUStruct, RSUStruct__)

/*<FunctionDesc ja_jp>テキストから構造体を定義します</FunctionDesc ja_jp>*/
%macro RSUStruct__DefineByText(
/*<FunctionArgDesc ja_jp>テキストファイルフルパス</FunctionArgDesc ja_jp>*/
								i_file_path =
/*<FunctionArgDesc ja_jp>テキスト区切り文字</FunctionArgDesc ja_jp>*/
								, i_delimiter = &RSUTab.
/*<FunctionArgDesc ja_jp>ヘッダーを読み飛ばすか否か</FunctionArgDesc ja_jp>*/
								, i_is_header_skipped = %&RSUBool.True
								);
	%&RSUFile.VerifyExists(i_file_path = &i_file_path.)
	%local _firstobs;
	%if (&i_is_header_skipped. = 1) %then %do;
		%let _firstobs = 2;
	%end;
	%else %do;
		%let _firstobs = 1;
	%end;

	%local /readonly _RSU_STRUCT_TMP_IMPORTED_DS = %&RSUDS.GetTempDSName();
	data &_RSU_STRUCT_TMP_IMPORTED_DS.;
		attrib
			key length = $500.
			value length = $500.
		;
		stop;
	run;
	quit;

	%RSUDSIO.LoadTextIntoFrame(i_file_path =	&i_file_path.
										, iods_frame_ds = &_RSU_STRUCT_TMP_IMPORTED_DS.
										, i_firstobs = &_firstobs.
										, i_delimiter = &i_delimiter.)
	%RSUStruct__DefineByDSV(ids_input_ds = &_RSU_STRUCT_TMP_IMPORTED_DS.
									, i_key_varname = key
									, i_value_varname = value)
	%&RSUDS.Delete(&_RSU_STRUCT_TMP_IMPORTED_DS.)
%mend RSUStruct__DefineByText;

/*<FunctionDesc ja_jp>データセットからStructを定義します（横型）。データセットの最初の一行が読み込み対象となります。</FunctionDesc ja_jp>*/
%macro RSUStruct__DefineByDSH(
/*<FunctionArgDesc ja_jp>インポート元データセット</FunctionArgDesc ja_jp>*/
										ids_input_ds =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_input_ds)
	%local /readonly _RSU_STRUCT_TMP_IMPORTED_DS = %&RSUDS.GetTempDSName();
	%&RSUDS.Let(i_query = &ids_input_ds.(obs = 1)
					, ods_dest_ds = &_RSU_STRUCT_TMP_IMPORTED_DS.)

	proc trans data = &_RSU_STRUCT_TMP_IMPORTED_DS. out = &_RSU_STRUCT_TMP_IMPORTED_DS._trans;
		var
			_all_
		;
	run;
	quit;
	%&RSUDS.Delete(&_RSU_STRUCT_TMP_IMPORTED_DS.)

	%RSUStruct__DefineByDSV(ids_input_ds = &_RSU_STRUCT_TMP_IMPORTED_DS._trans
									, i_key_varname = _NAME_
									, i_value_varname = COL1)
	%&RSUDS.Delete(&_RSU_STRUCT_TMP_IMPORTED_DS._trans)
%mend RSUStruct__DefineByDSH;

/*<FunctionDesc ja_jp>データセットから構造体を定義します（縦型）</FunctionDesc ja_jp>*/
%macro RSUStruct__DefineByDSV(
/*<FunctionArgDesc ja_jp>インポート元データセット</FunctionArgDesc ja_jp>*/
										ids_input_ds =
/*<FunctionArgDesc ja_jp>構造体要素名を定義する変数名</FunctionArgDesc ja_jp>*/
										, i_key_varname =
/*<FunctionArgDesc ja_jp>構造体要素値を定義する変数名</FunctionArgDesc ja_jp>*/
										, i_value_varname =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_key_varname i_key_varname i_value_varname)
	%local /readonly _DS_ITER_ELMENTS = %&RSUDSIterator.Create(&ids_input_ds.);
	%do %while(%&RSUDSIterator.Next(_DS_ITER_ELMENTS));
		%Int_RSUStruct__DefineElement(i_struct_name = &i_struct_name.
												, i_element_name = %&RSUDSIterator.Current(_DS_ITER_ELMENTS, &i_key_varname.)
												, i_value = %&RSUDSIterator.Current(_DS_ITER_ELMENTS, &i_value_varname.));
	%end;
	%&RSUDSIterator.Dispose(_DS_ITER_ELMENTS)
%mend RSUStruct__DefineByDSV;

/*<FunctionDesc ja_jp>構造体をクリアします</FunctionDesc ja_jp>*/
/*<FunctionDesc en_us>Clear Structure</FunctionDesc en_us>*/
%macro RSUStruct__Clear(
/*<FunctionArgDesc ja_jp>構造体名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Name of Structure</FunctionArgDesc en_us>*/
								i_struct_name
								);
	%local /readonly _RSU_STRUCT_DISPOSE_DS = %&RSUDS.GetTempDSName();
	proc catalog cat = WORK.sasmac1;
		contents out = &_RSU_STRUCT_DISPOSE_DS.(where = (upcase(name) like upcase("&i_struct_name%__")));
	run;
	%local /readonly _DS_ITER_ELMENTS = %&RSUDSIterator.Create(&ids_input_ds.);
	%do %while(%&RSUDSIterator.Next(_DS_ITER_ELMENTS));
		%sysmacdelete %&RSUDSIterator.Current(_DS_ITER_ELMENTS, name);
	%end;
	%&RSUDSIterator.Dispose(_DS_ITER_ELMENTS)
	%&RSUDS.Delete(&_RSU_STRUCT_DISPOSE_DS.)
%mend RSUStruct__Clear;
