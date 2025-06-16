%RSUSetConstant(Format, Format__)

/*********************************************************/
/* フォーマット情報
/*		- フォーマット一覧
/*			> format_id
/*			> format_name
/*			> format_description
/*			> format_type（未使用）
/*
/*		- フォーマット項目一覧
/*			> format_id
/*			> format_lhs
/*			> format_rhs
/*********************************************************/
%macro Format__GatherDocInformation(ids_module_ds =
												, ods_formats =
												, ods_format_components =);
	%&RSULogger.PutNote(フォーマット情報収集)
	data &ods_formats(keep = format_id format_name format_description format_type);
		attrib
			format_id length = $100.
			format_name length = $100.
			format_description length = $200.
			format_type length = $1.
		;
		set &ids_module_ds.;
		_regex_format_description = prxparse("/^\/\*<FormatDesc &g_locale.>(.+)<\/FormatDesc &g_locale.>\*\/$/o");
		_regex_format_name = prxparse('/^\s*value\s+((\$?)(\w+))$/o');	
		_regex_format_end = prxparse("/^\s*;$/o");

		retain format_id;
		retain format_description;
		retain format_name;
		retain format_type;
		retain _is_format_defined;
		if (prxmatch(_regex_format_description, trim(code))) then do;
			format_description = prxposn(_regex_format_description, 1, trim(code));
			_is_format_defined= 1;
		end;
		if (_is_format_defined = 1) then do;
			if (prxmatch(_regex_format_name, trim(code))) then do;
				format_name = prxposn(_regex_format_name, 1, trim(code));
				if (substr(format_name, 1, 1) = '$') then do;
					format_type = 'c';
				end;
				else do;
					format_type = 'n';
				end;
				format_id = prxchange('s/\$//o', -1, format_name);
			end;
			if (prxmatch(_regex_format_end, trim(code))) then do;
				output;
				format_name = '';
				format_type = '';
				format_description = '';
				_is_format_defined = 0;
			end;
		end;
	run;
	quit;

	%&RSULogger.PutNote(フォーマット成分情報収集)
	data &ods_format_components.(keep =  format_id format_lhs format_rhs);
		attrib
			format_id length = $100.
			format_lhs length = $50.
			format_rhs length = $50.
		;
		set &ids_module_ds.;
		_regex_format_description = prxparse("/^\/\*<FormatDesc &g_locale.>(.+)<\/FormatDesc &g_locale.>\*\/$/o");
		_regex_format_id = prxparse('/^\s*value\s+(\$)?(\w+)$/o');	
		_regex_format_component = prxparse('/^\s*([^=]+)\s*=\s*(.+)$/o');
		_regex_format_end = prxparse("/^\s*;$/o");

		retain format_id;
		retain _is_format_defined;
		if (prxmatch(_regex_format_description, trim(code))) then do;
			_is_format_defined= 1;
		end;
		if (_is_format_defined = 1) then do;
			if (prxmatch(_regex_format_id, trim(code))) then do;
				format_id = prxposn(_regex_format_id, 2, trim(code));
			end;
			if (prxmatch(_regex_format_component, trim(code))) then do;
				format_lhs = prxposn(_regex_format_component, 1, trim(code));
				format_rhs = prxposn(_regex_format_component, 2, trim(code));
				output;
			end;
			if (prxmatch(_regex_format_end, trim(code)) and _is_format_defined = 1) then do;
				format_id = '';
				_is_format_defined = 0;
			end;
		end;
	run;
	quit;

%mend Format__GatherDocInformation;

%macro Format__ConvertIntoTeXCode(iods_formats =
											, iods_format_components =);
	data &iods_formats;
		set &iods_formats.;
		attrib
			tex_format_name length = $100.
			tex_format_type length = $1.
		;
		tex_format_name = make_texttt_string(format_name);
		tex_format_type = format_type;
	run;
	quit;

	data &iods_format_components.;
		set &iods_format_components.;
		attrib
			tex_format_lhs length = $50.
			tex_format_rhs length = $50.
		;
		tex_format_lhs = make_texttt_string(format_lhs);
		tex_format_rhs = make_texttt_string(format_rhs);
	run;
	quit;
%mend Format__ConvertIntoTeXCode;