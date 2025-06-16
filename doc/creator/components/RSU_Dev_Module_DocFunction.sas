%RSUSetConstant(PkgFunc, PkgFunc__)

/*********************************************************/
/* パッケージ関数情報
/*		- 関数一覧
/*			> package_id
/*			> function_id
/*			> function_description
/*			> function_return
/*
/*		- 関数定義
/*			> function_id
/*			> function_def_code
/*
/*		- 関数引数
/*			> function_id
/*			> function_arg_description
/*			> function_arg_var
/*			> is_required
/*
/*		- 関数詳細説明
/*			> function_id
/*			> function_detail
/*
/*		- 関数詳細注意
/*			> function_id
/*			> function_note
/*********************************************************/
%macro PkgFunc__GatherDocInformation(ids_module_ds =
												, ods_package_functions =
												, ods_class_functions =
												, ods_function_definition =
												, ods_function_arguments =
												, ods_function_details =
												, ods_function_notes =);
	%&RSULogger.PutNote(パッケージ関数レベル情報収集)
	%GatherFunctionInfoHelper(ids_module_ds = &ids_module_ds.
										, ods_functions_ds = &ods_package_functions.
										, i_owner_id_var_name = package_id
										, i_owner_bock_tag = PackageID)

	%&RSULogger.PutNote(クラス関数レベル情報収集)
	%GatherFunctionInfoHelper(ids_module_ds = &ids_module_ds.
										, ods_functions_ds = &ods_class_functions.
										, i_owner_id_var_name = class_id
										, i_owner_bock_tag = ClassID)

	/* 定義 */
	%&RSULogger.PutNote(パッケージ関数定義)
	data &ods_function_definition.(keep = function_name function_id function_def_code);
		attrib
			parent_obj_id length = $50.
			function_name length = $100.
			function_id length = $100.
			function_def_code length = $500.
		;
		set &ids_module_ds.;
		_regex_package_id = prxparse('/^\/\*<PackageID>(.+)<\/PackageID>\*\/$/o');
		_regex_class_start = prxparse('/^\/\*<ClassID>(.+)<\/ClassID>\*\/$/o');
		_regex_function_def_start = prxparse('/^%macro\s+([^;\(]+)/o');
		_regex_comment_code = prxparse('/^\/\*/o');
		_regex_function_def_end = prxparse('/;$/o');

		retain parent_obj_id;
		retain function_name;
		retain function_id;
		retain _is_function_defined;
		if (prxmatch(_regex_package_id, trim(code))) then do;
			parent_obj_id = prxposn(_regex_package_id, 1, trim(code));
		end;
		if (prxmatch(_regex_class_start, trim(code))) then do;
			parent_obj_id = prxposn(_regex_class_start, 1, trim(code));
		end;
		if (prxmatch(_regex_function_def_start, trim(code))) then do;
			function_name = prxposn(_regex_function_def_start, 1, trim(code));
			function_id = catx('_', trim(parent_obj_id), trim(function_name));
			_is_function_defined = 1;
		end;
		if (_is_function_defined = 1) then do;
			if (not prxmatch(_regex_comment_code, strip(code))) then do;
				function_def_code = trim(code);
				output;			
			end;
		end;
		if (prxmatch(_regex_function_def_end, trim(code))) then do;
			function_name = '';
			function_id = '';
			_is_function_defined = 0;
		end;
	run;
	quit;
	
	%&RSULogger.PutInfo(関数引数情報収集)
	data 
		WORK.tmp_function_args(keep = lineno function_name function_id function_arg_description function_arg_var)
		WORK.tmp_required_args(keep = lineno function_name function_id function_arg_required)
		;
		attrib
			parent_obj_id length = $50.
			function_name length = $100.
			function_id length = $100.
			function_arg_description length = $500.
			function_arg_var length = $50.
			function_arg_required length = $200.
		;
		set &ids_module_ds.;
		_regex_package_id = prxparse('/^\/\*<PackageID>(.+)<\/PackageID>\*\/$/o');
		_regex_class_start = prxparse('/^\/\*<ClassID>(.+)<\/ClassID>\*\/$/o');
		_regex_function_start = prxparse('/^%macro\s+([^;\(]+)/o');
		_regex_func_arg_desc = prxparse("/^\/\*<FunctionArgDesc &g_locale.>(.+)<\/FunctionArgDesc &g_locale.>\*\/$/o");
		_regex_func_arg_def = prxparse("/^\s*(,\s*)?([\w]+)\s*(=)?(.+)?$/o");
		_regex_func_arg_req = prxparse('/^\s*%&RSUUtil\.VerifyRequiredArgs\(i_args\s*=\s*([^\)]+)\s*\)$/o');
		_regex_function_end = prxparse('/^%mend\s+([^;\s]+);$/o');

		retain parent_obj_id;
		retain function_name;
		retain function_id;
		retain function_arg_description;
		retain _is_function_defined;
		retain _is_arg_desc_defined;
		if (prxmatch(_regex_package_id, trim(code))) then do;
			parent_obj_id = prxposn(_regex_package_id, 1, trim(code));
		end;
		if (prxmatch(_regex_class_start, trim(code))) then do;
			parent_obj_id = prxposn(_regex_class_start, 1, trim(code));
		end;
		if (prxmatch(_regex_function_start, trim(code))) then do;
			function_name = prxposn(_regex_function_start, 1, trim(code));
			function_id = catx('_', trim(parent_obj_id), trim(function_name));
			_is_function_defined = 1;
		end;
		if (_is_function_defined = 1) then do;
			if (prxmatch(_regex_func_arg_desc, trim(code))) then do;
				function_arg_description = prxposn(_regex_func_arg_desc, 1, trim(code));
				_is_arg_desc_defined = 1;
			end;
			if (_is_arg_desc_defined = 1) then do;
				if (prxmatch(_regex_func_arg_def, trim(code))) then do;
					function_arg_var = prxposn(_regex_func_arg_def, 2, trim(code));
					output WORK.tmp_function_args;
					function_arg_description = '';
					_is_arg_desc_defined = 0;
				end;
			end;
			if (prxmatch(_regex_func_arg_req, trim(code))) then do;
				function_arg_required = prxposn(_regex_func_arg_req, 1, trim(code));
				output WORK.tmp_required_args;
			end;
			if (prxmatch(_regex_function_end, trim(code)) and _is_function_defined = 1) then do;
				function_name = '';
				function_id = '';
				_is_function_defined = 0;
			end;
		end;
	run;
	quit;

	/* 必須引数 */
	data WORK.tmp_required_args_rows(keep = function_id function_arg_var is_required);
		set WORK.tmp_required_args;
		attrib
			function_arg_var length = $50.
		;
		_index = 1;
		function_arg_var = scan(function_arg_required, _index, ' ');
		do while(not missing(function_arg_var));
			is_required = 1;
			output;
			_index = _index + 1;
			function_arg_var = scan(function_arg_required, _index, ' ');
		end;
	run;
	quit;
	%&RSUDS.Delete(WORK.tmp_required_args)

	/* マージ */
	proc sort data = WORK.tmp_function_args;
		by
			function_id
			function_arg_var
		;
	run;
	quit;

	proc sort data = WORK.tmp_required_args_rows;
		by
			function_id
			function_arg_var
		;
	run;
	quit;

	data WORK.function_args;
		merge
			WORK.tmp_function_args(in = in1)
			WORK.tmp_required_args_rows(in = in2)
		;
		by
			function_id
			function_arg_var
		;
		if (in1) then do;
			output;
		end;
	run;
	quit;

	proc sort data = WORK.function_args out = &ods_function_arguments.;
		by
			lineno
		;
	run;
	quit;
	%&RSUDS.Delete(WORK.tmp_function_args WORK.function_args WORK.tmp_required_args_rows)

	%&RSULogger.PutInfo(関数詳細情報収集)
	data &ods_function_details.(keep = function_name function_id function_detail);
		attrib
			parent_obj_id length = $50.
			function_name length = $100.
			function_id length = $100.
			function_detail length = $2000.
		;
		set &ids_module_ds.;
		_regex_package_id = prxparse('/^\/\*<PackageID>(.+)<\/PackageID>\*\/$/o');
		_regex_class_start = prxparse('/^\/\*<ClassID>(.+)<\/ClassID>\*\/$/o');
		_regex_function_start = prxparse('/^%macro\s+([^;\(]+)/o');
		_regex_function_detail_start = prxparse("/^\/\*<FunctionDetail &g_locale.>$/o");
		_regex_function_detail_end = prxparse("/^<\/FunctionDetail &g_locale.>\*\/$/o");
		_regex_function_end = prxparse('/^%mend\s+([^;\s]+);$/o');

		retain parent_obj_id;
		retain function_name;
		retain function_id;
		retain _is_in_detail 0;
		if (prxmatch(_regex_package_id, trim(code))) then do;
			parent_obj_id = prxposn(_regex_package_id, 1, trim(code));
		end;
		if (prxmatch(_regex_class_start, trim(code))) then do;
			parent_obj_id = prxposn(_regex_class_start, 1, trim(code));
		end;
		if (prxmatch(_regex_function_start, trim(code))) then do;
			function_name = prxposn(_regex_function_start, 1, trim(code));
			function_id = catx('_', trim(parent_obj_id), trim(function_name));
		end;
		if (prxmatch(_regex_function_end, trim(code))) then do;
			function_name = '';
			function_id = '';
		end;
		if (_is_in_detail = 0) then do;
			if (prxmatch(_regex_function_detail_start, trim(code))) then do;
				_is_in_detail = 1;
			end;
		end;
		else do;
			if (prxmatch(_regex_function_detail_end, trim(code))) then do;
					_is_in_detail = 0;
			end;
			else do;
				function_detail = strip(code);
				output;
			end;
		end;
	run;
	quit;	
	%&RSULogger.PutInfo(関数注釈情報収集)
	data &ods_function_notes.(keep = function_name function_id function_note);
		attrib
			parent_obj_id length = $50.
			function_name length = $100.
			function_id length = $100.
			function_note length = $2000.
		;
		set &ids_module_ds.;
		_regex_package_id = prxparse('/^\/\*<PackageID>(.+)<\/PackageID>\*\/$/o');
		_regex_class_start = prxparse('/^\/\*<ClassID>(.+)<\/ClassID>\*\/$/o');
		_regex_function_start = prxparse('/^%macro\s+([^;\(]+)/o');
		_regex_function_note_start = prxparse("/^\/\*<FunctionNote &g_locale.>$/o");
		_regex_function_note_end = prxparse("/^<\/FunctionNote &g_locale.>\*\/$/o");
		_regex_function_end = prxparse('/^%mend\s+([^;\s]+);$/o');

		retain parent_obj_id;
		retain function_name;
		retain function_id;
		retain _is_in_note 0;
		if (prxmatch(_regex_package_id, trim(code))) then do;
			parent_obj_id = prxposn(_regex_package_id, 1, trim(code));
		end;
		if (prxmatch(_regex_class_start, trim(code))) then do;
			parent_obj_id = prxposn(_regex_class_start, 1, trim(code));
		end;
		if (prxmatch(_regex_function_start, trim(code))) then do;
			function_name = prxposn(_regex_function_start, 1, trim(code));
			function_id = catx('_', trim(parent_obj_id), trim(function_name));
		end;
		if (prxmatch(_regex_function_end, trim(code))) then do;
			function_name = '';
			function_id = '';
		end;
		if (_is_in_note = 0) then do;
			if (prxmatch(_regex_function_note_start, trim(code))) then do;
				_is_in_note = 1;
			end;
		end;
		else do;
			if (prxmatch(_regex_function_note_end, trim(code))) then do;
					_is_in_note = 0;
			end;
			else do;
				function_note = strip(code);
				output;
			end;
		end;
	run;
	quit;	

