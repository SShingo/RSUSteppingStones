%RSUSetConstant(LaTeX, LaTeX__)

/**=============================================**/
/*	ロケール対応LaTeXマクロコマンド定義
/*	
/*	NOTE: [in]  latex_template/doc_message.txt
/* NOTE: [out] source/<locale>/message_command.tex	
/**=============================================**/
%macro LaTeX__CreateLaTeXCommand(i_command_template_path =
											, i_latex_source_path =
											, i_locale =);
	%&RSULogger.PutSubsection(Creating user-defined latex commands)
	data WORK.latex_macro_def;
		attrib
			latex_macro_name length = $50.
			latex_macro_value_ja_jp length = $100.
			latex_macro_value_en_us length = $100.
		;
		stop;
	run;
	quit;
	%&RSUDS.LoadTextIntoFrame(i_file_path = &i_command_template_path.
										, iods_frame_ds = WORK.latex_macro_def
										, i_delimiter = &RSUTab.)
	data _null_;
		set WORK.latex_macro_def;
		file "&i_latex_source_path.";
		attrib
			_command length = $200.
		;
		_command = cats('\def\', latex_macro_name, '{', latex_macro_value_&i_locale., '}');
		put _command;
	run;
	quit;
	%&RSUDS.Delete(WORK.latex_macro_def)
%mend LaTeX__CreateLaTeXCommand;

/**=============================================**/
/*	ドキュメントタイトル
/*	
/*	NOTE: [in]  なし
/* NOTE: [out] source/<locale>/title.tex	
/**=============================================**/
%macro LaTeX__CreateTitle(i_latex_source_path =);
	%&RSULogger.PutSubsection(Creating document title
									, Version: %&RSUSys.GetVersion(i_formatting = %&RSUBool.True))
	%local _writer;   
   %let _writer = %&RSUFile.CreateWriter(i_file_path = &i_latex_source_path.);
	%&_writer.PutLine(\title{\RDM\copyright\;ver. %&RSUSys.GetVersion(i_formatting = %&RSUBool.True)})
	%&RSUClass.Dispose(_writer)
%mend LaTeX__CreateTitle;

/**=============================================**/
/* 静的（Stepping Stonesのソースコードの内容に依存しない部分）のLaTeXコード作成
/*
/* NOTE: テンプレートをすべて読み込んでデータセット化
/* NOTE: 連結キー file_nameをセット
/**=============================================**/
%macro LaTeX__StaticLaTeXCode(iods_latex_source_code_ds =
										, i_locale =);
	%&RSULogger.PutSubsection(Creating LaTeX code independent from source code)
	%&RSUDirectory.GetContents(i_dir_path = &g_template_dir./static/&i_locale.
								, ods_output_ds = WORK.static_latex_templates
								, i_content_type =%&RSUFileType.File)
	%local _entry_full_path;
	%local _dsid_template_file;
	%local _template_file_name_body;
	%do %while(%&RSUDS.ForEach(i_query = WORK.static_latex_templates, i_vars = _entry_full_path:_entry_full_path, ovar_dsid = _dsid_template_file));
		%let _template_file_name_body = %&RSUFile.GetFileName(&_entry_full_path.
																				, i_extension = %&RSUBool.False);
		%&RSULogger.PutInfo(Processing &_template_file_name_body...)
		data WORK.static_latex_template_code;
			attrib
				latex_code_src length = $30000.
				file_name length = $100.
			;
			infile "&_entry_full_path." delimiter = &RSUNULL. dsd missover firstobs = 1;
			input
				latex_code_src
			;
			file_name = "&_template_file_name_body.";
		run;
		quit;
		%&RSUDS.Append(iods_base_ds = &iods_latex_source_code_ds.
							, ids_data_ds = WORK.static_latex_template_code)
		%&RSUDS.Delete(WORK.static_latex_template_code)
	%end;
	%&RSUDS.Delete(WORK.static_latex_templates)
%mend LaTeX__StaticLaTeXCode;

/**=============================================**/
/* 動的（Stepping Stonesのソースコードの内容に依存する部分）のLaTeXコード作成
/*
/* NOTE: テンプレートをすべて読み込んでデータセット化
/* NOTE: 連結キー file_nameをセット
/**=============================================**/
%macro LaTeX__CreateDynamicLaTeXCode(i_template_filename_body =
												, i_file_name_def =
												, i_sort_keys =
												, ids_source_ds =
												, iods_latex_source_code_ds =);
	%if (%&RSUDS.IsDSEmpty(&ids_source_ds.)) %then %do;
		%&RSULogger.PutNote(No source... Skipped)
		%return;
	%end;
	%else %do;
		%&RSULogger.PutSubsection(Creating LaTeX code depending to source code
										, Source dataset: &ids_source_ds.
										, Template: &i_template_filename_body.
										, Output filename(definition): &i_file_name_def.)
		
		/* Templateファイルパース */
		%local /readonly _TEMPLATE_FILE = &g_template_dir./dynamic/&i_template_filename_body..txt;
		data WORK.tmp_latex_source(keep = _code_templ _template_code_line_no);
			attrib
				_code_templ length = $30000.
				_latex_code length = $10000.
			;
			infile "&_TEMPLATE_FILE." delimiter = &RSUTab. dsd missover firstobs = 1;
			input
				_code_templ
			;
			_regex_latex_line = prxparse('/<#LATEX>(.+)<\/#LATEX>/');
			if (prxmatch(_regex_latex_line, _code_templ)) then do;
				_latex_code = prxposn(_regex_latex_line, 1, _code_templ);
			end;
			_regex_var_val_open = prxparse('s/<RSU_VAR_VAL>/",trim(/o');
			_regex_var_val_close = prxparse('s/<\/RSU_VAR_VAL>/),"/o');
			_latex_code = prxchange(_regex_var_val_open, -1, _latex_code);
			_latex_code = prxchange(_regex_var_val_close, -1, _latex_code);
			_latex_code = cats('latex_code_src = cats("', _latex_code, '"); output;');
			_code_templ = prxchange(cats('s/<#LATEX>(.+)<\/#LATEX>/', _latex_code, '/'), -1, _code_templ);
			_template_code_line_no = _N_;
		run;
		quit;

		data WORK.tmp_source;
			set &ids_source_ds.;
			attrib
				file_name length = $100.
			;
			file_name = &i_file_name_def.;
		run;
		quit;

		proc sort data = WORK.tmp_source out = WORK.tmp_source;
			by
				&i_sort_keys.
			;
		run;
		quit;

		data WORK.tmp_source;
			set WORK.tmp_source;
			_source_line_no = _N_;
		run;
		quit;

		%&RSUDS.CrossJoin(ids_lhs_ds = WORK.tmp_source
								, ids_rhs_ds = WORK.tmp_latex_source
								, ods_output_ds = WORK.tmp_latex_source_expanded)
		%&RSUDS.Delete(WORK.tmp_source WORK.tmp_latex_source)

		proc sort data = WORK.tmp_latex_source_expanded out = WORK.tmp_latex_source_expanded(drop = _template_code_line_no _source_line_no);
			by
				_source_line_no
				_template_code_line_no
			;
		run;
		quit;

		/* 文字列コードを実行 */
		/* ! TCFD on Stratum の数式評価と同じ !!! */
		data _null_;
			set tmp_latex_source_expanded end = eof;
			if (_N_ = 1) then do;
				call execute("data WORK.dynamic_latex_template_code; attrib latex_code_src length = $30000.; set WORK.tmp_latex_source_expanded;");
			end;
			call execute(cats('if (_N_ = ', _N_, ') then do;', _code_templ, ' end;'));
			if (eof) then do;
				call execute('run; quit;');
			end;
		run;
		%&RSUDS.Delete(WORK.tmp_latex_source_expanded)

		data WORK.dynamic_latex_template_code(keep = latex_code_src file_name);
			set WORK.dynamic_latex_template_code;
		run;
	%end;
	%&RSUDS.Append(iods_base_ds = &iods_latex_source_code_ds.
						, ids_data_ds = WORK.dynamic_latex_template_code)
	%&RSUDS.Delete(WORK.dynamic_latex_template_code)

%mend LaTeX__CreateDynamicLaTeXCode;

/**===========================================**/
/* 統合ドキュメント作成
/**===========================================**/
%macro LaTeX__CreateIntegratedDocument(i_file_path = 
													, ids_latex_source_code_ds =);
	%&RSULogger.PutSubsection(Intergate all files...)
	data WORK.tmp_latex_source_ds;
		set &ids_latex_source_code_ds.;
		line_no_child = _N_;
	run;
	quit;
	proc sort data = WORK.tmp_latex_source_ds;
		by
			file_name
		;
	run;
	quit;

	data WORK.tmp_outline;
		attrib
			latex_code length = $30000.
		;
		infile "&i_file_path." delimiter = &RSUNULL. dsd missover firstobs = 1;
		input
			latex_code
		;
	run;
	quit;
	/* LaTeXコードの融合 */
	%local _safty_count; 
	%do _safty_count = 1 %to 10;
		%&RSULogger.PutNote(Processing @depth = &_safty_count.)
		data WORK.tmp_outline;
			set WORK.tmp_outline;
			attrib
				file_name length = $100.
			;
			line_no_parent = _N_;
			if (prxmatch('/^<#INPUT>/o', trim(latex_code))) then do;
				file_name = prxchange('s/<#INPUT>//o', -1, latex_code);
				latex_code = '';
			end;
		run;
		quit;

		%if (%&RSUDS.IsDSEmpty(WORK.tmp_outline(where = (not missing(file_name))))) %then %do;
			/* すべての<#INPUT>置換完了 */
			%goto _leave_loop;
		%end;

		proc sort data = WORK.tmp_outline;
			by
				file_name
			;
		run;
		quit;

		data WORK.tmp_outline;
			merge
				WORK.tmp_outline(in = in1)
				WORK.tmp_latex_source_ds(in = in2)
			;
			by
				file_name
			;
			if (in1) then do;
				if (in2) then do;
					latex_code = latex_code_src;
				end;
				output;
			end;
		run;
		quit;

		proc sort data = WORK.tmp_outline out = WORK.tmp_outline(keep = latex_code);
			by
				line_no_parent
				line_no_child
			;
		run;
		quit;
	%end;
%_leave_loop:
	/* Output LaTeX Source Code to File */
	data _null_;
		set WORK.tmp_outline;
		file "&g_latex_source_dir./outline.tex";
		put latex_code;
	run;
	quit;
	%&RSUDS.Delete(WORK.tmp_outline WORK.tmp_latex_source_ds)
%mend LaTeX__CreateIntegratedDocument;