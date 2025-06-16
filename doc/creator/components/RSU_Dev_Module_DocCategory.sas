%RSUSetConstant(Cate, Cate__)

/*********************************************************/
/* カテゴリー情報（外部ファイル定義）
/*		- カテゴリー一覧
/*			> category_id
/*			> category_description
/*********************************************************/
%macro Cate__GatherDocInformation(ods_categories =);
	%&RSULogger.PutNote(カテゴリ一覧作成)
	/* カテゴリマスタ読み込み */
	data &ods_categories.;
		attrib
			category_id length = $50.
			category_description_ja_jp length = $200.
			category_description_en_us length = $200.
		;
		stop;
	run;
	quit;
	%&RSUDS.LoadTextIntoFrame(i_file_path = &g_rsu_dev_module_doc_root./creator/resources/category_master.txt
										, iods_frame_ds = &ods_categories.
										, i_delimiter = &RSUTab.)
	data &ods_categories.(keep = category_id category_description);
		set &ods_categories.;
		attrib
			category_description length = $200.
		;
		category_description = category_description_&g_locale.;
	run;
	quit;

%mend Cate__GatherDocInformation;

%macro Cate__ConvertIntoTeXCode(iods_categories =);
	/* Do Nothing */
%mend Cate__ConvertIntoTeXCode;