%mend PkgFunc__GatherDocInformation;

%macro GatherFunctionInfoHelper(ids_module_ds = 
										, ods_functions_ds =
										, i_owner_id_var_name =
										, i_owner_bock_tag =);
	data &ods_functions_ds.(keep = &i_owner_id_var_name. function_name function_id function_description function_return);
		attrib
			&i_owner_id_var_name. length = $50.
			function_name length = $100.
			function_id length =$100.
			function_description length = $200.
			function_return length = $200.
		;
		set &ids_module_ds.;
		_regex_owner_section_start = prxparse("/^\/\*<&i_owner_bock_tag.>(.+)<\/&i_owner_bock_tag.>\*\/$/o");
		_regex_owner_section_end = prxparse('/^\/\*<EndOfPackage\/>\*\/$/o');
		_regex_function_description = prxparse("/^\/\*<FunctionDesc &g_locale.>(.+)<\/FunctionDesc &g_locale.>\*\/$/o");
		_regex_function_return = prxparse("/^\/\*<FunctionReturn &g_locale.>(.+)<\/FunctionReturn &g_locale.>\*\/$/o");
		_regex_function_start = prxparse('/^%macro\s+([^;\(]+)/o');
		_regex_function_end = prxparse('/^%mend\s+([^;\s]+);$/o');

		retain &i_owner_id_var_name.;
		retain function_description;
		retain function_return;
		retain function_name;
		retain function_id;
		retain _is_owner_defined;
		retain _is_function_defined;
		if (prxmatch(_regex_owner_section_start, trim(code))) then do;
			&i_owner_id_var_name. = prxposn(_regex_owner_section_start, 1, trim(code));
			_is_owner_defined = 1;
		end;
		if (_is_owner_defined = 1) then do;
			if (prxmatch(_regex_function_description, trim(code))) then do;
				function_description = prxposn(_regex_function_description, 1, trim(code));
				_is_function_defined = 1;
			end;
			if (_is_function_defined = 1) then do;
				if (prxmatch(_regex_function_return, trim(code))) then do;
					function_return = prxposn(_regex_function_return, 1, trim(code));
				end;
				if (prxmatch(_regex_function_start, trim(code))) then do;
					function_name = prxposn(_regex_function_start, 1, trim(code));
					function_id = catx('_', trim(&i_owner_id_var_name.), trim(function_name));
					/* ! 特別処理 */
					if (function_name = '<instance>.') then do;
						function_name = '<instance>';
					end;
				end;

				if (prxmatch(_regex_function_end, trim(code))) then do;
					output;
					function_description = '';
					function_return = '';
					function_name = '';
					function_id = '';
					_is_function_defined = 0;
				end;
			end;

			if (prxmatch(_regex_owner_section_end, trim(code))) then do;
				&i_owner_id_var_name. = '';
				_is_owner_defined = 0;
			end;
		end;
	run;
	quit;
