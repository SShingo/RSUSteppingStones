%RSUSetConstant(Class, Class__)

/*********************************************************/
/* クラス情報
/*		- クラス一覧
/*			> class_id
/*			> class_purpose
/*			> class_description
/*
/*		- クラス生成関数
/*			> class_id
/*			> class_creator
/*
/*		- クラス詳細説明
/*			> class_id
/*			> class_detail
/*
/*		- クラス注意
/*			> class_id
/*			> class_note
/*********************************************************/
%macro Class__GatherDocInformation(ids_module_ds =
											, ods_classes =
											, ods_class_creators =
											, ods_class_details =
											, ods_class_notes =);
	%&RSULogger.PutInfo(クラス単位情報収集)
	data &ods_classes.(keep = class_id class_purpose);
		attrib
			class_id length = $50.
			class_purpose length = $100.
		;
		set &ids_module_ds.;
		_regex_class_start = prxparse('/^\/\*<ClassID>(.+)<\/ClassID>\*\/$/o');
		_regex_class_purpose = prxparse("/^\/\*<ClassPurpose &g_locale.>(.+)<\/ClassPurpose &g_locale.>\*\/$/o");
		_regex_class_end = prxparse('/^\/\*<EndOfPackage\/>\*\/$/o');

		retain class_id;
		retain category_id;
		retain class_purpose;
		retain _is_class_defined;

		if (prxmatch(_regex_class_start, trim(code))) then do;
			class_id = prxposn(_regex_class_start, 1, trim(code));
			_is_class_defined = 1;
		end;
		else if (prxmatch(_regex_class_purpose, trim(code))) then do;
			class_purpose = prxposn(_regex_class_purpose, 1, trim(code));
		end;
		else if (prxmatch(_regex_class_end, trim(code)) and _is_class_defined = 1) then do;
			output;
			class_id = '';
			class_purpose = '';
			_is_class_defined = 0;
		end;
	run;
	quit;

	%&RSULogger.PutInfo(クラスの生成関数)
	data &ods_class_creators.(keep = class_id class_creator);
		attrib
			class_id length = $50.
			class_creator length = $100.
		;
		set &ids_module_ds.;
		_regex_class_start = prxparse('/^\/\*<ClassID>(.+)<\/ClassID>\*\/$/o');
		_regex_class_cretor = prxparse("/^\/\*<ClassCreator>(.+)<\/ClassCreator>\*\/$/o");
		_regex_class_end = prxparse('/^\/\*<EndOfPackage\/>\*\/$/o');

		retain class_id;
		retain _is_class_defined;

		if (prxmatch(_regex_class_start, trim(code))) then do;
			class_id = prxposn(_regex_class_start, 1, trim(code));
			_is_class_defined = 1;
		end;
		if (prxmatch(_regex_class_end, trim(code))) then do;
			class_id = '';
			_is_class_defined = 0;
		end;
		else do;
			if (_is_class_defined = 1) then do;
				if (prxmatch(_regex_class_cretor, trim(code))) then do;
					class_creator = prxposn(_regex_class_cretor, 1, trim(code));
					output;
				end;
			end;
		end;
	run;
	quit;	

	%&RSULogger.PutInfo(クラスの詳細情報収集)
	data &ods_class_details.(keep = class_id class_detail);
		attrib
			class_id length = $50.
			class_detail length = $30000.
		;
		set &ids_module_ds.;
		_regex_class_start = prxparse('/^\/\*<ClassID>(.+)<\/ClassID>\*\/$/o');
		_regex_class_detail_start = prxparse("/^\/\*<ClassDetail &g_locale.>$/o");
		_regex_class_detail_end = prxparse("/^<\/ClassDetail &g_locale.>\*\/$/o");
		_regex_class_end = prxparse('/^\/\*<EndOfPackage\/>\*\/$/o');

		retain class_id;
		retain _is_in_detail 0;

		if (prxmatch(_regex_class_start, trim(code))) then do;
			class_id = prxposn(_regex_class_start, 1, trim(code));
		end;
		if (prxmatch(_regex_class_end, trim(code))) then do;
			class_id = '';
		end;
		if (_is_in_detail = 0) then do;
			if (prxmatch(_regex_class_detail_start, trim(code))) then do;
				_is_in_detail = 1;
			end;
		end;
		else do;
			if (prxmatch(_regex_class_detail_end, trim(code))) then do;
					_is_in_detail = 0;
			end;
			else do;
				class_detail = strip(code);
				output;
			end;
		end;
	run;
	quit;	
	
	%&RSULogger.PutInfo(クラスの注釈情報収集)
	data &ods_class_notes.(keep = class_id class_note);
		attrib
			class_id length = $50.
			class_note length = $2000.
		;
		set &ids_module_ds.;
		_regex_class_start = prxparse('/^\/\*<ClassID>(.+)<\/ClassID>\*\/$/o');
		_regex_class_note_start = prxparse("/^\/\*<ClassNote &g_locale.>$/o");
		_regex_class_note_end = prxparse("/<\/ClassNote &g_locale.>\*\/$/o");
		_regex_class_end = prxparse('/^\/\*<EndOfPackage\/>\*\/$/o');

		retain class_id;
		retain _is_in_note 0;

		if (prxmatch(_regex_class_start, trim(code))) then do;
			class_id = prxposn(_regex_class_start, 1, trim(code));
		end;
		if (prxmatch(_regex_class_end, trim(code))) then do;
			class_id = '';
		end;
		if (_is_in_note = 0) then do;
			if (prxmatch(_regex_class_note_start, trim(code))) then do;
				_is_in_note = 1;
			end;
		end;
		else do;
			if (prxmatch(_regex_class_note_end, trim(code))) then do;
					_is_in_note = 0;
			end;
			else do;
				class_note = strip(code);
				output;
			end;
		end;
	run;
	quit;	
