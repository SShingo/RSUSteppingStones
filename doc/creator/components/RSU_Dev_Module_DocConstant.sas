%RSUSetConstant(Const, Const__)

/*********************************************************/
/* 定数情報
/*		- 定数一覧
/*			> global_constant_id
/*			> constant_value
/*			> constant_description
/*********************************************************/
%macro Const__GatherDocInformation(ids_module_ds =
											, ods_constants =);
	%&RSULogger.PutNote(定数情報収集)
	/* 情報収集 */
	data &ods_constants.(keep = global_constant_id constant_description constant_value _use_alt_value);
		attrib
			global_constant_id length = $32.
			constant_value length = $100.
			constant_description length = $500.
			_constant_alt_value length = $500.
		;
		set &ids_module_ds.;
		_regex_constant_description = prxparse("/^\/\*<ConstantDesc &g_locale.>(.+)<\/ConstantDesc &g_locale.>\*\/$/o");
		_regex_structure_desc = prxparse("/^\/\*<StructureDesc &g_locale.>(.+)<\/StructureDesc &g_locale.>\*\/$/o");
		_regex_const_alt_val = prxparse("/^\/\*<AltValue &g_locale.>(.+)<\/AltValue &g_locale.>\*\/$/o");
		_regex_constant_def = prxparse('/^\s*%RSUSetConstant\((\w+),\s*(.+)\)$/o');	

		retain constant_description;
		retain _constant_alt_value;
		retain _is_const_defined;
		if (prxmatch(_regex_constant_description, trim(code))) then do;
			constant_description = prxposn(_regex_constant_description, 1, trim(code));
			_is_const_defined = 1;
		end;
		if (prxmatch(_regex_structure_desc, trim(code))) then do;
			constant_description = prxposn(_regex_structure_desc, 1, trim(code));
			_is_const_defined = 1;
		end;
		if (_is_const_defined = 1) then do;
			if (prxmatch(_regex_const_alt_val, trim(code))) then do;
				_constant_alt_value = prxposn(_regex_const_alt_val, 1, trim(code));
			end;
			if (prxmatch(_regex_constant_def, trim(code))) then do;
				global_constant_id = prxposn(_regex_constant_def, 1, trim(code));
				if (missing(_constant_alt_value)) then do;
					constant_value = prxposn(_regex_constant_def, 2, trim(code));
					_use_alt_value = 0;
				end;
				else do;
					constant_value = _constant_alt_value;
					_use_alt_value = 1;
				end;
				output;
				constant_description = '';
				_constant_alt_value = '';
				_is_const_defined = 0;
			end;
		end;
	run;
	quit;
%mend Const__GatherDocInformation;

%macro Const__ConvertIntoTeXCode(iods_constants =);
	data &iods_constants.;
		attrib
			tex_constant_id length = $100.
			tex_constant_value length = $100.
		;
		set &iods_constants.;
		tex_constant_id = make_texttt_string(global_constant_id);
		if (_use_alt_value = 1) then do;
			tex_constant_value = constant_value;
		end;
		else do;
			tex_constant_value = make_texttt_string(constant_value);
		end;
	run;
	quit;
%mend Const__ConvertIntoTeXCode;
