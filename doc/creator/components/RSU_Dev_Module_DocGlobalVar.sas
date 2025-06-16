%RSUSetConstant(GlbVar, GlbVar__)

/*********************************************************/
/* グローバルマクロ変数情報
/*		- グローバルマクロ変数一覧
/*			> global_variable_id
/*			> global_variable_description
/*********************************************************/
%macro GlbVar__GatherDocInformation(ids_module_ds =
												, ods_global_variables =);
	%&RSULogger.PutNote(グローバル変数情報収集)
	data &ods_global_variables.(keep = global_variable_id global_variable_description);
		attrib
			global_variable_id length = $32.
			global_variable_description length = $200.
		;
		set &ids_module_ds.;
		_regex_global_var_id = prxparse('/\s*%global\s+(\w+);$/o');
		_regex_global_var_description = prxparse("/^\/\*<GlobalVariableDesc &g_locale.>(.+)<\/GlobalVariableDesc &g_locale.>\*\/$/o");

		retain global_variable_description;
		retain _is_global_var_defined;
		if (prxmatch(_regex_global_var_description, trim(code))) then do;
			global_variable_description = prxposn(_regex_global_var_description, 1, trim(code));
			_is_global_var_defined = 1;
		end;
		if (_is_global_var_defined) then do;
			if (prxmatch(_regex_global_var_id, trim(code))) then do;
				global_variable_id = prxposn(_regex_global_var_id, 1, trim(code));
				output;
				global_variable_description = '';
				_is_global_var_defined = 0;
			end;
		end;
	run;
	quit;

	proc sort data = &ods_global_variables.;
		by
			global_variable_id
		;
	run;
	quit;
%mend GlbVar__GatherDocInformation;

%macro GlbVar__ConvertIntoTeXCode(iods_global_variables =);
	data &iods_global_variables.;
		attrib
			tex_global_variable_id length = $100.
		;
		set &iods_global_variables.;
		tex_global_variable_id = make_texttt_string(global_variable_id);
	run;
	quit;
%mend GlbVar__ConvertIntoTeXCode;
