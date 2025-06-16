%RSUSetConstant(Pkg, Pkg__)

/*********************************************************/
/* パッケージ情報
/*		- パッケージ一覧
/*			> category_id
/*			> package_id
/*			> package_purpose
/*			> package_description
/*
/*		- パッケージ詳細説明
/*			> package_id
/*			> package_detail
/*
/*		- パッケージ注意
/*			> package_id
/*			> package_note
/*********************************************************/
%macro Pkg__GatherDocInformation(ids_module_ds =
											, ods_packages =
											, ods_package_details =
											, ods_package_notes =);
	%&RSULogger.PutNote(パッケージ単位情報収集)
	data &ods_packages.(keep = package_id category_id package_purpose package_description);
		attrib
			category_id length = $50.
			package_id length = $50.
			package_purpose length = $100.
			package_description length = $1000.
		;
		set &ids_module_ds.;
		_regex_package_id = prxparse('/^\/\*<PackageID>(.+)<\/PackageID>\*\/$/o');
		_regex_category_id = prxparse('/^\/\*<CategoryID>(.+)<\/CategoryID>\*\/$/o');
		_regex_package_purpose = prxparse("/^\/\*<PackagePurpose &g_locale.>(.+)<\/PackagePurpose &g_locale.>\*\/$/o");
		_regex_package_description = prxparse("/^\/\*<PackageDesc &g_locale.>(.+)<\/PackageDesc &g_locale.>\*\/$/o");
		_regex_end_of_package = prxparse('/^\/\*<EndOfPackage\/>\*\/$/o');

		retain package_id;
		retain category_id;
		retain package_purpose;
		retain package_description;
		retain _is_package_defined;

		if (prxmatch(_regex_package_id, trim(code))) then do;
			package_id = prxposn(_regex_package_id, 1, trim(code));
			_is_package_defined = 1;
		end;
		else if (prxmatch(_regex_category_id, trim(code))) then do;
			category_id = prxposn(_regex_category_id, 1, trim(code));
		end;
		else if (prxmatch(_regex_package_purpose, trim(code))) then do;
			package_purpose = prxposn(_regex_package_purpose, 1, trim(code));
		end;
		else if (prxmatch(_regex_package_description, trim(code))) then do;
			package_description = prxposn(_regex_package_description, 1, trim(code));
		end;
		else if (prxmatch(_regex_end_of_package, trim(code)) and _is_package_defined = 1) then do;
			output;
			package_id = '';
			category_id = '';
			package_purpose = '';
			package_description = '';
			_is_package_defined = 0;
		end;
	run;
	quit;

	%&RSULogger.PutNote(パッケージの詳細情報収集)
	data &ods_package_details.(keep = package_id package_detail);
		attrib
			package_id length = $50.
			package_detail length = $30000.
		;
		set &ids_module_ds.;
		_regex_package_id = prxparse('/^\/\*<PackageID>(.+)<\/PackageID>\*\/$/o');
		_regex_package_detail_start = prxparse("/^\/\*<PkgDetail &g_locale.>$/o");
		_regex_package_detail_end = prxparse("/^<\/PkgDetail &g_locale.>\*\/$/o");

		retain package_id;
		retain _is_in_detail 0;

		if (prxmatch(_regex_package_id, trim(code))) then do;
			package_id = prxposn(_regex_package_id, 1, trim(code));
		end;
		if (_is_in_detail = 0) then do;
			if (prxmatch(_regex_package_detail_start, trim(code))) then do;
				_is_in_detail = 1;
			end;
		end;
		else do;
			if (prxmatch(_regex_package_detail_end, trim(code))) then do;
				_is_in_detail = 0;
				package_id = '';
			end;
			else do;
				package_detail = strip(code);
				output;
			end;
		end;
	run;
	quit;	

	%&RSULogger.PutNote(パッケージの注釈情報収集)
	data &ods_package_notes.(keep = package_id package_note);
		attrib
			package_id length = $50.
			package_note length = $2000.
		;
		set &ids_module_ds.;
		_regex_package_id = prxparse('/^\/\*<PackageID>(.+)<\/PackageID>\*\/$/o');
		_regex_package_note_start = prxparse("/^\/\*<PkgNote &g_locale.>$/o");
		_regex_package_note_end = prxparse("/<\/PkgNote &g_locale.>\*\/$/o");

		retain package_id;
		retain _is_in_note 0;

		if (prxmatch(_regex_package_id, trim(code))) then do;
			package_id = prxposn(_regex_package_id, 1, trim(code));
		end;
		if (_is_in_note = 0) then do;
			if (prxmatch(_regex_package_note_start, trim(code))) then do;
				_is_in_note = 1;
			end;
		end;
		else do;
			if (prxmatch(_regex_package_note_end, trim(code))) then do;
				_is_in_note = 0;
				package_id = '';
			end;
			else do;
				package_note = strip(code);
				output;
			end;
		end;
	run;
	quit;	
%mend Pkg__GatherDocInformation;

%macro Pkg__ConvertIntoTeXCode(iods_packages =
											, iods_package_details =
											, iods_package_notes =);
	%&RSULogger.PutInfo(パッケージ単位 TeX変換)
	data &iods_packages.;
		attrib
			tex_category_id length = $50.
			tex_package_id length = $100.
			tex_package_purpose length = $100.
			tex_package_description length = $1000.
		;
		set &iods_packages.;
		tex_category_id = category_id;
		tex_package_id = make_texttt_string(package_id);
		tex_package_purpose = package_purpose;
		tex_package_description = package_description;
		line_no = _N_;
	run;
	quit;

	proc sort data = &iods_packages.;
		by
			package_id
		;
	run;
	quit;

	%&RSULogger.PutInfo(パッケージの詳細情報 TeX変換)
	data &iods_package_details.;
		attrib
			tex_package_id length = $50.
			tex_package_detail length = $30000.
		;
		set &iods_package_details.;
		tex_package_id = make_texttt_string(package_id);
		tex_package_detail = package_detail;
	run;
	quit;

	%SetAggregation(iods_base = &iods_packages.
							, ids_source = &iods_package_details.
							, i_agg_var = package_id
							, i_flag_var = has_detail)

	%&RSULogger.PutInfo(パッケージの注釈 TeX変換)
	data &iods_package_notes.;
		attrib
			tex_package_id length = $50.
			tex_package_note length = $2000.
		;
		set &iods_package_notes.;
		tex_package_id = make_texttt_string(package_id);
		tex_package_note = package_note;
	run;
	quit;

	%SetAggregation(iods_base = &iods_packages.
							, ids_source = &iods_package_notes.
							, i_agg_var = package_id
							, i_flag_var = has_note)

	proc sort data = &iods_packages.;
		by
			line_no
		;
	run;
	quit;
%mend Pkg__ConvertIntoTeXCode;