%mend GatherFunctionInfoHelper;

%macro PkgFunc__ConvertIntoTeXCode(iods_package_functions =
												, iods_class_functions =
												, iods_function_arguments =
												, iods_function_details =
												, iods_function_notes =
												, iods_function_definition =);
	%ConvertIntoTeXCodeHelperFunc(iods_function_arguments = &iods_function_arguments.
											, iods_function_details = &iods_function_details.
											, iods_function_notes = &iods_function_notes.
											, iods_function_definition = &iods_function_definition.)
	%ConvertIntoTeXCodeHelper(iods_functions_ds = &iods_package_functions.
									, ids_function_arguments = &iods_function_arguments.
									, ids_function_details = &iods_function_details.
									, ids_function_notes = &iods_function_notes.
									, ids_function_definition = &iods_function_definition.
									, i_owner_id_var_name = package_id)
	%ConvertIntoTeXCodeHelper(iods_functions_ds = &iods_class_functions.
									, ids_function_arguments = &iods_function_arguments.
									, ids_function_details = &iods_function_details.
									, ids_function_notes = &iods_function_notes.
									, ids_function_definition = &iods_function_definition.
									, i_owner_id_var_name = class_id)
%mend PkgFunc__ConvertIntoTeXCode;

%macro ConvertIntoTeXCodeHelperFunc(iods_function_arguments =
												, iods_function_details =
												, iods_function_notes =
												, iods_function_definition =);
	/* 定義 */
	data &iods_function_definition.;
		set &iods_function_definition. end = eof;
		attrib
			tex_function_name length = $100.
			tex_function_def_code length = $500.
		;
		tex_function_name = make_texttt_string(function_name);
		tex_function_def_code = function_def_code;
		if (1 < _N_) then do;
			if (eof) then do;
				tex_function_def_code = cat('       ', tex_function_def_code);
			end;
			else do;
				tex_function_def_code = cat('    ', tex_function_def_code);
			end;
		end;
	run;
	quit;
	
	/* 引数 */
	data &iods_function_arguments.;
		set &iods_function_arguments.;
		attrib
			tex_function_name length = $100.
			tex_function_arg_description length = $500.
			tex_function_arg_var length = $50.
			tex_is_required length = $200.
		;
		tex_function_name = make_texttt_string(function_name);
		tex_function_arg_description = function_arg_description;
		tex_function_arg_var = make_texttt_string(function_arg_var);
		if (is_required = 1) then do;
			tex_is_required = '\ding{51}';
		end;
		else do;
			tex_is_required = '';
		end;
	run;
	quit;

	/* 詳細 */
	data &iods_function_details.;
		set &iods_function_details.;
		attrib
			tex_function_name length = $100.
			tex_function_detail length = $2000.
		;
		tex_function_name = make_texttt_string(function_name);
		tex_function_detail = function_detail;
	run;
	quit;

	/* 注釈 */
	data &iods_function_notes.;
		set &iods_function_notes.;
		attrib
			tex_function_name length = $100.
			tex_function_note length = $2000.
		;
		tex_function_name = make_texttt_string(function_name);
		tex_function_note = function_note;
	run;
	quit;