%mend Class__GatherDocInformation;

%macro Class__ConvertIntoTeXCode(iods_classes =
											, iods_class_creators =
											, iods_class_details =
											, iods_class_notes =);
	%&RSULogger.PutNote(クラス単位 TeX変換)
	data &iods_classes.;
		attrib
			tex_class_id length = $100.
			tex_class_purpose length = $1000.
		;
		set &iods_classes.;
		tex_class_id = make_texttt_string(class_id);
		tex_class_purpose = class_purpose;
		line_no = _N_;
	run;
	quit;

	proc sort data = &iods_classes.;
		by
			class_id
		;
	run;
	quit;

	%&RSULogger.PutNote(クラス生成関数 TeX変換)
	data &iods_class_creators.;
		attrib
			tex_class_id length = $50.
			tex_class_creator length = $30000.
		;
		set &iods_class_creators.;
		tex_class_id = make_texttt_string(class_id);
		tex_class_creator = make_texttt_string(class_creator);
	run;
	quit;

	%&RSULogger.PutNote(クラスの詳細情報 TeX変換)
	data &iods_class_details.;
		attrib
			tex_class_id length = $50.
			tex_class_detail length = $30000.
		;
		set &iods_class_details.;
		tex_class_id = make_texttt_string(class_id);
		tex_class_detail = class_detail;
	run;
	quit;

	%SetAggregation(iods_base = &iods_classes.
							, ids_source = &iods_class_details.
							, i_agg_var = class_id
							, i_flag_var = has_detail)

	%&RSULogger.PutNote(クラスの注釈 TeX変換)
	data &iods_class_notes.;
		attrib
			tex_class_id length = $50.
			tex_class_note length = $2000.
		;
		set &iods_class_notes.;
		tex_class_id = make_texttt_string(class_id);
		tex_class_note = class_note;
	run;
	quit;

	%SetAggregation(iods_base = &iods_classes.
							, ids_source = &iods_class_notes.
							, i_agg_var = class_id
							, i_flag_var = has_note)

	proc sort data = &iods_classes.;
		by
			line_no
		;
	run;
	quit;
%mend Class__ConvertIntoTeXCode;
