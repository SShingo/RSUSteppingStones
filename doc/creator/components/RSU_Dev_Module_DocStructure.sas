%RSUSetConstant(Struct, Struct__)

/*********************************************************/
/* 構造体情報
/*		- 構造体一覧
/*			> structure_id
/*			> structure_description
/*
/*		- 構造体メンバー一覧
/*			> structure_id
/*			> structure_mem_id
/*			> structure_mem_value
/*			> structure_mem_description
/*********************************************************/
%macro Struct__GatherDocInformation(ids_module_ds =
												, ods_structures =
												, ods_structure_members =);
	%&RSULogger.PutInfo(構造体情報収集)
	data  &ods_structures.(keep = structure_id structure_description);
		attrib
			structure_id length = $100.
			structure_description length = $200.
		;
		set &ids_module_ds.;
		_regex_structure_description = prxparse("/^\/\*<StructureDesc &g_locale.>(.+)<\/StructureDesc &g_locale.>\*\/$/o");
		_regex_structure_definition = prxparse('/^\s*%RSUSetConstant\((\w+),\s*(\w+)\)$/o');	
		_regex_structure_end = prxparse('/^\/\*<EndOfStructure>\*\/$/o');

		retain structure_id;
		retain structure_description;
		retain _is_structure_defined;
		if (prxmatch(_regex_structure_description, trim(code))) then do;
			structure_description = prxposn(_regex_structure_description, 1, trim(code));
			_is_structure_defined= 1;
		end;
		if (_is_structure_defined = 1) then do;
			if (prxmatch(_regex_structure_definition, trim(code))) then do;
				structure_id = prxposn(_regex_structure_definition, 1, trim(code));
			end;
			if (prxmatch(_regex_structure_end, trim(code))) then do;
				output;
				structure_id = '';
				structure_description = '';
				_is_structure_defined = 0;
			end;
		end;
	run;
	quit;

	%&RSULogger.PutInfo(構造体メンバー情報収集)
	data &ods_structure_members.(keep = structure_id structure_mem_description structure_mem_id structure_mem_value);
		attrib
			structure_id length = $100.
			structure_mem_id length = $100.
			structure_mem_value length = $20.
			structure_mem_description length = $100.
		;
		set &ids_module_ds.;
		_regex_structure_description = prxparse("/^\/\*<StructureDesc &g_locale.>(.+)<\/StructureDesc &g_locale.>\*\/$/o");
		_regex_structure_definition = prxparse('/^\s*%RSUSetConstant\((\w+),\s*(\w+)\)$/o');	
		_regex_structure_end = prxparse('/^\/\*<EndOfStructure>\*\/$/o');
		_regex_structure_mem_description = prxparse("/^\/\*<StructMemberDesc &g_locale.>(.+)<\/StructMemberDesc &g_locale.>\*\/$/o");
		_regex_structure_mem_id = prxparse('/^\s*%macro\s+(RSU\w+)__(\w+);$/o');
		_regex_structure_mem_end = prxparse('/^\s*%mend\s+(\w+);$/o');

		retain structure_id;
		retain structure_mem_id;
		retain structure_mem_description;
		retain _is_structure_defined;
		retain _is_structure_mem_defined;
		if (prxmatch(_regex_structure_description, trim(code))) then do;
			_is_structure_defined= 1;
		end;
		if (_is_structure_defined = 1) then do;
			if (prxmatch(_regex_structure_definition, trim(code))) then do;
				structure_id = prxposn(_regex_structure_definition, 1, trim(code));
			end;
			if (prxmatch(_regex_structure_mem_description, trim(code))) then do;
				structure_mem_description = prxposn(_regex_structure_mem_description, 1, trim(code));
				_is_structure_mem_defined = 1;
			end;
			else if (prxmatch(_regex_structure_mem_end, trim(code))) then do;
				structure_mem_id = '';
				structure_mem_description = '';
				_is_structure_mem_defined = 0;
			end;
			else do;
				if (_is_structure_mem_defined) then do;
					if (prxmatch(_regex_structure_mem_id, trim(code))) then do;
						structure_mem_id = prxposn(_regex_structure_mem_id, 2, trim(code));
					end;
					else do;
						structure_mem_value = trim(code);
						output;
					end;
				end;
				if (prxmatch(_regex_structure_end, trim(code)) and _is_structure_defined = 1) then do;
					structure_id = '';
					_is_structure_defined = 0;
				end;
			end;
		end;
	run;
	quit;
%mend Struct__GatherDocInformation;

%macro Struct__ConvertIntoTeXCode(iods_structures =
												, iods_structure_members =);
	data  &iods_structures.;
		set &iods_structures.;
		attrib
			tex_structure_id length = $100.
		;
		tex_structure_id = make_texttt_string(structure_id);
	run;
	quit;

	data &iods_structure_members.;
		set &iods_structure_members.;
		attrib
			tex_structure_id length = $100.
			tex_structure_mem_id length = $100.
			tex_structure_mem_value length = $20.
		;
		tex_structure_id = make_texttt_string(structure_id);
		tex_structure_mem_id = make_texttt_string(structure_mem_id);
		tex_structure_mem_value = make_texttt_string(structure_mem_value);
	run;
	quit;
%mend Struct__ConvertIntoTeXCode;