%mend ConvertIntoTeXCodeHelperFunc;

%macro ConvertIntoTeXCodeHelper(iods_functions_ds =
										, ids_function_arguments =
										, ids_function_details =
										, ids_function_notes =
										, ids_function_definition =
										, i_owner_id_var_name =);
	data &iods_functions_ds.;
		set &iods_functions_ds.;
		attrib
			tex_&i_owner_id_var_name. length = $50.
			tex_function_name_short length = $50.
			tex_function_name length = $100.
			tex_function_description length = $200.
			tex_function_return length = $200.
		;
		tex_&i_owner_id_var_name. = make_texttt_string(&i_owner_id_var_name.);
		_regex_instance = prxparse('/^<instance>(.+)$/o');
		if (prxmatch(_regex_instance, function_id)) then do;
			tex_function_name_short = trim(prxposn(_regex_instance, 1, function_name));
			tex_function_name = cats('.', trim(tex_function_name_short));
			tex_function_name = cats('\texttt{\%\&}{\it <instance>}', trim(make_texttt_string(tex_function_name)));
		end;
		if (prxmatch('/__/', function_name)) then do;
			tex_function_name = cats('%&', prxchange('s/__/./o', -1, function_name));
			tex_function_name_short = scan(tex_function_name, -1, '.');
			tex_function_name = make_texttt_string(tex_function_name);
		end;
		else do;
			tex_function_name = cats('%', trim(function_name));
			tex_function_name_short = scan(tex_function_name, -1, '>');
			tex_function_name = make_texttt_string(tex_function_name);
		end;
		tex_function_name_short = make_texttt_string(tex_function_name_short);
		tex_function_description = function_description;
		if (missing(function_return)) then do;
			has_return = 0;
		end;
		else do;
			has_return = 1;
			tex_function_return = function_return;
		end;
	run;
	quit;

	proc sort data = &iods_functions_ds.;
		by
			function_id
		;
	run;
	quit;

	%SetAggregation(iods_base = &iods_functions_ds.
						, ids_source = &ids_function_arguments.
						, i_agg_var = function_id
						, i_flag_var = has_argument)
	%SetAggregation(iods_base = &iods_functions_ds.
						, ids_source = &ids_function_details.
						, i_agg_var = function_id
						, i_flag_var = has_detail)
	%SetAggregation(iods_base = &iods_functions_ds.
						, ids_source = &ids_function_notes.
						, i_agg_var = function_id
						, i_flag_var = has_note)
%mend ConvertIntoTeXCodeHelper;
