/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Msg.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/2/13
/*
/************************************************************************************/
/*<PackageID>RSUMsg</PackageID>*/
/*<CategoryID>Cate_DebuggingAndLogging</CategoryID>*/
/*<PackagePurpose ja_jp>ロケール対応メッセージ</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Locale sensitive messaging</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>ロケール対応メッセージ処理マクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions for locale sensitive messaging</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>メッセージパッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUMsg, RSUMsg__)

/*<FunctionDesc ja_jp>エクセルファイルによってメッセージを定義します</FunctionDesc ja_jp>*/
%macro RSUMsg__DefineMessage(
/*<FunctionArgDesc ja_jp>メッセージ定義エクセルファイルフルパス</FunctionArgDesc ja_jp>*/
									i_file_path =
/*<FunctionArgDesc ja_jp>読み込みシート名</FunctionArgDesc ja_jp>*/
									, i_sheet_name =
/*<FunctionArgDesc ja_jp>出力データセット名</FunctionArgDesc ja_jp>*/
									, ods_message_ds =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_sheet_name ods_message_ds)
	%&RSULogger.PutNote(Defining Messages by Excel file "&i_file_path.")
	%local /readonly _RSU_MESSAGE_TMP_MSG_DS = %&RSUDS.GetTempDSName();
	proc import datafile = "&i_file_path."
					out = &_RSU_MESSAGE_TMP_MSG_DS.
					dbms = xlsx
					sheet = "&i_sheet_name."
					replace
				;
	run;

	proc sort data = &_RSU_MESSAGE_TMP_MSG_DS.;
		by
			key
		;
	run;

	proc transpose data = &_RSU_MESSAGE_TMP_MSG_DS. out = &_RSU_MESSAGE_TMP_MSG_DS._trans;
		var
			_all_
		;
		by
			key
		;
	run;
	%&RSUDS.Delete(&_RSU_MESSAGE_TMP_MSG_DS.)

	data &ods_message_ds.;
		attrib
			locale length = $5.
			key length = $60.
			text length = $1200.
		;
		set &_RSU_MESSAGE_TMP_MSG_DS._trans(where = (_name_ ne 'key'));
		lineno = _N_;
		locale = _name_;
		text = unicodec(col1);
		drop
			_label_
			_name_
			col1
		;
	run;
	quit;
	%&RSUDS.Delete(&_RSU_MESSAGE_TMP_MSG_DS._trans)

	%Prv_RSUMsg_CreateMsgDSHelper(i_libname = %&RSUDS.GetLibname(ids_dataset = &ods_message_ds.)
											, iods_message_ds = %&RSUDS.GetDSName(ids_dataset = &ods_message_ds.))
%mend RSUMsg__DefineMessage;

/*<FunctionDesc ja_jp>テキストファイルによってメッセージを定義します</FunctionDesc ja_jp>*/
%macro RSUMsg__DefineMessageByText(
/*<FunctionArgDesc ja_jp>メッセージ定義テキストファイルフルパス</FunctionArgDesc ja_jp>*/
											i_file_path =
/*<FunctionArgDesc ja_jp>メッセージ呼び出し関数の Prefix</FunctionArgDesc ja_jp>*/
											, i_message_prefix =
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_message_prefix)
	%&RSULogger.PutNote(%&RSUMsg.DEFINE_MSG_BY_TEXT(&i_file_path., &i_message_prefix.))
	%local /readonly RSU_MSG_TMP_DEF_MESSAGE = %&RSUDS.GetTempDSName();
	data &RSU_MSG_TMP_DEF_MESSAGE.;
		attrib
			key length = $32.
			en_US length = $500.
			ja_jp length = $500.
		;
		infile "&i_file_path" delimiter = '09'x dsd missover firstobs = 2;
		input
			key
			en_US
			ja_JP
		;
	run;

	proc sort data = &RSU_MSG_TMP_DEF_MESSAGE.;
      by
         key
      ;
   run;

   proc transpose data = &RSU_MSG_TMP_DEF_MESSAGE. out = &RSU_MSG_TMP_DEF_MESSAGE._trans;
      var
         _all_
      ;
      by
         key
      ;
   run;
	%&RSUDS.Delete(&RSU_MSG_TMP_DEF_MESSAGE.)

   data &RSU_MSG_TMP_DEF_MESSAGE._trans;
      attrib
         locale length = $5.
         key length = $60.
         text length = $1200.
      ;
      set &RSU_MSG_TMP_DEF_MESSAGE._trans(where = (_name_ ne 'key'));
      lineno = _N_;
      locale = _name_;
      text = unicodec(col1);
      drop
         _name_
         col1
      ;
   run;

	%Prv_RSUMsg_CreateMsgDSHelper(i_libname = %&RSUDS.GetLibname(ids_dataset = &RSU_MSG_TMP_DEF_MESSAGE._trans)
											, iods_message_ds = %&RSUDS.GetDSName(ids_dataset = &RSU_MSG_TMP_DEF_MESSAGE._trans))
	%Int_RSUMsg_DefineMsgFunction(ids_message_ds = &RSU_MSG_TMP_DEF_MESSAGE._trans
											, i_massage_prefix = &i_message_prefix.);
	%&RSUDS.Delete(&RSU_MSG_TMP_DEF_MESSAGE._trans)
%mend RSUMsg__DefineMessageByText;